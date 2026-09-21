suppressMessages({library(afex);library(car);library(dplyr);library(reshape2);library(plyr);library(sjstats)})
analysis_path <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/work/2019-63/Study3-PIC/ANALYSIS/R"
setwd(analysis_path)
PIC <- read.delim(file.path(analysis_path,'Database-PIC.txt'), header=T, sep='')
PIC$ID<-factor(PIC$ID);PIC$run<-factor(PIC$run);PIC$group<-factor(PIC$group);PIC$IC<-factor(PIC$IC);PIC$phase<-factor(PIC$phase)
PIC$Ccongr[PIC$IC=='CSm']<- 0;PIC$Ccongr[PIC$IC=='congr']<- 1;PIC$Ccongr[PIC$IC=='incongr']<- -1
CHANGE<-subset(PIC,run=='2'|run=='3')
# ---- author line 285-292: aggregate then fit on RAW CHANGE ----
vars<-names(CHANGE)%in%c('ID','group','phase','Ccongr','ANT_DW_ins');cn<-na.omit(CHANGE[vars]);cm<-aggregate(cn$ANT_DW_ins,by=list(cn$ID,cn$group,cn$phase,cn$Ccongr),FUN='mean');colnames(cm)<-c('ID','group','phase','Ccongr','ANT_DW_ins')
cat("== A) INS author model: aov(data=CHANGE raw) anova_stats(ID:Ccongr:phase) ==\n")
fit<-aov(ANT_DW_ins~Ccongr*phase*group+Error(ID/(Ccongr*phase)),data=CHANGE);print(anova_stats(fit$`ID:Ccongr:phase`))
cat("== B) INS author model: anova_stats(ID:phase) ==\n");print(anova_stats(fit$`ID:phase`))
cat("== C) INS aggregated model anova_stats(ID:Ccongr:phase) ==\n")
fit2<-aov(ANT_DW_ins~Ccongr*phase*group+Error(ID/(Ccongr*phase)),data=cm);print(anova_stats(fit2$`ID:Ccongr:phase`))
cat("== D) INS aggregated model anova_stats(ID:phase) ==\n");print(anova_stats(fit2$`ID:phase`))
# ---- PAV author line 378-388: aggregate then fit on CHANGE.pav.mean ----
vars<-names(CHANGE)%in%c('ID','group','phase','Ccongr','ANT_DW_pav');cn2<-na.omit(CHANGE[vars]);cp<-aggregate(cn2$ANT_DW_pav,by=list(cn2$ID,cn2$group,cn2$phase,cn2$Ccongr),FUN='mean');colnames(cp)<-c('ID','group','phase','Ccongr','ANT_DW_pav')
cat("== E) PAV author model aov(data=cp) anova_stats(ID:Ccongr:phase) ==\n")
fit3<-aov(ANT_DW_pav~Ccongr*phase*group+Error(ID/(Ccongr*phase)),data=cp);print(anova_stats(fit3$`ID:Ccongr:phase`))
