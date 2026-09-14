# ReproAI re-audit verification script: cross-experiment tables, N, trial counts,
# pooled percentages, and the Exp3 sub-analysis dz/BF denominator hypothesis.
options(stringsAsFactors=FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
suppressMessages(library(BayesFactor)); library(psych)
set.seed(42)
condCode <- function(g){g<-tolower(as.character(g)); ifelse(g%in%c("full"),1L,ifelse(g%in%c("sd"),2L,ifelse(g%in%c("small","min","minimal"),3L,NA_integer_)))}
codeCorr <- function(e){o<-rep(NA_real_,length(e)); o[e==0]<-1;o[e==1]<-1.5;o[e==3]<-2;o[e==5]<-3;o[e==8]<-4;o}

run <- function(f, excl, subjf=NULL, dcrit=NULL){
  dt<-read.csv(file.path(wrk,"data",f),stringsAsFactors=FALSE)
  if("axisRange"%in%colnames(dt)) colnames(dt)[colnames(dt)=="axisRange"]<-"graphType"
  if(!is.null(subjf)) dt<-dt[subjf(dt),]
  dt$corr<-codeCorr(dt$effectSize); dt$corrC<-dt$corr-2.5; dt$cond<-condCode(dt$graphType)
  dt<-dt[!is.na(dt$cond)&!is.na(dt$corr),]
  if(!is.null(dcrit)) dt<-dt[dt$effectSize>dcrit,]
  subjs<-sort(setdiff(unique(dt$Subject),excl))
  A<-data.frame()
  for(s in subjs) for(cc in 1:3){d<-dt[dt$Subject==s&dt$cond==cc,]; m<-lm(resp~corrC,data=d)
    A<-rbind(A,data.frame(subj=s,cond=cc,coef=coef(m)[2],intercept=coef(m)[1],bias=(coef(m)[1]-2.5)/2.5*100))}
  A
}
summ <- function(A,val){md<-sapply(1:3,function(cc)mean(A[[val]][A$cond==cc]));sdv<-sapply(1:3,function(cc)sd(A[[val]][A$cond==cc]))
  sprintf("Full %.2f(%.2f) | Std %.2f(%.2f) | Min %.2f(%.2f)",md[1],sdv[1],md[2],sdv[2],md[3],sdv[3])}

cat("============ TABLE A3 cross-experiment all-trial slopes (manuscript: E1 .28/.46/.27, E2 .31/.54/.30, E3 .21/.58/.49, E4 .30/.61/.61, E5 .32/.55/.53) ============\n")
cat("Exp1:",summ(run("axisSize 1-24.csv",c(1,8),function(d)d$Subject<10),"coef"),"\n")
cat("Exp2:",summ(run("axisSize 1-24.csv",c(13,17,24),function(d)d$Subject>9),"coef"),"\n")
cat("Exp3 N=11:",summ(run("axisRangeEBv2 1-14.csv",c(3,4)),"coef"),"\n")
cat("Exp3 N=9 :",summ(run("axisRangeEBv2 1-14.csv",c(2,3,4,5)),"coef"),"\n")
cat("Exp4:",summ(run("axisRangeLineV2 1-20.csv",c(4,9,15,16)),"coef"),"\n")
cat("Exp5:",summ(run("axisRangeLine 1-14.csv",c(7,13)),"coef"),"\n")

cat("\n============ TABLE A4 d>0.1 slopes (manuscript: E1 .17/.42/.07, E2 .18/.46/.13, E3 .09/.46/.25, E4 .15/.52/.31, E5 .20/.48/.36) ============\n")
cat("Exp1:",summ(run("axisSize 1-24.csv",c(1,8),function(d)d$Subject<10,dcrit=1),"coef"),"\n")
cat("Exp2:",summ(run("axisSize 1-24.csv",c(13,17,24),function(d)d$Subject>9,dcrit=1),"coef"),"\n")
cat("Exp3:",summ(run("axisRangeEBv2 1-14.csv",c(3,4),dcrit=1),"coef"),"\n")
cat("Exp4:",summ(run("axisRangeLineV2 1-20.csv",c(4,9,15,16),dcrit=1),"coef"),"\n")
cat("Exp5:",summ(run("axisRangeLine 1-14.csv",c(7,13),dcrit=1),"coef"),"\n")

cat("\n============ TABLE A5 bias (manuscript: E1 -27/1/36(SD5,4,21), E2 -28/6/31(9,9,21), E3 -25/14/23(10,13,16), E4 -26/2/19(11,10,17), E5 -15/6/12(17,14,20)) ============\n")
cat("Exp1:",summ(run("axisSize 1-24.csv",c(1,8),function(d)d$Subject<10),"bias"),"\n")
cat("Exp2:",summ(run("axisSize 1-24.csv",c(13,17,24),function(d)d$Subject>9),"bias"),"\n")
cat("Exp3 N=11:",summ(run("axisRangeEBv2 1-14.csv",c(3,4)),"bias"),"\n")
cat("Exp4:",summ(run("axisRangeLineV2 1-20.csv",c(4,9,15,16)),"bias"),"\n")
cat("Exp5:",summ(run("axisRangeLine 1-14.csv",c(7,13)),"bias"),"\n")

cat("\n============ N / trial counts ============\n")
d12<-read.csv(file.path(wrk,"data","axisSize 1-24.csv"))
cat("Recruited N per exp: E1=",length(unique(d12$Subject[d12$Subject<10])),
    " E2=",length(unique(d12$Subject[d12$Subject>=10])),"\n",sep="")
d3<-read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv")); d4<-read.csv(file.path(wrk,"data","axisRangeLineV2 1-20.csv")); d5<-read.csv(file.path(wrk,"data","axisRangeLine 1-14.csv"))
cat("Recruited N: E3=",length(unique(d3$Subject))," E4=",length(unique(d4$Subject))," E5=",length(unique(d5$Subject)),"\n",sep="")
cat("TOTAL recruited =",sum(c(9,14,length(unique(d3$Subject)),length(unique(d4$Subject)),length(unique(d5$Subject)))),"\n")
tcs <- function(d,nm){tc<-table(d$Subject); cat(nm," trial counts min=",min(tc)," max=",max(tc)," non480:",paste(names(tc[tc!=480]),tc[tc!=480],sep="=",collapse=" "),"\n")}
tcs(d12[d12$Subject<10,],"Exp1"); tcs(d12[d12$Subject>=10,],"Exp2"); tcs(d3,"Exp3"); tcs(d4,"Exp4"); tcs(d5,"Exp5")

cat("\n============ Exp3 sub-analysis dz/BF denominator test (t matches, does dz= t/sqrt(9) or t/sqrt(11)?) ============\n")
d3$corrC<-codeCorr(d3$effectSize)-2.5; d3$cond<-condCode(d3$graphType); d3<-d3[!is.na(d3$cond)&!is.na(d3$corrC),]
sub9<-sort(setdiff(unique(d3$Subject),c(2,3,4,5)))
mk <- function(crit){dd<-if(crit=="eff") d3[d3$effectSize>1,] else d3[d3$effectSize<5,]; w<-data.frame(subj=sub9)
  for(cc in 1:3) w[[paste0("c",cc)]]<-sapply(sub9,function(s){m<-lm(resp~corrC,data=dd[dd$Subject==s&dd$cond==cc,]);coef(m)[2]}); w}
for(crit in c("eff","no")){w<-mk(crit)
  for(pair in list(c("c2","c1"),c("c3","c2"))){
    t<-t.test(w[[pair[1]]],w[[pair[2]]],paired=TRUE)$statistic
    cat(crit,pair[1],"vs",pair[2],": t= ",round(t,3)," | t/sqrt(9)=",round(abs(t)/3,3)," t/sqrt(11)=",round(abs(t)/sqrt(11),3),
        " | BF n=9=",round(exp(as.numeric(BayesFactor::ttest.tstat(t=t,n1=9,rscale=0.707)[['bf']])),2),
        " BF n=11=",round(exp(as.numeric(BayesFactor::ttest.tstat(t=t,n1=11,rscale=0.707)[['bf']])),2),"\n")
  }
}
cat("\n============ pooled percentages (prose claims) ============\n")
mkdec <- function(f,subjf=NULL){dt<-read.csv(file.path(wrk,"data",f),stringsAsFactors=FALSE)
  if("axisRange"%in%colnames(dt)) colnames(dt)[colnames(dt)=="axisRange"]<-"graphType"
  if(!is.null(subjf)) dt<-dt[subjf(dt),]; dt$cond<-condCode(dt$graphType); dt<-dt[!is.na(dt$cond),]; dt}
subs <- list(
  list(d=mkdec("axisSize 1-24.csv",function(d)d$Subject<10),excl=c(1,8)),
  list(d=mkdec("axisSize 1-24.csv",function(d)d$Subject>9),excl=c(13,17,24)),
  list(d=mkdec("axisRangeEBv2 1-14.csv"),excl=c(3,4)),
  list(d=mkdec("axisRangeLineV2 1-20.csv"),excl=c(4,9,15,16)),
  list(d=mkdec("axisRangeLine 1-14.csv"),excl=c(7,13)))
# Fig 2 / main text pooled claims across all 5 experiments with per-exp exclusions.
full_ns_n<-0; full_ns<-0; full_d_n<-0; full_d_ns<-0
min_big_n<-0; min_big<-0; min_mb_n<-0; min_mb<-0
for(s in subs){ d<-s$d; excl<-s$excl; d<-d[!d$Subject%in%excl,]
  fl<-d[d$cond==1,]
  full_ns_n<-full_ns_n+nrow(fl); full_ns<-full_ns+sum(fl$resp<3)
  fld<-fl[fl$effectSize>1,]; full_d_n<-full_d_n+nrow(fld); full_d_ns<-full_d_ns+sum(fld$resp<3)
  mn<-d[d$cond==3,]
  mnd<-mn[mn$effectSize>1,]; min_big_n<-min_big_n+nrow(mnd); min_big<-min_big+sum(mnd$resp==4)
  min_mb_n<-min_mb_n+nrow(mn); min_mb<-min_mb+sum(mn$resp>2)
}
cat("full no/small (ALL trials):",sprintf("%.1f%%",100*full_ns/full_ns_n),"\n")
cat("full no/small (d>0.1 trials):",sprintf("%.1f%%",100*full_d_ns/full_d_n)," (manuscript Fig2: 86%)\n")
cat("minimal big (d>0.1 trials):",sprintf("%.1f%%",100*min_big/min_big_n)," (manuscript Fig3: 49%)\n")
cat("minimal medium+big (ALL trials):",sprintf("%.1f%%",100*min_mb/min_mb_n),"\n")
# Exp1-specific (prose "With the minimal graphs, 58% big, 88% medium/big")
e1d<-subs[[1]]$d; e1d<-e1d[!e1d$Subject%in%c(1,8),]; mn<-e1d[e1d$cond==3,]
cat("Exp1 minimal big (d>0.1):",sprintf("%.1f%%",100*sum((mn$effectSize>1)&(mn$resp==4))/sum(mn$effectSize>1)),
    " med+big (all):",sprintf("%.1f%%",100*sum(mn$resp>2)/nrow(mn)),"\n")
cat("Exp1 full no/small (all):",sprintf("%.1f%%",100*sum(e1d[e1d$cond==1,'resp']<3)/sum(e1d$cond==1)),"\n")
cat("\n===== DONE =====\n")

