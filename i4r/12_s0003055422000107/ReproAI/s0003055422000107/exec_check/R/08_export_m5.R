suppressMessages({library(lme4); library(lmerTest)})
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/exec_check")
load("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/replication/Replication_data.RData")
newd2 <- newd[ newd$newpartyfam=="Radical Right", ]
newd2$prop2f <- as.factor(newd2$prop2)
fr <- model.frame(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
  year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + prop2f + natquota + weurope + party + country,
  data=newd2, na.action=na.exclude)
fr$party <- as.integer(as.character(fr$party))
fr$country <- as.integer(as.character(fr$country))
write.csv(fr, "output/t1m5_data.csv", row.names=FALSE)
cat("N exported (complete cases Model 5):", nrow(fr), "\n")
cat("==== END (status: OK) ====\n")
