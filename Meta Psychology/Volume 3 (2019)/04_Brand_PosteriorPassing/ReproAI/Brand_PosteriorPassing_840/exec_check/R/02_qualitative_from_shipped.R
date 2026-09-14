# 02_qualitative_from_shipped.R
# Verify structural/qualitative claims from shipped meta_results:
#  - C8 effect-size -> probability mapping (logistic)
#  - C21 (e=2 -> 0.38 increase)
#  - ANOVA underestimates at high var/high effect
#  - PP & meta converge to truth; GLMM ~ BGLMM estimates
res <- file.path("..","code_author","Results","meta_results_18_09_16.txt")
d <- read.delim(res, check.names=FALSE)

cat("=== C8: logistic mapping of true effects (base 0) ===\n")
for (e in c(0,0.5,1,1.5,2)) {
  p <- 1/(1+exp(-e))
  cat(sprintf("e=%.1f -> P(correct|sex1,cond1)=%.4f; increase over 0.5 = %.4f\n", e, p, p-0.5))
}

cat("\n=== C21: e=2 -> increase 0.38? ===")
cat(sprintf(" %.4f\n", 1/(1+exp(-2))-0.5))

# Means per combo
cat("\n=== Mean sex_cond effect ESTIMATE (log-odds space) by effect & var ===\n")
cat("columns used: meta_sex_cond_estimate_anova/glmm/bglmm/pp/mega_bglmm\n")
combs <- expand.grid(var=sort(unique(d$meta_var_base)), e=sort(unique(d$meta_true_sex_cond)))
show <- function(colname, label){
  cat("\n-- ",label," --\n",sep="")
  mat <- matrix(NA, nrow=5, ncol=5, dimnames=list(paste("var",c(0,0.25,0.5,0.75,1)), paste("e",c(0,0.5,1,1.5,2))))
  for(i in 1:nrow(combs)){
    s <- d$meta_true_sex_cond==combs$e[i] & d$meta_var_base==combs$var[i]
    mat[as.character(combs$var[i]), as.character(combs$e[i])] <- mean(d[[colname]][s], na.rm=TRUE)
  }
  print(round(mat,3))
}
show("meta_sex_cond_estimate_anova","ANOVA")
show("meta_sex_cond_estimate_glmm","GLMM")
show("meta_sex_cond_estimate_bglmm","BGLMM")
show("meta_sex_cond_estimate_pp","PP (final)")

cat("\n=== PP vs meta BGLMM final estimate correlation (close to identical?) ===\n")
cat("cor(pp, mega):", cor(d$meta_sex_cond_estimate_pp, d$meta_sex_cond_estimate_mega_bglmm, use="complete.obs"), "\n")
cat("mean |pp - mega| :", mean(abs(d$meta_sex_cond_estimate_pp - d$meta_sex_cond_estimate_mega_bglmm), na.rm=TRUE), "\n")
cat("mean |glmm - bglmm| :", mean(abs(d$meta_sex_cond_estimate_glmm - d$meta_sex_cond_estimate_bglmm), na.rm=TRUE), "\n")

cat("\n=== ANOVA bias: mean estimate - truth, by var (e pooled across non-zero?) ===\n")
cat("Use e=2 row (high effect) where underestimation stated most strongly\n")
for (cname in c("meta_sex_cond_estimate_anova","meta_sex_cond_estimate_glmm","meta_sex_cond_estimate_pp","meta_sex_cond_estimate_mega_bglmm")){
  cat("\n",cname,"(e=2): mean(est)-`truth(logistic=2)` per var\n",sep="")
  for (v in c(0,0.25,0.5,0.75,1)){
    s <- d$meta_true_sex_cond==2 & d$meta_var_base==v
    cat(sprintf("  var=%.2f  mean est=%.3f  delta from 2 = %+.3f\n", v, mean(d[[cname]][s],na.rm=TRUE), mean(d[[cname]][s],na.rm=TRUE)-2))
  }
}

cat("\n=== Uncertainty (log-odds width) patterns: PP smallest? ===\n")
cat("meta_sex_cond uncertainty naming: meta_sex_cond_uncertainty_anova/glmm/bglmm/pp/mega_bglmm (log-odds)\n")
for (cname in c("meta_sex_cond_uncertainty_anova","meta_sex_cond_uncertainty_pp","meta_sex_cond_uncertainty_mega_bglmm")){
  cat(cname, " overall mean:", round(mean(d[[cname]],na.rm=TRUE),3), "\n")
}
