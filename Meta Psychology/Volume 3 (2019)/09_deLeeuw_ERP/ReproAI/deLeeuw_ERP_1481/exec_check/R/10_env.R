cat("==== START env check (status: running) ====\n")
cat("R version:", R.version.string, "\n")
cat("platform:", R.version$platform, "\n")
cat("RNGkind:", paste(RNGkind(), collapse=" "), "\n")
deps <- c("readr","dplyr","tidyr","purrr","ez","BayesFactor","cowplot","ggplot2","grid")
ip <- rownames(installed.packages())
for (d in deps) {
  v <- if (d %in% ip) as.character(packageVersion(d)) else "NOT INSTALLED"
  cat(sprintf("%-12s %s\n", d, v))
}
cat("==== END env check (status: OK) ====\n")
