# ReproAI re-audit - Kuper & Bott (2019) - Script 03
# Moderator meta-regressions on (a) my reconstructed k=76 and (b) uncorrected k=102,
# compared against the manuscript's prose claims (results section / Table 3 / Discussion).
options(width=220)
WORK <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878"
setwd(WORK)
suppressMessages(library(metafor))

dat2 <- readRDS(file.path(WORK,"exec_check/output/dat2_k76_recon.rds"))
dat2$comp_c <- ifelse(dat2$comparison==1,"neutral","immoral")
dat2$vi <- dat2$se^2

# uncorrected k=102
d102 <- read.table("exec_check/data/dat_old_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
d102$yi <- as.numeric(as.character(d102$yi)); d102$se <- as.numeric(as.character(d102$se)); d102$vi <- d102$se^2
d102$comp_c <- ifelse(d102$comparison==1,"neutral","immoral")

sink(file.path(WORK,"exec_check/output/03_moderators.txt"))
cat("==== ReproAI re-audit Script 03: moderator analyses ====\n\n")

show <- function(label, m, k) {
  cat("\n## ", label, " (k=",k,") ##\n",sep="")
  b <- m$b; se <- m$se; z <- m$zval; p <- m$pval
  rn <- rownames(b)
  for(i in seq_along(rn))
    cat(sprintf("  %-22s beta=%.3f  se=%.3f  Z=%.2f  p=%.3f\n", rn[i], b[i], se[i], z[i], p[i]))
}

# (1) replicate S&S moderator: ~ comparison + world_region, SEA ref  -- on k=76 reconstruction
m1 <- rma(yi=yi, vi=vi, mods=~ comp_c + factor(world_region, levels=c("SEA","NOA","EUR")), dat=dat2)
show("k76: ~ comp + region (SEA ref)", m1, nrow(dat2))

# (2) with se added (PET-PEESE + moderator)
m2 <- rma(yi=yi, vi=vi, mods=~ comp_c + factor(world_region, levels=c("SEA","NOA","EUR")) + se, dat=dat2)
show("k76: ~ comp + region + se", m2, nrow(dat2))

# (3) uncorrected k=102 comparison moderator (prose: beta=-.42 Z=-3.72 p<.001)
m3 <- rma(yi=yi, vi=vi, mods=~ factor(world_region, levels=c("SEA","NOA","EUR")) + comp_c, dat=d102)
show("k102 uncorrected: ~ region + comp", m3, nrow(d102))

# (4) k102 region-only to isolate culture (prose NA>SEA beta=.71 Z=2.34 p=.019)
m4 <- rma(yi=yi, vi=vi, mods=~ factor(world_region, levels=c("SEA","NOA","EUR")), dat=d102)
show("k102 uncorrected: ~ region only", m4, nrow(d102))

sink()
cat("Script 03 done\n")
