setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/exec_check")
options(width=250)
suppressMessages({library(lme4); library(lmerTest)})
cat("==== START (status: OK) ====\n")
dir.rep <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/replication"
load(file.path(dir.rep, "Replication_data.RData"))
newd2 <- newd[ newd$newpartyfam=='Radical Right', ]
set.seed(02145)

# ---------- Sample / N claims ----------
cat("\n[Sample] nrow(newd):", nrow(newd), "| unique parties:", length(unique(newd$party)),
    "| unique countries:", length(unique(newd$country)), "\n")
cat("[Sample] nrow(newd2 RRP):", nrow(newd2), "| RRP parties:", length(unique(newd2$party)),
    "| RRP countries:", length(unique(newd2$country)), "\n")

# ---------- Table 1 models (RRP) ----------
out1 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + (1|party)+(1|country), data=newd2, REML=FALSE)
out2 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged + (1|party)+(1|country), data=newd2, REML=FALSE)
out3 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged + year + (1|party)+(1|country), data=newd2, REML=FALSE)
out4 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged + year + femaleleader2_lag + cabinet_party2_lag + (1|party)+(1|country), data=newd2, REML=FALSE)
out5 <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged + year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope + (1|party)+(1|country), data=newd2, REML=FALSE)
for (nm in c("out1","out2","out3","out4","out5")) {
  m <- get(nm); s <- summary(m)
  if ("lag1_mfcombined10:chgvotelagged" %in% rownames(s$coefficients)) {
    ic <- s$coefficients["lag1_mfcombined10:chgvotelagged",]
    cat(sprintf("[T1 %s] interaction est=%.3f se=%.3f t=%.3f p=%.4f | N(nobs)=%d | parties=%d countries=%d\n",
        nm, ic["Estimate"], ic["Std. Error"], ic["t value"], ic["Pr(>|t|)"], nobs(m),
        length(unique(m@frame$party)), length(unique(m@frame$country))))
  } else {
    cat(sprintf("[T1 %s] (no interaction) | N(nobs)=%d | parties=%d countries=%d\n",
        nm, nobs(m), length(unique(m@frame$party)), length(unique(m@frame$country))))
  }
}
cat(sprintf("[T1 M5] natquota est=%.3f se=%.3f p=%.4f\n", summary(out5)$coefficients["natquota","Estimate"], summary(out5)$coefficients["natquota","Std. Error"], summary(out5)$coefficients["natquota","Pr(>|t|)"]))

cat("\n[T1 M2 model summary coefficients]\n"); print(round(summary(out2)$coefficients,4))

# ---------- Table 3: N and Ncountries per family ----------
full_form <- pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
  year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 +
  as.factor(prop2) + natquota + weurope + (1|party) + (1|country)
fams <- c("Christian Dem","Conservative","Green / New Left","Liberal","Social Dem")
cat("\n[Table 3] model N and cluster counts:\n")
for (fm in fams) {
  d <- newd[ newd$newpartyfam==fm, ]
  m <- lmer(full_form, data=d, REML=FALSE)
  cat(sprintf("  %-16s rows=%d  model N(nobs)=%d  parties=%d  countries=%d\n",
      fm, nrow(d), nobs(m), length(unique(m@frame$party)), length(unique(m@frame$country))))
}

# ---------- In-text predicted values: M/F=2, votechange +/-5 (Model 5) ----------
cat("\n[In-text predicted %women MPs @ M/F ratio 2, vote change -5 vs +5]\n")
b <- fixef(out5)
newd2cc <- newd2[ complete.cases(newd2[,c("lag1_mfcombined10","chgvotelagged","year","femaleleader2_lag","cabinet_party2_lag","lag1womenpar","tier1_avemag2","prop2","natquota","weurope")]), ]
# use representative values: mean of covariates
repvals <- list(
  lag1_mfcombined10 = 2,
  chgvotelagged = c(-5, 5),
  year = mean(newd2cc$year),
  femaleleader2_lag = mean(newd2cc$femaleleader2_lag),
  cabinet_party2_lag = mean(newd2cc$cabinet_party2_lag),
  lag1womenpar = mean(newd2cc$lag1womenpar),
  tier1_avemag2 = mean(newd2cc$tier1_avemag2),
  prop2 = 3, natquota = mean(newd2cc$natquota), weurope = mean(newd2cc$weurope))
for (vc in c(-5,5)) {
  x <- c(1, 2, vc, 2*vc, repvals$year, repvals$femaleleader2_lag, repvals$cabinet_party2_lag,
         repvals$lag1womenpar, repvals$tier1_avemag2, 0,0, repvals$natquota, repvals$weurope)
  # match order of fixef(out5): Intercept, lag1_mf, chgvote, lag1:chg, year, femaleleader, cabinet, womenpar, tier1, factor3, natquota, weurope
  pred <- sum(b * x)
  cat(sprintf("  Vote Change = %+d => predicted %% women = %.2f\n", vc, pred))
}
cat("\nfixef(out5):\n"); print(round(b,4))

# ---------- PVV 2017 & SVP 2015 residuals from Table A7 procedure (Model 5 on na.omit temp_r) ----------
vars <- c("country","countryname","year","party","partyname","partyabbrev","pfem_new2","lag1_mfcombined10","chgvotelagged",
  "femaleleader2_lag","cabinet_party2_lag","lag1womenpar","tier1_avemag2","prop2","natquota","weurope")
temp_r <- na.omit(newd2[vars])
m5r <- lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged +
  year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
  (1|party)+(1|country), data=temp_r, REML=FALSE)
temp_r$resid5 <- residuals(m5r)
cat("\n[PVV 2017 / SVP 2015 residuals (fn 12 claim: 4.7 and 1.4; SD 8.3)]\n")
cat("  sd(resid5):", sd(temp_r$resid5), "| sd(predicted_mod5):", sd(predict(m5r)), "\n")
cat("  sd(predicted_mod2):", sd(predict(lmer(pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + lag1_mfcombined10:chgvotelagged + (1|party)+(1|country), data=temp_r, REML=FALSE))), "\n")
for (pn in c("PVV","SVP")) {
  sub <- temp_r[ temp_r$partyname %in% c("PVV", pn) | temp_r$partyabbrev %in% c(pn), ]
  if (nrow(sub)>0) for (i in seq_len(nrow(sub))) {
    cat(sprintf("  %s %d resid=%.2f\n", sub$partyname[i], sub$year[i], sub$resid5[i]))
  }
}
cat("\nDistinct partyabbrev/partyname around SVP/PVV:\n")
print(unique(temp_r[grepl("People|Freedom|Progress|PVV|SVP", temp_r$partyname), c("partyname","partyabbrev","year")]))

cat("\n==== END (status: OK) ====\n")
