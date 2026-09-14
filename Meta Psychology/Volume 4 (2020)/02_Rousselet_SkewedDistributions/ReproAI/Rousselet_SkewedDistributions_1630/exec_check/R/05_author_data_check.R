# ReproAI :: compare author's committed data to paper Table 1/2 and to our reimplementation
myrexgauss <- function(n, mu, sigma, tau) rnorm(n, mu, sigma) + rexp(n, rate = 1 / tau)
param <- rbind(c(300,20,300),c(300,50,300),c(350,20,250),c(350,50,250),c(400,20,200),
               c(400,50,200),c(450,20,150),c(450,50,150),c(500,20,100),c(500,50,100),
               c(550,20,50),c(550,50,50))
nvec <- c(4,6,8,10,15,20,25,35,50,100); nP <- 12
tab1_median <- c(509,512,524,528,540,544,555,562,572,579,588,594)
tab1_skew   <- c(92,88,76,72,60,55,45,38,29,21,12,6)
tab2 <- rbind(c(41,26,19,18,8,8,6,4,3,1),c(39,27,21,16,10,7,5,5,3,2),c(35,23,16,12,8,7,5,4,3,1),
              c(35,24,16,14,8,6,5,4,3,2),c(28,18,15,9,6,6,4,3,2,1),c(26,18,12,9,7,5,4,3,2,1),
              c(21,14,10,9,5,4,3,2,2,1),c(18,11,8,7,5,3,3,1,1,1),c(13,10,6,5,3,2,2,1,1,0),
              c(9,6,4,4,2,2,1,1,1,0),c(5,4,3,2,1,1,1,1,0,0),c(2,2,1,0,1,0,0,0,0,0))
datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"

# ---- author's committed population params ----
load(file.path(datadir, "miller_exg_param.RData"))  # miller.param, pop.m, pop.md, pop.sk
cat("Author pop.m (rounded):", round(pop.m), "\n")
cat("Author pop.md (rounded):", round(pop.md), "paper median:", tab1_median, "\n")
cat("Author mean-median (rounded):", round(pop.m - pop.md), "paper skew:", tab1_skew, "\n")
cat("Author median == paper median (12):", sum(round(pop.md) == tab1_median), "\n")

# ---- author's committed simulation ----
load(file.path(datadir, "sim_miller1988.RData"))  # sim.m, sim.md, sim.md.bc, bias etc, nvec, nsim, nboot
author_bias.md <- apply(sim.md, c(2,3), mean) - matrix(rep(pop.md, length(nvec)), nrow=nP)
author_tab2 <- round(author_bias.md)
cat("\nAuthor committed Table 2 (rounded):\n")
print(author_tab2)
cat("Author committed Table2 == paper (cell-level):", sum(author_tab2 == tab2), "of 120\n")
cat("Author committed Table2 == paper (row-level all):", sum(apply(author_tab2 == tab2, 1, all)), "of 12\n")

# ---- our fresh reimplementation (same seeds as author: set.seed(21)) ----
set.seed(21)
sim.md.mine <- array(NA, dim=c(10000, nP, length(nvec)))
for (P in 1:nP) {
  mu<-param[P,1]; s<-param[P,2]; t<-param[P,3]
  max.data <- matrix(myrexgauss(100*10000, mu, s, t), nrow=10000)
  for (j in 1:length(nvec)) sim.md.mine[,P,j] <- apply(max.data[,1:nvec[j]], 1, median)
}
# compare OUR sim.md directly to AUTHOR sim.md (byte-level)
same <- sim.md.mine == sim.md
cat("\nOUR rexgauss sim.md vs AUTHOR committed sim.md:\n")
cat("  identical cells:", sum(same), "of", length(same), "\n")
cat("  identical proportion:", round(sum(same)/length(same), 6), "\n")
# our population params (seed 4)
set.seed(4)
pop.md.mine <- numeric(nP); pop.m.mine <- numeric(nP)
for (P in 1:nP) { pv <- myrexgauss(1e6, param[P,1],param[P,2],param[P,3]); pop.m.mine[P]<-mean(pv); pop.md.mine[P]<-sort(pv)[round(length(pv)*0.5)] }
cat("\nOUR pop.md vs AUTHOR pop.md (max abs diff):", max(abs(pop.md.mine - pop.md)), "\n")
cat("OUR pop.m vs AUTHOR pop.m (max abs diff):", max(abs(pop.m.mine - pop.m)), "\n")

# our bias table using AUTHOR population values, compare both to paper & author
our_bias.md <- apply(sim.md.mine, c(2,3), mean) - matrix(rep(pop.md.mine, length(nvec)), nrow=nP)
our_tab2 <- round(our_bias.md)
cat("\nOUR fresh Table2 == paper:", sum(our_tab2 == tab2), "of 120\n")
cat("OUR fresh Table2 == author committed:", sum(our_tab2 == author_tab2), "of 120\n")
cat("OUR sim.md vs author sim.md: mean abs diff", round(mean(abs(sim.md.mine - sim.md)), 5), "max abs diff", round(max(abs(sim.md.mine - sim.md)), 5), "\n")
