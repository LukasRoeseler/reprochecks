options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
condCode <- function(g){ g<-tolower(as.character(g)); ifelse(g %in% c("full"),1L,ifelse(g %in% c("sd"),2L,ifelse(g %in% c("small","min","minimal"),3L,NA_integer_))) }
slopes <- function(dt, excl, mode="all"){
  dt$corr<-ifelse(dt$effectSize==0,1,NA); dt$corr[dt$effectSize==1]<-1.5; dt$corr[dt$effectSize==3]<-2; dt$corr[dt$effectSize==5]<-3; dt$corr[dt$effectSize==8]<-4
  dt$corrC<-dt$corr-2.5; dt$cond<-condCode(dt$graphType); dt<-dt[!is.na(dt$cond),]
  if(mode=="eff") dt<-dt[dt$effectSize>1,]
  if(mode=="noeff") dt<-dt[dt$effectSize<5,]
  subjs<-sort(setdiff(unique(dt$Subject),excl)); out<-data.frame()
  for(s in subjs) for(cc in 1:3){ d<-dt[dt$Subject==s & dt$cond==cc,]
    if(mode=="all"){m<-lm(resp~corrC,data=d);i<-coef(m)[1];b<-coef(m)[2]}
    else{m<-lm(resp~scale(corr,scale=F,center=T),data=d);i<-coef(m)[1];b<-coef(m)[2]}
    out<-rbind(out,data.frame(subj=s,cond=cc,coef=b)) }
  out
}
repC <- function(A){ m<-aggregate(coef~cond,A,mean);cat("  full",round(m$coef[1],2)," sd",round(m$coef[2],2)," min",round(m$coef[3],2),"\n") }
for(exp in c(3,4,5)){
  f<-c(3,4,5)[exp-2]
  if(exp==3){df<-read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv")); excl<-c(3,4)}
  if(exp==4){df<-read.csv(file.path(wrk,"data","axisRangeLineV2 1-20.csv")); excl<-c(4,9,15,16)}
  if(exp==5){df<-read.csv(file.path(wrk,"data","axisRangeLine 1-14.csv")); excl<-c(7,13)}
  cat("== Exp",exp,"==\n")
  cat(" d>0.1 (.3-.8 slopes) [Table allDs>0]:\n"); repC(slopes(df,excl,"eff"))
  cat(" d=0-.3 slopes [Table]:\n"); repC(slopes(df,excl,"noeff"))
}
