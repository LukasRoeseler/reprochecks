suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
qa <- read.csv(file.path(base,"repo_data/QualityAssessment.csv"), stringsAsFactors=FALSE, check.names=FALSE)
rev <- read.csv(file.path(base,"repo_data/Reviews.csv"), stringsAsFactors=FALSE, check.names=FALSE)
names(rev) <- make.names(names(rev), unique=TRUE)
kk <- rev$k..number.of.studies.in.the.entire.review.
nn <- rev$N..combined.sample.across.all.studies.in.review.
kk <- as.numeric(kk); nn <- as.numeric(nn)
kk[kk < 0] <- NA; nn[nn < 0] <- NA
cat("Reviews.csv rows:", nrow(rev), "\n")
cat("Sum of review k (primary studies, non-missing):", sum(kk, na.rm=TRUE), " (missing:", sum(is.na(kk)),")\n")
cat("Sum of review N (participants, non-missing):", sum(nn, na.rm=TRUE), "\n\n")

## ROB tallies over consensus
cons <- qa[qa$Reviewer=="Consensus",]
crits <- names(cons)[3:9]
cat("Consensus rows (denominator candidate):", nrow(cons), " of total QA rows:", nrow(qa), "\n\n")
for (c in crits){
  tb <- table(factor(cons[[c]], levels=c("low","unclear","high")))
  cat(sprintf("%-62s low=%3d unclear=%3d high=%3d  | percent-low=%.0f%%\n",
      c, tb["low"], tb["unclear"], tb["high"], 100*tb["low"]/nrow(cons)))
}
## all 7 low
low7 <- rowSums(cons[,crits]=="low")==7
cat("\nConsensus low on ALL 7 criteria:", sum(low7), "\n")
## medium-to-high = not low on all 7 (paper abstract: 95/102 medium-to-high)
cat("Consensus medium-to-high (not low on all 7):", nrow(cons)-sum(low7), "/", nrow(cons), "\n")
## all 6 (exclude eligibility - first tool item, per paper note)
crits6 <- crits[!grepl("Eligibility", crits)]
low6 <- rowSums(cons[,crits6]=="low")==6
cat("Consensus low on all 6 (excl. eligibility):", sum(low6), "\n")
cat("Medium-to-high by 6 criteria:", nrow(cons)-sum(low6), "\n")
