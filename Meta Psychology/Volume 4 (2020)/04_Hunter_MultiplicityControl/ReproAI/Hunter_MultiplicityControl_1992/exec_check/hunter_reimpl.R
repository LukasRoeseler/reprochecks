# ReproAI independent reimplementation
# Hunter et al. (2020), MP.2019.1992, "Multiplicity Control vs Replication"
# Author code is NOT in the public OSF project (empty storage; source node private).
# Per ReproAI standards + per-paper brief (simulated-data papers), the simulation is
# reimplemented INDEPENDENTLY from the fully-specified design in the paper:
#   - one-way independent groups; n = 25 or 100 per group
#   - J = 4 (T=6 comparisons) or J = 7 (T=21 comparisons)
#   - population SD = 20 (fixed)
#   - mean structures: complete null / partial null / complete non-null
#   - MCPs: no control, Bonferroni, Holm
#   - replications R = 0, 1, 2
#   - meta-analytic combination variant (fixed-effect inverse-variance weighted)
#   - 5000 simulations per condition; alpha = 0.05; epsilon (Cohen d) = 0.3
# Engine note: random seed NOT reported by the authors -> we fix our own and quantify
# sampling drift by running a second independent seed for the FWER tables.

set.seed(20260914)

alpha   <- 0.05
eps     <- 0.30
Nsim    <- 5000
nvars   <- c(25, 100)
njs     <- c(4, 7)
sds     <- 20

mean_structs <- list(
  null4    = c(0,0,0,0),
  partial4 = c(0,0,0,8),
  nonnull4 = c(0,8,16,24),
  null7    = c(0,0,0,0,0,0,0),
  partial7 = c(0,0,0,0,0,0,8),
  nonnull7 = c(0,8,16,24,32,40,48)
)

# which pairwise comparisons are true-null for a given mean vector
null_pairs <- function(mu) {
  J <- length(mu)
  pr <- combn(J, 2)
  idx <- apply(pr, 2, function(p) mu[p[1]] == mu[p[2]])
  list(true_null = which(idx), non_null = which(!idx), pairs = pr)
}

# per-comparison stat on a single simulated dataset (matrix of groups)
pair_stats <- function(dat) {
  J <- ncol(dat); n <- nrow(dat)
  pr <- combn(J, 2)
  T <- ncol(pr)
  p  <- numeric(T); dd <- numeric(T)
  for (k in 1:T) {
    a <- dat[, pr[1,k]]; b <- dat[, pr[2,k]]
    ma <- mean(a); mb <- mean(b)
    va <- var(a); vb <- var(b)
    sp <- sqrt(((n-1)*va + (n-1)*vb)/(2*n-2))
    if (sp == 0) sp <- 1e-12
    tstat <- (ma - mb)/(sp*sqrt(2/n))
    dfree <- 2*n - 2
    p[k]  <- 2*pt(-abs(tstat), dfree)
    dd[k] <- (ma - mb)/sp   # signed Cohen's d
  }
  list(p = p, d = dd, pairs = pr, T = T)
}

# Holm-adjusted significant set given full p-vector
holm_sig <- function(pv, alpha) {
  T <- length(pv)
  ord <- order(pv)
  rej <- rep(FALSE, T)
  for (i in 1:T) {
    if (pv[ord[i]] <= alpha/(T - i + 1)) rej[ord[i]] <- TRUE else break
  }
  rej
}

# fixed-effect inverse-variance meta of standardized mean diff (Cohen's d) across studies
meta_sig <- function(d_list, n, alpha) {
  S <- length(d_list)
  y <- numeric(S); w <- numeric(S)
  for (k in 1:S) {
    dd <- d_list[[k]]
    y[k] <- dd
    v <- 2/n + dd^2/(4*n)     # Var(d) approx = (n1+n2)/(n1*n2) + d^2/(2*(n1+n2)); equal n
    w[k] <- 1/max(v, 1e-12)
  }
  comb <- sum(w*y)/sum(w)
  se <- sqrt(1/sum(w))
  z <- comb/se
  2*pnorm(-abs(z)) < alpha
}

# ---- generate one dataset list (orig + up to 2 replications) ----
make_studies <- function(n, mu) {
  J <- length(mu)
  draw <- function() {
    m <- matrix(rnorm(n*J, mean = rep(mu, each = n), sd = sds), nrow = n, ncol = J)
    m
  }
  list(orig = draw(), r1 = draw(), r2 = draw())
}

