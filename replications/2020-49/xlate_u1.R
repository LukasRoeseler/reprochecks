suppressMessages({library(haven);library(sandwich);library(lmtest);library(dplyr)})
d<-"C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/9mfws/data_and_code"
u<-read_dta(file.path(d,"ultimatum_game","data","ultimatum.dta"))
cat("ultimatum dims",dim(u),"\n")
cat("cols:",paste(names(u),collapse=", "),"\n")
# Variables per do file
u$repeated <- ifelse(u$Total_played_rounds==1,1,ifelse(u$Round_label==1 & u$Total_played_rounds>1,11,ifelse(u$Round_label==u$Total_played_rounds & u$Total_played_rounds>1,13,12)))
u$one_shot <- as.numeric(u$repeated==1)
u$first_repeated_round <- as.numeric(u$repeated==11)
u$non_last_round <- as.numeric(u$repeated==12)
u$last_repeated_round <- as.numeric(u$repeated==13)
u$fifty <- as.numeric(u$decision_first_scale>=50)
u$fifty_offer <- u$decision_first_scale*u$fifty
u$offer_one <- u$decision_first_scale*u$one_shot
u$offer_first <- u$decision_first_scale*u$first_repeated_round
u$fifty_one <- u$fifty*u$one_shot
u$fifty_offer_one <- u$fifty_offer*u$one_shot
cat("\n=== Model (1): decision_face_first ~ decision_first_scale + fifty + fifty_offer, cluster SessionID ===\n")
m1<-lm(decision_face_first~decision_first_scale+fifty+fifty_offer,data=u)
cm1<-coeftest(m1,vcov=vcovCL(m1,cluster=~SessionID))
print(cm1)
# test decision_first_scale + fifty_offer = 0
b<-coef(m1); v<-vcovCL(m1,cluster=~SessionID)
lin<-c(decision_first_scale=1,fifty=0,fifty_offer=1)
test_stat<-sum(lin*b); test_var<-t(lin)%*%v%*%lin; z<-test_stat/sqrt(test_var)
cat("\ntest decision_first_scale + fifty_offer = 0: est=",test_stat," z=",z," p=",2*pnorm(-abs(z)),"\n")
# lincom fifty + 50*fifty_offer
lin2<-c(decision_first_scale=0,fifty=1,fifty_offer=50)
est2<-sum(lin2*b); v2<-t(lin2)%*%v%*%lin2; z2<-est2/sqrt(v2)
cat("lincom fifty + 50*fifty_offer:",est2," z=",z2," p=",2*pnorm(-abs(z2)),"\n")
