suppressMessages({library(BayesFactor)}); options(warn=-1)
set.seed(1)
mean1<-.5; mySDs<-c(.1,.1); N<-30; d<-.5; sdPooled<-sqrt((.1^2+.1^2)/2); mean2<-mean1-(d*sdPooled)
numStudies<-20; numTimes<-100
hackNull<-numeric(numTimes); hackEff<-numeric(numTimes)
for(i in 1:numTimes){
  hN<-0; hE<-0
  for(k in 1:10){ g1<-rnorm(N,mean1,.1); g2<-rnorm(N,mean2,.1); a<-t.test(g2,g1,var.equal=T)
    if(a$p.value < .2 & a$p.value > .05) hE<-hE+1 }
  for(k in 1:10){ g1<-rnorm(N,mean1,.1); g2<-rnorm(N,mean1,.1); a<-t.test(g2,g1,var.equal=T)
    if(a$p.value < .2 & a$p.value > .05) hN<-hN+1 }
  hackNull[i]<-hN; hackEff[i]<-hE
}
cat('null-only hacks mean:', mean(hackNull), 'sd:', sd(hackNull), 'range:', min(hackNull), max(hackNull), '\n')
cat('effect-only hacks mean:', mean(hackEff), 'sd:', sd(hackEff), '\n')
cat('total hacks mean:', mean(hackNull+hackEff), '\n')
