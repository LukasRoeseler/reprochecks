suppressMessages(library(haven));library(dplyr)
d<-"C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/github/warwickpsych__NationalValenceIndex/TableFigure_Nature_onGithub"
v<-read_dta(file.path(d,"nature_valence.dta"))
cat("dims",dim(v)," cols:",paste(names(v),collapse=", "),"\n")
# headline corr: valence vs val_score_coha US (C==6), year>=1820
s<-v[!is.na(v$valence) & !is.na(v$val_score_coha) & v$C==6 & v$year>=1820,]
cat("\npwcorr valence val_score_coha US C==6 year>=1820 n=",nrow(s),"\n"); print(cor.test(s$valence,s$val_score_coha))
s2<-v[!is.na(v$valence) & !is.na(v$val_score_fmp) & v$C==4 & v$year>=1820 & v$year<1951,]
cat("\npwcorr valence val_score_fmp UK C==4 1820..1950 n=",nrow(s2),"\n"); print(cor.test(s2$valence,s2$val_score_fmp))
