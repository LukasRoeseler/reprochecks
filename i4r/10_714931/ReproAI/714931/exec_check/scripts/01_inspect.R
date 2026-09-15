suppressPackageStartupMessages({
  library(readr); library(dplyr)
})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/10_714931/ReproAI/714931"
d <- read_delim(file.path(base,"extracted","Cordova_Kras_dataset.txt"), delim="\t", col_types = cols(.default = col_character()))
cat("DIM:", dim(d)[1], "x", dim(d)[2], "\n")
d2 <- read.delim(file.path(base,"extracted","Cordova_Kras_dataset.txt"), sep="\t", na.strings="")
cat("R read.delim: rows=", nrow(d2), " cols=", ncol(d2), "\n")
vars <- c("cidade","p2a","b9a","deam","knowdeam1","female","knowvictim","marital_status","children","classe","homiciderate","femiciderate","civilpolice","b11ar","c1r","b4gr","q91cr","q89er","color","q53r","q91er","edlevel","a3aer","b4dr","vaw_law","education_muni_2010","c6r","num_years","Loggdp_2012","Logpopsize","yearscollective","protest_fem")
cat("All vars present:", all(vars %in% names(d2)), "\n")
for (v in names(d2)) {
  x <- d2[[v]]
  tab <- sort(table(x, useNA="ifany"))
  cat(sprintf("%-25s type=%s  nNA=%d  ", v, typeof(x), sum(is.na(x))))
  cat(paste(names(tab)[1:min(6,length(tab))], "=", as.character(tab)[1:min(6,length(tab))], collapse="; "), "\n")
}
