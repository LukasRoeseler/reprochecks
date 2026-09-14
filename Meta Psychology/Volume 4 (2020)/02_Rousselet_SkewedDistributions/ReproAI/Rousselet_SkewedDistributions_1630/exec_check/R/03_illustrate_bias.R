# ReproAI :: Rousselet & Wilcox (2020) MP.2019.1630
# illustrate_bias notebook claims: Figure 1 (bias 2.5/15.1/0.7), population median 508.7,
# single-sample bootstrap (sample median 535.6, boot mean 722.6, bias 187, BC 348.6),
# 100 experiments (515.1 / 498.8), 1000 experiments (522.1 / 508.6).
myrexgauss <- function(n, mu, sigma, tau) rnorm(n, mu, sigma) + rexp(n, rate = 1 / tau)
mu <- 300; sigma <- 20; tau <- 300
outdir <- "../output"; dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

out <- list()
for (kind in c("Rejection", "Rounding")) {
  RNGkind("Mersenne-Twister"); RNGkind(sample.kind = kind)
  set.seed(4); p <- myrexgauss(1e6, mu, sigma, tau)
  out[[kind]] <- list(pop.m=mean(p), pop.md=sort(p)[round(length(p)*0.5)])
  set.seed(44); nsim <- 1000; n <- 10
  out[[kind]]$mean_bias_n10 <- mean(apply(matrix(myrexgauss(n*nsim,mu,sigma,tau),nrow=nsim),1,mean)) - out[[kind]]$pop.m
  out[[kind]]$med_bias_n10 <- mean(apply(matrix(myrexgauss(n*nsim,mu,sigma,tau),nrow=nsim),1,median)) - out[[kind]]$pop.md
  out[[kind]]$med_bias_n100 <- mean(apply(matrix(myrexgauss(100*nsim,mu,sigma,tau),nrow=nsim),1,median)) - out[[kind]]$pop.md
  set.seed(4); s <- sort(sample(p,10,replace=TRUE))
  out[[kind]]$samp <- s
  set.seed(21)
  boot.md <- apply(matrix(sample(s,1000*length(s),replace=TRUE),nrow=1000),1,median)
  out[[kind]]$boot_mean <- mean(boot.md); out[[kind]]$bias_est <- mean(boot.md)-median(s)
  out[[kind]]$bc <- 2*median(s)-mean(boot.md)
  set.seed(7); nexp<-100; n<-10; nboot<-200
  mr <- matrix(0,nexp,2)
  for(E in 1:nexp){ s2<-sample(p,n,replace=TRUE); mr[E,1]<-median(s2); bm<-apply(matrix(sample(s2,nboot*n,replace=TRUE),nrow=nboot),1,median); mr[E,2]<-2*median(s2)-mean(bm)}
  out[[kind]]$exp100_avg_md <- mean(mr[,1]); out[[kind]]$exp100_avg_bc <- mean(mr[,2])
}
d <- data.frame(
  item = c("pop.md","mean_bias_n10","med_bias_n10","med_bias_n100","boot_mean","bias_est","bc","exp100_avg_md","exp100_avg_bc"),
  paper = c("508.7","2.5","15.1","0.7","722.6","187","348.6","515.1","498.8"),
  Rejection = sapply(out$Rejection, function(x) if(is.numeric(x)) round(x[1],1) else NA)[1:9],
  Rounding  = sapply(out$Rounding, function(x) if(is.numeric(x)) round(x[1],1) else NA)[1:9],
  stringsAsFactors = FALSE)
write.csv(d, file.path(outdir, "illustrate_bias_repl.csv"), row.names=FALSE)
print(d)
cat("single sample (Rejection):", out$Rejection$samp, "\n")
cat("mean of bootstrap estimates kind=Rejection:", out$Rejection$boot_mean, "\n")
cat("mean of bootstrap estimates kind=Rounding :", out$Rounding$boot_mean, "\n")
cat("DONE illustrate_bias\n")
