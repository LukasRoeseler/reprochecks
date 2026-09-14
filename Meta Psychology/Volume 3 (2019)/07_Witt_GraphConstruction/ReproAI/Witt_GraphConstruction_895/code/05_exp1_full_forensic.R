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
sAm <- function(A){ m<-aggregate(coef~cond,A,mean);s<-aggregate(coef~cond,A,sd); paste(round(m$coef,2),"(",round(s$coef,2),")",collapse=" / ") }
sB <- function(A){ m<-aggregate(bias~cond,A,mean);s<-aggregate(bias~cond,A,sd); paste(round(m$bias,0),"(",round(s$bias,0),")",collapse=" / ") }

d1 <- read.csv(file.path(wrk,"data","axisSize 1-24.csv"))
colnames(d1)[which(colnames(d1)=="axisRange")] <- "graphType"
d1 <- d1[d1$Subject<10,]
cat("EXP1 ---- excl {1,3} (table provenance)\n")
cat("A3 all-trial slopes :", sAm(slopes(d1,c(1,3))),"\n")
cat("A4 d>0.1 slopes     :", sAm(slopes(d1,c(1,3),1)),"\n")
cat("A5 bias             :", sB(slopes(d1,c(1,3))),"\n")
cat("   [Paper A3: Full .28(.10) SD .46(.13) Min .27(.03); A4: .17(.10) .42(.16) .07(.09); A5: -27(5) 1(4) 36(21)]\n")
cat("EXP1 ---- excl {1,8} (stated)\n")
cat("A3 :", sAm(slopes(d1,c(1,8)))," A4:", sAm(slopes(d1,c(1,8),1))," A5:", sB(slopes(d1,c(1,8))),"\n")
