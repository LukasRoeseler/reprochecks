suppressMessages({library(BayesFactor); library(pROC)})
options(warn = -1)

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
        saveSims$p[sa] <- a$p.value
        saveSims$BF[sa] <- exp(ttest.tstat(t = a$statistic, n1 = N, n2 = N, rscale = 0.707)[['bf']])
        saveSims$modeledD[sa] <- effectSizes[j]
      }
    }
  }
  saveSims
}

biasAtSize <- function(n, eff = 0.5, nNull = 10, nEff = 10, seed = 1, numTimes = 50) {
  set.seed(seed)
  pc <- c(.10, .05, .005, .001); bc <- c(1, 2, 3, 10)
  acc <- data.frame(criterion = c(paste0("p<", pc), paste0("BF>", bc)), stringsAsFactors = FALSE)
  dSum <- numeric(8)
  for (i in 1:numTimes) {
    ss <- runSims(n, c(0, eff), .5, c(.1, .1), nNull, nEff)
    eP <- ss$p[ss$modeledD > 0]; nP <- ss$p[ss$modeledD == 0]
    eB <- ss$BF[ss$modeledD > 0]; nB <- ss$BF[ss$modeledD == 0]
    dd <- numeric(8)
    for (j in 1:4) { hit <- mean(eP <= pc[j]); fa <- mean(nP <= pc[j]); dd[j] <- sqrt((1 - hit)^2 + fa^2) }
    for (j in 1:4) { hit <- mean(eB >= bc[j]); fa <- mean(nB >= bc[j]); dd[4 + j] <- sqrt((1 - hit)^2 + fa^2) }
    dSum <- dSum + dd
  }
  acc$dist.mean <- dSum / numTimes
  acc
}

outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/01_Witt_SignalDetection/ReproAI/Witt_SignalDetection_871/exec_check/output"
for (n in c(105, 148)) {
  b <- biasAtSize(n)
  write.csv(b, file.path(outdir, paste0("bias_distance_n", n, ".csv")), row.names = FALSE)
  cat("\n==== Distance-to-perfection n =", n, "====\n")
  print(b[order(b$dist.mean), ])
}
cat("\n==== END (status: OK) ====\n")
