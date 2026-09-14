datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"
load(file.path(datadir, "miller_exg_param.RData"))
load(file.path(datadir, "sim_miller1988.RData"))
nvec <- c(4,6,8,10,15,20,25,35,50,100); nP <- 12
tab2 <- rbind(c(41,26,19,18,8,8,6,4,3,1),c(39,27,21,16,10,7,5,5,3,2),c(35,23,16,12,8,7,5,4,3,1),
              c(35,24,16,14,8,6,5,4,3,2),c(28,18,15,9,6,6,4,3,2,1),c(26,18,12,9,7,5,4,3,2,1),
              c(21,14,10,9,5,4,3,2,2,1),c(18,11,8,7,5,3,3,1,1,1),c(13,10,6,5,3,2,2,1,1,0),
              c(9,6,4,4,2,2,1,1,1,0),c(5,4,3,2,1,1,1,1,0,0),c(2,2,1,0,1,0,0,0,0,0))
author_bias.md <- apply(sim.md, c(2,3), mean) - matrix(rep(pop.md, length(nvec)), nrow=nP)
auth <- round(author_bias.md)
dev <- as.vector(auth - tab2)
cat("Committed-data Table2 vs Paper Table2:\n")
cat("  exact cells:", sum(dev==0), "/120\n")
cat("  within +-1:", sum(abs(dev)<=1), " +-2:", sum(abs(dev)<=2), "\n")
cat("  max abs dev:", max(abs(dev)), "\n")
cat("  dev distribution:\n"); print(table(dev))
# Is printout the true value, not rounded? show raw bias for a few cells
cat("\nAuthor committed raw bias (sk 92 row):", round(author_bias.md[1,],1), "\n")
cat("Paper Table2 sk92 row: 41 26 19 18 8 8 6 4 3 1\n")
cat("\nAuthor committed raw bias (sk 12, n=10):", author_bias.md[11,4], "\n")
cat("\nAlso compute bias using author's pop.md but the committed sim gives these decimals:\n")
print(round(author_bias.md,1))
