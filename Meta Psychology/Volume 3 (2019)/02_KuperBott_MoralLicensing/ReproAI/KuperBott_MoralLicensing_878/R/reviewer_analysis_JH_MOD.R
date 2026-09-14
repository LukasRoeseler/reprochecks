
#############################################################
# Niclas Kuper, Antonia Bott
# Version: 23.04.18 
####### R-code to reproduce the analyses in the comment  ####


# load relevant packages 
library(metafor) 
library(weightr)
library(dplyr)
library(forcats)


# load uncorrected dataframe
# dat<-read.table("dat_old_s.txt",sep=" ",header=T)


# load corrected Simbrunner & Schlegelmilch dataframe
dat<-read.table("dat_new_s.txt",sep=" ",header=T)



# define variables              
dat$comparison<-ifelse(dat$comparison=="1","neutral","immoral")
dat$se<-as.numeric(as.character(dat$se))
dat$yi<-as.numeric(as.character(dat$yi))
dat$vi<-dat$se^2
dat$pch_region <- ifelse(dat$world_region == "EUR", 15, 
                         ifelse(dat$world_region == "NOA", 17,
                                ifelse(dat$world_region == "SEA", 1,
                                       3)))



##### analyses with the entire dataset ##### 

# random effects meta-analysis 
mod1 <- rma(yi=yi,vi=vi,dat=dat)
summary(mod1)
#LOGISTIC-EDIT funnel masked by weightr, commented (no numeric change): funnel(mod1, level = c(95, 97.5), refline = 0, pch = dat$pch_region)

# moderator analyses 
# ressaign levels 
dat$world_region<-factor(dat$world_region,levels=c("SEA","NOA","EUR"))
model2 <- rma(yi=yi,vi=vi,mods=~comparison+world_region,dat=dat)

# pet-peese
summary(lm(dat$yi~dat$se,weights=1/dat$vi))

# three-parameter-model
weightfunct(dat$yi,dat$vi,steps=c(0.025,1),table=T)

# moderator analyses with se as additional predictor  (PET-PEESE + moderator)
rma(yi=yi,vi=vi,mods=~comparison+world_region+se,dat=dat)

# three-parameter selection model with moderators 
weightfunct(dat$yi,dat$vi,mods= ~ dat$comparison+ dat$world_region,steps=c(0.025,1),table=T)
# relevel so that "NOA" is the reference category
dat %>% 
  mutate(region = fct_relevel(world_region, "NOA", "EUR", "SEA")) %>% 
  with(.,  weightfunct(yi, vi, 
                       mods= ~ comparison+ region,steps=c(0.025,1),
                       table=T)) # intercept is very significant
# relevel so that "EUR" is the reference category
dat %>% 
  mutate(region = fct_relevel(world_region, "NOA", "EUR", "SEA")) %>% 
  with(.,  weightfunct(yi, vi, 
                       mods= ~ comparison+ region,steps=c(0.025,1),
                       table=T)) # intercept is very significant

# plot 
#pdf("plot.pdf")
par(mar=c(5,5,2,2))
plot(dat$se,dat$yi,xlab="Standard Error",ylab="Effect Size",pch=19,cex.lab=1.5,xlim=c(0,0.55))
abline(lm(dat$yi~dat$se,weights=1/dat$vi),lwd=2)
#dev.off()
                
####################

### Analyses in subsets of the data formed by culture ###

## North America 
dat2<-dat[ dat$world_region=="NOA" & is.na(dat$world_region)==FALSE,]

# random effects MA 
rma(yi=yi,vi=vi,dat=dat2)
#pet-peese
summary(lm(dat2$yi~dat2$se,weights=1/dat2$vi))
# 3 parameter selection model
weightfunct(dat2$yi,dat2$vi,steps=c(0.025,1),table=T)


  
##  Europe
dat2<-dat[ dat$world_region=="EUR" & is.na(dat$world_region)==FALSE,]

# random effects MA
rma(yi=yi,vi=vi,dat=dat2)
#pet-peese
summary(lm(dat2$yi~dat2$se,weights=1/dat2$vi))
# 3 parameter selection model
weightfunct(dat2$yi,dat2$vi,steps=c(0.025,1),table=T)



##  South-East-Asia
dat2<-dat[ dat$world_region=="SEA" & is.na(dat$world_region)==FALSE,]

# only rma feasible 
rma(yi=yi,vi=vi,dat=dat2)





   
    
