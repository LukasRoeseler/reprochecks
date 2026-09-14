suppressMessages({library(BayesFactor); library(pROC)})
runSims <- function(sampleSizes, effectSizes, mean1, mySDs, numStudiesNull,numStudiesEff) {
  sdPooled <- sqrt((mySDs[1]^2 + mySDs[2]^2) / 2)
  saveSims <- as.data.frame(matrix(0,ncol=7, nrow=length(sampleSizes) * (numStudiesNull+numStudiesEff)))
  colnames(saveSims) <- c("groupNum","modeledD","sampleSize","actualD","t","p","BF")
  sa <- 0
  for (i in 1:length(sampleSizes)) {
    N <- sampleSizes[i]
    for (j in 1:length(effectSizes)) {
      mean2 <- mean1 - (effectSizes[j] * sdPooled)
      numStudies3 <- ifelse(effectSizes[j] == 0, numStudiesNull,numStudiesEff)
      for (k in 1:numStudies3) {
        group1 <- rnorm(N,mean1,mySDs[1]); group2 <- rnorm(N,mean2,mySDs[2])
        a <- t.test(group2, group1,var.equal=T)
        sa <- sa+1
        saveSims$modeledD[sa] <- effectSizes[j]; saveSims$sampleSize[sa] <- N
        saveSims$actualD[sa] <- (mean(group1) - mean(group2))/sqrt((sd(group1)^2 + sd(group2)^2)/2)
        saveSims$p[sa] <- a$p.value; saveSims$t[sa] <- a$statistic
        saveSims$BF[sa] <- exp(ttest.tstat(t=a$statistic, n1=N, n2=N, rscale = 0.707)[['bf']])
      }
    }
  }
  saveSims
}
plotAUC <- function(saveSims,priorOdds) {
  auc <- rep(0,2+length(priorOdds))
  sg <- c(log(saveSims$p[which(saveSims$modeledD > 0)]),log(saveSims$p[which(saveSims$modeledD == 0)]))
  sf <- c(rep(1,length(which(saveSims$modeledD > 0))),rep(0,length(which(saveSims$modeledD == 0))))
  fit_glm <- glm(sf ~ sg, family=binomial(link="logit"))
  glm_response_scores <- predict(fit_glm, data.frame(sg,sf), type="response")
  auc[1] <- suppressMessages(auc(sf, glm_response_scores, quiet=TRUE))
  sg3 <- c(saveSims$actualD[which(saveSims$modeledD > 0)],saveSims$actualD[which(saveSims$modeledD == 0)])
  fit_glm3 <- glm(sf ~ sg3, family=binomial(link="logit"))
  glm_response_scores3 <- predict(fit_glm3, data.frame(sg3,sf), type="response")
  auc[2] <- suppressMessages(auc(sf, glm_response_scores3, quiet=TRUE))
  for(ii in 1:length(priorOdds)) {
    sg2 <- c(log(priorOdds[ii]*saveSims$BF[which(saveSims$modeledD>0)]),log(priorOdds[ii]*saveSims$BF[which(saveSims$modeledD==0)]))
    fit_glm2 <- glm(sf ~ sg2, family=binomial(link="logit"))
    glm_response_scores2 <- predict(fit_glm2, data.frame(sg2,sf), type="response")
    auc[2+ii] <- suppressMessages(auc(sf, glm_response_scores2, quiet=TRUE))
  }
  auc
}
set.seed(1)
ss <- runSims(64, c(0,.5), .5, c(.1,.1), 10, 10)
ca <- plotAUC(ss, c(1))
cat(system.time({ for(i in 1:100) plotAUC(ss, c(1)) })[["elapsed"]], "\n")
