##CLeaned up everything but looktime

##Data Analysis
# Load Packages Needed ----------------------------------------------------

library(lme4) #for logistic regression
library(plyr) #for rearranging the spreadsheets using ddply
library(psych) #for using describe to get descriptives
library(effsize) #to calculate effect sizes for cohens d
library(ez) #to run repeated measures anova and get effect size, eta squared
library(Hmisc) # correlations with significance
library(Rmisc) #for summarySE
library(ggplot2) #for ggplot
library(tidyr) # to use gather
library(stringr) # for string split
library(officer) #for writing out to powerpoint
library(cowplot) #for removing borders on graphs
library(rvg) #for helping to write out editable plots in powerpoint
library(nlme)
library(dplyr)
library(reshape2)
library(gridExtra)
library(apaTables) #CI for anova
library(psychometric) #CI for correlations
# NOTE (repro audit): rvg 0.4.2 removed ph_with_vg. PPT-export writes are
# irrelevant to reported statistics; no-op them so the pipeline can run past.
ph_with_vg <- function(..., type="body") { list(...)[[1]] }
# Read in Spreadsheets ----------------------------------------------------
setwd("C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/work/2020-52")
ET_total <- read.csv("ET.csv", header=TRUE)
TS_total <- read.csv("TS.csv", header=TRUE)
Drift <- read.csv("Drift.csv", header=TRUE)
Uncertainty <- read.csv("Uncertainty.csv", header=TRUE)
Drift_HDDM <- read.csv("HDDM_data_paper.csv", header=TRUE)
within_trans <- read.csv("within_switches.csv", header=TRUE)

#Add in uncertainty ratings for ET and TS task
#ET
Uncertainty$combo <- NA
Uncertainty$head_change_mind <- NA
for(i in 1:nrow(Uncertainty)){
  Uncertainty$combo[i]<- sum(c(Uncertainty$IDK[i],Uncertainty$Changing_mind[i],Uncertainty$head_turn[i]), na.rm=TRUE)
  Uncertainty$head_change_mind[i] <- sum(c(Uncertainty$head_turn[i], Uncertainty$Changing_mind[i]),na.rm=TRUE)
  }
ET_total <- merge(ET_total, Uncertainty, by=c("Subject", "Trial"), all.x=TRUE, all.y=FALSE)

# Marking Unknown Trials and Skipped Trials -------------------------------

for(u in 1:nrow(ET_total)) {
  if(is.na(ET_total$know[u])) {
    ET_total$know[u] <- 1
  }
}

for(u in 1:nrow(TS_total)) {
  if(is.na(TS_total$know[u])) {
    TS_total$know[u] <- 1
  }
}

########Marking skipped trials#############
ET_total$skipped <- 999

for(s in 1:nrow(ET_total)) {
  if(ET_total$Answer[s] == "Space"){
    ET_total$skipped[s] <- 1
  }
}

TS_total$skipped <- 999

for(s in 1:nrow(TS_total)) {
  if(TS_total$Answer[s] == "SPACE"){
    TS_total$skipped[s] <- 1
  }
}

# Choosing Study ----------------------------------------------------------


ET_total_split <- subset(ET_total[ET_total$Study1 == 1,])
# repro audit (Study 1): neutralize the Study-2 overwrite so the Study-1 subset is kept
# ET_total_split <- subset(ET_total[ET_total$Study2 == 1,])

TS_total_split <- subset(TS_total[TS_total$Study1 == 1,])
# TS_total_split <- subset(TS_total[TS_total$Study2 == 1,])

# Removing Skipped, Unknown Trials, and low accuracy kids. Counting up ------------------------

#####Remove skipped trials and unknown trials, counting them up as well. Here to count and find # of participants, I made
##new spreadsheets, I did skipped first, then removed for unknown use these sheets to one, remove for
##low accuracy and then do accuracy analyses. Then remove long/short trials and no AOI trials. 
ET_skipped <- subset(ET_total_split[ET_total_split$skipped == 1,])
num_skipped_part <- length(unique(ET_skipped$Subject))
ET_total_split <- subset(ET_total_split[ET_total_split$skipped == 999,])
ET_unknown <- subset(ET_total_split[ET_total_split$know == 0,])
num_unknown_part <- length(unique(ET_unknown$Subject))
ET_total_split <- subset(ET_total_split[ET_total_split$know == 1,])

TS_skipped <- subset(TS_total_split[TS_total_split$skipped == 1,])
num_skipped_part <- length(unique(TS_skipped$Subject))
TS_total_split <- subset(TS_total_split[TS_total_split$skipped == 999,])
TS_unknown <- subset(TS_total_split[TS_total_split$know == 0,])
num_unknown_part <- length(unique(TS_unknown$Subject))
TS_total_split <- subset(TS_total_split[TS_total_split$know == 1,])

##Find which participants performed below chance in the tasks, and then remove their data
acc_ET <- aggregate(Accuracy ~Subject , ET_total_split, mean) 
low_acc_ET <- subset(acc_ET, Accuracy <=.5)
low_acc_ET <- low_acc_ET$Subject
ET <- ET_total_split[which(!(ET_total_split$Subject %in% low_acc_ET)),]


acc_TS <- aggregate(Accuracy ~Subject , TS_total_split, mean) 
low_acc_TS <- subset(acc_TS, Accuracy <=.5)
low_acc_TS <- low_acc_TS$Subject
TS <- TS_total_split[which(!(TS_total_split$Subject %in% low_acc_TS)),]

# Accuracy Analysis -----------------------------------------------
##Create sheets for variables needed
d.TS=TS %>% 
  group_by(Subject) %>% 
  summarise(total_pc_TS = mean(Accuracy,na.rm=TRUE))

data=as.data.frame(TS %>% 
                     group_by(Subject, Similarity) %>% 
                     summarise(pc_TS= mean(Accuracy,na.rm=TRUE)))
data$Similarity=ifelse(data$Similarity==0, "dissimilar", "similar")
data=reshape(data, idvar = "Subject", timevar = "Similarity", direction="wide")
d.TS=merge(d.TS, data, by.x="Subject", by.y="Subject")

d.ET=ET %>% 
  group_by(Subject) %>% 
  summarise(total_pc_ET = mean(Accuracy,na.rm=TRUE))

data=as.data.frame(ET %>% 
                     group_by(Subject, Similarity) %>% 
                     summarise(pc_ET= mean(Accuracy,na.rm=TRUE)))
data$Similarity=ifelse(data$Similarity==0, "dissimilar", "similar")
data=reshape(data, idvar = "Subject", timevar = "Similarity", direction="wide")
d.ET=merge(d.ET, data, by.x="Subject", by.y="Subject")

####Find the overall accuracy for touchscreen and eye tracker and the descriptives
psych::describe(d.TS$total_pc_TS)

psych::describe(d.ET$total_pc_ET)

#Doing logistic regression, to see if accuracy on ET trials is predicted by accuracy on TS matched trial
##First create a spreadsheet with subject ID, trial level accuracy for both tasks, and trial number on it
ET_log <- subset(ET[,c(1,2,6)])
colnames(ET_log) <- c('Subject', 'Trial', 'Accuracy_ET')
TS_log <- subset(TS[,c(1,3,6)])
colnames(TS_log) <- c('Subject', 'Trial', 'Accuracy_TS')

Logistic_data <- merge(ET_log, TS_log, by = c('Subject', 'Trial'), all.x=TRUE, all.y=TRUE)

###Running the regression
summary(glmer(Accuracy_ET ~ Accuracy_TS + 
                (1|Subject) + 
                (1|Trial), #behavior item
              data = Logistic_data, 
              family = "binomial", na.action=na.omit))
r1 <- glmer(Accuracy_ET ~ Accuracy_TS + 
              (1|Subject) + 
              (1|Trial), #behavior item
            data = Logistic_data, 
            family = "binomial", na.action=na.omit)
confint(r1, method="Wald", level=.95)

#Eye tracker accuracy comparison, Comparing accuracy in similiar condition to dissimilar condition
##Run the t-test, get the means of each group, then calculate effect size
t.test(d.ET$pc_ET.dissimilar,d.ET$pc_ET.similar, paired=TRUE)

psych ::describe(d.ET$pc_ET.similar)
psych ::describe(d.ET$pc_ET.dissimilar)

cohen.d(d.ET$pc_ET.dissimilar,d.ET$pc_ET.similar, paired=TRUE, na.rm=TRUE)

####Same as above but for TS
t.test(d.TS$pc_TS.dissimilar, d.TS$pc_TS.similar, paired=TRUE)
psych :: describe(d.TS$pc_TS.dissimilar)
psych :: describe(d.TS$pc_TS.similar)
cohen.d(d.TS$pc_TS.dissimilar, d.TS$pc_TS.similar, paired=TRUE, na.rm=TRUE)

###Graphing overall accuracy
ET_acc <- d.ET[, c(1,3,4)]
TS_acc <- d.TS[, c(1,3,4)]
ET_acc$Task <- "Eye-Tracker"
TS_acc$Task <- "Touchscreen"

ET_acc_long <- reshape(ET_acc, idvar="Subject", varying=c("pc_ET.dissimilar", "pc_ET.similar"),v.names="Mean",timevar='Similarity', direction = "long")
ET_acc_long$Similarity <- factor(ET_acc_long$Similarity, levels = c(1,2), labels = c("Dissimilar", "Similar"))

TS_acc_long <- reshape(TS_acc, idvar="Subject", varying=c("pc_TS.dissimilar", "pc_TS.similar"),v.names="Mean",timevar='Similarity', direction = "long")
TS_acc_long$Similarity <- factor(TS_acc_long$Similarity, levels = c(1,2), labels = c("Dissimilar", "Similar"))

Total_acc <- rbind(ET_acc_long, TS_acc_long)

Total_Sum <- summarySE(Total_acc, measurevar="Mean", groupvars=c("Similarity", "Task"),na.rm=TRUE)
a <- ggplot(data=Total_Sum, aes(x=factor(Similarity), y=Mean,fill=Similarity)) + #fill puts in the colors
  geom_bar(stat="identity")+
  scale_fill_grey()  + 
  guides(fill=FALSE)+ #takes out legend
  geom_errorbar(aes(ymin=Mean-ci, ymax=Mean+ci), width=.1)+
  geom_jitter(data = Total_acc, aes(x = Similarity, y = Mean)) + 
  xlab("") +
  ylab("Proportion Accurate") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(text = element_text(size=18))+
  facet_grid(~Task)+
  panel_border(remove=TRUE)+
  theme(strip.background = element_blank(),strip.text.x = element_blank())

##Write out to powerpoint
graphs <- read_pptx()
layout_summary(graphs)
graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = print(a), type="body") 

# Removing Long RT Trials and No Look Trials ------------------------------

###Take out trials with RTs faster than 700 ms, first seeing how many there are across how many participants
TS_short<- TS[which(TS$RT < 700),]
TS_short_part <- unique(TS_short$Subject)
TS <- TS[which(TS$RT > 700),]
### Z-score the RTs to eliminate the rest
TS$RT_zsubj=ave(TS$RT,TS$Subject, FUN=scale)
TS_long <- TS[which(TS$RT_zsubj > 3),]
TS_long_part <- unique(TS_long$Subject)

