# Ziano (2021) MP.2019.2134 - replicate per-study effect sizes
# Effect = mean of categorized preference variable (1=prefer indirect, -1=prefer direct, 0=none)
# Cohen's d (one-sample) = M / SD

mt <- read.csv("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/ziano/RoyzmanBaron_S2_MTurk.csv", stringsAsFactors=FALSE, check.names=FALSE)
hk <- read.csv("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/ziano/RoyzmanBaron_S2_HK.csv", stringsAsFactors=FALSE, check.names=FALSE)

cat("MTurk n=", nrow(mt), " HK n=", nrow(hk), "\n")

calc <- function(v, label, reported_d) {
  v <- as.numeric(v)
  v <- v[!is.na(v)]
  M <- mean(v)
  SD <- sd(v)
  d <- M / SD
  cat(sprintf("%-22s n=%3d  M=%.3f  SD=%.3f  d=%.3f  (reported d=%.2f)\n", label, length(v), M, SD, d, reported_d))
  invisible(c(M, SD, d))
}

calc(mt[["Organ Morality (categorized)"]], "MTurk Organ", 0.24)
calc(mt[["Zoo Morality (categorized)"]], "MTurk Zoo", 0.36)

calc(hk[["Organ Morality - Categorized"]], "HK Organ", 0.55)
calc(hk[["Zoo Morality - Categorized"]], "HK Zoo", 0.41)

cat("--- HK after filter_$==1 (n=", sum(hk[["filter_$"]]==1), ") ---\n")
hkf <- hk[hk[["filter_$"]]==1, , drop=FALSE]
calc(hkf[["Organ Morality - Categorized"]], "HK Organ (filtered)", 0.55)
calc(hkf[["Zoo Morality - Categorized"]], "HK Zoo (filtered)", 0.41)
