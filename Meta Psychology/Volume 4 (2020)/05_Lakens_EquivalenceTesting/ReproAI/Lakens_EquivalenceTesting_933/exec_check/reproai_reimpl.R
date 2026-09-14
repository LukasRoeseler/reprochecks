# ReproAI re-audit of Lakens & Delacre (2020) MP.2018.933
# "Equivalence Testing and the Second Generation P-Value"
# Engine: anomalyco/opencode (ReproAI) - DeepSeek V4 Flash via uniGPT
# Rules: REPRO_STANDARDS.md 2026.06.27 ; Audit date: 2026-09-14
# Independent reimplementation of TOST + SGPV from FIRST PRINCIPLES,
# cross-checked against the author's own p_delta() (dependency-free) function.

set.seed(20260914)

outdir <- "exec_check/output"
dir.create(outdir, showWarnings = FALSE)

# ---- Author's reference SGPV implementation (sourced, dependency-free) ----
source("extracted/author_code/functions__SGPV_function.R")  # defines p_delta()

# ---- Independent SGPV from the paper's formula ----
# p_delta = |I n H0| / |I|  * max(|I| / (2|H0|), 1)
sgpv_formula <- function(lb, ub, delta_lb, delta_ub) {
  if (ub < delta_lb | lb > delta_ub) return(0)              # no overlap
  if (lb >= delta_lb & ub <= delta_ub) return(1)            # CI inside H0
  inter <- min(ub, delta_ub) - max(lb, delta_lb)            # overlap width
  ci_w  <- ub - lb
  h0_w  <- delta_ub - delta_lb
  inter / ci_w * max(ci_w / (2 * h0_w), 1)
}

# ---- TOST p-value (one-sample), M = equivalence max of the two one-sided p's ----
tost_p_onesample <- function(m, mu0, n, sd, low_eq, high_eq) {
  se <- sd / sqrt(n)
  t_lo <- (m - low_eq) / se
  t_hi <- (m - high_eq) / se
  p_lo <- pt(t_lo, df = n - 1, lower.tail = FALSE)
  p_hi <- pt(t_hi, df = n - 1, lower.tail = TRUE)
  max(p_lo, p_hi)
}
t_onesample <- function(m, bound, n, sd) (m - bound) / (sd / sqrt(n))

logrow <- function(x) cat(sprintf("%s\n", paste(x, collapse = "\t")))
out <- function(x) {
  con <- file(file.path(outdir, "reproai_results.tsv"), open = "a")
  writeLines(paste(x, collapse = "\t"), con); close(con)
}
if (file.exists(file.path(outdir, "reproai_results.tsv"))) file.remove(file.path(outdir, "reproai_results.tsv"))
out(c("claim","quantity","manuscript","reimpl","verdict"))

# ================= FIGURE 1 =================
# One-sample t-test, n=30, sd=2, eq bounds [143,147] (145 +/- 2), means 140..150
cat("=== FIGURE 1: means 140..150, n=30, sd=2, eq=[143,147] ===\n")
n <- 30; sd <- 2; lo <- 143; hi <- 147
fig1 <- data.frame(mean = integer(), tost_p = numeric(), sgpv = numeric())
for (m in 140:150) {
  p <- tost_p_onesample(m, 145, n, sd, lo, hi)
  se <- sd/sqrt(n); tcrit <- qt(0.975, n-1)
  lb <- m - tcrit*se; ub <- m + tcrit*se
  s <- sgpv_formula(lb, ub, lo, hi)
  s_ref <- p_delta(lb, ub, lo, hi)
  fig1 <- rbind(fig1, data.frame(mean=m, tost_p=round(p,4), sgpv=round(s,4)))
  cat(sprintf("mean=%3d  TOST p=%.4f  SGPV=%.4f  (author p_delta=%.4f)\n",
              m, p, s, s_ref))
}
write.csv(fig1, file.path(outdir,"fig1_table.csv"), row.names=FALSE)