TS_short_z <- TS[which(TS$RT_zsubj < -3),]
TS_short_z_part <- unique(TS_short_z$Subject)

TS <- TS[which(TS$RT_zsubj < 3),]


#####AOI Trials###########3
ET$no_aoi <- 999
total_nolook_trials <- 0
for(l in 1:nrow(ET)) {
  if(is.na(ET$Target_Total[l]) & is.na(ET$Distractor_Total[l])){
    total_nolook_trials <- total_nolook_trials + 1
    ET$no_aoi[l] <- 1
  }
}
#Find the number of participants that had at least one trials with no looktime 
No_AOI <- subset(ET[ET$no_aoi == 1,])
No_AOI_part <- length(unique(No_AOI$Subject))
#Clean the sheet so it is only the data we want, no non looktime trials
ET <- subset(ET[ET$no_aoi == 999,])

# Creating variables --------------------------------------------------------
#TS variables
#Totals
data=as.data.frame(TS %>%
  group_by(Subject) %>% 
  summarise(total_pc_trimmed_TS = mean(Accuracy,na.rm=TRUE), total_RT_TS = mean(RT,na.rm=TRUE)))
d.TS=merge(d.TS, data, by.x="Subject", by.y="Subject")

#broken up by correct incorrect
data=as.data.frame(TS %>% 
                     group_by(Subject, Accuracy) %>% 
                     summarise(RT_TS = mean(RT,na.rm=TRUE)))
data$Accuracy=ifelse(data$Accuracy==1, "corr","incorr")
data=reshape(data, idvar = "Subject", timevar = "Accuracy", direction="wide")
d.TS=merge(d.TS, data, by.x="Subject", by.y="Subject")

#Data broken up by similarity
data=as.data.frame(TS %>% 
                     group_by(Subject, Similarity) %>% 
                     summarise(pc_trimmed_TS= mean(Accuracy,na.rm=TRUE), RT_TS = mean(RT,na.rm=TRUE)))
data$Similarity=ifelse(data$Similarity==0, "dissimilar", "similar")
data=reshape(data, idvar = "Subject", timevar = "Similarity", direction="wide")
d.TS=merge(d.TS, data, by.x="Subject", by.y="Subject")


#Broken up by acc sim, acc diss, inacc 
data=as.data.frame(TS %>% 
                     group_by(Subject, Similarity, Accuracy) %>% 
                     summarise(RT_TS = mean(RT,na.rm=TRUE)))
data$Similarity=ifelse(data$Similarity==0, "dissimilar","similar")
data$Accuracy=ifelse(data$Accuracy==0, "inaccurate","accurate")
data=reshape(data, idvar = c("Subject", "Accuracy"), timevar = "Similarity", direction="wide")
data=reshape(data, idvar = "Subject", timevar = "Accuracy", direction="wide")

d.TS=merge(d.TS, data, by.x="Subject", by.y="Subject")

d.TS$Macbates <- TS_total$Macbates[match(d.TS$Subject, TS_total$Subject)]
d.TS$I_dont_know <- TS_total$I_dont_know[match(d.TS$Subject, TS_total$Subject)]
d.TS$mental_states_sure_unsure <- TS_total$Mental_states_sure_unsure[match(d.TS$Subject, TS_total$Subject)]
d.TS$age <- TS_total$Age[match(d.TS$Subject, TS_total$Subject)]

#Find drift outliers, then add to data sheet
Drift <- merge(Drift, Drift_HDDM, by="SID", all.x=TRUE, all.y=TRUE)

Participants_Drift <- Drift[which(Drift$Study==1),]
# Participants_Drift <- Drift[which(Drift$Study==2),]

Participants_Drift <- Participants_Drift[which(!(Participants_Drift$SID %in% low_acc_TS)),]

### find outliers
Participants_Drift$Dis_Alpha_zsubj=ave(Participants_Drift$Dis.alpha, FUN=scale)
Participants_Drift$Dis_Tau_zsubj=ave(Participants_Drift$Dis.tau, FUN=scale)
Participants_Drift$Dis_Delta_zsubj=ave(Participants_Drift$Dis.delta, FUN=scale)
Participants_Drift$Sim_Alpha_zsubj=ave(Participants_Drift$Sim.alpha, FUN=scale)
Participants_Drift$Sim_Tau_zsubj=ave(Participants_Drift$Sim.tau, FUN=scale)
Participants_Drift$Sim_Delta_zsubj=ave(Participants_Drift$Sim.delta, FUN=scale)

Participants_Drift$Alpha_zsubj=ave(Participants_Drift$alpha, FUN=scale)
Participants_Drift$Tau_zsubj=ave(Participants_Drift$tau, FUN=scale)
Participants_Drift$Delta_zsubj=ave(Participants_Drift$delta, FUN=scale)

#HDDM Parameters
Participants_Drift$Dis_Alpha_HDDM_zsubj=ave(Participants_Drift$A_Dis_HDDM, FUN=scale)
Participants_Drift$Dis_Tau_HDDM_zsubj=ave(Participants_Drift$t_Dis_HDDM, FUN=scale)
Participants_Drift$Dis_Delta_HDDM_zsubj=ave(Participants_Drift$V_Dis_HDDM, FUN=scale)
Participants_Drift$Sim_Alpha_HDDM_zsubj=ave(Participants_Drift$A_Sim_HDDM, FUN=scale)
Participants_Drift$Sim_Tau_HDDM_zsubj=ave(Participants_Drift$t_Sim_HDDM, FUN=scale)
Participants_Drift$Sim_Delta_HDDM_zsubj=ave(Participants_Drift$V_Sim_HDDM, FUN=scale)

Participants_Drift$Alpha_HDDM_zsubj=ave(Participants_Drift$A_HDDM, FUN=scale)
Participants_Drift$Tau_HDDM_zsubj=ave(Participants_Drift$t_HDDM, FUN=scale)
Participants_Drift$Delta_HDDM_zsubj=ave(Participants_Drift$V_HDDM, FUN=scale)

total_outliers_dis_alpha <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Dis.alpha[l])) {next}
  if(Participants_Drift$Dis_Alpha_zsubj[l] > 3){
    Participants_Drift$Dis.alpha[l] <- NA
    total_outliers_dis_alpha <- total_outliers_dis_alpha + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Dis.alpha[l])) {next}
  if(Participants_Drift$Dis_Alpha_zsubj[l] < -3){
    Participants_Drift$dis.alpha[l] <- NA
    total_outliers_dis_alpha <- total_outliers_dis_alpha + 1
  }
}

total_outliers_dis_delta <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Dis.delta[l])) {next}
  if(Participants_Drift$Dis_Delta_zsubj[l] > 3){
    Participants_Drift$Dis.delta[l] <- NA
    total_outliers_dis_delta <- total_outliers_dis_delta + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Dis.delta[l])) {next}
  if(Participants_Drift$Dis_Delta_zsubj[l] < -3){
    Participants_Drift$dis.delta[l] <- NA
    total_outliers_dis_delta <- total_outliers_dis_delta + 1
  }
}

total_outliers_dis_tau <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Dis.tau[l])) {next}
  if(Participants_Drift$Dis_Tau_zsubj[l] > 3){
    Participants_Drift$Dis.tau[l] <- NA
    total_outliers_dis_tau <- total_outliers_dis_tau + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Dis.tau[l])) {next}
  if(Participants_Drift$Dis_Tau_zsubj[l] < -3){
    Participants_Drift$dis.tau[l] <- NA
    total_outliers_dis_tau <- total_outliers_dis_tau + 1
  }
}

total_outliers_Sim_delta <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Sim.delta[l])) {next}
  if(Participants_Drift$Sim_Delta_zsubj[l] > 3){
    Participants_Drift$Sim.delta[l] <- NA
    total_outliers_Sim_delta <- total_outliers_Sim_delta + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Sim.delta[l])) {next}
  if(Participants_Drift$Sim_Delta_zsubj[l] < -3){
    Participants_Drift$Sim.delta[l] <- NA
    total_outliers_Sim_delta <- total_outliers_Sim_delta + 1
  }
}

total_outliers_Sim_tau <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Sim.tau[l])) {next}
  if(Participants_Drift$Sim_Tau_zsubj[l] > 3){
    Participants_Drift$Sim.tau[l] <- NA
    total_outliers_Sim_tau <- total_outliers_Sim_tau + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Sim.tau[l])) {next}
  if(Participants_Drift$Sim_Tau_zsubj[l] < -3){
    Participants_Drift$Sim.tau[l] <- NA
    total_outliers_Sim_tau <- total_outliers_Sim_tau + 1
  }
}

total_outliers_Sim_alpha <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Sim.alpha[l])) {next}
  if(Participants_Drift$Sim_Alpha_zsubj[l] > 3){
    Participants_Drift$Sim.alpha[l] <- NA
    total_outliers_Sim_alpha <- total_outliers_Sim_alpha + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$Sim.alpha[l])) {next}
  if(Participants_Drift$Sim_Alpha_zsubj[l] < -3){
    Participants_Drift$Sim.alpha[l] <- NA
    total_outliers_Sim_alpha <- total_outliers_Sim_alpha + 1
  }
}

total_outliers_delta <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$delta[l])) {next}
  if(Participants_Drift$Delta_zsubj[l] > 3){
    Participants_Drift$delta[l] <- NA
    total_outliers_delta <- total_outliers_delta + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$delta[l])) {next}
  if(Participants_Drift$Delta_zsubj[l] < -3){
    Participants_Drift$delta[l] <- NA
    total_outliers_delta <- total_outliers_delta + 1
  }
}

total_outliers_tau <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$tau[l])) {next}
  if(Participants_Drift$Tau_zsubj[l] > 3){
    Participants_Drift$tau[l] <- NA
    total_outliers_tau <- total_outliers_tau + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$tau[l])) {next}
  if(Participants_Drift$Tau_zsubj[l] < -3){
    Participants_Drift$tau[l] <- NA
    total_outliers_tau <- total_outliers_tau + 1
  }
}

total_outliers_alpha <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$alpha[l])) {next}
  if(Participants_Drift$Alpha_zsubj[l] > 3){
    Participants_Drift$alpha[l] <- NA
    total_outliers_alpha <- total_outliers_alpha + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$alpha[l])) {next}
  if(Participants_Drift$Alpha_zsubj[l] < -3){
    Participants_Drift$alpha[l] <- NA
    total_outliers_alpha <- total_outliers_alpha + 1
  }
}

#HDDM outliers
total_outliers_dis_alpha <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$A_Dis_HDDM[l])) {next}
  if(Participants_Drift$Dis_Alpha_HDDM_zsubj[l] > 3){
    Participants_Drift$A_Dis_HDDM[l] <- NA
    total_outliers_dis_alpha <- total_outliers_dis_alpha + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$A_Dis_HDDM[l])) {next}
  if(Participants_Drift$Dis_Alpha_HDDM_zsubj[l] < -3){
    Participants_Drift$A_Dis_HDDM[l] <- NA
    total_outliers_dis_alpha <- total_outliers_dis_alpha + 1
  }
}

