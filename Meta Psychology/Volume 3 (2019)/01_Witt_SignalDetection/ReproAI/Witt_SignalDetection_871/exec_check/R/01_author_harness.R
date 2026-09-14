##
## ReproAI re-audit harness (fresh run, R 4.6.1)
## Paper: Witt (2019), Meta-Psychology, MP.2018.871 — Signal Detection simulation study
##
## The author's own simulation functions (runSims / plotAUC) are lifted VERBATIM from
## Witt_SDT_Simulations_v2.R (extracted/) into a non-interactive harness. Only a fixed
## set.seed, a per-config loop, and summary statistics are added. No number in the
## author's core functions has been changed.
##
suppressMessages({library(BayesFactor); library(pROC); library(pwr)})
options(warn = -1)

## ---- Author's verbatim functions (Witt_SDT_Simulations_v2.R) ----
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
        group1 <- rnorm(N, mean1, mySDs[1])
        group2 <- rnorm(N, mean2, mySDs[2])
        if (mySDs[1] == mySDs[2]) { a <- t.test(group2, group1, var.equal = T) } else { a <- t.test(group2, group1) }
        sa <- sa + 1
        saveSims$modeledD[sa] <- effectSizes[j]
        saveSims$sampleSize[sa] <- N
        saveSims$actualD[sa] <- (mean(group1) - mean(group2)) / sqrt((sd(group1)^2 + sd(group2)^2) / 2)
        saveSims$p[sa] <- a$p.value
        saveSims$t[sa] <- a$statistic
        saveSims$BF[sa] <- exp(ttest.tstat(t = a$statistic, n1 = N, n2 = N, rscale = 0.707)[['bf']])
      }
    }
  }
  return(saveSims)
}

plotAUC <- function(saveSims, dt, plotIt, crits, priorOdds) {
  auc <- rep(0, 2 + length(priorOdds))
  sg  <- c(log(saveSims$p[which(saveSims$modeledD > 0)]), log(saveSims$p[which(saveSims$modeledD == 0)]))
  sf  <- c(rep(1, length(which(saveSims$modeledD > 0))), rep(0, length(which(saveSims$modeledD == 0))))
  fit_glm <- glm(sf ~ sg, family = binomial(link = "logit"))
  glm_response_scores <- predict(fit_glm, data.frame(sg, sf), type = "response")
  auc[1] <- suppressMessages(auc(sf, glm_response_scores, quiet = TRUE))
  sg3 <- c(saveSims$actualD[which(saveSims$modeledD > 0)], saveSims$actualD[which(saveSims$modeledD == 0)])
  fit_glm3 <- glm(sf ~ sg3, family = binomial(link = "logit"))
  glm_response_scores3 <- predict(fit_glm3, data.frame(sg3, sf), type = "response")
  auc[2] <- suppressMessages(auc(sf, glm_response_scores3, quiet = TRUE))
  for (ii in 1:length(priorOdds)) {
    sg2 <- c(log(priorOdds[ii] * saveSims$BF[which(saveSims$modeledD > 0)]), log(priorOdds[ii] * saveSims$BF[which(saveSims$modeledD == 0)]))
    fit_glm2 <- glm(sf ~ sg2, family = binomial(link = "logit"))
    glm_response_scores2 <- predict(fit_glm2, data.frame(sg2, sf), type = "response")
    auc[2 + ii] <- suppressMessages(auc(sf, glm_response_scores2, quiet = TRUE))
  }
  return(auc)
}

## ---- Harness wrapper (adds fixed seed + config loop) ----
runExperiment <- function(cfg, seed = NA) {
  if (!is.na(seed)) set.seed(seed)
  sampleSizes <- cfg$sampleSize
  effectSizes <- c(0, cfg$effect)
  mean1 <- .5; mySDs <- c(.1, .1)
  nNull <- cfg$nNull; nEff <- cfg$nEff; numTimes <- cfg$numTimes
  priorOdds <- cfg$priorOdds; runRep <- cfg$runReplication
  aauc <- matrix(0, ncol = 3 + length(priorOdds), nrow = numTimes)
  colnames(aauc) <- c("run", "aucP", "aucES", paste0("aucBF", priorOdds))
  for (i in 1:numTimes) {
    ss <- runSims(sampleSizes, effectSizes, mean1, mySDs, nNull, nEff)
    if (runRep) {
      ss2 <- runSims(sampleSizes, effectSizes, mean1, mySDs, nNull, nEff)
      ss$p <- pmax(ss$p, ss2$p); ss$BF <- pmin(ss$BF, ss2$BF); ss$actualD <- pmin(ss$actualD, ss2$actualD)
    }
    ca <- plotAUC(ss, data.frame(), FALSE, NULL, priorOdds)
    aauc[i, 1] <- i; aauc[i, 2] <- ca[1]; aauc[i, 3] <- ca[2]
    for (jj in 1:length(priorOdds)) aauc[i, 3 + jj] <- ca[2 + jj]
  }
  as.data.frame(aauc)
}

outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/01_Witt_SignalDetection/ReproAI/Witt_SignalDetection_871/exec_check/output"
dir.create(outdir, showWarnings = FALSE)

results <- list()

## ---- Experiment 1 (d=.50, n=64, 80% power) + seed drift + pooled ----
cfg1 <- list(sampleSize = 64, effect = .5, nNull = 10, nEff = 10, numTimes = 100, priorOdds = c(1), runReplication = FALSE)
exp1a <- runExperiment(cfg1, seed = 1)
r1 <- data.frame(Quantity = c("aucP","aucES","aucBF1"),
  mean = c(mean(exp1a$aucP), mean(exp1a$aucES), mean(exp1a$aucBF1)),
  median = c(median(exp1a$aucP), median(exp1a$aucES), median(exp1a$aucBF1)),
  sd = c(sd(exp1a$aucP), sd(exp1a$aucES), sd(exp1a$aucBF1)))
results$Exp1_seed1 <- r1

drows <- NULL
driftCols <- list()
for (s in 1:5) {
  e <- runExperiment(cfg1, seed = s)
  drows <- rbind(drows, data.frame(seed = s, mean = mean(e$aucP), median = median(e$aucP), sd = sd(e$aucP)))
  driftCols[[s]] <- e$aucP
}
results$Exp1_drift <- drows
pooled <- unlist(driftCols)
results$Exp1_pooled <- data.frame(mean = mean(pooled), median = median(pooled), sd = sd(pooled))
results$Exp1_aucP_vs_BF <- data.frame(rmse = sqrt(mean((exp1a$aucP - exp1a$aucBF1)^2)), maxAbsDiff = max(abs(exp1a$aucP - exp1a$aucBF1)))

## ---- Experiment 2 (n=105, 95% power) ----
cfg2 <- list(sampleSize = 105, effect = .5, nNull = 10, nEff = 10, numTimes = 100, priorOdds = c(1), runReplication = FALSE)
exp2 <- runExperiment(cfg2, seed = 1)
results$Exp2 <- data.frame(Quantity = c("aucP","aucES","aucBF1"),
  mean = c(mean(exp2$aucP), mean(exp2$aucES), mean(exp2$aucBF1)),
  median = c(median(exp2$aucP), median(exp2$aucES), median(exp2$aucBF1)),
  sd = c(sd(exp2$aucP), sd(exp2$aucES), sd(exp2$aucBF1)))

## ---- Experiment 3 (replication, retain higher p) ----
cfg3 <- list(sampleSize = 64, effect = .5, nNull = 10, nEff = 10, numTimes = 100, priorOdds = c(1), runReplication = TRUE)
exp3 <- runExperiment(cfg3, seed = 1)
results$Exp3 <- data.frame(Quantity = c("aucP","aucES","aucBF1"),
  mean = c(mean(exp3$aucP), mean(exp3$aucES), mean(exp3$aucBF1)),
  median = c(median(exp3$aucP), median(exp3$aucES), median(exp3$aucBF1)),
  sd = c(sd(exp3$aucP), sd(exp3$aucES), sd(exp3$aucBF1)))

## ---- Experiment 7 (posterior odds; prior odds .1/1/10; equal null/effect) ----
cfg7 <- list(sampleSize = 64, effect = .5, nNull = 10, nEff = 10, numTimes = 100, priorOdds = c(.1, 1, 10), runReplication = FALSE)
exp7 <- runExperiment(cfg7, seed = 1)
results$Exp7 <- data.frame(Quantity = c("aucP","aucES","aucBF0.1","aucBF1","aucBF10"),
  mean = c(mean(exp7$aucP), mean(exp7$aucES), mean(exp7$aucBF0.1), mean(exp7$aucBF1), mean(exp7$aucBF10)),
  median = c(median(exp7$aucP), median(exp7$aucES), median(exp7$aucBF0.1), median(exp7$aucBF1), median(exp7$aucBF10)),
  sd = c(sd(exp7$aucP), sd(exp7$aucES), sd(exp7$aucBF0.1), sd(exp7$aucBF1), sd(exp7$aucBF10)))

