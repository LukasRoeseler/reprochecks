# Bartos & Maier (2022) FDR reproduction
# FDR = P(H0)*alpha / (P(H0)*alpha + P(H1)*power)   [Eq 1]

fdr <- function(p0, alpha, power) {
  p0*alpha / (p0*alpha + (1-p0)*power)
}

# Running example: P(H0)=0.80 (P(H1)=0.20), alpha=0.05, power=0.19
p0 <- 0.80; alpha <- 0.05; power <- 0.19
fp <- p0*alpha              # false positives = 4%
tp <- (1-p0)*power          # true positives = 3.8%
cat("False positives:", fp, " True positives:", tp, "\n")
cat("FDR = ", fp, "/(", fp, "+", tp, ") = ", fdr(p0, alpha, power), "\n\n")

# Central claim: reducing alpha is more efficient than increasing power
base <- fdr(p0, 0.05, 0.19)
cat("Baseline FDR (alpha=.05, power=.19):", round(base*100,1), "%\n")

# Option 1: decrease alpha to .01 (power fixed at .19)
opt1 <- fdr(p0, 0.01, 0.19)
cat("Decrease alpha to .01 (power=.19): FDR =", round(opt1*100,1), "%\n")

# Option 2: increase power to .80 (alpha fixed at .05)
opt2 <- fdr(p0, 0.05, 0.80)
cat("Increase power to .80 (alpha=.05): FDR =", round(opt2*100,1), "%\n")

cat("\nVerdict: decreasing alpha (", round(opt1*100,1), "%) more efficient than increasing power (",
    round(opt2*100,1), "%)? ", opt1 < opt2, "\n", sep="")
