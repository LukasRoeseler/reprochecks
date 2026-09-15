suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
qa <- read.csv(file.path(base,"repo_data/QualityAssessment.csv"), stringsAsFactors=FALSE, check.names=FALSE)
names(qa) <- make.names(names(qa), unique=TRUE)
cat("rows:", nrow(qa), " unique Review IDs:", length(unique(qa$Review.ID)), " reviewers:", paste(unique(qa$Reviewer), collapse=", "), "\n\n")
## For each review, take the consensus row (or blend)
cons <- qa[qa$Reviewer=="Consensus",]
cat("Consensus rows:", nrow(cons), " unique review ids in consensus:", length(unique(cons$Review.ID)), "\n\n")
crit <- names(qa)[3:9]
cat("Criteria:", paste(crit, collapse=" | "), "\n\n")
## Low risk tallies per criterion (out of ALL consensus rows)
for (c in crit) {
  tb <- table(cons[[c]])
  cat(sprintf("%-75s low=%s unclear=%s high=%s\n", c,
    tb[["low"]] %||% 0, tb[["unclear"]] %||% 0, tb[["high"]] %||% 0))
}
## Count low risk on all criteria
allcat <- crit
low_all <- rowSums(cons[, crit] == "low", na.rm=TRUE)
cat("\nReviews low-risk on ALL criteria:", sum(low_all == length(crit)), "of", nrow(cons), "\n")
cat("Any row with 6 or 7 lows:", sum(low_all >= 6), "\n")
