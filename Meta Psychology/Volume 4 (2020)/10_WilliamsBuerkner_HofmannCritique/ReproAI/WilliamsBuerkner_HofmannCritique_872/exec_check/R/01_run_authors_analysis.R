suppressMessages(require(metafor))
options(width=250)

cat("==== START (status: running) ====\n")
cat("R ", R.version.string, "\n")
cat("metafor ", as.character(packageVersion("metafor")), "\n")
cat("date: ", date(), "\n")
cat("data_file: dat.csv md5: ", tools::md5sum("dat.csv"), "\n")

# ---- Re-run the EXACT author pipeline (hofmann_analysis.R) ----
adata <- read.csv("dat.csv")
adata$ri <- 0.7

adata <- escalc(measure="SMD", m1i=oxyMean_pre, sd1i=oxySd_pre,
                n1i=oxyN, m2i=plaMean_pre, sd2i=plaSd_pre,
                n2i=plaN, data=adata, var.names = c("SMD_pre", "vSMD_pre"))
adata <- escalc(measure="SMD", m1i=oxyMean_post, sd1i=oxySd_post,
                n1i=oxyN, m2i=plaMean_post, sd2i=plaSd_post,
                n2i=plaN, data=adata, var.names = c("SMD_post", "vSMD_post"))
adata <- escalc(measure="SMCR", m1i=oxyMean_post, m2i=oxyMean_pre,
                sd1i=oxySd_pre, ni=oxyN, ri = ri,
                data=adata, var.names = c("oxySMCR", "voxySMCR"))
adata <- escalc(measure="SMCR", m1i=plaMean_post, m2i=plaMean_pre,
                sd1i=plaSd_pre, ni=plaN, ri = ri,
                data=adata, var.names = c("plaSMCR", "vplaSMCR"))
adata$SMCR <- adata$oxySMCR - adata$plaSMCR
adata$vSMCR <- adata$voxySMCR + adata$vplaSMCR

# hard-coded Averbeck row (computed from t-stat on post scores)
adata[1,19] <- -0.51
adata[1,25] <- -.51
adata[1,20] <- 0.19
adata[1,26] <- 0.19

# ---- Inspect derived effect sizes ----
es_df <- data.frame(
  name=adata$name, disorder=adata$disorder, overall=adata$overall,
  psycho_tot=adata$psycho_tot,
  SMD_post=round(adata$SMD_post,4), SMD_post_neg=round(adata$SMD_post*-1,4),
  vSMD_post=round(adata$vSMD_post,4),
  SMCR_neg=round(adata$SMCR*-1,4), vSMCR=round(adata$vSMCR,4))
write.csv(es_df, "output/derived_effect_sizes.csv", row.names=FALSE)

cat("\n---- COUNT NEGATIVE-DIRECTION OUTCOMES (of those used in overall meta-analysis) ----\n")
ov <- adata[adata$overall==1,]
cat("rows with overall==1:", nrow(ov), "\n")
cat("SMD_post*-1 < 0 count:", sum(ov$SMD_post*-1 < 0), "\n")
smcr_neg <- ov$SMCR*-1
cat("SMCR*-1 < 0 count:", sum(smcr_neg < 0), "\n")
cat("SMCR*-1 values:\n"); print(round(smcr_neg,3))
cat("SMD_post*-1 values:\n"); print(round(ov$SMD_post*-1,3))

# ---- MAIN OVERALL ----
cat("\n==== OVERALL SMCR (author code rma(SMCR*-1)) ====\n")
m.smcr <- rma(SMCR * -1, vi = vSMCR, subset=(overall==1), data=adata, slab=name)
print(summary(m.smcr)); cat("tau^2 CI:\n"); print(m.smcr$ci.lb); print(m.smcr$ci.ub)

cat("\n==== OVERALL SMD (author code rma(SMD_post*-1)) ====\n")
m.smd <- rma(SMD_post * -1, vi = vSMD_post, subset=(overall==1), data=adata, slab=name)
print(summary(m.smd)); cat("tau^2 CI:\n"); print(m.smd$ci.lb); print(m.smd$ci.ub)

# ---- MODERATOR BY DISORDER (Table 1) ----
cat("\n==== SMCR MODERATOR ~ disorder -1 (Table 1 SMCR rows) ====\n")
m.smcr.mod <- rma(SMCR * -1, vi = vSMCR, mods = ~ disorder - 1, data=adata, slab=name)
print(summary(m.smcr.mod))

cat("\n==== SMD MODERATOR ~ disorder -1 (Table 1 SMD rows) ====\n")
m.smd.mod <- rma(SMD_post * -1, vi = vSMD_post, mods = ~ disorder - 1, data=adata, slab=name)
print(summary(m.smd.mod))

# ---- ONLY TOTAL PSYCHOTIC ----
cat("\n==== SMCR subset psycho_tot==1 ====\n")
m.smcr.pt <- rma(SMCR * -1, vi = vSMCR, subset=(psycho_tot==1), data=adata, slab=name)
print(summary(m.smcr.pt))
cat("\n==== SMD subset psycho_tot==1 ====\n")
m.smd.pt <- rma(SMD_post * -1, vi = vSMD_post, subset=(psycho_tot==1), data=adata, slab=name)
print(summary(m.smd.pt))

