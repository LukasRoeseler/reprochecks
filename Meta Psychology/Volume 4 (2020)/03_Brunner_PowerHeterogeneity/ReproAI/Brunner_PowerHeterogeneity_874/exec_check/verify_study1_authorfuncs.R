# ReproAI: Test whether the AUTHOR's recovered estimator functions (scalar df2),
# applied to variable-n significant-F data at a FIXED representative df2=84,
# reproduce Table 1 (Study 1, F df=1). Compares p-curve2.1 / p-uniform / ML / z-curve.
source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/estimatR_raw.txt")

set.seed(20260914)
alpha <- 0.05; MEANN <- 86
FIXN <- 84
rn_sig <- function(k) pmax(rpois(k, MEANN), 3)
expPower_f2 <- function(f2){ n<-pmax(rpois(2e5,MEANN),3); c<-qf(1-alpha,1,n-2); mean(1-pf(c,1,n-2,n*f2)) }
findF2 <- function(target){ if(target<=0.05) return(0); uniroot(function(f2) expPower_f2(f2)-target,c(1e-4,4))$root }

tab <- list(
  "0.05" = c(pcurve=.059,punif=.058,ml=.057,zcurve=.049),
  "0.25" = c(pcurve=.253,punif=.251,ml=.251,zcurve=.280),
  "0.50" = c(pcurve=.497,punif=.496,ml=.497,zcurve=.508),
  "0.75" = c(pcurve=.747,punif=.746,ml=.747,zcurve=.723)
)

nsims <- 1500; k <- 100
out <- character()
cat("Author functions at fixed df2=84 on variable-n data (k=100), mean over", nsims, "sims\n")
for (tp in c(.25,.50,.75)) {
  f2 <- findF2(tp)
  pc<-pu<-ml<-zc<-numeric(nsims); nfail<-0
  for (s in 1:nsims) {
    n <- rn_sig(k); ncp <- n*f2; crit <- qf(1-alpha,1,n-2)
    g <- 1-pf(crit,1,n-2,ncp); U<-runif(k); FF <- qf(1-g*U,1,n-2,ncp)
    pv <- pf(FF,1,n-2,lower.tail=FALSE)
    pc[s] <- tryCatch(heteroNpcurveF(FF,1,FIXN), error=function(e) NA_real_)
    pu[s] <- tryCatch(heteroNpunifF(FF,1,FIXN,CI=F), error=function(e) NA_real_)
    ml[s] <- tryCatch(heteroNmleF(FF,1,FIXN,CI=F,warn=F), error=function(e) NA_real_)
    zc[s] <- tryCatch(suppressWarnings(zcurve(pv,Plot=0,Verbose=F)), error=function(e) NA_real_)
    if(any(is.na(c(pc[s],pu[s],ml[s],zc[s])))) nfail<-nfail+1
  }
  paper <- tab[[sprintf("%.2f",tp)]]
  for (nm in c("pcurve","punif","ml","zcurve")) {
    v<-switch(nm,pcurve=pc,punif=pu,ml=ml,zcurve=zc); o<-!is.na(v)
    m<-mean(v[o]); se<-sd(v[o])/sqrt(sum(o))
    cat(sprintf("true=%.2f %-6s : est=%.3f (SE=%.4f) paper=%.3f delta=%.3f fail=%d\n",
        tp,nm,m,se,paper[[nm]],m-paper[[nm]],nfail))
    out<-c(out,sprintf("true=%.2f %-6s : est=%.3f paper=%.3f delta=%.3f",tp,nm,m,paper[[nm]],m-paper[[nm]]))
  }
}
dir.create("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output", showWarnings=FALSE, recursive=TRUE)
writeLines(out,"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/output/study1_authorfuncs_results.txt")
cat("Done.\n")
