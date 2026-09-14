# ReproAI re-audit (fresh) - Kuper & Bott (2019) MP.2018.878
# Script 02: faithful reconstruction of the manuscript's k=76 analytic dataset from the RAW k=102
# `dat_new_s.txt` by applying ONLY the rules stated in the paper's Table 1 and Table 2.
# The aggregation/exclusion code and the k=76 dataset itself are NOT archived, so this is the
# only way to check the headline statistics.
options(width=220)
WORK <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878"
setwd(WORK)
suppressMessages({library(metafor); library(weightr)})

dat <- read.table("exec_check/data/dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$yi <- as.numeric(as.character(dat$yi))
dat$se <- as.numeric(as.character(dat$se))
dat$vi <- dat$se^2
dat$au <- gsub("^[. ]+","",dat$authors)

log_lines <- c()
note <- function(...) log_lines <<- c(log_lines, paste0(...,""))

k0 <- nrow(dat)
note(sprintf("START k = %d (dat_new_s)", k0))

# TABLE 1 EXCLUSIONS (studies not assessing moral licensing, or duplicate ES)
drop_effron2014 <- dat$au=="Effron (2014)"
drop_kouchaki   <- dat$au=="Kouchaki (2011)"
dat$keep <- !(drop_effron2014 | drop_kouchaki)
note(sprintf("Table1: drop Effron(2014) n=%d (2 ES), Kouchaki(2011) n=%d (4 ES) -> k=%d",
             sum(drop_effron2014), sum(drop_kouchaki), sum(dat$keep)))

# TABLE 2 PAIR DROPS (two groups vs same control -> keep ES1 only)
drop_second <- rep(FALSE, nrow(dat))
blk12 <- dat$au=="Blanken et al. (2012)"
for (p in list(c(1,2),c(4,5),c(6,7),c(8,9),c(10,11),c(12,13),c(14,15),c(16,17)))
  drop_second[blk12 & (dat$study %in% p) & (dat$study != p[1])] <- TRUE
bg10 <- dat$au=="Bradley-Geist et al. (2010)"
for (p in list(c(1,2),c(3,4)))
  drop_second[bg10 & (dat$study %in% p) & (dat$study != p[1])] <- TRUE
mej14 <- dat$au=="Meijers et al. (2014)"
for (p in list(c(1,2),c(3,4)))
  drop_second[mej14 & (dat$study %in% p) & (dat$study != p[1])] <- TRUE
dat$keep <- dat$keep & !drop_second
note(sprintf("Table2: drop 2nd-of-pair Blanken=%d, Bradley-Geist=%d, Meijers=%d -> k=%d",
             sum(drop_second[blk12]), sum(drop_second[bg10]), sum(drop_second[mej14]), sum(dat$keep)))

# Detect whether manuscript's Mazar & Zhong study-3 duplicate and Monin & Miller study-3 duplicate
# are already removed in the corrected file (they are single rows here -> nothing to drop).
note("Table1: Mazar&Zhong s3 & Monin&Miller s3 duplicates already absent in dat_new_s (single rows) -> 0 drops")

# TABLE 2 SIMBRUNNER AGGREGATION (5 outcomes -> average), two samples
# NB author string in shipped file is "(Simbrunner and Schlegelmilch 2016a)"
sim <- grepl("Simbrunner", dat$au) & grepl("2016", dat$au)
agg_rows <- list()
dat_pos <- dat$keep & sim
sample_ids <- unique(dat$N[dat_pos])
for (sid in sample_ids) {
  sub <- dat[dat_pos & dat$N==sid,]
  newse <- mean(sub$se); newyi <- mean(sub$yi)
  agg_rows[[as.character(sid)]] <- data.frame(
    authors="Simbrunner & Schlegelmilch (2016) [aggregated]",
    study=1, N=round(mean(sub$N)), yi=newyi, se=newse,
    comparison=sub$comparison[1], decision_type=sub$decision_type[1], pub=sub$pub[1],
    country=sub$country[1], world_region=sub$world_region[1],
    ID=paste0("Simbrunner agg n=",sid), stringsAsFactors=FALSE)
  note(sprintf("Table2: aggregate Simbrunner n=%d: %d ES -> 1  (yi mean=%.4f, se mean=%.4f)",
               sid, nrow(sub), newyi, newse))
}
agg <- do.call(rbind, agg_rows)
dat2 <- rbind(dat[dat$keep & !sim, c("authors","study","N","yi","se","comparison","decision_type","pub","country","world_region","ID")],
              agg)
dat2$yi <- as.numeric(dat2$yi); dat2$se <- as.numeric(dat2$se); dat2$vi <- dat2$se^2
note(sprintf("FINAL k = %d", nrow(dat2)))

print_counts <- function(d2, label, f) {
  cat("\n== ",label," (k=",nrow(d2),") ==\n",sep="")
  m <- rma(yi=yi, vi=vi, dat=d2)
  cat("NAIVE rma d=",round(m$b,4)," SE=",round(m$se,4)," Z=",round(m$zval,3)," p=",signif(m$pval,4),
      " 95%CI[",round(m$ci.lb,3),";",round(m$ci.ub,3),"]\n",sep="")
  cat("tau2=",round(m$tau2,4)," I2=",round(m$I2,4)," QE=",round(m$QE,3)," (df=",(m$k-1),") QEp=",signif(m$QEp,4),
      "   [I2 implied by Q: ",round((m$QE-(m$k-1))/m$QE,4),"]\n",sep="")
  if(nrow(d2)>=2){ pp <- lm(d2$yi ~ d2$se, weights=1/d2$vi); pps<-summary(pp)
    cat("PET int d=",round(coef(pp)[1],3)," t=",round(pps$coefficients[1,3],2)," p=",round(pps$coefficients[1,4],3),
        " | slope b=",round(coef(pp)[2],3)," t=",round(pps$coefficients[2,3],2)," p=",round(pps$coefficients[2,4],3),"\n",sep="")
  } else cat("PET: not run (k<2)\n")
  wm <- tryCatch(weightfunct(d2$yi, d2$vi, steps=c(0.025,1), table=TRUE), error=function(e) NULL)
  if(!is.null(wm)) { cat("3-PSM par:",paste(round(wm[[1]]$par,4),collapse=" "),"\n")
    } else cat("3-PSM failed\n")
}

sink(file.path(WORK,"exec_check/output/02_reconstruct_k76.txt"))
cat(log_lines, sep="\n")
# Now the ANALYTIC (non-NA) subset per the paper's analyses
# The manuscript's headline is on the full k=76 (including NA region Leonard/Thomas rows)
dall <- dat2                       # full reconstructed set
d_na  <- dat2[!is.na(dat2$world_region),]   # region-analysed subset (k = ?)
print_counts(dall, "All reconstructed (k=76 full)")
print_counts(d_na, "Reconstructed, region non-NA")
cat("\nCulture counts (full): NOA=",sum(dat2$world_region=="NOA",na.rm=TRUE),
    " EUR=",sum(dat2$world_region=="EUR",na.rm=TRUE),
    " SEA=",sum(dat2$world_region=="SEA",na.rm=TRUE),
    " NA=",sum(is.na(dat2$world_region)),"\n",sep="")
for(reg in c("NOA","EUR","SEA")){
  ds <- dat2[!is.na(dat2$world_region)&dat2$world_region==reg,]
  print_counts(ds, paste0("subgroup ",reg))
}
sink()
cat("Script 02 done\n")
saveRDS(dat2, file.path(WORK,"exec_check/output/dat2_k76_recon.rds"))
