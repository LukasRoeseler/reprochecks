# 04b_scratch_sim_bayes.R -- saves the independent from-scratch Bayesian posterior-passing
# trajectory + C38/C39 to disk. Same run as 04 (SEED 20260914, e=1, var=1, 20 expts) but
# without the (computationally prohibitive in base R) full-pool mega MCMC; C37 is covered by
# 05_scratch_bayes_mega.R (pooled analysis) and the EXACT shipped-table check (cor=0.9999).
source("pg_gibbs.R")
suppressMessages({library(lme4)})

SEED <- 20260914; set.seed(SEED)
n_people <- 1000000L; n_ppt <- 80L; n_trial <- 25L
e <- 1; v <- 1; NEX <- 20
create_population <- function(var_base){ d_base <- rnorm(n_people/4,0,var_base); d_base <- c(d_base,-d_base,d_base,-d_base); data.frame(id=1:n_people, sex=c(rep(0,n_people/2),rep(1,n_people/2)), d_base) }
create_datasets <- function(pop,e){
  lapply(1:NEX, function(experiment){
    s0 <- sample(1:(n_people/2), n_ppt/2); s1 <- sample(((n_people/2)+1):n_people, n_ppt/2)
    pps <- pop[c(s0,s1),]; dum <- c(rep(0,n_ppt/4),rep(1,n_ppt/4)); tc <- c(sample(dum,n_ppt/2),sample(dum,n_ppt/2))
    lp <- 0 + pps$d_base + e*pps$sex*tc; prob <- plogis(lp)
    resp <- vapply(1:n_ppt, function(i) mean(runif(n_trial,0,1)<prob[i]), numeric(1))
    data.frame(pid=1:n_ppt, sex=pps$sex, condition=tc, resp=resp, trials=n_trial)
  })
}
pop <- create_population(v); datlist <- create_datasets(pop, e)
Xfun <- function(d) with(d, cbind(1, sex, condition, sex*condition))

NI <- 2500; BU <- 500
all_med <- all_lo <- all_hi <- numeric(NEX)
prev <- c(0,10)
for (x in 1:NEX) {
  d <- datlist[[x]]
  post <- fit_bayes(d$resp*d$trials, d$trials, Xfun(d), d$pid, pp_beta4=if(x==1) NULL else prev, n_iter=NI, burnin=BU)
  s <- summ_beta4(post)
  all_med[x]<-s["median"]; all_lo[x]<-s["lo"]; all_hi[x]<-s["hi"]; prev <- c(s["median"],s["sd"])
}

d1 <- datlist[[1]]
pb1 <- fit_bayes(d1$resp*d1$trials, d1$trials, Xfun(d1), d1$pid, n_iter=NI, burnin=BU)
bglmm_first <- median(pb1[,4])
g1 <- glmer(cbind(resp*n_trial,(1-resp)*n_trial) ~ sex + condition + sex*condition + (1|pid), family=binomial, data=d1)
glmm_first <- as.numeric(fixef(g1)["sex:condition"])

df <- data.frame(expt=1:NEX, pp_median=all_med, pp_lo=all_lo, pp_hi=all_hi, true_e=e)
write.csv(df, file.path("output","scratch_bayes_pp_trajectory.csv"), row.names=FALSE)
sink(file.path("output","scratch_bayes_key.txt"))
cat("SEED",SEED,"e",e,"var",v,"NEX",NEX,"n_iter",NI,"burnin",BU,"\n")
cat("C38 bglmm_first",bglmm_first,"glmm_first",glmm_first,"\n")
cat("C39 pp_expt5",all_med[5],"pp_expt10",all_med[10],"pp_expt15",all_med[15],"pp_final",all_med[NEX],"\n")
cat("PP final CI",all_lo[NEX],all_hi[NEX]," -> excludes 0 (C30 positive):",(all_lo[NEX]>0|all_hi[NEX]<0),"\n")
sink()
cat("PP final =", all_med[NEX], "C38 bglmm_first =", bglmm_first, "glmm_first =", glmm_first, "\n")
cat("WROTE output/scratch_bayes_pp_trajectory.csv + scratch_bayes_key.txt\n")
