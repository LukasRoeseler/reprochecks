setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/exec_check")
options(width=250)
suppressMessages({library(lme4); library(lmerTest)})
cat("==== START (status: OK) ====\n")
cat("R:", R.version.string, "| lme4:", as.character(packageVersion("lme4")), "| lmerTest:", as.character(packageVersion("lmerTest")), "\n\n")

dir.rep <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/replication"
load(file.path(dir.rep, "Replication_data.RData"))

# Build the RRP-only sample exactly as authors do
newd2 <- newd[ newd$newpartyfam=='Radical Right', ]
cat("nrow(newd2) (RRP parties):", nrow(newd2), "\n")

set.seed(02145)

# ---- Table 1 models ----
run_models <- function(dat, tag) {
  out1 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged +
               (1|party) + (1|country), data=dat, REML=FALSE)
  out2 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
               (1|party) + (1|country), data=dat, REML=FALSE)
  out3 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
               year + (1|party) + (1|country), data=dat, REML=FALSE)
  out4 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
               year + femaleleader2_lag + cabinet_party2_lag +
               (1|party) + (1|country), data=dat, REML=FALSE)
  out5 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
               year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 +
               as.factor(prop2) + natquota + weurope +
               (1|party) + (1|country), data=dat, REML=FALSE)
  list(out1=out1,out2=out2,out3=out3,out4=out4,out5=out5,tag=tag)
}

extract <- function(m) {
  s <- summary(m)
  fe <- s$coefficients
  out <- data.frame(
    term = rownames(fe),
    est  = fe[,"Estimate"],
    se   = fe[,"Std. Error"],
    p    = fe[,"Pr(>|t|)"],
    stringsAsFactors=FALSE)
  rownames(out) <- NULL
  # variance components (as SD by default in lme4) - convert to variances
  vc <- as.data.frame(VarCorr(m))
  variances <- vc$vcov  # these are variances already in lme4 v2
  names(variances) <- vc$grp
  ll <- as.numeric(logLik(m))
  n  <- nobs(m)
  list(fe=out, variances=variances, ll=ll, n=n)
}

t1 <- run_models(newd2, "Table1_RRP")
t2 <- run_models(newd,  "Table2_AllParties")

write_results <- function(res, filebase) {
  sink(file.path("output", paste0(filebase, ".txt")))
  cat("==== START (status: OK) ====\n")
  for (nm in c("out1","out2","out3","out4","out5")) {
    m <- res[[nm]]
    cat("\n############ ", nm, " ############\n", sep="")
    print(summary(m))
  }
  sink()
}

write_results(t1, "table1_models")
write_results(t2, "table2_models")

# Build plain-data comparison tables for Table 1
fe_tab <- function(res){
  do.call(rbind, lapply(c("out1","out2","out3","out4","out5"), function(nm){
    ex <- extract(res[[nm]])
    d <- data.frame(model=nm, term=ex$fe$term, est=ex$fe$est, se=ex$fe$se, p=ex$fe$p)
    v <- ex$variances
    rhow <- data.frame(model=nm, term=c("sd_party_variance","sd_country_variance","sd_residual_variance"),
                       est=c(if("party" %in% names(v)) v["party"] else NA,
                             if("country" %in% names(v)) v["country"] else NA,
                             if("Residual" %in% names(v)) v["Residual"] else NA),
                       se=NA, p=NA)
    ll <- data.frame(model=nm, term="logLik", est=ex$ll, se=NA, p=NA)
    nn <- data.frame(model=nm, term="N", est=ex$n, se=NA, p=NA)
    rbind(d, rhow, ll, nn)
  }))
}
t1fe <- fe_tab(t1)
t2fe <- fe_tab(t2)
write.csv(t1fe, file.path("output","table1_reimplementation.csv"), row.names=FALSE)
write.csv(t2fe, file.path("output","table2_reimplementation.csv"), row.names=FALSE)

cat("\n==== Table 1 Model 5 fixed effects (headline) ====\n")
print(t1fe[ t1fe$model=="out5" & t1fe$term=="lag1_mfcombined10:chgvotelagged", ])
print(t1fe[ t1fe$model=="out5" & t1fe$term=="lag1_mfcombined10", ])
print(t1fe[ t1fe$model=="out5" & t1fe$term=="chgvotelagged", ])

cat("\n==== END (status: OK) ====\n")
