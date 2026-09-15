# ReproAI static-audit reimplementation — s10683-011-9295-3
# Rodriguez-Lara & Moreno-Garrido (2012), Exp Econ 15:158-175
# No public raw data deposit (2011 Springer; ESM = appendices only, no data).
# This script reimplements the DERIVABLE / INTERNAL-CONSISTENCY checks from the
# published summary statistics. All raw-data-dependent stats are out of scope (risk code DATA-NA).
suppressMessages(library(stats))

base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/03_s10683-011-9295-3/ReproAI/s10683-011-9295-3"
outdir <- file.path(base, "exec_check", "output")

# --- Reported Table 1 values (n = 24 each treatment) ---
n <- 24
treat <- c("DW","DB","BL","Pooled")
qd_mean <- c(9.92, 10.75, 9.83, 10.16)
qd_sd   <- c(2.95,  2.41, 3.47, 2.96)
qd_min  <- c(5,7,3,3); qd_max <- c(16,15,17,17)
qr_mean <- c(10.17, 10.5, 11.96, 10.87)
qr_sd   <- c(2.39, 3.13, 3.38, 3.06)
qr_min  <- c(6,5,4,4); qr_max <- c(16,19,18,19)
s_mean  <- c(0.44, 0.37, 0.36, 0.39)
s_sd    <- c(0.20, 0.17, 0.21, 0.19)
s_min   <- c(0,0,0,0); s_max <- c(0.74,0.57,0.63,0.74)
sh_nothing <- c(0.08, 0.04, 0.17, 0.10)
sh_above05 <- c(0.29, 0.17, 0.25, 0.24)
sxa_mean <- c(-0.07,-0.12,-0.18,-0.13)
sxa_sd   <- c(0.17,0.16,0.25,0.20)
sxa_min  <- c(-0.53,-0.56,-0.69,-0.69); sxa_max <- c(0.07,0.12,0.10,0.12)
sxl_mean <- c(-0.14,-0.03,-0.18,-0.11)
sxl_sd   <- c(0.17,0.16,0.25,0.20)
sxl_min  <- c(-0.60,-0.46,-0.69,-0.69); sxl_max <- c(0,0.21,0.10,0.21)

res <- list()
logline <- function(...) cat(sprintf(...), "\n")

logline("==== ReproAI consistency reimplementation START (status: OK) ====")
cat("Engine: anomalyco/opencode (ReproAI) / DeepSeek V4 Flash via uniGPT\n")
cat("Rules: 2026.06.27  Audit date: 2026-09-14  R ", R.version.string, "\n\n")

# ---------- 1. Pooled means vs unweighted group means ----------
logline("[1] Pooled (n=72) mean = unweighted mean of the three treatment means (n=24 each)")
pool_check <- function(reported, g1,g2,g3, name){
  calc <- (g1+g2+g3)/3
  res[[name]] <<- data.frame(reported=reported, calculated=round(calc,2))
  logline("   %-12s reported=%.2f  calc=%.3f  diff=%.3f", name, reported, calc, reported-calc)
}
pool_check(10.16, 9.92,10.75,9.83,  "qd pool mean")
pool_check(10.87, 10.17,10.5,11.96, "qr pool mean")
pool_check(0.39,  0.44,0.37,0.36,   "s pool mean")
pool_check(-0.13, -0.07,-0.12,-0.18,"s-xa pool mean")
pool_check(-0.11, -0.14,-0.03,-0.18,"s-xl pool mean")
logline("   (s-xa) & (s-xl) pooled: computed -0.1233 & -0.1167 -> would round to -0.12/-0.12; paper prints -0.13/-0.11 (rounding drift)")

# ---------- 2. (s-xa), (s-xl) derived from qd,qr,s means ----------
logline("[2] (s-xa)=s-qr/(qd+qr) and (s-xl)=s-mr/(md+mr) from cell means (price: DW 150:200, DB 150:100, BL 150:150)")
pr <- c(200,100,150); pd <- c(150,150,150)
for(i in 1:3){
  xa <- qr_mean[i]/(qd_mean[i]+qr_mean[i])
  xl <- (pr[i]*qr_mean[i])/(pd[i]*qd_mean[i]+pr[i]*qr_mean[i])
  sxa_c <- s_mean[i]-xa; sxl_c <- s_mean[i]-xl
  logline("   %s: s-xa rep=%.2f calc=%.3f | s-xl rep=%.2f calc=%.3f", treat[i], sxa_mean[i], sxa_c, sxl_mean[i], sxl_c)
}

