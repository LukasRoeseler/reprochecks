# ReproAI faithful reimplementation of Witt (2019) MP.2018.895
# Reproduces the author's analysis choices with EXPLICIT graphType->condition mapping
# (1=full, 2=SD/standardized, 3=small/minimal by NAME, robust to factor ordering).
# Author conventions matched:
#  - per-subject per-condition lm(resp ~ corrCentered) on all trials -> slope=sensitivity
#  - bias = (intercept - 2.5)/2.5*100
#  - dz = t/sqrt(n)  (Lakens 2013 paired dz)
#  - CIs via psych::cohen.d.ci(dz, n)
#  - Bayes factors via BayesFactor::ttestBF rscale="medium"
options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
suppressMessages({
  library(BayesFactor); library(reshape2); library(psych)
})
set.seed(42)

T2 <- function(x) x - 2.5

# graphType name -> condition code
condCode <- function(g){
  g <- tolower(as.character(g))
  ifelse(g %in% c("full"), 1L,
    ifelse(g %in% c("sd"), 2L,
      ifelse(g %in% c("small","min","minimal"), 3L, NA_integer_)))
}

# Run per-experiment individual LM, return data.frame subj, cond, intercept, coef, bias
# plus separate results for effectSize>1 subset and 0<.3 etc.
runLM <- function(dt, excl, extra_excl=NULL){
  # build corr
  dt$corr <- ifelse(dt$effectSize == 0, 1, NA)
  dt$corr[which(dt$effectSize == 1)] <- 1.5
  dt$corr[which(dt$effectSize == 3)] <- 2
  dt$corr[which(dt$effectSize == 5)] <- 3
  dt$corr[which(dt$effectSize == 8)] <- 4
  dt$corrCentered <- dt$corr - 2.5
  dt$cond <- condCode(dt$graphType)
  dt <- dt[!is.na(dt$cond),]
  subjs <- sort(unique(dt$Subject))
  res <- lapply(subjs, function(s){
    out <- list()
    for (cc in 1:3){
      d <- dt[dt$Subject==s & dt$cond==cc,]
      m <- lm(resp ~ corrCentered, data=d)
      i <- as.numeric(coef(m)[1]); b <- as.numeric(coef(m)[2])
      # effectSize > 1 subset
      d2 <- dt[dt$Subject==s & dt$cond==cc & dt$effectSize > 1,]
      m2 <- lm(resp ~ scale(corr, scale=FALSE, center=TRUE), data=d2)
      i2 <- as.numeric(coef(m2)[1]); b2 <- as.numeric(coef(m2)[2])
      # effectSize < 5 subset
      d3 <- dt[dt$Subject==s & dt$cond==cc & dt$effectSize < 5,]
      m3 <- lm(resp ~ scale(corr, scale=FALSE, center=TRUE), data=d3)
      i3 <- as.numeric(coef(m3)[1]); b3 <- as.numeric(coef(m3)[2])
      row <- data.frame(subj=s, cond=cc,
                        intercept=i, coef=b, bias=(i-2.5)/2.5*100,
                        coef_eff=b2, bias_eff=(i2-2.5)/2.5*100,
                        coef_noeff=b3, bias_noeff=(i3-2.5)/2.5*100)
      out[[cc]] <- row
    }
    do.call(rbind, out)
  })
  A <- do.call(rbind, res)
  A <- A[!(A$subj %in% excl),]
  list(A=A)
}

