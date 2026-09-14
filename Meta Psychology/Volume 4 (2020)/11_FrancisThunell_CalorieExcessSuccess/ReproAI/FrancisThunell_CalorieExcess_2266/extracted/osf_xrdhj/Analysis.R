rm(list=ls(all=TRUE))  # clear all variables
# Analysis of Dallas, Liu & Ubel (2018)


library(pwr)

# Study 1
# See Study1.R
power1 = 0.45946


# Study 2
# Fewer calories in left vs. right (exclusions subtracted)
n1=152-9 
n2=153 - 21
d= 2.08*sqrt(1/n1 + 1/n2)
g = (1-3/(4*(n1+n2-2)-1) ) * d
tempPwr = pwr.t2n.test(n1=n1, n2=n2, d=g)
power2 = tempPwr$power

# Study 3
# See Study3.R
power3 = 0.37647

# Study S1
# Fewer calories in left vs. right 
n1=101-2
n2=83-6
d= 2.07*sqrt(1/n1 + 1/n2)
g = (1-3/(4*(n1+n2-2)-1) ) * d
tempPwr = pwr.t2n.test(n1=n1, n2=n2, d=g)
powerS1 = tempPwr$power

# Study S2
# See StudyS2.R
powerS2 = 0.56661

# Study S3
# See StudyS3.R
powerS3 = 0.49526




cat("Study 1 ", power1, "\n", sep="\t")
cat("Study 2 ", power2, "\n", sep="\t")
cat("Study 3 ", power3, "\n", sep="\t")
cat("Study S1 ", powerS1, "\n", sep="\t")
cat("Study S2 ", powerS2, "\n", sep="\t")
cat("Study S3 ", powerS3, "\n", sep="\t")
cat("--------\nAll experiments ", power1*power2*power3*powerS1*powerS2*powerS3, "\n", sep="\t")





