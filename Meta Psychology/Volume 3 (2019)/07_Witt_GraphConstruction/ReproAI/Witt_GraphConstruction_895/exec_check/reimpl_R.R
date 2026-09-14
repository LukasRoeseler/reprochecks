# ReproAI re-audit (2026-09-14) of Witt (2019) MP.2018.895
# Independent R reimplementation of the author's per-subject per-condition LM pipeline.
# Conventions (verified against author notebook Witt_AnalyzeGraphSD_V4_adapted.Rmd):
#   - effect size -> corr code: d=0->1, d=0.1->1.5, d=0.3->2, d=0.5->3, d=0.8->4; centered -2.5
#   - condition mapping by graphType NAME: full=FULL, standardized=SD, minimal=SMALL/MIN
#   - per-subject per-condition lm(resp ~ corrCentered) on all trials -> slope=sensitivity
#   - bias %  = (intercept - 2.5)/2.5*100
#   - sub-analyses: effectSize > 1 (d>0.1) and effectSize < 5 (no/small effect)
#   - dz = |t|/sqrt(n)  (Lakens 2013 paired dz); 95% CI via psych::cohen.d.ci
#   - BF via BayesFactor::ttest.tstat(t=, n1=n, rscale=0.707) medium prior
# BetOnData: no RNG used anywhere -> results are deterministic; set.seed kept for the one
# BayesFactor MCMC-free analytic path.

options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
suppressMessages({ library(BayesFactor); library(psych) })
set.seed(42)

condCode <- function(g){
  g <- tolower(as.character(g))
  ifelse(g %in% c("full"), 1L,
    ifelse(g %in% c("sd"), 2L,
      ifelse(g %in% c("small","min","minimal"), 3L, NA_integer_)))
}

codeCorr <- function(e){
  out <- rep(NA_real_, length(e))
  out[e==0] <- 1; out[e==1] <- 1.5; out[e==3] <- 2
  out[e==5] <- 3; out[e==8] <- 4
  out
}

# per-subject analysis over a given data subset
indiv <- function(dt, s, cc){
  d <- dt[dt$Subject==s & dt$cond==cc,]
  m <- lm(resp ~ corrCentered, data=d)
  data.frame(subj=s, cond=cc,
             intercept=as.numeric(coef(m)[1]), coef=as.numeric(coef(m)[2]),
             bias=(as.numeric(coef(m)[1])-2.5)/2.5*100)
}

