suppressMessages({library(lme4); library(lmerTest)})
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/exec_check")
cat("==== START (status: OK) ====\n")
load("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/replication/Replication_data.RData")
newd2 <- newd[ newd$newpartyfam=="Radical Right", ]
set.seed(02145)
vars <- c("country","countryname","year","party","partyname","partyabbrev","pfem_new2","lag1_mfcombined10","chgvotelagged",
  "femaleleader2_lag","cabinet_party2_lag","lag1womenpar","tier1_avemag2","prop2","natquota","weurope")
temp_r <- na.omit(newd2[vars])
m5r <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
  year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
  (1|party)+(1|country), data=temp_r, REML=FALSE)
temp_r$resid5 <- residuals(m5r)
cat("SVP 2015 (Switzerland) residual from Model 5:\n")
svp <- temp_r[ temp_r$countryname=="Switzerland" & temp_r$year==2015, ]
print(svp[, c("partyname","year","countryname","pfem_new2","resid5","lag1_mfcombined10","chgvotelagged")])
cat("\nPVV 2017 residual:", temp_r$resid5[ temp_r$countryname=="Netherlands" & temp_r$year==2017 ], "\n")
cat("sd(resid5):", sd(temp_r$resid5), "| sd(pred5):", sd(predict(m5r)), "\n\n")

cat("---- Abstract sample reconciliation (187 parties / 30 countries) ----\n")
cat("All rows in newd:", nrow(newd), "| unique parties:", length(unique(newd$party)), "| unique countries:", length(unique(newd$country)), "\n")
# Sample used in Table 2 Model 5 (all parties, complete cases of full model)
m5all <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
  year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
  (1|party)+(1|country), data=newd, REML=FALSE)
cat("Table2 M5: nobs=", nobs(m5all), "| parties=", length(unique(m5all@frame$party)), "| countries=", length(unique(m5all@frame$country)), "\n\n")
# window 1985-2018, exclude agrarian/ethnic, non-missing pfem
w <- newd[ newd$year>=1985 & newd$year<=2018 & !newd$newpartyfam %in% c("Nationalist / Agrarian","Ethnic / Regional") & !is.na(newd$pfem_new2), ]
cat("1985-2018 non-agrarian/ethnic with pfem: rows=", nrow(w), " parties=", length(unique(w$party)), " countries=", length(unique(w$country)), "\n")
cat("==== END (status: OK) ====\n")
