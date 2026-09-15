############################################
############################################
########### Replication Code for: ##########
########### When Do Männerparteien #########
#### Elect Women? Radical Right Populist ###
#### Parties and Strategic Descriptive #####
#### Representation ########################
#### Weeks, Meguid, Kittilson, and Coffe ###
############################################
############################################

### Analyses conducted using R version 4.1.2 (2021-11-01) (base R)

rm(list = ls())

library(ggplot2)
library(directlabels)
library(RColorBrewer)
library(colorRamps)
getPalette = colorRampPalette(brewer.pal(9, "Spectral"))

library(lme4)
library(lmerTest)
library(interplot)
library("dplyr")

#### read in data

load("Replication_data.RData")
### head(newd)

#####################
#####################
#### Codebook #######
#####################
#####################

## Variable name followed by in-text label 

## year                              ## Time 
## pfem_new2                         ## % Women MPs
## lag1_mfcombined10                 ## M/F Ratio(t-1)
## chgvotelagged                     ## Vote Change(t-1)
## femaleleader2_lag                 ## Woman Leader(t-1)
## cabinet_party2_lag                ## Cabinet Party(t-1)
## lag1womenpar                      ## Women in Parliament(t-1)
## tier1_avemag2                     ## District Magnitude
## prop3                             ## PR Electoral System (1 = SMD; 2 = Modified PR; 3 = PR)
## natquota                          ## Quota Law
## weurope                           ## Western Europe 
## lagged_share_green_newleft        ## Vote Share Green / New Left(t-1)
## party                             ## Party ID (CMP)
## country                           ## Country ID 


#####################
#####################
#### Figure 1 #######
#####################
#####################

### Women in the Party plot 
### loess smoothing 

library(scales)
library(readr)

vars<-c("countryname", "date", "party", "newpartyfam", "partyname", "year", "pfem_new2")
temp<-na.omit(newd[vars])
head(temp)
nrow(temp) ##1408

#########
#########
## take out Ethnic / Regional and Nationalist / Agrarian party families 

temp_1<- temp[ which(temp$newpartyfam!='Nationalist / Agrarian' & temp$newpartyfam!='Ethnic / Regional'), ]
nrow(temp_1) 


temp_1$newpartyfam <- factor(temp_1$newpartyfam, levels = c("Radical Right", "Conservative", "Liberal", "Social Dem", "Green / New Left", "Christian Dem"))


set.seed(02138)

bypar <- ggplot(data = temp_1, aes(x = year, y = pfem_new2, color = newpartyfam, linetype=newpartyfam )) +
  geom_point(size = 0.5) + geom_smooth(method = "loess", se = FALSE, size=1.5) +
  labs(x="Election Year",
       y="% Women in the Party",
       title="")

bypar

bypar  + xlim(1980, 2018)  + theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  scale_color_discrete(name = "Party family") +
  scale_linetype_discrete(name = "Party family") 

### and make it in grayscale 

tiff("Figure_1.tiff", width = 10, height = 5, units = 'in', res = 1200)

bypar <- ggplot(data = temp_1, aes(x = year, y = pfem_new2, color = newpartyfam, linetype=newpartyfam )) +
  geom_point(size = 0.1) + geom_smooth(method = "loess", se = FALSE, size=1.8) +
  labs(x="Election Year",
       y="% Women in the Party",
       title="")

bypar

bypar  + xlim(1980, 2018)  + theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  scale_color_grey(name = "Party family") +
  scale_linetype_discrete(name = "Party family") +
  theme(legend.key.height= unit(.8, 'cm'),
        legend.key.width= unit(1.5, 'cm'))+
theme(text = element_text(size=20))
dev.off()

#####################
#####################
#### Figure 2 #######
#####################
#####################

vars<-c("countryname", "date", "party", "newpartyfam", "partyname", "partyabbrev", "year", "pfem_new2", "weurope")
temp<-na.omit(newd[vars])
head(temp)
nrow(temp) ##1408

### looking at only RR 
### Run this bit too look at only RR parties 

temp<-temp[ which(temp$newpartyfam=="Radical Right"), ]
nrow(temp) ## 134

