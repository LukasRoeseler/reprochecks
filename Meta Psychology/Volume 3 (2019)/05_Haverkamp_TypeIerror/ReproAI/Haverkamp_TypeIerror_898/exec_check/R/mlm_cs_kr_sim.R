## ReproAI RE-AUDIT — MLM-CS & MLM-KR(Type I error, random-intercept lmer).
## Usage: Rscript mlm_cs_kr_sim.R <S> <seed> <outfile>
suppressMessages({library(MASS); library(lmerTest); source("sim_funcs.R")})
args <- commandArgs(trailingOnly = TRUE)
S <- as.integer(args[1]); seed <- as.integer(args[2]); out <- args[3]
set.seed(seed)
cond_list <- list(
  list(m=9,  sp="hold",      n=15), list(m=9,  sp="hold",      n=30),
  list(m=12, sp="hold",      n=15), list(m=12, sp="hold",      n=30),
  list(m=9,  sp="violation", n=15), list(m=9,  sp="violation", n=30),
  list(m=12, sp="violation", n=15), list(m=12, sp="violation", n=30))
res <- list()
for (ci in seq_along(cond_list)) {
  cc <- cond_list[[ci]]; m <- cc$m; sp <- cc$sp; n <- cc$n
  Sigma <- gen_cov(m, sp)
  pcs <- pkr <- numeric(S); nf_cs <- nf_kr <- 0
  for (s in 1:S) {
    Y <- draw_sample(n, m, sp, Sigma)
    pcs[s] <- tryCatch(mlm_cs_p(Y), error=function(e){nf_cs<<-nf_cs+1; NA})
    pkr[s] <- tryCatch(mlm_kr_p(Y), error=function(e){nf_kr<<-nf_kr+1; NA})
  }
  res[[ci]] <- data.frame(m=m, sphericity=sp, n=n, S=S,
                          MLM_CS=typeI(pcs), MLM_KR=typeI(pkr),
                          fail_CS=nf_cs, fail_KR=nf_kr)
}
outdf <- do.call(rbind, res)
write.csv(outdf, out, row.names = FALSE)
cat(sprintf("== MLM CS/KR S=%d seed=%d done ==\n", S, seed))
print(outdf)
