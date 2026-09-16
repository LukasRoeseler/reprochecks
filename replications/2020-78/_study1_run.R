sink("Study1_out.txt", split=TRUE)
cat("===== STUDY 1 ANALYSIS (WVS cross-national) =====\n\n")
setwd("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/work/7cg2h")
country <- read.csv("countrydata.csv", header=TRUE)
wvs <- read.csv("WVS.csv", header=TRUE)
cat("WVS initial n:", nrow(wvs), "\n")
library(plyr)
library(nlme)

cat("\n--- counts per country clusters wrt -4 (not asked) ---\n")
cat("Pakistan rows where ideology==-4:", sum(wvs$ideology==-4, na.rm=TRUE), "\n")
cat("Pakistan total rows:", sum(wvs$country==586), "\n")

# remove data
wvs <- wvs[ which(wvs$ideology>=-3), ]
wvs <- wvs[ which(wvs$ineq>=-3),]
wvs <- wvs[ which(wvs$attrib>=-3),]
wvs <- wvs[ which(wvs$attrib <= 2),]
wvs <- wvs[ which(wvs$sex>=-3),]
wvs <- wvs[ which(wvs$age>=-3),]
wvs <- wvs[ which(wvs$educ>=-3),]
wvs <- wvs[ which(wvs$inc.lad>=-3),]
wvs <- wvs[ which(wvs$relig.import>=-3),]
# missing to NA
wvs$ineq[wvs$ineq<=0] <- NA
wvs$attrib[wvs$attrib<=0] <- NA
wvs$ideology[wvs$ideology<=0] <- NA
wvs$sex[wvs$sex<=0] <- NA
wvs$age[wvs$age<=0] <- NA
wvs$educ[wvs$educ<=0] <- NA
wvs$inc.lad[wvs$inc.lad<=0] <- NA
wvs$relig.import[wvs$relig.import<=0] <- NA
# list wise deletion
wvs <- wvs[ which(wvs$ideology>=1), ]
wvs <- wvs[ which(wvs$ineq>=1),]
wvs <- wvs[ which(wvs$attrib==1 | wvs$attrib==2),]
wvs <- wvs[ which(wvs$sex>=1),]
wvs <- wvs[ which(wvs$age>=1),]
wvs <- wvs[ which(wvs$educ>=1),]
wvs <- wvs[ which(wvs$inc.lad>=1),]
wvs <- wvs[ which(wvs$relig.import>=1),]
cat("Complete cases n:", nrow(wvs), "\n")

cat("\n--- z-score transform ---\n")
wvs$zineq <- scale(wvs$ineq, center=TRUE,scale=TRUE)
wvs$zideol <- scale(wvs$ideology, center=TRUE,scale=TRUE)
wvs$zattrib <- scale(wvs$attrib, center=TRUE,scale=TRUE)
wvs$zsex <- scale(wvs$sex, center=TRUE,scale=TRUE)
wvs$zage <- scale(wvs$age, center=TRUE,scale=TRUE)
wvs$zeduc <- scale(wvs$educ, center=TRUE,scale=TRUE)
wvs$zinclad <- scale(wvs$inc.lad, center=TRUE,scale=TRUE)
wvs$zrelig.import <- scale(wvs$relig.import, center=TRUE,scale=TRUE)

cat("\n--- Simple regression zineq~zattrib ---\n")
print(summary(lm(zineq~zattrib, data=wvs)))
cat("\n--- Multiple regression with controls ---\n")
print(summary(lm(zineq~zattrib+zideol+zsex+zage+zeduc+zinclad+zrelig.import, data=wvs)))

cat("\n--- Merge country-level data ---\n")
wvs$ID <- seq.int(nrow(wvs))
wvs$gini = 0
for(i in 1:length(wvs$ID)){wvs$gini[i]=country$Gini[which(country$Code == wvs$country[i])]}
wvs$gdpcap = 0
for(i in 1:length(wvs$ID)){wvs$gdpcap[i]=country$GDPpercap[which(country$Code == wvs$country[i])]}
wvs$zgini <- scale(wvs$gini, center=TRUE,scale=TRUE)
wvs$zgdpcap <- scale(wvs$gdpcap, center=TRUE,scale=TRUE)
cat("gini describe:\n"); print(psych::describe(wvs$gini))
cat("gdpcap describe:\n"); print(psych::describe(wvs$gdpcap))

cat("\n--- NULL MODEL (zineq~1, random ~1|S003A) ---\n")
nullmod <- lme(zineq~1, data=wvs, random=~1|S003A, method="ML", na.action="na.omit")
print(summary(nullmod))
cc <- as.numeric(VarCorr(nullmod)[1,1]); rr <- as.numeric(VarCorr(nullmod)[2,1])
cat("ICC recomputed from sqrt SDs:", (sqrt(cc)*sqrt(cc))/((sqrt(cc)*sqrt(cc))+(sqrt(rr)*sqrt(rr))), "\n")

cat("\n--- MODEL1 (zineq~zattrib, random ~1|S003A) ---\n")
print(summary(lme(zineq~zattrib, data=wvs, random=~1|S003A, method="ML", na.action="na.omit")))

cat("\n--- MODEL2 full (random ~1|country) ---\n")
print(summary(lme(zineq~zattrib+zideol+zsex+zage+zeduc+zinclad+zrelig.import+zgini+zgdpcap, data=wvs, random=~1|country, method="ML", na.action="na.omit")))
sink()
cat("DONE\n")
