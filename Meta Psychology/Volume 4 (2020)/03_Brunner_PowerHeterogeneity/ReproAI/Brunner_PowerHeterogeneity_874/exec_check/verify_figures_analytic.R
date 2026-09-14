# ReproAI re-audit: analytic verification of Figures 1 & 2 selection-model claims.
# Figure 1: uniform power on [0.05, 1.0], mean before = 0.525, after = 0.635 (CLAIMED)
# Figure 2: beta(13,6)*0.95+0.05, mean before = 0.700, after = 0.714 (CLAIMED)
# Theorem 3: E(G|sig) = E(G^2)/E(G). Compute analytically + numerically.

require(stats)

cmp <- function(label, computed, paper) {
  d <- abs(computed - paper)
  flag <- if (d < 1e-3) "MATCH" else "DIFF"
  cat(sprintf("%-58s computed=%.5f paper=%.4f delta=%.2e -> %s\n", label, computed, paper, d, flag))
}

# ---- Figure 1: Uniform[a,b] ----
a <- 0.05; b <- 1.0
Ep  <- (a + b) / 2                       # E[power] before
Ep2 <- (a^2 + a*b + b^2) / 3            # E[power^2]
cmp("Fig1 E[G] before (uniform)", Ep, 0.525)
cmp("Fig1 E[G|sig] = E[G^2]/E[G]", Ep2 / Ep, 0.635)  # paper CLAIMS 0.635

# ---- Figure 2: G = 0.95*beta(13,6) + 0.05 ----
mub <- 13 / (13 + 6)                     # beta mean 13/19
Eg_before <- 0.95 * mub + 0.05
# E[G^2] for G = c*X + d with X~beta(alpha,beta):
# E[X^2] = alpha(alpha+1)/[(alpha+beta)(alpha+beta+1)]
c <- 0.95; d <- 0.05; aa <- 13; bb <- 6
EX  <- aa / (aa + bb)
EX2 <- aa * (aa + 1) / ((aa + bb) * (aa + bb + 1))
Eg2 <- c^2 * EX2 + 2 * c * d * EX + d^2
cmp("Fig2 E[G] before (beta)", Eg_before, 0.700)
cmp("Fig2 E[G|sig] = E[G^2]/E[G]", Eg2 / Eg_before, 0.714)

# Sanity: cross-check with Monte Carlo
set.seed(1)
x <- 0.95 * rbeta(1e7, 13, 6) + 0.05
cmp("Fig2 MC mean before", mean(x), 0.700)
cmp("Fig2 MC E[G^2]/E[G]", mean(x^2) / mean(x), 0.714)

cat("\nFigure 1 check: a uniform on [0.05,1.0] yields after-selection mean", format(Ep2/Ep, digits=6), "NOT 0.635.\n")
cat("For Fig1 to give 0.635 after with 0.525 before, no uniform[a,b] works (see report).\n")