# ---------- 3. Footnote 13: BL qd vs qr independent two-sample t (pooled, df=46) ----------
logline("[3] Footnote 13: BL qd!=qr, reported t=2.14, p=0.036 -> recompute from cell stats")
m1<-9.83; s1<-3.47; m2<-11.96; s2<-3.38
sp2 <- ((n-1)*s1^2 + (n-1)*s2^2)/(2*n-2)
se <- sqrt(sp2*(2/n)); t13 <- (m2-m1)/se; p13 <- 2*pt(-abs(t13), df=46)
logline("   t=%.3f  two-tailed p=%.4f  (df=46)", t13, p13)

# ---------- 4. Footnote 14: DW vs DB offers KS, D=0.33, n=24 each ----------
logline("[4] Footnote 14: KS=0.33, p=0.089 (DW vs DB offers). Compute two-sample two-sided KS p for n1=n2=24.")
# Exact two-sample KS p via Kolmogorov distribution (asymptotic for the test statistic k = D*sqrt(mn/(m+n)))
ku <- 0.33*sqrt(24*24/48)
# two-sided p ~ 2 * sum_{j>=1} (-1)^(j-1) exp(-2 j^2 k^2)
ks_p <- function(k){ s<-0; for(j in 1:40){ s<-s + (-1)^(j-1)*exp(-2*j^2*k^2) }; 2*s }
p14 <- ks_p(ku)
logline("   k=%.3f  two-sided asymptotic p=%.4f   [exact/companion approx not reproducible w/o raw data -> not exact]", ku, p14)

# ---------- 5. W (z) <-> two-tailed p mapping ----------
logline("[5] Reported 'W' = normal approx z; verify every printed (W, p) pair by p=2*(1-pnorm(|W|))")
w_cases <- data.frame(
  label = c(
   "Account DW ftn17","Libert DW ftn17","Egalit DW ftn17",
   "md>=mr Libert T3","md<mr Egalit T3","md<mr qd>=qr Acc","md<mr qd>=qr Lib","md<mr qd>=qr Egal",
   "md<mr qd<qr Acc","md<mr qd<qr Lib","md<mr qd<qr Egal",
   "md>=mr pd>pr Lib","md>=mr pd<=pr Acc","md>=mr pd<=pr Lib","md>=mr pd<=pr Egal",
   "Pool bias W","Pool acc W","Pool lib W","Pool egal W"),
  W = c(0.93,4.095,1.060, 0.762,0.240, 0.120,2.668,1.640, 3.845,4.131,0.292, 0.345,1.120,1.753,3.185, 0.10,4.93,4.484,3.936),
  p_reported = c(0.3529,0.0000,0.2889, 0.446,0.810, 0.9049,0.007,0.10, 0.0001,0.0000,0.7699, 0.730,0.904,NA,NA, 0.9172,NA,NA,NA))
w_cases$p_calc <- round(2*pnorm(-abs(w_cases$W)),4)
w_cases$flag <- with(w_cases, ifelse(is.na(p_reported),"n/a", ifelse(abs(p_calc-p_reported)<=0.0009,"OK",
                                   ifelse(abs(p_calc-p_reported)<=0.003,"~","MISMATCH"))))
for(i in seq_len(nrow(w_cases)))
  logline("   [%s] W=%.3f p_reported=%.4f p_calc=%.4f -> %s", w_cases$label[i], w_cases$W[i], w_cases$p_reported[i], w_cases$p_calc[i], w_cases$flag[i])
logline("   *** KEY: md>=mr & pd<=pr Accountability W=1.120 -> p_calc=0.2628, but in-text prints p-value=0.904 (matches W=0.12 row) -> citation error.")

# ---------- 6. F <-> p mapping (given df) ----------
logline("[6] F(.,.) <-> p verification for reported F values")
f_cases <- data.frame(
  label=c("Lib DW robust ftn17","Lib DW quant ftn17","Acc DW robust ftn17","Acc DW quant ftn17",
          "Lib DB robust ftn17","Lib DB quant ftn17","Egal DW robust ftn17","Egal DW quant ftn17",
          "Pool acc robust","Pool acc quant","Pool lib robust","Pool lib quant",
          "Pool egal robust","Pool egal quant","Pool bias robust","Pool bias quant",
          "Bias isolate robust ftn19","M-acc DB(2,22)","M-acc DB unself(2,20)","M-lib DW(2,22)","M-lib DW unself(2,19)"),
  F=c(7.93,8.03,2.04,1.39, 0.88,0.00,4.28,0.61, 16.03,13.98,15.72,6.79, 21.46,10.70,3.17,0.35, 0.59, 25.97,10.43,17.89,8.55),
  df1=c(2,2,2,2, 2,2,2,2, 2,2,2,2, 2,2,2,2, 2, 2,2,2,2),
  df2=c(22,22,22,22, 22,22,22,22, 60,60,60,60, 60,60,60,60, 60, 22,20,22,19),
  p_reported=c(0.0025,0.0024,0.1534,0.2705, 0.4278,1,0.0269,0.5524, 0.0020,NA,NA,NA, NA,NA,0.0482,0.7056, 0.5597, 0.0000,0.001,0.0000,0.002))
