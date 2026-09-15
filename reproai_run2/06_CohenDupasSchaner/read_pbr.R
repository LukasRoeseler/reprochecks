library(openxlsx)
dir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
wb <- loadWorkbook(file.path(dir, "Cohen_AmEcoRev_2015_2lb5_2g781_PBR.xlsx"))
cat("sheets:", paste(names(wb), collapse=", "), "\n")
for (s in names(wb)) {
  cat("\n========== SHEET:", s, "==========\n")
  df <- read.xlsx(wb, sheet=s)
  txt <- capture.output(print(df, width=200))
  cat(paste(txt, collapse="\n"), "\n")
}
