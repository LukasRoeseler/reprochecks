# ReproAI re-audit -- p-uniform with CORRECTED upper-tail modified p-value.
# Author recovered code uses pf(datta, log.p=T) == log(LOWER tail) in the numerator of P_j, but the
# conditional p-value is P_j = P(T>t|T>c) = [1-pf(t)]/[1-pf(c)] => log(P_j) = pf(t,low=F,log)-pf(c,low=F,log).
# Test whether the corrected version reproduces Table 1 p-uniform column.
alpha <- 0.05; MEANN <- 86
set.seed(20260914)
rn_sig <- function(k) pmax(rpois(k, MEANN), 3)
expPower_f2 <- function(f2, nmc=200000){ n<-pmax(rpois(nmc,MEANN),3); crit<-qf(1-alpha,1,n-2); mean(1-pf(crit,1,n-2,ncp=n*f2)) }
findF2 <- function(target) if(target<=0.05) 0 else uniroot(function(f2) expPower_f2(f2)-target, c(1e-4,4))$root

punif_correct <- function(FF, n) {
  df2 <- n-2; crit <- qf(1-alpha,1,df2); k <- length(FF)
  loss <- function(es0) {
    ncp <- n*es0
    logP <- pf(FF,1,df2,ncp,lower.tail=FALSE,log.p=TRUE) -
            pf(crit,1,df2,ncp,lower.tail=FALSE,log.p=TRUE)   # log of conditional p-value
    ( -sum(logP) - k )^2
  }
  eshat <- optimize(loss, interval=c(0,1))$minimum
  mean(1 - pf(crit,1,df2,ncp=n*eshat))
}
paper <- c("0.05"=.058,"0.25"=.251,"0.50"=.496,"0.75"=.746)
nsims <- 1000
res <- character(); out <- function(s){res<<-c(res,s); cat(s,"\n")}
for (k in c(100,250)) for (tp in c(.25,.50,.75,.05)) {
  f2 <- findF2(tp); est <- numeric(nsims)
  for (s in 1:nsims) {
    n <- rn_sig(k); ncp<-n*f2; crit<-qf(1-alpha,1,n-2); g<-1-pf(crit,1,n-2,ncp); U<-runif(k)
    FF <- qf(1-g*U,1,n-2,ncp)
    est[s] <- tryCatch(punif_correct(FF,n), error=function(e) NA_real_)
  }
  ok <- !is.na(est); m<-mean(est[ok]); se<-sd(est[ok])/sqrt(sum(ok)); pv<-paper[[sprintf("%.2f",tp)]]
  out(sprintf("k=%-4d true=%.2f punif_correct=%.3f (SE=%.4f) paper=%.3f delta=%.3f", k,tp,m,se,pv,m-pv))
}
writeLines(res,"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output/reaudit_study1_punif_correct.txt")
cat("\nWrote reaudit_study1_punif_correct.txt\n")