# t-statistics cited in text
t145 <- t_onesample(145, 143, n, sd); t140 <- t_onesample(140, 143, n, sd)
cat(sprintf("At mean=145: t(29)=%.2f  paper: 5.48\n", t145))
cat(sprintf("At mean=140: t(29)=%.2f  paper: -8.22\n", t140))
out(c("C3","t at mean=145","5.48 (p<.001)", sprintf("%.2f",t145), ifelse(abs(t145-5.48)<0.005,"OK","CHECK")))
out(c("C4","t at mean=140","-8.22 (p=1)", sprintf("%.2f",t140), ifelse(abs(t140+8.22)<0.005,"OK","CHECK")))
# TOST p at mean=145 and mean=140
p145 <- tost_p_onesample(145,145,n,sd,lo,hi); p140 <- tost_p_onesample(140,145,n,sd,lo,hi)
out(c("C3","TOST p at 145","< .001", sprintf("%.2e",p145), ifelse(p145<0.001,"OK","CHECK")))
out(c("C4","TOST p at 140","1 (>.999)", sprintf("%.2f",p140), ifelse(p140>0.999,"OK","CHECK")))
# SGPV at 145 and 140
se<-sd/sqrt(n); tcrit<-qt(0.975,n-1)
sv145<-p_delta(145-tcrit*se,145+tcrit*se,lo,hi); sv140<-p_delta(140-tcrit*se,140+tcrit*se,lo,hi)
out(c("C3","SGPV at 145","1", sprintf("%.4f",sv145), ifelse(sv145==1,"OK","CHECK")))
out(c("C4","SGPV at 140","0", sprintf("%.4f",sv140), ifelse(sv140==0,"OK","CHECK")))

# ---- Three correspondence points ----
# (a) mean on eq bound => TOST p=0.5, SGPV=0.5
for (m in c(143,147)) {
  p<-tost_p_onesample(m,145,n,sd,lo,hi); s<-p_delta(m-tcrit*se,m+tcrit*se,lo,hi)
  cat(sprintf("corr: mean=%d  TOST_p=%.4f (want 0.5)  SGPV=%.4f (want 0.5)\n",m,p,s))
  out(c("C6","TOST p=0.5 @ bound", m, sprintf("%.4f",p), ifelse(abs(p-0.5)<0.001,"OK","CHECK")))
}
# (b) lower CI endpoint == lower bound => TOST p=0.025, SGPV=1
mB <- lo + tcrit*se
pB <- tost_p_onesample(mB,145,n,sd,lo,hi); sB<-p_delta(mB-tcrit*se,mB+tcrit*se,lo,hi)
cat(sprintf("situation B mean=%.4f  TOST_p=%.4f (want 0.025)  SGPV=%.4f (want 1)\n",mB,pB,sB))
out(c("C7","situation B TOST p","0.025", sprintf("%.4f",pB), ifelse(abs(pB-0.025)<0.0005,"OK","CHECK")))
out(c("C7","situation B SGPV","1", sprintf("%.4f",sB), ifelse(abs(sB-1)<1e-9,"OK","CHECK")))
# (c) lower CI endpoint == upper bound, CI above eq => TOST p=0.975, SGPV=0
mC <- hi + tcrit*se
pC <- tost_p_onesample(mC,145,n,sd,lo,hi); sC<-p_delta(mC-tcrit*se,mC+tcrit*se,lo,hi)
cat(sprintf("situation C mean=%.4f  TOST_p=%.4f (want 0.975)  SGPV=%.4f (want 0)\n",mC,pC,sC))
out(c("C8","situation C TOST p","0.975", sprintf("%.4f",pC), ifelse(abs(pC-0.975)<0.0005,"OK","CHECK")))
out(c("C8","situation C SGPV","0", sprintf("%.4f",sC), ifelse(abs(sC-0)<1e-9,"OK","CHECK")))

