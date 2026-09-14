source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/extracted/supp/estimatR_raw.txt")
set.seed(42)
d1 = 1; d2 = 84; alpha = 0.05
crit = qf(1-alpha, d1, d2)

# Paper Table 1 values (z-curve column, k=100)
paper_vals = c(
  "power=0.25" = 0.280,
  "power=0.50" = 0.508,
  "power=0.75" = 0.723
)

nsims = 200
for (tp in c(0.25, 0.50, 0.75)) {
    ncp = uniroot(function(ncp) pf(crit, d1, d2, ncp) - (1-tp), c(0, 200))$root
    k = 100
    ests = numeric(nsims)
    for (s in 1:nsims) {
        FF = rsigF(k, d1, d2, ncp)
        pv = pf(FF, d1, d2, lower.tail=FALSE)
        ests[s] = zcurve(pv, Plot=0, Verbose=FALSE)
    }
    est_mean = mean(ests)
    paper = paper_vals[paste0("power=",tp)]
    cat(sprintf("True power=%.2f, k=100: z-curve=%.3f (paper=%.3f), diff=%.3f\n", tp, est_mean, paper, abs(est_mean-paper)))
}