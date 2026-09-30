fleishman <- function(sk, krt) {
  fl_syst <- function(skew, kurt, dd) {
    b=dd[1L]; c=dd[2L]; d=dd[3L]
    eqn1 = b^2 + 6*b*d + 2*c^2 + 15*d^2 - 1
    eqn2 = 2*c*(b^2 + 24*b*d + 105*d^2 + 2) - sk
    eqn3 = 24*(b*d + c^2*(1 + b^2 + 28*b*d) + d^2*(12 + 48*b*d + 141*c^2 + 225*d^2)) - krt
    eqn <- c(eqn1, eqn2, eqn3)
    sum(eqn*eqn)
  }
  sol <- nlminb(start = c(0,0,1), objective = fl_syst, skew = sk, kurt = krt)
}
cat("fleishman(1,15)$par =", fleishman(1,15)$par, "\n")

# Verify: generate E with these coefficients and check moments
set.seed(124)
Z <- rnorm(100000)
coef <- fleishman(1,15)$par
b <- coef[1]; c <- coef[2]; d <- coef[3]; a <- -c
E <- a + b*Z + c*Z^2 + d*Z^3
m <- function(x,n) mean((x-mean(x))^n)
library(e1071)
cat("mean(E) =", mean(E), " sd(E) =", sd(E), "\n")
cat("skewness(E) =", skewness(E), " (target 1)\n")
cat("excess kurtosis(E) =", kurtosis(E), " (target 15)\n")
