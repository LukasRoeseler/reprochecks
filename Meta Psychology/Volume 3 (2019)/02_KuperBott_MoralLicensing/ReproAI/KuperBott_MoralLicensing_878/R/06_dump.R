options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$yi <- as.numeric(as.character(dat$yi)); dat$se <- as.numeric(as.character(dat$se)); dat$vi <- dat$se^2

cat("=== Simbrunner (2016) rows (study, N, yi, se) ===\n")
sim <- dat[ grepl("Simbrunner", dat$authors), ]
print(sim[, c("study","N","yi","se","comparison","world_region")])

cat("\n=== decision_type values ===\n")
print(table(dat$decision_type, useNA="ifany"))

cat("\n=== Full data dump (author, study, N, yi, se, comparison, world_region) ===\n")
print(dat[, c("authors","study","N","yi","se","comparison","world_region")])
