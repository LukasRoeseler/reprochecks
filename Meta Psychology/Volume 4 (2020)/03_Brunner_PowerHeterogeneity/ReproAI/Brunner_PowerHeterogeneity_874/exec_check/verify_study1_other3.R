# ReproAI re-audit: Study 1 - p-curve2.1 / p-uniform / ML columns (Table 1).
# The recovered author library functions (heteroN*) take a single scalar df2 and so
# cannot represent per-study sample-size heterogeneity. The paper's method description
# (SS "Estimation methods") is: estimate ONE common effect size es from all k p-values,
# conditional on each study's own n, then compute per-study power with its own n and
# average. We reimplement exactly that. This is a genuine independent reimplementation
# of the described method (NOT byte-for-byte of the unrecovered driver).

set.seed(20260914)
alpha <- 0.05; MEANN <- 86
rn_sig <- function(k) pmax(rpois(k, MEANN), 3)

# Generate a sample of k SIGNIFICANT F statistics at fixed effect-size f2, variable n.
genSigF <- function(k, f2) {
  n <- rn_sig(k)
  ncp <- n * f2
  crit <- qf(1 - alpha, 1, n - 2)
  g <- 1 - pf(crit, 1, n - 2, ncp)
  U <- runif(k)
  FF <- qf(1 - g * U, 1, n - 2, ncp)
  list(FF = FF, n = n, crit = crit, ncp = ncp)
}

# ---- p-curve 2.1: minimize KS statistic of conditional p-values vs uniform ----
pcurve21 <- function(FF, n, crit) {
  loss <- function(es) {
    ncp <- n * es
    newpp <- (1 - pf(FF, 1, n - 2, ncp)) / (1 - pf(crit, 1, n - 2, ncp))
    suppressWarnings(ks.test(newpp, "punif")$statistic)
  }
  eshat <- optimize(loss, interval = c(0, 1))$minimum
  mean(1 - pf(crit, 1, n - 2, n * eshat))
}

# ---- p-uniform: find es such that Y = -sum(log(newpp)) = k ----
puniform <- function(FF, n, crit) {
  k <- length(FF)
  loss <- function(es) {
    ncp <- n * es
    lognewpp <- pf(FF, 1, n - 2, ncp, log.p = TRUE) -
                pf(crit, 1, n - 2, ncp, lower.tail = FALSE, log.p = TRUE)
    ( -sum(lognewpp) - k )^2
  }
  eshat <- optimize(loss, interval = c(0, 1))$minimum
  mean(1 - pf(crit, 1, n - 2, n * eshat))
}

# ---- ML (heterogeneous-n): maximize product of conditional densities ----
heteroML <- function(FF, n, crit) {
  mll <- function(es) {
    ncp <- n * abs(es)
    sum(pf(crit, 1, n - 2, ncp, lower.tail = FALSE, log.p = TRUE)) -
      sum(df(FF, 1, n - 2, ncp, log = TRUE))
  }
  Search <- nlminb(start = 0.1, mll, lower = 0)
  eshat <- abs(Search$par)
  mean(1 - pf(crit, 1, n - 2, n * eshat))
}

# Table 1 values (F-test, df=1), k=100 columns
tab <- list(
  "0.05" = c(pcurve = 0.059, punif = 0.058, ml = 0.057),
  "0.25" = c(pcurve = 0.253, punif = 0.251, ml = 0.251),
  "0.50" = c(pcurve = 0.497, punif = 0.496, ml = 0.497),
  "0.75" = c(pcurve = 0.747, punif = 0.746, ml = 0.747)
)

expPower_f2 <- function(f2) { n <- pmax(rpois(2e5, MEANN), 3); crit <- qf(1-alpha,1,n-2); mean(1-pf(crit,1,n-2,n*f2)) }
findF2 <- function(target){ if(target<=0.05) return(0); uniroot(function(f2) expPower_f2(f2)-target, c(1e-4,4))$root }

nsims <- 1200; k <- 100
out <- character()
cat("Study 1 (k=100): p-curve2.1 / p-uniform / ML reimplementation, mean over", nsims, "sims\n")
cat("================================================================\n")
for (tp in c(.25, .50, .75)) {
  f2 <- findF2(tp)
  pc <- pu <- ml <- numeric(nsims)
  nfail <- 0
  for (s in 1:nsims) {
    d <- genSigF(k, f2)
    pc[s] <- tryCatch(pcurve21(d$FF, d$n, d$crit), error = function(e) NA_real_)
    pu[s] <- tryCatch(puniform(d$FF, d$n, d$crit), error = function(e) NA_real_)
    ml[s] <- tryCatch(heteroML(d$FF, d$n, d$crit), error = function(e) NA_real_)
    if (is.na(pc[s]) || is.na(pu[s]) || is.na(ml[s])) nfail <- nfail + 1
  }
  paper <- tab[[sprintf("%.2f", tp)]]
  vecs <- list(pcurve = pc, punif = pu, ml = ml)
  for (nm in names(vecs)) {
    v <- vecs[[nm]]; o <- !is.na(v)
    m <- mean(v[o]); se <- sd(v[o]) / sqrt(sum(o))
    line <- sprintf("true=%.2f %-6s : est=%.3f (SE=%.4f)  paper=%.3f  delta=%.3f  (fail=%d)",
                    tp, nm, m, se, paper[[nm]], m - paper[[nm]], nfail)
    out <- c(out, line); cat(line, "\n")
  }
}
dir.create("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output", showWarnings = FALSE, recursive = TRUE)
writeLines(out, "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output/study1_other3_results.txt")
cat("\nDone.\n")
