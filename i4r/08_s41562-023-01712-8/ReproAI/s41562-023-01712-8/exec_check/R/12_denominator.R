suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
qa <- read.csv(file.path(base,"repo_data/QualityAssessment.csv"), stringsAsFactors=FALSE, check.names=FALSE)
eff <- read.csv(file.path(base,"repo_data/Effects.csv"), stringsAsFactors=FALSE, check.names=FALSE)
rev <- read.csv(file.path(base,"repo_data/Reviews.csv"), stringsAsFactors=FALSE, check.names=FALSE)
sti <- read.csv(file.path(base,"repo_data/Studies.csv"), stringsAsFactors=FALSE, check.names=FALSE)
names(eff)[names(eff)=="Review ID"] <- "Review.ID"
names(qa)[names(qa)=="Review.ID"] <- "Review.ID"
names(sti)[names(sti)=="Review ID"] <- "Review.ID"
cat("QualityAssessment unique reviews:", length(unique(qa$Review.ID)), "\n")
cat("Effects.csv unique reviews:", length(unique(eff$Review.ID)), "\n")
cat("Reviews.csv rows:", nrow(rev), "\n")
cat("Studies.csv unique reviews:", length(unique(sti$Review.ID)), "\n\n")
## Reviews that appear in Effects.csv
eff_rev <- unique(eff$Review.ID)
cat("QA reviews present in Effects.csv:", sum(qa$Review.ID %in% eff_rev), "\n\n")
## Paper-prose tallies to check:
## 93/102 low heterogeneity; 86/102 low characteristics; 71/102 low search; 71/102 unclear eligibility
## 20/102 high screening; 37/102 unclear screening; 52/102 high dual qual; 7 low on all criteria
## Use CONSENSUS rows in the QA file, denominator = number of consensus rows
cons <- qa[qa$Reviewer=="Consensus",]
cat("Consensus unique reviews:", length(unique(cons$Review.ID)), "\n")
for (c in names(qa)[3:9]) {
  tb <- table(factor(cons[[c]], levels=c("low","unclear","high")))
  cat(sprintf("%-60s low=%3d unclear=%3d high=%3d\n", c, tb["low"], tb["unclear"], tb["high"]))
}
crits <- names(qa)[3:9]
low_all <- rowSums(cons[,crits]=="low", na.rm=TRUE)
cat("\nReviews low on ALL 7 criteria:", sum(low_all==7), "\n")
cat("Reviews low on >=6 criteria:", sum(low_all>=6), "\n")
