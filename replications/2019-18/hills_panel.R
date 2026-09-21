# Reproduction of Hills et al. 2019 (NHB 2019-18) main panel models
# Source: Nature_final.do (Stata) translated to R; data nature_valence.dta
#   (github.com/warwickpsych/NationalValenceIndex)
options(warn=-1)
f <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/downloads/github/warwickpsych__NationalValenceIndex/TableFigure_Nature_onGithub/nature_valence.dta"
d <- if (requireNamespace("haven", quietly=TRUE)) haven::read_dta(f) else foreign::read.dta(f)
library(plm)

# ---- Table 1: NVI predicts aggregate life satisfaction (Germany/Italy/UK, 1973-2009) ----
sub <- d[d$C %in% c(1,4,5) & !is.na(d$satislfe) & !is.na(d$valence) & !is.na(d$lgdp) & !is.na(d$year),]
sub$C <- as.factor(sub$C); p <- pdata.frame(sub, index=c("C","year")); G <- length(unique(sub$C))
cat("=== Table 1 sample: N=", nrow(sub), " countries=", paste(sort(unique(sub$C)),collapse=","), " ===\n")
m1 <- plm(satislfe ~ valence + lgdp + factor(year), data=p, model="within")
b1 <- coef(m1)["valence"]; se1 <- sqrt(plm::vcovHC(m1, method="arellano", type="HC1", cluster="group")["valence","valence"])*sqrt(G/(G-1))
cat(sprintf("Model1 (Year FE):      b=%.4f  se=%.4f  t=%.4f  within-r2=%.4f  N=%d  (paper 2.8551/.2867/.730/104)\n", b1, se1, b1/se1, summary(m1)$r.squared[["rsq"]], length(m1$residuals)))
m2 <- plm(satislfe ~ valence + lgdp + italy_year + germany_year + uk_year, data=p, model="within")
b2 <- coef(m2)["valence"]; se2 <- sqrt(plm::vcovHC(m2, method="arellano", type="HC1", cluster="group")["valence","valence"])*sqrt(G/(G-1))
cat(sprintf("Model2 (CS trends):    b=%.4f  se=%.4f  t=%.4f  within-r2=%.4f  N=%d  (paper 1.6596/.2246/.588/104)\n", b2, se2, b2/se2, summary(m2)$r.squared[["rsq"]], length(m2$residuals)))

# ---- Table 2: historical determinants of NVI (Germany/Italy/UK/USA, 1820-2009) ----
sub2 <- d[d$C %in% c(1,4,5,6) & !is.na(d$valence) & !is.na(d$year),]
sub2$C <- as.factor(sub2$C); p2 <- pdata.frame(sub2, index=c("C","year")); G2 <- length(unique(sub2$C))
cat("\n=== Table 2 sample: N=", nrow(sub2), " ===\n")
m3 <- plm(valence ~ lgdpM5 + life_exp1 + wcovered_valence + polity2 + gini_edu + factor(year), data=p2, model="within")
for (v in c("lgdpM5","life_exp1")){
  se <- sqrt(plm::vcovHC(m3, method="arellano", type="HC1", cluster="group")[v,v])*sqrt(G2/(G2-1))
  cat(sprintf("Table2 col2 %-10s b=%.4f se=%.4f t=%.4f  (paper 0.0698/0.0106 and 0.0030/0.0014)\n", v, coef(m3)[v], se, coef(m3)[v]/se))
}
cat("Table2 col2 within-r2=", summary(m3)$r.squared[["rsq"]], " N=", length(m3$residuals), "\n")
