# 03_metrics_from_shipped.R
# Verify remaining load-bearing quantitative claims from the SHIPPED meta_results file.
# - C8/C21: logistic mapping of true effect e to probability (already analytic)
# - Effect-size estimates: mean estimate per method, per (e, var) -> does ANOVA underestimate at high var/high e?
# - PP vs meta-BGLMM convergence (near-identical)
# - GLMM vs BGLMM estimates (near-identical)
# - True-positive rate (e>0) increases with e; ANOVA/GLMM/BGLMM decrease with var, PP stable
# - Uncertainty (CI width) patterns
res <- file.path("..","code_author","Results","meta_results_18_09_16.txt")
d <- read.delim(res, check.names=FALSE)
es <- c(0,0.5,1,1.5,2); vs <- c(0,0.25,0.5,0.75,1)
getm <- function(col, e, v){ mean(d[[col]][d$meta_true_sex_cond==e & d$meta_var_base==v], na.rm=TRUE) }

cat("=== A) Mean effect estimate per method (log-odds), by (e x var) ===\n")
for (m in c("meta_sex_cond_estimate_anova","meta_sex_cond_estimate_glmm",
            "meta_sex_cond_estimate_bglmm","meta_sex_cond_estimate_pp","meta_sex_cond_estimate_mega_bglmm")) {
  cat("\n--", m, "--\n")
  for (v in vs) {
    vals <- sapply(es, function(e) getm(m, e, v))
    cat(sprintf("  var=%.2f | e=0:%.3f e=.5:%.3f e=1:%.3f e=1.5:%.3f e=2:%.3f\n", v,
                vals[1], vals[2], vals[3], vals[4], vals[5]))
  }
}

cat("\n=== B) PP vs meta-BGLMM: near-identical? ===\n")
cat("cor(pp, mega):", round(cor(d$meta_sex_cond_estimate_pp, d$meta_sex_cond_estimate_mega_bglmm, use="complete.obs"),4), "\n")
cat("mean|pp - mega|:", round(mean(abs(d$meta_sex_cond_estimate_pp - d$meta_sex_cond_estimate_mega_bglmm), na.rm=TRUE),4), "\n")
cat("mean|glmm - bglmm|:", round(mean(abs(d$meta_sex_cond_estimate_glmm - d$meta_sex_cond_estimate_bglmm), na.rm=TRUE),4), "\n")
cat("mean|glmm - anova|:", round(mean(abs(d$meta_sex_cond_estimate_glmm - d$meta_sex_cond_estimate_anova), na.rm=TRUE),4), "\n")

cat("\n=== C) ANOVA underestimation: mean estimate - true e, e=2 (highest) ===\n")
for (m in c("meta_sex_cond_estimate_anova","meta_sex_cond_estimate_glmm","meta_sex_cond_estimate_pp")) {
  cat("\n", m, " (e=2):\n")
  for (v in vs) {
    cat(sprintf("   var=%.2f  mean_est=%.3f  delta_from_2=%+.3f\n", v, getm(m,2,v), getm(m,2,v)-2))
  }
}

cat("\n=== D) True-positive rate (e>0) by (e x var) ===\n")
for (m in c("meta_sex_cond_positive_rate_anova","meta_sex_cond_positive_rate_glmm",
            "meta_sex_cond_positive_rate_pp")) {
  cat("\n--", m, "--\n")
  for (v in vs) {
    vals <- sapply(es, function(e) getm(m, e, v))
    cat(sprintf("  var=%.2f | e=0:%.3f e=.5:%.3f e=1:%.3f e=1.5:%.3f e=2:%.3f\n", v,
                vals[1], vals[2], vals[3], vals[4], vals[5]))
  }
}

cat("\n=== E) Uncertainty (95% CI/credible width) mean by method (overall) ===\n")
for (m in c("meta_sex_cond_uncertainty_anova","meta_sex_cond_uncertainty_glmm",
            "meta_sex_cond_uncertainty_bglmm","meta_sex_cond_uncertainty_pp","meta_sex_cond_uncertainty_mega_bglmm")) {
  cat(m, " overall mean:", round(mean(d[[m]], na.rm=TRUE),4), "\n")
}
cat("\nPP uncertainty by (e x var):\n")
for (v in vs) {
  vals <- sapply(es, function(e) getm("meta_sex_cond_uncertainty_pp", e, v))
  cat(sprintf("  var=%.2f | e=0:%.3f e=.5:%.3f e=1:%.3f e=1.5:%.3f e=2:%.3f\n", v, vals[1], vals[2], vals[3], vals[4], vals[5]))
}
