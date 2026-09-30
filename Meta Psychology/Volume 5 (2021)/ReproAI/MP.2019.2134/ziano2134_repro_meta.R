# Ziano (2021) MP.2019.2134 - t-tests and mini meta-analysis
mt <- read.csv("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/ziano/RoyzmanBaron_S2_MTurk.csv", stringsAsFactors=FALSE, check.names=FALSE)
hk <- read.csv("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/ziano/RoyzmanBaron_S2_HK.csv", stringsAsFactors=FALSE, check.names=FALSE)

# One-sample t-test against 0
tt <- function(v, label){
  v <- as.numeric(v); v <- v[!is.na(v)]
  t <- t.test(v, mu=0)
  cat(sprintf("%-20s n=%3d  M=%.3f SD=%.3f  t(%d)=%.3f  p=%.4f  d=%.3f\n", label, length(v), mean(v), sd(v), t$parameter, unname(t$statistic), t$p.value, mean(v)/sd(v)))
}
tt(mt[["Organ Morality (categorized)"]], "MTurk organ")
tt(mt[["Zoo Morality (categorized)"]], "MTurk zoo")
tt(hk[["Organ Morality - Categorized"]], "HK organ")
tt(hk[["Zoo Morality - Categorized"]], "HK zoo")

# Mini meta-analysis (random effects, d + CI). Using metafor if available.
if (requireNamespace("metafor", quietly=TRUE)) {
  # organ: original 0.70 [.40,.99], HK 0.55 [.23,.86], MTurk 0.24 [.12,.34]
  organ <- data.frame(d=c(0.70,0.55,0.24), lo=c(0.40,0.23,0.12), hi=c(0.99,0.86,0.34), n=c(54,46,314))
  organ$sei <- (organ$hi-organ$lo)/(2*1.96)
  m <- metafor::rma(yi=d, sei=sei, method="REML", data=organ)
  cat("\nORGAN mini-meta: d=%.3f [%.3f, %.3f]\n", m$b[1], m$ci.lb, m$ci.ub)
  zoo <- data.frame(d=c(0.70,0.41,0.36), lo=c(0.40,0.11,0.24), hi=c(0.99,0.71,0.47), n=c(54,46,314))
  zoo$sei <- (zoo$hi-zoo$lo)/(2*1.96)
  m2 <- metafor::rma(yi=d, sei=sei, method="REML", data=zoo)
  cat("ZOO mini-meta: d=%.3f [%.3f, %.3f]\n", m2$b[1], m2$ci.lb, m2$ci.ub)
} else {
  cat("\nmetafor not installed; skipping mini-meta\n")
}
