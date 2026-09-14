##
## ReproAI re-audit: clean per-study p-hack count under the manuscript's "20 studies
## (10 null + 10 effect)" convention, plus the bias / distance-to-perfection analysis
## that underpins claims C7, C39, C40 (which criteria achieve best EUCLIDEAN distance to
## the top-left corner = 100% hits / 0% false alarms).
##
suppressMessages({library(BayesFactor); library(pROC)})
options(warn = -1)

outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/01_Witt_SignalDetection/ReproAI/Witt_SignalDetection_871/exec_check/output"
dir.create(outdir, showWarnings = FALSE)

## ============ 1) Hack count under 10 null + 10 effect convention (C22: 4.3, SD 2) ===
set.seed(1)
mean1 <- .5; mySDs <- c(.1, .1); N <- 30; d <- .5
sdPooled <- sqrt((.1^2 + .1^2) / 2); mean2 <- mean1 - (d * sdPooled)
numTimes <- 100
hackNull <- numeric(numTimes); hackEff <- numeric(numTimes)
for (i in 1:numTimes) {
  hN <- 0; hE <- 0
  for (k in 1:10) { g1 <- rnorm(N, mean1, .1); g2 <- rnorm(N, mean2, .1); a <- t.test(g2, g1, var.equal = T)
    if (a$p.value < .2 & a$p.value > .05) hE <- hE + 1 }
  for (k in 1:10) { g1 <- rnorm(N, mean1, .1); g2 <- rnorm(N, mean1, .1); a <- t.test(g2, g1, var.equal = T)
    if (a$p.value < .2 & a$p.value > .05) hN <- hN + 1 }
  hackNull[i] <- hN; hackEff[i] <- hE
}
hackTbl <- data.frame(
  null_mean = mean(hackNull), null_sd = sd(hackNull),
  eff_mean  = mean(hackEff),  eff_sd  = sd(hackEff),
  total_mean = mean(hackNull + hackEff), total_sd = sd(hackNull + hackEff),
  total_min = min(hackNull + hackEff), total_max = max(hackNull + hackEff))
write.csv(hackTbl, file.path(outdir, "exp5_hackcount_10plus10.csv"), row.names = FALSE)
cat("==== Hack count (10 null + 10 effect) seed=1 ====\n"); print(hackTbl)

## ============ 2) Distance-to-perfection by criterion (C7, C39, C40) ===
## Use the author's Exp1 machinery: simulate one set of 20 studies (10 null/10 effect,
## n=64 d=.50) and compute hit/fa rate at each criterion, then Euclidean distance to (1,0).
runSims <- function(sampleSizes, effectSizes, mean1, mySDs, numStudiesNull, numStudiesEff) {
  sdPooled <- sqrt((mySDs[1]^2 + mySDs[2]^2) / 2)
  saveSims <- as.data.frame(matrix(0, ncol = 7, nrow = length(sampleSizes) * (numStudiesNull + numStudiesEff)))
  colnames(saveSims) <- c("groupNum","modeledD","sampleSize","actualD","t","p","BF")
  sa <- 0
  for (i in 1:length(sampleSizes)) {
    N <- sampleSizes[i]
    for (j in 1:length(effectSizes)) {
      mean2 <- mean1 - (effectSizes[j] * sdPooled)
      numStudies3 <- ifelse(effectSizes[j] == 0, numStudiesNull, numStudiesEff)
      for (k in 1:numStudies3) {
        group1 <- rnorm(N, mean1, mySDs[1]); group2 <- rnorm(N, mean2, mySDs[2])
        a <- t.test(group2, group1, var.equal = T)
        sa <- sa + 1
        saveSims$modeledD[sa] <- effectSizes[j]; saveSims$sampleSize[sa] <- N
        saveSims$actualD[sa] <- (mean(group1) - mean(group2)) / sqrt((sd(group1)^2 + sd(group2)^2) / 2)
        saveSims$p[sa] <- a$p.value; saveSims$t[sa] <- a$statistic
        saveSims$BF[sa] <- exp(ttest.tstat(t = a$statistic, n1 = N, n2 = N, rscale = 0.707)[['bf']])
      }
    }
  }
  saveSims
}

biasAtSize <- function(n, eff = .5, nNull = 10, nEff = 10, seed = 1, numTimes = 100) {
  set.seed(seed)
  ## criteria matrix: p-thresholds and BF-thresholds
  pc <- c(.10, .05, .005, .001)
  bc <- c(1, 2, 3, 10)
  ## distance averaged over numTimes sets of studies
  acc <- data.frame(criterion = c(paste0("p<", pc), paste0("BF>", bc)),
                    type = c(rep("p", 4), rep("BF", 4)), stringsAsFactors = FALSE)
  dSum <- numeric(8); dN <- 0
  for (i in 1:numTimes) {
    ss <- runSims(n, c(0, eff), .5, c(.1, .1), nNull, nEff)
    effP <- ss$p[ss$modeledD > 0]; nullP <- ss$p[ss$modeledD == 0]
    effBF <- ss$BF[ss$modeledD > 0]; nullBF <- ss$BF[ss$modeledD == 0]
    dd <- numeric(8)
    for (j in 1:4) {
      hit <- mean(effP <= pc[j]); fa <- mean(nullP <= pc[j])
      dd[j] <- sqrt((1 - hit)^2 + fa^2)
    }
    for (j in 1:4) {
      hit <- mean(effBF >= bc[j]); fa <- mean(nullBF >= bc[j])
      dd[4 + j] <- sqrt((1 - hit)^2 + fa^2)
    }
    dSum <- dSum + dd; dN <- dN + 1
  }
  acc$dist.mean <- dSum / dN
  acc
}

b64 <- biasAtSize(64)
write.csv(b64, file.path(outdir, "bias_distance_n64.csv"), row.names = FALSE)
cat("\n==== Distance-to-perfection, n=64 d=.50 (C7/C39/C40) ====\n"); print(b64)

## order check: which criteria beat which
cat("\nOrder (lowest distance = best):\n"); print(b64[order(b64$dist.mean), c("criterion","dist.mean")])
cat("==== END (status: OK) ====\n")
