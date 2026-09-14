# ReproAI re-audit (fresh) - Kuper & Bott (2019) MP.2018.878
# Script 01: run the SHIPPED methodology (reviewer,analysis_JH.R) verbatim on dat_new_s.txt (k=102)
# Purpose: establish exactly what the archived code can produce, i.e. the reviewer-analysis dataset.
options(width=220)
WORK <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878"
setwd(WORK)
suppressMessages({library(metafor); library(weightr)})

dat <- read.table("exec_check/data/dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$comparison <- ifelse(dat$comparison=="1","neutral","immoral")
dat$se <- as.numeric(as.character(dat$se))
dat$yi <- as.numeric(as.character(dat$yi))
dat$vi <- dat$se^2

sink(file.path(WORK,"exec_check/output/01_shipped_k102.txt"))
cat("==== ReproAI re-audit Script 01: shipped methodology on dat_new_s (k=",nrow(dat),") ====\n",sep="")
cat("This is the analysis actually archived (reviewer,analysis_JH.R). NOTE: k=102 here, NOT k=76.\n\n")

cat("-- Naive random-effects rma (k=102) --\n")
mod1 <- rma(yi=yi, vi=vi, dat=dat)
cat("d=",round(mod1$b,4)," SE=",round(mod1$se,4)," Z=",round(mod1$zval,3)," p=",signif(mod1$pval,4),
    " 95%CI[",round(mod1$ci.lb,4),";",round(mod1$ci.ub,4),"]\n",sep="")
cat("tau2=",round(mod1$tau2,4)," I2=",round(mod1$I2,3)," H2=",round(mod1$H2,3),
    " QE=",round(mod1$QE,2)," (df=",mod1$k-1,") QEp=",signif(mod1$QEp,4),"\n",sep="")

cat("\n-- PET-PEESE (lm yi~se, weights=1/vi) k=102 --\n")
pp <- lm(dat$yi ~ dat$se, weights=1/dat$vi); pps <- summary(pp)
cat("intercept d=",round(coef(pp)[1],3)," t(",pps$df[2],")=",round(pps$coefficients[1,3],2),
    " p=",round(pps$coefficients[1,4],3),"\n",sep="")
cat("slope b=",round(coef(pp)[2],3)," t=",round(pps$coefficients[2,3],2)," p=",round(pps$coefficients[2,4],3),"\n",sep="")

cat("\n-- 3-PSM weightfunct k=102 (steps c(0.025,1)) --\n")
wm <- weightfunct(dat$yi, dat$vi, steps=c(0.025,1), table=TRUE)
cat(paste(capture.output(wm),collapse="\n"),"\n")

cat("\n-- Culture subgroups (k=102 raw) --\n")
for (reg in c("NOA","EUR","SEA")) {
  d2 <- dat[!is.na(dat$world_region) & dat$world_region==reg,]
  m <- rma(yi=yi, vi=vi, dat=d2)
  pl <- lm(d2$yi ~ d2$se, weights=1/d2$vi)
  cat(reg," k=",m$k," | rma d=",round(m$b,3)," Z=",round(m$zval,2)," 95%CI[",round(m$ci.lb,2),";",round(m$ci.ub,2),"]",
      " | PET int=",round(coef(pl)[1],2)," slope=",round(coef(pl)[2],2),"\n",sep="")
}
sink()
cat("Script 01 done\n")
