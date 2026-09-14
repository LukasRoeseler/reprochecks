suppressMessages({library(pROC)})
options(warn = -1)
runSimsES <- function(sampleSizes, effectSizes, mean1, mySDs, ns0, ns1) {
  sdP <- sqrt((mySDs[1]^2 + mySDs[2]^2) / 2)
  saveSims <- as.data.frame(matrix(0, ncol = 7, nrow = length(sampleSizes) * (ns0 + ns1)))
  colnames(saveSims) <- c("groupNum","modeledD","sampleSize","actualD","t","p","BF")
  sa <- 0
  for (i in 1:length(sampleSizes)) {
    N <- sampleSizes[i]
    for (j in 1:length(effectSizes)) {
      mean2 <- mean1 - (effectSizes[j] * sdP)
      nn <- ifelse(effectSizes[j] == 0, ns0, ns1)
      for (k in 1:nn) {
        g1 <- rnorm(N, mean1, mySDs[1]); g2 <- rnorm(N, mean2, mySDs[2])
        a <- t.test(g2, g1, var.equal = T)
        sa <- sa + 1
        saveSims$p[sa] <- a$p.value
        saveSims$actualD[sa] <- (mean(group1 <- g1) - mean(g2)) / sqrt((sd(g1)^2 + sd(g2)^2) / 2)
        saveSims$modeledD[sa] <- effectSizes[j]
      }
    }
  }
  saveSims
}
set.seed(1)
nRuns <- 100
aucP <- numeric(nRuns); aucSign <- numeric(nRuns); aucAbs <- numeric(nRuns)
for (i in 1:nRuns) {
  ss <- runSimsES(64, c(0, .5), .5, c(.1, .1), 10, 10)
  sf <- c(rep(1, sum(ss$modeledD > 0)), rep(0, sum(ss$modeledD == 0)))
  fit <- glm(sf ~ c(log(ss$p[ss$modeledD > 0]), log(ss$p[ss$modeledD == 0])), family = binomial())
  aucP[i] <- suppressMessages(auc(sf, predict(fit, type = "response"), quiet = TRUE))
  dA <- c(ss$actualD[ss$modeledD > 0], ss$actualD[ss$modeledD == 0])
  fit2 <- glm(sf ~ dA, family = binomial()); aucSign[i] <- suppressMessages(auc(sf, predict(fit2, type = "response"), quiet = TRUE))
  dAbs <- abs(dA)
  fit3 <- glm(sf ~ dAbs, family = binomial()); aucAbs[i] <- suppressMessages(auc(sf, predict(fit3, type = "response"), quiet = TRUE))
}
res <- data.frame(
  mean = c(mean(aucP), mean(aucSign), mean(aucAbs)),
  row.names = c("aucP (log-p)","aucSignedD (C41)","aucAbsD (C42)"))
cat("==== Effect-size AUC comparison (Exp1, seed=1) ====\n"); print(round(res, 4))
cat("C41 signed d AUC >= p AUC:", mean(aucSign) >= mean(aucP), "\n")
cat("C42 abs d AUC approx= p AUC:", abs(mean(aucAbs) - mean(aucP)) < 0.01, " (diff=", round(mean(aucAbs)-mean(aucP),4), ")\n")
outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/01_Witt_SignalDetection/ReproAI/Witt_SignalDetection_871/exec_check/output"
write.csv(res, file.path(outdir, "effectsize_aucs.csv"))
cat("==== END (status: OK) ====\n")
