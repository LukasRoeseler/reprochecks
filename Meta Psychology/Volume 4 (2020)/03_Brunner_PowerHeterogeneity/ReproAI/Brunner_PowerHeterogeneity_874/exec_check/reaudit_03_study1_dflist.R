# ReproAI re-audit (2026-09-14) -- Study 1, p-curve2.1 / p-uniform / ML columns, Table 1.
#
# KEY QUESTION: In the paper, sample sizes vary (n ~ Poisson(86)) so df2 = n-2 varies per study.
# The AUTHOR's recovered estimator functions (heteroNpcurveF/heteroNpunifF/heteroNmleF) only accept a
# SINGLE scalar dfree2. A prior audit applied them at a representative df2=84 and found p-uniform and
# ML do NOT reproduce Table 1. Here we implement the CORRECT per-study-df2 versions and test whether
# THEY reproduce Table 1. This distinguishes "author-function fixed-df2 limitation" from a real
# discrepancy in the paper's reported numbers.
#
# Conventions (matched to author code): es0 == f^2 (Cohen lambda = f^2*(df1+df2+1) = n*f^2 for df1=1).

alpha <- 0.05; MEANN <- 86
set.seed(20260914)
rn_sig <- function(k) pmax(rpois(k, MEANN), 3)

expPower_f2 <- function(f2, nmc = 200000) {
  n <- pmax(rpois(nmc, MEANN), 3); crit <- qf(1 - alpha, 1, n - 2)
  mean(1 - pf(crit, 1, n - 2, ncp = n * f2))
}
findF2 <- function(target) if (target <= 0.05) 0 else uniroot(function(f2) expPower_f2(f2) - target, c(1e-4, 4))$root

# ---- per-study df2 versions ----
pcurve_est <- function(FF, n) {
  df2 <- n - 2; crit <- qf(1 - alpha, 1, df2)
  KSloss <- function(es0) {
    ncp <- n * es0
    pp <- exp(pf(FF, 1, df2, ncp, lower.tail = FALSE, log.p = TRUE) -
              pf(crit, 1, df2, ncp, lower.tail = FALSE, log.p = TRUE))
    as.numeric(ks.test(pp, "punif")$statistic)
  }
  eshat <- optimize(KSloss, interval = c(0, 1))$minimum
  mean(1 - pf(crit, 1, df2, ncp = n * eshat))
}
punif_est <- function(FF, n) {
  df2 <- n - 2; crit <- qf(1 - alpha, 1, df2); k <- length(FF)
  loss <- function(es0) {
    ncp <- n * es0
    logp <- pf(FF, 1, df2, ncp, log.p = TRUE) -
            pf(crit, 1, df2, ncp, lower.tail = FALSE, log.p = TRUE)
    ( -sum(logp) - k )^2
  }
  eshat <- optimize(loss, interval = c(0, 1))$minimum
  mean(1 - pf(crit, 1, df2, ncp = n * eshat))
}
mle_est <- function(FF, n) {
  df2 <- n - 2; crit <- qf(1 - alpha, 1, df2)
  mll <- function(es0) {
    ncp <- n * abs(es0)
    sum(pf(crit, 1, df2, ncp, lower.tail = FALSE, log.p = TRUE)) -
    sum(df(FF, 1, df2, ncp, log = TRUE))
  }
  eshat <- abs(nlminb(0.1, mll, lower = 0)$par)
  mean(1 - pf(crit, 1, df2, ncp = n * eshat))
}

paper <- list(
  pcurve = c("0.05"=.059,"0.25"=.253,"0.50"=.497,"0.75"=.747),
  punif  = c("0.05"=.058,"0.25"=.251,"0.50"=.496,"0.75"=.746),
  ml     = c("0.05"=.057,"0.25"=.251,"0.50"=.497,"0.75"=.747)
)

nsims <- 1000
res <- character()
out <- function(s){res<<-c(res,s); cat(s,"\n")}
for (k in c(100, 250)) {
  for (tp in c(.25,.50,.75,.05)) {
    f2 <- findF2(tp)
    pc <- pu <- ml <- numeric(nsims)
    for (s in 1:nsims) {
      n <- rn_sig(k); ncp <- n*f2; crit <- qf(1-alpha,1,n-2)
      g <- 1 - pf(crit,1,n-2,ncp); U <- runif(k)
      FF <- qf(1-g*U,1,n-2,ncp)
      pc[s] <- pcurve_est(FF, n)
      pu[s] <- punif_est(FF, n)
      ml[s] <- tryCatch(mle_est(FF, n), error=function(e) NA_real_)
    }
    for (m in c("pcurve","punif","ml")) {
      v <- switch(m, pcurve=pc, punif=pu, ml=ml); o <- !is.na(v)
      est <- mean(v[o]); se <- sd(v[o])/sqrt(sum(o)); pv <- paper[[m]][[sprintf("%.2f",tp)]]
      out(sprintf("k=%-4d true=%.2f %-6s est=%.3f (SE=%.4f) paper=%.3f delta=%.3f",
                  k,tp,m,est,se,pv,est-pv))
    }
  }
}
dir.create("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output", showWarnings=FALSE, recursive=TRUE)
writeLines(res,"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output/reaudit_study1_dflist.txt")
cat("\nWrote reaudit_study1_dflist.txt\n")
