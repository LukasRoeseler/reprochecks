rm(list=ls(all=TRUE))  # clear all variables
# Programmed by Greg Francis (gfrancis@purdue.edu) September 2019

# Study 3 of of Dallas, Liu & Ubel (2018)
# Simulation used because this is a contrast based on standard error from an ANOVA

# Uncomment the following line to get the same random number generator results as published in Francis & Thunell (2020)
set.seed(3947194)

# sample sizes
n1 = 85 # Left
n2 =86 # Right
n3 = 81 # None (changed to reflect Corrigendum of April 9, 2020)

contrastdf = n1+n2+n3-3

Means = c(1428.24, 1308.66, 1436.79)  # Left, right, none (last mean changed to reflect Corrigendum of April 9, 2020)
SDs = c(377.02, 420.14, 378.47)  # (last SD changed to reflect Corrigendum of April 9, 2020)
Ns = c(n1, n2, n3)
pooledVar = sum((Ns-1)*SDs*SDs)/contrastdf
SDs = sqrt(pooledVar) + 0*SDs # same for all conditions

numRepeats = 100000
numSuccess = 0

NS1=0
NS2=0
NS3=0

for(rep in c(1:numRepeats)){

# Draw random samples and run the tests, then compute Condition for those test from that sample
    Left  <- rnorm(n1, mean=Means[1], sd=SDs[1])
	Right <- rnorm(n2, mean=Means[2], sd=SDs[2])	
	None <- rnorm(n3, mean=Means[3], sd=SDs[3])
	

	# Set up data frame
	
	Condition<-c()
	Calories <-c()	
		
	for(i in c(1:n1)){
		Condition <- c(Condition, "Left")
		Calories <- c(Calories, Left[i])
	}
	for(i in c(1:n2)){
		Condition <- c(Condition, "Right")
		Calories <- c(Calories, Right[i])
	}
	for(i in c(1:n3)){
		Condition <- c(Condition, "None")
		Calories <- c(Calories, None[i])
	}	
	
	dataOneWay=data.frame(Condition=Condition, Calories=Calories)
	
	
	#ANOVA	
	out <- anova(lm(Calories~Condition, dataOneWay))
	thing<-out$`Pr(>F)`
	conditionP = thing[1]  # Apparently, only need a marginal effect, we just ignore it
	thing2<-out$`Mean Sq`
	MSE = thing2[2]
	
	# Contrast (Left vs. Right)
	weights <- c(1, -1, 0)
	nweights <- c(weights[1]/sqrt(n1), weights[2]/sqrt(n2), weights[3]/sqrt(n3))
	L = weights[1]*mean(Left) + weights[2]*mean(Right) + weights[3]*mean(None)
	t= abs(L)/sqrt(sum(nweights*nweights)*MSE) 	
	
	contrastP <-  2 * (1 - pt(abs(t), df=n1 + n2 + n3 - 3))
	
	# Contrast (Right vs. None)
	weights <- c(0, 1, -1)
	nweights <- c(weights[1]/sqrt(n1), weights[2]/sqrt(n2), weights[3]/sqrt(n3))
	L = weights[1]*mean(Left) + weights[2]*mean(Right) + weights[3]*mean(None)
	t= abs(L)/sqrt(sum(nweights*nweights)*MSE) 	
	
	contrastP2 <-  2 * (1 - pt(abs(t), df=n1 + n2 + n3 - 3))
		

		# See if all tests rejects as predicted 
			if (contrastP<=0.05 &&  contrastP2<=0.05 )	{
				numSuccess = numSuccess +1
				}
			if (conditionP <=0.05){NS1=NS1+1}
			if (contrastP <=0.05){NS2=NS2+1}
			if (contrastP2 <=0.05){NS3=NS3+1}
}

cat("------\n",numSuccess/numRepeats, "\n")

cat("contrast: Left vs. Right ", NS2/numRepeats, "\n")
cat("contrast: Right vs. None ", NS3/numRepeats, "\n")

