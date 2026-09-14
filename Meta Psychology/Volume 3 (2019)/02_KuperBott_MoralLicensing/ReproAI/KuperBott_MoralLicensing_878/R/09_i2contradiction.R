options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
suppressMessages({library(metafor); library(weightr)})
dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$yi <- as.numeric(as.character(dat$yi)); dat$se <- as.numeric(as.character(dat$se)); dat$vi <- dat$se^2
rem <- c(51,52,62,63,64,65)
agg_pairs <- list(c(1,2),c(4,5),c(6,7),c(8,9),c(10,11),c(12,13),c(14,15),c(16,17),c(24,25),c(26,27),c(75,76),c(77,78))
drop <- c(rem)
for (p in agg_pairs) drop <- c(drop, p[2])
drop <- c(drop, 93,94,95,96,97,99,100,101,102)
d76 <- dat[setdiff(seq_len(nrow(dat)), drop), ]

m <- rma(yi=yi, vi=vi, dat=d76)
cat("My reconstructed k=", m$k, " Q=", round(m$QE,2), " df=", m$QE.df, " I2=", round(m$I2,1), "\n")
# What I2 does Q=175.77 (manuscript) imply? 
Q_ms <- 175.77; df_ms <- 75
I2_implied <- (Q_ms - df_ms)/Q_ms
cat("MANUSCRIPT: Q(75)=175.77  =>  implied I2 = (175.77-75)/175.77 =", round(I2_implied,3), "  (manuscript reports I2=0.26)\n")
cat("=> Internally inconsistent: reported I2=0.26 contradicts its own Q(75)=175.77 (which implies I2=", round(I2_implied*100,1), "%)\n\n")

# 3-PSM on reconstructed (fix coef access)
cat("3-PSM on reconstructed k=", m$k, ":\n")
p3 <- weightr::weightfunct(d76$yi, d76$vi, steps=c(0.025,1), table=TRUE)
adj <- p3$adjCoef  # adjusted model coefficients
if (!is.null(adj)) { cat("  adjusted intercept (corrected d) =", round(adj[1,1],3), "\n") }
else { cat("  (coef structure differs; printing full)\n  "); print(p3) }
cat("  MANUSCRIPT 3-PSM corrected d = .18, Z=3.11, p=.002\n")