total_outliers_dis_delta <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$V_Dis_HDDM[l])) {next}
  if(Participants_Drift$Dis_Delta_HDDM_zsubj[l] > 3){
    Participants_Drift$V_Dis_HDDM[l] <- NA
    total_outliers_dis_delta <- total_outliers_dis_delta + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$V_Dis_HDDM[l])) {next}
  if(Participants_Drift$Dis_Delta_HDDM_zsubj[l] < -3){
    Participants_Drift$V_Dis_HDDM[l] <- NA
    total_outliers_dis_delta <- total_outliers_dis_delta + 1
  }
}

total_outliers_dis_tau <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$t_Dis_HDDM[l])) {next}
  if(Participants_Drift$Dis_Tau_HDDM_zsubj[l] > 3){
    Participants_Drift$t_Dis_HDDM[l] <- NA
    total_outliers_dis_tau <- total_outliers_dis_tau + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$t_Dis_HDDM[l])) {next}
  if(Participants_Drift$Dis_Tau_HDDM_zsubj[l] < -3){
    Participants_Drift$t_Dis_HDDM[l] <- NA
    total_outliers_dis_tau <- total_outliers_dis_tau + 1
  }
}

total_outliers_Sim_delta <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$V_Sim_HDDM[l])) {next}
  if(Participants_Drift$Sim_Delta_HDDM_zsubj[l] > 3){
    Participants_Drift$V_Sim_HDDM[l] <- NA
    total_outliers_Sim_delta <- total_outliers_Sim_delta + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$V_Sim_HDDM[l])) {next}
  if(Participants_Drift$Sim_Delta_HDDM_zsubj[l] < -3){
    Participants_Drift$V_Sim_HDDM[l] <- NA
    total_outliers_Sim_delta <- total_outliers_Sim_delta + 1
  }
}

total_outliers_Sim_tau <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$t_Sim_HDDM[l])) {next}
  if(Participants_Drift$Sim_Tau_HDDM_zsubj[l] > 3){
    Participants_Drift$t_Sim_HDDM[l] <- NA
    total_outliers_Sim_tau <- total_outliers_Sim_tau + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$t_Sim_HDDM[l])) {next}
  if(Participants_Drift$Sim_Tau_HDDM_zsubj[l] < -3){
    Participants_Drift$t_Sim_HDDM[l] <- NA
    total_outliers_Sim_tau <- total_outliers_Sim_tau + 1
  }
}

total_outliers_Sim_alpha <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$A_Sim_HDDM[l])) {next}
  if(Participants_Drift$Sim_Alpha_HDDM_zsubj[l] > 3){
    Participants_Drift$A_Sim_HDDM[l] <- NA
    total_outliers_Sim_alpha <- total_outliers_Sim_alpha + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$A_Sim_HDDM[l])) {next}
  if(Participants_Drift$Sim_Alpha_HDDM_zsubj[l] < -3){
    Participants_Drift$A_Sim_HDDM[l] <- NA
    total_outliers_Sim_alpha <- total_outliers_Sim_alpha + 1
  }
}

total_outliers_delta <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$V_HDDM[l])) {next}
  if(Participants_Drift$Delta_HDDM_zsubj[l] > 3){
    Participants_Drift$V_HDDM[l] <- NA
    total_outliers_delta <- total_outliers_delta + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$V_HDDM[l])) {next}
  if(Participants_Drift$Delta_HDDM_zsubj[l] < -3){
    Participants_Drift$V_HDDM[l] <- NA
    total_outliers_delta <- total_outliers_delta + 1
  }
}

total_outliers_tau <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$t_HDDM[l])) {next}
  if(Participants_Drift$Tau_HDDM_zsubj[l] > 3){
    Participants_Drift$t_HDDM[l] <- NA
    total_outliers_tau <- total_outliers_tau + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$t_HDDM[l])) {next}
  if(Participants_Drift$Tau_HDDM_zsubj[l] < -3){
    Participants_Drift$t_HDDM[l] <- NA
    total_outliers_tau <- total_outliers_tau + 1
  }
}

total_outliers_alpha <-0
for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$A_HDDM[l])) {next}
  if(Participants_Drift$Alpha_HDDM_zsubj[l] > 3){
    Participants_Drift$A_HDDM[l] <- NA
    total_outliers_alpha <- total_outliers_alpha + 1
  }
}

for(l in 1:nrow(Participants_Drift)){
  if(is.na(Participants_Drift$A_HDDM[l])) {next}
  if(Participants_Drift$Alpha_HDDM_zsubj[l] < -3){
    Participants_Drift$A_HDDM[l] <- NA
    total_outliers_alpha <- total_outliers_alpha + 1
  }
}

Participants_Drift <- Participants_Drift[,c(1:11,13:18,21:23)]
d.TS <- merge(d.TS, Participants_Drift, by.x= ("Subject"), by.y="SID", all.x=TRUE, all.y=TRUE)


#ET variables
#Creating looktime proportions
mysum <- function(x)sum(x,na.rm = any(!is.na(x)))

for(m in 1:nrow(ET)){
  ET$total_sum[m] <-mysum(c(ET$Target_Total[m], ET$Distractor_Total[m]))
  if(is.na(ET$Target_Total[m])){
    ET$prop_target[m] <- 0/ET$total_sum[m] 
  }else{
    ET$prop_target[m] <- ET$Target_Total[m] / ET$total_sum[m]
  }
  if(is.na(ET$Distractor_Total[m])){
    ET$prop_distractor[m] <- 0/ET$total_sum[m] 
  }else{
    ET$prop_distractor[m] <- ET$Distractor_Total[m] / ET$total_sum[m]
  }
}

for(m in 1:nrow(ET)){
  ET$total_sum_Bin1_1sec[m] <-mysum(c(ET$Target_Bin1_1sec[m], ET$Distractor_Bin1_1sec[m]))
  if(is.na(ET$Target_Bin1_1sec[m])){
    ET$prop_target_Bin1_1sec[m] <- 0/ET$total_sum_Bin1_1sec[m] 
  }else{
    ET$prop_target_Bin1_1sec[m] <- ET$Target_Bin1_1sec[m] / ET$total_sum_Bin1_1sec[m]
  }
  if(is.na(ET$Distractor_Bin1_1sec[m])){
    ET$prop_distractor_Bin1_1sec[m] <- 0/ET$total_sum_Bin1_1sec[m] 
  }else{
    ET$prop_distractor_Bin1_1sec[m] <- ET$Distractor_Bin1_1sec[m] / ET$total_sum_Bin1_1sec[m]
  }
}

for(m in 1:nrow(ET)){
  ET$total_sum_Bin2_1sec[m] <-mysum(c(ET$Target_Bin2_1sec[m], ET$Distractor_Bin2_1sec[m]))
  if(is.na(ET$Target_Bin2_1sec[m])){
    ET$prop_target_Bin2_1sec[m] <- 0/ET$total_sum_Bin2_1sec[m] 
  }else{
    ET$prop_target_Bin2_1sec[m] <- ET$Target_Bin2_1sec[m] / ET$total_sum_Bin2_1sec[m]
  }
  if(is.na(ET$Distractor_Bin2_1sec[m])){
    ET$prop_distractor_Bin2_1sec[m] <- 0/ET$total_sum_Bin2_1sec[m] 
  }else{
    ET$prop_distractor_Bin2_1sec[m] <- ET$Distractor_Bin2_1sec[m] / ET$total_sum_Bin2_1sec[m]
  }
}
for(m in 1:nrow(ET)){
  ET$total_sum_Bin3_1sec[m] <-mysum(c(ET$Target_Bin3_1sec[m], ET$Distractor_Bin3_1sec[m]))
  if(is.na(ET$Target_Bin3_1sec[m])){
    ET$prop_target_Bin3_1sec[m] <- 0/ET$total_sum_Bin3_1sec[m] 
  }else{
    ET$prop_target_Bin3_1sec[m] <- ET$Target_Bin3_1sec[m] / ET$total_sum_Bin3_1sec[m]
  }
  if(is.na(ET$Distractor_Bin3_1sec[m])){
    ET$prop_distractor_Bin3_1sec[m] <- 0/ET$total_sum_Bin3_1sec[m] 
  }else{
    ET$prop_distractor_Bin3_1sec[m] <- ET$Distractor_Bin3_1sec[m] / ET$total_sum_Bin3_1sec[m]
  }
}

for(m in 1:nrow(ET)){
  ET$total_sum_Bin4_1sec[m] <-mysum(c(ET$Target_Bin4_1sec[m], ET$Distractor_Bin4_1sec[m]))
  if(is.na(ET$Target_Bin4_1sec[m])){
    ET$prop_target_Bin4_1sec[m] <- 0/ET$total_sum_Bin4_1sec[m] 
  }else{
    ET$prop_target_Bin4_1sec[m] <- ET$Target_Bin4_1sec[m] / ET$total_sum_Bin4_1sec[m]
  }
  if(is.na(ET$Distractor_Bin4_1sec[m])){
    ET$prop_distractor_Bin4_1sec[m] <- 0/ET$total_sum_Bin4_1sec[m] 
  }else{
    ET$prop_distractor_Bin4_1sec[m] <- ET$Distractor_Bin4_1sec[m] / ET$total_sum_Bin4_1sec[m]
  }
}
for(m in 1:nrow(ET)){
  ET$total_sum_Bin5_1sec[m] <-mysum(c(ET$Target_Bin5_1sec[m], ET$Distractor_Bin5_1sec[m]))
  if(is.na(ET$Target_Bin5_1sec[m])){
    ET$prop_target_Bin5_1sec[m] <- 0/ET$total_sum_Bin5_1sec[m] 
  }else{
    ET$prop_target_Bin5_1sec[m] <- ET$Target_Bin5_1sec[m] / ET$total_sum_Bin5_1sec[m]
  }
  if(is.na(ET$Distractor_Bin5_1sec[m])){
    ET$prop_distractor_Bin5_1sec[m] <- 0/ET$total_sum_Bin5_1sec[m] 
  }else{
    ET$prop_distractor_Bin5_1sec[m] <- ET$Distractor_Bin5_1sec[m] / ET$total_sum_Bin5_1sec[m]
  }
}
for(m in 1:nrow(ET)){
  ET$total_sum_Bin6_1sec[m] <-mysum(c(ET$Target_Bin6_1sec[m], ET$Distractor_Bin6_1sec[m]))
  if(is.na(ET$Target_Bin6_1sec[m])){
    ET$prop_target_Bin6_1sec[m] <- 0/ET$total_sum_Bin6_1sec[m] 
  }else{
    ET$prop_target_Bin6_1sec[m] <- ET$Target_Bin6_1sec[m] / ET$total_sum_Bin6_1sec[m]
  }
  if(is.na(ET$Distractor_Bin6_1sec[m])){
    ET$prop_distractor_Bin6_1sec[m] <- 0/ET$total_sum_Bin6_1sec[m] 
  }else{
    ET$prop_distractor_Bin6_1sec[m] <- ET$Distractor_Bin6_1sec[m] / ET$total_sum_Bin6_1sec[m]
  }
}

ET <- merge(ET, within_trans, by.x=c("Subject", "Trial"), by.y=c("SubjectID", "Trial"), all.x=TRUE, all.y=FALSE)

