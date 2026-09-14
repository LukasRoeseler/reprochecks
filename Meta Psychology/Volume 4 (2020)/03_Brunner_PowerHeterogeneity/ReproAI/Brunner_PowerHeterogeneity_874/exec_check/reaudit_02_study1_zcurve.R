# ReproAI re-audit (2026-09-14) -- Study 1 z-curve column, Table 1.
# Simulation from the paper's described design (variable n ~ Poisson(86), fixed effect size f,
# F-test numerator df = 1) with inverse-CDF selection of significant F (cf. author rsigF).
# Estimator = AUTHOR's recovered zcurve() (p-values only, no n).
# Reduced Monte Carlo (S sims per cell) with fixed seed; compare mean estimate to Table 1.

source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/estimatR_raw.txt")

set.seed(20260914)
alpha <- 0.05; MEANN <- 86
rn_sig <- function(k) pmax(rpois(k, MEANN), 3)

expPower_f2 <- function(f2, nmc = 200000) {
  n <- pmax(rpois(nmc, MEANN), 3)
  crit <- qf(1 - alpha, 1, n - 2)
  mean(1 - pf(crit, 1, n - 2, ncp = n * f2))
}
findF2 <- function(target) if (target <= 0.05) 0 else uniroot(function(f2) expPower_f2(f2) - target, c(1e-4, 4))$root

paper_zcurve <- list(
  "15" =c("0.05"=.086,"0.25"=.314,"0.50"=.513,"0.75"=.704),
  "25" =c("0.05"=.071,"0.25"=.305,"0.50"=.516,"0.75"=.712),
  "50" =c("0.05"=.058,"0.25"=.293,"0.50"=.513,"0.75"=.717),
  "100"=c("0.05"=.049,"0.25"=.280,"0.50"=.508,"0.75"=.723),
  "250"=c("0.05"=.040,"0.25"=.268,"0.50"=.502,"0.75"=.728)
)

nsims <- 2000
res <- character()
out  <- function(s){res<<-c(res,s); cat(s,"\n")}
out(sprintf("Study 1 z-curve column (Table 1). Mean over %d sims per cell, fixed seed 20260914.", nsims))
for (k in c(100, 250, 50)) {
  for (tp in c(.05,.25,.50,.75)) {
    f2 <- findF2(tp); ests <- numeric(nsims); nerr <- 0
    for (s in 1:nsims) {
      n <- rn_sig(k); ncp <- n*f2; crit <- qf(1-alpha,1,n-2)
      g <- 1 - pf(crit,1,n-2,ncp); U <- runif(k)
      FF <- qf(1-g*U,1,n-2,ncp); pv <- pf(FF,1,n-2,lower.tail=FALSE)
      v <- tryCatch(suppressWarnings(zcurve(pv,Plot=0,Verbose=FALSE)), error=function(e) NA_real_)
      if (is.na(v)) nerr <- nerr+1 else ests[s] <- v
    }
    paper <- paper_zcurve[[as.character(k)]][[sprintf("%.2f",tp)]]
    ok <- !is.na(ests); m <- mean(ests[ok]); se <- sd(ests[ok])/sqrt(sum(ok))
    out(sprintf("k=%-4d true=%.2f zcurve=%.3f (SE=%.4f) paper=%.3f delta=%.3f nfail=%d",
                k,tp,m,se,paper,m-paper,nerr))
  }
}
dir.create("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output", showWarnings=FALSE, recursive=TRUE)
writeLines(res,"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output/reaudit_study1_zcurve.txt")
cat("\nWrote reaudit_study1_zcurve.txt\n")