# Given per-comparison significance for each study (matrix: comparisons x studies),
# returns significance-with-replication: comparison sig iff sig in orig AND in all required reps
sig_across <- function(mat, R) {
  # mat: T x (1+Rmax); cols are orig,r1,r2 (r1/r2 may be unused)
  k <- R + 1
  apply(mat[, 1:k, drop = FALSE], 1, all)
}

# evaluate one (n,J,meanstruct) config; returns list of numeric rates
eval_cell <- function(n, mu) {
  np <- null_pairs(mu)
  T  <- ncol(np$pairs)
  nullI <- np$true_null
  nonI  <- np$non_null
  nreps <- 3   # indices 1=orig,2=r1,3=r2
  res_fwer <- matrix(NA, nrow = Nsim, ncol = 11)
  colnames(res_fwer) <- c("NoC_R0","Bonf_R0","Holm_R0",
                          "NoC_R1","Bonf_R1","Holm_R1","Meta_R1",
                          "NoC_R2","Bonf_R2","Holm_R2","Meta_R2")
  res_pp  <- res_fwer  # per-pair power (over non-null)
  res_ap  <- res_fwer  # all-pairs power

  for (s in 1:Nsim) {
    st <- make_studies(n, mu)
    sts <- lapply(1:nreps, function(k) pair_stats(st[[k]]))
    # significance matrices across studies for each MCP
    sigNoC <- sapply(sts, function(x) x$p < alpha)
    sigBonf<- sapply(sts, function(x) x$p < alpha/T)
    sigHolm<- sapply(sts, function(x) holm_sig(x$p, alpha))
    metaSig1 <- sapply(1:T, function(k) meta_sig(list(sts[[1]]$d[k], sts[[2]]$d[k]), n, alpha))
    metaSig2 <- sapply(1:T, function(k) meta_sig(list(sts[[1]]$d[k], sts[[2]]$d[k], sts[[3]]$d[k]), n, alpha))

    # FWER
    # no-rep: any true-null significant
    res_fwer[s,"NoC_R0"]  <- any(sigNoC[nullI,1])
    res_fwer[s,"Bonf_R0"] <- any(sigBonf[nullI,1])
    res_fwer[s,"Holm_R0"] <- any(sigHolm[nullI,1])
    # R=1: any true-null significant in orig AND r1
    res_fwer[s,"NoC_R1"]  <- any(sig_across(sigNoC, 1)[nullI])
    res_fwer[s,"Bonf_R1"] <- any(sig_across(sigBonf, 1)[nullI])
    res_fwer[s,"Holm_R1"] <- any(sig_across(sigHolm, 1)[nullI])
    res_fwer[s,"Meta_R1"] <- any(metaSig1[nullI])
    # R=2
    res_fwer[s,"NoC_R2"]  <- any(sig_across(sigNoC, 2)[nullI])
    res_fwer[s,"Bonf_R2"] <- any(sig_across(sigBonf, 2)[nullI])
    res_fwer[s,"Holm_R2"] <- any(sig_across(sigHolm, 2)[nullI])
    res_fwer[s,"Meta_R2"] <- any(metaSig2[nullI])

    # Power (non-null comparisons)
    if (length(nonI) > 0) {
      # per-pair: fraction of non-null significant; all-pairs: all non-null significant
      pp_no0 <- mean(sigNoC[nonI,1]); ap_no0 <- all(sigNoC[nonI,1])
      pp_b0  <- mean(sigBonf[nonI,1]); ap_b0  <- all(sigBonf[nonI,1])
      pp_h0  <- mean(sigHolm[nonI,1]); ap_h0  <- all(sigHolm[nonI,1])
      x1 <- sig_across(sigNoC,1); pp_no1 <- mean(x1[nonI]); ap_no1 <- all(x1[nonI])
      x1b<- sig_across(sigBonf,1); pp_b1 <- mean(x1b[nonI]); ap_b1 <- all(x1b[nonI])
      x1h<- sig_across(sigHolm,1); pp_h1 <- mean(x1h[nonI]); ap_h1 <- all(x1h[nonI])
      x1m<- metaSig1; pp_m1 <- mean(x1m[nonI]); ap_m1 <- all(x1m[nonI])
      x2 <- sig_across(sigNoC,2); pp_no2 <- mean(x2[nonI]); ap_no2 <- all(x2[nonI])
      x2b<- sig_across(sigBonf,2); pp_b2 <- mean(x2b[nonI]); ap_b2 <- all(x2b[nonI])
      x2h<- sig_across(sigHolm,2); pp_h2 <- mean(x2h[nonI]); ap_h2 <- all(x2h[nonI])
      x2m<- metaSig2; pp_m2 <- mean(x2m[nonI]); ap_m2 <- all(x2m[nonI])
      res_pp[s,] <- c(pp_no0,pp_b0,pp_h0,pp_no1,pp_b1,pp_h1,pp_m1,pp_no2,pp_b2,pp_h2,pp_m2)
      res_ap[s,] <- c(ap_no0,ap_b0,ap_h0,ap_no1,ap_b1,ap_h1,ap_m1,ap_no2,ap_b2,ap_h2,ap_m2)
    } else {
      res_pp[s,] <- NA; res_ap[s,] <- NA
    }
  }
  list(fwer = colMeans(res_fwer),
       pp   = if (length(nonI)>0) colMeans(res_pp, na.rm=TRUE) else rep(NA,11),
       ap   = if (length(nonI)>0) colMeans(res_ap, na.rm=TRUE) else rep(NA,11))
}

