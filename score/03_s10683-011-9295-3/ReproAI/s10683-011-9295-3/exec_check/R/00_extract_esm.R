suppressMessages({
  if (!requireNamespace("pdftools", quietly=TRUE)) install.packages("pdftools", repos="https://cloud.r-project.org", quiet=TRUE)
})
library(pdftools)
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/03_s10683-011-9295-3/ReproAI/s10683-011-9295-3"
pdf <- file.path(base, "exec_check", "ESM_MOESM1.pdf")
txt <- pdf_text(pdf)
writeLines(txt, file.path(base, "exec_check", "ESM_text.txt"))
cat("PAGES:", length(txt), "\n")
cat("CHARS:", sum(nchar(txt)), "\n")
