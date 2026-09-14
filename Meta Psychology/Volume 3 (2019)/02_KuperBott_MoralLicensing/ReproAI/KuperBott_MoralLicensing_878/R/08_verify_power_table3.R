# Verify (a) power analysis n=766 claim, (b) k=75 reconstruction vs manuscript Table 3 subgroup values.
options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
suppressMessages({library(metafor); library(weightr); library(stats)})
dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$yi <- as.numeric(as.character(dat$yi)); dat$se <- as.numeric(as.character(dat$se)); dat$vi <- dat$se^2

# ---- (a) Power analysis: d=0.18, 80% power, one-tailed, two groups ----
# For two-sample t-test, n per group for power .80, one-tailed alpha .05, d=.18:
# Use pwr-style formula: n = 2*(z_{1-alpha}+z_{power})^2 / d^2  (per group, pooled)
d <- 0.18; power <- 0.80; alpha <- 0.05
z_a <- qnorm(1-alpha); z_p <- qnorm(power)
n_per_group <- 2*(z_a+z_p)^2/d^2
cat("(a) POWER: d=0.18, 80% power, one-tailed alpha=0.05\n")
cat("  n per group =", round(n_per_group,1), "  total N =", ceiling(n_per_group)*2, "\n")
cat("  Manuscript claims n = 766 total for 80% power (one-tailed).\n\n")

# ---- (b) Reconstruct k=76 following Tables 1 & 2 (author name-robust) ----
# Exclusions per Table 1 (by study + N + yi signature):
# Effron (2014) both -> rows 51,52
# Kouchaki (2011) studies 1-4 -> rows 62,63,64,65
# (Jordan study 1, Mazar&Zhong study 3-dup, Monin&Miller study 3-dup already absent/deduped in dat_new_s)
# Table 2 aggregations:
#  Blanken 2012: (1,2),(4,5),(6,7),(8,9),(10,11),(12,13),(14,15),(16,17) -> keep 1 of each pair (8 removed)
#  Bradley-Geist 2010: (1,2),(3,4) -> 2 removed
#  Meijers 2014: (1,2),(3,4) -> 2 removed
#  Simbrunner 2016: aggregate 5 EUR (N=57) -> 1 ; aggregate 5 SEA (N=111) -> 1  (8 removed)
rem <- c(51,52,62,63,64,65)  # Table 1 exclusions (1-based row indices)
agg_pairs <- list(c(1,2),c(4,5),c(6,7),c(8,9),c(10,11),c(12,13),c(14,15),c(16,17),
                  c(24,25),c(26,27), c(75,76),c(77,78))
drop <- c(rem)
for (p in agg_pairs) drop <- c(drop, p[2])
# Simbrunner: keep one EUR (row 92) and one SEA (row 98); drop 93,94,95,96,97,99,100,101,102
drop <- c(drop, 93,94,95,96,97,99,100,101,102)
keep <- setdiff(seq_len(nrow(dat)), drop)
d76 <- dat[keep, ]
cat("(b) Reconstructed k =", nrow(d76), "(manuscript k=76)\n")
cat("  region counts:", paste(names(table(d76$world_region)), table(d76$world_region), sep="=", collapse=", "), "\n\n")

# Naive rma
m <- rma(yi=yi, vi=vi, dat=d76)
cat("NAIVE rma: k=",m$k," d=",round(m$b,4)," SE=",round(m$se,4)," Z=",round(m$zval,2),
    " CI[",round(m$ci.lb,3),";",round(m$ci.ub,3),"]  I2=",round(m$I2,1),"\n")
cat("  MANUSCRIPT: d=.27 [0.19;0.35] Z=6.57, I2=0.26, Q(75)=175.77\n\n")

# Culture subgroups
for (reg in c("NOA","EUR","SEA")) {
  d2 <- d76[d76$world_region==reg, ]
  if (nrow(d2)>=1) {
    m2 <- rma(yi=yi, vi=vi, dat=d2)
    cat(sprintf("%s: k=%d  d=%.3f  Z=%.2f  CI[%.3f;%.3f]\n", reg, m2$k, m2$b, m2$zval, m2$ci.lb, m2$ci.ub))
  }
}
cat("  MANUSCRIPT T3: NOA d=.38 [0.27;0.48] Z=7.01 | EUR d=.21 [0.09;0.32] Z=3.45 | SEA d=-.37 [-0.75;0.004] Z=-1.94\n\n")

# PET-PEESE full
pp <- lm(d76$yi ~ d76$se, weights=1/d76$vi)
cat("PET-PEESE: intercept=",round(coef(pp)[1],3),"  (manuscript -.05, t(74)=-0.46)\n")
# 3-PSM full
p3 <- weightr::weightfunct(d76$yi, d76$vi, steps=c(0.025,1), table=TRUE)
cat("3-PSM corrected d =", round(coef(p3)[1],3), "  (manuscript .18, Z=3.11)\n")
