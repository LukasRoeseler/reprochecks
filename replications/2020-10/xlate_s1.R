suppressMessages({library(haven);library(geepack);library(car)})
d<-"C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/ht7j6/Data"
s1<-read_sav(file.path(d,"Study1Data.sav"))
# SPSS GENLIN GEE: punishyesno ~ condition_recodedintuitive, repeated subject=participantnumber, binomial logit, robust (independent)
s1f<-s1[s1$include==1 & !is.na(s1$include),]
s1f$cond<-factor(s1f$condition_recodedintuitive)
s1f$pt<-factor(s1f$participantnumber)
cat("included N:",nrow(s1f),"\n")
cat("p(punish) by condition:\n"); print(round(tapply(s1f$punishyesno,s1f$cond,function(x)mean(x,na.rm=TRUE)),3))
cat("\n== GEE: punishyesno ~ condition (main) ==\n")
gee1<-tryCatch(geeglm(punishyesno~cond, id=pt, data=s1f, family=binomial("logit"), corstr="independence"),error=function(e)e)
if(inherits(gee1,"error")){print(gee1)}else{print(summary(gee1))}
cat("\n== Contrast comm(1) vs noncomm(2) vs control(3) - Wald ==\n")
# emulate GENLIN ANALYSISTYPE=3 WALD overall
m0<-glm(punishyesno~cond, data=s1f, family=binomial())
print(Anova(m0,type=3,test.statistic="Wald"))
cat("\n== UNIANOVA: meanness ~ condition (SS3) ==\n")
a1<-aov(meanness~cond,data=s1f); print(Anova(a1,type=3))
print(summary(a1))
cat("\n== UNIANOVA: punishcontinuous ~ condition ==\n")
a2<-aov(punishcontinuous~cond,data=s1f); print(summary(a2))
cat("\n== UNIANOVA: happiness ~ condition ==\n")
a3<-aov(happiness~cond,data=s1f); print(summary(a3))
