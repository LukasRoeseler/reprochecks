source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/extracted/supp/estimatR_raw.txt")
set.seed(42)
d1 = 1; d2 = 84; alpha = 0.05
crit = qf(1-alpha, d1, d2)
tp = 0.50
ncp = uniroot(function(ncp) pf(crit, d1, d2, ncp) - (1-tp), c(0, 200))$root
k = 100; nsims = 200
punif_ests = numeric(nsims)
pcurve_ests = numeric(nsims)
mle_ests = numeric(nsims)
for (s in 1:nsims) {
    FF = rsigF(k, d1, d2, ncp)
    punif_ests[s] = heteroNpunifF(FF, d1, d2, CI=F)
    pcurve_ests[s] = heteroNpcurveF(FF, d1, d2)
    mle_ests[s] = heteroNmleF(FF, d1, d2, CI=F, warn=F)
}
cat(sprintf("P-uniform  mean: %.3f (paper=0.496)\n", mean(punif_ests)))
cat(sprintf("P-curve 2.1 mean: %.3f (paper=0.497)\n", mean(pcurve_ests)))
cat(sprintf("ML-model  mean: %.3f (paper=0.497)\n", mean(mle_ests)))