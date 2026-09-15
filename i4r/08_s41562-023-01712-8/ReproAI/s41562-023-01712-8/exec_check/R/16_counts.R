suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
m <- read.csv(file.path(base,"output/reanalysis_full_joined.csv"), stringsAsFactors=FALSE)
m$n<-as.numeric(m$n)
edu <- m[m$cat=="education", ]; hea <- m[is.na(m$cat) | m$cat!="education", ]
cat("Study-data effects: education (n>=1000):", sum(edu$n>=1000), " of edu study-data:", nrow(edu), "\n")
cat("Study-data effects: non-education (n>=1000):", sum(hea$n>=1000), " of non-edu study-data:", nrow(hea), "\n")
cat("Edu n>=1000 & sig999:", sum(edu$n>=1000 & edu$sig999), " ; non-edu n>=1000 & sig999:", sum(hea$n>=1000 & hea$sig999), "\n")
## I2>50 among credible-candidate effects
cat("Edu credible-cand (n>=1000) with I2>50:", sum(edu$n>=1000 & edu$i2>50), " of", sum(edu$n>=1000), "\n")
## PRISMA arithmetic
cat("\nPRISMA: 50649-28675=",50649-28675," ; 21974-19417=",21974-19417," ; 2557-2340=",2557-2340,"\n")
## effects CIs for 99.9% classification sanity for abstract-level claims
