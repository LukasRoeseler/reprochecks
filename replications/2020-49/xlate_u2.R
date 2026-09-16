suppressMessages({library(haven);library(sandwich);library(lmtest);library(dplyr)})
d<-"C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/9mfws/data_and_code"
u<-read_dta(file.path(d,"ultimatum_game","data","ultimatum.dta"))
u$repeated <- ifelse(u$Total_played_rounds==1,1,ifelse(u$Round_label==1 & u$Total_played_rounds>1,11,ifelse(u$Round_label==u$Total_played_rounds & u$Total_played_rounds>1,13,12)))
u$one_shot <- as.numeric(u$repeated==1); u$first_repeated_round <- as.numeric(u$repeated==11)
u$non_last_round <- as.numeric(u$repeated==12); u$last_repeated_round <- as.numeric(u$repeated==13)
u$fifty <- as.numeric(u$decision_first_scale>=50); u$fifty_offer <- u$decision_first_scale*u$fifty
u$offer_one <- u$decision_first_scale*u$one_shot; u$fifty_one <- u$fifty*u$one_shot
u$fifty_offer_one <- u$fifty_offer*u$one_shot

fit1<-lm(decision_face_first~decision_first_scale+fifty+fifty_offer,data=u)
b<-coef(fit1); v<-vcovCL(fit1,cluster=~SessionID)
test<-function(sel,b,v){st<-sum(sel*b);z<-st/sqrt(t(sel)%*%v%*%sel);c(est=st,se=sqrt(t(sel)%*%v%*%sel),z=z,p=2*pnorm(-abs(z)))}
cat("Model1 coefs:",round(b,6),"\n")
cat("test d_f_s + f_o =0:",round(test(c(0,1,0,1),b,v),4),"\n")
cat("lincom fifty+50*f_o:",round(test(c(0,0,1,50),b,v),4),"\n")

cat("\n=== Model (2): + one_shot interactions, cluster ===\n")
fit2<-lm(decision_face_first~decision_first_scale+fifty+fifty_offer+one_shot+offer_one+fifty_one+fifty_offer_one,data=u)
b2<-coef(fit2); v2<-vcovCL(fit2,cluster=~SessionID)
print(coeftest(fit2,vcov=v2)[,c(1,2,4)])
cat("test d_f_s+f_o=0:",round(test(c(0,1,0,1,0,0,0,0),b2,v2),4),"\n")
cat("test +offer_one+f_o_o=0:",round(test(c(0,1,0,1,0,1,0,1),b2,v2),4),"\n")
cat("lincom fifty+50 f_o:",round(test(c(0,0,1,50,0,0,0,0),b2,v2),4),"\n")
cat("lincom fifty+fifty_one+50(f_o+f_o_o):",round(test(c(0,0,1,50,0,0,1,50),b2,v2),4),"\n")
cat("lincom fifty_one+50 f_o_o:",round(test(c(0,0,0,0,0,0,1,50),b2,v2),4),"\n")

cat("\n=== Reaction time (responder, one_shot, Tukey outlier) ===\n")
rt<-u[u$player!=0 & u$one_shot==1,]
q3<-quantile(rt$decisiontime,.75,na.rm=TRUE); q1<-quantile(rt$decisiontime,.25,na.rm=TRUE); iqr<-q3-q1
rt<-rt[!is.na(rt$decisiontime)&rt$decisiontime<=q3+3*iqr,]
cat("N rt",nrow(rt),"\n")
for(off in c(49,50)){for(d in c(1,0)){s<-rt[rt$offer_face_scale==off & rt$decision_second==d,"decisiontime"];cat("offer",off,"dec",d,"n",length(s),"mean",round(mean(s,na.rm=TRUE),2),"\n")}}
fifty_exact<-as.numeric(rt$offer_face_scale==50)
tt<-t.test(rt$decisiontime~fifty_exact)
cat("ttest decisiontime by fifty_exact: t=",tt$statistic,"df=",tt$parameter,"p=",tt$p.value,"\n")
