options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
suppressMessages(library(BayesFactor))
condCode <- function(g){ g<-tolower(as.character(g)); ifelse(g %in% c("full"),1L,ifelse(g %in% c("sd"),2L,ifelse(g %in% c("small","min","minimal"),3L,NA_integer_))) }
d3 <- read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"))
d3$corr <- ifelse(d3$effectSize==0,1,NA)
d3$corr[d3$effectSize==1] <- 1.5
d3$corr[d3$effectSize==3] <- 2
d3$corr[d3$effectSize==5] <- 3
d3$corr[d3$effectSize==8] <- 4
d3$corrC <- d3$corr - 2.5
d3$cond <- condCode(d3$graphType)
d3 <- d3[!is.na(d3$cond),]
excl9 <- c(2,3,4,5)
slopes <- function(dt, excl, mode){
  if(mode=="eff") dt<-dt[dt$effectSize>1,]
  if(mode=="noeff") dt<-dt[dt$effectSize<5,]
  ss<-sort(setdiff(unique(dt$Subject),excl)); out<-data.frame()
  for(s in ss) for(cc in 1:3){ d<-dt[dt$Subject==s & dt$cond==cc,]
    m<-lm(resp~scale(corr,scale=F,center=T),data=d); out<-rbind(out,data.frame(subj=s,cond=cc,coef=coef(m)[2])) }
  out
}
mkwide <- function(A){ w<-data.frame(subj=sort(unique(A$subj))); for(cc in 1:3){sub<-A[A$cond==cc,c("subj","coef")]; w[[paste0("c",cc)]]<-sub$coef[match(w$subj,sub$subj)]}; w }
bf <- function(tval,n){ exp(as.numeric(BayesFactor::ttest.tstat(t=as.numeric(tval),n1=n,rscale=0.707)[['bf']])) }
ptt <- function(x,y){ t.test(x,y,paired=TRUE) }
cat("===== Exp 3 sub-analyses (manuscript: N=9, df=8) =====\n")
we <- mkwide(slopes(d3, excl9, "eff")); wn <- mkwide(slopes(d3, excl9, "noeff"))
n <- length(we$subj)
cat("N =", n, " (df =", n-1, ")\n\n")
cat("[d=.3-.8 magnitude analysis]\n")
p<-ptt(we$c2,we$c1); cat("  SD vs Full:    t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," p=",round(p$p.value,4)," BF=",round(bf(p$statistic,n),2),"\n")
p<-ptt(we$c3,we$c2); cat("  Min vs SD:     t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," p=",round(p$p.value,4)," BF=",round(bf(p$statistic,n),2),"\n")
cat("[d=0-.3 presence analysis]\n")
p<-ptt(wn$c2,wn$c1); cat("  SD vs Full:    t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," p=",round(p$p.value,4)," BF=",round(bf(p$statistic,n),2),"\n")
p<-ptt(wn$c3,wn$c2); cat("  Min vs SD:     t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," p=",round(p$p.value,4)," BF=",round(bf(p$statistic,n),2),"\n")
cat("mean slopes (d>0.1):\n  full", round(mean(we$c1),2), " sd", round(mean(we$c2),2), " min", round(mean(we$c3),2), "\n")
cat("mean slopes (d=0-.3):\n  full", round(mean(wn$c1),2), " sd", round(mean(wn$c2),2), " min", round(mean(wn$c3),2), "\n")
cat("===== DONE =====\n")
