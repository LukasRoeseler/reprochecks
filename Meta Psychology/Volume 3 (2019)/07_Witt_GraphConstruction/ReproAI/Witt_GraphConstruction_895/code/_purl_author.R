wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
setwd(file.path(wrk, "code"))
knitr::purl("Witt_AnalyzeGraphSD_V4_adapted.Rmd", output = "Witt_AnalyzeGraphSD_V4_purl.R", quiet = FALSE)
cat("PURL DONE\n")
