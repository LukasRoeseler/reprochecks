suppressMessages({library(WRS2)})
written <- c(1.67,2.00,2.67,2.67, 3.00,3.33,4.33,4.33, 4.67,4.67,4.67,4.67, 5.67,5.67,6.67,7.33, 7.67,8.00)
spoken  <- c(3.33,4.33,4.67,5.67, 5.67,6.00,6.00,6.00, 6.33,6.67,6.67,6.67, 7.00,7.00,7.00,7.00, 7.00,7.67,8.67,10.00,10.00)
cat("n written =", length(written), " n spoken =", length(spoken), "\n")
cat("means: written=", mean(written), " spoken=", mean(spoken), "\n")

# Student's t (equal var)
tt <- t.test(written, spoken, var.equal=TRUE)
cat("\nStudent t: t=", unname(tt$statistic), " df=", unname(tt$parameter), " p=", unname(tt$p.value), "\n")

# Welch t
wt <- t.test(written, spoken, var.equal=FALSE)
cat("Welch t:  t=", unname(wt$statistic), " df=", round(unname(wt$parameter),3), " p=", unname(wt$p.value), "\n")

# Wilcoxon
wx <- wilcox.test(written, spoken)
cat("Wilcoxon: W=", unname(wx$statistic), " p=", unname(wx$p.value), "\n")

# Shapiro-Wilk on deviations from group mean
d1 <- written - mean(written); d2 <- spoken - mean(spoken); devs <- c(d1, d2)
sw <- shapiro.test(devs)
cat("Shapiro-Wilk on deviations: W=", unname(sw$statistic), " p=", unname(sw$p.value), "\n")

# F test equality of variances
fv <- var.test(written, spoken)
cat("F test: F=", unname(fv$statistic), " df=", unname(fv$parameter[1]), ",", unname(fv$parameter[2]), " p=", unname(fv$p.value), "\n")

# Yuen's test (20% trimmed) - formula interface
grp <- factor(rep(c("written","spoken"), c(length(written), length(spoken))))
dat <- data.frame(intellect=c(written, spoken), grp=grp)
yu <- yuen(intellect ~ grp, data=dat, tr=0.2)
cat("Yuen 20% trimmed: diff=", unname(yu$dif), " p=", unname(yu$p.value), "\n")

# Bootstrapped Yuen's test, 1000 samples, seed 1
set.seed(1)
yb <- yuenbt(intellect ~ grp, data=dat, tr=0.2, nboot=1000)
cat("Bootstrapped Yuen: diff=", unname(yb$dif), " p=", unname(yb$p.value), " CI=[", yb$ci[1], ",", yb$ci[2], "]\n")

# Power for d=0.5, two-sample t, n=18+21, alpha .05, two-sided
power <- power.t.test(n=18, d=0.5, sig.level=.05, type="two.sample", alternative="two.sided")
cat("\nPower d=0.5 (n=18/group): ", round(power$power,4), "\n")
# total n 39 -> per group 18 & 21; compute power for the unbalanced using pwr-like simulation? report nominal for n=18/group