# ================= FIGURE 4 =================
cat("\n=== FIGURE 4: m-diff 1.5,1.4,1.3,1.2 (mu=144.5, sd=500, n=1e6, eq=+/-2) ===\n")
mu4<-144.5; sd4<-500; n4<-1e6
# eq bounds in raw units [mu-2, mu+2]
lo4b <- mu4-2; hi4b <- mu4+2
se4 <- sd4/sqrt(n4); tcrit4 <- qt(0.975,n4-1)
sgpvs <- numeric(4); tails <- numeric(4)
for (k in 1:4) {
  m4 <- 146 - (k-1)*0.1
  lb4 <- m4 - tcrit4*se4; ub4 <- m4 + tcrit4*se4
  sgpvs[k] <- p_delta(lb4, ub4, lo4b, hi4b)
}
# tail probability more extreme than upper bound of 2 (mean-diff units), sd=0.5
diffmeans <- c(1.5,1.4,1.3,1.2)
tails <- 1 - pnorm(2, diffmeans, 0.5)
cat(sprintf("SGPV A-D: %.2f %.2f %.2f %.2f   (paper: 0.76 0.81 0.86 0.91)\n", sgpvs[1],sgpvs[2],sgpvs[3],sgpvs[4]))
cat(sprintf("diffs A-B=%.2f C-D=%.2f (paper both -0.05)\n", sgpvs[1]-sgpvs[2], sgpvs[3]-sgpvs[4]))
cat(sprintf("tail p A-D: %.2f %.2f %.2f %.2f   (paper: 0.16 0.12 0.08 0.05)\n", tails[1],tails[2],tails[3],tails[4]))
cat(sprintf("tail diffs A-B=%.2f C-D=%.2f (paper 0.04 vs 0.03)\n", tails[1]-tails[2], tails[3]-tails[4]))
for(k in 1:4){out(c("C9",sprintf("Fig4 SGPV %d",k), c("0.76","0.81","0.86","0.91")[k], sprintf("%.2f",sgpvs[k]), ifelse(abs(sgpvs[k]-c(0.76,0.81,0.86,0.91)[k])<0.005,"OK","CHECK")))}
for(k in 1:4){out(c("C10",sprintf("Fig4 tail p %d",k), c("0.16","0.12","0.08","0.05")[k], sprintf("%.2f",tails[k]), ifelse(abs(tails[k]-c(0.16,0.12,0.08,0.05)[k])<0.005,"OK","CHECK")))}
out(c("C9","Fig4 diff A-B/C-D overlap","-0.05 / -0.05", sprintf("%.2f / %.2f",sgpvs[1]-sgpvs[2],sgpvs[3]-sgpvs[4]),
     ifelse(abs((sgpvs[1]-sgpvs[2])-(sgpvs[3]-sgpvs[4]))<0.001,"OK","CHECK")))
out(c("C10","Fig4 diff A-B/C-D tail","0.04 / 0.03", sprintf("%.2f / %.2f",tails[1]-tails[2],tails[3]-tails[4]),
     ifelse(abs((tails[1]-tails[2])-(tails[3]-tails[4]))>0.001,"OK","CHECK")))

