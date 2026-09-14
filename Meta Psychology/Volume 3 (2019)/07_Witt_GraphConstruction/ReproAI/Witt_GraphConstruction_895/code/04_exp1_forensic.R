options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
condCode <- function(g){ g<-tolower(as.character(g)); ifelse(g %in% c("full"),1L,ifelse(g %in% c("sd"),2L,ifelse(g %in% c("small","min","minimal"),3L,NA_integer_))) }
slopes <- function(dt, excl, dcrit=NULL){
  dt$corr<-ifelse(dt$effectSize==0,1,NA); dt$corr[dt$effectSize==1]<-1.5; dt$corr[dt$effectSize==3]<-2; dt$corr[dt$effectSize==5]<-3; dt$corr[dt$effectSize==8]<-4
  dt$corrCentered<-dt$corr-2.5; dt$cond<-condCode(dt$graphType); dt<-dt[!is.na(dt$cond),]
  if(!is.null(dcrit)) dt<-dt[dt$effectSize>dcrit,]
  subjs<-sort(setdiff(unique(dt$Subject),excl)); out<-data.frame()
  for(s in subjs) for(cc in 1:3){ d<-dt[dt$Subject==s & dt$cond==cc,]
    if(is.null(dcrit)){m<-lm(resp~corrCentered,data=d); i<-coef(m)[1];b<-coef(m)[2]}
    else{m<-lm(resp~scale(corr,scale=F,center=T),data=d);i<-coef(m)[1];b<-coef(m)[2]}
    out<-rbind(out,data.frame(subj=s,cond=cc,coef=b,bias=(i-2.5)/2.5*100)) }
  out
}
vecM <- function(A){ m<-aggregate(coef~cond,A,mean);s<-aggregate(coef~cond,A,sd); c(m$coef,s$coef) }
# Table A3 target Exp1: full .28 .46 .27 (mean); SDs .10 .13 .03
d1 <- read.csv(file.path(wrk,"data","axisSize 1-24.csv"))
colnames(d1)[which(colnames(d1)=="axisRange")] <- "graphType"
d1 <- d1[d1$Subject<10,]
tgt <- c(.28,.46,.27)
cat("target Table A3 Exp1: Full .28 SD .46 Min .27\n")
best <- Inf; bestrow<-NULL
for(a in 1:9) for(b in a:9){ if(a==b) next; v<-round(vecM(slopes(d1,c(a,b)))[1:3],2); d<-sum(abs(v-tgt)); if(d<best){best<-d;bestrow<-c(a,b,v)} }
cat("closest 2-subject exclusion:", bestrow[1:2], "-> means", bestrow[3:5], "sumabs=",best,"\n")
cat("paper excl{1,8}: ", round(vecM(slopes(d1,c(1,8)))[1:3],2),"\n")
# also single exclusions
for(a in 1:9){ cat("excl",a,": ",round(vecM(slopes(d1,a))[1:3],2),"\n") }