cat("==== START (status: OK) ====\n")
cat("Engine: anomalyco/opencode (ReproAI) - DeepSeek V4 Flash via uniGPT\n")
cat("R:", R.version.string, "\n")
cat("Seed: 20260914 ; Simulations/condition:", Nsim, "\n")

cfg <- expand.grid(n = nvars, J = njs)
results <- list()

for (i in 1:nrow(cfg)) {
  n <- cfg$n[i]; J <- cfg$J[i]
  if (J == 4) {
    ms <- list(null = mean_structs$null4, partial = mean_structs$partial4, nonnull = mean_structs$nonnull4)
  } else {
    ms <- list(null = mean_structs$null7, partial = mean_structs$partial7, nonnull = mean_structs$nonnull7)
  }
  for (mnm in names(ms)) {
    key <- paste0("n", n, "_J", J, "_", mnm)
    cat("Running", key, "...\n")
    results[[key]] <- eval_cell(n, ms[[mnm]])
  }
}

outdir <- "output"
if (!dir.exists(outdir)) dir.create(outdir)

# ---- Build comparison tables against manuscript (Tables 3-6) ----
# Table 3 (FWER, 4 groups, T=6): rows = method, cols under no/one/two replication; mu complete/partial null; n 25/100
tab3 <- data.frame(
  n=rep(c(25,100), each=2), mu=rep(c("null","partial"),2),
  Bonf_R0=NA, Holm_R0=NA, NoC_R0=NA,
  Bonf_R1=NA, Holm_R1=NA, NoC_R1=NA, Meta_R1=NA,
  Bonf_R2=NA, Holm_R2=NA, NoC_R2=NA, Meta_R2=NA,
  stringsAsFactors=FALSE
)
tab4 <- tab3
tab3$mu <- c("null","partial","null","partial")
for (i in 1:nrow(tab3)) {
  key <- paste0("n", tab3$n[i], "_J4_", tab3$mu[i])
  f <- results[[key]]$fwer
  tab3[i, 3:13] <- round(f[c("Bonf_R0","Holm_R0","NoC_R0","Bonf_R1","Holm_R1","NoC_R1","Meta_R1","Bonf_R2","Holm_R2","NoC_R2","Meta_R2")], 3)
}
write.csv(tab3, file.path(outdir, "table3_fwer_4groups_reimpl.csv"), row.names=FALSE)

tab4$mu <- c("null","partial","null","partial")
for (i in 1:nrow(tab4)) {
  key <- paste0("n", tab4$n[i], "_J7_", tab4$mu[i])
  f <- results[[key]]$fwer
  tab4[i, 3:13] <- round(f[c("Bonf_R0","Holm_R0","NoC_R0","Bonf_R1","Holm_R1","NoC_R1","Meta_R1","Bonf_R2","Holm_R2","NoC_R2","Meta_R2")], 3)
}
write.csv(tab4, file.path(outdir, "table4_fwer_7groups_reimpl.csv"), row.names=FALSE)

