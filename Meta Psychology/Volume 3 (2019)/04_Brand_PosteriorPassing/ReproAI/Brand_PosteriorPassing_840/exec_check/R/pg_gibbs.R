# pg_gibbs.R -- Polya-Gamma augmented Gibbs sampler for the exact posterior-passing model
# logit(p_i) = beta1 + beta2*sex + beta3*cond + beta4*sex*cond + u[pid]
# priors (matching author's jags): beta ~ N(0, 1/0.01); u ~ N(0, 1/tau); tau ~ Gamma(0.01,0.01)
# PG(b=ntrials, psi) via truncated sum-of-gammas (Polson, Scott & Windle 2013).

pg_draw <- function(b, psi, K=300) {
  # returns vector length n: PG(b_i, psi_i); b scalar or length-n, psi length-n
  n <- length(psi)
  G <- matrix(rgamma(K*n, shape=b, rate=1), nrow=K, ncol=n)   # shape = n_trials
  k <- (1:K) - 0.5
  denom <- outer(k^2, psi^2/(4*pi^2), "+")   # (k-.5)^2 + psi^2/(4 pi^2)
  (1/(2*pi^2)) * colSums(G / denom)
}

# beta matrix: X columns = intercept,sex,condition,interaction (0/1); Z = participant dummies
fit_bayes <- function(y, trials, X, pid, pp_beta4 = NULL, n_iter=2500, burnin=500,
                      b0s=0.0, prec0=0.01) {
  pid <- match(pid, unique(pid))
  N <- length(y); J <- max(pid)
  if (is.null(pp_beta4)) pp_beta4 <- c(0, sqrt(1/prec0))
  Xt <- X
  beta <- c(0,0,0,0); u <- rep(0,J); tau <- 1
  prec_mat <- diag(prec0, 4)
  pp_prec <- 1/(pp_beta4[2]^2)
  prec_int <- if (pp_beta4[2]==Inf) 0 else pp_prec
  prec_mat[4,4] <- prec_int
  prec_mean <- c(0,0,0, pp_beta4[1])
  keep <- matrix(NA, nrow=n_iter-burnin, ncol=4)
  ii <- 0
  for (it in 1:n_iter) {
    psi <- as.vector(Xt %*% beta) + u[pid]
    omega <- pg_draw(trials, psi, K=300)
    z <- (y - trials/2) / omega
    W <- omega
    XtWX <- t(Xt) %*% (W * Xt)
    # sample beta | ...
    Zmat <- model.matrix(~ factor(pid) - 1)
    XtWz  <- t(Xt) %*% (W * z)
    ZtWz  <- t(Zmat) %*% (W * z)
    ZtWZ  <- t(Zmat) %*% (W * Zmat)
    # beta:
    Vb <- solve(XtWX + prec_mat)
    mb <- Vb %*% (XtWz - t(Xt) %*% (W * (Zmat %*% u)) + prec_mat %*% prec_mean)
    beta <- as.vector(MASS::mvrnorm(1, mb, Vb))
    # u:
    Vu <- solve(ZtWZ + tau*diag(J))
    mu <- Vu %*% (ZtWz - t(Zmat) %*% (W * (X %*% beta)))
    u <- as.vector(MASS::mvrnorm(1, mu, Vu))
    # tau:
    tau <- rgamma(1, 0.01 + J/2, 0.01 + 0.5*sum(u^2))
    if (it > burnin) { ii <- ii+1; keep[ii,] <- beta }
  }
  keep
}

summ_beta4 <- function(post) {
  q <- quantile(post[,4], c(0.025,0.975))
  c(median=unname(median(post[,4])), lo=unname(q[1]), hi=unname(q[2]),
    mean=unname(mean(post[,4])), sd=unname(sd(post[,4])))
}
