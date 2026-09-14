##
## ReproAI re-audit: Experiment 5 (optional stopping / p-hacking)
## Author's p-hacking loop lifted VERBATIM from Witt_SDT_Simulations_OptionalStopping_v2.R,
## run in a fresh non-interactive harness with a fixed seed and config loop.
##
suppressMessages({library(BayesFactor); library(pROC)})
options(warn = -1)

## ---- Author's runSims (optional-stopping version), verbatim ----
runSims <- function(sampleSizes, effectSizes, mean1, mySDs, numStudies) {
  sdPooled <- sqrt((mySDs[1]^2 + mySDs[2]^2) / 2)
  allPs  <- array(0, c(length(sampleSizes), length(effectSizes), numStudies))
  allPs2 <- array(NA, c(length(sampleSizes), length(effectSizes), numStudies))
  allBFs <- array(0, c(length(sampleSizes), length(effectSizes), numStudies))
  allBFs2<- array(NA, c(length(sampleSizes), length(effectSizes), numStudies))
  allESs <- array(0, c(length(sampleSizes), length(effectSizes), numStudies))
  allESs2<- array(NA, c(length(sampleSizes), length(effectSizes), numStudies))
  numExtraSs <- 10
  numTimesRunExtra <- 10
  for (i in 1:length(sampleSizes)) {
    N <- sampleSizes[i]
    for (j in 1:length(effectSizes)) {
      mean2 <- mean1 - (effectSizes[j] * sdPooled)
      for (k in 1:numStudies) {
        group1 <- rnorm(N, mean1, mySDs[1]); group2 <- rnorm(N, mean2, mySDs[2])
        a <- t.test(group2, group1, var.equal = T)
        allPs[i,j,k] <- a$p.value; allBFs[i,j,k] <- exp(ttest.tstat(t = a$statistic, n1 = N, n2 = N, rscale = 0.707)[['bf']])
        allESs[i,j,k] <- (mean(group1) - mean(group2)) / sqrt((sd(group1)^2 + sd(group2)^2) / 2)
        BFcurr <- allBFs[i,j,k]
        if (a$p.value < .2 & a$p.value > .05) {
          for (keepGoing in 1:numTimesRunExtra) {
            if (a$p.value > .05) {
              group1b <- c(group1, rnorm(numExtraSs, mean1, mySDs[1]))
              group2b <- c(group2, rnorm(numExtraSs, mean2, mySDs[2]))
              a <- t.test(group2b, group1b, var.equal = T)
            }
          }
          allPs2[i,j,k] <- a$p.value
          allESs2[i,j,k] <- (mean(group1b) - mean(group2b)) / sqrt((sd(group1b)^2 + sd(group2b)^2) / 2)
        }
        if (BFcurr < 3 & BFcurr > 1) {
          for (keepGoing in 1:numTimesRunExtra) {
            if (BFcurr < 3) {
              group1b <- c(group1, rnorm(numExtraSs, mean1, mySDs[1]))
              group2b <- c(group2, rnorm(numExtraSs, mean2, mySDs[2]))
              a <- t.test(group2b, group1b, var.equal = T)
              BFcurr <- exp(ttest.tstat(t = a$statistic, n1 = length(group1b), n2 = length(group2b), rscale = 0.707)[['bf']])
            }
          }
          allBFs2[i,j,k] <- BFcurr
        }
      }
    }
  }
  return(list(allPs, allBFs, allESs, allPs2, allBFs2, allESs2))
}

runExp5 <- function(n, d, numStudies = 20, numTimes = 100, seed = 1) {
  set.seed(seed)
  mean1 <- .5; mySDs <- c(.1, .1)
  sampleSizes <- n; effectSizes <- c(0, d)
  numHacked <- numeric(numTimes)
  hitB <- numeric(numTimes); faB <- numeric(numTimes)
  hitA <- numeric(numTimes); faA <- numeric(numTimes)
  for (i in 1:numTimes) {
    myOut <- runSims(sampleSizes, effectSizes, mean1, mySDs, numStudies)
    allPs <- myOut[[1]]; allPs2 <- myOut[[4]]
    numHacked[i] <- length(which(!is.na(allPs2)))
    notHacked <- which(is.na(allPs2)); allPs2f <- allPs2; allPs2f[notHacked] <- allPs[notHacked]
    crit <- .05
    hitB[i] <- mean(allPs[1,2,] <= crit); faB[i] <- mean(allPs[1,1,] <= crit)
    hitA[i] <- mean(allPs2f[1,2,] <= crit); faA[i] <- mean(allPs2f[1,1,] <= crit)
  }
  data.frame(n = n, d = d,
    hack_mean = mean(numHacked), hack_sd = sd(numHacked),
    hack_min = min(numHacked), hack_max = max(numHacked),
    hitB = mean(hitB), faB = mean(faB), hitA = mean(hitA), faA = mean(faA),
    hitDeltaPct = (mean(hitA) - mean(hitB)) / max(mean(hitB), 1e-9) * 100,
    faDeltaPct  = (mean(faA) - mean(faB)) / max(mean(faB), 1e-9) * 100,
    hitDeltaPP = (mean(hitA) - mean(hitB)) * 100,
    faDeltaPP  = (mean(faA) - mean(faB)) * 100)
}

outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/01_Witt_SignalDetection/ReproAI/Witt_SignalDetection_871/exec_check/output"
dir.create(outdir, showWarnings = FALSE)

r30 <- runExp5(30, .5, seed = 1)
r30d <- NULL
for (s in 1:5) r30d <- rbind(r30d, runExp5(30, .5, seed = s))
rHP <- runExp5(148, .5, seed = 1)

cat("==== EXP5 (n=30, d=.50) seed=1 ====\n"); print(r30)
cat("\n==== EXP5 drift seeds 1-5 (n=30 d=.50) ====\n"); print(r30d)
cat("\n==== EXP5 high power (n=148 ~ >99% power, d=.50) seed=1 ====\n"); print(rHP)

write.csv(r30,  file.path(outdir, "exp5_n30.csv"),  row.names = FALSE)
write.csv(r30d, file.path(outdir, "exp5_drift.csv"), row.names = FALSE)
write.csv(rHP,  file.path(outdir, "exp5_highpower.csv"), row.names = FALSE)
cat("\n==== END (status: OK) ====\n")