### Fix abbreviations and party names 
temp$partyabbrev<-as.character(temp$partyabbrev)
temp$partyname<-as.character(temp$partyname)

temp$partyabbrev[temp$partyname=="Austrian Freedom Party"]<-"FPO"
temp$partyabbrev[temp$countryname=="Czech Republic"]<-"Association for the Republic"
temp$partyname[temp$countryname=="Czech Republic"]<-"Association for the Republic"
temp$partyname[temp$countryname=="Latvia"]<-"For Fatherland and Freedom"
temp$partyname[temp$partyabbrev=="DF"]<-"Danish People's Party"
temp$partyname[temp$countryname=="Switzerland"]<-"Swiss People's Party"
temp$partyname[temp$countryname=="Norway" & temp$partyname=="Progress Party"]<-"NO Progress Party"
temp$partyname[temp$countryname=="Denmark" & temp$partyname=="Progress Party"]<-"DK Progress Party"

tiff("Figure_2.tiff", width = 10, height = 5, units = 'in', res = 1200)

set.seed(02138)
bypar <- ggplot(data = temp, aes(x = year, y = pfem_new2, label = partyname, fontface="bold")) +
  geom_point(size = 0.35, color = "black") + geom_smooth(method = "loess", se = FALSE, color="darkgrey") +
  labs(x="Election Year",
       y="% Women in Party",
       title="")

bypar + geom_hline(yintercept=1) + geom_text(check_overlap = TRUE, size=3) + xlim(1985, 2020)+ 
theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + theme(text = element_text(size=20))
dev.off()

#####################
#####################
####### Figure 4#####
#####################

vars<-c("countryname", "date", "party", "newpartyfam",  "year", "mfcombined10")
temp<-na.omit(newd[vars])
head(temp)
nrow(temp) #

### set the cut off
temp$mfcombined10[temp$mfcombined10>5]<-5
summary(temp$mfcombined10)

## take out the smaller party families 
temp_1<- temp[ which(temp$newpartyfam!='Nationalist / Agrarian' & temp$newpartyfam!='Ethnic / Regional'), ]
nrow(temp_1) ##1022

temp_1$newpartyfam <- factor(temp_1$newpartyfam, levels = c("Radical Right", "Conservative", "Liberal", "Social Dem", "Green / New Left", "Christian Dem"))
temp_1<-na.omit(temp_1) ##984

set.seed(02138)

tiff("Figure_4.tiff", width = 10, height = 5, units = 'in', res = 1200)

bypar <- ggplot(data = temp_1, aes(x = year, y = mfcombined10, color = newpartyfam, linetype = newpartyfam )) +
  geom_point(size = 0.1) + geom_smooth(method = "loess", se = FALSE, size=1.8) +
  labs(x="Election Year",
       y="M/F Voter Ratio",
       title="")

bypar

bypar  + scale_colour_grey(name  ="Party Family") + geom_hline(yintercept=1)+ xlim(1985, 2018) + theme_bw() + 
theme(panel.border = element_blank(), panel.grid.major = element_blank(),
panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  scale_color_grey(name = "Party family") +
  scale_linetype_discrete(name = "Party family") +
  theme(legend.key.height= unit(.8, 'cm'),
        legend.key.width= unit(1.5, 'cm')) + theme(text = element_text(size=20))
dev.off()

######################
######################
### Table 1 ##########
######################
######################

newd2 <- newd[ which(newd$newpartyfam=='Radical Right'), ] 
nrow(newd2)

library(ggplot2)
library(directlabels)
library(RColorBrewer)
library(colorRamps)
getPalette = colorRampPalette(brewer.pal(9, "Spectral"))

library(lme4)
library(lmerTest)
library(interplot)

set.seed(02145) 

## Model 1 -- constituent variables 
out1<-lmer(pfem_new2 ~ lag1_mfcombined10    + chgvotelagged +
	(1 | party ) + 	(1 | country), data=newd2, REML=FALSE)
summary(out1) 

## Model 2 -- add interaction 
out2<-lmer(pfem_new2 ~ lag1_mfcombined10     + chgvotelagged + lag1_mfcombined10:chgvotelagged +
	(1 | party ) + 	(1 | country), data=newd2, REML=FALSE)
summary(out2) ## 

### Model 3 -- add time trend 
out3<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + 
	(1 | party ) + 	(1 | country), data=newd2,  REML=FALSE)
