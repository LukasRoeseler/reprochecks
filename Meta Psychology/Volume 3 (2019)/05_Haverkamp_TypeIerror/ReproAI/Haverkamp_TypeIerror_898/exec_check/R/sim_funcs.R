## ReproAI RE-AUDIT (2026-09-14) — shared helpers.
## Haverkamp & Beauducel (2019), MP.2018.898. Type I error comparison
## rANOVA / rANOVA-HF / MLM-CS / MLM-UN / MLM-KR.
##
## NOT a byte-for-byte SAS 9.4 / SPSS 23 reproduction. This is an independent R
## reimplementation of the paper's *described design and analysis methods*.
## The SPSS Mersenne-Twister stream (seed=1000) that generated the 1,000,000-case
## population is not reproducible in R; samples are instead drawn as i.i.d. MVN
## from the same population covariance structure (distributionally equivalent).

gen_cov <- function(m, sphericity) {
  ## m x m population correlation matrix.
  ## hold:      all pairwise correlations 0.5  (compound symmetry -> sphericity holds)
  ## violation: pairwise corr 0.8 among ODD-numbered occasions, 0.5 elsewhere
  ##            (mirrors the paper's second common variable over odd t, Eq. 4)
  R <- matrix(0.5, m, m); diag(R) <- 1
  if (sphericity == "violation") {
    odd <- which(1:m %% 2 == 1)
    for (i in odd) for (j in odd) if (i != j) R[i, j] <- 0.8
  }
  R
}

draw_sample <- function(n, m, sphericity, Sigma = NULL) {
  if (is.null(Sigma)) Sigma <- gen_cov(m, sphericity)
  MASS::mvrnorm(n, mu = rep(0, m), Sigma = Sigma)
}

## ---- classical rANOVA (sphericity assumed) + Huynh-Feldt corrected ---------
ranova_ps <- function(Y) {
  n <- nrow(Y); m <- ncol(Y)
  time_means <- colMeans(Y); grand <- mean(Y)
  SS_time <- n * sum((time_means - grand)^2)
  subj_means <- rowMeans(Y)
  resid <- sweep(Y, 2, time_means) - (subj_means - grand)
  SS_err <- sum(resid^2)
  df1 <- m - 1; df2 <- (m - 1) * (n - 1)
  F_time <- (SS_time / df1) / (SS_err / df2)
  p_assumed <- pf(F_time, df1, df2, lower.tail = FALSE)
  ## Greenhouse-Geisser epsilon on orthonormalised time contrasts
  S <- cov(Y)
  H <- contr.helmert(m); H <- apply(H, 2, function(v) v / sqrt(sum(v * v)))
  Sstar <- t(H) %*% S %*% H
  eig <- eigen(Sstar, symmetric = TRUE, only.values = TRUE)$values
  eps_GG <- sum(eig)^2 / ((m - 1) * sum(eig^2))
  ## Huynh-Feldt epsilon (bounded above by 1)
  eps_HF <- (n * (m - 1) * eps_GG - 2) / ((m - 1) * (n - 1 - (m - 1) * eps_GG))
  eps_HF <- min(1, eps_HF)
  p_HF <- pf(F_time, eps_HF * df1, eps_HF * df2, lower.tail = FALSE)
  list(rANOVA_p = p_assumed, rANOVA_HF_p = p_HF)
}

## ---- MLM-CS: random-intercept lmer (compound symmetry / exchangeable) ------
mlm_cs_p <- function(Y, Index = 1:ncol(Y)) {
  n <- nrow(Y); m <- ncol(Y)
  id <- rep(1:n, each = m); idx <- rep(Index, times = n)
  yv <- as.vector(t(Y))
  fit <- lmerTest::lmer(yv ~ idx + (1 | id), REML = TRUE)
  as.data.frame(summary(fit)$coefficients)[2, "Pr(>|t|)"]
}

## ---- MLM-UN: nlme::gls with corSymm (unstructured) residual covariance -----
mlm_un_p <- function(Y, Index = 1:ncol(Y)) {
  n <- nrow(Y); m <- ncol(Y)
  id <- rep(1:n, each = m); idx <- rep(Index, times = n)
  yv <- as.vector(t(Y))
  fit <- nlme::gls(yv ~ idx,
                   correlation = nlme::corSymm(form = ~ 1 | id),
                   method = "REML")
  cf <- summary(fit)$tTable
  cf[2, "p-value"]
}

## ---- MLM-KR approximation: lmer + Kenward-Roger df --------------------------
mlm_kr_p <- function(Y, Index = 1:ncol(Y)) {
  n <- nrow(Y); m <- ncol(Y)
  id <- rep(1:n, each = m); idx <- rep(Index, times = n)
  yv <- as.vector(t(Y))
  fit <- suppressWarnings(lmerTest::lmer(yv ~ idx + (1 | id), REML = TRUE))
  a <- anova(fit, ddf = "Kenward-Roger")
  a$`Pr(>F)`[1]
}

typeI <- function(ps, alpha = 0.05) mean(ps < alpha)
