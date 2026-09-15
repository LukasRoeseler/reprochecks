suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
st <- read.csv(file.path(base,"repo_data/Studies.csv"), stringsAsFactors=FALSE, check.names=FALSE, na.strings=c("-999","","#N/A"))
names(st) <- make.names(names(st), unique=TRUE)
st$study_n <- st$Study.N
d <- st[st$Effect.Size.ID=="47569_001",]
cat("class study_n after read:", class(d$Study.N), " values:", paste(unique(d$Study.N),collapse=","),"\n")