# Tables 5 & 6 power (per-pair PP, all-pairs AP)
mk_pow <- function(J, label) {
  nrows <- 4
  df <- data.frame(n=rep(c(25,100), each=2), J=J, mu=rep(c("partial","nonnull"),2),
                   NoRepl_Bonf_PP=NA, NoRepl_Bonf_AP=NA, NoRepl_Holm_PP=NA, NoRepl_Holm_AP=NA,
                   NoRepl_NoC_PP=NA, NoRepl_NoC_AP=NA,
                   OneRep_Bonf_PP=NA, OneRep_Bonf_AP=NA, OneRep_Holm_PP=NA, OneRep_Holm_AP=NA,
                   OneRep_NoC_PP=NA, OneRep_NoC_AP=NA, OneRep_Meta_PP=NA, OneRep_Meta_AP=NA,
                   TwoRep_Bonf_PP=NA, TwoRep_Bonf_AP=NA, TwoRep_Holm_PP=NA, TwoRep_Holm_AP=NA,
                   TwoRep_NoC_PP=NA, TwoRep_NoC_AP=NA, TwoRep_Meta_PP=NA, TwoRep_Meta_AP=NA,
                   stringsAsFactors=FALSE)
  ri <- 0
  for (nn in c(25,100)) for (mm in c("partial","nonnull")) {
    ri <- ri+1
    key <- paste0("n",nn,"_J",J,"_",mm)
    pp <- results[[key]]$pp; ap <- results[[key]]$ap
    df$NoRepl_Bonf_PP[ri]<-pp["Bonf_R0"]; df$NoRepl_Bonf_AP[ri]<-ap["Bonf_R0"]
    df$NoRepl_Holm_PP[ri]<-pp["Holm_R0"]; df$NoRepl_Holm_AP[ri]<-ap["Holm_R0"]
    df$NoRepl_NoC_PP[ri] <-pp["NoC_R0"];  df$NoRepl_NoC_AP[ri] <-ap["NoC_R0"]
    df$OneRep_Bonf_PP[ri]<-pp["Bonf_R1"]; df$OneRep_Bonf_AP[ri]<-ap["Bonf_R1"]
    df$OneRep_Holm_PP[ri]<-pp["Holm_R1"]; df$OneRep_Holm_AP[ri]<-ap["Holm_R1"]
    df$OneRep_NoC_PP[ri] <-pp["NoC_R1"];  df$OneRep_NoC_AP[ri] <-ap["NoC_R1"]
    df$OneRep_Meta_PP[ri]<-pp["Meta_R1"]; df$OneRep_Meta_AP[ri]<-ap["Meta_R1"]
    df$TwoRep_Bonf_PP[ri]<-pp["Bonf_R2"]; df$TwoRep_Bonf_AP[ri]<-ap["Bonf_R2"]
    df$TwoRep_Holm_PP[ri]<-pp["Holm_R2"]; df$TwoRep_Holm_AP[ri]<-ap["Holm_R2"]
    df$TwoRep_NoC_PP[ri] <-pp["NoC_R2"];  df$TwoRep_NoC_AP[ri] <-ap["NoC_R2"]
    df$TwoRep_Meta_PP[ri]<-pp["Meta_R2"]; df$TwoRep_Meta_AP[ri]<-ap["Meta_R2"]
  }
  df
}
tab5 <- mk_pow(4, "table5")
tab6 <- mk_pow(7, "table6")
write.csv(tab5, file.path(outdir, "table5_power_4groups_reimpl.csv"), row.names=FALSE)
write.csv(tab6, file.path(outdir, "table6_power_7groups_reimpl.csv"), row.names=FALSE)

# Cohen's d Tables 7 & 8
# Table 7: Proportion of incorrect statements re magnitude of d:
#   false conclusion d>=eps when population d (for that comparison) = 0
#   averaged over the null comparisons (all comparisons under complete null are null;
#   under partial null, the between-equal-groups comparisons are null)
eval_d <- function(n, mu, Rmax=3) {
  np <- null_pairs(mu)
  nullI <- np$true_null
  T <- ncol(np$pairs)
  # incorrect rate = fraction of sims where any null comparison has |obs d| >= eps across orig+reps (persist)
  res <- matrix(NA, nrow=Nsim, ncol=3)  # R0,R1,R2 (for "no rep" uses orig only)
  for (s in 1:Nsim) {
    st <- make_studies(n, mu)
    ds <- lapply(1:3, function(k) abs(pair_stats(st[[k]])$d))
    res[s,1] <- any(ds[[1]][nullI] >= eps)
    res[s,2] <- any(ds[[1]][nullI] >= eps & ds[[2]][nullI] >= eps)
    res[s,3] <- any(ds[[1]][nullI] >= eps & ds[[2]][nullI] >= eps & ds[[3]][nullI] >= eps)
  }
  colMeans(res)
}