ET$NSwitchROIs.Target_z=ave(ET$NSwitchROIs.Target, FUN=scale)
ET$NSwitchROIs.Lure_z=ave(ET$NSwitchROIs.Lure, FUN=scale)

target_long <- subset(ET, ET$NSwitchROIs.Target_z > 3)
lure_long <- subset(ET, ET$NSwitchROIs.Lure_z > 3)

total_outliers_target <-0
for(l in 1:nrow(ET)){
  if(is.na(ET$NSwitchROIs.Target[l])) {next}
  if(ET$NSwitchROIs.Target_z[l] > 3){
    ET$NSwitchROIs.Target[l] <- NA
    total_outliers_target <- total_outliers_target + 1
  }
}

for(l in 1:nrow(ET)){
  if(is.na(ET$NSwitchROIs.Target[l])) {next}
  if(ET$NSwitchROIs.Target_z[l] < -3){
    ET$NSwitchROIs.Target[l] <- NA
    total_outliers_target <- total_outliers_target + 1
  }
}

total_outliers_Lure <-0
for(l in 1:nrow(ET)){
  if(is.na(ET$NSwitchROIs.Lure[l])) {next}
  if(ET$NSwitchROIs.Lure_z[l] > 3){
    ET$NSwitchROIs.Lure[l] <- NA
    total_outliers_Lure <- total_outliers_Lure + 1
  }
}

for(l in 1:nrow(ET)){
  if(is.na(ET$NSwitchROIs.Lure[l])) {next}
  if(ET$NSwitchROIs.Lure_z[l] < -3){
    ET$NSwitchROIs.Lure[l] <- NA
    total_outliers_Lure <- total_outliers_Lure + 1
  }
}

#Totals
data=as.data.frame(ET %>% 
  group_by(Subject) %>% 
  summarise(total_pc_trimmed_ET = mean(Accuracy,na.rm=TRUE),total_RT_ET = mean(RT, na.rm=TRUE), total_trans = mean(Transition,na.rm=TRUE),total_head_change_mind_combo =mean(head_change_mind, na.rm=TRUE),total_uncertain_combo=mean(combo, na.rm=TRUE),total_head_turn=mean(head_turn, na.rm=TRUE), total_verbal_IDK= mean(IDK, na.rm=TRUE),total_verbal_dont_see= mean(There_is_no, na.rm=TRUE), total_changing_mind= mean(Changing_mind, na.rm=TRUE),total_shrug=mean(Shrugging,na.rm=TRUE),total_refusal=mean(Refusal_to_point,na.rm=TRUE),total_other_verbal=mean(other_verbal,na.rm=TRUE),total_prompt=mean(prompt,na.rm=TRUE), total.looktime.taget= mean(prop_target,na.rm=TRUE),total.looktime.distract=mean(prop_distractor,na.rm=TRUE),total.looktime.taget.Bin1= mean(prop_target_Bin1_1sec,na.rm=TRUE),total.looktime.distract.Bin1=mean(prop_distractor_Bin1_1sec,na.rm=TRUE),total.looktime.taget.Bin2= mean(prop_target_Bin2_1sec,na.rm=TRUE),total.looktime.distract.Bin2=mean(prop_distractor_Bin2_1sec,na.rm=TRUE),total.looktime.taget.Bin3= mean(prop_target_Bin3_1sec,na.rm=TRUE),total.looktime.distract.Bin3=mean(prop_distractor_Bin3_1sec,na.rm=TRUE),total.looktime.taget.Bin4= mean(prop_target_Bin4_1sec,na.rm=TRUE),total.looktime.distract.Bin4=mean(prop_distractor_Bin4_1sec,na.rm=TRUE),total.looktime.taget.Bin5= mean(prop_target_Bin5_1sec,na.rm=TRUE),total.looktime.distract.Bin5=mean(prop_distractor_Bin5_1sec,na.rm=TRUE),total.looktime.taget.Bin6= mean(prop_target_Bin6_1sec,na.rm=TRUE),total.looktime.distract.Bin6=mean(prop_distractor_Bin6_1sec,na.rm=TRUE), total.lure.trans = mean(NSwitchROIs.Lure, na.rm=TRUE),total.target.trans=mean(NSwitchROIs.Target, na.rm=TRUE), total.within.trans=mean(NSwitchROIs, na.rm=TRUE)))
d.ET=merge(d.ET, data, by.x="Subject", by.y="Subject")

#broken up by correct incorrect
data=as.data.frame(ET %>% 
                     group_by(Subject, Accuracy) %>% 
                     summarise(RT_ET = mean(RT, na.rm=TRUE), trans = mean(Transition,na.rm=TRUE),head_change_mind_combo =mean(head_change_mind, na.rm=TRUE),uncertain_combo=mean(combo, na.rm=TRUE),head_turn=mean(head_turn, na.rm=TRUE), verbal_IDK= mean(IDK, na.rm=TRUE),verbal_dont_see= mean(There_is_no, na.rm=TRUE), changing_mind= mean(Changing_mind, na.rm=TRUE),shrug=mean(Shrugging,na.rm=TRUE),refusal=mean(Refusal_to_point,na.rm=TRUE),other_verbal=mean(other_verbal,na.rm=TRUE),prompt=mean(prompt,na.rm=TRUE),looktime.taget= mean(prop_target,na.rm=TRUE),looktime.distract=mean(prop_distractor,na.rm=TRUE),looktime.taget.Bin1= mean(prop_target_Bin1_1sec,na.rm=TRUE),looktime.distract.Bin1=mean(prop_distractor_Bin1_1sec,na.rm=TRUE),looktime.taget.Bin2= mean(prop_target_Bin2_1sec,na.rm=TRUE),looktime.distract.Bin2=mean(prop_distractor_Bin2_1sec,na.rm=TRUE),looktime.taget.Bin3= mean(prop_target_Bin3_1sec,na.rm=TRUE),looktime.distract.Bin3=mean(prop_distractor_Bin3_1sec,na.rm=TRUE),looktime.taget.Bin4= mean(prop_target_Bin4_1sec,na.rm=TRUE),looktime.distract.Bin4=mean(prop_distractor_Bin4_1sec,na.rm=TRUE),looktime.taget.Bin5= mean(prop_target_Bin5_1sec,na.rm=TRUE),looktime.distract.Bin5=mean(prop_distractor_Bin5_1sec,na.rm=TRUE),looktime.taget.Bin6= mean(prop_target_Bin6_1sec,na.rm=TRUE),looktime.distract.Bin6=mean(prop_distractor_Bin6_1sec,na.rm=TRUE), lure.trans = mean(NSwitchROIs.Lure, na.rm=TRUE),target.trans=mean(NSwitchROIs.Target, na.rm=TRUE), within.trans=mean(NSwitchROIs, na.rm=TRUE)))
data$Accuracy=ifelse(data$Accuracy==1, "corr","incorr")
data=reshape(data, idvar = "Subject", timevar = "Accuracy", direction="wide")
d.ET=merge(d.ET, data, by.x="Subject", by.y="Subject")

#Data broken up by similarity
data=as.data.frame(ET %>% 
                     group_by(Subject, Similarity) %>% 
                     summarise(PC_ET= mean(Accuracy, na.rm=TRUE),RT_ET = mean(RT, na.rm=TRUE), trans = mean(Transition,na.rm=TRUE),head_change_mind_combo =mean(head_change_mind, na.rm=TRUE),uncertain_combo=mean(combo, na.rm=TRUE),head_turn=mean(head_turn, na.rm=TRUE), verbal_IDK= mean(IDK, na.rm=TRUE),verbal_dont_see= mean(There_is_no, na.rm=TRUE), changing_mind= mean(Changing_mind, na.rm=TRUE),shrug=mean(Shrugging,na.rm=TRUE),refusal=mean(Refusal_to_point,na.rm=TRUE),other_verbal=mean(other_verbal,na.rm=TRUE),prompt=mean(prompt,na.rm=TRUE), looktime.taget= mean(prop_target,na.rm=TRUE),looktime.distract=mean(prop_distractor,na.rm=TRUE),looktime.taget.Bin1= mean(prop_target_Bin1_1sec,na.rm=TRUE),looktime.distract.Bin1=mean(prop_distractor_Bin1_1sec,na.rm=TRUE),looktime.taget.Bin2= mean(prop_target_Bin2_1sec,na.rm=TRUE),looktime.distract.Bin2=mean(prop_distractor_Bin2_1sec,na.rm=TRUE),looktime.taget.Bin3= mean(prop_target_Bin3_1sec,na.rm=TRUE),looktime.distract.Bin3=mean(prop_distractor_Bin3_1sec,na.rm=TRUE),looktime.taget.Bin4= mean(prop_target_Bin4_1sec,na.rm=TRUE),looktime.distract.Bin4=mean(prop_distractor_Bin4_1sec,na.rm=TRUE),looktime.taget.Bin5= mean(prop_target_Bin5_1sec,na.rm=TRUE),looktime.distract.Bin5=mean(prop_distractor_Bin5_1sec,na.rm=TRUE),looktime.taget.Bin6= mean(prop_target_Bin6_1sec,na.rm=TRUE),looktime.distract.Bin6=mean(prop_distractor_Bin6_1sec,na.rm=TRUE), lure.trans = mean(NSwitchROIs.Lure, na.rm=TRUE),target.trans=mean(NSwitchROIs.Target, na.rm=TRUE), within.trans=mean(NSwitchROIs, na.rm=TRUE)))
data$Similarity=ifelse(data$Similarity==0, "dissimilar", "similar")
data=reshape(data, idvar = "Subject", timevar = "Similarity", direction="wide")
d.ET=merge(d.ET, data, by.x="Subject", by.y="Subject")


#Broken up by acc sim, acc diss, inacc 
data=as.data.frame(ET %>% 
                     group_by(Subject, Similarity, Accuracy) %>% 
                     summarise(PC_trimmed_ET= mean(Accuracy, na.rm=TRUE),RT_ET = mean(RT, na.rm=TRUE), trans = mean(Transition,na.rm=TRUE),head_change_mind_combo =mean(head_change_mind, na.rm=TRUE),uncertain_combo=mean(combo, na.rm=TRUE),head_turn=mean(head_turn, na.rm=TRUE), verbal_IDK= mean(IDK, na.rm=TRUE),verbal_dont_see= mean(There_is_no, na.rm=TRUE), changing_mind= mean(Changing_mind, na.rm=TRUE),shrug=mean(Shrugging,na.rm=TRUE),refusal=mean(Refusal_to_point,na.rm=TRUE),other_verbal=mean(other_verbal,na.rm=TRUE),prompt=mean(prompt,na.rm=TRUE), looktime.taget= mean(prop_target,na.rm=TRUE),looktime.distract=mean(prop_distractor,na.rm=TRUE),looktime.taget.Bin1= mean(prop_target_Bin1_1sec,na.rm=TRUE),looktime.distract.Bin1=mean(prop_distractor_Bin1_1sec,na.rm=TRUE),looktime.taget.Bin2= mean(prop_target_Bin2_1sec,na.rm=TRUE),looktime.distract.Bin2=mean(prop_distractor_Bin2_1sec,na.rm=TRUE),looktime.taget.Bin3= mean(prop_target_Bin3_1sec,na.rm=TRUE),looktime.distract.Bin3=mean(prop_distractor_Bin3_1sec,na.rm=TRUE),looktime.taget.Bin4= mean(prop_target_Bin4_1sec,na.rm=TRUE),looktime.distract.Bin4=mean(prop_distractor_Bin4_1sec,na.rm=TRUE),looktime.taget.Bin5= mean(prop_target_Bin5_1sec,na.rm=TRUE),looktime.distract.Bin5=mean(prop_distractor_Bin5_1sec,na.rm=TRUE),looktime.taget.Bin6= mean(prop_target_Bin6_1sec,na.rm=TRUE),looktime.distract.Bin6=mean(prop_distractor_Bin6_1sec,na.rm=TRUE), lure.trans = mean(NSwitchROIs.Lure, na.rm=TRUE),target.trans=mean(NSwitchROIs.Target, na.rm=TRUE), within.trans=mean(NSwitchROIs, na.rm=TRUE)))
