setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/exec_check")
options(width=250)
suppressMessages({library(lme4); library(lmerTest)})
cat("==== START (status: OK) ====\n")
dir.rep <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/replication"
load(file.path(dir.rep, "Replication_data.RData"))
newd2 <- newd[ newd$newpartyfam=='Radical Right', ]

set.seed(02145)
full_form <- pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
  year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 +
  as.factor(prop2) + natquota + weurope + (1|party) + (1|country)

fams <- c("Christian Dem","Conservative","Green / New Left","Liberal","Social Dem")
res3 <- list()
for (fm in fams) {
  d <- newd[ newd$newpartyfam==fm, ]
  res3[[fm]] <- list(n=nrow(d), fit=lmer(full_form, data=d, REML=FALSE))
}

sink(file.path("output","table3_models.txt"))
cat("==== START (status: OK) ====\n")
for (fm in fams) {
  cat("\n######### ", fm, " | n=", res3[[fm]]$n, " #########\n")
  print(summary(res3[[fm]]$fit))
}
sink()

# extract key interaction coefficients
act <- function(m){
  s<-summary(m); s$coefficients
}
write.table(t(sapply(fams, function(fm){
  s <- summary(res3[[fm]]$fit)
  fe <- s$coefficients
  ic <- intersect(c("lag1_mfcombined10","chgvotelagged","year","femaleleader2_lag","cabinet_party2_lag","lag1womenpar","tier1_avemag2","as.factor(prop2)2","as.factor(prop2)3","natquota","weurope","lag1_mfcombined10:chgvotelagged"), rownames(fe))
  sapply(ic, function(t) sprintf("%.3f(%.3f)%s", fe[t,"Estimate"], fe[t,"Std. Error"], ifelse(fe[t,"Pr(>|t|)"]<0.001,"***",ifelse(fe[t,"Pr(>|t|)"]<0.01,"**",ifelse(fe[t,"Pr(>|t|)"]<0.05,"*","")))))
})), file=file.path("output","table3_coefs.txt"), sep="\t")

cat("\n---- Table 3: key interaction (lag1_mfcombined10:chgvotelagged) per family ----\n")
for (fm in fams) {
  fe <- summary(res3[[fm]]$fit)$coefficients
  rr <- fe["lag1_mfcombined10:chgvotelagged",]
  cat(sprintf("%-16s n=%-3d  interaction est=%.3f se=%.3f t=%.3f p=%.4f\n", fm, res3[[fm]]$n, rr["Estimate"], rr["Std. Error"], rr["t value"], rr["Pr(>|t|)"]))
}

cat("\n==== END (status: OK) ====\n")
