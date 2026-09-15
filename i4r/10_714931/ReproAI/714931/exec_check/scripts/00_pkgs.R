pkgs <- c("lme4","ordinal","readr","dplyr")
for (p in pkgs) cat(p, requireNamespace(p, quietly=TRUE), "\n")
cat("R version:", R.version.string, "\n")
