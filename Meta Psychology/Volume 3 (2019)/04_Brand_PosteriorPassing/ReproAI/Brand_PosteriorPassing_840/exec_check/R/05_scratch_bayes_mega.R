# 05_scratch_bayes_mega.R -- C37 demonstration: PP(final) vs a POOLED all-data analysis.
# The author's mega-BGLMM pools all 60 experiments into one dataset with a random effect
# per participant (1 observation per participant -> essentially a fixed-effects pooling;
# with a gamma(0.01,0.01) prior the participant effects shrink to ~0). Here we recompute,
# on the SAME data as 04 (seed 20260914, e=1, var=1, 20 experiments), the pooled logistic
# interaction (raw glm + glmer, the latter mirroring the author's random-per-participant
# structure) and compare to the from-scratch PP final from 04.
suppressMessages({library(lme4)})
SEED <- 20260914; set.seed(SEED)
n_people <- 1000000L; n_ppt <- 80L; n_trial <- 25L; e <- 1; v <- 1; NEX <- 20
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
datlist <- create_datasets(create_population(v), e)
pooled <- do.call(rbind, lapply(seq_along(datlist), function(i){ d<-datlist[[i]]; d$pid <- i*10000+d$pid; d }))

m_glm <- glm(cbind(resp*n_trial,(1-resp)*n_trial) ~ sex*condition, family=binomial, data=pooled)
m_glmer <- glmer(cbind(resp*n_trial,(1-resp)*n_trial) ~ sex + condition + sex*condition + (1|pid), family=binomial, data=pooled, nAGQ=0)

pp_final <- 0.815   # from 04_scratch_sim_bayes.R, expt 20 (see scratch_bayes_pp_trajectory.csv)
cat("\n=== C37 PP(final) vs pooled all-data analysis (same data) ===\n")
cat(sprintf("PP final (from 04, expt 20)   = %.3f\n", pp_final))
cat(sprintf("Pooled fixed-effects glm  int = %.3f\n", as.numeric(coef(m_glm)["sex:condition"])))
cat(sprintf("Pooled glmer (RE/ppt)     int = %.3f\n", as.numeric(fixef(m_glmer)["sex:condition"])))

sink(file.path("output","scratch_bayes_mega_key.txt"))
cat("pp_final(04,expt20)", pp_final, "\n")
cat("pooled glm interaction", as.numeric(coef(m_glm)["sex:condition"]), "\n")
cat("pooled glmer interaction", as.numeric(fixef(m_glmer)["sex:condition"]), "\n")
sink()
cat("WROTE output/scratch_bayes_mega_key.txt\n")