# ---- TRIM AND FILL ----
cat("\n==== TRIMFILL SMCR (default) ====\n")
tf.smcr <- trimfill(m.smcr); print(summary(tf.smcr))
cat("\n==== TRIMFILL SMD (default) ====\n")
tf.smd <- trimfill(m.smd); print(summary(tf.smd))
cat("\n==== TRIMFILL SMD (estimator=L0 as in script for smcr) ====\n")
tf.smd.l0 <- trimfill(m.smd, estimator="L0"); print(summary(tf.smd.l0))

# ---- structured CSV table-1 capture ----
f <- function(mod, kind){
  b <- mod$b; se <- mod$se; ci.lb<-mod$ci.lb; ci.ub<-mod$ci.ub
  z <- b/se
  p <- 2*(1-pnorm(abs(z)))
  ci.lb <- as.numeric(ci.lb); ci.ub <- as.numeric(ci.ub)
  dat <- data.frame(kind=kind, level=rownames(b),
                    ES=round(as.numeric(b),4), SE=round(as.numeric(se),4),
                    z=round(as.numeric(z),4), p=signif(as.numeric(p),4),
                    ci.lb=round(ci.lb,3), ci.ub=round(ci.ub,3))
  dat
}
ci.smcr.tau2 <- confint(m.smcr.mod)$random[1, c("ci.lb","ci.ub")]
ci.smd.tau2 <- confint(m.smd.mod)$random[1, c("ci.lb","ci.ub")]
smcr.tau2 <- data.frame(kind="SMCR",level="tau^2",
   ES=round(m.smcr.mod$tau2,3), SE=round(m.smcr.mod$se.tau2,3),
   z=round(m.smcr.mod$tau2/m.smcr.mod$se.tau2,4),
   p=signif(m.smcr.mod$QEp,3),
   ci.lb=round(ci.smcr.tau2["ci.lb"],3), ci.ub=round(ci.smcr.tau2["ci.ub"],3))
smd.tau2 <- data.frame(kind="SMD",level="tau^2",
   ES=round(m.smd.mod$tau2,3), SE=round(m.smd.mod$se.tau2,3),
   z=round(m.smd.mod$tau2/m.smd.mod$se.tau2,4),
   p=signif(m.smd.mod$QEp,3),
   ci.lb=round(ci.smd.tau2["ci.lb"],3), ci.ub=round(ci.smd.tau2["ci.ub"],3))
t1 <- rbind(f(m.smcr.mod, "SMCR"), smcr.tau2, f(m.smd.mod, "SMD"), smd.tau2)
write.csv(t1, "output/table1_repro.csv", row.names=FALSE)
cat("\n==== TABLE 1 REPRO CSV ====\n"); print(t1, row.names=FALSE)

ov.smcr <- data.frame(kind="SMCR",level="overall",
  ES=round(m.smcr$b[1],4), SE=round(m.smcr$se[1],4),
  z=round(m.smcr$zval[1],4), p=signif(m.smcr$pval[1],4),
  ci.lb=round(m.smcr$ci.lb[1],3), ci.ub=round(m.smcr$ci.ub[1],3),
  tau2=round(m.smcr$tau2,4), tau2p=signif(m.smcr$QEp,4))
ov.smd <- data.frame(kind="SMD",level="overall",
  ES=round(m.smd$b[1],4), SE=round(m.smd$se[1],4),
  z=round(m.smd$zval[1],4), p=signif(m.smd$pval[1],4),
  ci.lb=round(m.smd$ci.lb[1],3), ci.ub=round(m.smd$ci.ub[1],3),
  tau2=round(m.smd$tau2,4), tau2p=signif(m.smd$QEp,4))
ov <- rbind(ov.smcr, ov.smd)
write.csv(ov, "output/overall_repro.csv", row.names=FALSE)
cat("\n==== OVERALL REPRO CSV ====\n"); print(ov, row.names=FALSE)

tf.smd.est <- data.frame(kind="SMD", level="trimfill",
  ES=round(tf.smd$b[1],4), SE=round(tf.smd$se[1],4),
  z=round(tf.smd$zval[1],4), p=signif(tf.smd$pval[1],4),
  ci.lb=round(tf.smd$ci.lb[1],3), ci.ub=round(tf.smd$ci.ub[1],3),
  missing=tf.smd$k0, k=tf.smd$k)
write.csv(tf.smd.est, "output/trimfill_repro.csv", row.names=FALSE)
cat("\n==== TRIMFILL SMD REPRO CSV ====\n"); print(tf.smd.est, row.names=FALSE)

pt <- data.frame(
  kind=c("SMCR","SMD"),
  ES=c(m.smcr.pt$b[1], m.smd.pt$b[1]),
  z=c(m.smcr.pt$zval[1], m.smd.pt$zval[1]),
  p=c(m.smcr.pt$pval[1], m.smd.pt$pval[1]))
write.csv(round(pt,4), "output/psycho_tot_repro.csv", row.names=FALSE)
cat("\n==== PSYCHO_TOT SUBSET REPRO CSV ====\n"); print(round(pt,4), row.names=FALSE)

cat("==== END (status: OK) ====\n")
