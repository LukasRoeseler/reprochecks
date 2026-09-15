cat("==== START (status: OK) ====\n")
cat("R version:", R.version.string, "\n")
cat("lme4 version:", as.character(packageVersion("lme4")), "\n")
cat("lmerTest version:", as.character(packageVersion("lmerTest")), "\n")
cat("sessionInfo:\n")
print(sessionInfo())
cat("\n")

options(width=200)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/exec_check")
dir.rep <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/12_s0003055422000107/ReproAI/s0003055422000107/replication"
load(file.path(dir.rep, "Replication_data.RData"))

cat("Objects loaded:", ls(), "\n\n")

if (exists("newd")) {
  cat("=== newd (all parties) ===", "\n")
  cat("dim:", dim(newd), "\n")
  cat("names:", paste(names(newd), collapse=" | "), "\n")
  cat("nrow(newd):", nrow(newd), "\n")
  if (exists("newpartyfam", where=newd)) cat("party family table:\n")
  print(table(newd$newpartyfam))
}
if (exists("newd2")) {
  cat("\n=== newd2 (Radical Right only) ===", "\n")
  cat("dim:", dim(newd2), "\n")
  cat("nrow(newd2):", nrow(newd2), "\n")
}
cat("\nstr of newd:\n")
print(str(newd))
cat("==== END (status: OK) ====\n")
