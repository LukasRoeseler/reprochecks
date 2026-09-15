library(pdftools)
dir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
t2 <- pdf_text(file.path(dir,"ACT_MainPaperTables_REPLICATION_short.pdf"))
full <- paste(t2, collapse="\n")
# find matrix output section
cat(nchar(full), "chars\n")
# print lines around 'mat li t' outputs -> look for "c1 " style matrix listings
lines <- strsplit(full, "\n")[[1]]
# locate occurrences
idc <- grep("^c1|c2|c3|r1|r2|^t\\[|mat li", lines)
cat("relevant line numbers:", length(idc), "\n")
# Print the portion after "mat li t" for Table 2 to end
for (i in seq_along(lines)) {
  if (grepl("mat li t$", lines[i])) {
    cat("\n--- after mat li t at line", i, "---\n")
    for (j in (i):min(i+30, length(lines))) cat(lines[j], "\n")
  }
}