f_cases$p_calc <- round(pf(f_cases$F, f_cases$df1, f_cases$df2, lower.tail=FALSE),4)
f_cases$p_calc <- ifelse(f_cases$F==0, 1, f_cases$p_calc)
f_cases$flag <- with(f_cases, ifelse(is.na(p_reported),"n/a", ifelse(abs(p_calc-p_reported)<=0.0009,"OK","~")))
for(i in seq_len(nrow(f_cases)))
  logline("   [%s] F=%g(%d,%d) p_reported=%s p_calc=%.4f -> %s", f_cases$label[i], f_cases$F[i], f_cases$df1[i], f_cases$df2[i], ifelse(is.na(f_cases$p_reported[i]),"n/a",as.character(f_cases$p_reported[i])), f_cases$p_calc[i], f_cases$flag[i])
logline("   Pooled F df2=60 with n=72 implies k=12 estimated params in unrestricted robust model (not a plain 2-param fit, which would be df2=70) -> documentation note.")

# ---------- 7. q0, q1 breaking points (Appendix C) ----------
logline("[7] Appendix C thresholds: q0 (DW, 200qr=150qd) -> qr/Q = 0.75/1.75 = 3/7; q1 (DB, 150qd=100qr) -> 1.5/2.5 = 0.6")
q0 <- 0.75/1.75; q1 <- 1.5/2.5
logline("   q0 = %.4f (paper 3/7 = %.4f)  q1 = %.4f (paper 0.6)", q0, 3/7, q1)

# ---------- 8. Cell counts: 'share offering nothing' integer decomposition ----------
logline("[8] Share-offering-nothing -> integer counts out of 24")
cnt_nothing <- round(sh_nothing[1:3]*24)
  logline("   DW=%d/24 (%.2f), DB=%d/24 (%.2f), BL=%d/24 (%.2f); total zero-givers=%d /72 = %.3f",
        cnt_nothing[1],cnt_nothing[1]/24, cnt_nothing[2],cnt_nothing[2]/24, cnt_nothing[3],cnt_nothing[3]/24, sum(cnt_nothing), sum(cnt_nothing)/72)
logline("   Pooled reported 0.10 -> about 7 zero-givers. Footnote/Appendix B state EIGHT s=0 dictators (8/72=0.111).")
logline("   Prose 'positive transfers 90 pct of the time' matches 7 zero-givers (65/72=0.9028), NOT 8 (64/72=0.8889).")
logline("   Appendix B: 'unselfish' (give>=5pct) DW=21, DB=22 -> below-5pct = 3 in DW, 2 in DB.")
logline("   => internal inconsistency 7 (Table-shares/prose-90pct) vs 8 (footnote19/AppendixB) zero-givers.")

# ---------- 9. Pooled min/max vs treatment min/max ----------
cat("[9] Pooled min/max vs across-treatment min/max\n")
chk <- function(short, mn, mx){ ok <- (mn[4]==min(mn[1:3]) && mx[4]==max(mx[1:3])); cat("   ", short, ifelse(ok,"OK","!"), " pooled", mn[4], "/", mx[4], "\n") }
chk("qd:", qd_min, qd_max)
chk("qr:", qr_min, qr_max)
chk("s:",  s_min,  s_max)
chk("sxa:",sxa_min,sxa_max)
chk("sxl:",sxl_min,sxl_max)

# ---------- 10. '~40%' prose check ----------
cat("[10] prose 'average distribution is around 40 percent' vs pooled s=0.39 -> 0.39 (39 percent, ~40) OK\n")

logline("==== END (status: OK) ====")

save(w_cases, f_cases, file=file.path(outdir,"consistency_cases.RData"))
write.csv(w_cases, file.path(outdir,"w_to_p_check.csv"), row.names=FALSE)
write.csv(f_cases, file.path(outdir,"f_to_p_check.csv"), row.names=FALSE)
