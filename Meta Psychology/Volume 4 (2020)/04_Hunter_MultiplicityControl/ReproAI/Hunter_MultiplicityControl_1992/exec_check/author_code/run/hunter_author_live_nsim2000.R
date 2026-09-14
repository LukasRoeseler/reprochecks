# Multiplicity Control vs Replication
# One-way ANOVA Design

library(WRS2)
library(effsize)
library(metafor)


alpha<-.05
cohend_cut<-.3

#Number of Simulations
nsim<-2000


# Number of Replications = 2



#### Simulation Conditions ####

### Mean configurations
## Complete Type I error
#popmn<-c(0,0,0,0)
#popmn<-c(0,0,0,0,0,0,0)

## Type I Error and/or Power
#popmn<-c(0,8,16,24)
#popmn<-c(0,0,0,8)
#popmn<-c(0,0,8,8)
popmn<-c(0,8,16,24,32,40,48)
#popmn<-c(0,0,0,0,0,0,8)
#popmn<-c(0,0,0,0,8,8,8)

## Determine Number of Groups and Calculate
## Number of Pairwise Comparisons
ngroup<-length(popmn)
npair<-choose(ngroup,2)

### Standard deviations
popsd<-rep(20,ngroup)

### Sample sizes 
sampsz<-100
n<-rep(sampsz,ngroup)


# This section below specifies whether the pairwise comparisons are
# Type I errors (0) or Power (1) conditions
pairw<-c(numeric(choose(length(popmn),2)))
cc<-0
for (aa in 1:(length(popmn)-1)) {
  for (bb in (aa+1):length(popmn)) {
    cc<-cc+1
    ifelse(popmn[aa]==popmn[bb],pairw[cc]<-0,pairw[cc]<-1) 
  }
}

# Sets up specifics common to all simulations
tests<-c("bonf","holm","nocontrol","nc_replicated","nc_2reps","bonf_replicated",
         "bonf_2reps","holm_replicated","holm_2reps","meta_an_1rep","meta_an_2reps",
        "cohend","cohend_1rep","cohend_2reps")
numtests<-length(tests)

# Creates results matrix to store familywise error and power rates
results<-matrix(data=NA,nrow=nsim,ncol=3*npair)
res_cohd<-matrix(data=NA,nrow=nsim,ncol=3*npair)
#var_cohd<-matrix(data=NA,nrow=nsim,ncol=(nrep+1)*npair)
meta_d<-matrix(data=NA,nrow=nsim,ncol=3*npair)
meta_vard<-matrix(data=NA,nrow=nsim,ncol=3*npair)
ma_p_1rep<-matrix(data=NA,nrow=1,ncol=npair)
ma_p_2rep<-matrix(data=NA,nrow=1,ncol=npair)
fwe<-matrix(data=0,nrow=1,ncol=numtests,dimnames=list("rate",tests))
anypower<-matrix(data=0,nrow=1,ncol=numtests) #any pair power
pppower<-matrix(data=0,nrow=nsim,ncol=numtests) #per pair power
allpower<-matrix(data=0,nrow=1,ncol=numtests) #all pairs power


