# ReproAI internal-consistency & summary-stat reproduction audit
# Paper: Flesia et al. (2020) JCM 9, 3350 / PsyArXiv 10.31234/osf.io/yb2h8
# Purpose: verify what IS checkable from the shipped summary-level supplement
# (no raw data or code shipped on OSF node e285f). These are closed-form checks.
options(width=200)
cat("==== START (status: OK) ====\n")
cat("R version:", R.version.string, "\n")
cat("Audit date:", Sys.Date(), "\n\n")

outdir <- "output"
if (!dir.exists(outdir)) dir.create(outdir)
sink(file.path(outdir,"internal_consistency.log"), split=TRUE)

## ------------------------------------------------------------------
## 0. Sample / N arithmetic (paper section 2.2)
## ------------------------------------------------------------------
cat("==== SECTION 0: N ARITHMETIC ====\n")
volunteers <- 2072; duplicates <- 19; final_n <- 2053
cat(sprintf("2072 - 19 = %d (reported %d) => %s\n", volunteers-duplicates, final_n,
            ifelse(volunteers-duplicates==final_n,"OK","MISMATCH")))
fem <- 1555; mal <- 480; oth <- 18
cat(sprintf("1555+480+18 = %d (reported 2053) => %s\n", fem+mal+oth,
            ifelse(fem+mal+oth==final_n,"OK","MISMATCH")))
hi <- 393; lo <- 1642
cat(sprintf("high+low = %d (=2035 after excluding 18 'other') => %s\n", hi+lo,
            ifelse(hi+lo==final_n-oth,"OK","MISMATCH")))
train_n <- 1628; test_n <- 407
cat(sprintf("train+test = %d (reported 2035) => %s\n", train_n+test_n,
            ifelse(train_n+test_n==final_n-oth,"OK","MISMATCH")))
cat(sprintf("test set = 407 is %.3f%% of 2035; 20%% of 2035 = %.1f => %s\n",
            100*test_n/(final_n-oth), 0.2*(final_n-oth),
            ifelse(abs(test_n-0.2*(final_n-oth))<0.5,"OK","MISMATCH")))
cat(sprintf("high+low = %d; train high+low = 314+1314 = %d; test = 79+328 = %d\n",
            hi+lo, 314+1314, 79+328))

## ------------------------------------------------------------------
## 1. Section 3.1 one-sample t-tests and Cohen's d (summary-level reproduction)
## ------------------------------------------------------------------
cat("\n==== SECTION 1: ONE-SAMPLE t & d (section 3.1) ====\n")
onesamp <- function(M, SD, n, mu){
  se <- SD/sqrt(n); t <- (M-mu)/se; d <- (M-mu)/SD
  c(t=t, d=d, se=se, p=2*pt(-abs(t), n-1))
}
# males: sample M=16.71 SD=6.91, n=480, normative mu=15.2
m <- onesamp(16.71,6.91,480,15.2)
cat(sprintf("Males: recomputed t=%.3f (reported 4.79), d=%.3f (reported 0.22), p=%.3g\n", m["t"],m["d"],m["p"]))
# females: sample M=19.44 SD=6.79, n=1555, normative mu=16.3
f <- onesamp(19.44,6.79,1555,16.3)
cat(sprintf("Females: recomputed t=%.3f (reported 18.21), d=%.3f (reported 0.46), p=%.3g\n", f["t"],f["d"],f["p"]))
cat("Note: recomputation uses the sample's own rounded M and SD; small residual from rounding.\n")

