## ReproAI audit — Forster & Neugebauer 2024 (Sociological Science 11:886-906)
## Step 00: Inspect shipped replication data structure
suppressMessages({ library(haven) })

dataDir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/ReproAI Checks III/03_Forster_Neugebauer_SocSci2024/ReproAI/SocSci2024/exec_check/data/pkg/replication_package_incl_data/00_data"

fe <- read_dta(file.path(dataDir, "validation_fe.dta"))
fs <- read_dta(file.path(dataDir, "validation_fs.dta"))

cat("FE dims:", nrow(fe), "x", ncol(fe), "\n")
cat("FS dims:", nrow(fs), "x", ncol(fs), "\n\n")

inspect <- function(df, nm) {
  cat("==== ", nm, " ====\n", sep="")
  for (n in names(df)) {
    v <- df[[n]]
    cat(sprintf("%-28s class=%-9s", n, class(v)[1]))
    if (inherits(v, "labelled")) {
      lbls <- attr(v, "labels")
      cat(sprintf(" labels={%s}", paste(paste(names(lbls), lbls, sep="="), collapse=", ")))
    } else {
      r <- suppressWarnings(range(as.numeric(v), na.rm=TRUE))
      cat(sprintf(" range=[%s]", paste(r, collapse=", ")))
    }
    cat("\n")
  }
  cat("\n")
}

inspect(fe, "FIELD EXPERIMENT")
inspect(fs, "FACTORIAL SURVEY")

OUT <- "../output"
saveRDS(fe, file.path(OUT, "fe.rds"))
saveRDS(fs, file.path(OUT, "fs.rds"))
cat("Saved fe.rds and fs.rds\n")