summary(out3) 

## Model 4 -- add party level covariates 
out4<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag +
	(1 | party ) + 	(1 | country), data=newd2,  REML=FALSE)
summary(out4) 

## Model 5 -- add national level covariates 
out5<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd2,  REML=FALSE)
summary(out5) 
## 

 library(stargazer)
 class(out1) <- "lmerMod"
 class(out2) <- "lmerMod"
 class(out3) <- "lmerMod"
 class(out4) <- "lmerMod"
 class(out5) <- "lmerMod"
 stargazer(out1, out2, out3, out4, out5, style="ajps", title="Determinants of Women's Representation in
 Radical Right Parties", dep.var.labels.include = FALSE,  star.cutoffs = c(0.05, 0.01, 0.001), covariate.labels = c("M/F Ratio", "Vote Change", 
 "Time", "Female Leader", "Cabinet Party", "Women in Parliament", "Dis. Mag.", "PR", "Quota Law", "Western Europe", "M/F Ratio*Vote Change"),
 type = "html",
 out="Table1.doc")


######################
######################
### Figure 5 #########
######################
######################

### Plot
set.seed(02145)
tiff("Figure_5.tiff", width = 6, height = 6, units = 'in', res = 1200)
 
plot2<- interplot(m = out5, var1 = "lag1_mfcombined10", var2 = "chgvotelagged", hist=TRUE) + 
  # Add labels for X and Y axes
    xlab("Vote Change (lagged)") +
    ylab("Estimated Coefficient for\n(lagged) M/F ratio") +
  # Change the background
    theme_bw() +
  # Add the title
    ggtitle("Estimated Coefficient of M/F ratio \non Women in Party by Vote Change") +
    theme(plot.title = element_text(face="bold")) +
  # Add a horizontal line at y = 0
    geom_hline(yintercept = 0, linetype = "dashed")+ theme(text = element_text(size=16))

plot2 
dev.off()


######################
######################
### Table 2 ##########
######################
######################

## Model 1 -- constituent variables 
out1b<-lmer(pfem_new2 ~ lag1_mfcombined10    + chgvotelagged +
	(1 | party ) + 	(1 | country), data=newd, REML=FALSE)
summary(out1b) 

## Model 2 -- add interaction 
out2b<-lmer(pfem_new2 ~ lag1_mfcombined10     + chgvotelagged + lag1_mfcombined10:chgvotelagged +
	(1 | party ) + 	(1 | country), data=newd, REML=FALSE)
summary(out2b) ##

### Model 3 -- add time trend 
out3b<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + 
	(1 | party ) + 	(1 | country), data=newd,  REML=FALSE)
summary(out3b) 

## Model 4 -- add party level covariates 
out4b<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag +
	(1 | party ) + 	(1 | country), data=newd,  REML=FALSE)
summary(out4b) 

## Model 5 -- add national level covariates 
out5b<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd,  REML=FALSE)
summary(out5b) 

library(stargazer)
class(out1b) <- "lmerMod"
class(out2b) <- "lmerMod"
class(out3b) <- "lmerMod"
class(out4b) <- "lmerMod"
class(out5b) <- "lmerMod"
stargazer(out1b, out2b, out3b, out4b, out5b, style="ajps", star.cutoffs = c(0.05, 0.01, 0.001), title="Determinants of Women's Representation in Parties", dep.var.labels.include = FALSE, covariate.labels = c("M/F Ratio", "Vote Change", 
"Time", "Female Leader", "Cabinet Party", "Women in Parliament", "Dis. Mag.", "Modified PR Electoral System",
"PR Electoral System", "Quota Law", "Western Europe", "M/F Ratio*Vote Change"),
type = "html",
out="Table2.doc")

######################
######################
### Table 3 ##########
######################
######################

#### party families 

