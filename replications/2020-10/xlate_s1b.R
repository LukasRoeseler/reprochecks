suppressMessages({library(haven);library(geepack);library(car)})
d<-"C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/ht7j6/Data"
s1<-read_sav(file.path(d,"Study1Data.sav"))
s1f<-as.data.frame(s1[s1$include==1 & !is.na(s1$include),])
s1f$cond<-as.factor(s1f$condition_recodedintuitive)
s1f$pt<-as.numeric(as.character(s1f$participantnumber))
s1f$y<-as.numeric(as.character(s1f$punishyesno))
cat("included N:",nrow(s1f),"\n")
cat("== GEE: punishyesno ~ condition (independent, robust) ==\n")
gee1<-tryCatch(geeglm(y~cond, id=pt, data=s1f, family=binomial("logit"), corstr="independence"),error=function(e)e)
if(inherits(gee1,"error")){print(gee1)}else{print(summary(gee1)$coefficients)}
cat("\n== GEE model Wald overall (type III) ==\n")
if(!inherits(gee1,"error")){print(anova(gee1)[2,])}
cat("\n== GLM Wald Anova ==\n")
m0<-glm(y~cond,data=s1f,family=binomial()); print(Anova(m0,type=3,test.statistic="Wald"))
cat("\n== meanness ANOVA ==\n"); a1<-aov(meanness~cond,data=s1f); print(summary(a1))
cat("\n== punishcontinuous ANOVA ==\n"); a2<-aov(punishcontinuous~cond,data=s1f); print(summary(a2))
cat("\n== happiness ANOVA ==\n"); a3<-aov(happiness~cond,data=s1f); print(summary(a3))
