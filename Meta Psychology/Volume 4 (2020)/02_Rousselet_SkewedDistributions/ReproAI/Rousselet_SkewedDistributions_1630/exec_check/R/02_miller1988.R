# ReproAI :: Rousselet & Wilcox (2020) MP.2019.1630
# Reimplementation of Table 1 (population parameters) and Table 2 (median mean bias)
# from the miller1988 notebook. rexgauss reimplemented (retimes not installed):
#   exact RNG order used by retimes::rexgauss = rnorm(n,mu,sigma) then rexp(n,rate=1/tau)
myrexgauss <- function(n, mu, sigma, tau) rnorm(n, mu, sigma) + rexp(n, rate = 1 / tau)

param <- rbind(
  c(300,20,300), c(300,50,300), c(350,20,250), c(350,50,250),
  c(400,20,200), c(400,50,200), c(450,20,150), c(450,50,150),
  c(500,20,100), c(500,50,100), c(550,20,50),  c(550,50,50))

# Manuscript Table 1 & Table 2 values (paper)
tab1_median <- c(509,512,524,528,540,544,555,562,572,579,588,594)
tab1_skew   <- c(92,88,76,72,60,55,45,38,29,21,12,6)
tab2 <- rbind(
  c(41,26,19,18, 8, 8, 6, 4, 3,1),  # sk 92
  c(39,27,21,16,10, 7, 5, 5, 3,2),  # sk 88
  c(35,23,16,12, 8, 7, 5, 4, 3,1),  # sk 76
  c(35,24,16,14, 8, 6, 5, 4, 3,2),  # sk 72
  c(28,18,15, 9, 6, 6, 4, 3, 2,1),  # sk 60
  c(26,18,12, 9, 7, 5, 4, 3, 2,1),  # sk 55
  c(21,14,10, 9, 5, 4, 3, 2, 2,1),  # sk 45
  c(18,11, 8, 7, 5, 3, 3, 1, 1,1),  # sk 38
  c(13,10, 6, 5, 3, 2, 2, 1, 1,0),  # sk 29
  c( 9, 6, 4, 4, 2, 2, 1, 1, 1,0),  # sk 21
  c( 5, 4, 3, 2, 1, 1, 1, 1, 0,0),  # sk 12
  c( 2, 2, 1, 0, 1, 0, 0, 0, 0,0))  # sk 6
# rows = distributions (1=most skewed), cols = sample sizes n=4..100

nvec <- c(4, 6, 8, 10, 15, 20, 25, 35, 50, 100)
nP <- 12; maxn <- 100; nsim <- 10000

outdir <- "../output"
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
log <- c()
log <- c(log, "== Table 1: population parameters (seed 4, n=1,000,000) ==")
set.seed(4)
pop.m <- pop.md <- numeric(nP)
for (P in 1:nP) {
  popv <- myrexgauss(1e6, param[P,1], param[P,2], param[P,3])
  pop.m[P]  <- mean(popv)
  pop.md[P] <- sort(popv)[round(length(popv) * 0.5)]
}
tab1_median_rep <- round(pop.md)
tab1_skew_rep   <- round(pop.m - pop.md)
t1 <- data.frame(mu=param[,1], sigma=param[,2], tau=param[,3],
                 mean=round(pop.m), median_ms=tab1_median_rep, median_paper=tab1_median,
                 skew_rep=tab1_skew_rep, skew_paper=tab1_skew,
                 median_match=tab1_median_rep==tab1_median, skew_match=tab1_skew_rep==tab1_skew)
write.csv(t1, file.path(outdir, "table1_population_repl.csv"), row.names=FALSE)
print(t1)
log <- c(log, "median matches paper:", sum(t1$median_match), "of 12",
         "skewness matches paper:", sum(t1$skew_match), "of 12")

log <- c(log, "== Table 2: median mean bias (seed 21, 10,000 sims) ==")
set.seed(21)
bias.md <- matrix(NA, nP, length(nvec))
sim.m  <- array(NA, dim = c(nsim, nP, length(nvec)))
sim.md <- array(NA, dim = c(nsim, nP, length(nvec)))
for (P in 1:nP) {
  mu <- param[P,1]; sigma <- param[P,2]; tau <- param[P,3]
  max.data <- matrix(myrexgauss(maxn*nsim, mu, sigma, tau), nrow = nsim)
  for (j in 1:length(nvec)) {
    mc <- max.data[, 1:nvec[j]]
    sim.m[,P,j]  <- apply(mc, 1, mean)
    sim.md[,P,j] <- apply(mc, 1, median)
  }
}
for (j in 1:length(nvec)) bias.md[,j] <- apply(sim.md[,,j], 2, mean) - pop.md
tab2_rep <- round(bias.md)
t2 <- data.frame(skewness=round(pop.m-pop.md), round(tab2_rep))
colnames(t2) <- c("skewness", paste0("n", nvec))
t2$matches <- apply(tab2_rep == tab2, 1, all)
write.csv(t2, file.path(outdir, "table2_bias_repl.csv"), row.names=FALSE)
print(t2)
log <- c(log, "Table 2 rows fully matching paper (all 10 sizes):", sum(t2$matches), "of 12")
diff_cells <- sum(tab2_rep == tab2)
log <- c(log, "Table 2 cell-level matches:", diff_cells, "of 120")
maxdev <- max(abs(tab2_rep - tab2))
log <- c(log, "Table 2 max integer deviation:", maxdev)

# Compute mean mean-bias & median median-bias summaries (Figure 3D/E) for reporting
bias.m     <- apply(sim.m, c(2,3), mean) - matrix(rep(pop.m, length(nvec)), nrow=nP)
bias.m.md  <- apply(sim.m, c(2,3), median) - matrix(rep(pop.m, length(nvec)), nrow=nP)
bias.md.md <- apply(sim.md,c(2,3), median) - matrix(rep(pop.md,length(nvec)), nrow=nP)
write.csv(round(bias.m,2), file.path(outdir, "bias_mean_mean.csv"), row.names=FALSE)
write.csv(round(bias.m.md,2), file.path(outdir, "bias_mean_median.csv"), row.names=FALSE)
write.csv(round(bias.md.md,2), file.path(outdir, "bias_median_median.csv"), row.names=FALSE)

log <- c(log, "Figure 3A expectation (mean mean-bias ~ 0); max abs across all 120:",
         round(max(abs(bias.m)), 3))
writeLines(log, file.path(outdir, "miller1988_repl.log"))
cat("DONE miller1988 repl\n")
