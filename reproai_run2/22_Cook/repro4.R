options(error=function(){traceback(); q(status=1)})
suppressMessages({library(haven);library(AER);library(sandwich);library(lmtest)})
df<-read_dta('package/comment replication package/DATASET_ETHNOATLAS.dta'); df$year<-as.numeric(df$year)
d<-df[!is.na(df$year),];d<-d[d$year>=1500,];d<-d[!is.na(d$Barley_point_cal),]
d$L_hier1<-ifelse(d$V33!=0,d$V33,NA)
d$cereals<-ifelse(d$V29==6,1,NA); d$cereals[is.na(d$cereals)&!is.na(d$V29)&d$V29!=0]<-0
v5lo<-c(0,6,16,26,36,46,56,66,76,86); v5hi<-c(5,15,25,35,45,55,65,75,85,100)
dep<-numeric(nrow(d)); for(i in 1:nrow(d)){k<-match(d$V5[i],0:9); if(!is.na(k)) dep[i]<-(v5lo[k]+(v5hi[k]-v5lo[k])/2)/100 else dep[i]<-NA}
d$depend_agric<-dep
ccols<-c('Barley_point_cal','Buckwheat_point_cal','Dryland_Rice_point_cal','Foxtail_Millet_point_cal','Maize_point_cal','Oat_point_cal','Pearl_Millet_point_cal','Rye_point_cal','Sorghum_point_cal','Wetland_Rice_point_cal','Wheat_point_cal')
tcols<-c('Cassava_point_cal','Sweet_Potato_point_cal','White_Potato_point_cal','Yams_point_cal')
d$mc1<-apply(d[ccols],1,max,na.rm=TRUE);d$mt<-apply(d[tcols],1,max,na.rm=TRUE)
d$diff<-d$mc1-d$mt;d$max<-pmax(d$mc1,d$mt)
stdz<-function(x){s<-sd(x,na.rm=TRUE);m<-mean(x,na.rm=TRUE);(x-m)/s}
d$std_max<-stdz(d$max); d$std_diff<-stdz(d$diff)
d$snd<-ifelse(d$mt!=0&d$mc1!=0,1,0); d$iso<-as.character(d$iso)
est<-d[!is.na(d$snd)&d$snd==1,]
est$c1<-as.numeric(est$dummy_continental3==1);est$c2<-as.numeric(est$dummy_continental3==2)
est$c3<-as.numeric(est$dummy_continental3==3);est$c4<-as.numeric(est$dummy_continental3==4)
est$c5<-as.numeric(est$dummy_continental3==5);est$c6<-as.numeric(est$dummy_continental3==6)
clv<-function(m,dat){coeftest(m,vcov=vcovCL(m,cluster=dat$iso,type='HC1'))}
FE<-'c1+c2+c3+c4+c6'

# OLS col1
m<-lm(L_hier1~cereals,data=est); ct<-clv(m,est); cat('OLS col1: Cer=',round(ct['cereals','Estimate'],3),' SE=',round(ct['cereals','Std. Error'],3),' p=',round(ct['cereals','Pr(>|t|)'],3),' N=',nobs(m),'\n')

# baseline (no winsor) col4 (with landprod)
m0<-ivreg(as.formula(paste('L_hier1~cereals+std_max+',FE,'|std_diff+std_max+',FE)),data=est); r<-clv(m0,est); cat('Baseline col4 Cer=',round(r['cereals','Estimate'],3),' p=',round(r['cereals','Pr(>|t|)'],3),'\n')

cat('\n--- Winsorization threshold sweep, col4 spec (CerMain) ---\n')
pcts<-c(0.005,0.012,0.021,0.03,0.04,0.05)
for(p in pcts){
  sq<-sort(est$std_diff[!is.na(est$std_diff)]); nw<-ceiling(p*length(sq)); cut<-sq[length(sq)-nw+1]
  wd<-pmin(est$std_diff,cut); est$wd<-wd
  m<-ivreg(as.formula(paste('L_hier1~cereals+std_max+',FE,'|wd+std_max+',FE)),data=est)
  r<-clv(m,est)
  cat(sprintf('winsor top p=%.3f (trim=%d, cut=%.3f): Cer=%.3f (SE=%.3f) p=%.3f\n',
      p, sum(est$std_diff>cut & !is.na(est$std_diff)), cut, r['cereals','Estimate'], r['cereals','Std. Error'], r['cereals','Pr(>|t|)']))
}

cat('\n--- Trimming check: drop top 1.2% & 3% obs (symmetric interpretation) ---\n')
sq<-sort(est$std_diff[!is.na(est$std_diff)])
for(p in c(0.012,0.03)){
  nt<-round(p*length(sq)); cut<-sq[length(sq)-nt]
  sub<-est[is.na(est$std_diff) | est$std_diff<=cut, ]
  m<-ivreg(as.formula(paste('L_hier1~cereals+std_max+',FE,'|std_diff+std_max+',FE)),data=sub)
  r<-clv(m,sub)
  cat(sprintf('drop top %.3f (n=%d removed): Cer=%.3f p=%.3f (N=%d)\n', p, nt, r['cereals','Estimate'], r['cereals','Pr(>|t|)'], nobs(m)))
}
