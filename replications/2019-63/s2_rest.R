suppressMessages({library(afex);library(car);library(dplyr);library(reshape2);library(plyr);library(sjstats)})
analysis_path <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/work/2019-63/Study2-PAVtwoUS/ANALYSIS/R"
setwd(analysis_path)
PAV <- read.delim(file.path(analysis_path,'Database-PAVtwoUS.txt'), header=T, sep='')
LIKE <- read.delim(file.path(analysis_path,'Database-PAVtwoUS-liking.txt'), header=T, sep='')
PAV$ID<-factor(PAV$ID);PAV$run<-factor(PAV$run);PAV$bin<-factor(PAV$bin);PAV$CS_ID<-factor(PAV$CS_ID);PAV$CS_SIDE<-factor(PAV$CS_SIDE);PAV$phase<-factor(PAV$phase)
LIKE$ID<-factor(LIKE$ID);LIKE$run<-factor(LIKE$run);LIKE$CS_ID<-factor(LIKE$CS_ID);LIKE$CS_ALL<-factor(LIKE$CS_ALL);LIKE$CS_SIDE<-factor(LIKE$CS_SIDE)
PAV$CS.value[PAV$CS_ID=='CSmi']<- -1;PAV$CS.value[PAV$CS_ID=='val']<- .5;PAV$CS.value[PAV$CS_ID=='deval']<- .5
PAV$CS.left[PAV$CS_SIDE=='CSmi']<- -.5;PAV$CS.left[PAV$CS_SIDE=='CSpR']<- -.5;PAV$CS.left[PAV$CS_SIDE=='CSpL']<- 1
PAV$CS.right[PAV$CS_SIDE=='CSmi']<- -.5;PAV$CS.right[PAV$CS_SIDE=='CSpR']<- 1;PAV$CS.right[PAV$CS_SIDE=='CSpL']<- -.5
LIKE$CS.value[LIKE$CS_ID=='CSmi']<- -1;LIKE$CS.value[LIKE$CS_ID=='val']<- .5;LIKE$CS.value[LIKE$CS_ID=='deval']<- .5
LIKE$CS.left[LIKE$CS_SIDE=='CSmi']<- -.5;LIKE$CS.left[LIKE$CS_SIDE=='CSpR']<- -.5;LIKE$CS.left[LIKE$CS_SIDE=='CSpL']<- 1
LIKE$CS.right[LIKE$CS_SIDE=='CSmi']<- -.5;LIKE$CS.right[LIKE$CS_SIDE=='CSpR']<- 1;LIKE$CS.right[LIKE$CS_SIDE=='CSpL']<- -.5
cat("===== SATIATION-INDUCED CHANGE (bin03-06, val/deval) =====\n")
CHANGE<-subset(PAV, bin=='bin03'|bin=='bin04'|bin=='bin05'|bin=='bin06');CHANGE_CS<-subset(CHANGE, CS_ID=='val'|CS_ID=='deval')
# dwell time congruent ROI
dm<-aggregate(CHANGE_CS$ANT_DW_congr, by=list(CHANGE_CS$ID,CHANGE_CS$phase,CHANGE_CS$CS_ID),FUN='mean');colnames(dm)<-c('ID','phase','CS_ID','ANT_DW_congr')
fit<-aov(ANT_DW_congr~CS_ID*phase+Error(ID/CS_ID*phase),data=dm);cat("-- DW CS_ID:phase --\n");print(anova_stats(fit$`ID:CS_ID:phase`))
# pupil dilation
pm<-aggregate(CHANGE_CS$CS_pupil, by=list(CHANGE_CS$ID,CHANGE_CS$phase,CHANGE_CS$CS_ID),FUN='mean');colnames(pm)<-c('ID','phase','CS_ID','CS_pupil')
fit<-aov(CS_pupil~CS_ID*phase+Error(ID/CS_ID*phase),data=pm);cat("-- PUPIL CS_ID:phase --\n");print(anova_stats(fit$`ID:CS_ID:phase`))
cat("===== LIKING (run 1-2, CS.value) =====\n")
LL<-subset(LIKE, run=='1'|run=='2');lm2<-aggregate(LL$ratings,by=list(LL$ID,LL$CS.value),FUN='mean');colnames(lm2)<-c('ID','CS.value','ratings')
fit<-aov(ratings~CS.value+Error(ID/(CS.value)),data=lm2);cat("-- liking CS.value --\n");print(anova_stats(fit$`ID:CS.value`))
cat("===== RT congruent/incongruent =====\n")
LEARN<-subset(PAV, run=='1'|run=='2')
vars<-names(LEARN)%in%c('ID','congr_SIDE','congr_ID','US_RT');LN<-na.omit(LEARN[vars])
rm1<-aggregate(LN$US_RT,by=list(LN$ID,LN$congr_SIDE),FUN='mean');colnames(rm1)<-c('ID','congr_SIDE','US_RT')
fit<-aov(US_RT~congr_SIDE+Error(ID/(congr_SIDE)),data=rm1);cat("-- RT congr_SIDE --\n");print(anova_stats(fit$`ID:congr_SIDE`))
rm2<-aggregate(LN$US_RT,by=list(LN$ID,LN$congr_ID),FUN='mean');colnames(rm2)<-c('ID','congr_ID','US_RT')
fit<-aov(US_RT~congr_ID+Error(ID/(congr_ID)),data=rm2);cat("-- RT congr_ID --\n");print(anova_stats(fit$`ID:congr_ID`))
