options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
cat("===== VERIFICATION: N, 57-claim, trials, Exp3 N=9 sub-analyses =====\n")

# --- recruited N per experiment ---
d12 <- read.csv(file.path(wrk,"data","axisSize 1-24.csv"))
e1 <- sort(unique(d12$Subject[d12$Subject < 10]))
e2 <- sort(unique(d12$Subject[d12$Subject >= 10]))
d3  <- read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"))
e3  <- sort(unique(d3$Subject))
d4  <- read.csv(file.path(wrk,"data","axisRangeLineV2 1-20.csv"))
e4  <- sort(unique(d4$Subject))
d5  <- read.csv(file.path(wrk,"data","axisRangeLine 1-14.csv"))
e5  <- sort(unique(d5$Subject))
cat("Exp1 recruited N =", length(e1), " subjects:", paste(e1, collapse=","), "\n")
cat("Exp2 recruited N =", length(e2), " subjects:", paste(e2, collapse=","), "\n")
cat("Exp3 recruited N =", length(e3), " subjects:", paste(e3, collapse=","), "\n")
cat("Exp4 recruited N =", length(e4), " subjects:", paste(e4, collapse=","), "\n")
cat("Exp5 recruited N =", length(e5), " subjects:", paste(e5, collapse=","), "\n")
cat("TOTAL recruited =", length(e1)+length(e2)+length(e3)+length(e4)+length(e5), " (manuscript says 57)\n\n")

# --- per-participant trial counts ---
cat("--- trials per participant (expect ~480 = 120 graphs x 4 blocks) ---\n")
for (nm in c("Exp1","Exp2","Exp3","Exp4","Exp5")) {
  if (nm=="Exp1") d <- d12[d12$Subject<10,]
  if (nm=="Exp2") d <- d12[d12$Subject>=10,]
  if (nm=="Exp3") d <- d3
  if (nm=="Exp4") d <- d4
  if (nm=="Exp5") d <- d5
  tc <- table(d$Subject)
  cat(nm, "trial counts: min=", min(tc), " max=", max(tc), " unique=", length(tc),
      " non-480:", paste(names(tc[tc!=480]), collapse="->", ""), "\n", sep="")
  cat("   values:", paste(names(tc), tc, sep="=", collapse=" "), "\n")
}

# --- effect sizes and graph types present ---
cat("\n--- effect sizes / graph types per exp ---\n")
cat("Exp1 effectSize:", paste(sort(unique(d12$effectSize)), collapse=","),
    " axisRange:", paste(sort(unique(d12$axisRange)), collapse=","), "\n")
cat("Exp3 effectSize:", paste(sort(unique(d3$effectSize)), collapse=","),
    " graphType:", paste(sort(unique(d3$graphType)), collapse=","), "\n")
cat("Exp4 effectSize:", paste(sort(unique(d4$effectSize)), collapse=","),
    " graphType:", paste(sort(unique(d4$graphType)), collapse=","), "\n")
cat("Exp5 effectSize:", paste(sort(unique(d5$effectSize)), collapse=","),
    " graphType:", paste(sort(unique(d5$graphType)), collapse=","), "\n")

# --- Exp 3 sub-analyses with CORRECT exclusions ---
cat("\n===== Exp 3 sub-analyses (manuscript N=9, excludes 2,3,4,5) =====\n")
condCode <- function(g){ g<-tolower(as.character(g)); ifelse(g %in% c("full"),1L,ifelse(g %in% c("sd"),2L,ifelse(g %in% c("small","min","minimal"),3L,NA_integer_))) }
d3$corr <- ifelse(d3$effectSize==0,1,NA)
d3$corr[d3$effectSize==1] <- 1.5
d3$corr[d3$effectSize==3] <- 2
d3$corr[d3$effectSize==5] <- 3
d3$corr[d3$effectSize==8] <- 4
d3$corrC <- d3$corr - 2.5
d3$cond <- condCode(d3$graphType)
d3 <- d3[!is.na(d3$cond),]
excl9 <- c(2,3,4,5)
subjs <- sort(setdiff(unique(d3$Subject), excl9))
cat("Exp3 sub-analysis N =", length(subjs), " subjects:", paste(subjs, collapse=","), "\n")
slopes <- function(dt, excl, mode){
  if(mode=="eff") dt<-dt[dt$effectSize>1,]
  if(mode=="noeff") dt<-dt[dt$effectSize<5,]
  ss<-sort(setdiff(unique(dt$Subject),excl)); out<-data.frame()
  for(s in ss) for(cc in 1:3){ d<-dt[dt$Subject==s & dt$cond==cc,]
    m<-lm(resp~scale(corr,scale=F,center=T),data=d); out<-rbind(out,data.frame(subj=s,cond=cc,coef=coef(m)[2])) }
  out
}
for (mode in c("eff","noeff")) {
  A <- slopes(d3, excl9, mode)
  w <- data.frame(subj=sort(unique(A$subj)))
  for(cc in 1:3){ sub<-A[A$cond==cc,c("subj","coef")]; w[[paste0("c",cc)]]<-sub$coef[match(w$subj,sub$subj)] }
  n<-length(w$subj)
  t.test<-function(x,y){t.test(x,y,paired=TRUE)}
  p1<-t.test(w$c2,w$c1); cat("  [d>0.1] SDvsFull t(",n-1,")=",round(p1$statistic,2), " dz=",round(abs(p1$statistic)/sqrt(n),2), " p=",round(p1$p.value,3),"\n",sep="")
  p2<-t.test(w$c3,w$c2); cat("  [d>0.1] MinvsSD  t(",n-1,")=",round(p2$statistic,2), " dz=",round(abs(p2$statistic)/sqrt(n),2), " p=",round(p2$p.value,3),"\n",sep="")
  p3<-t.test(w$c2,w$c1); # placeholder
}
# recompute with BayesFactor
suppressMessages(library(BayesFactor))
Aeff <- slopes(d3, excl9, "eff")
Anoe <- slopes(d3, excl9, "noeff")
mkwide <- function(A){ w<-data.frame(subj=sort(unique(A$subj))); for(cc in 1:3){sub<-A[A$cond==cc,c("subj","coef")]; w[[paste0("c",cc)]]<-sub$coef[match(w$subj,sub$subj)]}; w }
we<-mkwide(Aeff); wn<-mkwide(Anoe); n<-length(we$subj)
bf <- function(tval){ exp(as.numeric(BayesFactor::ttest.tstat(t=as.numeric(tval),n1=n,rscale=0.707)[['bf']])) }
cat("\n  EXP3 d>0.1 (N=",n,"):\n",sep="")
p<-t.test(we$c2,we$c1,paired=TRUE); cat("   SDvsFull: t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," BF=",round(bf(p$statistic),2),"\n")
p<-t.test(we$c3,we$c2,paired=TRUE); cat("   MinvsSD : t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," BF=",round(bf(p$statistic),2),"\n")
cat("  EXP3 d=0-.3 (N=",n,"):\n",sep="")
p<-t.test(wn$c2,wn$c1,paired=TRUE); cat("   SDvsFull: t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," BF=",round(bf(p$statistic),2),"\n")
p<-t.test(wn$c3,wn$c2,paired=TRUE); cat("   MinvsSD : t=",round(p$statistic,2)," dz=",round(abs(p$statistic)/sqrt(n),2)," BF=",round(bf(p$statistic),2),"\n")
cat("\n===== DONE =====\n")
