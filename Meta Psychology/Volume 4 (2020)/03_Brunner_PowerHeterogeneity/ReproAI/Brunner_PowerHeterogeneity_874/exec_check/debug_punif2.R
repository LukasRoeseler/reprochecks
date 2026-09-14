set.seed(20260914)
alpha <- 0.05; MEANN <- 86
rn_sig <- function(k) pmax(rpois(k, MEANN), 3)
genSigF <- function(k, f2) {
  n <- rn_sig(k); ncp <- n * f2; crit <- qf(1 - alpha, 1, n - 2)
  g <- 1 - pf(crit, 1, n - 2, ncp); U <- runif(k)
  FF <- qf(1 - g * U, 1, n - 2, ncp); list(FF=FF,n=n,crit=crit)
}

# target true power 0.50 at k=100 -> find f2
expPower_f2 <- function(f2){ n<-pmax(rpois(2e5,MEANN),3); c<-qf(1-alpha,1,n-2); mean(1-pf(c,1,n-2,n*f2)) }
f2 <- uniroot(function(f2) expPower_f2(f2)-0.5, c(1e-4,4))$root
cat("f2 for target 0.50:", f2, "\n")

d <- genSigF(100, f2)
FF <- d$FF; n <- d$n; crit <- d$crit
k <- length(FF)

# Inspect Ygam over a grid of es. Also compute true conditional power mean.
Ygam <- function(es) {
  ncp <- n*es
  lognewpp <- pf(FF,1,n-2,ncp,log.p=TRUE) - pf(crit,1,n-2,ncp,lower.tail=FALSE,log.p=TRUE)
  -sum(lognewpp)
}
cat("Ygam at es=f2 (=true):", Ygam(f2), " expect ~k=",k,"\n")
for (es in seq(0,0.5,length.out=11)) {
  cat(sprintf("es=%.3f  Ygam=%.2f\n", es, Ygam(es)))
}
# Which es makes Ygam=k?
fk <- uniroot(function(es) Ygam(es)-k, c(1e-6,1))$root
cat("es that makes Ygam=k:", fk, " (true f2=", f2, ")\n")
# Power at recovered es:
cat("Power estimate:", mean(1-pf(crit,1,n-2,n*fk)), "\n")
cat("True mean power of sample:", mean(1-pf(crit,1,n-2,n*f2)), "\n")
