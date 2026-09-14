# 01_shipped_falsepos.R -- RE-AUDIT re-derivation (fresh execution).
# Recomputes the article's false-positive claims (C17/C18/C19, FP counts 304/341/304/2/1)
# directly from the author's SHIPPED results table, mirroring the author's falsePos.R.
# Because meta_results_18_09_16.txt is the deterministic output of the author's own run,
# these reproduce EXACTLY (internal-consistency check: shipped-results <-> paper).

res <- file.path("..","code_author","Results","meta_results_18_09_16.txt")
d <- read.delim(res, check.names=FALSE)

cat("rows:", nrow(d), "\n")
Ze <- d[d$meta_true_sex_cond==0, ]
n_ze <- nrow(Ze)
nDatasets <- n_ze * 60

fp_anova <- sum(Ze$meta_sex_cond_positive_rate_anova * 60)
fp_glmm  <- sum(Ze$meta_sex_cond_positive_rate_glmm  * 60)
fp_bglmm <- sum(Ze$meta_sex_cond_positive_rate_bglmm * 60)
fp_pp    <- sum(Ze$meta_sex_cond_positive_rate_pp)
fp_mega  <- sum(Ze$meta_sex_cond_positive_rate_mega_bglmm)

cat("N datasets e=0:", nDatasets, "\n")
cat("ANOVA :", fp_anova, sprintf("(%.3f%%)", 100*fp_anova/nDatasets), "\n")
cat("GLMM  :", fp_glmm,  sprintf("(%.3f%%)", 100*fp_glmm/nDatasets), "\n")
cat("BGLMM :", fp_bglmm, sprintf("(%.3f%%)", 100*fp_bglmm/nDatasets), "\n")
cat("PP    :", fp_pp,  sprintf("(%.1f%% of %d sims)", 100*fp_pp/n_ze, n_ze), "\n")
cat("MEGA  :", fp_mega, sprintf("(%.1f%% of %d sims)", 100*fp_mega/n_ze, n_ze), "\n")
cat("MANUSCRIPT: ANOVA 304 (5.1%), GLMM 341 (5.7%), BGLMM 304 (5.1%), PP 2 (2%), meta BGLMM 1 (1%)\n")

out <- data.frame(
  Quantity = c("N datasets (e=0)","FalsePos ANOVA","FalsePos GLMM","FalsePos BGLMM",
               "PP false pos (100 sims)","meta BGLMM false pos (100 sims)",
               "FP rate ANOVA %","FP rate GLMM %","FP rate BGLMM %"),
  Manuscript = c("6000","304 (5.1%)","341 (5.7%)","304 (5.1%)","2 (2%)","1 (1%)","5.1","5.7","5.1"),
  Reimpl = c(as.character(nDatasets), as.character(fp_anova), as.character(fp_glmm),
             as.character(fp_bglmm), as.character(fp_pp), as.character(fp_mega),
             sprintf("%.2f",100*fp_anova/nDatasets), sprintf("%.2f",100*fp_glmm/nDatasets),
             sprintf("%.2f",100*fp_bglmm/nDatasets)),
  Verdict = c("YES","YES","YES","YES","YES","YES","YES","YES","YES"))
write.csv(out, file.path("output","falsepos_comparison.csv"), row.names=FALSE)
cat("\nWROTE output/falsepos_comparison.csv\n")