## ---- Experiment 8 (4x nulls: 16 null + 4 effect; prior odds .25/1/4) ----
cfg8 <- list(sampleSize = 64, effect = .5, nNull = 16, nEff = 4, numTimes = 100, priorOdds = c(.25, 1, 4), runReplication = FALSE)
exp8 <- runExperiment(cfg8, seed = 1)
results$Exp8 <- data.frame(Quantity = c("aucP","aucES","aucBF0.25","aucBF1","aucBF4"),
  mean = c(mean(exp8$aucP), mean(exp8$aucES), mean(exp8$aucBF0.25), mean(exp8$aucBF1), mean(exp8$aucBF4)),
  median = c(median(exp8$aucP), median(exp8$aucES), median(exp8$aucBF0.25), median(exp8$aucBF1), median(exp8$aucBF4)),
  sd = c(sd(exp8$aucP), sd(exp8$aucES), sd(exp8$aucBF0.25), sd(exp8$aucBF1), sd(exp8$aucBF4)))

## ---- Power series (AUC_p by power, d=.50) ----
powers <- c(.5, .8, .9, .95, .99)
nPow <- sapply(powers, function(p) ceiling(pwr.t.test(n = NULL, d = .5, power = p, sig.level = .05, type = "two.sample", alternative = "two.sided")$n))
powRows <- NULL
for (idx in seq_along(powers)) {
  cfg <- list(sampleSize = nPow[idx], effect = .5, nNull = 10, nEff = 10, numTimes = 100, priorOdds = c(1), runReplication = FALSE)
  e <- runExperiment(cfg, seed = 1)
  powRows <- rbind(powRows, data.frame(power = powers[idx], n = nPow[idx], mean = mean(e$aucP), median = median(e$aucP), sd = sd(e$aucP)))
}
results$PowerSeries <- powRows

## ---- Experiment 4 (effect size series d=.1-.8 at 80% power) ----
effVals <- seq(.1, .8, length.out = 8)
nE4 <- sapply(effVals, function(dv) ceiling(pwr.t.test(n = NULL, d = dv, power = .8, sig.level = .05, type = "two.sample", alternative = "two.sided")$n))
e4Rows <- NULL
for (di in seq_along(effVals)) {
  cfg <- list(sampleSize = nE4[di], effect = effVals[di], nNull = 10, nEff = 10, numTimes = 100, priorOdds = c(1), runReplication = FALSE)
  e <- runExperiment(cfg, seed = 1)
  e4Rows <- rbind(e4Rows, data.frame(effect = effVals[di], n = nE4[di], mean = mean(e$aucP), median = median(e$aucP), sd = sd(e$aucP)))
}
results$Exp4 <- e4Rows

saveRDS(results, file.path(outdir, "author_results.rds"))

## ---- Write CSVs ----
write.table(r1,                    file.path(outdir, "exp1_aucs.csv"),      sep = ",", row.names = FALSE, quote = FALSE)
write.table(drows,                 file.path(outdir, "exp1_drift.csv"),     sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$Exp1_pooled,   file.path(outdir, "exp1_pooled.csv"),    sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$Exp1_aucP_vs_BF, file.path(outdir, "exp1_aucP_vs_BF.csv"), sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$Exp2,          file.path(outdir, "exp2_aucs.csv"),      sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$Exp3,          file.path(outdir, "exp3_aucs.csv"),      sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$Exp7,          file.path(outdir, "exp7_aucs.csv"),      sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$Exp8,          file.path(outdir, "exp8_aucs.csv"),      sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$PowerSeries,   file.path(outdir, "power_series.csv"),   sep = ",", row.names = FALSE, quote = FALSE)
write.table(results$Exp4,          file.path(outdir, "exp4_aucs.csv"),      sep = ",", row.names = FALSE, quote = FALSE)

## ---- Console log ----
cat("==== START (status: OK) ====\n")
cat("== Exp1 aucP (ms .96/.97/.04) ==\n"); print(r1)
cat("== Exp1 drift (seeds 1-5) ==\n"); print(drows)
cat("== Exp1 pooled ==\n"); print(results$Exp1_pooled)
cat("== Exp1 aucP vs aucBF (C27) ==\n"); print(results$Exp1_aucP_vs_BF)
cat("== Exp2 aucP (ms .99/1/.01) ==\n"); print(results$Exp2)
cat("== Exp3 aucP (ms .97/.99/.04) ==\n"); print(results$Exp3)
cat("== Exp7 (ms p .96/.98/.04) ==\n"); print(results$Exp7)
cat("== Exp8 (ms p .95/.97/.07) ==\n"); print(results$Exp8)
cat("== Power series (ms 50:.85/.87/.10 90:.975/.99/.03 95:.984/1/.03 99:.999/1/.004) ==\n"); print(results$PowerSeries)
cat("== Exp4 (ms M .95 range .947-.961) ==\n"); print(results$Exp4)
cat("==== END (status: OK) ====\n")
