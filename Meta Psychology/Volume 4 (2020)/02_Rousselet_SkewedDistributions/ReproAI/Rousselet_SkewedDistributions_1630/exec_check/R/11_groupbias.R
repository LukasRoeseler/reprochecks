datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"
load(file.path(datadir, "bias_diff_size.RData"))
cat("nvec[1]:", nvec[1], "\n")
cat("median max bias n=10 (bc_gp) [paper 1.79]:", round(max(diff.md.bc_gp[,1]),2), "\n")
cat("mean  max bias n=10 [paper 0.88]:", round(max(diff.m.m_bias[,1]),2), "\n")
cat("dims diff.md.bc_gp:", dim(diff.md.bc_gp), "\n")
cat("max abs median bias (mean-based) at n=10 all dists:", round(max(abs(diff.md.bc_gp[,1])),3), "\n")
cat("max abs mean bias at n=10 all dists:", round(max(abs(diff.m.m_bias[,1])),3), "\n")
