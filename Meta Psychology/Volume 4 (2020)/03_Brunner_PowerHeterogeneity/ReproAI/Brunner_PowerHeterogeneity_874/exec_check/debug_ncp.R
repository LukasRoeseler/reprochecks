source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/extracted/supp/estimatR_raw.txt")
set.seed(42)
d1 = 1; d2 = 84; alpha = 0.05
crit = qf(1-alpha, d1, d2)
cat("Critical value:", crit, "\n")

# For each target power, check NCP
for (tp in c(0.25, 0.50, 0.75)) {
    ncp = uniroot(function(ncp) pf(crit, d1, d2, ncp) - (1-tp), c(0, 200))$root
    # Verify: power = 1 - pf(crit, d1, d2, ncp)
    pw = 1 - pf(crit, d1, d2, ncp)
    cat(sprintf("Target=%.2f: NCP=%.4f, actual power=%.4f\n", tp, ncp, pw))
}

# Check a single FF sample
ncp = uniroot(function(ncp) pf(crit, d1, d2, ncp) - 0.50, c(0, 200))$root
FF = rsigF(10, d1, d2, ncp)
cat("Sample FF:", FF, "\n")
cat("Min FF:", min(FF), "Crit:", crit, "\n")
cat("All > crit:", all(FF > crit), "\n")