# ================= CORRELATION CIs =================
cat("\n=== CORRELATION CIs via Fisher z ===\n")
fz <- function(r) 0.5*log((1+r)/(1-r))
iz <- function(z) tanh(z)
# n=10
for (r in c(0,0.7)) {
  z <- fz(r); sez <- 1/sqrt(7); zc <- 1.96*sez
  lb <- iz(z-zc); ub <- iz(z+zc)
  cat(sprintf("n=10 r=%.1f: 95%%CI=[%.2f, %.2f]\n", r, lb, ub))
  if(r==0){out(c("C13","CI r=0 n=10","[-0.63, 0.63]",sprintf("[%.2f, %.2f]",lb,ub), ifelse(abs(lb+0.63)<0.01 & abs(ub-0.63)<0.01,"OK","CHECK")))}
  if(r==0.7){out(c("C13","CI r=0.7 n=10","[0.13, 0.92]",sprintf("[%.2f, %.2f]",lb,ub), ifelse(abs(lb-0.13)<0.01 & abs(ub-0.92)<0.01,"OK","CHECK")))}
}
# n=30, r=0.45
r<-0.45; n<-30; z<-fz(r); sez<-1/sqrt(27); zc<-1.96*sez
lb<-iz(z-zc); ub<-iz(z+zc)
cat(sprintf("n=30 r=0.45: 95%%CI=[%.2f, %.2f]  (paper 0.11 to 0.70)\n", lb, ub))
out(c("C15","CI r=0.45 n=30","[0.11, 0.70]",sprintf("[%.2f, %.2f]",lb,ub), ifelse(abs(lb-0.11)<0.01 & abs(ub-0.70)<0.01,"OK","CHECK")))
s_045 <- p_delta(lb, ub, -0.45, 0.45)
cat(sprintf("SGPV overlap r=0.45 eq[-.45,.45]: %.4f (paper 58.11%%)\n", 100*s_045))
out(c("C15","SGPV r=0.45 overlap","58.11%", sprintf("%.2f%%",100*s_045), ifelse(abs(100*s_045-58.11)<0.2,"OK","CHK-NEAR")))

# ================= Figure 12 : n=30, r=-.45/0/.45 overlap > 50% =================
for (r in c(-0.45,0,0.45)){
  z<-fz(r); sez<-1/sqrt(27); zc<-1.96*sez
  lb<-iz(z-zc); ub<-iz(z+zc); ov<-p_delta(lb,ub,-0.45,0.45)
  cat(sprintf("n=30 r=%.2f CI=[%.2f,%.2f] overlap=%.2f%% (claim >50 when r=+/-.45)\n",r,lb,ub,100*ov))
}
out(c("C15","Fig12 overlaps r=+/-.45 > 50%","TRUE", sprintf("r-.45=%.1f%% r.45=%.1f%%",100*p_delta(iz(fz(-.45)-zc),iz(fz(-.45)+zc),-.45,.45),100*s_045),
     ifelse(s_045>0.5,"OK","CHECK")))

# ================= extreme case n=4, r=0.99, eq [-.99,.99] =================
cat("\n=== extreme case: n=4, true r=0.99, eq[-0.99,0.99] (Blume) ===\n")
r<-0.99; n<-4; z<-fz(r); sez<-1/sqrt(n-3); zcrit<-qnorm(0.975)
zl<-z-zcrit*sez; zu<-z+zcrit*sez
rl<-iz(zl); ru<-iz(zu)
cat(sprintf("99%%CI in r: [%.4f, %.4f]\n", rl, ru))
# CI upper truncated at 1 for correlation
s_ext <- p_delta(max(rl,-0.99), min(ru,1), -0.99, 0.99)
cat(sprintf("SGPV overlap: %.2f%%  (paper 97.60%%)\n", 100*s_ext))
out(c("C16","extreme SGPV overlap","97.60%", sprintf("%.2f%%",100*s_ext), ifelse(abs(100*s_ext-97.60)<0.5,"OK-NEAR","CHECK")))
cat("(value 97.60 from Blume et al 2018; exact depends on CI truncation handling)\n")

