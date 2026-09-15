library(pdftools)
dir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
t1 <- pdf_text(file.path(dir,"README_AER2013-0267.pdf"))
cat("======= README_AER2013-0267.pdf =======\n")
cat(paste(t1, collapse="\n\n"), "\n")
