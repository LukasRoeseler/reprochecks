options(stringsAsFactors=FALSE)
wrk<-"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
suppressMessages(library(BayesFactor));library(psych);set.seed(42)
condCode<-function(g){g<-tolower(as.character(g));ifelse(g%in%c("full"),1L,ifelse(g%in%c("sd"),2L,ifelse(g%in%c("small","min","minimal"),3L,NA_integer_)))}
codeCorr<-function(e){o<-rep(NA_real_,length(e));o[e==0]<-1;o[e==1]<-1.5;o[e==3]<-2;o[e==5]<-3;o[e==8]<-4;o}
A<-function(excl){d1<-read.csv(file.path(wrk,"data","axisSize 1-24.csv"));d1<-d1[d1$Subject<10,]
  if("axisRange"%in%colnames(d1))colnames(d1)[colnames(d1)=="axisRange"]<-"graphType"
  d1$corr<-codeCorr(d1$effectSize);d1$corrC<-d1$corr-2.5;d1$cond<-condCode(d1$graphType);d1<-d1[!is.na(d1$cond)&!is.na(d1$corr),]
  subjs<-sort(setdiff(unique(d1$Subject),excl));o<-data.frame()
  for(s in subjs)for(cc in 1:3){d<-d1[d1$Subject==s&d1$cond==cc,];m<-lm(resp~corrC,data=d);o<-rbind(o,data.frame(subj=s,cond=cc,coef=coef(m)[2],bias=(coef(m)[1]-2.5)/2.5*100))};o}
mk<-function(o){w<-data.frame(subj=sort(unique(o$subj)));for(cc in 1:3){s<-o[o$cond==cc,];w[[paste0("c",cc)]]<-s$coef[match(w$subj,s$subj)]};w}
for(ex in list(c(1,8),c(1,3))){
  o<-A(ex);w<-mk(o);n<-nrow(w)
  t<-t.test(w$c2,w$c1,paired=TRUE)$statistic
  cat("Exp1 excl {",paste(ex,collapse=","),"} N=",n,": Std M=",round(mean(w$c2),2)," Full M=",round(mean(w$c1),2),
      " Min M=",round(mean(w$c3),2)," | t(SDvsFull)=",round(t,3)," dz=",round(abs(t)/sqrt(n),3),"\n",sep="")
}