# Run one experiment
runExp <- function(exp, f, excl, subjfilter){
  dt <- read.csv(file.path(wrk,"data",f), stringsAsFactors=FALSE)
  if ("axisRange" %in% colnames(dt)) colnames(dt)[colnames(dt)=="axisRange"] <- "graphType"
  if (!is.null(subjfilter)) dt <- dt[subjfilter(dt),]
  dt$corr <- codeCorr(dt$effectSize)
  dt$corrCentered <- dt$corr - 2.5
  dt$cond <- condCode(dt$graphType)
  dt <- dt[!is.na(dt$cond) & !is.na(dt$corr),]
  subjs <- sort(setdiff(unique(dt$Subject), excl))

  allSlopes <- do.call(rbind, lapply(subjs, function(s) indiv(dt,s,1)))
  out <- data.frame()
  for (cc in 1:3){
    for (s in subjs){
      out <- rbind(out, indiv(dt, s, cc))
    }
  }
  # subset analyses
  effSub <- dt[dt$effectSize > 1,]   # d > 0.1 (codes 3,5,8 -> but effectSize values are 1,3,5,8 or 0,3,5,8)
  noSub  <- dt[dt$effectSize < 5,]   # no/small effect (codes 0/1 and 3)
  effSlopes <- do.call(rbind, lapply(subjs, function(s)
    do.call(rbind, lapply(1:3, function(cc){
      d <- effSub[effSub$Subject==s & effSub$cond==cc,]
      m <- lm(resp ~ corrCentered, data=d)
      data.frame(subj=s, cond=cc, coef=as.numeric(coef(m)[2]))
    }))))
  noSlopes <- do.call(rbind, lapply(subjs, function(s)
    do.call(rbind, lapply(1:3, function(cc){
      d <- noSub[noSub$Subject==s & noSub$cond==cc,]
      m <- lm(resp ~ corrCentered, data=d)
      data.frame(subj=s, cond=cc, coef=as.numeric(coef(m)[2]))
    }))))

  n <- length(subjs)
  wide <- function(A, val){
    w <- data.frame(subj=subjs)
    for (cc in 1:3){ sub <- A[A$cond==cc, c("subj",val)]; w[[paste0(val,"_",cc)]] <- sub[[val]][match(w$subj, sub$subj)] }
    w
  }
  wAll <- wide(out,"coef"); wEff <- wide(effSlopes,"coef"); wNo <- wide(noSlopes,"coef"); wB <- wide(out,"bias")

  pair <- function(x,y,label){
    t <- t.test(x,y,paired=TRUE)
    dz <- abs(as.numeric(t$statistic))/sqrt(n)
    ci <- psych::cohen.d.ci(dz, n1=n)
    bf <- tryCatch(exp(as.numeric(BayesFactor::ttest.tstat(t=as.numeric(t$statistic), n1=n, rscale=0.707)[['bf']])), error=function(e) NA)
    cat(sprintf("  %-22s t=%.3f p=%.4f dz=%.3f CI[%.2f,%.2f] BF=%.3g\n", label, as.numeric(t$statistic), t$p.value, dz, ci[1], ci[3], bf))
    c(label=label, t=as.numeric(t$statistic), p=t$p.value, dz=dz, ciL=ci[1], ciU=ci[3], BF=bf)
  }
  ones <- function(x,label){
    t <- t.test(x)
    dz <- abs(as.numeric(t$statistic))/sqrt(n)
    ci <- psych::cohen.d.ci(dz, n1=n)
    bf <- tryCatch(exp(as.numeric(BayesFactor::ttest.tstat(t=as.numeric(t$statistic), n1=n, rscale=0.707)[['bf']])), error=function(e) NA)
    cat(sprintf("  %-22s M=%.2f SD=%.2f t=%.3f p=%.4f dz=%.3f CI[%.2f,%.2f] BF=%.3g\n", label, mean(x), sd(x), as.numeric(t$statistic), t$p.value, dz, ci[1], ci[3], bf))
    c(label=label, t=as.numeric(t$statistic), p=t$p.value, dz=dz, ciL=ci[1], ciU=ci[3], BF=bf)
  }

  ms <- function(W, prefix){
    md <- sapply(1:3, function(cc) mean(W[[paste0(prefix,"_",cc)]]))
    sdv <- sapply(1:3, function(cc) sd(W[[paste0(prefix,"_",cc)]]))
    sprintf("Full=%.2f(%.2f) Std=%.2f(%.2f) Min=%.2f(%.2f)", md[1],sdv[1],md[2],sdv[2],md[3],sdv[3]) }

  cat(sprintf("\n===== EXPERIMENT %d (analyzed N=%d, df=%d) =====\n", exp, n, n-1))
  cat("  ALL-TRIAL SLOPES :", ms(wAll,"coef"),"\n")
  cat("  d>0.1 SLOPES     :", ms(wEff,"coef"),"\n")
  cat("  no/small SLOPES  :", ms(wNo,"coef"),"\n")
  cat("  BIAS %%           :", ms(wB,"bias"),"\n")
  cat("  -- paired t-tests (all-trial slopes) --\n")
  r1 <- pair(wAll$coef_2, wAll$coef_1, "Std vs Full")
  r2 <- pair(wAll$coef_3, wAll$coef_2, "Min vs Std")
  r3 <- pair(wAll$coef_3, wAll$coef_1, "Min vs Full")
  cat("  -- paired t-tests (d>0.1 slopes) --\n")
  q1 <- pair(wEff$coef_2, wEff$coef_1, "Std vs Full")
  q2 <- pair(wEff$coef_3, wEff$coef_2, "Min vs Std")
  q3 <- pair(wEff$coef_3, wEff$coef_1, "Min vs Full")
  cat("  -- paired t-tests (no/small slopes) --\n")
  s1 <- pair(wNo$coef_2, wNo$coef_1, "Std vs Full")
  s2 <- pair(wNo$coef_3, wNo$coef_2, "Min vs Std")
  s3 <- pair(wNo$coef_3, wNo$coef_1, "Min vs Full")
  cat("  -- bias one-sample t-tests vs 0 --\n")
  b1 <- ones(wB$bias_1, "Full bias")
  b2 <- ones(wB$bias_2, "Std bias")
  b3 <- ones(wB$bias_3, "Min bias")

  out$exp <- exp
  list(out=out, n=n, pairAll=r1, pairEff=q1, pairNo=s1, bias=b2)
}