table(newd$newpartyfam)
newd3a <- newd[ which(newd$newpartyfam=='Christian Dem'), ] 
nrow(newd3a)

out7.1<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd3a,  REML=FALSE)
summary(out7.1) 

newd3b <- newd[ which(newd$newpartyfam=='Conservative'), ] 
nrow(newd3b)

out7.2<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd3b,  REML=FALSE)
summary(out7.2) 

table(newd$newpartyfam)
newd3c <- newd[ which(newd$newpartyfam=='Green / New Left'), ] 
nrow(newd3c)

out7.3<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd3c,  REML=FALSE)
summary(out7.3) 


table(newd$newpartyfam)
newd3d <- newd[ which(newd$newpartyfam=='Liberal'), ] 
nrow(newd3d)

out7.4<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd3d,  REML=FALSE)
summary(out7.4) 

table(newd$newpartyfam)
newd3e <- newd[ which(newd$newpartyfam=='Social Dem'), ] 
nrow(newd3e)

out7.5<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd3e,  REML=FALSE)
summary(out7.5) 

class(out7.1)<- "lmerMod"
class(out7.2)<- "lmerMod"
class(out7.3)<- "lmerMod"
class(out7.4)<- "lmerMod"
class(out7.5)<- "lmerMod"
 stargazer(out7.1, out7.2, out7.3, out7.4, out7.5, style="ajps", star.cutoffs = c(0.05, 0.01, 0.001),
 title="Determinants of Women's Representation by Party Family", 
 dep.var.labels.include = FALSE, covariate.labels = c("M/F Ratio", "Vote Change", 
 "Time", "Female Leader", "Cabinet Party", "Women in Parliament", "Dis. Mag.", "Modified Proportional Representation", "Proportional Representation", "Quota Law", "Western Europe", "M/F Ratio*Vote Change"),
 type = "html",
 out="Table3.doc")

#########################
#########################
## Appendix Table A1 ####
#########################
#########################

##Table of RRP parties in analysis 

vars<-c("countryname", "year" , "party", "partyname", "partyabbrev", "pfem_new2", "lag1_mfcombined10", "chgvotelagged",
"femaleleader2_lag", "cabinet_party2_lag" , "lag1womenpar", "tier1_avemag2" ,"prop2", "natquota" ,"weurope")

stats<-na.omit(newd2[vars])
head(stats)
nrow(stats)
 write.csv(stats, "RR_Parties_in_Analysis.csv")



#########################
#########################
## Appendix Table A2 ####
#########################
#########################

library(stargazer)

### Summary statistics RRP party sample 

temp<-newd2

## Because we used factor(prop2) for descriptive stats need to create dummy

temp$PR<-0
temp$PR[temp$prop2==3]<-1
table(temp$PR)

vars<-c("year" , "pfem_new2", "lag1_mfcombined10", "chgvotelagged",
"year", "femaleleader2_lag", "cabinet_party2_lag" , "lag1womenpar", "tier1_avemag2" ,
"PR", "natquota" ,"weurope","lagged_share_green_newleft", "party", "country")

stats<-na.omit(temp[vars])
head(stats)

nrow(stats)
 stargazer(stats, type = "html",
 out="TableA2.doc")

#########################
#########################
## Appendix Table A3 ####
#########################
#########################

#### OLS Models 

## Model 1 -- constituent variables 
out1c<-lm(pfem_new2 ~ lag1_mfcombined10    + chgvotelagged , data=newd2)
summary(out1c) 

## Model 2 -- add interaction 
out2c<-lm(pfem_new2 ~ lag1_mfcombined10     + chgvotelagged + lag1_mfcombined10:chgvotelagged , data=newd2)
summary(out2c) 

### Model 3 -- add time trend 
out3c<-lm(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year , data=newd2)
summary(out3c) 

## Model 4 -- add party level covariates 
out4c<-lm(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag , data=newd2)
summary(out4c) 

## Model 5 -- add national level covariates 
out5c<-lm(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope , data=newd2)
summary(out5c) 

