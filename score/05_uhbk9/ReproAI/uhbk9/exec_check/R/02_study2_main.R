## ReproAI uhbk9 - Study 2 build + main analysis (replicates 'study 2 code.do')
source('00_lib.R')
d <- read.csv('../../extracted/Pennycook et al._Study 2.csv', check.names=FALSE,
              na.strings='', stringsAsFactors=FALSE, fileEncoding='latin1')
condcol <- names(d)[grep('[Cc]ondition', names(d))[1]]
ok <- function(x) !is.na(as.numeric(x))
nsubj <- nrow(d)
fakeMat <- matrix(NA, nsubj, 15); realMat <- matrix(NA, nsubj, 15)
for (i in 1:nsubj) for (j in 1:15) {
  fakeMat[i,j] <- suppressWarnings(as.numeric(d[[paste0('Fake1_',j)]][i]))
  realMat[i,j] <- suppressWarnings(as.numeric(d[[paste0('Real1_',j)]][i]))
}
long <- data.frame(
  id      = rep(1:nsubj, each=30),
  item_num= rep(c(1:15,16:30), times=nsubj),
  real    = rep(c(rep(0,15),rep(1,15)), times=nsubj),
  rating  = as.numeric(t(cbind(fakeMat,realMat)))
)
subj <- data.frame(id=1:nsubj, condition=as.numeric(d[[condcol]]),
                   crt=suppressWarnings(as.numeric(d$CRT_ACC)),
                   mms=suppressWarnings(as.numeric(d$MMS)),
                   demrep=suppressWarnings(as.numeric(d$DemRep))-1,
                   mind10=suppressWarnings(as.numeric(d$min_dist_10)),
                   sk=suppressWarnings(as.numeric(d$SciKnow)))
long <- merge(long, subj, by='id'); long <- long[order(long$id, long$item_num),]
cat('Study2 long rows:', nrow(long), ' non-missing:', sum(!is.na(long$rating)), '\n')
## treatment = condition==2 (control=1)
long$treatment <- as.numeric(long$condition==2)
## rescale rating to [0,1] per .do
long$rating <- (long$rating - 1)/5
## drop missing
dat <- long[!is.na(long$rating),]
cat('after drop N=', nrow(dat), ' nsubj=', length(unique(dat$id)), '\n')
dat$realXtrt <- dat$real * dat$treatment

X <- cbind(1, dat$real, dat$treatment, dat$realXtrt)
N <- nrow(dat); K <- ncol(X)
fit <- lm(dat$rating ~ X - 1)
b <- coef(fit); u <- resid(fit)
V <- twoway_cluster_vcov(X, u, dat$id, dat$item_num)$V
names(b) <- c('intercept','real','treatment','realXtrt')

fn <- function(cvec, label){
  r <- wald_F(b, V, cvec, N, K)
  cat(sprintf('%-24s est=%7.5f F=%8.3f p=%8.5f t=%7.3f se=%7.5f\n', label, r$est, r$F, r$p, r$t, r$se))
  c(est=r$est, F=r$F, p=r$p, t=r$t, se=r$se, df2=N-K)
}
cat('=== Study 2 main (rescaled DV, two-way cluster) ===\n')
cat('N=',N,' df2=',N-K,'\n',sep='')
int   <- fn(c(0,0,0,1),'interaction realXtrt')
ctrl  <- fn(c(0,1,0,0),'simple real in control')
treat <- fn(c(0,1,0,1),'simple real in treatment')

## Cohen d simple effects
dcalc <- function(trv, rv0, rv1){
  a<-dat$rating[dat$treatment==trv & dat$real==rv0]; b<-dat$rating[dat$treatment==trv & dat$real==rv1]
  sp<-sqrt(((length(a)-1)*var(a)+(length(b)-1)*var(b))/(length(a)+length(b)-2))
  c(d=(mean(b)-mean(a))/sp, m0=mean(a), m1=mean(b), n=length(a)+length(b))
}
dc <- dcalc(0,0,1); dt <- dcalc(1,0,1)
cat('control d=',fmt(dc['d'],4),' fail M=',fmt(dc['m0'],4),' true M=',fmt(dc['m1'],4),'\n')
cat('treat   d=',fmt(dt['d'],4),' fail M=',fmt(dt['m0'],4),' true M=',fmt(dt['m1'],4),'\n')
cat('discernment control=', fmt(dc['m1']-dc['m0'],5), ' treatment=', fmt(dt['m1']-dt['m0'],5),
    ' ratio=', fmt((dt['m1']-dt['m0'])/(dc['m1']-dc['m0']),3), ' (ms says 2.8x)\n')

## Figure 3 correlation: item-level treatment effect vs Study-1 perceived accuracy
s1 <- readRDS('output/study1_long_clean.rds')
s1acc <- aggregate(rating ~ item_num, data=s1[s1$accf==TRUE,], FUN=mean, na.rm=TRUE)
names(s1acc)[2] <- 'perceivedAcc'
te <- aggregate(rating ~ item_num, data=dat, FUN=function(x) mean(x))
te2 <- data.frame(item_num=te$item_num, accRate=NA)
trt_eff <- numeric(0)
for (it in 1:30) {
  c0 <- mean(dat$rating[dat$item_num==it & dat$treatment==0], na.rm=TRUE)
  c1 <- mean(dat$rating[dat$item_num==it & dat$treatment==1], na.rm=TRUE)
  trt_eff <- c(trt_eff, c1-c0)
}
fg <- data.frame(item_num=1:30, trtEffect=trt_eff)
fg <- merge(fg, s1acc, by='item_num')
corr <- cor(fg$trtEffect, fg$perceivedAcc)
cat('Figure 3: r(28)=', fmt(corr,3), ' (ms says 0.76)\n')
p28 <- sum(fg$perceivedAcc < median(fg$perceivedAcc))
saveRDS(list(N=N, K=K, b=b, V=V, int=int, ctrl=ctrl, treat=treat, dc=dc, dt=dt, corr=corr,
             fg=fg, df2=N-K), 'output/study2_main.rds')
write.csv(data.frame(term=c('interaction','ctrl-simple','treat-simple'),
                     est=c(int['est'],ctrl['est'],treat['est']),
                     F=c(int['F'],ctrl['F'],treat['F']), p=c(int['p'],ctrl['p'],treat['p'])),
          'output/study2_main_tests.csv', row.names=FALSE)
cat('DONE study2\n')
