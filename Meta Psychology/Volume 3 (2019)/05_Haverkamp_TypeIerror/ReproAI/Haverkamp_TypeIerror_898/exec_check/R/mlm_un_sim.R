## ReproAI RE-AUDIT — MLM-UN Type I error (nlme::gls corSymm, REML). SLOW.
## Usage: Rscript mlm_un_sim.R <m> <sp> <n> <S> <seed> <outfile>
suppressMessages({library(MASS); library(nlme); source("sim_funcs.R")})
args <- commandArgs(trailingOnly = TRUE)
m <- as.integer(args[1]); sp <- args[2]; n <- as.integer(args[3])
S <- as.integer(args[4]); seed <- as.integer(args[5]); out <- args[6]
set.seed(seed)
Sigma <- gen_cov(m, sp)
p <- numeric(S); nfail <- 0; t0 <- proc.time()
for (s in 1:S) {
  Y <- draw_sample(n, m, sp, Sigma)
  p[s] <- tryCatch(mlm_un_p(Y), error = function(e) { nfail <<- nfail + 1; NA })
}
el <- (proc.time() - t0)[["elapsed"]]
outdf <- data.frame(m=m, sphericity=sp, n=n, S=S, MLM_UN=typeI(p), fail=nfail, elapsed_s=round(el,1))
write.csv(outdf, out, row.names = FALSE)
cat(sprintf("== MLM-UN m=%d sp=%s n=%d S=%d done (%.1fs) ==\n", m, sp, n, S, el))
print(outdf)
