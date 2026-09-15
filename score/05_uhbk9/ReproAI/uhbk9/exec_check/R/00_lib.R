## ReproAI uhbk9 - shared library: two-way cluster-robust OLS (reimplements Stata `cluster2`)
## Engine: anomalyco/opencode (ReproAI) - DeepSeek V4 Flash via uniGPT. R 4.6.1.

## One-way cluster-robust variance-covariance (Stata `reg, vce(cluster)` flavour).
## Returns a LIST of pieces needed for sum-of-two-minus-one (CGM additive) estimator.
oneway_meat_sumsq <- function(X, u, g) {
  # X: n x K model matrix (col 1 = intercept unless none)
  # u: residuals
  # g: vector of cluster ids
  K <- ncol(X)
  XtX_inv <- solve(crossprod(X))
  G <- length(unique(g))
  N <- length(u)
  ug <- split(seq_len(N), g)
  Sg <- matrix(0, K, K)
  for (idx in ug) {
    xg <- X[idx, , drop = FALSE]
    s <- crossprod(xg, u[idx])
    Sg <- Sg + tcrossprod(s)
  }
  ## Stata-style small-sample correction for one-way cluster
  adj <- (G / (G - 1)) * ((N - 1) / (N - K))
  V <- adj * (XtX_inv %*% Sg %*% XtX_inv)
  list(V = V, XtX_inv = XtX_inv, Sg = Sg, G = G, N = N, K = K)
}

## Two-way cluster-robust VCV: V = V_g1 + V_g2 - V_g12  (Cameron-Gelbach-Miller additive).
twoway_cluster_vcov <- function(X, u, g1, g2) {
  V1 <- oneway_meat_sumsq(X, u, g1)$V
  V2 <- oneway_meat_sumsq(X, u, g2)$V
  ## firm-level cluster = interaction of person x headline
  g12 <- paste(g1, g2, sep = "_")
  V12 <- oneway_meat_sumsq(X, u, g12)$V
  V <- V1 + V2 - V12
  list(V = V, V1 = V1, V2 = V2, V12 = V12)
}

## Wald F-test for a single linear combination c'b = 0, df = (1, N - K)
wald_F <- function(b, V, cvec, N, K) {
  cb <- sum(cvec * b)
  estVar <- as.numeric(t(cvec) %*% V %*% cvec)
  F <- cb^2 / estVar
  p <- 1 - pf(F, 1, N - K)
  list(F = F, df1 = 1, df2 = N - K, p = p, est = cb, se = sqrt(estVar),
       t = cb / sqrt(estVar))
}

## format helper
fmt <- function(x, d = 3) formatC(x, format = "f", digits = d)