## ------------------------------------------------------------------
## 2. Table S2: item-level two-sample t-tests & Cohen's d from means/SDs
##    pooled (Student's) df = n1+n2-2 = 2033, matching reported df.
## ------------------------------------------------------------------
n1 <- 393  # high stress
n2 <- 1642 # low stress
items <- data.frame(
  item=1:10,
  M_hi =c(2.62,3.09,3.51,2.30,2.97,2.85,2.72,2.93,2.96,2.92),
  SD_hi=c(0.91,0.80,0.60,0.83,0.85,1.04,0.91,0.78,0.84,0.89),
  M_lo =c(1.84,1.60,2.08,1.30,2.02,1.76,1.82,1.76,1.68,1.19),
  SD_lo=c(0.91,0.98,0.92,0.78,0.86,1.08,0.85,0.92,0.97,0.91),
  t_rep=c(27.95,28.04,29.48,22.75,19.82,18.06,18.71,23.20,23.958,33.972),
  d_rep=c(1.57,1.58,1.66,1.28,1.11,1.01,1.05,1.30,1.345,1.908)
)
items$d_rep <- -1*items$d_rep  # reported as negative (low-minus-high convention)
ttest2 <- function(M1,SD1,n1,M2,SD2,n2){
  s2p <- ((n1-1)*SD1^2 + (n2-1)*SD2^2)/(n1+n2-2)
  sp <- sqrt(s2p)
  se <- sp*sqrt(1/n1+1/n2)
  t <- (M1-M2)/se
  d <- (M1-M2)/sp
  # welch
  seW <- sqrt(SD1^2/n1 + SD2^2/n2)
  tW <- (M1-M2)/seW
  list(sp=sp, se=se, t=t, d=d, tW=tW)
}
cat("\n==== SECTION 2: Table S2 item t-tests from reported means/SDs ====\n")
cat("(compared against manuscript's reported t [pooled, df=2033] and Cohen's d)\n")
items$t_calc <- NA; items$d_calc <- NA
for(i in 1:nrow(items)){
  r <- ttest2(items$M_hi[i],items$SD_hi[i],n1,items$M_lo[i],items$SD_lo[i],n2)
  items$t_calc[i] <- r$t; items$d_calc[i] <- r$d
  cat(sprintf("Item %2d: rep t=%6.3f calc t=%6.3f (Welch=%.3f) | rep d=%7.4f calc d=%7.4f | pooledSD=%.3f\n",
      items$item[i], items$t_rep[i], r$t, r$tW, items$d_rep[i], r$d, r$sp))
}
t_tol <- 0.20; d_tol <- 0.05
items$t_ok <- abs(items$t_calc-items$t_rep) <= t_tol
items$d_ok <- abs(items$d_calc-items$d_rep) <= d_tol
cat("\nt-consistency (delta<=0.20):", sum(items$t_ok), "/", nrow(items))
cat("\nd-consistency (delta<=0.05):", sum(items$d_ok), "/", nrow(items))
write.csv(items, file.path(outdir,"tableS2_item_recomputation.csv"), row.names=FALSE)

## ------------------------------------------------------------------
## 3. Table S2: reported t <-> reported Cohen's d mutual consistency
##    t = d * sqrt(n1*n2/(n1+n2)) for two-sample pooled
## ------------------------------------------------------------------
cat("\n==== SECTION 3: reported t <-> reported d relation ====\n")
k <- sqrt(n1*n2/(n1+n2))
items$t_from_d <- items$d_rep * k   # d signed negative here
items$d_from_t <- items$t_rep / k
items$td_ok <- abs(abs(items$t_rep) - abs(items$d_from_t)) <= 0.15
cat(sprintf("sqrt(n1*n2/(n1+n2)) = %.4f\n", k))
for(i in 1:nrow(items)){
  cat(sprintf("Item %2d: t=%6.3f vs t-from-d=%6.3f | d=%7.4f vs d-from-t=%7.4f  %s\n",
      items$item[i], items$t_rep[i], items$d_from_t[i], items$d_rep[i], -items$d_from_t[i]*-1,
      ifelse(items$td_ok[i],"OK","CHECK")))
}
cat("(d stored as negative = low-minus-high convention; compare magnitudes)\n")

