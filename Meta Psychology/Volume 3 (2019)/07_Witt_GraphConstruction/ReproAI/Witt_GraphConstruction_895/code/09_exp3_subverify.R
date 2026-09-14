options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
condCode <- function(g){g<-tolower(as.character(g));ifelse(g%in%c("full"),1L,ifelse(g%in%c("sd"),2L,ifelse(g%in%c("small","min","minimal"),3L,NA_integer_)))}
slopes<-function(dt,excl,mode){dt$corr<-ifelse(dt$effectSize==0,1,NA);dt$corr[dt$effectSize==1]<-1.5;dt$corr[dt$effectSize==3]<-2;dt$corr[dt$effectSize==5]<-3;dt$corr[dt$effectSize==8]<-4;dt$corrC<-dt$corr-2.5;dt$cond<-condCode(dt$graphType);dt<-dt[!is.na(dt$cond),];if(mode=="eff")dt<-dt[dt$effectSize>1,];if(mode=="noeff")dt<-dt[dt$effectSize<5,];S<-sort(setdiff(unique(dt$Subject),excl));o<-data.frame();for(s in S)for(cc in 1:3){d<-dt[dt$Subject==s&dt$cond==cc,];if(mode=="all"){m<-lm(resp~corrC,data=d)}else{m<-lm(resp~scale(corr,scale=F,center=T),data=d)};o<-rbind(o,data.frame(cond=cc,coef=coef(m)[2]))};o}
repC<-function(A){m<-aggregate(coef~cond,A,mean);s<-aggregate(coef~cond,A,sd);cat(" full",round(m$coef[1],2),"(" ,round(s$coef[1],2),") sd",round(m$coef[2],2),"(",round(s$coef[2],2),") min",round(m$coef[3],2),"(",round(s$coef[3],2),")\n")}
d3<-read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"))
cat("EXP3 magnitude(.3-.8) excl{2,3,4,5}: "); repC(slopes(d3,c(2,3,4,5),"eff"))
cat("  prose: full .09(.06) sd .46(.11) min .25(.13)\n")
cat("EXP3 noeffect(0-.3) excl{2,3,4,5}: "); repC(slopes(d3,c(2,3,4,5),"noeff"))
cat("  prose: full .49(.22) sd .89(.40) min 1.02(.45)\n")
