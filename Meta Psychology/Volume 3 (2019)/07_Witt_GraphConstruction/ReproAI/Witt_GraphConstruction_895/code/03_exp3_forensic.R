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
sA <- function(A,nrcats=F){ m<-aggregate(coef~cond,A,mean);s<-aggregate(coef~cond,A,sd)
  if(nrcats) paste(round(m$coef,2),"(",round(s$coef,2),")",collapse=" / ") else paste(round(m$coef,3),"(",round(s$coef,3),")",collapse=" / ") }
sB <- function(A){ m<-aggregate(bias~cond,A,mean);s<-aggregate(bias~cond,A,sd); paste(round(m$bias,1),"(",round(s$bias,1),")",collapse=" / ") }

d3 <- read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"))
cat("== EXP3 all-trial slopes ==\n"); cat("excl 3,4  :",sA(slopes(d3,c(3,4)),T),"\n"); cat("excl 2,3,4,5:",sA(slopes(d3,c(2,3,4,5)),T),"\n")
cat("== EXP3 d>0.1 slopes (Table A4) ==\n"); cat("excl 3,4  :",sA(slopes(d3,c(3,4),1),T),"\n"); cat("excl 2,3,4,5:",sA(slopes(d3,c(2,3,4,5),1),T),"\n")
cat("== EXP3 bias (Table A5) ==\n"); cat("excl 3,4  :",sB(slopes(d3,c(3,4))),"\n"); cat("excl 2,3,4,5:",sB(slopes(d3,c(2,3,4,5))),"\n")
cat("   [Table A3: Full .21(.08) SD .58(.17) Min .49(.15); A4: Full .09(.06) SD .46(.11) Min .25(.13); A5: Full -25(10) SD 14(13) Min 23(16)]\n")
