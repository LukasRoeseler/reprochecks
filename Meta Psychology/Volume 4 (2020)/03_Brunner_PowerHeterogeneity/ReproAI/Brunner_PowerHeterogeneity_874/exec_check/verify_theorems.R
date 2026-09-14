# ReproAI re-audit: Brunner & Schimmack (2020) MP.2018.874
# Verify Theorems 1-5 with the EXACT deterministic numerical example from the
# paper's appendix (set.seed(9999), million draws, F(3,26) with ncp~chisq(14.36826)).
# This is a fully deterministic check: values should match the paper to printed precision.

outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output"
results <- character()

add <- function(s) results <<- c(results, s)
cmp <- function(label, computed, paper) {
  d <- abs(computed - paper)
  flag <- if (d < 1e-4) "MATCH" else if (d < 1e-3) "CLOSE" else "DIFF"
  line <- sprintf("%-55s computed=%.7f paper=%.6f delta=%.2e -> %s", label, computed, paper, d, flag)
  add(line)
  cat(line, "\n")
}

alpha  <- 0.05
criticalvalue <- qf(1 - alpha, 3, 26)

# Locate df that gives E(power)=0.80 (paper uses uniroot minimizing |integrate - 0.8|)
fun <- function(ncp, DF) (1 - pf(criticalvalue, df1 = 3, df2 = 26, ncp)) * dchisq(ncp, DF)
int_at <- function(DF) integrate(fun, 0, Inf, DF = DF)$value
findDF <- uniroot(function(DF) int_at(DF) - 0.8, c(1, 60))$root
add(sprintf("Located df (should be ~14.36826): %.5f", findDF))
cmp("integrate(fun,0,Inf,DF=14.36826)=0.80", int_at(14.36826), 0.8000001)

# One-million-draw simulation (paper's exact appendix code)
popsize <- 1000000
set.seed(9999)
NCP       <- rchisq(popsize, df = findDF)
Power     <- 1 - pf(criticalvalue, df1 = 3, df2 = 26, NCP)
cmp("mean(Power) [E(G) before selection]", mean(Power), 0.8002137)

Fstat     <- rf(popsize, df1 = 3, df2 = 26, NCP)
sigF      <- subset(Fstat, Fstat > criticalvalue)
cmp("length(sigF)/popsize [P(significant)=E(G)]", length(sigF) / popsize, 0.800177)

SigPower  <- subset(Power, Fstat > criticalvalue)
cmp("mean(SigPower) [E(G|sig) after selection]", mean(SigPower), 0.8274357)

sigNCP    <- subset(NCP, Fstat > criticalvalue)
Fstat2    <- rf(length(sigF), df1 = 3, df2 = 26, ncp = sigNCP)
cmp("replication success proportion (Theorem 1 after selection)", length(subset(Fstat2, Fstat2 > criticalvalue)) / length(sigF), 0.827172)

cmp("1/mean(1/SigPower) [Theorem 4: E(G) from reciprocal]", 1 / mean(1 / SigPower), 0.8000502)
cmp("mean(Power^2)/mean(Power) [Theorem 3: E(G|sig)]", mean(Power^2) / mean(Power), 0.8275373)
cmp("mean(SigPower) - mean(Power) [Theorem 5 numerator]", mean(SigPower) - mean(Power), 0.02722205)
cmp("var(Power)/mean(Power) [Theorem 5: Var/E]", var(Power) / mean(Power), 0.02732371)

dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
writeLines(results, file.path(outdir, "theorems_check.txt"))
cat("\nWrote theorems_check.txt\n")