library(stargazer)

 stargazer(out1c, out2c, out3c, out4c, out5c, style="ajps", star.cutoffs = c(0.05, 0.01, 0.001), title="Determinants of Women's Representation in
 Radical Right Parties", dep.var.labels.include = FALSE, covariate.labels = c("M/F Ratio", "Vote Change", 
 "Time", "Female Leader", "Cabinet Party", "Women in Parliament", "Dis. Mag.", "PR", "Quota Law", "Western Europe", "M/F Ratio*Vote Change"),
 type = "html",
 out="TableA3.doc")

#########################
#########################
## Appendix Table A4 ####
#########################
#########################

## Table showing results hold removing extreme outliers for M/F voter ratio 

newd3 <- newd2[ which(newd2$lag1_mfcombined10<11), ] 
nrow(newd3)

## new version of Model 7 excluding these three variables -- rrp parties 
out6.2<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd3,  REML=FALSE)
summary(out6.2) 

newd4 <- newd[ which(newd$lag1_mfcombined10<11), ] 
nrow(newd4)

## new version of Model 5 excluding these variables -- all parties 

out6.3<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd4,  REML=FALSE)
summary(out6.3) 

class(out6.2)<- "lmerMod"
class(out6.3)<- "lmerMod"
 stargazer(out6.2, out6.3, style="ajps", title="Determinants of Women's Representation in RRP parties", star.cutoffs = c(0.05, 0.01, 0.001),
 dep.var.labels.include = FALSE, covariate.labels = c("M/F Ratio", "Vote Change", 
 "Time", "Female Leader", "Cabinet Party", "Women in Parliament", "Dis. Mag.", "Mod PR", "PR", "Quota Law", "Western Europe", "M/F Ratio*Vote Change"),
 type = "html",
 out="TableA4.doc")

#########################
#########################
## Appendix Table A5 ####
#########################
#########################

####  without the interaction term

out5dd<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + 
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd2,  REML=FALSE)
summary(out5dd) 

class(out5dd) <- "lmerMod"
 stargazer(out5dd, style="ajps", title="Determinants of Women's Representation in
 Radical Right Parties", dep.var.labels.include = FALSE,  star.cutoffs = c(0.05, 0.01, 0.001), covariate.labels = c("M/F Ratio", "Vote Change", 
 "Time", "Female Leader", "Cabinet Party", "Women in Parliament", "Dis. Mag.", "PR", "Quota Law", "Western Europe"),
 type = "html",
 out="TableA5.doc")



#########################
#########################
## Appendix Table A6 ####
#########################
#########################

## excluding women in parliament (all parties model) 

out5b2<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd,  REML=FALSE)
summary(out5b2)
nobs(out5b2)

library(stargazer)
class(out5b2) <- "lmerMod"
 stargazer(out5b2, style="ajps", star.cutoffs = c(0.05, 0.01, 0.001), title="Determinants of Women's Representation in Parties", dep.var.labels.include = FALSE, covariate.labels = c("M/F Ratio", "Vote Change", 
 "Time", "Female Leader", "Cabinet Party",  "Dis. Mag.", "Modified PR", "PR", "Quota Law", "Western Europe", "M/F Ratio*Vote Change"),
 type = "html",
 out="TableA7.doc")


#########################
#########################
## Appendix Table A7 ####
#########################
#########################

## Calculating residuals for case selection 
## For each model, calculate predicted values, residuals, and SE / residuals
## and predicted 

### first run na.omit 

vars<-c("country", "countryname", "year", "party", "partyname", "partyabbrev", "pfem_new2", "lag1_mfcombined10", "chgvotelagged", 
"femaleleader2_lag", "cabinet_party2_lag", "lag1womenpar", "tier1_avemag2", "prop2", "natquota",
"weurope")
temp_r<-na.omit(newd2[vars])
head(temp_r)
nrow(temp_r)

#### Now the models 

## Model 1 -- constituent variables 
out1<-lmer(pfem_new2 ~ lag1_mfcombined10    + chgvotelagged +
	(1 | party ) + 	(1 | country), data=temp_r, REML=FALSE)
summary(out1) 

## Model 2 -- add interaction 
out2<-lmer(pfem_new2 ~ lag1_mfcombined10     + chgvotelagged + lag1_mfcombined10:chgvotelagged +
	(1 | party ) + 	(1 | country), data=temp_r, REML=FALSE)
