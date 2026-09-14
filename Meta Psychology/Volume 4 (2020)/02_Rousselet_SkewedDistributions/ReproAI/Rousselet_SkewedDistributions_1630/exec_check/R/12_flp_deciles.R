# ReproAI :: verify FLP decile claims (Figure 23) directly from raw data
datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"
load(file.path(datadir, "french_lexicon_project_rt_data.RData"))
p.list <- unique(flp$participant); nP <- length(p.list)
dec <- c(1:9)/10
QS <- function(p, x) quantile(x, probs=p, type=8)  # algorithm 8 Hyndman & Fan
diffmat <- matrix(NA, nP, 9)  # non-word - word decile differences
for (P in 1:nP) {
  w  <- flp$rt[flp$participant==p.list[P] & flp$condition=="word"]
  nw <- flp$rt[flp$participant==p.list[P] & flp$condition=="non-word"]
  diffmat[P,] <- QS(dec, nw) - QS(dec, w)
}
# every decile positive / negative
allpos <- apply(diffmat, 1, function(r) all(r>0))
allneg <- apply(diffmat, 1, function(r) all(r<0))
cat("Proportion all 9 deciles positive (paper 83.2%):", round(100*mean(allpos),1), "%\n")
cat("Proportion all 9 deciles negative (paper 1.4%):", round(100*mean(allneg),1), "%\n")
# 20% trimmed mean across participants per decile
tmean20 <- function(x) mean(sort(x)[(0.2*length(x)+1):(0.8*length(x))])
ctm <- apply(diffmat, 2, tmean20)
cat("20% trimmed mean across participants per decile (paper 59 66 72 77 82 86 89 91 89):\n")
cat("  ", paste(round(ctm), collapse=" "), "\n")
# Spearman monotonic increase / decrease across deciles per participant (alpha .05)
inc <- decr <- 0; Nsig<-0
for (P in 1:nP) {
  rho <- cor(1:9, diffmat[P,], method="spearman")
  # p-value of Spearman rho on 9 points
  stat <- rho*sqrt(7/(1-rho^2)); pv <- 2*pt(-abs(stat), df=7)
  if (pv<0.05) { Nsig<-Nsig+1; if (rho>0) inc<-inc+1 else decr<-decr+1 }
}
cat("Proportion monotonic increase across deciles (paper 52.9%):", round(100*inc/nP,1), "%\n")
cat("Proportion monotonic decrease (paper 14.9%):", round(100*decr/nP,1), "%\n")
cat("(fraction of participants with any significant Spearman trend):", round(100*Nsig/nP,1), "%\n")
