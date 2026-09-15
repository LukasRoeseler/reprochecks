## ReproAI uhbk9 - Study 1 main analysis reimplementation (clean, version-selected data)
## Replicates 'study 1 code.do': two-way cluster-robust OLS on z-scored rating,
## veracity x condition interaction, simple effects, Cohen's d, raw percentages.
source('00_lib.R')

long <- readRDS('output/study1_long_clean.rds')

## centered codings (matches .do)
long$sharingC <- long$sharing - 0.5
long$realC    <- long$real - 0.5
long$realCxsharingC <- long$realC * long$sharingC

## standardized DV (Stata egen zrating=std(rating) uses sample sd)
m <- mean(long$rating); s <- sd(long$rating)
long$zrating <- (long$rating - m) / s
long$ratingRaw <- long$rating

## ---- MAIN two-way clustered regression: zrating ~ realC sharingC inter ----
dat <- long
X  <- cbind(1, dat$realC, dat$sharingC, dat$realCxsharingC)
N  <- nrow(dat); K <- ncol(X)
fit <- lm(dat$zrating ~ X - 1)
b  <- coef(fit); u <- resid(fit)
V  <- twoway_cluster_vcov(X, u, dat$id, dat$item_num)$V
names(b) <- c('intercept','realC','sharingC','realCxsharingC')

fn <- function(cvec, label) {
  r <- wald_F(b, V, cvec, N, K)
  cat(sprintf('%-22s est=%7.4f F=%8.3f p=%8.5f t=%7.3f SE=%7.5f\n',
              label, r$est, r$F, r$p, r$t, r$se))
  c(est=r$est, F=r$F, p=r$p, t=r$t, se=r$se, df2=N-K)
}
cat('=== Study 1 main (z-scored, two-way cluster) ===\n')
cat('N=', N, ' df2=', N-K, '\n', sep='')
int  <- fn(c(0,0,0,1), 'interaction')
acc  <- fn(c(0,1,0,-0.5), 'accuracy simple effect')
shar <- fn(c(0,1,0, 0.5), 'sharing simple effect')

## Cohen's d for simple effects (esize twosample by sharing)
cat('\n=== Cohen d simple effects (raw rating) ===\n')
dcalc <- function(accv, rv0, rv1) {
  a <- dat$ratingRaw[dat$accf==accv & dat$real==rv0]
  b <- dat$ratingRaw[dat$accf==accv & dat$real==rv1]
  n1<-length(a); n2<-length(b)
  sp <- sqrt(((n1-1)*var(a)+(n2-1)*var(b))/(n1+n2-2))
  d  <- (mean(b)-mean(a))/sp
  c(d=d, m0=mean(a), m1=mean(b), sd0=sd(a), sd1=sd(b), n=n1)
}
da <- dcalc(TRUE, 0, 1)   # accuracy: real minus false
ds <- dcalc(FALSE,0,1)    # sharing
cat('Accuracy simple: d=', fmt(da[['d']],4), '  false M=',fmt(da[['m0']],4),' true M=',fmt(da[['m1']],4),'\n')
cat('Sharing  simple: d=', fmt(ds[['d']],4), '  false M=',fmt(ds[['m0']],4),' true M=',fmt(ds[['m1']],4),'\n')

## unstandardized interaction (Table S2 col 1) for cross-check
fit2 <- lm(dat$ratingRaw ~ X - 1); b2 <- coef(fit2); u2 <- resid(fit2)
V2  <- twoway_cluster_vcov(X, u2, dat$id, dat$item_num)$V
riu <- wald_F(b2, V2, c(0,0,0,1), N, K)
cat('\n[unstandardized] interaction b=', fmt(b2[4],4), ' SE=', fmt(riu$se,4), '\n')

## raw % yes by condition/veracity + the "32.4%" claim
cat('\n=== %yes by condition x veracity ===\n')
for (accv in c(TRUE,FALSE)) {
  lab <- if(accv) 'Accuracy' else 'Sharing'
  for (rv in c(0,1)) {
    rr <- dat$ratingRaw[dat$accf==accv & dat$real==rv]
    cat(sprintf('%-9s real=%s  mean=%7.4f n=%d\n', lab, rv, mean(rr), length(rr)))
  }
}
fa <- mean(dat$ratingRaw[dat$accf==TRUE  & dat$real==0])
fs <- mean(dat$ratingRaw[dat$accf==FALSE & dat$real==0])
cat('false: %acc=', fmt(fa,4), ' %share=', fmt(fs,4), ' diff(share-acc)=', fmt((fs-fa)*100,2), '% (ms says 32.4%)\n', sep='')

res <- rbind(interaction=int, accuracy=acc, sharing=shar)
write.csv(as.data.frame(res), 'output/study1_main_tests.csv')
saveRDS(list(b=b, V=V, b2=b2, V2=V2, N=N, K=K, int=int, acc=acc, shar=shar,
             da=da, ds=ds, unstd_int=b2[4], unstd_se=riu$se, fa=fa, fs=fs),
        'output/study1_main.rds')
cat('\nDONE study1 main\n')
