## ReproAI audit: Altmann, Falk & Wibral (2012), JOLE 30(1):149-174, DOI 10.1086/662130
## Static / internal-consistency audit. No raw (z-Tree) data is shipped with the paper and
## none is publicly obtainable, so treatment means / MW-U / Table 3 OLS are NOT recomputable.
## What IS recomputable here:
##   (1) Nash-equilibrium effort predictions from the experimental parameters (wages, c, q).
##   (2) One-sample t-tests of row means vs equilibrium FROM REPORTED (mean, SD, N).
##   (3) Two-sided p-values implied by the reported Mann-Whitney z statistics.
##   (4) Sample-size / percentage / arithmetic consistency.
## Written by: DeepSeek V4 Flash (uniGPT) via opencode ReproAI engine. Host R 4.6.1.
## No RNG anywhere: all checks are closed-form.

options(width = 200)
outdir <- "output"

round2p <- function(z) 2 * pnorm(-abs(z))

## ---------- (1) Equilibrium effort predictions --------------------------------
## Model: f_eps(0) = 1/(2q); FOC -> e* = c*(w_high - w_low)/(4q). c=2250, q=60.
c <- 2250; q <- 60
wSpread <- c(OS = 13.62 - 5.73,                # w_med_OS - w_low
             TS_stage2 = 20 - 12.11,           # w_high - w_med
             THS_stage3 = 26.38 - 18.49,       # w_top - w_high
             OSL = 17.57 - 9.68)               # lottery high - low
eStar <- c * wSpread / (4 * q)
eStarR <- round(eStar)
eq <- data.frame(Treatment = names(wSpread), WageSpread = wSpread,
                 eStar_raw = eStar, eStar_rounded = eStarR, PaperPred = 74)
print(eq)
write.csv(eq, file.path(outdir, "equilibrium_predictions.csv"), row.names = FALSE)

## ---------- (2) One-sample t-tests of reported means vs equilibrium (74) ---- 
rows <- data.frame(
  Label = c("OS stage1", "TS stage1", "TS stage2", "THS stage1",
            "THS stage2", "THS stage3", "OSL stage1"),
  Mean  = c(71.7, 84.8, 76.7, 79.2, 83.1, 74.6, 77.3),
  SD    = c(29.1, 19.7, 26.5, 16.2, 17.3, 23.9, 25.8),
  N     = c(60, 64, 32, 64, 32, 16, 100),
  H0  = 74,
  PaperP = c(.534, NA, .565, .013, .006, .918, .199),
  PaperText = c("not rejected (p=.534)","rejected p<.001","not rejected (p=.565)",
                "rejected (p=.013)","rejected (p=.006)","not rejected (p=.918)",
                "insignificant (p=.199)")
)
tcalc <- mapply(function(m,s,n,h) (m-h)/(s/sqrt(n)), rows$Mean, rows$SD, rows$N, rows$H0)
rows$t_recalc <- round(tcalc, 4)
rows$p_recalc  <- round(2*pt(-abs(tcalc), df=rows$N-1), 4)
rows$sigma_check <- rows$PaperP - rows$p_recalc   # abs diff
print(rows[, c("Label","Mean","SD","N","t_recalc","p_recalc","PaperP","PaperText")])
write.csv(rows, file.path(outdir, "onesample_ttests_recompute.csv"), row.names = FALSE)

## ---------- (3) Mann-Whitney z -> two-sided p (internal conversion check) ----
mw <- data.frame(
  Comparison = c("OS vs TS st1 (Result 2)",
                 "TS finalists st1->st2 Wilcoxon |z|",
                 "TS st2 vs OS",
                 "THS final vs TS final",
                 "THS prefinal vs TS st1",
                 "THS st1 vs TS st1",
                 "OSL vs OS",
                 "OSL vs TS"),
  absz = c(2.536, 2.315, .771, .37, .81, 1.85, .94, 1.81),
  PaperP = c(.011, .021, .441, .710, .419, .065, .349, .070)
)
mw$p_from_z <- round(round2p(mw$absz), 3)
mw$within <- abs(mw$PaperP - mw$p_from_z) <= 0.0015
print(mw)
write.csv(mw, file.path(outdir, "mannwhitney_z2p.csv"), row.names = FALSE)

## ---------- (4) Sample / arithmetic consistency ------------------------------
## OS 60 + TS 64 = 124 (two main treatments) ; + THS 64 + OSL 100 + TSC 32 = 320
N <- data.frame(Item = c("OS","TS","TS+OS (two main)","THS","OSL","TSC (footnote)","Total all"),
                Reported = c(60,64,124,64,100,32,320), Author = "paper")
N$recaltotal <- 60+64+64+100+32
print(N)
write.csv(N, file.path(outdir, "sample_sizes.csv"), row.names = FALSE)

## arithmetic: OS->TS "almost 20% higher"
cat("TS/OS ratio:", 84.8/71.7, "\n")
## OSL vs OS "more than five points above": 77.3 - 71.7
cat("OSL-OS points:", 77.3-71.7, "\n")
## finalists st1 93.1 -> st2 76.7 drop "about 16 points"
cat("finalist drop:", 93.1-76.7, "\n")
## footnote10: median 84 vs second-stage effort 55 "almost 30% lower than actual"
cat("footnote10: 55/76.7 =", 55/76.7, " -> lower by", 1-55/76.7, "\n")
## OS: 20% of subjects at/below TS min 40 ; TS min effort 40
cat("TS min effort reported 40; OS at-or-below 40 = 20%\n")
## footnote9 TSC: mean 82.4, median 83, SD 24.6, N=32, e*=42
tsc <- data.frame(Mean=82.4, SD=24.6, N=32, H0=42)
tsc$t <- (tsc$Mean-42)/(tsc$SD/sqrt(tsc$N))
tsc$p <- 2*pt(-abs(tsc$t), df=31)
print(tsc)   # paper: "significantly above 42 (p<.001)"
write.csv(tsc, file.path(outdir, "tsc_footnote9.csv"), row.names = FALSE)

## Risk CE N=114 consistency: footnote 7 -> 10 subjects no CE, 124-10=114 (Table 3 col 2)
cat("Risk CE N check: 124-10 =", 124-10, "(Table 3 col 2 reports N=114)\n")

## Distributional claim sanity: SD vs bounded 0-125
print(rows[,c("Label","Mean","SD")])

cat("\n==== ReproAI internal-consistency recompute complete ====\n")
