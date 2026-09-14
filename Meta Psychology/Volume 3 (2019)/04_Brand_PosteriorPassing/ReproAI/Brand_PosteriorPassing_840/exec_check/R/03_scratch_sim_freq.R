# 03_scratch_sim_freq.R -- RE-AUDIT: INDEPENDENT from-scratch reimplementation
# of the paper's frequentist pipeline (data-generating model + ANOVA + GLMM).
# Purpose: verify the paper's method-level claims WITHOUT relying on the author's
# shipped results table. Fixed, documented seed. Author's conventions reproduced:
#   - population: doppelganger quadrangle, mean 0 exactly, within-sex variance equal
#   - DGM: p = plogis(b_base + d_base + b_sex*sex + b_cond*cond + e*sex*cond)
#   - ANOVA: 2x2 aov on mean response; interaction p via F test (p<.05 => positive)
#   - GLMM: glmer binomial with participant RE; Wald 95% CI excludes 0 => positive
# Expected (from paper): ~5% FP at e=0; ANOVA underestimates the (log-odds) effect;
# GLMM recovers e; TPR rises with e. The exact counts will differ (different seed)
# but the rates/patterns must match.

suppressMessages({library(lme4)})

SEED <- 20260914
set.seed(SEED)

n_people <- 1000000L
n_ex    <- 60L
n_ppt   <- 80L
n_trial <- 25L
Rrep    <- 4L
es  <- c(0, 0.5, 1, 1.5, 2)
vs  <- c(0, 0.25, 0.5, 0.75, 1)

create_population <- function(var_base) {
  id <- 1:n_people
  sex <- c(rep(0, n_people/2), rep(1, n_people/2))
  d_base <- rnorm(n_people/4, 0.0, var_base)
  d_base <- c(d_base, 0-d_base, d_base, 0-d_base)
  data.frame(id, sex, d_base)
}

create_datasets <- function(pop, e) {
  dat <- lapply(1:n_ex, function(experiment) {
    sex_0 <- sample(1:(n_people/2), n_ppt/2)
    sex_1 <- sample(((n_people/2)+1):n_people, n_ppt/2)
    pps <- pop[c(sex_0, sex_1), ]
    dum <- c(rep(0, n_ppt/4), rep(1, n_ppt/4))
    temp_cond <- c(sample(dum, n_ppt/2), sample(dum, n_ppt/2))
    lp <- 0 + pps$d_base + 0 + 0 + e*pps$sex*temp_cond
    prob <- plogis(lp)
    resp <- vapply(1:n_ppt, function(i) mean(runif(n_trial,0,1) < prob[i]), numeric(1))
    data.frame(data_set=experiment, pid=1:n_ppt, sex=pps$sex, condition=temp_cond, response=resp)
  })
  do.call(rbind, dat)
}

fit_one <- function(dat) {
  fit_anova <- tryCatch({
    m <- aov(response ~ sex * condition, data=dat)
    sm <- summary(m)[[1]]
    p_int <- sm$`Pr(>F)`[3]
    coefs <- coef(m)
    est_int <- if ("sex:condition" %in% names(coefs)) coefs["sex:condition"] else 0
    c(est=as.numeric(est_int), p=p_int)
  }, error=function(e) c(est=NA, p=NA))

  fit_glmm <- tryCatch({
    g <- glmer(cbind(response*n_trial,(1-response)*n_trial) ~ sex + condition + sex*condition + (1|pid),
               family=binomial, data=dat, nAGQ=0)
    fe <- fixef(g)
    ci <- confint(g, method="Wald", parm="sex:condition")
    c(est=as.numeric(fe["sex:condition"]), lo=as.numeric(ci[1]), hi=as.numeric(ci[2]))
  }, error=function(e) c(est=NA, lo=NA, hi=NA))

  c(anova_est=fit_anova[["est"]], anova_p=fit_anova[["p"]],
    glmm_est=fit_glmm[["est"]], glmm_lo=fit_glmm[["lo"]], glmm_hi=fit_glmm[["hi"]])
}

cat("SEED =", SEED, "| grid:", length(es), "e x", length(vs), "var x", Rrep, "repeats x", n_ex, "experiments\n\n")

res <- list()
k <- 0
for (e in es) {
  for (v in vs) {
    a_est <- a_pp <- g_est <- g_pos <- numeric()
    for (r in 1:Rrep) {
      pop <- create_population(v)
      dat <- create_datasets(pop, e)
      out <- t(vapply(split(dat, dat$data_set), fit_one, numeric(5)))
      a_est <- c(a_est, out[,"anova_est"])
      a_pp  <- c(a_pp,  out[,"anova_p"] < 0.05)
      g_est <- c(g_est, out[,"glmm_est"])
      g_pos <- c(g_pos, out[,"glmm_lo"] > 0 | out[,"glmm_hi"] < 0)
    }
    n <- length(a_est)
    k <- k+1
    res[[k]] <- data.frame(e=e, var=v, n=n,
      anova_est_mean=mean(a_est,na.rm=TRUE),
      anova_tpr=mean(a_pp,na.rm=TRUE),
      glmm_est_mean=mean(g_est,na.rm=TRUE),
      glmm_tpr=mean(g_pos,na.rm=TRUE))
    cat(sprintf("e=%.1f var=%.2f | ANOVA est=%.3f tpr=%.3f | GLMM est=%.3f tpr=%.3f\n",
                e, v, res[[k]]$anova_est_mean, res[[k]]$anova_tpr, res[[k]]$glmm_est_mean, res[[k]]$glmm_tpr))
  }
}
tab <- do.call(rbind, res)

fp <- tab[tab$e==0, ]
n0 <- sum(fp$n)
fpA <- sum(fp$anova_tpr * fp$n)
fpG <- sum(fp$glmm_tpr  * fp$n)
cat("\n=== FROM-SCRATCH FALSE-POSITIVE RATES @ e=0 (independent seed) ===\n")
cat(sprintf("N datasets e=0: %d\nANOVA FP: %d (%.2f%%)   |   GLMM FP: %d (%.2f%%)\n",
            n0, round(fpA), 100*fpA/n0, round(fpG), 100*fpG/n0))
cat("(Paper: ANOVA 304/6000=5.07%, GLMM 341/6000=5.68%. Expect our seed to give ~5%.)\n")

cat("\n=== ANOVA underestimation @ e=2 (paper: estimate ~0.35-0.38, GLMM ~2.0) ===\n")
sub <- tab[tab$e==2, ]
print(sub[,c("var","anova_est_mean","glmm_est_mean")], row.names=FALSE)

write.csv(tab, file.path("output","scratch_frequentist.csv"), row.names=FALSE)
cat("\nWROTE output/scratch_frequentist.csv (seed", SEED, ")\n")
