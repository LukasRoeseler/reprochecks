# 01_falsepos_from_shipped.R
# Verify the false-positive claims (C17, C18, C19) from the SHIPPED meta_results file.
# This replicates the logic in the author's falsePos.R using the submitted results table.

res <- file.path("..","code_author","Results","meta_results_18_09_16.txt")
d <- read.delim(res, check.names=FALSE)

cat("=== Structure ===\n")
cat("rows:", nrow(d), "\n")
cat("unique meta_true_sex_cond:", paste(sort(unique(d$meta_true_sex_cond)), collapse=","), "\n")
cat("unique meta_var_base:", paste(sort(unique(d$meta_var_base)), collapse=","), "\n")
cat("repeats per combo:\n")
print(table(d$meta_true_sex_cond, d$meta_var_base))

# Only e=0 rows
Ze <- d[d$meta_true_sex_cond==0,]
n_ze <- nrow(Ze)
cat("\nrows with true effect 0:", n_ze, "\n")
cat("expected datasets for FP analysis (5 var x 20 rep x 60 expt):", length(unique(Ze$meta_var_base))*20*60, "\n")

# ANOVA/GLMM/BGLMM positive rates are averages over 60 datasets per repeat;
# multiply by 60 to get false-positive counts per repeat, then sum over all 100 repeats.
fp_anova <- sum(Ze$meta_sex_cond_positive_rate_anova * 60)
fp_glmm  <- sum(Ze$meta_sex_cond_positive_rate_glmm  * 60)
fp_bglmm <- sum(Ze$meta_sex_cond_positive_rate_bglmm * 60)

# PP & mega_bglmm: positive rate is 0/1 per repeat (final analysis); sum gives count over 100 repeats
fp_pp   <- sum(Ze$meta_sex_cond_positive_rate_pp)
fp_mega <- sum(Ze$meta_sex_cond_positive_rate_mega_bglmm)

nDatasets <- n_ze * 60
cat("\n=== FALSE POSITIVE COUNTS (from shipped meta_results) ===\n")
cat("Total datasets e=0 (N):", nDatasets, "\n")
cat("ANOVA :", fp_anova, sprintf("(%.3f%%)", 100*fp_anova/nDatasets), "\n")
cat("GLMM  :", fp_glmm,  sprintf("(%.3f%%)", 100*fp_glmm/nDatasets), "\n")
cat("BGLMM :", fp_bglmm, sprintf("(%.3f%%)", 100*fp_bglmm/nDatasets), "\n")
cat("PP    :", fp_pp,  sprintf("(%.1f%% of 100 sims)", 100*fp_pp/n_ze), "\n")
cat("MEGA  :", fp_mega, sprintf("(%.1f%% of 100 sims)", 100*fp_mega/n_ze), "\n")

cat("\n=== Manuscript claims ===\n")
cat("Paper: ANOVA 304 (5.1%), GLMM 341 (5.7%), BGLMM 304 (5.1%), PP 2 (2%), meta BGLMM 1 (1%)\n")

# Save comparison table
out <- data.frame(
  Quantity = c("N datasets (e=0)","FalsePos ANOVA","FalsePos GLMM","FalsePos BGLMM",
               "PP false pos (100 sims)","meta BGLMM false pos (100 sims)",
               "FP rate ANOVA %","FP rate GLMM %","FP rate BGLMM %"),
  Manuscript = c("6000","304 (5.1%)","341 (5.7%)","304 (5.1%)","2 (2%)","1 (1%)",
                 "5.1","5.7","5.1"),
  Reimpl = c(as.character(nDatasets), as.character(fp_anova), as.character(fp_glmm),
             as.character(fp_bglmm), as.character(fp_pp), as.character(fp_mega),
             sprintf("%.2f",100*fp_anova/nDatasets), sprintf("%.2f",100*fp_glmm/nDatasets),
             sprintf("%.2f",100*fp_bglmm/nDatasets)))
write.csv(out, file.path("output","falsepos_comparison.csv"), row.names=FALSE)
cat("\nWrote output/falsepos_comparison.csv\n")
