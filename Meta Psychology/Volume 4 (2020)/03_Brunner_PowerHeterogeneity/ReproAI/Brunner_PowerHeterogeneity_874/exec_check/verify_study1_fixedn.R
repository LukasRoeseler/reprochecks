# ReproAI: Fully-FIXED sample-size case (both data generation AND estimation at df2=84).
# Determines whether the author's recovered functions reproduce Table 1 Study 1 columns
# when the entire pipeline uses a single representative sample size (n=86, df2=84), i.e.
# when the estimator "ignores" per-study n heterogeneity.
source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/estimatR_raw.txt")
set.seed(20260914)
alpha<-0.05; d1<-1; d2<-84; k<-100
crit<-qf(1-alpha,d1,d2)
tab<-list(
 "0.05"=c(pcurve=.059,punif=.058,ml=.057,zcurve=.049),
 "0.25"=c(pcurve=.253,punif=.251,ml=.251,zcurve=.280),
 "0.50"=c(pcurve=.497,punif=.496,ml=.497,zcurve=.508),
 "0.75"=c(pcurve=.747,punif=.746,ml=.747,zcurve=.723))
nsims<-1500
out<-character()
cat("Fully-fixed n (df2=84 both simulate & estimate), k=100, mean over",nsims,"sims\n")
for(tp in c(.05,.25,.50,.75)){
  ncp<-uniroot(function(x) pf(crit,d1,d2,x)-(1-tp),c(0,200))$root
  pc<-pu<-ml<-zc<-numeric(nsims); nfail<-0
  for(s in 1:nsims){
    FF<-rsigF(k,d1,d2,ncp)
    pv<-pf(FF,d1,d2,lower.tail=FALSE)
    pc[s]<-tryCatch(heteroNpcurveF(FF,d1,d2),error=function(e) NA_real_)
    pu[s]<-tryCatch(heteroNpunifF(FF,d1,d2,CI=F),error=function(e) NA_real_)
    ml[s]<-tryCatch(heteroNmleF(FF,d1,d2,CI=F,warn=F),error=function(e) NA_real_)
    zc[s]<-tryCatch(suppressWarnings(zcurve(pv,Plot=0,Verbose=F)),error=function(e) NA_real_)
    if(any(is.na(c(pc[s],pu[s],ml[s],zc[s])))) nfail<-nfail+1
  }
  paper<-tab[[sprintf("%.2f",tp)]]
  for(nm in c("pcurve","punif","ml","zcurve")){
    v<-switch(nm,pcurve=pc,punif=pu,ml=ml,zcurve=zc); o<-!is.na(v)
    m<-mean(v[o]); se<-sd(v[o])/sqrt(sum(o))
    cat(sprintf("true=%.2f %-6s : est=%.3f (SE=%.4f) paper=%.3f delta=%.3f fail=%d\n",
        tp,nm,m,se,paper[[nm]],m-paper[[nm]],nfail))
    out<-c(out,sprintf("true=%.2f %-6s : est=%.3f paper=%.3f delta=%.3f",tp,nm,m,paper[[nm]],m-paper[[nm]]))
  }
}
dir.create("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output",showWarnings=FALSE,recursive=TRUE)
writeLines(out,"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output/study1_fixedn_results.txt")
cat("Done.\n")
