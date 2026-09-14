cat(R.version.string, "\n")
for (p in c("ez","BayesFactor","readr","dplyr","tidyr","purrr","readxl","cowplot","ggplot2")) {
  cat(p, requireNamespace(p, quietly=TRUE), "\n")
}
