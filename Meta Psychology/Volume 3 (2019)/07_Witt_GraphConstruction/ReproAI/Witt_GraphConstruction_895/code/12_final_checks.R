options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
condCode <- function(g){ g<-tolower(as.character(g)); ifelse(g %in% c("full"),1L,ifelse(g %in% c("sd"),2L,ifelse(g %in% c("small","min","minimal"),3L,NA_integer_))) }
slopesAll <- function(dt, excl){
  ss<-sort(setdiff(unique(dt$Subject),excl)); out<-data.frame()
  for(s in ss) for(cc in 1:3){ d<-dt[dt$Subject==s & dt$cond==cc,]
    m<-lm(resp~corrC,data=d); out<-rbind(out,data.frame(subj=s,cond=cc,coef=coef(m)[2])) }
  out
}
mkwide <- function(A){ w<-data.frame(subj=sort(unique(A$subj))); for(cc in 1:3){sub<-A[A$cond==cc,c("subj","coef")]; w[[paste0("c",cc)]]<-sub$coef[match(w$subj,sub$subj)]}; w }
cat("===== Table A3 Exp3 all-trial: N=11 (excl 3,4) vs N=9 (excl 2,3,4,5) =====\n")
d3 <- read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"))
d3$corr <- ifelse(d3$effectSize==0,1,NA); d3$corr[d3$effectSize==1]<-1.5; d3$corr[d3$effectSize==3]<-2; d3$corr[d3$effectSize==5]<-3; d3$corr[d3$effectSize==8]<-4
d3$corrC <- d3$corr-2.5; d3$cond <- condCode(d3$graphType); d3 <- d3[!is.na(d3$cond),]
w11 <- mkwide(slopesAll(d3, c(3,4))); w9 <- mkwide(slopesAll(d3, c(2,3,4,5)))
cat("N=11: full", round(mean(w11$c1),2),"(",round(sd(w11$c1),2),")  sd", round(mean(w11$c2),2),"(",round(sd(w11$c2),2),")  min", round(mean(w11$c3),2),"(",round(sd(w11$c3),2),")\n")
cat("N=9 : full", round(mean(w9$c1),2),"(",round(sd(w9$c1),2),")  sd", round(mean(w9$c2),2),"(",round(sd(w9$c2),2),")  min", round(mean(w9$c3),2),"(",round(sd(w9$c3),2),")\n")
cat("Manuscript Table A3 Exp3: full .21(.08)  sd .58(.17)  min .49(.15)\n")
cat("Manuscript main text Exp3: full .24(.09)  sd .62(.19)  min .55(.20)\n\n")

cat("===== Percentage claims (pooled across 5 exps, d>0.1 where noted) =====\n")
# full: % resp 1 or 2 (no/small) across all full trials
# minimal: % resp==4 (big) for effectSize>1; % resp>2 (med/big) for effectSize>1
d12 <- read.csv(file.path(wrk,"data","axisSize 1-24.csv"))
d4 <- read.csv(file.path(wrk,"data","axisRangeLineV2 1-20.csv"))
d5 <- read.csv(file.path(wrk,"data","axisRangeLine 1-14.csv"))
d12$graphType <- d12$axisRange
allfull <- rbind(d12[d12$graphType=="full",], d3[d3$graphType=="full",], d4[d4$graphType=="Full",], d5[d5$graphType=="Full",])
allmin  <- rbind(d12[d12$graphType=="small",], d3[d3$graphType=="small",], d4[d4$graphType=="Small",], d5[d5$graphType=="Small",])
cat("full: % resp<=2 (no/small), all trials:", round(100*mean(allfull$resp<=2),1), "%  (manuscript ~86%)\n")
m_big  <- allmin[allmin$effectSize>1,]
cat("minimal: % resp==4 (big) for d>0.1:", round(100*mean(m_big$resp==4),1), "%  (manuscript ~49%)\n")
cat("minimal: % resp>2 (med/big) for d>0.1:", round(100*mean(m_big$resp>2),1), "%  (manuscript ~88% Exp1 / pooled)\n")

# pooled bias %
cat("\n===== Pooled bias % (full/sd/min) across 5 exps =====\n")
allsd <- rbind(d12[d12$graphType=="sd",], d3[d3$graphType=="SD",], d4[d4$graphType=="SD",], d5[d5$graphType=="SD",])
# per-subject intercept bias, pooled
biasSubj <- function(dt, cc){
  ss<-sort(unique(dt$Subject)); out<-c()
  for(s in ss){ d<-dt[dt$Subject==s & dt$cond==cc,]; if(nrow(d)>=5){m<-lm(resp~corrC,data=d); out<-c(out,(coef(m)[1]-2.5)/2.5*100)} }
  out
}
# use combined dataset with cond coded
full <- rbind(d12[d12$graphType=="full",c("Subject","resp","corrC")], d3[d3$graphType=="full",c("Subject","resp","corrC")], d4[d4$graphType=="Full",c("Subject","resp","corrC")], d5[d5$graphType=="Full",c("Subject","resp","corrC")])
sdg  <- rbind(d12[d12$graphType=="sd",c("Subject","resp","corrC")], d3[d3$graphType=="SD",c("Subject","resp","corrC")], d4[d4$graphType=="SD",c("Subject","resp","corrC")], d5[d5$graphType=="SD",c("Subject","resp","corrC")])
minm <- rbind(d12[d12$graphType=="small",c("Subject","resp","corrC")], d3[d3$graphType=="small",c("Subject","resp","corrC")], d4[d4$graphType=="Small",c("Subject","resp","corrC")], d5[d5$graphType=="Small",c("Subject","resp","corrC")])
cat("Python cross-check gave pooled bias full/sd/min: -24.51 / 4.5 / 20.93\n")
cat("===== DONE =====\n")
