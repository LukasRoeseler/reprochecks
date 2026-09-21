suppressMessages({library(afex);library(car);library(dplyr);library(reshape2);library(plyr);library(sjstats)})
analysis_path <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/work/2019-63/Study3-PIC/ANALYSIS/R"
setwd(analysis_path)
PIC <- read.delim(file.path(analysis_path,'Database-PIC.txt'), header=T, sep='')
PIC$ID<-factor(PIC$ID);PIC$run<-factor(PIC$run);PIC$group<-factor(PIC$group);PIC$IC<-factor(PIC$IC);PIC$phase<-factor(PIC$phase)
PIC$Ccongr[PIC$IC=='CSm']<- 0;PIC$Ccongr[PIC$IC=='congr']<- 1;PIC$Ccongr[PIC$IC=='incongr']<- -1
CHANGE<-subset(PIC,run=='2'|run=='3');TEST<-subset(CHANGE,run=='3');RUN2<-subset(CHANGE,run=='2')
# PAV follow-ups
vars<-names(TEST)%in%c('ID','group','Ccongr','ANT_DW_pav');tn<-na.omit(TEST[vars]);tm<-aggregate(tn$ANT_DW_pav,by=list(tn$ID,tn$group,tn$Ccongr),FUN='mean');colnames(tm)<-c('ID','group','Ccongr','ANT_DW_pav');tm<-subset(tm,Ccongr!=0)
cat("== PAV follow-up AFTER devaluation: group x cue (ID:Ccongr) ==\n");fit<-aov(ANT_DW_pav~Ccongr*group+Error(ID/(Ccongr)),data=tm);print(anova_stats(fit$`ID:Ccongr`))
vars<-names(RUN2)%in%c('ID','group','Ccongr','ANT_DW_pav');rn<-na.omit(RUN2[vars]);rm<-aggregate(rn$ANT_DW_pav,by=list(rn$ID,rn$group,rn$Ccongr),FUN='mean');colnames(rm)<-c('ID','group','Ccongr','ANT_DW_pav');rm<-subset(rm,Ccongr!=0)
cat("== PAV follow-up BEFORE devaluation: group x cue (ID:Ccongr) ==\n");fit<-aov(ANT_DW_pav~Ccongr*group+Error(ID/(Ccongr)),data=rm);print(anova_stats(fit$`ID:Ccongr`))
con<-tm[tm$Ccongr==1,];cat("== PAV AFTER deval CONGRUENT: group (ID) ==\n");fit<-aov(ANT_DW_pav~group+Error(ID),data=con);print(anova_stats(fit$`ID`))
inc<-tm[tm$Ccongr==-1,];cat("== PAV AFTER deval INCONGRUENT: group (ID) ==\n");fit<-aov(ANT_DW_pav~group+Error(ID),data=inc);print(anova_stats(fit$`ID`))
# INS follow-ups (test session)
vars<-names(TEST)%in%c('ID','group','Ccongr','ANT_DW_ins');tn2<-na.omit(TEST[vars]);tm2<-aggregate(tn2$ANT_DW_ins,by=list(tn2$ID,tn2$group,tn2$Ccongr),FUN='mean');colnames(tm2)<-c('ID','group','Ccongr','ANT_DW_ins');tm2<-subset(tm2,Ccongr!=0)
cat("== INS test session: congruency main effect (ID:Ccongr) ==\n");fit<-aov(ANT_DW_ins~Ccongr*group+Error(ID/(Ccongr)),data=tm2);print(anova_stats(fit$`ID:Ccongr`))
