# ReproAI re-audit (2026-09-14) -- Brunner & Schimmack (2020) MP.2018.874
# Verify the analytic/theorem claims: Figure 1 (uniform[0.05,1]), Figure 2 (beta(13,6)*0.95+0.05),
# and the paper's deterministic appendix numerical example (F(3,26), ncp~chisq(14.36826), seed 9999).
# All checks are closed-form or deterministic (fixed seed) -> fully reproducible.

outdir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output"
res <- character()
add <- function(s) { res <<- c(res, s); cat(s, "\n") }

cmp <- function(label, computed, paper) {
  d <- abs(computed - paper)
  flag <- if (d < 1e-4) "MATCH" else if (d < 1e-3) "CLOSE" else "DIFF"
  add(sprintf("%-58s computed=%.7f paper=%.6f delta=%.2e  -> %s", label, computed, paper, d, flag))
}

# ---------- Figure 1: Uniform[0.05, 1.0] ----------
# Before selection: E[p] = (a+b)/2. After selection (Theorem 2): density ~ p => E[p|sig]=E[p^2]/E[p].
a <- 0.05; b <- 1.0
before <- (a + b) / 2
after  <- ((b^3 - a^3) / 3) / ((b^2 - a^2) / 2)
add("-------------------- Figure 1 (Uniform[0.05,1]) --------------------")
cmp("E[p] before selection (paper 0.525)", before, 0.525)
cmp("E[p|sig] after selection   (paper 0.635)", after, 0.635)   # computed 0.6683 -> DISCREPANCY

# ---------- Figure 2: beta(13,6)*0.95 + 0.05 ----------
# Before: E[p] = 0.95*E[b] + 0.05. After: E[p^2]/E[p] via numeric integration over beta.
eb  <- 13/19
eb2 <- 13*6/((13+6)^2*(13+6+1)) + (13/19)^2
before2 <- 0.95*eb + 0.05
E2 <- 0.95^2*eb2 + 2*0.95*0.05*eb + 0.05^2
after2 <- E2 / before2
# cross-check by numeric integration
fint <- function(x) { p <- 0.95*dbeta(x,13,6)*0 + (0.95*x + 0.05); p }
# exact: E[p] and E[p^2]
add("-------------------- Figure 2 (beta(13,6)*0.95+0.05) --------------------")
cmp("E[p] before selection (paper 0.700)", before2, 0.700)
cmp("E[p|sig] after selection (paper 0.714)", after2, 0.714)

# ---------- Appendix deterministic numerical example (F(3,26), ncp~chisq(df), E[pow]=0.80) ----------
alpha <- 0.05
crit  <- qf(1 - alpha, 3, 26)
fun   <- function(ncp, DF) (1 - pf(crit, 3, 26, ncp)) * dchisq(ncp, DF)
int_at <- function(DF) integrate(fun, 0, Inf, DF = DF)$value
findDF <- uniroot(function(DF) int_at(DF) - 0.8, c(1, 60))$root
add("-------------------- Appendix example (R code from paper, seed 9999) --------------------")
cmp("located df (paper 14.36826)", findDF, 14.36826)
cmp("integrate(fun,DF=14.36826) (paper 0.8000001)", int_at(14.36826), 0.8000001)

popsize <- 1000000
set.seed(9999)
NCP   <- rchisq(popsize, df = findDF)
Power <- 1 - pf(crit, 3, 26, NCP)
cmp("mean(Power) (paper 0.8002137)", mean(Power), 0.8002137)
Fstat <- rf(popsize, 3, 26, NCP)
sigF  <- Fstat[Fstat > crit]
cmp("length(sigF)/popsize (paper 0.800177)", length(sigF)/popsize, 0.800177)
SigPower <- Power[Fstat > crit]
cmp("mean(SigPower) (paper 0.8274357)", mean(SigPower), 0.8274357)
sigNCP <- NCP[Fstat > crit]
Fstat2 <- rf(length(sigF), 3, 26, ncp = sigNCP)
cmp("replication success rate (paper 0.827172)", length(Fstat2[Fstat2 > crit])/length(sigF), 0.827172)
cmp("1/mean(1/SigPower) Thm4 (paper 0.8000502)", 1/mean(1/SigPower), 0.8000502)
cmp("mean(Power^2)/mean(Power) Thm3 (paper 0.8275373)", mean(Power^2)/mean(Power), 0.8275373)
cmp("mean(SigPower)-mean(Power) Thm5 (paper 0.02722205)", mean(SigPower)-mean(Power), 0.02722205)
cmp("var(Power)/mean(Power) Thm5 (paper 0.02732371)", var(Power)/mean(Power), 0.02732371)

dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
writeLines(res, file.path(outdir, "reaudit_theorems.txt"))
cat("\nWrote reaudit_theorems.txt\n")