# paired t-test summary helper -> t, p, dz, ci, BF
pair <- function(x, y, n){
  t <- t.test(x, y, paired=TRUE)
  dz <- abs(as.numeric(t$statistic))/sqrt(n)
  ci <- psych::cohen.d.ci(dz, n1=n)
  bf <- tryCatch(exp(as.numeric(BayesFactor::ttest.tstat(t=as.numeric(t$statistic), n1=n, rscale=0.707)[['bf']])), error=function(e) NA)
  c(t=as.numeric(t$statistic), p=t$p.value, dz=dz, ciL=ci[1], ciU=ci[3], BF=bf)
}
ones <- function(x, n){
  t <- t.test(x)
  dz <- abs(as.numeric(t$statistic))/sqrt(n)
  ci <- psych::cohen.d.ci(dz, n1=n)
  bf <- tryCatch(exp(as.numeric(BayesFactor::ttest.tstat(t=as.numeric(t$statistic), n1=n, rscale=0.707)[['bf']])), error=function(e) NA)
  c(t=as.numeric(t$statistic), p=t$p.value, dz=dz, ciL=ci[1], ciU=ci[3], BF=bf)
}

long <- NULL
cat("REDO START\n")
for (exp in 1:5){
  if (exp==1){ f<-"axisSize 1-24.csv"; excl<-c(1,8); mindat<-"S<10" }
  if (exp==2){ f<-"axisSize 1-24.csv"; excl<-c(13,17,24); mindat<-"S>9" }
  if (exp==3){ f<-"axisRangeEBv2 1-14.csv"; excl<-c(3,4) }
  if (exp==4){ f<-"axisRangeLineV2 1-20.csv"; excl<-c(4,9,15,16) }
  if (exp==5){ f<-"axisRangeLine 1-14.csv"; excl<-c(7,13) }
  dt <- read.csv(file.path(wrk,"data",f))
  if ("axisRange" %in% colnames(dt)) colnames(dt)[which(colnames(dt)=="axisRange")] <- "graphType"
  if (exp<=2){ if (exp==1) dt<-dt[dt$Subject<10,] else dt<-dt[dt$Subject>9,] }
  if (exp==5){ dt$graphType <- dt$graphType }  # already Full/SD/Small
  if (exp==3){ dt$graphType <- dt$graphType }  # SD/small/full
  res <- runLM(dt, excl)
  A <- res$A
  n <- length(unique(A$subj))
  cat("\n================== EXPERIMENT", exp, "N =", n, "==================\n")

  # means/SDs all-trial slopes
  mm <- aggregate(coef ~ cond, data=A, mean)
  ssd <- aggregate(coef ~ cond, data=A, sd)
  cat("ALL-TRIAL SLOPES (Table A3): full\n"); 
  for(cc in 1:3) cat("  cond",cc, ": M=",round(mm$coef[mm$cond==cc],3)," SD=",round(ssd$coef[ssd$cond==cc],3),"\n")

  # effectSize>1 slopes (Table A4)
  mm2 <- aggregate(coef_eff ~ cond, data=A, mean)
  ssd2 <- aggregate(coef_eff ~ cond, data=A, sd)
  cat("d>0.1 SLOPES (Table A4):\n")
  for(cc in 1:3) cat("  cond",cc, ": M=",round(mm2$coef_eff[mm2$cond==cc],3)," SD=",round(ssd2$coef_eff[ssd2$cond==cc],3),"\n")

  # bias means/SDs (Table A5)
  mb <- aggregate(bias ~ cond, data=A, mean)
  sb <- aggregate(bias ~ cond, data=A, sd)
  cat("BIAS % (Table A5):\n")
  for(cc in 1:3) cat("  cond",cc, ": M=",round(mb$bias[mb$cond==cc],3)," SD=",round(sb$bias[sb$cond==cc],3),"\n")

  # manual wide pivot (reshape2 dcast with multi-value.var unreliable here)
  w <- data.frame(subj=sort(unique(A$subj)))
  for(cc in 1:3){
    sub <- A[A$cond==cc, c("subj","coef","coef_eff","coef_noeff","bias")]
    sub <- sub[match(w$subj, sub$subj),]
    w[[paste0("coef_",cc)]] <- sub$coef
    w[[paste0("coef_eff_",cc)]] <- sub$coef_eff
    w[[paste0("coef_noeff_",cc)]] <- sub$coef_noeff
    w[[paste0("bias_",cc)]] <- sub$bias
  }

  cat("\n-- Paired t-tests on ALL-TRIAL slopes --\n")
  p1<-pair(w$coef_2, w$coef_1, n); cat("SD vs Full: t=",round(p1['t'],3)," p=",round(p1['p'],4)," dz=",round(p1['dz'],3)," CI=",round(p1['ciL'],2),",",round(p1['ciU'],2)," BF=",round(p1['BF'],2),"\n")
  p2<-pair(w$coef_3, w$coef_2, n); cat("Min vs SD:  t=",round(p2['t'],3)," p=",round(p2['p'],4)," dz=",round(p2['dz'],3)," CI=",round(p2['ciL'],2),",",round(p2['ciU'],2)," BF=",round(p2['BF'],2),"\n")
  p3<-pair(w$coef_3, w$coef_1, n); cat("Min vs Full:t=",round(p3['t'],3)," p=",round(p3['p'],4)," dz=",round(p3['dz'],3)," CI=",round(p3['ciL'],2),",",round(p3['ciU'],2)," BF=",round(p3['BF'],2),"\n")

  cat("\n-- Paired t-tests on d>0.1 slopes --\n")
  q1<-pair(w$coef_eff_2, w$coef_eff_1, n); cat("SD vs Full: t=",round(q1['t'],3)," p=",round(q1['p'],4)," dz=",round(q1['dz'],3)," CI=",round(q1['ciL'],2),",",round(q1['ciU'],2)," BF=",round(q1['BF'],2),"\n")
  q2<-pair(w$coef_eff_3, w$coef_eff_2, n); cat("Min vs SD:  t=",round(q2['t'],3)," p=",round(q2['p'],4)," dz=",round(q2['dz'],3)," CI=",round(q2['ciL'],2),",",round(q2['ciU'],2)," BF=",round(q2['BF'],2),"\n")
  q3<-pair(w$coef_eff_3, w$coef_eff_1, n); cat("Min vs Full:t=",round(q3['t'],3)," p=",round(q3['p'],4)," dz=",round(q3['dz'],3)," CI=",round(q3['ciL'],2),",",round(q3['ciU'],2)," BF=",round(q3['BF'],2),"\n")

  cat("\n-- Paired t-tests on d=0-.3 (no-effect) slopes --\n")
  r1<-pair(w$coef_noeff_2, w$coef_noeff_1, n); cat("SD vs Full: t=",round(r1['t'],3)," p=",round(r1['p'],4)," dz=",round(r1['dz'],3)," CI=",round(r1['ciL'],2),",",round(r1['ciU'],2)," BF=",round(r1['BF'],2),"\n")
  r3<-pair(w$coef_noeff_3, w$coef_noeff_1, n); cat("Min vs Full:t=",round(r3['t'],3)," p=",round(r3['p'],4)," dz=",round(r3['dz'],3)," CI=",round(r3['ciL'],2),",",round(r3['ciU'],2)," BF=",round(r3['BF'],2),"\n")

  cat("\n-- Bias one-sample t-tests vs 0 --\n")
  for(cc in 1:3){
    o<-ones(w[[paste0("bias_",cc)]], n)
    cat("  cond",cc,"bias: M=",round(mb$bias[mb$cond==cc],2)," SD=",round(sb$bias[sb$cond==cc],2),
        " t=",round(o['t'],3)," p=",round(o['p'],4)," dz=",round(o['dz'],3)," CI=",round(o['ciL'],2),",",round(o['ciU'],2)," BF=",round(o['BF'],2),"\n")
  }
  A$exp<-exp; long <- rbind(long, A)
}
cat("\nREDO END\n")
write.csv(long, file.path(wrk,"output","reimpl_slopes_bias_long.csv"), row.names=FALSE)
cat("WROTE output/reimpl_slopes_bias_long.csv\n")
