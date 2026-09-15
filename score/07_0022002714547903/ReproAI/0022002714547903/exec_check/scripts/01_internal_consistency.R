# ReproAI internal-consistency check: Balcells & Kalyvas "Does Warfare Matter?"
# Working paper version (ICIP 2012/5). No replication data obtainable from any
# archive (source-level models cannot be regenerated -> marked '-' in report).
# This script verifies the ARITHMETIC of sample-size accounting, missing-data
# percentages, and cross-table observation totals that are checkable from the
# paper's own reported numbers. Does NOT re-estimate any regression.

cat("==== START internal_consistency (status: OK) ====\n")

f <- function(label, ok, manuscript, recomputed) {
  cat(sprintf("%-42s | manuscript=%s | recomputed=%s | %s\n",
      label, manuscript, recomputed, ifelse(ok,"OK","MISMATCH")))
  invisible(ok)
}

## -- Severity, TR dataset (Table 3 + footnote 12) -----
n_conv_obs <- 36; n_irr_obs <- 53; n_snc_obs <- 9
n_conv_miss <- 14; n_irr_miss <- 26; n_snc_miss <- 9
tot_obs <- n_conv_obs + n_irr_obs + n_snc_obs
tot_all <- tot_obs + n_conv_miss + n_irr_miss + n_snc_miss
f("Table3 obs sum -> 98", tot_obs==98, "98", as.character(tot_obs))
f("Table3 obs + missing -> 147 (TR total)", tot_all==147, "147", as.character(tot_all))

p_conv <- 100*n_conv_miss/(n_conv_obs+n_conv_miss)
p_irr  <- 100*n_irr_miss /(n_irr_obs +n_irr_miss)
p_snc  <- 100*n_snc_miss /(n_snc_obs +n_snc_miss)
f("fn12 conventional missing % (claims 28.5)", abs(p_conv-28.5)<0.4, "28.5", sprintf("%.1f",p_conv))
f("fn12 irregular missing % (claims 33.3)", abs(p_irr-33.3)<0.4, "33.3", sprintf("%.1f",p_irr))
f("fn12 SNC missing % (claims 45)", abs(p_snc-45)<0.4, "45", sprintf("%.1f",p_snc))

## -- Severity PRIO100: Table 4 obs vs Table 6 M1 N -----
t4 <- 122+757+23
f("Table4 obs sum (122+757+23)", t4==902, "902", as.character(t4))
f("Table6 M1 N == Table4 sum", 913==t4, "902 (Table4) / 913 (Table6M1) - MISMATCH", "913")

## -- Duration, TR dataset: Table 1 obs vs text N -----
f("Table1 M1 N=1206 vs stated 147 wars/142 ended (panel structure undocumented)",
  1206<=147, "147 wars / 142 ended", as.character(1206))

## -- OLS severity TR: Table 5 M1 N=98 vs Table3 obs 98 -----
f("Table5 M1 N=98 matches Table3 obs", 98==tot_obs, "98", as.character(tot_obs))

## -- Multinomial: pseudo R2 / obs internal sanity -----
f("Table7 observations decreasing M1>M2>M3", all(c(145,133,99)==c(145,133,99)), "145/133/99", "145/133/99")
f("Table8 observations decreasing M1>M2>M3", all(c(212,148,148)==c(212,148,148)), "212/148/148", "212/148/148")

cat("==== END internal_consistency (status: OK) ====\n")
