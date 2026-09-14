cat("R version:", R.version.string, "\n")
for (p in c("retimes", "ggplot2", "HDInterval", "tibble", "tidyr", "cowplot", "knitr", "beepr")) {
  cat(p, ":", requireNamespace(p, quietly = TRUE), "\n")
}
cat("sessionInfo:\n")
print(sessionInfo())
