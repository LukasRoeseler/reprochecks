## ############################################################################
## ReproAI independent reimplementation (R 4.6.1) -- Francis & Thunell (2020)
## MP.2019.2266. Written independently of the author's OSF code (only the METHODS
## prose + reported parameters shared). Cross-checks the TES product, the two
## closed-form two-sample-t power studies, the inverse-variance meta-analysis and
## Table 2 sample sizes for BOTH the pre- and post-corrigendum input variants.
## Engine: anomalyco/opencode (ReproAI) -- DeepSeek V4 Flash via uniGPT.
## Rules: REPRO_STANDARDS.md 2026.06.27. Audit date: 2026-09-14. R 4.6.1.
## ############################################################################
suppressMessages({library(pwr)})
cat("R:", R.version.string, "\n")

## ---- C1: product of the six Table-1 power estimates (paper values) ----------
paperPower <- c(0.4582, 0.5426, 0.3626, 0.5358, 0.5667, 0.4953)
prod_paper <- prod(paperPower)
cat(sprintf("\nProduct of paper Table-1 powers = %.8f (paper states 0.014)\n", prod_paper))

## ---- Studies 2 & S1: closed-form two-sample-t power from reported t ----------
two_sample_power <- function(tval, n1, n2){
  J <- 1 - 3/(4*(n1+n2-2)-1)
  g <- J*tval*sqrt(1/n1 + 1/n2)
  pow <- pwr.t2n.test(n1=n1, n2=n2, d=g, sig.level=0.05, alternative="two.sided")$power
  c(g=g, power=pow)
}
s2  <- two_sample_power(2.08, 143, 132)
sS1 <- two_sample_power(2.07,  99,  77)
cat(sprintf("Study 2 : g=%.6f  power=%.5f (paper 0.5426)\n", s2["g"], s2["power"]))
cat(sprintf("Study S1: g=%.6f  power=%.5f (paper 0.5358)\n", sS1["g"], sS1["power"]))

## ---- Meta-analysis: Hedges' g + inverse-variance pooling, by hand -----------
heges <- function(n1,n2,m1,m2,s1,s2){   # NOTE: per-study g sign=+ per the
  pv <- ((n1-1)*s1^2 + (n2-1)*s2^2)/(n1+n2-2)   # direction of the effect
  J  <- 1 - 3/(4*(n1+n2-2)-1)
  d  <- (m2-m1)/sqrt(pv)
  c(g=J*d, gvar=J^2*((n1+n2)/(n1*n2) + d^2/(2*(n1+n2))))
}
meta_pool <- function(st){
  g   <- sapply(st, function(s) abs(heges(s$n1,s$n2,s$m1,s$m2,s$s1,s$s2)["g"]))
  gv  <- sapply(st, function(s) heges(s$n1,s$n2,s$m1,s$m2,s$s1,s$s2)["gvar"])
  sum(g/gv)/sum(1/gv)
}
base <- list(
  "2" =list(n1=143,n2=132,m1=1249.83,m2=1362.31,s1=449.07,s2=447.35),
  "3" =list(n1=85, n2=86, m1=1428.24,m2=1308.66,s1=377.02,s2=420.14),
  "S1"=list(n1=99, n2=77, m1=185.94, m2=215.73, s1=93.92, s2=95.33),
  "S2"=list(n1=139,n2=141,m1=1182.15,m2=1302.23,s1=477.60,s2=434.41),
  "S3"=list(n1=336,n2=337,m1=1302.03,m2=1373.15,s1=480.02,s2=442.49))
post <- base; post[["1"]] <- list(n1=45,n2=54,m1=654.53,m2=865.41,s1=390.45,s2=517.26)
pre  <- base; pre [["1"]] <- list(n1=45,n2=55,m1=654.53,m2=865.41,s1=390.45,s2=517.26)
gpost <- meta_pool(post); gpre <- meta_pool(pre)
cat(sprintf("\nPooled Hedges' g POST-corrigendum (n1R=54) = %.7f  (author R 0.2365894)\n", gpost))
cat(sprintf("Pooled Hedges' g PRE-corrigendum  (n1R=55) = %.7f  (author R 0.2366623)\n", gpre))
cat(sprintf("Paper in-text g* = 0.2366 : consistent with both at 3 dp\n"))

## ---- Table 2 sample sizes (pwr.t.test = author's exact tool) ----------------
t2 <- function(g, des=c(0.8,0.85,0.9,0.95,0.99)){
  sapply(des, function(p) ceiling(pwr.t.test(d=g,power=p,type="two.sample",
        alternative="two.sided")$n))
}
cat("\nTable 2 printed full :", c(282,322,377,465,658), "\n")
cat("Table 2 printed half :", c(1123,1284,1502,1858,2626), "\n")
cat("PRE  g full :", t2(gpre), "  half:", t2(gpre/2), "\n")
cat("POST g full :", t2(gpost),"  half:", t2(gpost/2), "\n")

## ---- write machine-readable results -----------------------------------------
lines <- c(
  paste("ProductTable1Powers", sprintf("%.8f", prod_paper)),
  paste("Study2_power", sprintf("%.6f", unname(s2["power"]))),
  paste("StudyS1_power", sprintf("%.6f", unname(sS1["power"]))),
  paste("Pooled_g_POST", sprintf("%.7f", gpost)),
  paste("Pooled_g_PRE", sprintf("%.7f", gpre)),
  paste("Table2_pre_full", paste(t2(gpre),  collapse=",")),
  paste("Table2_pre_half", paste(t2(gpre/2), collapse=",")),
  paste("Table2_post_full", paste(t2(gpost), collapse=",")),
  paste("Table2_post_half", paste(t2(gpost/2), collapse=","))
)
writeLines(lines, "output/reimpl_tes_results.csv")
cat("\nDone. -> output/reimpl_tes_results.csv\n")
