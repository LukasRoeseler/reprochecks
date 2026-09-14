## ReproAI RE-AUDIT — rANOVA & rANOVA-HF Type I error.
## Usage: Rscript ranova_sim.R <S> <seed> <outfile>
suppressMessages({library(MASS); source("sim_funcs.R")})
args <- commandArgs(trailingOnly = TRUE)
S <- as.integer(args[1]); seed <- as.integer(args[2]); out <- args[3]
set.seed(seed)
res <- list(); cond <- 0
for (m in c(9, 12)) for (sp in c("hold", "violation")) {
  Sigma <- gen_cov(m, sp)
  for (n in c(15, 20, 25, 30)) {
    cond <- cond + 1
    pa <- numeric(S); phf <- numeric(S)
    for (s in 1:S) {
      Y <- draw_sample(n, m, sp, Sigma)
      r <- ranova_ps(Y); pa[s] <- r$rANOVA_p; phf[s] <- r$rANOVA_HF_p
    }
    res[[cond]] <- data.frame(m=m, sphericity=sp, n=n, S=S,
                              rANOVA=typeI(pa), rANOVA_HF=typeI(phf))
  }
}
outdf <- do.call(rbind, res)
write.csv(outdf, out, row.names = FALSE)
cat(sprintf("== rANOVA S=%d seed=%d done ==\n", S, seed))
print(outdf)
