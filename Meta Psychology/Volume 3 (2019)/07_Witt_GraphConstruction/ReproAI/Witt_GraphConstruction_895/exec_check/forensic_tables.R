# Forensic: identify which exclusion sets reproduce the cross-experiment tables A3/A4/A5
# for Exp1 and Exp3, since main-sample recompute differs.
options(stringsAsFactors=FALSE)
wrk<-"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
condCode<-function(g){g<-tolower(as.character(g));ifelse(g%in%c("full"),1L,ifelse(g%in%c("sd"),2L,ifelse(g%in%c("small","min","minimal"),3L,NA_integer_)))}
codeCorr<-function(e){o<-rep(NA_real_,length(e));o[e==0]<-1;o[e==1]<-1.5;o[e==3]<-2;o[e==5]<-3;o[e==8]<-4;o}
slopes<-function(dt,excl,dcrit=NULL){dt$corr<-codeCorr(dt$effectSize);dt$corrC<-dt$corr-2.5;dt$cond<-condCode(dt$graphType);dt<-dt[!is.na(dt$cond)&!is.na(dt$corr),]
  if(!is.null(dcrit))dt<-dt[dt$effectSize>dcrit,]; subjs<-sort(setdiff(unique(dt$Subject),excl)); out<-data.frame()
  for(s in subjs)for(cc in 1:3){d<-dt[dt$Subject==s&dt$cond==cc,];m<-lm(resp~corrC,data=d);out<-rbind(out,data.frame(subj=s,cond=cc,coef=coef(m)[2],bias=(coef(m)[1]-2.5)/2.5*100))};out}
sm<-function(A){md<-sapply(1:3,function(cc)mean(A$coef[A$cond==cc]));sdv<-sapply(1:3,function(cc)sd(A$coef[A$cond==cc]));sprintf("F %.2f(%.2f) S %.2f(%.2f) M %.2f(%.2f)",md[1],sdv[1],md[2],sdv[2],md[3],sdv[3])}
sb<-function(A){md<-sapply(1:3,function(cc)mean(A$bias[A$cond==cc]));sdv<-sapply(1:3,function(cc)sd(A$bias[A$cond==cc]));sprintf("F %.0f(%.0f) S %.0f(%.0f) M %.0f(%.0f)",md[1],sdv[1],md[2],sdv[2],md[3],sdv[3])}
d1<-read.csv(file.path(wrk,"data","axisSize 1-24.csv"));d1<-d1[d1$Subject<10,]
if("axisRange"%in%colnames(d1))colnames(d1)[colnames(d1)=="axisRange"]<-"graphType"
cat("TABLE A3 Exp1 target: F .28(.10) S .46(.13) M .27(.03)\n")
cat("  excl {1,8} (main):",sm(slopes(d1,c(1,8))),"\n")
cat("  excl {1,3}:       ",sm(slopes(d1,c(1,3))),"\n")
cat("  excl none:        ",sm(slopes(d1,c())),"\n")
cat("  excl {1}:         ",sm(slopes(d1,c(1))),"\n")
cat("  excl {8}:         ",sm(slopes(d1,c(8))),"\n")
cat("  excl {3}:         ",sm(slopes(d1,c(3))),"\n")
cat("TABLE A5 Exp1 bias target: F -27(5) S 1(4) M 36(21)\n")
cat("  excl {1,8}: ",sb(slopes(d1,c(1,8))),"\n")
cat("  excl {1,3}: ",sb(slopes(d1,c(1,3))),"\n")
cat("  excl none:  ",sb(slopes(d1,c())),"\n")
cat("  excl {1}:   ",sb(slopes(d1,c(1))),"\n")
cat("  excl {8}:   ",sb(slopes(d1,c(8))),"\n")

d3<-read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"))
cat("\nTABLE A3/A4/A5 Exp3 targets: A3 F.21(.08) S.58(.17) M.49(.15); A4 F.09(.06) S.46(.11) M.25(.13); A5 F-25(10) S14(13) M23(16)\n")
cat("A3 excl {3,4}(N11):",sm(slopes(d3,c(3,4))),"\n")
cat("A3 excl {2,3,4,5}(N9):",sm(slopes(d3,c(2,3,4,5))),"\n")
cat("A4 excl {3,4}(N11):",sm(slopes(d3,c(3,4),1)),"\n")
cat("A4 excl {2,3,4,5}(N9):",sm(slopes(d3,c(2,3,4,5),1)),"\n")
for(ex in list(c(3,4),c(2,3,4,5),c(2,3,4))){cat("A5 excl {",paste(ex,collapse=","),"}: ",sb(slopes(d3,ex)),"\n",sep="")}
cat("\n===== DONE =====\n")
