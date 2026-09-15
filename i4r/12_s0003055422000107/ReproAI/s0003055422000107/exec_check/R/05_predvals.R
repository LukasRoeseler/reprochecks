suppressMessages({library(lme4); library(lmerTest)})
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/exec_check")
cat("==== START (status: OK) ====\n")
load("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/replication/Replication_data.RData")
newd2 <- newd[ newd$newpartyfam=="Radical Right", ]
set.seed(02145)
out5 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
  year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 +
  as.factor(prop2) + natquota + weurope + (1|party) + (1|country), data=newd2, REML=FALSE)
d <- newd2[ complete.cases(newd2[,c("lag1_mfcombined10","chgvotelagged","year","femaleleader2_lag","cabinet_party2_lag","lag1womenpar","tier1_avemag2","prop2","natquota","weurope")]), ]
nd <- data.frame(lag1_mfcombined10=2, chgvotelagged=c(-5,5), year=mean(d$year),
  femaleleader2_lag=mean(d$femaleleader2_lag), cabinet_party2_lag=mean(d$cabinet_party2_lag),
  lag1womenpar=mean(d$lag1womenpar), tier1_avemag2=mean(d$tier1_avemag2),
  prop2=3, natquota=mean(d$natquota), weurope=mean(d$weurope))
nd$pfem_new2 <- 0
p <- predict(out5, newdata=nd, re.form=NA)
cat(sprintf("predicted %% women at M/F=2, VoteChange=-5: %.2f\n", p[1]))
cat(sprintf("predicted %% women at M/F=2, VoteChange=+5: %.2f\n", p[2]))

cat("\nRRP rows for PVV/SVP and Nordic/other big-RRP:\n")
sub <- newd2[ newd2$partyabbrev %in% c("PVV","SVP","DF","FN","PRM","LN"), c("partyname","partyabbrev","year","pfem_new2","lag1_mfcombined10","chgvotelagged")]
print(sub)

cat("\nSearch for any party name containing 'Swiss' or 'People' or 'SVP':\n")
print(unique(newd2[ grepl("Swiss|People|peoples", newd2$partyname), c("partyname","partyabbrev","year") ]))
cat("==== END (status: OK) ====\n")