summary(out2) ## this is now sig at .1 (.07)

### Model 3 -- add time trend 
out3<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + 
	(1 | party ) + 	(1 | country), data=temp_r,  REML=FALSE)
summary(out3) 

## Model 4 -- add party level covariates 
out4<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag +
	(1 | party ) + 	(1 | country), data=temp_r,  REML=FALSE)
summary(out4) 

## Model 5 -- add national level covariates 
out5<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=temp_r,  REML=FALSE)
summary(out5) 

### Now save residuals and predicted for each model (except first one with no interaction)

temp_r$predicted_mod2 <- predict(out2)   # Save the predicted values
temp_r$residuals_mod2 <- residuals(out2) # Save the residual values
sd(temp_r$predicted_mod2) ## 7.434402
sd(temp_r$residuals_mod2) ##6.06

#produce residual vs. fitted plot
res <- resid(out2)
plot(fitted(out2), res)

#add a horizontal line at 0 
abline(0,0)

temp_r$predicted_mod3 <- predict(out3)   # Save the predicted values
temp_r$residuals_mod3 <- residuals(out3) # Save the residual values
sd(temp_r$predicted_mod3) ##8.12
sd(temp_r$residuals_mod3) ##5.46

temp_r$predicted_mod4 <- predict(out4)   # Save the predicted values
temp_r$residuals_mod4 <- residuals(out4) # Save the residual values
sd(temp_r$predicted_mod4) ##8.19
sd(temp_r$residuals_mod4) ## 5.44

temp_r$predicted_mod5 <- predict(out5)   # Save the predicted values
temp_r$residuals_mod5 <- residuals(out5) # Save the residual values
sd(temp_r$predicted_mod5) ##8.28
sd(temp_r$residuals_mod5) ##5.64

write.csv(temp_r,"Residuals_RR_all_models.csv")


###################################
###################################
#### Appendix Figure A1
###################################
###################################

vars<-c("countryname", "date", "party", "newpartyfam",  "year", "mfcombined10")
temp<-na.omit(newd[vars])
head(temp)
nrow(temp) ##1167


## take out the smaller party families 
temp_1<- temp[ which(temp$newpartyfam!='Nationalist / Agrarian' & temp$newpartyfam!='Ethnic / Regional'), ]
nrow(temp_1) ##1022

temp_1$newpartyfam <- factor(temp_1$newpartyfam, levels = c("Radical Right", "Conservative", "Liberal", "Social Dem", "Green / New Left", "Christian Dem"))
temp_1<-na.omit(temp_1) 
nrow(temp_1) ##984

### now drop those observations greater than 20 

temp_2<- temp_1[ which(temp_1$mfcombined10 < 21), ]
nrow(temp_2) ##980 -- 4 values removed 

set.seed(02138)
bypar <- ggplot(data = temp_2, aes(x = year, y = mfcombined10, color = newpartyfam, linetype = newpartyfam )) +
  geom_point(size = 0.5) + geom_smooth(method = "loess", se = FALSE, size=1.5) +
  labs(x="Election Year",
       y="M/F Voter Ratio",
       title="")

bypar

bypar  + scale_colour_discrete(name  ="Party Family") + geom_hline(yintercept=1)+ xlim(1985, 2018) + theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) +
  scale_color_discrete(name = "Party family") +
  scale_linetype_discrete(name = "Party family")+ theme(text = element_text(size=20))


###################################
###################################
#### Appendix Figure A2
###################################
###################################
 
vars<-c("countryname", "date", "party", "newpartyfam", "partyname", "partyabbrev", "year", "mfcombined10", "weurope")
temp<-na.omit(newd[vars])
head(temp)
nrow(temp)

temp$mfcombined10[temp$mfcombined10>5]<-5

### looking at only RR 

temp<-temp[ which(temp$newpartyfam=="Radical Right"), ]
nrow(temp) ##

### Fix abbreviations and party names 
temp$partyabbrev<-as.character(temp$partyabbrev)
temp$partyname<-as.character(temp$partyname)

