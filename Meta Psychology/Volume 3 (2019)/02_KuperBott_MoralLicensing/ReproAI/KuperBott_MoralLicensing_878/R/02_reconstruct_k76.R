# ReproAI audit - Kuper & Bott (2019) MP.2018.878
# Script 02 (v2): reconstruct k=76 aggregation, recompute all headline stats robustly.

options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
suppressMessages({library(metafor); library(weightr)})

dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$yi <- as.numeric(as.character(dat$yi)); dat$se <- as.numeric(as.character(dat$se)); dat$vi <- dat$se^2
dat$au <- gsub("^[. ]+","",dat$authors)

keep_first <- function(au, st) {
  keep <- rep(TRUE, length(au))
  for (p in list(c(1,2),c(4,5),c(6,7),c(8,9),c(10,11),c(12,13),c(14,15),c(16,17)))
    keep[au=="Blanken et al. (2012)" & st %in% p & st != p[1]] <- FALSE
  for (p in list(c(1,2),c(3,4)))
    keep[au=="Bradley-Geist et al. (2010)" & st %in% p & st != p[1]] <- FALSE
  for (p in list(c(1,2),c(3,4)))
    keep[au=="Meijers et al. (2014)" & st %in% p & st != p[1]] <- FALSE
  keep
}
dat$keep <- keep_first(dat$au, dat$study)
dat$keep[ dat$au=="Effron (2014)" ] <- FALSE
dat$keep[ dat$au=="Kouchaki (2011)" ] <- FALSE
dat2 <- dat[dat$keep,]

sim57  <- dat2[ dat2$au=="(Simbrunner and Schlegelmilch (2016)" & dat2$N==57,  ]
sim111 <- dat2[ dat2$au=="(Simbrunner and Schlegelmilch (2016)" & dat2$N==111, ]
dat2   <- dat2[ dat2$au!="(Simbrunner and Schlegelmilch (2016)", ]
mk <- function(sub, tag) data.frame(authors=tag, study=1, N=mean(sub$N), yi=mean(sub$yi),
     se=mean(sub$se), comparison=sub$comparison[1], decision_type=sub$decision_type[1],
     pub=sub$pub[1], country=sub$country[1], world_region=sub$world_region[1],
     ID=sub$ID[1], vi=mean(sub$se)^2, au=tag, keep=TRUE)
dat2 <- rbind(dat2, mk(sim57,"Simbrunner agg n57"), mk(sim111,"Simbrunner agg n111"))
dat2$yi <- as.numeric(dat2$yi); dat2$se <- as.numeric(dat2$se); dat2$vi <- as.numeric(dat2$se)^2

OUT <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/output/02_k76_results.txt"
sink(OUT)
cat("==== ReproAI Script 02: reconstructed k =", nrow(dat2), " ====\n\n")
cat("Step detail:\n")
cat("  dat_new_s rows = 102\n")
cat("  after removing Effron(2014)1-2, Kouchaki(2011)1-4 and pair-wise duplicates: ", sum(dat$keep), "\n")
cat("  k after aggregation = ", nrow(dat2), "\n")
cat("  culture counts: NOA=", sum(dat2$world_region=="NOA",na.rm=TRUE),
    " EUR=", sum(dat2$world_region=="EUR",na.rm=TRUE),
    " SEA=", sum(dat2$world_region=="SEA",na.rm=TRUE),
    " NA=", sum(is.na(dat2$world_region)), "\n")

mod1 <- rma(yi=yi, vi=vi, dat=dat2)
cat("\n-- NAIVE random-effects rma (k =", mod1$k, ") --\n")
cat("d = ", round(mod1$b,4), " SE=", round(mod1$se,4), " Z=", round(mod1$zval,3),
    " p=", signif(mod1$pval,4), " 95%CI[", round(mod1$ci.lb,3), ";", round(mod1$ci.ub,3), "]\n", sep="")
cat("tau2=", round(mod1$tau2,4), " I2=", round(mod1$I2,2), " QE=", round(mod1$QE,2),
    " QEp=", signif(mod1$QEp,4), "\n")

pp_lm <- lm(dat2$yi ~ dat2$se, weights=1/dat2$vi)
pps <- summary(pp_lm); pdf_ <- pps$df[2]
ci <- confint(pp_lm)[1,]
cat("\n-- PET-PEESE --\n")
cat("intercept d=", round(coef(pp_lm)[1],3), " t(", pdf_, ")=", round(pps$coefficients[1,3],2),
    " p=", round(pps$coefficients[1,4],3), " 95%CI[", round(ci[1],3), ";", round(ci[2],3), "]\n", sep="")
cat("slope b=", round(coef(pp_lm)[2],2), " t=", round(pps$coefficients[2,3],2),
    " p=", round(pps$coefficients[2,4],3), "\n")

wm <- tryCatch(weightfunct(dat2$yi, dat2$vi, steps=c(0.025,1), table=TRUE), error=function(e) NULL)
cat("\n-- 3-PSM (weightr) --\n")
if (!is.null(wm)) { cat(paste(capture.output(wm), collapse="\n"), "\n") } else cat("failed\n")

dat2$comp_c <- ifelse(dat2$comparison==1,"neutral","immoral")
dat2$region <- dat2$world_region
cat("\n-- Moderator rma: ~comparison + region (SEA ref) --\n")
m2 <- rma(yi=yi, vi=vi, mods=~ comp_c + factor(region,levels=c("SEA","NOA","EUR")), dat=dat2)
print(summary(m2))
cat("\n-- Moderator rma + se (PET-PEESE style) --\n")
m3 <- rma(yi=yi, vi=vi, mods=~ comp_c + factor(region,levels=c("SEA","NOA","EUR")) + se, dat=dat2)
print(summary(m3))
cat("\n-- 3-PSM with moderators (NOA ref) --\n")
dat2$region2 <- relevel(factor(dat2$region), ref="NOA")
wmod <- tryCatch(weightfunct(dat2$yi, dat2$vi, mods=~ comp_c + region2, steps=c(0.025,1)), error=function(e) NULL)
if (!is.null(wmod)) cat(paste(capture.output(wmod), collapse="\n"), "\n") else cat("failed\n")

cat("\n-- Culture subgroups --\n")
for (reg in c("NOA","EUR","SEA")) {
  d2s <- dat2[!is.na(dat2$world_region) & dat2$world_region==reg,]
  ms <- rma(yi=yi, vi=vi, dat=d2s)
  pl <- lm(d2s$yi ~ d2s$se, weights=1/d2s$vi)
  cat("\n", reg, " k=", ms$k, "\n", sep="")
  cat("  rma d=", round(ms$b,3), " SE=", round(ms$se,3), " Z=", round(ms$zval,3),
      " p=", signif(ms$pval,4), " 95%CI[", round(ms$ci.lb,3), ";", round(ms$ci.ub,3), "]\n", sep="")
  cat("  PET int=", round(coef(pl)[1],3), " t=", round(summary(pl)$coefficients[1,3],2),
      " p=", round(summary(pl)$coefficients[1,4],3), "; slope=", round(coef(pl)[2],3),
      " t=", round(summary(pl)$coefficients[2,3],2), " p=", round(summary(pl)$coefficients[2,4],3), "\n")
  if (reg != "SEA") {
    w2 <- tryCatch(weightfunct(d2s$yi, d2s$vi, steps=c(0.025,1)), error=function(e) NULL)
    if (!is.null(w2)) cat("  3-PSM par =", round(w2[[1]]$par,4), "\n") else cat("  3-PSM failed\n")
  }
}
sink()
cat("DONE\n")
saveRDS(list(dat2=dat2), "output/02_env.rds")
