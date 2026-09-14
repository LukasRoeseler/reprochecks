# 02_shipped_metrics.R -- RE-AUDIT re-derivation of remaining load-bearing figures
# from the SHIPPED meta_results table (internal-consistency: results <-> paper).
# Covers: logistic mapping, ANOVA underestimation, PP~meta identity, BGLMM~GLMM,
# TPR patterns, uncertainty widths.

res <- file.path("..","code_author","Results","meta_results_18_09_16.txt")
d <- read.delim(res, check.names=FALSE)
es <- c(0,0.5,1,1.5,2); vs <- c(0,0.25,0.5,0.75,1)
getm <- function(col, e, v){ mean(d[[col]][d$meta_true_sex_cond==e & d$meta_var_base==v], na.rm=TRUE) }

cat("=== A) logistic(e) mapping (C8) ===\n")
for (e in es) cat(sprintf("  e=%.1f -> P=%.4f (increase over 0.5 = %.4f)\n", e, plogis(e), plogis(e)-0.5))
cat("  e=2 increase (Fig2 caption) =", sprintf("%.4f", plogis(2)-0.5), "\n")

cat("\n=== B) mean interaction ESTIMATE (log-odds) by method, all (e x var) ===\n")
for (m in c("meta_sex_cond_estimate_anova","meta_sex_cond_estimate_glmm",
            "meta_sex_cond_estimate_bglmm","meta_sex_cond_estimate_pp","meta_sex_cond_estimate_mega_bglmm")) {
  cat("\n--", m, "--\n")
  for (v in vs) {
    vals <- sapply(es, function(e) getm(m, e, v))
    cat(sprintf("  var=%.2f | e=0:%.3f e=.5:%.3f e=1:%.3f e=1.5:%.3f e=2:%.3f\n", v, vals[1],vals[2],vals[3],vals[4],vals[5]))
  }
}

cat("\n=== C) PP vs meta / GLMM vs BGLMM agreement (C37, C38) ===\n")
cat("cor(pp,mega) =", round(cor(d$meta_sex_cond_estimate_pp, d$meta_sex_cond_estimate_mega_bglmm, use="complete.obs"),4), "\n")
cat("mean|pp-mega| =", round(mean(abs(d$meta_sex_cond_estimate_pp - d$meta_sex_cond_estimate_mega_bglmm), na.rm=TRUE),4), "\n")
cat("mean|glmm-bglmm| =", round(mean(abs(d$meta_sex_cond_estimate_glmm - d$meta_sex_cond_estimate_bglmm), na.rm=TRUE),4), "\n")

cat("\n=== D) ANOVA underestimation at e=2 (C27) ===\n")
for (m in c("meta_sex_cond_estimate_anova","meta_sex_cond_estimate_glmm")) {
  cat(m, "(e=2):\n")
  for (v in vs) cat(sprintf("   var=%.2f  est=%.3f  delta=%+.3f\n", v, getm(m,2,v), getm(m,2,v)-2))
}

cat("\n=== E) True-positive rate by (e x var): rises with e, falls with var (ANOVA/GLMM), PP stable at e>0 (C28-30) ===\n")
for (m in c("meta_sex_cond_positive_rate_anova","meta_sex_cond_positive_rate_glmm","meta_sex_cond_positive_rate_pp")) {
  cat("\n--", m, "--\n")
  for (v in vs) {
    vals <- sapply(es, function(e) getm(m, e, v))
    cat(sprintf("  var=%.2f | e=0:%.3f e=.5:%.3f e=1:%.3f e=1.5:%.3f e=2:%.3f\n", v, vals[1],vals[2],vals[3],vals[4],vals[5]))
  }
}

cat("\n=== F) Uncertainty (95% width, log-odds) overall by method (C31-34) ===\n")
for (m in c("meta_sex_cond_uncertainty_anova","meta_sex_cond_uncertainty_glmm",
            "meta_sex_cond_uncertainty_bglmm","meta_sex_cond_uncertainty_pp","meta_sex_cond_uncertainty_mega_bglmm"))
  cat(m, " overall:", round(mean(d[[m]], na.rm=TRUE),4), "\n")
cat("\nPP uncertainty by (e x var):\n")
for (v in vs) {
  vals <- sapply(es, function(e) getm("meta_sex_cond_uncertainty_pp", e, v))
  cat(sprintf("  var=%.2f | e=0:%.3f e=.5:%.3f e=1:%.3f e=1.5:%.3f e=2:%.3f\n", v, vals[1],vals[2],vals[3],vals[4],vals[5]))
}

out <- data.frame(
  check=c("cor(pp,mega)","mean|pp-mega|","mean|glmm-bglmm|","ANOVA est e=2 var=0","ANOVA est e=2 var=1","PP uncertainty range"),
  value=c(as.character(round(cor(d$meta_sex_cond_estimate_pp,d$meta_sex_cond_estimate_mega_bglmm,use="complete.obs"),4)),
          sprintf("%.4f", mean(abs(d$meta_sex_cond_estimate_pp-d$meta_sex_cond_estimate_mega_bglmm),na.rm=TRUE)),
          sprintf("%.4f", mean(abs(d$meta_sex_cond_estimate_glmm-d$meta_sex_cond_estimate_bglmm),na.rm=TRUE)),
          sprintf("%.3f", getm("meta_sex_cond_estimate_anova",2,0)),
          sprintf("%.3f", getm("meta_sex_cond_estimate_anova",2,1)),
          sprintf("%.3f-%.3f", getm("meta_sex_cond_uncertainty_pp",0,0), getm("meta_sex_cond_uncertainty_pp",0,1))))
write.csv(out, file.path("output","shipped_metrics_key.csv"), row.names=FALSE)
cat("\nWROTE output/shipped_metrics_key.csv\n")