data$Similarity=ifelse(data$Similarity==0, "dissimilar","similar")
data$Accuracy=ifelse(data$Accuracy==0, "inaccurate","accurate")
data=reshape(data, idvar = c("Subject", "Accuracy"), timevar = "Similarity", direction="wide")
data=reshape(data, idvar = "Subject", timevar = "Accuracy", direction="wide")

d.ET=merge(d.ET, data, by.x="Subject", by.y="Subject")

# RTs ---------------------------------------------------------------------

##is there a difference between similar incorrect answers and dissimilar incorrect answers?
psych::describe(d.TS$RT_TS.similar.inaccurate)
psych::describe(d.TS$RT_TS.dissimilar.inaccurate)

t.test(d.TS$RT_TS.dissimilar.inaccurate,d.TS$RT_TS.similar.inaccurate, paired=TRUE)
cohen.d(d.TS$RT_TS.dissimilar.inaccurate,d.TS$RT_TS.similar.inaccurate, paired=TRUE, na.rm=TRUE)

###Multilevel Model in order to not have all of the list-wise deletions comparing inaccurate responses to each other
RT_multi <- subset(TS[TS$Accuracy==0,])
RT_multi <- RT_multi[,c(1,7,8)]
RT_multi$Similarity <- as.factor(RT_multi$Similarity)

mRT <- lme(RT ~  Similarity,
          data=RT_multi,
          random =~ 1|Subject,
          na.action = na.omit)
summary(mRT)
intervals(mRT) #gives confidence intervals

##Run the RT analyses
data=subset(d.TS, select=c(Subject, RT_TS.incorr, RT_TS.dissimilar.accurate,RT_TS.similar.accurate))
data[complete.cases(data)==FALSE,] # people will missin data
nrow(data)-nrow(data[complete.cases(data),]) #how many people removed for NA
data <- data[complete.cases(data),]

anova_data=melt(data, id.vars = c("Subject"), 
                variable.name = "condition")
anova_data$condition=revalue(anova_data$condition, c("RT_TS.incorr"="Inaccurate", "RT_TS.dissimilar.accurate"="Dissimilar-Accurate","RT_TS.similar.accurate"="Similar-Accurate"))

results=as.data.frame(ezANOVA(data=anova_data, dv=value,wid=.(Subject),
                              within=.(condition),type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

####Descriptives, T-tests, and effect size
psych::describe(data$RT_TS.similar.accurate)
psych::describe(data$RT_TS.dissimilar.accurate)
psych::describe(data$RT_TS.incorr)

t.test(data$RT_TS.similar.accurate,data$RT_TS.dissimilar.accurate, paired=TRUE)
t.test(data$RT_TS.similar.accurate,data$RT_TS.incorr, paired=TRUE)
t.test(data$RT_TS.dissimilar.accurate,data$RT_TS.incorr, paired=TRUE)

cohen.d(data$RT_TS.similar.accurate,data$RT_TS.dissimilar.accurate, paired=TRUE, na.rm=TRUE)
cohen.d(data$RT_TS.similar.accurate,data$RT_TS.incorr, paired=TRUE, na.rm=TRUE)
cohen.d(data$RT_TS.dissimilar.accurate,data$RT_TS.incorr, paired=TRUE, na.rm=TRUE)

#Exp 1 CI 
get.ci.partial.eta.squared(6.461, 2, 136, conf.level = .95)

#Exp 2 CI 
get.ci.partial.eta.squared(4.896, 2, 126, conf.level = .95)

####Graphing Response times
TS_RT_sum <- summarySE(anova_data, measurevar="value", groupvars=c("condition"),na.rm=TRUE)
TS_RT_sum$condition=factor(TS_RT_sum$condition, levels=c("Dissimilar-Accurate","Similar-Accurate", "Inaccurate"))

#Now we can use ggplot to do the line graph
b <- ggplot(data=TS_RT_sum, aes(x=condition, y=value,fill=condition)) + #fill puts in the colors
  geom_bar(stat="identity")+
  theme(strip.background = element_blank(), strip.text.x = element_blank())+
  scale_fill_grey()  + 
  guides(fill=FALSE)+ #takes out legend
  geom_errorbar(aes(ymin=value-ci, ymax=value+ci), width=.1)+
  geom_jitter(data = anova_data, aes(x = condition, y = value)) + 
  #scale_y_log10()+
  xlab("") +
  ylab("Mean Response Latency") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(text = element_text(size=18))

#Print out the graph
graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = print(b), type="body") 

#Correlations between differences in trial types and age
data$Age <- d.TS$age[match(data$Subject, d.TS$Subject)]
data$Diff.sim.inacc <- data$RT_TS.similar.accurate - data$RT_TS.incorr
data$Diff.diss.inacc <- data$RT_TS.dissimilar.accurate - data$RT_TS.incorr
data$Diff.diss.sim <- data$RT_TS.dissimilar.accurate - data$RT_TS.similar.accurate

rcorr(data$Diff.sim.inacc, data$Age, type = "pearson")
rcorr(data$Diff.diss.inacc, data$Age, type = "pearson")
rcorr(data$Diff.diss.sim, data$Age, type = "pearson")

###Multilevel Model in order to not have all of the list-wise deletions
RT_multi <- TS[,c(1,6,7,8)]
for(i in 1:nrow(RT_multi)){
  if(RT_multi$Accuracy[i] == 0){
    RT_multi$Condition[i] <- "Inaccurate"
  }
  if(RT_multi$Accuracy[i]==1 & RT_multi$Similarity[i]==0){
    RT_multi$Condition[i] <- "Dissimilar-Accurate"
  }
  if(RT_multi$Accuracy[i]==1 & RT_multi$Similarity[i]==1){
    RT_multi$Condition[i] <- "Similar-Accurate"
  }
}
RT_multi$Condition=factor(RT_multi$Condition, levels=c("Inaccurate","Similar-Accurate", "Dissimilar-Accurate"))

mRT2 <- lme(RT ~  Condition,
           data=RT_multi,
           random =~ 1|Subject,
           na.action = na.omit)
summary(mRT2)
intervals(mRT2) #gives confidence intervals
#Null model
mRT2a <- lme(RT ~  1,
             data=RT_multi,
             random =~ 1|Subject,
             na.action = na.omit)
summary(mRT2a)
#against sim acc trials
RT_multi$Condition=factor(RT_multi$Condition, levels=c("Similar-Accurate", "Dissimilar-Accurate", "Inaccurate"))

mRT3 <- lme(RT ~  Condition,
            data=RT_multi,
            random =~ 1|Subject,
            na.action = na.omit)
summary(mRT3)
intervals(mRT3)

# Drift -------------------------------------------------------------------
data=subset(d.TS, select=c(Subject, Dis.alpha, Dis.tau,Dis.delta,Sim.alpha,Sim.tau,Sim.delta,I_dont_know,Macbates,age,mental_states_sure_unsure,alpha,tau,delta))

t.test(d.TS$Dis.alpha, d.TS$Sim.alpha, paired=TRUE)
t.test(d.TS$Dis.delta, d.TS$Sim.delta, paired=TRUE)
t.test(d.TS$Dis.tau, d.TS$Sim.tau, paired=TRUE)

effsize :: cohen.d(d.TS$Dis.alpha,d.TS$Sim.alpha, paired=TRUE, na.rm=TRUE)
effsize :: cohen.d(d.TS$Dis.delta,d.TS$Sim.delta, paired=TRUE, na.rm=TRUE)
effsize :: cohen.d(d.TS$Dis.tau,d.TS$Sim.tau, paired=TRUE, na.rm=TRUE)

psych :: describe(d.TS$Dis.alpha)
psych :: describe(d.TS$Dis.delta)
psych :: describe(d.TS$Dis.tau)

psych :: describe(d.TS$Sim.alpha)
psych :: describe(d.TS$Sim.delta)
psych :: describe(d.TS$Sim.tau)

##Drift with language regression
fit <- lm(I_dont_know ~ age + Macbates + alpha + delta, data = d.TS)
summary(fit)
confint(fit, level=.95)
QuantPsyc::lm.beta(fit)

fit1 <- lm(mental_states_sure_unsure ~ age + Macbates + alpha + delta, data = d.TS)
summary(fit1)
confint(fit1, level=.95)

###Get data ready for graphing
Participants_Drift_long <- gather(d.TS, "Parameter", "Value", 22:27)
Participants_Drift_long <- Participants_Drift_long[,c(1,34,35)]
Parameter <- str_split(Participants_Drift_long$Parameter, pattern = fixed("."), simplify=TRUE)
Parameter <- as.data.frame(Parameter)
Participants_Drift_long$Parameter <- Parameter[,"V2"]
Participants_Drift_long$Similarity <- Parameter[,"V1"]

Participants_Drift_long$Similarity <- factor(Participants_Drift_long$Similarity, levels = c("Dis", "Sim"), labels = c("Dissimilar", "Similar"))
Participants_Drift_long$Parameter <- factor(Participants_Drift_long$Parameter, levels = c( "delta","alpha", "tau"), labels = c( "Drift","Separation", "Non-Decision"))

Drift_Sum <- summarySE(Participants_Drift_long, measurevar="Value", groupvars=c("Similarity", "Parameter"),na.rm=TRUE)
Drift_Sum <- Drift_Sum %>% arrange(desc(Drift_Sum$Similarity))
c <- ggplot(data=Drift_Sum, aes(x=factor(Similarity), y=Value,fill=Similarity)) + #fill puts in the colors
  geom_bar(stat="identity")+
  scale_fill_grey()  + 
  guides(fill=FALSE)+ #takes out legend
  geom_errorbar(aes(ymin=Value-ci, ymax=Value+ci), width=.1)+
  geom_jitter(data = Participants_Drift_long, aes(x = Similarity, y = Value)) + 
  #xlab("")+
  xlab("    Drift                        Separation                    Non-Decision") +
  ylab("Parameter Estimate") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(text = element_text(size=18))+
  facet_grid(~Parameter)+
  panel_border(remove=TRUE)+
  theme(strip.background = element_blank(),strip.text.x = element_blank())

graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = print(c), type="body") 

# Eyetracker Looktime Analysis and ET RT --------------------------------------------
##RT analysis
data=subset(d.ET, select=c(Subject, RT_ET.incorr, RT_ET.dissimilar.accurate,RT_ET.similar.accurate))

