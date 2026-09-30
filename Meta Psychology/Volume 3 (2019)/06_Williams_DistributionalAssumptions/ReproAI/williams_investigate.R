suppressMessages({library(WRS2)})
written <- c(1.67,2.00,2.67,2.67, 3.00,3.33,4.33,4.33, 4.67,4.67,4.67,4.67, 5.67,5.67,6.67,7.33, 7.67,8.00)
spoken  <- c(3.33,4.33,4.67,5.67, 5.67,6.00,6.00,6.00, 6.33,6.67,6.67,6.67, 7.00,7.00,7.00,7.00, 7.00,7.67,8.67,10.00,10.00)
grp <- factor(rep(c("written","spoken"), c(18,21)))
dat <- data.frame(intellect=c(written,spoken), grp=grp)

cat("=== Shapiro-Wilk variants (paper W=0.966, p=.124) ===\n")
# residuals from lm
lmr <- lm(intellect ~ grp, data=dat)
sw_lm <- shapiro.test(residuals(lmr))
cat("lm residuals: W=", sw_lm$statistic, " p=", sw_lm$p.value, "\n")
# pooled raw (grand mean devs)
sw_pool <- shapiro.test(c(written,spoken)-mean(c(written,spoken)))
cat("pooled grand-mean devs: W=", sw_pool$statistic, " p=", sw_pool$p.value, "\n")
# per group
cat("written only: W=", shapiro.test(written)$statistic, " p=", shapiro.test(written)$p.value, "\n")
cat("spoken only:  W=", shapiro.test(spoken)$statistic, " p=", shapiro.test(spoken)$p.value, "\n")
# group-mean devs (what I did)
devs <- c(written-mean(written), spoken-mean(spoken))
cat("group-mean devs: W=", shapiro.test(devs)$statistic, " p=", shapiro.test(devs)$p.value, "\n")

cat("\n=== Bootstrapped Yuen (paper p=.002, CI [-3.323,-0.698]) ===\n")
for(seed in 1:5){
  set.seed(seed)
  yb <- yuenbt(intellect ~ grp, data=dat, tr=0.2, nboot=1000)
  cat("seed", seed, ": diff=", yb$dif, " p=", yb$p.value, " ci=", paste(yb$ci, collapse=","), "\n")
}

cat("\n=== Power d=0.5 (paper 33%) ===\n")
cat("n=18/group:", power.t.test(n=18, d=0.5, sig.level=.05, type="two.sample")$power, "\n")
# unbalanced n=18,21 -> use noncentral approx via pwr? compute with simulation
set.seed(1)
sigs <- replicate(20000, {x<-rnorm(18,0,1); y<-rnorm(21,0.5,1); t.test(x,y,var.equal=TRUE)$p.value<.05})
cat("sim power (18,21):", mean(sigs), "\n")
cat("n=18/group sim:", mean(replicate(20000, {x<-rnorm(18,0,1); y<-rnorm(18,0.5,1); t.test(x,y,var.equal=TRUE)$p.value<.05})), "\n")
