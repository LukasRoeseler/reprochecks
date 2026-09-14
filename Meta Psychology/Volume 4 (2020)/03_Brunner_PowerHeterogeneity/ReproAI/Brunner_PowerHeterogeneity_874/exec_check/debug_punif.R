source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/extracted/supp/estimatR_raw.txt")
set.seed(42)
d1 = 1; d2 = 84; alpha = 0.05
crit = qf(1-alpha, d1, d2)
ncp = 3.9305
FF = rsigF(100, d1, d2, ncp)

# Manually compute p-uniform
k = length(FF)
loss = function(es0) {
    lognewpp = pf(FF, df1=d1, df2=d2, ncp=(d1+d2+1)*es0, log.p=T) - 
               pf(crit, df1=d1, df2=d2, ncp=(d1+d2+1)*es0, lower.tail=F, log.p=T)
    Ygam = -sum(lognewpp)
    (Ygam - k)^2
}

# Try several es0 values
for (es0 in c(0.001, 0.01, 0.05, 0.1, 0.2, 0.5, 0.9)) {
    cat(sprintf("es0=%.3f: loss=%.4f, Ygam=%.2f\n", es0, loss(es0), -sum(pf(FF, d1, d2, ncp=(d1+d2+1)*es0, log.p=T) - pf(crit, d1, d2, ncp=(d1+d2+1)*es0, lower.tail=F, log.p=T))))
}

# Find minimum
res = optimize(loss, interval=c(0, 1))
cat("Optimal es0:", res$minimum, "\n")
# Power at this es0
PowerEst = mean(1 - pf(crit, d1, d2, ncp=(d1+d2+1)*res$minimum))
cat("Power estimate:", PowerEst, "\n")