ET_RT_long <- reshape(data, idvar="Subject", varying=c("RT_ET.incorr", "RT_ET.dissimilar.accurate","RT_ET.similar.accurate"),v.names="Mean",timevar='Acc', direction = "long")
ET_RT_long$Acc <- factor(ET_RT_long$Acc, levels = c(1,2,3), labels = c("Inaccurate", "Dissimilar-Accurate", "Similar-Accurate"))
ET_RT_long<-ET_RT_long[order(ET_RT_long$Subject),]

####Graphing Response times
ET_RT_sum <- summarySE(ET_RT_long, measurevar="Mean", groupvars=c("Acc"),na.rm=TRUE)
ET_RT_sum$Acc=factor(ET_RT_sum$Acc, levels=c("Dissimilar-Accurate","Similar-Accurate", "Inaccurate"))

##Pull out avgs to use for looking time analysis
for(i in 1:nrow(ET_RT_sum)){
  if(ET_RT_sum$Acc[i] == "Dissimilar-Accurate"){
    diss <- ET_RT_sum$Mean[i]
  }
  if(ET_RT_sum$Acc[i] == "Similar-Accurate"){
    sim <- ET_RT_sum$Mean[i]
  }
  if(ET_RT_sum$Acc[i] == "Inaccurate"){
    inacc <- ET_RT_sum$Mean[i]
  }
}

#Now we can use ggplot to do the graph
d <- ggplot(data=ET_RT_sum, aes(x=Acc, y=Mean,fill=Acc)) + #fill puts in the colors
  geom_bar(stat="identity")+
  scale_fill_grey()  + 
  guides(fill=FALSE)+ #takes out legend
  geom_errorbar(aes(ymin=Mean-ci, ymax=Mean+ci), width=.1)+
  geom_jitter(data = ET_RT_long, aes(x = Acc, y = Mean)) + 
  xlab("") +
  ylab("Mean Response Latency") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(text = element_text(size=18))

graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = print(d), type="body") 

##For multilevel model
ET_test <- subset(ET, select = c(Subject, Trial, Similarity, Accuracy, prop_target_Bin1_1sec, prop_distractor_Bin1_1sec, prop_target_Bin2_1sec, prop_distractor_Bin2_1sec, prop_target_Bin3_1sec, prop_distractor_Bin3_1sec))

ET_test1 <- ddply(ET_test, c("Subject", "Trial", "Similarity", "Accuracy"), summarise,
                  Bin1=mean(prop_target_Bin1_1sec, na.rm=TRUE),
                  Bin2=mean(prop_target_Bin2_1sec, na.rm =TRUE),
                  Bin3=mean(prop_target_Bin3_1sec, na.rm=TRUE))
ET_test1$Similarity <- factor(ET_test1$Similarity, levels = c(0,1), labels = c("Diss", "Sim"))
ET_test1$Accuracy <- factor(ET_test1$Accuracy, levels = c(0,1), labels = c("Inacc", "Acc"))
ET_test_wide <- reshape(ET_test1, idvar=c("Subject", "Similarity", "Trial"), timevar="Accuracy", direction = "wide")
ET_test_wide2 <- reshape(ET_test_wide, idvar=c("Subject", "Trial"), timevar="Similarity", direction = "wide")
ET_cond <- ET_test_wide2[,c('Subject','Trial','Bin1.Acc.Sim', 'Bin1.Acc.Diss','Bin2.Acc.Sim', 'Bin2.Acc.Diss'
                            ,'Bin3.Acc.Sim', 'Bin3.Acc.Diss')]
colnames(ET_cond) <- c('Subject','Trial', 'Bin.1_Acc.Sim', 'Bin.1_Acc.Diss', 'Bin.2_Acc.Sim', 'Bin.2_Acc.Diss'
                       , 'Bin.3_Acc.Sim', 'Bin.3_Acc.Diss')

ET_test2 <- ddply(ET_test, c("Subject", "Trial", "Accuracy"), summarise,
                  Bin1=mean(prop_distractor_Bin1_1sec, na.rm=TRUE),
                  Bin2=mean(prop_distractor_Bin2_1sec, na.rm=TRUE),
                  Bin3=mean(prop_distractor_Bin3_1sec, na.rm=TRUE))
ET_test2$Accuracy <- factor(ET_test2$Accuracy, levels = c(0,1), labels = c("Inacc", "Acc"))
ET_test2_wide <- reshape(ET_test2, idvar=c("Subject", "Trial"), timevar="Accuracy", direction = "wide")
ET_acc <- ET_test2_wide[,c('Subject','Trial','Bin1.Inacc', 'Bin2.Inacc'
                           ,'Bin3.Inacc')]
colnames(ET_acc) <- c('Subject', 'Trial', 'Bin.1_Inacc','Bin.2_Inacc','Bin.3_Inacc')
ET_bin_total <- merge(ET_cond, ET_acc, by = c("Subject", "Trial"))
ET_total_long <- reshape(ET_bin_total, varying = c(3:11), direction = "long", idvar = c("Subject", "Trial"), sep="_", timevar= "Cond")
ET_total_long2 <- reshape(ET_total_long, varying = c(4:6), direction = "long", idvar = c("Subject", "Trial", "Cond"), sep=".", timevar= "Time_Bin")

###Multilevel Model
ET_total_long2$Time_Bin <- as.factor(ET_total_long2$Time_Bin)
ET_total_long2$Cond <- as.factor(ET_total_long2$Cond)

###First run it dummy coded to inaccurate and time bin1
ET_total_long2$Cond=factor(ET_total_long2$Cond, levels=c("Inacc","Acc.Sim", "Acc.Diss"))

m1 <- lme(Bin ~ Time_Bin + Cond + Cond*Time_Bin,
          data=ET_total_long2,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m1)
intervals(m1) #gives confidence intervals

#Null model
m1a <- lme(Bin ~ 1,
          data=ET_total_long2,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m1a)
intervals(m1a)

##Dummy code to sim acc to get inacc findings
ET_total_long2$Cond=factor(ET_total_long2$Cond, levels=c("Acc.Sim", "Acc.Diss", "Inacc"))
m2 <- lme(Bin ~ Cond + Time_Bin + Cond*Time_Bin,
          data=ET_total_long2,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m2)
intervals(m2) #gives confidence intervals


###Look at bins individually
#bin1
ET_bin1 <- subset(ET_total_long2, ET_total_long2$Time_Bin == 1)
ET_bin1$Cond=factor(ET_bin1$Cond, levels=c("Inacc","Acc.Sim", "Acc.Diss"))
m3 <- lme(Bin ~ Cond,
          data=ET_bin1,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m3)
intervals(m3) #gives confidence intervals

ET_bin1$Cond=factor(ET_bin1$Cond, levels=c("Acc.Sim", "Acc.Diss","Inacc"))
m4 <- lme(Bin ~ Cond,
          data=ET_bin1,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m4)
intervals(m4)

p.adjust(c(.0458,.0990,.6774), method = "bonferroni", n=3)

#Bin2
ET_bin2 <- subset(ET_total_long2, ET_total_long2$Time_Bin == 2)
ET_bin2$Cond=factor(ET_bin2$Cond, levels=c("Inacc","Acc.Sim", "Acc.Diss"))
m5 <- lme(Bin ~ Cond,
          data=ET_bin2,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m5)
intervals(m5)

ET_bin2$Cond=factor(ET_bin2$Cond, levels=c("Acc.Sim", "Acc.Diss","Inacc"))
m6 <- lme(Bin ~ Cond,
          data=ET_bin2,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m6)
intervals(m6)

p.adjust(c(.0028,.0695,.1371), method = "bonferroni", n=3)

#Bin3
ET_bin3 <- subset(ET_total_long2, ET_total_long2$Time_Bin == 3)
ET_bin3$Cond=factor(ET_bin3$Cond, levels=c("Inacc","Acc.Sim", "Acc.Diss"))
m7 <- lme(Bin ~ Cond,
          data=ET_bin3,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m7)
intervals(m7) 

ET_bin3$Cond=factor(ET_bin3$Cond, levels=c("Acc.Sim", "Acc.Diss","Inacc"))
m8 <- lme(Bin ~ Cond,
          data=ET_bin3,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m8)
intervals(m8)

p.adjust(c(.0047,.0059,.9627), method = "bonferroni", n=3)

#For graph
ET_cond_Bin1_1sec <- ddply(ET_test, c("Subject", "Similarity", "Accuracy"), summarise,
                           mean = mean(prop_target_Bin1_1sec, na.rm=TRUE))
ET_cond_Bin2_1sec <- ddply(ET_test, c("Subject", "Similarity", "Accuracy"), summarise,
                           mean = mean(prop_target_Bin2_1sec, na.rm=TRUE))
ET_cond_Bin3_1sec <- ddply(ET_test, c("Subject", "Similarity", "Accuracy"), summarise,
                           mean = mean(prop_target_Bin3_1sec, na.rm=TRUE))

ET_cond_Bin1_1sec$Bin <- 1
ET_cond_Bin2_1sec$Bin <- 2
ET_cond_Bin3_1sec$Bin <- 3

ET_cond_bins <- rbind(ET_cond_Bin1_1sec, ET_cond_Bin2_1sec,ET_cond_Bin3_1sec)#, ET_cond_bin6, ET_cond_bin7, ET_cond_bin8, ET_cond_bin9, ET_cond_Bin1_1sec0)
ET_cond_bins$Similarity <- factor(ET_cond_bins$Similarity, levels = c(0,1), labels = c("Diss", "Sim"))
ET_cond_bins$Accuracy <- factor(ET_cond_bins$Accuracy, levels = c(0,1), labels = c("Inacc", "Acc"))
ET_cond_bins_wide <- reshape(ET_cond_bins, idvar=c("Subject", "Similarity", "Bin"), timevar="Accuracy", direction = "wide")
ET_cond_bins_wide2 <- reshape(ET_cond_bins_wide, idvar=c("Subject", "Bin"), timevar="Similarity", direction = "wide")
ET_cond <- ET_cond_bins_wide2[,c('Subject','Bin','mean.Acc.Sim', 'mean.Acc.Diss')]
colnames(ET_cond) <- c('Subject','Bin', 'Looktime.Acc.Sim', 'Looktime.Acc.Diss')


ET_acc_Bin1_1sec <- ddply(ET_test, c("Subject", "Accuracy"), summarise,
                          mean = mean(prop_distractor_Bin1_1sec, na.rm=TRUE))
ET_acc_Bin2_1sec <- ddply(ET_test, c("Subject", "Accuracy"), summarise,
                          mean = mean(prop_distractor_Bin2_1sec, na.rm=TRUE))
ET_acc_Bin3_1sec <- ddply(ET_test, c("Subject", "Accuracy"), summarise,
                          mean = mean(prop_distractor_Bin3_1sec, na.rm=TRUE))

ET_acc_Bin1_1sec$Bin <- 1
ET_acc_Bin2_1sec$Bin <- 2
ET_acc_Bin3_1sec$Bin <- 3

ET_acc_bins <- rbind(ET_acc_Bin1_1sec, ET_acc_Bin2_1sec,ET_acc_Bin3_1sec)#, ET_acc_bin6, ET_acc_bin7, ET_acc_bin8, ET_acc_bin9, ET_acc_Bin1_1sec0)

