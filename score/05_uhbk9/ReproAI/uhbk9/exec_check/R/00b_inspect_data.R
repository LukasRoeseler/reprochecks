## ReproAI uhbk9 - inspect raw CSV rating columns (Study 1 patterns)
csv1 <- "..\\..\\extracted\\Pennycook et al._Study 1.csv"
d <- read.csv(csv1, check.names = FALSE, na.strings = "", stringsAsFactors = FALSE)
cat("S1 nrow:", nrow(d), "\n")
cat("Condition table:\n"); print(table(d$Condition, useNA="ifany"))
cat("Acc table:\n"); print(table(d$Acc, useNA="ifany"))

base <- paste0("Fake1_", 1:15); real <- paste0("Real1_", 1:15)
cat("non-NA count base Fake1_1..15:\n"); print(sapply(base, function(c) sum(!is.na(d[[c]]))))
cat("non-NA base Real1_1..15:\n"); print(sapply(real, function(c) sum(!is.na(d[[c]]))))
vers <- c("", ".0", ".1", ".2")
for (v in vers) {
  cols <- paste0("Fake1_1", v)
  cat("Fake1_1", v, "non-na:", sum(!is.na(d[[cols]])), "\n")
}
## check if base equals .0/.1/.2 for overlapping rows
for (v in c(".0",".1",".2")) {
  b <- d[["Fake1_1"]]; o <- d[[paste0("Fake1_1",v)]]
  both <- !is.na(b) & !is.na(o)
  cat("Fake1_1 vs", v, "- both non-na:", sum(both), " equal:", if(sum(both)>0) sum(b[both]==o[both],na.rm=TRUE) else NA, "\n")
}
## how many rows have ANY of the 15 base fake ratings
nany <- apply(d[,base],1,function(r) sum(!is.na(r)))
cat("rows with any base Fake rating:", sum(nany>0), "\n")
cat("rows with all 15 base Fake ratings:", sum(nany==15), "\n")
## column classes
cat("Class of Fake1_1:", class(d[["Fake1_1"]]), "\n")
cat("head values Fake1_1:", head(d[["Fake1_1"]]), "\n")
## RT columns exist? any ratings stored only in RT? check
cat("has Fake1_RT_1_1:", "Fake1_RT_1_1" %in% names(d), "\n")
