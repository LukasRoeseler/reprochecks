## Cross-check two-way cluster SE using fixest (validated, Stata-convention)
library(fixest)
long <- readRDS('output/study1_long_clean.rds')
dat <- long
dat$sharingC <- dat$sharing - 0.5
dat$realC    <- dat$real - 0.5
dat$int      <- dat$realC * dat$sharingC
m <- mean(dat$rating); s <- sd(dat$rating)
dat$z <- (dat$rating - m)/s

cat('=== fixest two-way cluster: z ~ realC + sharingC + int ===\n')
fo <- feols(z ~ realC + sharingC + int, data=dat, cluster=~id+item_num)
print(coeftable(fo))
ii <- which(rownames(coeftable(fo))=='int')
t  <- coeftable(fo)[ii,'t value']; se <- coeftable(fo)[ii,'Std. Error']
cat('int t=', t, ' F=t^2=', t^2, ' p=', pf(t^2,1, nrow(dat)-4, lower.tail=FALSE), '\n', sep='')
cat('int coef=', coeftable(fo)[ii,'Estimate'], '\n')

## simple effects via linear hypothesis using vcov from fixest (need vcov matrix)
V <- vcov(fo)
b <- coef(fo)
cat('names b:', names(b), '\n')
for (lab in c('acc','share')) {
  cvec <- if(lab=='acc') c(0,1,0,-0.5) else c(0,1,0,0.5)
  est  <- sum(cvec*b)
  se2  <- sqrt(as.numeric(t(cvec)%*%V%*%cvec))
  Fr <- est^2/se2^2
  cat(lab, 'simple: est=',est,' se=',se2,' F=',Fr,' p=',pf(Fr,1,nrow(dat)-4,lower.tail=FALSE),'\n')
}
