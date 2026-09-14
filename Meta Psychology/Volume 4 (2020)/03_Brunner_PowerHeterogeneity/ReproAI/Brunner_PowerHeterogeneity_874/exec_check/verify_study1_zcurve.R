# ReproAI re-audit: Study 1 (heterogeneity in sample size only) - Z-CURVE column.
# The paper's headline recommendation is z-curve. z-curve uses ONLY p-values (no n),
# so it is the cleanest method to reimplement from the paper's described simulation.
#
# Simulation (from paper SS2 headings):
#  - Sample size n ~ Poisson(86). For F with numerator df = 1, df2 = n - 2.
#  - Effect size fixed (metric f, Cohen 1988). ncp = n*f^2  (Cohen lambda = f^2*(df1+df2+1),
#    with df1+df2+1 = 1+n-2+1 = n).
#  - We choose f^2 so that E_{n~Poisson(86)}[power(n)] = target population mean power.
#  - Only significant F statistics enter the sample (inverse-CDF selection, cf. rsigF).
# We then apply the AUTHOR's recovered zcurve() on each simulated sample of significant
# F-tests and average over many simulated meta-analyses -> compare to Table 1 z-curve column.
#
# This is a genuine reimplementation from the paper's parameters + author's estimator;
# it is NOT a byte-for-byte reproduction of the (unrecovered) simulation driver.

source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/estimatR_raw.txt")

set.seed(20260914)
alpha <- 0.05
MEANN <- 86

# n distribution after ensuring df2 >= 1 (need n-2 >= 1 -> n >= 3); Poisson floor at 3
rn_sig <- function(k) pmax(rpois(k, MEANN), 3)

# Expected power as a function of f2 (fixed effect size), marginal over n~Poisson(86)
expPower_f2 <- function(f2, nmc = 200000) {
  set.seed(20260914)
  n <- pmax(rpois(nmc, MEANN), 3)
  crit <- qf(1 - alpha, 1, n - 2)
  pow <- 1 - pf(crit, 1, n - 2, ncp = n * f2)
  mean(pow)
}

findF2 <- function(target) {
  if (target <= 0.05) return(0)          # power = alpha when effect size = 0
  f <- uniroot(function(f2) expPower_f2(f2) - target, c(1e-4, 4))$root
  f
}

# Table 1 z-curve column target values (already-known true power), k=100 & 250
targets <- c(.05, .25, .50, .75)
paper_zcurve <- list(
  "100" = c("0.05" = 0.049, "0.25" = 0.280, "0.50" = 0.508, "0.75" = 0.723),
  "250" = c("0.05" = 0.040, "0.25" = 0.268, "0.50" = 0.502, "0.75" = 0.728)
)

nsims <- 2000
res <- character()
cat("Study 1 - z-curve column reimplementation (mean over", nsims, "simulated meta-analyses)\n")
cat("================================================================\n")

for (k in c(100, 250)) {
  for (tp in targets) {
    f2 <- findF2(tp)
    ests <- numeric(nsims); nerr <- 0
    for (s in 1:nsims) {
      n <- rn_sig(k)
      ncp <- n * f2
      crit <- qf(1 - alpha, 1, n - 2)
      g <- 1 - pf(crit, 1, n - 2, ncp)
      U <- runif(k)
      FF <- qf(1 - g * U, 1, n - 2, ncp)
      pv <- pf(FF, 1, n - 2, lower.tail = FALSE)
      val <- tryCatch(suppressWarnings(zcurve(pv, Plot = 0, Verbose = FALSE)),
                      error = function(e) NA_real_)
      if (is.na(val)) nerr <- nerr + 1 else ests[s] <- val
    }
    paper <- paper_zcurve[[as.character(k)]][[sprintf("%.2f", tp)]]
    ok <- !is.na(ests)
    m <- mean(ests[ok]); se <- sd(ests[ok]) / sqrt(sum(ok))
    d <- m - paper
    line <- sprintf("k=%-4d true=%.2f: zcurve=%.3f (SE=%.4f)  paper=%.3f  delta=%.3f  (n_fail=%d)",
                    k, tp, m, se, paper, d, nerr)
    res <- c(res, line)
    cat(line, "\n")
  }
}
cat("\nDone.\n")
outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output"
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
writeLines(res, file.path(outdir, "study1_zcurve_results.txt"))
