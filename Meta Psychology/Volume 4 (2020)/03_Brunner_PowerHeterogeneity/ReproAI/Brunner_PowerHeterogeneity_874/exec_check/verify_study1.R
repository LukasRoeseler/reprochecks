source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/extracted/supp/estimatR_raw.txt")
set.seed(12345)
target_power = 0.50
d1 = 1; d2 = 84; alpha = 0.05
crit = qf(1-alpha, d1, d2)
ncp_target = uniroot(function(ncp) pf(crit, d1, d2, ncp) - (1-target_power), c(0, 100))$root
cat("NCP for power=0.50:", ncp_target, "\n")
k = 100; nsims = 200
zcurve_estimates = numeric(nsims)
for (s in 1:nsims) {
    FF = rsigF(k, d1, d2, ncp_target)
    pv = pf(FF, d1, d2, lower.tail=FALSE)
    est = zcurve(pv, Plot=0, Verbose=FALSE)
    zcurve_estimates[s] = est
}
cat("Z-curve mean (200 sims):", mean(zcurve_estimates), "\n")
cat("Paper value: 0.508\n")