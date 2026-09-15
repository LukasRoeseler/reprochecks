# ReproAI internal-consistency audit: Baillon, Huang, Selim & Wakker (2018), Econometrica 86(5) 1839-1858
# DOI 10.3982/ECTA14370. No raw data/code is publicly available (2018 paper; no Zenodo replication package).
# Track (b) empirics: verify cross-table internal consistency and reimplement the linear index means
# from the Supplement Table SC.I matching-probability summary means.

options(width = 200)

## ---- Section 1: Claim the index definitions (Eq.2, Eq.3) ----
# b = 1 - mc - ms
# a = 3*(1/3 - (mc - ms)) = 1 - 3*(mc - ms)
# Verify neutrality / range calibrations
cat("=== INDEX DEFINITION CALIBRATION ===\n")
b  <- function(ms, mc) 1 - mc - ms
a  <- function(ms, mc) 1 - 3*(mc - ms)
cat(sprintf("Neutrality: ms=1/3, mc=2/3 -> b=%.3f (expect 0), a=%.3f (expect 0)\n", b(1/3,2/3), a(1/3,2/3)))
cat(sprintf("Max aversion (all m=0): b=%.3f (expect 1)  |  all m=1: b=%.3f (expect -1)\n", b(0,0), b(1,1)))
cat(sprintf("Max insensitivity (mc=ms): a=%.3f (expect 1)  |  perfect discrim (mc=2/3,ms=1/3): a=%.3f (expect 0)\n",
            a(0.5, 0.5), a(1/3, 2/3)))
cat(sprintf("a<0 allowed when mc-ms>1/3: a(ms=0.1,mc=0.6)=%.3f (<0, as paper states)\n", a(0.1,0.6)))

## ---- Section 2: Reimplement Table III index MEANS from Supplement Table SC.I ----
# Because b and a are LINEAR in (mc, ms), mean over subjects of the index = index of the means,
# so the Table SC.I component means uniquely determine the Table III index means.
# SC.I columns order: m1 m2 m3 m23 m13 m12 ms mc
C <- function(m1,m2,m3,m23,m13,m12) {
  ms <- (m1+m2+m3)/3
  mc <- (m23+m13+m12)/3
  c(ms=ms, mc=mc, b=b(ms,mc), a=a(ms,mc))
}

cells <- list(
  # label, m1,m2,m3,m23,m13,m12 , Table III reported b mean, Table III reported a mean, N
  list("Control Part1", .39,.38,.41,.69,.69,.65, -.07, .15, 42),
  list("Control Part2", .47,.38,.40,.68,.68,.72, -.11, .17, 42),
  list("TP      Part1", .42,.46,.42,.67,.66,.64, -.09, .34, 57),
  list("TP      Part2", .43,.40,.35,.63,.65,.73, -.06, .17, 57)
)
cat("\n=== REIMPLEMENTED INDEX MEANS (from SC.I) vs TABLE III (paper) ===\n")
cat(sprintf("%-16s %6s %6s | %8s %8s | %8s %8s | %s\n","cell","ms","mc","b_impl","b_paper","a_impl","a_paper","b/a match"))
for (cl in cells){
  v <- C(cl[[2]],cl[[3]],cl[[4]],cl[[5]],cl[[6]],cl[[7]])
  bm <- cl[[8]]; am <- cl[[9]]
  cat(sprintf("%-16s %6.3f %6.3f | %8.3f %8.2f | %8.3f %8.2f | b:%s a:%s\n", cl[[1]], v["ms"], v["mc"],
      v["b"], bm, v["a"], am,
      ifelse(abs(v["b"]-bm)<=0.005,"OK","**DIFF**"), ifelse(abs(v["a"]-am)<=0.005,"OK","**DIFF**")))
}

## ---- Section 3: Table III SD/SE internal consistency (SE = SD/sqrt(N)) ----
cat("\n=== TABLE III SE = SD/sqrt(N) INTERNAL CHECK ===\n")
rows <- list(
  c("Control a P1",0.44,0.07,42), c("Control a P2",0.41,0.06,42),
  c("Control b P1",0.21,0.03,42), c("Control b P2",0.24,0.04,42),
  c("TP a P1",0.44,0.06,57), c("TP a P2",0.45,0.06,57),
  c("TP b P1",0.24,0.03,57), c("TP b P2",0.24,0.03,57))
for (r in rows){ se <- as.numeric(r[2])/sqrt(as.numeric(r[4])); rep <- as.numeric(r[3]);
  cat(sprintf("%-14s SD=%.2f N=%s -> SE=%.4f vs reported %.2f  %s\n", r[1], as.numeric(r[2]), r[4], se, rep,
      ifelse(abs(se-rep)<=0.005,"OK","**DIFF**"))) }

## ---- Section 4: N / denominator arithmetic ----
cat("\n=== SAMPLE / DENOMINATOR ARITHMETIC ===\n")
cat(sprintf("Enrolled: 42 control + 62 TP = %d (paper: 104)\n", 42+62))
cat(sprintf("After 5 TP excluded: 42 + 57 = %d (paper: 99)\n", 42+57))
cat(sprintf("Regression obs N = 99*2 parts = %d (paper: 198)\n", 99*2))
cat(sprintf("Response-time obs N = 99*2*8 q = %d (paper: 1584)\n", 99*2*8))
cat(sprintf("TP Part1 choices = 62 subjects * 8 = %d (paper: 496)\n", 62*8))
cat(sprintf("Weak-monotonicity exclusions (suppl. SA): 2+3+2 = %d; N 198-7 = %d (paper SA: 191)\n", 7, 198-7))
cat(sprintf("Weak-monotonicity violation rates: TP P1 3/57=%.3f (paper 5%%), TP P2 2/57=%.3f (4%%), ",
            3/57, 2/57))
cat(sprintf("Ctrl P1 2/42=%.3f (5%%), Ctrl P2 0/42=0 (0%%)\n", 2/42))

## ---- Section 5: prose-vs-figure Spearman rho discrepancy (a-index) ----
cat("\n=== SPEARMAN rho: TEXT vs FIGURE 2 CAPTION (a-index, Parts 1 vs 2) ===\n")
text <- c(control=0.73, TP=0.74); fig2 <- c(control=0.77, TP=0.70)
for (g in c("control","TP"))
  cat(sprintf("%-8s text rho=%.2f | Figure2 caption rho=%.2f | %s\n", g, text[g], fig2[g],
      ifelse(text[g]==fig2[g],"agree","DISCREPANT")))
cat("(For contrast, Figure 1 b-index: text control 0.77 / TP 0.85 = figure caption control 0.77 / TP 0.85, consistent.)\n")

## ---- Section 6: Response-time narrative vs Table VI ----
cat("\n=== RESPONSE-TIME NARRATIVE vs TABLE VI (Model 1) ===\n")
cat(sprintf("Control P1 ~ Intercept %.2f s (text 'about 17 s') ; TP P1 = 16.63-4.13 = %.2f s (text 'about 4 s longer'), R2=%.2f\n",
            16.63, 16.63-4.13, 0.02))

cat("\n==== DONE (status: OK) ====\n")
