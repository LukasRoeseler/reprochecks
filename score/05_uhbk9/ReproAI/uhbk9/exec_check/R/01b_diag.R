## Diagnostic: try many reporting variants to locate manuscript values
source('00_lib.R')
long <- readRDS('output/study1_long_clean.rds')
dat  <- long
dat$sharingC <- dat$sharing - 0.5
dat$realC    <- dat$real - 0.5
dat$int      <- dat$realC * dat$sharingC
m <- mean(dat$rating); s <- sd(dat$rating)
dat$z <- (dat$rating - m) / s

cat('=== Variant A: reg z ~ realC sharingC int (all beta on z DV) ===\n')
fA <- lm(z ~ realC + sharingC + int, dat)
print(coef(fA)['int'])

cat('=== Variant B: Bayesian-ish: standardized all predictors ===\n')
dat$zr <- scale(dat$realC)[,1]; dat$zs <- scale(dat$sharingC)[,1]; dat$zi <- scale(dat$int)[,1]
fB <- lm(z ~ zr + zs + zi, dat)
print(coef(fB)['zi'])

cat('=== Variant C: within-condition standardized DV (zratingByCond) ===\n')
dat$zbc <- ave(dat$rating, dat$sharing, FUN=function(x) (x-mean(x))/sd(x))
fC <- lm(zbc ~ realC + sharingC + int, dat)
print(coef(fC)['int'])
X <- cbind(1, dat$realC, dat$sharingC, dat$int)
v <- twoway_cluster_vcov(X, resid(fC), dat$id, dat$item_num)$V
b <- coef(fC); N <- nrow(dat); K <- ncol(X)
r <- wald_F(b, v, c(0,0,0,1), N, K)
cat('variant C interaction F=', r$F, '\n')

cat('\n=== 32.4% claim variants ===\n')
fa <- mean(dat$rating[dat$accf==TRUE  & dat$real==0])
fs <- mean(dat$rating[dat$accf==FALSE & dat$real==0])
ft <- mean(dat$rating[dat$accf==FALSE & dat$real==1])
aa <- mean(dat$rating[dat$accf==TRUE  & dat$real==1])
cat('false acc=',fa,' false share=',fs,' pp diff=',(fs-fa)*100,'\n')
cat('relative (fs-fa)/fa =', (fs-fa)/fa*100, '%\n')
cat('odds: fs/(1-fs) vs fa/(1-fa):', (fs/(1-fs))/(fa/(1-fa)), '\n')
cat('true acc=',aa,' true share=',ft,'\n')

cat('\n=== simple effect F + d with my cluster ===\n')
fz <- lm(z ~ realC + sharingC + int, dat)
bz <- coef(fz); uz <- resid(fz)
Vz <- twoway_cluster_vcov(X, uz, dat$id, dat$item_num)$V
cat('accuracy simple F:', wald_F(bz, Vz, c(0,1,0,-0.5), N, K)$F, '\n')
cat('sharing simple F :', wald_F(bz, Vz, c(0,1,0, 0.5), N, K)$F, '\n')