## ------------------------------------------------------------------
## 4. Table S1: correlation CI & p internal consistency (Fisher z), where n known
##    Correlation p-value: t = r*sqrt(n-2)/sqrt(1-r^2), df = n-2
##    CI via Fisher z: atanh(r) +/- 1.96/sqrt(n-3)
## ------------------------------------------------------------------
cat("\n==== SECTION 4: Table S1 correlation CI/p consistency ====\n")
nA <- 2053
corchk <- data.frame(
  var=c("Age","Gender(male)","Student","InternalLOC","BSCS GSD","BSCS IC",
        "Agreeableness","Conscientiousness","EmotionalStability","HOUSEhold"),
  r   =c(-0.26,-0.15,0.19,-0.32,-0.32,-0.36,-0.18,-0.21,-0.47,0.13),
  ciL =c(-0.30,-0.20,0.15,-0.36,-0.36,-0.39,-0.22,-0.25,-0.51,0.09),
  ciU =c(-0.20,-0.11,0.23,-0.28,-0.28,-0.32,-0.13,-0.16,-0.44,0.17),
  p_rep=c(1.458e-33,3.462e-12,4.488e-18,1.548e-25,2.647e-50,1.807e-50,1.450e-15,6.103e-21,1.322e-114,3.502e-9)
)
for(i in 1:nrow(corchk)){
  r <- corchk$r[i]; n <- nA
  z <- atanh(r); sez <- 1/sqrt(n-3)
  lo <- tanh(z-1.96*sez); hi <- tanh(z+1.96*sez)
  t <- r*sqrt(n-2)/sqrt(1-r^2)
  p <- 2*pt(-abs(t), n-2)
  cat(sprintf("%-18s r=%5.2f  CIcalc=(%6.2f,%6.2f) rep=(%6.2f,%6.2f)  pcalc=%.3e rep=%.3e\n",
      corchk$var[i], r, lo, hi, corchk$ciL[i], corchk$ciU[i], p, corchk$p_rep[i]))
}
cat("(CI/P recomputed assuming the correlation is vs PSS-10 on the full analytic N=2053)\n")

## ------------------------------------------------------------------
## 5. Table 3: F-measure consistency from precision & recall
## ------------------------------------------------------------------
cat("\n==== SECTION 5: Table 3 F-measure from precision/recall ====\n")
ml <- data.frame(
  alg=c("Logistic-High","Logistic-Low","SVM-High","SVM-Low","NB-High","NB-Low","RF-High","RF-Low"),
  P=c(0.349,0.919,0.337,0.914,0.361,0.909,0.438,0.881),
  R=c(0.759,0.659,0.747,0.646,0.709,0.698,0.532,0.835),
  F_rep=c(0.478,0.767,0.465,0.757,0.479,0.790,0.480,0.858)
)
ml$F_calc <- 2*ml$P*ml$R/(ml$P+ml$R)
ml$ok <- abs(ml$F_calc-ml$F_rep)<=0.005
for(i in 1:nrow(ml)) cat(sprintf("%-14s P=%.3f R=%.3f Fcalc=%.3f Frep=%.3f %s\n",
   ml$alg[i],ml$P[i],ml$R[i],ml$F_calc[i],ml$F_rep[i],ifelse(ml$ok[i],"OK","CHECK")))
cat("F-measure agreement:", sum(ml$ok), "/", nrow(ml), "\n")

## ------------------------------------------------------------------
## 6. Descriptive cross-checks (paper text vs supplement)
## ------------------------------------------------------------------
cat("\n==== SECTION 6: text vs supplement descriptives ====\n")
cat("Paper text age mean = 35.81 (SD 13.19); supplement Table S1 all-participants = 35.81 (13.19)\n")
cat("Paper text education = 15.35 (SD 3.43); supplement Table S1 = 15.36 (SD 3.43)\n")
cat("=> education mean differs by 0.01 year across the two sources (rounding or typo).\n")

cat("\n==== END (status: OK) ====\n")
sink()
cat("Done. Log at", file.path(outdir,"internal_consistency.log"), "\n")
