suppressMessages({
  library(readxl)
})
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/09_Ohtsubo/dl_httpsosfiodownloadp9whq.bin"
data <- read_excel(d, sheet = "Sheet3", skip = 1)
cat("dims:", dim(data), "\n")
cat("colnames:", paste(colnames(data), collapse=" | "), "\n")
cat("structure head:\n")
print(data[1:5, 1:min(12,ncol(data))])
