options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
suppressMessages({library(metafor); library(weightr)})
dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$yi <- as.numeric(as.character(dat$yi)); dat$se <- as.numeric(as.character(dat$se)); dat$vi <- dat$se^2

# Normalize author names (strip leading dot/space; map the Simbrunner label)
dat$au <- gsub("^[. ]+","", dat$authors)
dat$au[ dat$authors=="(Simbrunner and Schlegelmilch 2016a)"] <- "Simbrunner and Schlegelmilch (2016)"
cat("rows =", nrow(dat), "\n")

# --- Table 1 exclusions (studies not assessing moral licensing / duplicates) ---
# Effron (2014) studies 1-2 (both ES omitted)
dat$keep <- TRUE
dat$keep[ dat$au=="Effron (2014)" & dat$study %in% c(1,2) ] <- FALSE
# Kouchaki (2011) studies 1-4 (all ES omitted)
dat$keep[ dat$au=="Kouchaki (2011)" & dat$study %in% 1:4 ] <- FALSE
# Jordan (2011) study 1 (moral identity DV, not licensing) -> omitted
dat$keep[ dat$au=="Jordan et al. (2011)" & dat$study==1 ] <- FALSE

# --- Table 2: non-independent effect sizes -> keep first of each pair ---
# Blanken et al. (2012): pairs (1,2),(4,5),(6,7),(8,9),(10,11),(12,13),(14,15),(16,17) -> keep first
# (Blanken 2012 has studies 1-17; note study 3 is single/odd)
bl2012 <- dat$au=="Blanken et al. (2012)"
for (p in list(c(1,2),c(4,5),c(6,7),c(8,9),c(10,11),c(12,13),c(14,15),c(16,17)))
  dat$keep[ bl2012 & dat$study %in% p & dat$study != p[1] ] <- FALSE
# Bradley-Geist (2010): pairs (1,2),(3,4) -> keep first
bg <- dat$au=="Bradley-Geist et al. (2010)"
for (p in list(c(1,2),c(3,4)))
  dat$keep[ bg & dat$study %in% p & dat$study != p[1] ] <- FALSE
# Meijers (2014): pairs (1,2),(3,4) -> keep first
mj <- dat$au=="Meijers et al. (2014)"
for (p in list(c(1,2),c(3,4)))
  dat$keep[ mj & dat$study %in% p & dat$study != p[1] ] <- FALSE

# --- Simbrunner (2016) n=57 (studies 2.1-2.5) and n=111 (studies 3.1-3.5): average to 1 each ---
sim <- dat[ dat$au=="Simbrunner and Schlegelmilch (2016)" & dat$keep, ]
cat("Simbrunner rows kept (pre-agg):", nrow(sim), "  Ns:", paste(sort(unique(sim$N)), collapse=","), "\n")
# Remove all simbrunner rows from the keep set, then add 2 aggregated rows
dat$keep[ dat$au=="Simbrunner and Schlegelmilch (2016)" ] <- FALSE
mk <- function(sub, tag) data.frame(authors=tag, study=1, N=mean(sub$N), yi=mean(sub$yi),
   se=mean(sub$se), comparison=sub$comparison[1], decision_type=sub$decision_type[1],
   pub=sub$pub[1], country=sub$country[1], world_region=sub$world_region[1], ID=sub$ID[1],
   vi=mean(sub$se)^2, au=tag, keep=TRUE)
s57  <- sim[sim$N==57, ]
s111 <- sim[sim$N==111, ]
if (nrow(s57)>0)  dat <- rbind(dat, mk(s57,"Simbrunner agg n57"))
if (nrow(s111)>0) dat <- rbind(dat, mk(s111,"Simbrunner agg n111"))

d2 <- dat[dat$keep,]
cat("\nFINAL k =", nrow(d2), "\n")
cat("region counts: NOA=", sum(d2$world_region=="NOA", na.rm=TRUE),
    " EUR=", sum(d2$world_region=="EUR", na.rm=TRUE),
    " SEA=", sum(d2$world_region=="SEA", na.rm=TRUE),
    " NA=", sum(is.na(d2$world_region)), "\n")

mod1 <- rma(yi=yi, vi=vi, dat=d2)
cat("\nNAIVE rma: k=", mod1$k, " d=", round(mod1$b,4), " SE=", round(mod1$se,4), " Z=", round(mod1$zval,3),
    " p=", signif(mod1$pval,4), " CI[", round(mod1$ci.lb,3), ";", round(mod1$ci.ub,3), "]\n")
cat("tau2=", round(mod1$tau2,4), " I2=", round(mod1$I2,2), " QE=", round(mod1$QE,2), " QEp=", signif(mod1$QEp,4), "\n")

pp <- lm(d2$yi ~ d2$se, weights=1/d2$vi); ps <- summary(pp); pdf_ <- ps$df[2]; ci <- confint(pp)[1,]
cat("\nPET-PEESE: intercept=", round(coef(pp)[1],3), " t(", pdf_, ")=", round(ps$coefficients[1,3],2),
    " p=", round(ps$coefficients[1,4],3), " CI[", round(ci[1],3), ";", round(ci[2],3), "]\n")
cat("  slope b=", round(coef(pp)[2],3), " t=", round(ps$coefficients[2,3],2), " p=", round(ps$coefficients[2,4],3), "\n")

# 3-PSM
wm <- tryCatch(weightfunct(d2$yi, d2$vi, steps=c(0.025,1), table=TRUE), error=function(e) NULL)
cat("\n3-PSM (weightr):\n")
if (!is.null(wm)) cat(paste(capture.output(wm), collapse="\n"), "\n") else cat("FAILED\n")

cat("\n=== CULTURE SUBGROUPS (rma + PET) ===\n")
for (reg in c("NOA","EUR","SEA")) {
  s <- d2[ !is.na(d2$world_region) & d2$world_region==reg, ]
  ms <- rma(yi=yi, vi=vi, dat=s)
  pl <- lm(s$yi ~ s$se, weights=1/s$vi); pls <- summary(pl); pldf <- pls$df[2]; pci <- confint(pl)[1,]
  cat("\n", reg, " k=", ms$k, " d=", round(ms$b,3), " SE=", round(ms$se,3), " Z=", round(ms$zval,3),
      " p=", signif(ms$pval,4), " CI[", round(ms$ci.lb,3), ";", round(ms$ci.ub,3), "]\n")
  cat("  PET int=", round(coef(pl)[1],3), " t(", pldf, ")=", round(pls$coefficients[1,3],2),
      " p=", round(pls$coefficients[1,4],3), " CI[", round(pci[1],3), ";", round(pci[2],3), "]  ",
      " slope=", round(coef(pl)[2],3), " t=", round(pls$coefficients[2,3],2), " p=", round(pls$coefficients[2,4],3), "\n")
}

cat("\n=== MODERATOR rma (~ comparison + region, SEA ref) ===\n")
d2$comp_c <- ifelse(d2$comparison==1, "neutral", "immoral")
m2 <- rma(yi=yi, vi=vi, mods=~ comp_c + factor(world_region, levels=c("SEA","NOA","EUR")), dat=d2)
print(summary(m2))
cat("\n=== MODERATOR rma + se (PET-PEESE style) ===\n")
m3 <- rma(yi=yi, vi=vi, mods=~ comp_c + factor(world_region, levels=c("SEA","NOA","EUR")) + se, dat=d2)
print(summary(m3))
cat("DONE\n")
