options(stringsAsFactors=FALSE)
wrk<-"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
condCode<-function(g){g<-tolower(as.character(g));ifelse(g%in%c("full"),1L,ifelse(g%in%c("sd"),2L,ifelse(g%in%c("small","min","minimal"),3L,NA_integer_)))}
mkdec<-function(f,subjf=NULL){dt<-read.csv(file.path(wrk,"data",f),stringsAsFactors=FALSE)
  if("axisRange"%in%colnames(dt))colnames(dt)[colnames(dt)=="axisRange"]<-"graphType"
  if(!is.null(subjf))dt<-dt[subjf(dt),];dt$cond<-condCode(dt$graphType);dt<-dt[!is.na(dt$cond),];dt}
subs<-list(
  list(d=mkdec("axisSize 1-24.csv",function(d)d$Subject<10),excl=c(1,8)),
  list(d=mkdec("axisSize 1-24.csv",function(d)d$Subject>9),excl=c(13,17,24)),
  list(d=mkdec("axisRangeEBv2 1-14.csv"),excl=c(3,4)),
  list(d=mkdec("axisRangeLineV2 1-20.csv"),excl=c(4,9,15,16)),
  list(d=mkdec("axisRangeLine 1-14.csv"),excl=c(7,13)))
NM<-c("Exp1","Exp2","Exp3","Exp4","Exp5")
pct<-function(d,cond,crit){n<-nrow(d); if(n==0)return(NA); 100*sum(crit)/n}
cat("=== minimal condition, '+'big'(resp==4) ===\n")
for(i in 1:5){d<-subs[[i]]$d[!subs[[i]]$d$Subject%in%subs[[i]]$excl,];mn<-d[d$cond==3,]
  cat(sprintf("%s: all n=%d big=%.1f%% | d>0.1 n=%d big=%.1f%% | d==.8 n=%d big(resp4)=%.1f%% med+big=%.1f%%\n",
    NM[i],nrow(mn),100*sum(mn$resp==4)/nrow(mn),sum(mn$effectSize>1),100*sum(mn$resp[mn$effectSize>1]==4)/sum(mn$effectSize>1),
    sum(mn$effectSize==8),100*sum(mn$resp[mn$effectSize==8]==4)/sum(mn$effectSize==8),
    100*sum(mn$resp>2)/nrow(mn)))}
cat("\n=== full condition null/small (resp<3) ===\n")
for(i in 1:5){d<-subs[[i]]$d[!subs[[i]]$d$Subject%in%subs[[i]]$excl,];fl<-d[d$cond==1,]
  cat(sprintf("%s: all n=%d ns=%.1f%% | d>0.1 n=%d ns=%.1f%%\n",NM[i],nrow(fl),100*sum(fl$resp<3)/nrow(fl),sum(fl$effectSize>1),100*sum(fl$resp[fl$effectSize>1]<3)/sum(fl$effectSize>1)))}
cat("\n=== POOLED across all 5 (with exclusions) ===\n")
all<-do.call(rbind,lapply(subs,function(s)s$d[!s$d$Subject%in%s$excl,]))
mn<-all[all$cond==3,];fl<-all[all$cond==1,]
cat("pooled minimal big (all):",sprintf("%.1f%%",100*sum(mn$resp==4)/nrow(mn)),
    " big d>0.1:",sprintf("%.1f%%",100*sum(mn$resp[mn$effectSize>1]==4)/sum(mn$effectSize>1)),
    " med+big(all):",sprintf("%.1f%%",100*sum(mn$resp>2)/nrow(mn)),"\n")
cat("pooled full null/small (all):",sprintf("%.1f%%",100*sum(fl$resp<3)/nrow(fl)),
    " (d>0.1):",sprintf("%.1f%%",100*sum(fl$resp[fl$effectSize>1]<3)/sum(fl$effectSize>1)),"\n")
cat("\n===== DONE =====\n")
