rm(list=ls(all=TRUE))  # clear all variables
# Analysis of Dallas, Liu & Ubel (2018)

library(MBESS)
library(pwr)

gValues <-c()
gvarValues <-c()

# For confidence intervals
llG<-c()
ulG<-c()

StudyNames<-c("1", "2", "3", "S1", "S2", "S3")

#----------------
# Study 1
# Left vs. Right
n1 = 45 # Left
n2 = 55 # Right

Mean1 = 654.53 
Mean2 = 865.41

SD1 = 390.45
SD2 = 517.26

# Assume homogeneity of variance
pooledVar = ((n1-1)*SD1*SD1 + (n2-1)*SD2*SD2)/(n1+n2-2)
SD = sqrt(pooledVar) 

J= (1-3/(4*(n1+n2-2)-1) )  # bias correction
d = (Mean2 -Mean1)/SD
g = J* d
gvar = J*J *( (n1+n2)/(n1*n2) + d*d/(2*(n1+n2)))

gValues<-c(gValues, g)
gvarValues <-c(gvarValues, gvar)

thisCI <- ci.smd(smd=g, n.1=n1, n.2=n2)
llG<-c(llG, thisCI$Lower.Conf.Limit.smd)
ulG<-c(ulG, thisCI$Upper.Conf.Limit.smd)

#----------------
# Study 2
# Left vs. Right
n1 = 143 # Left
n2 = 132 # Right

Mean1 = 1249.83 
Mean2 = 1362.31

SD1 = 449.07
SD2 = 447.35

# Assume homogeneity of variance
pooledVar = ((n1-1)*SD1*SD1 + (n2-1)*SD2*SD2)/(n1+n2-2)
SD = sqrt(pooledVar) 

J= (1-3/(4*(n1+n2-2)-1) )  # bias correction
d = (Mean2 -Mean1)/SD
g = J* d
gvar = J*J *( (n1+n2)/(n1*n2) + d*d/(2*(n1+n2)))

gValues<-c(gValues, g)
gvarValues <-c(gvarValues, gvar)

thisCI <- ci.smd(smd=g, n.1=n1, n.2=n2)
llG<-c(llG, thisCI$Lower.Conf.Limit.smd)
ulG<-c(ulG, thisCI$Upper.Conf.Limit.smd)

#----------------
# Study 3
# Left vs. Right
n1 = 85 # Left
n2 = 86 # Right

Mean1 = 1428.24 
Mean2 = 1308.66

SD1 = 377.02
SD2 = 420.14

# Assume homogeneity of variance
pooledVar = ((n1-1)*SD1*SD1 + (n2-1)*SD2*SD2)/(n1+n2-2)
SD = sqrt(pooledVar) 

J= (1-3/(4*(n1+n2-2)-1) )  # bias correction
d = (Mean1 -Mean2)/SD  # Switch order to reflect expected direction of effect
g = J* d
gvar = J*J *( (n1+n2)/(n1*n2) + d*d/(2*(n1+n2)))

gValues<-c(gValues, g)
gvarValues <-c(gvarValues, gvar)

thisCI <- ci.smd(smd=g, n.1=n1, n.2=n2)
llG<-c(llG, thisCI$Lower.Conf.Limit.smd)
ulG<-c(ulG, thisCI$Upper.Conf.Limit.smd)

#----------------
# Study S1
# Left vs. Right
n1 = 99 # Left
n2 = 77 # Right

Mean1 = 185.94 
Mean2 = 215.73

SD1 = 93.92
SD2 = 95.33

# Assume homogeneity of variance
pooledVar = ((n1-1)*SD1*SD1 + (n2-1)*SD2*SD2)/(n1+n2-2)
SD = sqrt(pooledVar) 

J= (1-3/(4*(n1+n2-2)-1) )  # bias correction
d = (Mean2 -Mean1)/SD
g = J* d
gvar = J*J *( (n1+n2)/(n1*n2) + d*d/(2*(n1+n2)))

gValues<-c(gValues, g)
gvarValues <-c(gvarValues, gvar)

thisCI <- ci.smd(smd=g, n.1=n1, n.2=n2)
llG<-c(llG, thisCI$Lower.Conf.Limit.smd)
ulG<-c(ulG, thisCI$Upper.Conf.Limit.smd)

#----------------
# Study S2
# Left vs. Right
n1 = 139 # Left
n2 = 141 # Right

Mean1 = 1182.15 
Mean2 = 1302.23

SD1 = 477.60
SD2 = 434.41

# Assume homogeneity of variance
pooledVar = ((n1-1)*SD1*SD1 + (n2-1)*SD2*SD2)/(n1+n2-2)
SD = sqrt(pooledVar) 

J= (1-3/(4*(n1+n2-2)-1) )  # bias correction
d = (Mean2 -Mean1)/SD
g = J* d
gvar = J*J *( (n1+n2)/(n1*n2) + d*d/(2*(n1+n2)))

gValues<-c(gValues, g)
gvarValues <-c(gvarValues, gvar)

thisCI <- ci.smd(smd=g, n.1=n1, n.2=n2)
llG<-c(llG, thisCI$Lower.Conf.Limit.smd)
ulG<-c(ulG, thisCI$Upper.Conf.Limit.smd)

#----------------
# Study S3
# Left vs. Right
n1 = 336 # Left
n2 = 337 # Right

Mean1 = 1302.03 
Mean2 = 1373.15

SD1 = 480.02
SD2 = 442.49

# Assume homogeneity of variance
pooledVar = ((n1-1)*SD1*SD1 + (n2-1)*SD2*SD2)/(n1+n2-2)
SD = sqrt(pooledVar) 

J= (1-3/(4*(n1+n2-2)-1) )  # bias correction
d = (Mean2 -Mean1)/SD
g = J* d
gvar = J*J *( (n1+n2)/(n1*n2) + d*d/(2*(n1+n2)))

gValues<-c(gValues, g)
gvarValues <-c(gvarValues, gvar)

thisCI <- ci.smd(smd=g, n.1=n1, n.2=n2)
llG<-c(llG, thisCI$Lower.Conf.Limit.smd)
ulG<-c(ulG, thisCI$Upper.Conf.Limit.smd)

# --------
# Meta-analysis
gstarvar = 1/sum(1/gvarValues)
gstar = sum(gValues/gvarValues)/ sum(1/gvarValues)


# Report 
cat("Study \t g \t gVar \t CILL \t CIUL\n")
for (i in c(1:6)){
	cat( StudyNames[i], gValues[i], gvarValues[i], llG[i], ulG[i], "\n", sep= "\t")
}

cat("\nPooled g= ", gstar, "\n")

cat ("--------\n")

#-----------
# Power analysis
DesiredPower<-c(0.8, 0.85, 0.9, 0.95, 0.99)

cat("Using meta-analysis effect size: ", gstar, "\n")
cat("Desired Power\t Sample Size (each sample)\n")
for(dp in DesiredPower){
	
	sampleSize = pwr.t.test(d=gstar, power=dp, type="two.sample", alternative="two.sided")
	cat(dp, ceiling(sampleSize$n), "\n", sep="\t")
}


cat("\nUsing half the meta-analysis effect size: ", gstar/2, "\n")
cat("Desired Power\t Sample Size (each sample)\n")
for(dp in DesiredPower){
	
	sampleSize = pwr.t.test(d=gstar/2, power=dp, type="two.sample", alternative="two.sided")
	cat(dp, ceiling(sampleSize$n), "\n", sep="\t")
}

