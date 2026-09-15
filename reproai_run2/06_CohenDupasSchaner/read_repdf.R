library(pdftools)
dir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
t2 <- pdf_text(file.path(dir,"ACT_MainPaperTables_REPLICATION_short.pdf"))
cat("======= ACT_MainPaperTables_REPLICATION_short.pdf =======\n")
cat(paste(t2, collapse="\n\n"), "\n")