cat("========== REPROAI RE-AUDIT R REIMPLEMENTATION — Witt (2019) MP.2018.895 ==========\n")
cat("Runtime:", Sys.time(), "\n")
cat("R:", R.version.string, " BayesFactor:", as.character(packageVersion("BayesFactor")),
    " psych:", as.character(packageVersion("psych")),"\n")
cat("RNG seed set to 42 (deterministic analysis; no simulation RNG used)\n")

allLong <- do.call(rbind, list(
  runExp(1,"axisSize 1-24.csv", c(1,8),      function(d) d$Subject<10)$out,
  runExp(2,"axisSize 1-24.csv", c(13,17,24), function(d) d$Subject>9)$out,
  runExp(3,"axisRangeEBv2 1-14.csv", c(3,4), NULL)$out,
  runExp(4,"axisRangeLineV2 1-20.csv", c(4,9,15,16), NULL)$out,
  runExp(5,"axisRangeLine 1-14.csv", c(7,13), NULL)$out
))
write.csv(allLong, file.path(wrk,"exec_check","output","reimpl_long_R.csv"), row.names=FALSE)

cat("\n===== EXP3 sub-analyses (N=9, excl 2,3,4,5) =====\n")
d3 <- read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"), stringsAsFactors=FALSE)
d3$corr <- codeCorr(d3$effectSize); d3$corrCentered <- d3$corr-2.5
d3$cond <- condCode(d3$graphType); d3 <- d3[!is.na(d3$cond)&!is.na(d3$corr),]
subjs <- sort(setdiff(unique(d3$Subject), c(2,3,4,5)))
n <- length(subjs)
for (crit in c("eff","no")){
  dd <- if(crit=="eff") d3[d3$effectSize>1,] else d3[d3$effectSize<5,]
  w <- data.frame(subj=subjs)
  for (cc in 1:3){ vals <- sapply(subjs, function(s){ m<-lm(resp~corrCentered,data=dd[dd$Subject==s&dd$cond==cc,]); as.numeric(coef(m)[2]) }); w[[paste0("c",cc)]] <- vals }
  tst <- function(x,y){ t<-t.test(x,y,paired=TRUE); dz<-abs(as.numeric(t$statistic))/sqrt(n); ci<-psych::cohen.d.ci(dz,n1=n); bf<-tryCatch(exp(as.numeric(BayesFactor::ttest.tstat(t=as.numeric(t$statistic),n1=n,rscale=0.707)[['bf']])),error=function(e)NA); cat(sprintf("    %s: t=%.3f p=%.4f dz=%.3f CI[%.2f,%.2f] BF=%.3g\n", "x", as.numeric(t$statistic), t$p.value, dz, ci[1], ci[3], bf)) }
  cat("  ", crit, ":\n")
  tst(w$c2,w$c1); tst(w$c3,w$c2); tst(w$c3,w$c1)
}
cat("===== DONE (status: OK) =====\n")
