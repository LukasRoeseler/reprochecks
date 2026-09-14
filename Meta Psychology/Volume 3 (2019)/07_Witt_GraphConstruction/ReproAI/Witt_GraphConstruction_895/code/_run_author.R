wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
setwd(file.path(wrk, "data"))
outcon <- file(file.path(wrk, "output", "author_run_console.txt"), open = "wt")
sink(outcon)
cat("==== START AUTHOR SCRIPT RUN ====\n")
cat(paste("R", R.version.string, "on", Sys.time()), "\n\n")
tryCatch({
  source(file.path(wrk, "code", "Witt_AnalyzeGraphSD_V4_purl.R"), echo = FALSE)
}, error = function(e) {
  cat("\n\n==== ERROR ====\n")
  cat(as.character(e), "\n")
})
cat("\n\n==== END AUTHOR SCRIPT RUN ====\n")
sink()
close(outcon)
cat("RUN DONE\n")