ET_acc_bins$Accuracy <- factor(ET_acc_bins$Accuracy, levels = c(0,1), labels = c("Inacc", "Acc"))
ET_acc_bins_wide <- reshape(ET_acc_bins, idvar=c("Subject", "Bin"), timevar="Accuracy", direction = "wide")
ET_acc <- ET_acc_bins_wide[,c('Subject','Bin','mean.Inacc')]
colnames(ET_acc) <- c('Subject','Bin' ,'Looktime.Inacc')
ET_looktime <- merge(ET_cond, ET_acc, by = c("Subject", "Bin"))
ET_looktime_wide <- reshape(ET_looktime, idvar= "Subject", timevar="Bin", direction="wide")
colnames(ET_looktime_wide) <- c('Subject','Bin1_looktime_sim_acc' ,'Bin1_looktime_diss_acc', 'Bin1_looktime_inacc'
                                ,'Bin2_looktime_sim_acc' ,'Bin2_looktime_diss_acc', 'Bin2_looktime_inacc'
                                ,'Bin3_looktime_sim_acc' ,'Bin3_looktime_diss_acc', 'Bin3_looktime_inacc')

ET_looktime_long <- reshape(ET_looktime, idvar=c("Subject", "Bin"), varying=c("Looktime.Acc.Sim","Looktime.Acc.Diss",'Looktime.Inacc'),v.names="Mean",timevar='Trial', direction = "long")
ET_looktime_long$Trial <- factor(ET_looktime_long$Trial, levels = c(1,2,3), labels = c("Similar-Accurate", "Dissimilar-Accurate", "Inaccurate"))
ET_looktime_long$Trial =factor(ET_looktime_long$Trial, levels=c("Dissimilar-Accurate","Similar-Accurate", "Inaccurate"))
ET_looktime_long$Bin <- factor(ET_looktime_long$Bin, levels = c(1,2,3), labels = c("0-1", "1-2", "2-3"))#, "2.5-3","3-3.5", "3.5-4","4-4.5","4.5-5"))
Bin_Sum <- summarySE(ET_looktime_long, measurevar="Mean", groupvars=c("Bin","Trial"),na.rm=TRUE)
#Now we can use ggplot to do the line graph
e <- ggplot(Bin_Sum, aes(x=Bin, y=Mean, colour=Trial)) + 
  geom_errorbar(aes(ymin=Mean-ci, ymax=Mean+ci), width=.1) +
  geom_line(aes(group=Trial), size=2) +
  geom_point()+
  geom_jitter(data = ET_looktime_long, aes(x = Bin, y = Mean, colour=Trial)) + 
  xlab("Time Bins (Seconds)") +
  ylab("Proportion Look Time") +
  scale_colour_manual(values = c( "black","grey47", "gray77"))+
  theme_bw() +                                #This changes the look of the graph, default is grey
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(axis.text.x=element_text(angle=90))+ #This makes the x axis labels vertical
  theme(text = element_text(size=18))+
  theme(legend.position = c(.25, 0.8))

graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = print(e), type="body") 

## supplemental look time graph
ET$Looking_Prop <- NA
ET$Category <- NA

#Exp 1
for(i in 1:nrow(ET)){
  if(ET$Accuracy[i]==0){
    ET$Looking_Prop[i] <- ET$prop_distractor_Bin5_1sec[i]
    ET$Category[i] <- "Inaccurate"
  }
  if((ET$Accuracy[i]==1) & (ET$Similarity[i]==1)){
    ET$Looking_Prop[i] <- ET$prop_target_Bin4_1sec[i]
    ET$Category[i] <- "Similar-Accurate"
  }
  if((ET$Accuracy[i]==1) & (ET$Similarity[i]==0)){
    ET$Looking_Prop[i] <- ET$prop_target_Bin3_1sec[i]
    ET$Category[i] <- "Dissimilar-Accurate"
    
  }
}
# Exp 2
for(i in 1:nrow(ET)){
  if(ET$Accuracy[i]==0){
    ET$Looking_Prop[i] <- ET$prop_distractor_Bin6_1sec[i]
    ET$Category[i] <- "Inaccurate"
  }
  if((ET$Accuracy[i]==1) & (ET$Similarity[i]==1)){
    ET$Looking_Prop[i] <- ET$prop_target_Bin5_1sec[i]
    ET$Category[i] <- "Similar-Accurate"
  }
  if((ET$Accuracy[i]==1) & (ET$Similarity[i]==0)){
    ET$Looking_Prop[i] <- ET$prop_target_Bin5_1sec[i]
    ET$Category[i] <- "Dissimilar-Accurate"
    
  }
}
ET_RT_looking <- ET[, c("Subject","Looking_Prop","Category")]
Looking_Times <- ddply(ET_RT_looking, c("Subject", "Category"), summarise,
                       mean = mean(Looking_Prop, na.rm=TRUE))
ET_RT_look_sum <- summarySE(Looking_Times, measurevar="mean", groupvars=c("Category"),na.rm=TRUE)
ET_RT_look_sum$Category=factor(ET_RT_look_sum$Category, levels=c("Dissimilar-Accurate","Similar-Accurate", "Inaccurate"))
Looking_times_wide <- reshape(Looking_Times, idvar=c("Subject"), timevar="Category", direction = "wide")

f <- ggplot(data=ET_RT_look_sum, aes(x=Category, y=mean,fill=Category)) + #fill puts in the colors
  geom_bar(stat="identity")+
  scale_fill_grey()  + 
  guides(fill=FALSE)+ #takes out legend
  geom_errorbar(aes(ymin=mean-ci, ymax=mean+ci), width=.1)+
  geom_jitter(data = Looking_Times, aes(x = Category, y = mean)) + 
  xlab("") +
  ylab("Mean Proportion Looktime") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(text = element_text(size=18))

graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = print(f), type="body") 


###Check inaccurate multi
t.test(d.ET$looktime.distract.Bin1.dissimilar.inaccurate,d.ET$looktime.distract.Bin1.similar.inaccurate, paired=TRUE)
t.test(d.ET$looktime.distract.Bin2.dissimilar.inaccurate,d.ET$looktime.distract.Bin2.similar.inaccurate, paired=TRUE)
t.test(d.ET$looktime.distract.Bin3.dissimilar.inaccurate,d.ET$looktime.distract.Bin3.similar.inaccurate, paired=TRUE)

ET_cond <- ET_test_wide2[,c('Subject','Trial','Bin1.Inacc.Sim', 'Bin1.Inacc.Diss','Bin2.Inacc.Sim', 'Bin2.Inacc.Diss'
                            ,'Bin3.Inacc.Sim', 'Bin3.Inacc.Diss')]
colnames(ET_cond) <- c('Subject','Trial','Bin.1_Sim', 'Bin.1_Diss','Bin.2_Sim', 'Bin.2_Diss'
                       ,'Bin.3_Sim', 'Bin.3_Diss')

ET_cond_long <- reshape(ET_cond, varying = c(3:8), direction = "long", idvar = c("Subject", "Trial"), sep="_", timevar= "Cond")
ET_cond_long2 <- reshape(ET_cond_long, varying = c(4:6), direction = "long", idvar = c("Subject", "Trial", "Cond"), sep=".", timevar= "Time_Bin")

###Multilevel Model
ET_cond_long2$Cond <- as.factor(ET_cond_long2$Cond)
ET_cond_long2$Time_Bin <- as.factor(ET_cond_long2$Time_Bin)

###First run it dummy coded to inaccurate and time bin1
ET_total_long2$Cond=factor(ET_total_long2$Cond, levels=c("Inacc","Acc.Sim", "Acc.Diss"))

m1 <- lme(Bin ~ Time_Bin + Cond + Cond*Time_Bin,
          data=ET_cond_long2,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m1)
intervals(m1) #gives confidence intervals


# Transitions Analysis ----------------------------------------------------
##checking multi level model
t.test(d.ET$trans.dissimilar.inaccurate,d.ET$trans.similar.inaccurate, paired=TRUE)

###Multilevel Model
Trans_multi <- subset(ET[ET$Accuracy==0,])
Trans_multi <- Trans_multi[,c(1,11,8)]
Trans_multi$Similarity <- as.factor(Trans_multi$Similarity)

###First run it dummy coded to inaccurate and time bin1
m1 <- lme(Transition ~  Similarity,
          data=Trans_multi,
          random =~ 1|Subject,
          na.action = na.omit)
summary(m1)
intervals(m1) #gives confidence intervals

psych :: describe(d.ET$trans.similar.inaccurate)
psych :: describe(d.ET$trans.dissimilar.inaccurate)

##Run the Trans analyses
data=subset(d.ET, select=c(Subject, trans.incorr, trans.dissimilar.accurate,trans.similar.accurate))
data[complete.cases(data)==FALSE,] # people will missin data
nrow(data)-nrow(data[complete.cases(data),]) #how many people removed for NA
data <- data[complete.cases(data),]

anova_data=melt(data, id.vars = c("Subject"), 
                variable.name = "condition")
anova_data$condition=revalue(anova_data$condition, c("trans.incorr"="Inaccurate", "trans.dissimilar.accurate"="Dissimilar-Accurate","trans.similar.accurate"="Similar-Accurate"))

