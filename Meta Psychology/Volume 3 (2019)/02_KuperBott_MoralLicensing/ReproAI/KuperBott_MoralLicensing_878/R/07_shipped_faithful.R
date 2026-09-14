# Faithful re-run of the SHIPPED code (reviewer,analysis_JH.R) with output capture.
# No modifications to the analysis logic -- only added sink capture + explicit k reporting.
options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
suppressMessages({library(metafor); library(weightr); library(dplyr); library(forcats); library(graphics)})

OUT <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/output/07_shipped_code_output.txt"
sink(OUT, split=FALSE)

cat("==== Faithful run of SHIPPED reviewer,analysis_JH.R on dat_new_s.txt ====\n\n")
dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$comparison <- ifelse(dat$comparison=="1","neutral","immoral")
dat$se <- as.numeric(as.character(dat$se))
dat$yi <- as.numeric(as.character(dat$yi))
dat$vi <- dat$se^2
cat("SHIPPED DATASET k =", nrow(dat), "  (manuscript headline is k = 76)\n\n")

cat("---- random effects meta-analysis (entire dataset) ----\n")
mod1 <- rma(yi=yi, vi=vi, dat=dat)
print(summary(mod1))
cat("  >> k =", mod1$k, " d =", round(mod1$b,4), " I2 =", round(mod1$I2,2), " Q =", round(mod1$QE,2), "\n\n")

cat("---- moderator rma (~ comparison + world_region) ----\n")
dat$world_region <- factor(dat$world_region, levels=c("SEA","NOA","EUR"))
model2 <- rma(yi=yi, vi=vi, mods=~comparison+world_region, dat=dat)
print(summary(model2))
cat("\n")

cat("---- PET-PEESE (entire dataset) ----\n")
print(summary(lm(dat$yi ~ dat$se, weights=1/dat$vi)))
cat("\n")

cat("---- 3-PSM (entire dataset) ----\n")
print(weightfunct(dat$yi, dat$vi, steps=c(0.025,1), table=TRUE))
cat("\n")

cat("---- moderator rma + se ----\n")
print(rma(yi=yi, vi=vi, mods=~comparison+world_region+se, dat=dat))
cat("\n")

cat("---- culture: NOA ----\n")
dat2 <- dat[ dat$world_region=="NOA" & is.na(dat$world_region)==FALSE, ]
cat("NOA k =", nrow(dat2), "\n")
print(rma(yi=yi, vi=vi, dat=dat2))
print(summary(lm(dat2$yi ~ dat2$se, weights=1/dat2$vi)))
print(weightfunct(dat2$yi, dat2$vi, steps=c(0.025,1), table=TRUE))
cat("\n---- culture: EUR ----\n")
dat2 <- dat[ dat$world_region=="EUR" & is.na(dat$world_region)==FALSE, ]
cat("EUR k =", nrow(dat2), "\n")
print(rma(yi=yi, vi=vi, dat=dat2))
print(summary(lm(dat2$yi ~ dat2$se, weights=1/dat2$vi)))
print(weightfunct(dat2$yi, dat2$vi, steps=c(0.025,1), table=TRUE))
cat("\n---- culture: SEA ----\n")
dat2 <- dat[ dat$world_region=="SEA" & is.na(dat$world_region)==FALSE, ]
cat("SEA k =", nrow(dat2), "\n")
print(rma(yi=yi, vi=vi, dat=dat2))

cat("\n==== DONE ====\n")
sink()
cat("WROTE", OUT, "\n")