tab7 <- expand.grid(n=c(25,100), J=c(4,7), mu=c("null","partial"))
tab7$NoRep <- NA; tab7$OneRep <- NA; tab7$TwoRep <- NA
for (i in 1:nrow(tab7)) {
  key <- paste0("n", tab7$n[i], "_J", tab7$J[i], "_", tab7$mu[i])
  mu <- if (tab7$J[i]==4) (if(tab7$mu[i]=="null") mean_structs$null4 else mean_structs$partial4)
        else (if(tab7$mu[i]=="null") mean_structs$null7 else mean_structs$partial7)
  r <- eval_d(tab7$n[i], mu)
  tab7$NoRep[i] <- round(r[1],3); tab7$OneRep[i]<-round(r[2],3); tab7$TwoRep[i]<-round(r[3],3)
}
write.csv(tab7, file.path(outdir, "table7_d_incorrect_reimpl.csv"), row.names=FALSE)

# Table 8: APC/PAC for d (non-null comparisons where pop |d| >= eps)
eval_apc <- function(n, mu) {
  np <- null_pairs(mu)
  nonI <- np$non_null
  res <- matrix(NA, nrow=Nsim, ncol=6) # APC0,PAC0,APC1,PAC1,APC2,PAC2
  cn <- if (length(nonI)>0) nonI else integer(0)
  for (s in 1:Nsim) {
    st <- make_studies(n, mu)
    ds <- lapply(1:3, function(k) abs(pair_stats(st[[k]])$d))
    if (length(cn)==0) { res[s,] <- 0; next }
    # R0 (no replication): correct if non-null d >= eps in orig
    a0 <- ds[[1]][cn] >= eps
    ap0 <- mean(a0); ac0 <- all(a0)
    a1 <- ds[[1]][cn] >= eps & ds[[2]][cn] >= eps
    ap1 <- mean(a1); ac1 <- all(a1)
    a2 <- ds[[1]][cn] >= eps & ds[[2]][cn] >= eps & ds[[3]][cn] >= eps
    ap2 <- mean(a2); ac2 <- all(a2)
    res[s,] <- c(ap0,ac0,ap1,ac1,ap2,ac2)
  }
  colMeans(res)
}
tab8 <- expand.grid(n=c(25,100), J=c(4,7), mu=c("partial","nonnull"))
tab8$APC0<-tab8$PAC0<-tab8$APC1<-tab8$PAC1<-tab8$APC2<-tab8$PAC2<-NA
for (i in 1:nrow(tab8)) {
  mu <- if (tab8$J[i]==4) (if(tab8$mu[i]=="partial") mean_structs$partial4 else mean_structs$nonnull4)
        else (if(tab8$mu[i]=="partial") mean_structs$partial7 else mean_structs$nonnull7)
  r <- eval_apc(tab8$n[i], mu)
  tab8$APC0[i]<-round(r[1],3);tab8$PAC0[i]<-round(r[2],3)
  tab8$APC1[i]<-round(r[3],3);tab8$PAC1[i]<-round(r[4],3)
  tab8$APC2[i]<-round(r[5],3);tab8$PAC2[i]<-round(r[6],3)
}
write.csv(tab8, file.path(outdir, "table8_d_power_reimpl.csv"), row.names=FALSE)

# ---- drift check: rerun FWER (Table 3, key cells) with a second seed ----
set.seed(987654321)
drift <- list()
for (nn in c(25,100)) for (mm in c("null","partial")) {
  key <- paste0("n",nn,"_J4_",mm)
  drift[[key]] <- eval_cell(nn, if(mm=="null") mean_structs$null4 else mean_structs$partial4)$fwer
}
saveRDS(drift, file.path(outdir, "drift_seed2_fwer_4groups.rds"))

cat("==== END (status: OK) ====\n")