temp$partyabbrev[temp$partyname=="Austrian Freedom Party"]<-"FPO"
temp$partyabbrev[temp$countryname=="Czech Republic"]<-"Association for the Republic"
temp$partyname[temp$countryname=="Czech Republic"]<-"Association for the Republic"
temp$partyname[temp$countryname=="Latvia"]<-"For Fatherland and Freedom"
temp$partyname[temp$partyabbrev=="DF"]<-"Danish People's Party"
temp$partyname[temp$countryname=="Switzerland"]<-"Swiss People's Party"
temp$partyname[temp$countryname=="Norway" & temp$partyname=="Progress Party"]<-"NO Progress Party"
temp$partyname[temp$countryname=="Denmark" & temp$partyname=="Progress Party"]<-"DK Progress Party"

set.seed(01238)
bypar <- ggplot(data = temp, aes(x = year, y = mfcombined10, label = partyname, fontface="bold")) +
  geom_point(size = 0.5) + geom_smooth(method = "loess", se = FALSE) +
  labs(x="Election Year",
       y="M/F Voter Ratio",
       title="")

bypar + geom_hline(yintercept=1) + geom_text(check_overlap = TRUE, size=3) + xlim(1985, 2020)+ 
theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + theme(text = element_text(size=20))



###################################
###################################
#### Appendix Figure A3
###################################
###################################
 
## Model 5 -- add national level covariates 
out5<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd2,  REML=FALSE)

## Plot 
plot2<- interplot(m = out5, var1 = "chgvotelagged", var2 = "lag1_mfcombined10", hist=TRUE) + 
  # Add labels for X and Y axes
    xlab("M/F Ratio (lagged)") +
    ylab("Estimated Coefficient for\n(lagged) Vote Change") +
  # Change the background
    theme_bw() +
  # Add the title
    ggtitle("Estimated Coefficient of Vote Change \non Women in Party by M/F Ratio") +
    theme(plot.title = element_text(face="bold")) +
  # Add a horizontal line at y = 0
    geom_hline(yintercept = 0, linetype = "dashed") +
 theme(axis.text.x  = element_text(angle=90))+ theme(text = element_text(size=16))

plot2

###################################
###################################
#### Appendix Figure A4
###################################
###################################

## Model 5 -- add national level covariates 
out5b<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd,  REML=FALSE)
summary(out5b) 

### Plot 
plot2b<- interplot(m = out5b, var1 = "lag1_mfcombined10", var2 = "chgvotelagged", hist=TRUE) + 
  # Add labels for X and Y axes
    xlab("Vote Change (lagged)") +
    ylab("Estimated Coefficient for\n(lagged) M/F ratio") +
  # Change the background
    theme_bw() +
  # Add the title
    ggtitle("Estimated Coefficient of M/F ratio \non Women in Party by Vote Change") +
    theme(plot.title = element_text(face="bold")) +
  # Add a horizontal line at y = 0
    geom_hline(yintercept = 0, linetype = "dashed")+ theme(text = element_text(size=16))
plot2b


###################################
###################################
#### Appendix Figure A5
###################################
###################################

## Christian  Democrat party family plot 

out7.1<-lmer(pfem_new2 ~ lag1_mfcombined10   + chgvotelagged + lag1_mfcombined10:chgvotelagged +
year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + as.factor(prop2) + natquota + weurope +
	(1 | party ) + 	(1 | country), data=newd3a,  REML=FALSE)
summary(out7.1) 

### Plot 
plot2b<- interplot(m = out7.1, var1 = "lag1_mfcombined10", var2 = "chgvotelagged", hist=TRUE) + 
  # Add labels for X and Y axes
    xlab("Vote Change (lagged)") +
    ylab("Estimated Coefficient for\n(lagged) M/F ratio") +
  # Change the background
    theme_bw() +
  # Add the title
    ggtitle("Estimated Coefficient of M/F ratio \non Women in Party by Vote Change") +
    theme(plot.title = element_text(face="bold")) +
  # Add a horizontal line at y = 0
    geom_hline(yintercept = 0, linetype = "dashed") + theme(text = element_text(size=16))
plot2b