#### Simulation ####
# Simulate data
iv<-rep(1:ngroup,n)
iv<-factor(iv)
dv<-numeric()
dv_rep<-numeric()
for (i in 1:nsim) {
  for (j in 1:ngroup) {
    ifelse(j==1,dv<-rnorm(n[j],mean=popmn[j],sd=popsd[j]),
           dv<-c(dv,rnorm(n[j],mean=popmn[j],sd=popsd[j])))
    ifelse(j==1,dv_rep1<-rnorm(n[j],mean=popmn[j],sd=popsd[j]),
           dv_rep1<-c(dv_rep1,rnorm(n[j],mean=popmn[j],sd=popsd[j])))
    ifelse(j==1,dv_rep2<-rnorm(n[j],mean=popmn[j],sd=popsd[j]),
           dv_rep2<-c(dv_rep2,rnorm(n[j],mean=popmn[j],sd=popsd[j])))
    
  }
  k=0
  for (a in 1:(ngroup-1)) {      
    for (b in (a+1):ngroup) {
      k=k+1
        results[i,k]<-t.test(dv[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$p.value
        results[i,(k+npair)]<-t.test(dv_rep1[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$p.value
        results[i,(k+npair*2)]<-t.test(dv_rep2[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$p.value
        res_cohd[i,k]<-cohen.d(dv[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$estimate
        res_cohd[i,(k+npair)]<-cohen.d(dv_rep1[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$estimate
        res_cohd[i,(k+npair*2)]<-cohen.d(dv_rep2[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$estimate
        
        #        var_cohd[i,k]<-cohen.d(dv[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$var
#        var_cohd[i,(k+npair)]<-cohen.d(dv_rep[iv==a | iv==b]~factor(iv[iv==a | iv==b]),var.equal=TRUE)$var
         meta_d[i,k]<-escalc(measure="SMD",m1i=mean(dv[iv==a]),m2i=mean(dv[iv==b]),
                           sd1i=sd(dv[iv==a]),sd2i=sd(dv[iv==b]),
                           n1i=length(dv[iv==a]),n2i=length(dv[iv==b]))$yi
         meta_d[i,(k+npair)]<-escalc(measure="SMD",m1i=mean(dv_rep1[iv==a]),m2i=mean(dv_rep1[iv==b]),
                             sd1i=sd(dv_rep1[iv==a]),sd2i=sd(dv_rep1[iv==b]),
                             n1i=length(dv_rep1[iv==a]),n2i=length(dv_rep1[iv==b]))$yi  
         meta_d[i,(k+npair*2)]<-escalc(measure="SMD",m1i=mean(dv_rep2[iv==a]),m2i=mean(dv_rep2[iv==b]),
                                     sd1i=sd(dv_rep2[iv==a]),sd2i=sd(dv_rep2[iv==b]),
                                     n1i=length(dv_rep2[iv==a]),n2i=length(dv_rep2[iv==b]))$yi  
         meta_vard[i,k]<-escalc(measure="SMD",m1i=mean(dv[iv==a]),m2i=mean(dv[iv==b]),
                             sd1i=sd(dv[iv==a]),sd2i=sd(dv[iv==b]),
                             n1i=length(dv[iv==a]),n2i=length(dv[iv==b]))$vi
         meta_vard[i,(k+npair*2)]<-escalc(measure="SMD",m1i=mean(dv_rep1[iv==a]),m2i=mean(dv_rep1[iv==b]),
                                     sd1i=sd(dv_rep1[iv==a]),sd2i=sd(dv_rep1[iv==b]),
                                     n1i=length(dv_rep1[iv==a]),n2i=length(dv_rep1[iv==b]))$vi  
         meta_vard[i,(k+npair)]<-escalc(measure="SMD",m1i=mean(dv_rep2[iv==a]),m2i=mean(dv_rep2[iv==b]),
                                        sd1i=sd(dv_rep2[iv==a]),sd2i=sd(dv_rep2[iv==b]),
                                        n1i=length(dv_rep2[iv==a]),n2i=length(dv_rep2[iv==b]))$vi  
    }
  }

  #Meta-Analysis p-values for each pair - 1 replication
  for (m in 1:npair) {
    cd1<-data.frame(c(meta_d[i,m],meta_d[i,m+npair]),c(meta_vard[i,m],meta_vard[i,m+npair]),c(rep(sampsz,2)))
    names(cd1)<-c("cohensd","cohendvar","n")
    ma_p_1rep[1,m]<-rma(data=cd1,yi=cohensd,vi=cohendvar,method="FE",measure="SMD")$pval
  }
  
  #Meta-Analysis p-values for each pair - 2 replications
  for (m in 1:npair) {
    cd2<-data.frame(c(meta_d[i,m],meta_d[i,m+npair],meta_d[i,m+npair*2]),c(meta_vard[i,m],meta_vard[i,m+npair],meta_vard[i,m+npair*2]),
                   c(rep(sampsz,3)))
    names(cd2)<-c("cohensd","cohendvar","n")
    ma_p_2rep[1,m]<-rma(data=cd2,yi=cohensd,vi=cohendvar,method="FE",measure="SMD")$pval
  }
  
  #Cohen's d effect size analysis for each pair
  res_cohd<-abs(res_cohd)
  cd_0rep<-numeric(npair)
  cd_1rep<-numeric(npair)
  cd_2rep<-numeric(npair)
  for (m in 1:npair) {
    ifelse(res_cohd[i,m]>=cohend_cut,
           cd_0rep[m]<-1,
           cd_0rep[m]<-0)
    ifelse(res_cohd[i,m]>=cohend_cut &
             res_cohd[i,npair+m]>=cohend_cut,
           cd_1rep[m]<-1,
           cd_1rep[m]<-0)
    ifelse(res_cohd[i,m]>=cohend_cut &
             res_cohd[i,npair+m]>=cohend_cut &
             res_cohd[i,npair*2+m]>=cohend_cut,
           cd_2rep[m]<-1,
           cd_2rep[m]<-0)
  }
  
  
  # Multiple comparison procedures  
 
  # Manipulate the pvalues from the current simulation so they are 
  # in order from smallest to largest
  # This is done to facilitate stopping rules for the Holm procedure
  test<-1:npair
  pvalues<-results[i,1:npair][order(results[i,1:npair])]
  pvalues_rep1<-results[i,(npair+1):(npair*2)][order(results[i,(npair+1):(npair*2)])]
  pvalues_rep2<-results[i,(npair*2+1):(npair*3)][order(results[i,(npair*2+1):(npair*3)])]
  
  test_orig<-test[order(results[i,1:npair])]
  #cohd<-res_cohd[i,1:npair][order(res_cohd[i,1:npair])]
  #cohd<-res_cohd[i,(npair+1):(npair*2)][order(res_cohd[i,(npair+1):(npair*2)])]
  power<-pairw[order(results[i,1:npair])]
  power_rep1<-pairw[order(results[i,(npair+1):(npair*2)])]
  test_rep1<-test[order(results[i,(npair+1):(npair*2)])]
  power_rep2<-pairw[order(results[i,(npair*+1):(npair*3)])]
  test_rep2<-test[order(results[i,(npair*2+1):(npair*3)])]
  
  

    # Familywise error rates
  
  # Meta-Analysis
  ifelse(sum(ma_p_1rep[pairw==0]<=alpha)>0,fwe[1,10]<-fwe[1,10]+1,fwe[1,10]<-fwe[1,10])
  ifelse(sum(ma_p_2rep[pairw==0]<=alpha)>0,fwe[1,11]<-fwe[1,11]+1,fwe[1,11]<-fwe[1,11])
  
  # Cohen's D
  ifelse(sum(cd_0rep[pairw==0])>0,fwe[1,12]<-fwe[1,12]+1,fwe[1,12]<-fwe[1,12])  
  ifelse(sum(cd_1rep[pairw==0])>0,fwe[1,13]<-fwe[1,13]+1,fwe[1,13]<-fwe[1,13])  
  ifelse(sum(cd_2rep[pairw==0])>0,fwe[1,14]<-fwe[1,14]+1,fwe[1,14]<-fwe[1,14])  
  
  # Bonferroni
  bonfpvalues<-pvalues*npair
  # fwe for Bonferroni
  ifelse(sum(bonfpvalues[power==0]<=alpha)>0,fwe[1,1]<-fwe[1,1]+1,fwe[1,1]<-fwe[1,1])
  
  # Holm
  hpvalues<-p.adjust(pvalues,method="holm")
    # Stopping Rules for Holm
  holmpvalues<-numeric(npair)
  hpdecis<-hpvalues<=alpha
  ifelse(sum(hpdecis)==length(power), kk<-length(power), kk<-min(which(hpdecis!=TRUE)))
  for (m in 1:length(power)) {
    ifelse(m<=kk, holmpvalues[m]<-hpvalues[m], holmpvalues[m]<-1)
  }
  # fwe for Holm
  ifelse(sum(holmpvalues[power==0]<=alpha)>0,fwe[1,2]<-fwe[1,2]+1,fwe[1,2]<-fwe[1,2])
  
  # No control
  ncpvalues<-pvalues
  ncpvalues_rep1<-pvalues_rep1
  ncpvalues_rep2<-pvalues_rep2
  
  # fwe for No Control
  ifelse(sum(ncpvalues[power==0]<=alpha)>0,fwe[1,3]<-
           fwe[1,3]+1,fwe[1,3]<-fwe[1,3])
  
  # FWE for No Control with 1 Replication
  nc_1rep<-numeric(npair)
  for (m in 1:npair) {
    ifelse(ncpvalues[which(test_orig==m)]<=alpha &
           ncpvalues_rep1[which(test_rep1==m)]<=alpha,
           nc_1rep[which(test_orig==m)]<-1,
           nc_1rep[which(test_orig==m)]<-0)
  }
  ifelse(sum(nc_1rep[power==0])>0,fwe[1,4]<-fwe[1,4]+1,
         fwe[1,4]<-fwe[1,4])
  
  # FWE for No Control with 2 Replications
  nc_2rep<-numeric(npair)
  for (m in 1:npair) {
    ifelse(ncpvalues[which(test_orig==m)]<=alpha &
             ncpvalues_rep1[which(test_rep1==m)]<=alpha &
             ncpvalues_rep2[which(test_rep2==m)]<=alpha,
           nc_2rep[which(test_orig==m)]<-1,
           nc_2rep[which(test_orig==m)]<-0)
  }
  ifelse(sum(nc_2rep[power==0])>0,fwe[1,5]<-fwe[1,5]+1,
         fwe[1,5]<-fwe[1,5])
  
  # FWE for Bonferroni with Replication
  bonfpvalues_rep1<-pvalues_rep1*npair
  bonf_1rep<-numeric(npair)
  bonfpvalues_rep2<-pvalues_rep2*npair
  bonf_2rep<-numeric(npair)
  for (m in 1:npair) {
    ifelse(bonfpvalues[which(test_orig==m)]<=alpha &
             bonfpvalues_rep1[which(test_rep1==m)]<=alpha,
           bonf_1rep[which(test_orig==m)]<-1,
           bonf_1rep[which(test_orig==m)]<-0)
    ifelse(bonfpvalues[which(test_orig==m)]<=alpha &
             bonfpvalues_rep1[which(test_rep1==m)]<=alpha &
             bonfpvalues_rep2[which(test_rep2==m)]<=alpha,
           bonf_2rep[which(test_orig==m)]<-1,
           bonf_2rep[which(test_orig==m)]<-0)
  }
  ifelse(sum(bonf_1rep[power==0])>0,fwe[1,6]<-fwe[1,6]+1,
         fwe[1,6]<-fwe[1,6])
  ifelse(sum(bonf_2rep[power==0])>0,fwe[1,7]<-fwe[1,7]+1,
         fwe[1,7]<-fwe[1,7])
  
  # FWE for Holm with Replication
  hpvalues_rep1<-p.adjust(pvalues_rep1,method="holm")
  hpvalues_rep2<-p.adjust(pvalues_rep2,method="holm")
  # Stopping Rules for Holm
  holmpvalues_1rep<-numeric(npair)
  holmpvalues_2rep<-numeric(npair)
  hpdecis_rep1<-hpvalues_rep1<=alpha
  hpdecis_rep2<-hpvalues_rep2<=alpha

  ifelse(sum(hpdecis_rep1)==length(power), jj<-length(power), jj<-min(which(hpdecis_rep1!=TRUE)))
  for (q in 1:length(power)) {
    ifelse(q<=jj, holmpvalues_1rep[q]<-hpvalues_rep1[q], holmpvalues_1rep[q]<-1)
  }
  ifelse(sum(hpdecis_rep2)==length(power), kk<-length(power), kk<-min(which(hpdecis_rep2!=TRUE)))  
  for (q in 1:length(power)) {
    ifelse(q<=kk, holmpvalues_2rep[q]<-hpvalues_rep2[q], holmpvalues_2rep[q]<-1)
  }
  
  holm_1rep<-numeric(npair)
  holm_2rep<-numeric(npair)
  for (m in 1:npair) {
    ifelse(holmpvalues[which(test_orig==m)]<=alpha &
             holmpvalues_1rep[which(test_rep1==m)]<=alpha,
           holm_1rep[which(test_orig==m)]<-1,
           holm_1rep[which(test_orig==m)]<-0)
    ifelse(holmpvalues[which(test_orig==m)]<=alpha &
             holmpvalues_1rep[which(test_rep1==m)]<=alpha &
             holmpvalues_2rep[which(test_rep2==m)]<=alpha,
           holm_2rep[which(test_orig==m)]<-1,
           holm_2rep[which(test_orig==m)]<-0)
  }
  ifelse(sum(holm_1rep[power==0])>0,fwe[1,8]<-fwe[1,8]+1,
         fwe[1,8]<-fwe[1,8])
  ifelse(sum(holm_2rep[power==0])>0,fwe[1,9]<-fwe[1,9]+1,
         fwe[1,9]<-fwe[1,9])
  

  
  
  # Power
  
  # Per pair power for Bonferroni, Holm, NC, NC with Rep
  pppower[i,1]<-sum(bonfpvalues[power==1]<=alpha)
  pppower[i,2]<-sum(holmpvalues[power==1]<=alpha)
  pppower[i,3]<-sum(ncpvalues[power==1]<=alpha)
  pppower[i,4]<-sum(nc_1rep[power==1])
  pppower[i,5]<-sum(nc_2rep[power==1])
  pppower[i,6]<-sum(bonf_1rep[power==1])
  pppower[i,7]<-sum(bonf_2rep[power==1])
  pppower[i,8]<-sum(holm_1rep[power==1])
  pppower[i,9]<-sum(holm_2rep[power==1])
  pppower[i,10]<-sum(ma_p_1rep[pairw==1]<=alpha)
  pppower[i,11]<-sum(ma_p_2rep[pairw==1]<=alpha)
  pppower[i,12]<-sum(cd_0rep[pairw==1])
  pppower[i,13]<-sum(cd_1rep[pairw==1])
  pppower[i,14]<-sum(cd_2rep[pairw==1])
  
  # All pairs power for Bonferroni, Holm, NC, NC with Rep
  ifelse(sum(bonfpvalues[power==1]<=alpha)==sum(power),
         allpower[1,1]<-allpower[1,1]+1,allpower[1,1]<-allpower[1,1])
  ifelse(sum(holmpvalues[power==1]<=alpha)==sum(power),
         allpower[1,2]<-allpower[1,2]+1,allpower[1,2]<-allpower[1,2])
  ifelse(sum(ncpvalues[power==1]<=alpha)==sum(power),
         allpower[1,3]<-allpower[1,3]+1,allpower[1,3]<-allpower[1,3])
  ifelse(sum(nc_1rep[power==1])==sum(power),
         allpower[1,4]<-allpower[1,4]+1,allpower[1,4]<-allpower[1,4])
  ifelse(sum(nc_2rep[power==1])==sum(power),
         allpower[1,5]<-allpower[1,5]+1,allpower[1,5]<-allpower[1,5])
  ifelse(sum(bonf_1rep[power==1])==sum(power),
         allpower[1,6]<-allpower[1,6]+1,allpower[1,6]<-allpower[1,6])
  ifelse(sum(bonf_2rep[power==1])==sum(power),
         allpower[1,7]<-allpower[1,7]+1,allpower[1,7]<-allpower[1,7])
  ifelse(sum(holm_1rep[power==1])==sum(power),
         allpower[1,8]<-allpower[1,8]+1,allpower[1,8]<-allpower[1,8])
  ifelse(sum(holm_2rep[power==1])==sum(power),
         allpower[1,9]<-allpower[1,9]+1,allpower[1,9]<-allpower[1,9])
  ifelse(sum(ma_p_1rep[pairw==1]<=alpha)==sum(pairw),
         allpower[1,10]<-allpower[1,10]+1,allpower[1,10]<-allpower[1,10])
  ifelse(sum(ma_p_2rep[pairw==1]<=alpha)==sum(pairw),
         allpower[1,11]<-allpower[1,11]+1,allpower[1,11]<-allpower[1,11])
  ifelse(sum(cd_0rep[pairw==1])==sum(pairw),
         allpower[1,12]<-allpower[1,12]+1,allpower[1,12]<-allpower[1,12])
  ifelse(sum(cd_1rep[pairw==1])==sum(pairw),
         allpower[1,13]<-allpower[1,13]+1,allpower[1,13]<-allpower[1,13])
  ifelse(sum(cd_2rep[pairw==1])==sum(pairw),
         allpower[1,14]<-allpower[1,14]+1,allpower[1,14]<-allpower[1,14])
}

#### Results ####
pp<-NA
allp<-NA
if (sum(pairw>0)) {
  pp<-colMeans(pppower/sum(pairw)) 
  allp<-allpower/nsim 
 pp<-t(as.matrix(pp))
 colnames(pp)<-tests
 colnames(allp)<-tests
}

#Conditions
popmn
popsd
n

#Familywise Error Rates
fwe/nsim # Overall familywise error rate

#Per Pair Power Rates
#Average power across each (power) comparison
pp
#All Pairs Power Rates
#Average power of rejecting all power comparisons
allp

#rm(list=ls())