# ================= Figure 6/7 : n=10, sd=2, eq[-0.4,0.4] =================
cat("\n=== Fig6/7: n=10, sd=2, eq[-0.4,0.4]; SGPV=0.5 range, TOST p never <0.05 ===\n")
n<-10; sd<-2; loE<--0.4; hiE<-0.4; mu0<-0
seV<-sd/sqrt(n); tcritV<-qt(0.975,n-1); ciw<-2*tcritV*seV
cat(sprintf("CI width=%.3f eq width=0.8 ratio=%.2f (>2 => SGPV=0.5 correction)\n", ciw, ciw/0.8))
gr <- seq(-2,2,0.01); gr2<-seq(-1.03,1.03,0.01); tostmin<-1
const67<-TRUE; prev<-NA
for (m in gr2){
  p<-tost_p_onesample(m,mu0,n,sd,loE,hiE); if(p<tostmin)tostmin<-p
  s<-p_delta(m-tcritV*seV,m+tcritV*seV,loE,hiE)
  if(!is.na(prev)&&abs(s-prev)>1e-9) const67<-FALSE; prev<-s
}
cat(sprintf("min TOST p over means=%.4f (claim: never <0.05 -> OK if >=0.05)\n", tostmin))
cat(sprintf("Fig6/7 SGPV constant @0.5 across plateau (-1.03..1.03): %s, value=%.3f\n", const67, prev))
out(c("C11","Fig6/7 min TOST p >= 0.05", "TRUE", sprintf("%.4f",tostmin), ifelse(tostmin>=0.05,"OK","CHECK")))
out(c("C11","Fig6/7 SGPV plateau 0.5", "0.5", sprintf("const=%s val=%.3f",const67,prev), ifelse(const67 & abs(prev-0.5)<0.001,"OK","CHECK")))

# ================= Figure 9/10 : n=10, sd=1, eq[-0.4,0.4] =================
cat("\n=== Fig9/10: n=10, sd=1, eq[-0.4,0.4]; ratio 1.79, SGPV=0.56 plateau ===\n")
sd<-1; seV<-sd/sqrt(n); ciw<-2*tcritV*seV
cat(sprintf("CI width=%.3f eq width=0.8 ratio=%.3f (paper 1.79)\n", ciw, ciw/0.8))
out(c("C12","Fig8 CI/eq width ratio","1.79", sprintf("%.3f",ciw/0.8), ifelse(abs(ciw/0.8-1.79)<0.01,"OK","CHECK")))
# plateau value where CI overlaps BOTH bounds
s_plateau <- p_delta(0 - tcritV*seV, 0 + tcritV*seV, loE, hiE)
cat(sprintf("SGPV at mean 0 = %.3f (paper 0.56)\n", s_plateau))
# find range of means over which SGPV is constant & overlaps both bounds
mLow <- hiE - tcritV*seV      # lower plateau edge (-0.3157)
mHigh <- -mLow                # upper plateau edge (0.3157)
cat(sprintf("plateau mean range: (%.3f, %.3f)\n", mLow, mHigh))
rng2 <- seq(mLow+0.001, mHigh-0.001, 0.001); const<-TRUE; prev<-NA
for(m in rng2){ s<-p_delta(m-tcritV*seV,m+tcritV*seV,loE,hiE); if(!is.na(prev)&&abs(s-prev)>1e-9)const<-FALSE; prev<-s}
cat(sprintf("SGPV constant across plateau (%.2f..%.2f): %s, value=%.3f\n", mLow, mHigh, const, prev))
out(c("C12","Fig9/10 SGPV plateau ~0.56","0.56", sprintf("%.3f",s_plateau), ifelse(abs(s_plateau-0.56)<0.01,"OK","CHECK")))
out(c("C12","Fig9/10 SGPV constant range","TRUE", "", ifelse(const,"OK","CHECK")))

# ================= Critical r reference SGPV consistency =================
cat("\n=== author p_delta vs paper formula consistency (50 random CIs) ===\n")
agree<-0; N<-50
for(i in 1:N){ lb<-runif(1,-3,-1); ub<-runif(1,1,3); dlb<-runif(1,-2,0); dub<-runif(1,0,2)
  a<-sgpv_formula(lb,ub,dlb,dub); b<-p_delta(lb,ub,dlb,dub)
  if(abs(a-b)<1e-9) agree<-agree+1 }
cat(sprintf("formula==author p_delta: %d/%d agree\n", agree, N))
out(c("C1","sgpv_formula==p_delta","identical", sprintf("%d/%d",agree,N), ifelse(agree==N,"OK","CHECK")))

cat("\n==== R DONE ====\n")
