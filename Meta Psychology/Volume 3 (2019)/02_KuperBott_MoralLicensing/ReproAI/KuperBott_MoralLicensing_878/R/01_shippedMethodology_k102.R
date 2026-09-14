# ReproAI audit - Kuper & Bott (2019) MP.2018.878
# Script 01: Run the SHIPPED methodology (reviewer,analysis_JH.R) on dat_new_s.txt (k=102)
# This reproduces exactly what the shipped code does on the shipped modified S&S dataset.
# NOTE: the shipped dataset has 102 effect sizes (not k=76 as in the final paper).

options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
library(metafor)
library(weightr)

dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$comparison <- ifelse(dat$comparison=="1","neutral","immoral")
dat$se <- as.numeric(as.character(dat$se))
dat$yi <- as.numeric(as.character(dat$yi))
dat$vi <- dat$se^2

out <- function(...) cat(..., "\n")
res <- list()

# --- entire dataset k = nrow ---
res$k_all <- nrow(dat)
mod1 <- rma(yi=yi, vi=vi, dat=dat)
res$rma_all <- c(est=mod1$b, se=mod1$se, z=mod1$zval, p=mod1$pval,
                 CI.lb=mod1$ci.lb, CI.ub=mod1$ci.ub, tau2=mod1$tau2, I2=mod1$I2, QE=mod1$QE, QEp=mod1$QEp, k=mod1$k)

# PET-PEESE (exactly as shipped: lm with weights 1/vi)
pp_lm <- lm(dat$yi ~ dat$se, weights=1/dat$vi)
pp <- summary(pp_lm)
res$pet_intercept <- coef(pp)[1]
res$pet_slope <- coef(pp)[2]
res$pet_t <- c(coef(pp)[1]/sqrt(diag(vcov(pp)))[1], coef(pp)[2]/sqrt(diag(vcov(pp)))[2])
res$pet_df <- pp$df[2]
res$pet_p <- c(2*pt(-abs(res$pet_t[1]), df=res$pet_df), 2*pt(-abs(res$pet_t[2]), df=res$pet_df))
res$pet_ci <- confint(pp_lm)[1,]

# 3-PSM (weightr weightfunct, two-tailed p=.05 -> steps c(0.025,1))
wm <- weightfunct(dat$yi, dat$vi, steps=c(0.025,1), table=TRUE)
res$w3_est <- wm[[1]]$par[[2]]
tmp <- capture.output(wm)
res$w3_raw <- tmp

# --- subgroup by culture ---
for (reg in c("NOA","EUR","SEA")) {
  d2 <- dat[!is.na(dat$world_region) & dat$world_region==reg,]
  m <- rma(yi=yi, vi=vi, dat=d2)
  res[[paste0("rma_",reg)]] <- c(est=m$b,k=m$k,se=m$se,z=m$zval,p=m$pval,CI.lb=m$ci.lb,CI.ub=m$ci.ub)
  pp2 <- lm(d2$yi ~ d2$se, weights=1/d2$vi)
  res[[paste0("pet_",reg)]] <- coef(pp2)
  if (reg != "SEA") {
    w2 <- weightfunct(d2$yi, d2$vi, steps=c(0.025,1))
    res[[paste0("w3_",reg)]] <- w2[[1]]$par[[2]]
  }
}

# Write results
sink("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/output/01_k102_results.txt")
cat("==== ReproAI Script 01: Shipped methodology on dat_new_s (k=102) ====\n\n")
cat("k (whole dat_new_s) =", res$k_all, "\n\n")
cat("-- Naive random-effects rma (k=102) --\n")
print(round(c(est=res$rma_all["est"], se=res$rma_all["se"], z=res$rma_all["z"], p=res$rma_all["p"],
              LB=res$rma_all["CI.lb"], UB=res$rma_all["CI.ub"], I2=res$rma_all["I2"],
              QE=res$rma_all["QE"], QEp=res$rma_all["QEp"], tau2=res$rma_all["tau2"]), 4))
cat("\n-- PET-PEESE (k=102) --\n")
cat("intercept d =", round(res$pet_intercept,4), " t(", res$pet_df, ")=", round(res$pet_t[1],3),
    " p=", round(res$pet_p[1],4), " 95%CI [", round(res$pet_ci["2.5 %"],3), ";", round(res$pet_ci["97.5 %"],3), "]\n", sep="")
cat("slope b =", round(res$pet_slope,3), " t=", round(res$pet_t[2],3), " p=", round(res$pet_p[2],4), "\n")
cat("\n-- 3-PSM weightfunct (k=102) --\n")
cat("raw weightfunct output:\n")
cat(res$w3_raw, sep="\n")
cat("\n-- Culture subgroups --\n")
for (reg in c("NOA","EUR","SEA")) {
  cat("\n", reg, ": rma est=", round(res[[paste0("rma_",reg)]]["est"],3), " k=", res[[paste0("rma_",reg)]]["k"],
      " se=", round(res[[paste0("rma_",reg)]]["se"],3), " z=", round(res[[paste0("rma_",reg)]]["z"],2),
      " p=", round(res[[paste0("rma_",reg)]]["p"],4),
      " CI[", round(res[[paste0("rma_",reg)]]["CI.lb"],3), ";", round(res[[paste0("rma_",reg)]]["CI.ub"],3), "]\n", sep="")
  cat("   PET-PEESE intercept=", round(res[[paste0("pet_",reg)]][1],3), " slope=", round(res[[paste0("pet_",reg)]][2],3), "\n")
  if (reg != "SEA") cat("   3-PSM est =", round(res[[paste0("w3_",reg)]],3), "\n")
}
sink()
cat("DONE\n")
