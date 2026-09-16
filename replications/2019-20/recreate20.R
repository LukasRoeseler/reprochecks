suppressMessages({library(haven);library(lme4);library(lmerTest);library(car);library(dplyr)})
d<-"C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/fwp7g"
b<-read_sav(file.path(d,"SpainCB_t1t2t3_9-25-18.sav"))
# Study 1 between: use BetweenSubjectsStudy==1 rows, CB (T1) & CB_t2 (T2), Cond (0 control? 1/2 treatments), CondBTW (0/1)
b$Cond<-as.integer(b$Cond); b$CB<-as.numeric(b$CB); b$CB_t2<-as.numeric(b$CB_t2); b$Age_t1<-as.numeric(b$Age_t1)
# long format
long<-rbind(
  data.frame(id=1:nrow(b),time="T1",CB=b$CB,Cond=b$Cond,CBt=b$CB),
  data.frame(id=1:nrow(b),time="T2",CB=b$CB_t2,Cond=b$Cond,CBt=b$CB_t2)
)
long<-long[!is.na(long$CB) & !is.na(long$Cond),]
long$timeF<-factor(long$time,levels=c("T1","T2"))
long$CondF<-factor(long$Cond)
cat("long rows:",nrow(long)," subjects:",length(unique(long$id))," Cond:",paste(table(long$CondF),collapse="/"),"\n")
# Simple 2(time) x 3(cond) mixed ANOVA (SPSS MIXED ~ time cond time*cond)
cat("\n=== Mixed ANOVA: CB ~ time*cond + (1|id) ===\n")
m<-lmer(CB~timeF*CondF+(1|id),data=long)
print(anova(m,type=3,ddf="Kenward-Roger"))
cat("\n=== With age covariate (only T1 rows have Age; use Age_t1) ===\n")
# ANCOVA on T1 CB by condition controlling age (SPSS MIXED controlled age in F(1,463))
sub<-b[!is.na(b$CB)&!is.na(b$Cond)&!is.na(b$Age_t1),]
aov1<-aov(CB~Cond+Age_t1,data=sub)
print(summary(aov1))
# CB means by cond at T1
print(round(tapply(sub$CB,sub$Cond,function(x)c(mean=mean(x,na.rm=TRUE),sd=sd(x,na.rm=TRUE),n=length(x))),2))
