library(haven)
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/10_Hertel"
df <- read_sav(file.path(d, "Ashley_labels.sav"))
cat("DIMS:", dim(df), "\n")
cat("NAMES:\n")
print(names(df))
cat("\nVariable labels:\n")
print(attr(df, "label"))
cat("\nList of variables with labels:\n")
for (nm in names(df)) {
  lbl <- attr(df[[nm]], "label")
  if (!is.null(lbl)) cat(nm, ":", lbl, "\n")
}
cat("\nHEAD (first 60 rows, key cols):\n")
print(head(df, 60))