results=as.data.frame(ezANOVA(data=anova_data, dv=value,wid=.(Subject),
                              within=.(condition),type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

####Descriptives, T-tests, and effect size
describe(data$trans.similar.accurate)
describe(data$trans.dissimilar.accurate)
describe(data$trans.incorr)

t.test(data$trans.similar.accurate,data$trans.dissimilar.accurate, paired=TRUE)
t.test(data$trans.similar.accurate,data$trans.incorr, paired=TRUE)
t.test(data$trans.dissimilar.accurate,data$trans.incorr, paired=TRUE)

cohen.d(data$trans.similar.accurate,data$trans.dissimilar.accurate, paired=TRUE, na.rm=TRUE)
cohen.d(data$trans.similar.accurate,data$trans.incorr, paired=TRUE, na.rm=TRUE)
cohen.d(data$trans.dissimilar.accurate,data$trans.incorr, paired=TRUE, na.rm=TRUE)

#Exp 1 CI 
get.ci.partial.eta.squared(3.901, 2, 126, conf.level = .95)

#Exp 2 CI 
get.ci.partial.eta.squared(3.185, 2, 112, conf.level = .95)

##### Eyetracker Transitions Graph
ET_trans_sum <- summarySE(anova_data, measurevar="value", groupvars=c("condition"),na.rm=TRUE)
ET_trans_sum$condition=factor(ET_trans_sum$condition, levels=c("Dissimilar-Accurate","Similar-Accurate", "Inaccurate"))

g <- ggplot(data=ET_trans_sum, aes(x=condition, y=value,fill=condition)) + #fill puts in the colors
  geom_bar(stat="identity")+
  scale_fill_grey()  + 
  guides(fill=FALSE)+ #takes out legend
  geom_errorbar(aes(ymin=value-se, ymax=value+se), width=.1)+
  geom_jitter(data = anova_data, aes(x = condition, y = value)) + 
  xlab("") +
  ylab("Mean Switch Count") +
  theme_bw() +
  theme(plot.title = element_text(hjust = .5))+
  theme(text = element_text(size=18))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = print(g), type="body") 

#Looking at age in months correlation with differences between trial types transitions and accuracy with average switches
#Find average transitions for each subject, get average accuracy, merge
ET_avg_trans <- ddply(ET, "Subject", summarise,
                      mean.trans = mean(Transition, na.rm=TRUE))
ET_avg_acc <- ddply(ET, "Subject", summarise,
                    mean.acc = mean(Accuracy, na.rm=TRUE))
ET_trans_acc <- merge(ET_avg_trans, ET_avg_acc, by = "Subject")

#merge trans sheet with trial types with age, find differences
data$Age <- ET$Age[match(data$Subject, ET$Subject)]
data$Diff.sim.inacc <- data$trans.similar.accurate - data$trans.incorr
data$Diff.diss.inacc <- data$trans.dissimilar.accurate - data$trans.incorr
data$Diff.diss.sim <- data$trans.dissimilar.accurate - data$trans.similar.accurate

#Correlations
rcorr(data$Diff.sim.inacc, data$Age, type = "pearson")
rcorr(data$Diff.diss.inacc, data$Age, type = "pearson")
rcorr(data$Diff.diss.sim, data$Age, type = "pearson")
rcorr(d.ET$total_trans, d.ET$total_pc_trimmed_ET, type = "pearson")

#multi level model version
Trans_multi <- ET[,c(1,6,8,11)]
for(i in 1:nrow(Trans_multi)){
  if(Trans_multi$Accuracy[i] == 0){
    Trans_multi$Condition[i] <- "Inaccurate"
  }
  if(Trans_multi$Accuracy[i]==1 & Trans_multi$Similarity[i]==0){
    Trans_multi$Condition[i] <- "Dissimilar-Accurate"
  }
  if(Trans_multi$Accuracy[i]==1 & Trans_multi$Similarity[i]==1){
    Trans_multi$Condition[i] <- "Similar-Accurate"
  }
}
Trans_multi$Condition=factor(Trans_multi$Condition, levels=c("Inaccurate","Similar-Accurate", "Dissimilar-Accurate"))

mTrans2 <- lme(Transition ~  Condition,
            data=Trans_multi,
            random =~ 1|Subject,
            na.action = na.omit)
summary(mTrans2)
intervals(mTrans2) #gives confidence intervals


mTrans2a <- lme(Transition ~  1,
             data=Trans_multi,
             random =~ 1|Subject,
             na.action = na.omit)
summary(mTrans2a)

Trans_multi$Condition=factor(Trans_multi$Condition, levels=c("Similar-Accurate", "Dissimilar-Accurate", "Inaccurate"))

mTrans3 <- lme(Transition ~  Condition,
               data=Trans_multi,
               random =~ 1|Subject,
               na.action = na.omit)
summary(mTrans3)
intervals(mTrans3) 


graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = NULL, type="body") 

graphs <- graphs %>% 
  add_slide(layout = "Title and Content", master = "Office Theme")
graphs <- graphs %>% 
  ph_with_vg(code = NULL, type="body") 


# Within-Transitions ------------------------------------------------------

data=subset(d.ET, select=c(Subject, target.trans.similar.accurate, lure.trans.similar.accurate, target.trans.dissimilar.accurate, lure.trans.dissimilar.accurate,target.trans.incorr, lure.trans.incorr))
names(data)= c("Subject", "Within_Target.Sim_Cor", "Within_Lure.Sim_Cor", "Within_Target.Dis_Cor", "Within_Lure.Dis_Cor", "Within_Target.Incorrect", "Within_Lure.Incorrect")
data[complete.cases(data)==FALSE,] # people will missin data
nrow(data)-nrow(data[complete.cases(data),]) #how many people removed for NA
data <- data[complete.cases(data),]

anova_data=melt(data, id.vars = c("Subject"), 
                variable.name = "condition")

Parameter <- str_split(anova_data$condition, pattern = fixed("."), simplify=TRUE)
Parameter <- as.data.frame(Parameter)
anova_data$trial <- Parameter[,"V2"]
anova_data$place <- Parameter[,"V1"]

results=as.data.frame(ezANOVA(data=anova_data, dv=value,wid=.(Subject),
                              within=.(trial,place),type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

t.test(data$Within_Target.Dis_Cor,data$Within_Lure.Dis_Cor, paired=TRUE)
t.test(data$Within_Target.Sim_Cor,data$Within_Lure.Sim_Cor, paired=TRUE)
t.test(data$Within_Target.Incorrect,data$Within_Lure.Incorrect, paired=TRUE)
t.test(data$Within_Lure.Dis_Cor,data$Within_Lure.Sim_Cor, paired=TRUE)

psych:: describe(data$Within_Target.Dis_Cor)
psych:: describe(data$Within_Lure.Dis_Cor)
psych:: describe(data$Within_Target.Sim_Cor)
psych:: describe(data$Within_Lure.Sim_Cor)
psych:: describe(data$Within_Target.Incorrect)
psych:: describe(data$Within_Lure.Incorrect)

cohen.d(data$Within_Target.Dis_Cor,data$Within_Lure.Dis_Cor, paired=TRUE, na.rm=TRUE)
cohen.d(data$Within_Target.Sim_Cor,data$Within_Lure.Sim_Cor, paired=TRUE, na.rm=TRUE)
cohen.d(data$Within_Target.Incorrect,data$Within_Lure.Incorrect, paired=TRUE, na.rm=TRUE)

#Exp 1 CI (trial, place, interaction)
get.ci.partial.eta.squared(3.641, 2, 106, conf.level = .95)
get.ci.partial.eta.squared(12.862, 1, 53, conf.level = .95)
get.ci.partial.eta.squared(9.126, 2, 106, conf.level = .95)

#Exp 2 CI (trial, place, interaction)
get.ci.partial.eta.squared(3.195, 2, 98, conf.level = .95)
get.ci.partial.eta.squared(13.778, 1, 49, conf.level = .95)
get.ci.partial.eta.squared(18.277, 2, 98, conf.level = .95)

within_trans_sum <- summarySE(anova_data, measurevar="value", groupvars=c("condition"),na.rm=TRUE)

data=subset(d.ET, select=c(Subject, within.trans.corr,within.trans.incorr))
t.test(data$within.trans.corr,data$within.trans.incorr, paired=TRUE)
cohen.d(data$within.trans.corr,data$within.trans.incorr, paired=TRUE, na.rm=TRUE)
psych:: describe(data$within.trans.corr)
psych:: describe(data$within.trans.incorr)


# HDDM --------------------------------------------------------------------

data=subset(d.TS, select=c(Subject, A_Dis_HDDM, t_Dis_HDDM,V_Dis_HDDM,A_Sim_HDDM,t_Sim_HDDM,V_Sim_HDDM,I_dont_know,Macbates,age,mental_states_sure_unsure,A_HDDM,t_HDDM,V_HDDM))

t.test(d.TS$A_Dis_HDDM, d.TS$A_Sim_HDDM, paired=TRUE)
t.test(d.TS$V_Dis_HDDM, d.TS$V_Sim_HDDM, paired=TRUE)
t.test(d.TS$t_Dis_HDDM, d.TS$t_Sim_HDDM, paired=TRUE)

effsize :: cohen.d(d.TS$Dis.alpha,d.TS$Sim.alpha, paired=TRUE, na.rm=TRUE)
effsize :: cohen.d(d.TS$Dis.delta,d.TS$Sim.delta, paired=TRUE, na.rm=TRUE)
effsize :: cohen.d(d.TS$Dis.tau,d.TS$Sim.tau, paired=TRUE, na.rm=TRUE)

psych :: describe(d.TS$A_Dis_HDDM)
psych :: describe(d.TS$V_Dis_HDDM)
psych :: describe(d.TS$t_Dis_HDDM)

psych :: describe(d.TS$A_Sim_HDDM)
psych :: describe(d.TS$V_Sim_HDDM)
psych :: describe(d.TS$t_Sim_HDDM)

##Drift with language regression
fit <- lm(I_dont_know ~ age + Macbates + A_HDDM + V_HDDM, data = data)
summary(fit)

fit1 <- lm(mental_states_sure_unsure ~ age + Macbates + A_HDDM + V_HDDM, data = data)
summary(fit1)
confint(fit1, level=.95)


# Uncertainty Behavior ----------------------------------------------------
#save study one data before doing this section
Total <- merge(d.TS, d.ET, by ="Subject", all.x=TRUE, all.y=TRUE)
Both <- Total

#uncertain combo
data=subset(Both, select=c(Subject, uncertain_combo.incorr,uncertain_combo.dissimilar.accurate,uncertain_combo.similar.accurate))
data[complete.cases(data)==FALSE,] # people will missin data
nrow(data)-nrow(data[complete.cases(data),]) #how many people removed for NA
data <- data[complete.cases(data),]

anova_data=melt(data, id.vars = c("Subject"), 
                variable.name = "condition")
#anova_data$condition=revalue(anova_data$condition, c("RT_ET.incorr"="Inaccurate", "RT_ET.dissimilar.accurate"="Dissimilar-Accurate","RT_ET.similar.accurate"="Similar-Accurate"))

results=as.data.frame(ezANOVA(data=anova_data, dv=value,wid=.(Subject),
                              within=.(condition),type=3,detailed=T)$ANOVA)
results$pareta=results$SSn/(results$SSn+results$SSd)
is.num=sapply(results, is.numeric)
results[is.num] =lapply(results[is.num], round, 3)
results

t.test(data$uncertain_combo.incorr,data$uncertain_combo.dissimilar.accurate, paired=TRUE)
t.test(data$uncertain_combo.incorr,data$uncertain_combo.similar.accurate, paired=TRUE)
t.test(data$uncertain_combo.dissimilar.accurate,data$uncertain_combo.similar.accurate, paired=TRUE)

cohen.d(data$uncertain_combo.incorr,data$uncertain_combo.dissimilar.accurate, paired=TRUE,na.rm=TRUE)
cohen.d(data$uncertain_combo.incorr,data$uncertain_combo.similar.accurate, paired=TRUE,na.rm=TRUE)
cohen.d(data$uncertain_combo.dissimilar.accurate,data$uncertain_combo.similar.accurate, paired=TRUE,na.rm=TRUE)

psych:: describe(data$uncertain_combo.incorr)
psych:: describe(data$uncertain_combo.dissimilar.accurate)
psych:: describe(data$uncertain_combo.similar.accurate)

get.ci.partial.eta.squared(4.908, 2, 230, conf.level = .95)

rcorr(Both$total_uncertain_combo, Both$total_RT_TS, type= "pearson")
rcorr(Both$uncertain_combo.incorr, Both$RT_TS.incorr, type= "pearson")
rcorr(Both$uncertain_combo.incorr, Both$trans.incorr, type= "pearson")
rcorr(Both$uncertain_combo.incorr, Both$alpha, type= "pearson")
rcorr(Both$uncertain_combo.incorr, Both$delta, type= "pearson")

CIr(r=.28, n = 116, level = .95)
CIr(r=.27, n = 116, level = .95)
CIr(r=.22, n = 116, level = .95)
CIr(r=-.09, n = 116, level = .95)
