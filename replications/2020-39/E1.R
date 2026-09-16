setwd("C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/work/2020-39")

library(tidyr)
library(dplyr)
library(reshape2)
library(lme4)
library(lmerTest)
library(boot)

# Clean Data --------------------------------------------------------------

# Import
S1 <- read.csv(file = "AutomaticInfluenceOfAdvocacy.Experiment1.RawData.csv")

# Format variables
S1$innocent        <- as.integer(S1$innocent)
S1$defend          <- as.integer(S1$defend)
S1$innocent        <- as.integer(S1$innocent)
S1$defend          <- as.integer(S1$defend)
S1$Race_6_TEXT     <- as.character(S1$Race_6_TEXT)
S1$English_12_TEXT <- as.character(S1$English_12_TEXT)
S1$subject         <- as.factor(S1$subject)
S1$workerId        <- as.factor(S1$workerId)

# Rename variables
S1$Good3b          <- S1$Good3a.1
S1$GuiltyChk1      <- S1$GuiltChk1
S1$Warm            <- S1$ExplicitLiking_15
S1$Cold            <- S1$ExplicitLiking_16
S1$Pleasant        <- S1$ExplicitLiking_17
S1$Unpleasant      <- S1$ExplicitLiking_18

# Create dummy and contrast codes
S1$Innocent.D      <- as.integer(ifelse(S1$innocent == 1, 0, 1))
S1$Guilty.D        <- as.integer(ifelse(S1$innocent == 1, 1, 0))
S1$Innocent.C      <- as.integer(ifelse(S1$innocent == 1, 1, -1))
S1$Defend.D        <- as.integer(ifelse(S1$defend   == 1, 0, 1))
S1$Prosecute.D     <- as.integer(ifelse(S1$defend   == 1, 1, 0))
S1$Defend.C        <- as.integer(ifelse(S1$defend   == 1, 1, -1))

# Subset clean data
S1.Clean <- subset(S1, select=c(
  subject, workerId,                                                  # Identification
  Innocent.D, Guilty.D, Innocent.C, Defend.D, Prosecute.D, Defend.C,  # Condition Codes
  GuiltyChk1, GuiltyChk2, PorDchk, AppearChk,                         # Attention Checks
  Good1a, Good2a, Good3a, Good4a, Good5a,                             # TS Items (Positive + Binary)
  Good1b, Good2b, Good3b, Good4b, Good5b,                             # TS Items (Positive + Continuous)
  Bad1a, Bad2a, Bad3a, Bad4a, Bad5a,                                  # TS Items (Negative + Binary)
  Bad1b, Bad2b, Bad3b, Bad4b, Bad5b,                                  # TS Items (Negative + Continuous)
  Warm, Cold, Pleasant, Unpleasant,                                   # Global Evaluations
  Age, Sex, Race, English))                                           # Demographics


# Compute Outcomes --------------------------------------------------------

# Compute Global Evaluations
Cold.r              <- (S1.Clean$Cold - 100)*(-1)
Unpleasant.r        <- (S1.Clean$Unpleasant - 100)*(-1)
S1.Clean$GlobalEval <- rowMeans(cbind(S1.Clean$Warm, Cold.r, S1.Clean$Pleasant, Unpleasant.r), na.rm = TRUE)

# Compute True Self Beliefs (Continuous)
S1.Clean$TSpos.C    <- rowMeans(cbind(S1.Clean$Good1b, S1.Clean$Good2b, S1.Clean$Good3b, S1.Clean$Good4b, S1.Clean$Good5b), na.rm = TRUE)
S1.Clean$TSneg.C    <- rowMeans(cbind(S1.Clean$Bad1b, S1.Clean$Bad2b, S1.Clean$Bad3b, S1.Clean$Bad4b, S1.Clean$Bad5b), na.rm = TRUE)
S1.Clean$TSval.C    <- S1.Clean$TSpos.C - S1.Clean$TSneg.C

# Compute True Self Beliefs (Binary)
TSb.Old             <- c(names(S1.Clean[, which(colnames(S1.Clean) == "Good1a"):which(colnames(S1.Clean) == "Good5a")]),
                         names(S1.Clean[, which(colnames(S1.Clean) == "Bad1a"):which(colnames(S1.Clean) == "Bad5a")]))
TSb.New             <- paste(TSb.Old, ".TS", sep = "")
S1.Clean[, TSb.New] <- ifelse(S1.Clean[, TSb.Old] == 1, 1, 0)
S1.Clean$TSpos.B    <- rowSums(S1.Clean[, TSb.New[1:5]])
S1.Clean$TSneg.B    <- rowSums(S1.Clean[, TSb.New[6:10]])
S1.Clean$TSval.B    <- S1.Clean$TSpos.B - S1.Clean$TSneg.B

# Compute Surface Self Beliefs (Binary)
SSb.New             <- paste(TSb.Old, ".SS", sep = "")
S1.Clean[, SSb.New] <- ifelse(S1.Clean[, TSb.Old] == 2, 1, 0)
S1.Clean$SSpos.B    <- rowSums(S1.Clean[, SSb.New[1:5]])
S1.Clean$SSneg.B    <- rowSums(S1.Clean[, SSb.New[6:10]])
S1.Clean$SSval.B    <- S1.Clean$SSpos.B - S1.Clean$SSneg.B


# Implement Exclusion Criteria --------------------------------------------

# Code attentiveness
AttentionChk1 <- ifelse(S1.Clean$GuiltyChk1 == 1 & S1.Clean$GuiltyChk2 == 2 & S1.Clean$Guilty.D == 0 |
                        S1.Clean$GuiltyChk1 == 2 & S1.Clean$GuiltyChk2 == 1 & S1.Clean$Guilty.D == 1, 1, 0 )
AttentionChk2 <- ifelse(S1.Clean$PorDchk == 1 & S1.Clean$AppearChk == 2 & S1.Clean$Prosecute.D == 0 |
                        S1.Clean$PorDchk == 2 & S1.Clean$AppearChk == 1 & S1.Clean$Prosecute.D == 1, 1, 0 )
S1.Clean$AttentionChk <- ifelse(AttentionChk1 == 1 & AttentionChk2 == 1, 1, 0)

# Exclude inattitive participants and incomplete rows
S1.Clean <- S1.Clean[complete.cases(S1.Clean) & S1.Clean$AttentionChk == 1,]


# Global Evaluations: Find Best Fitting Model -----------------------------

# Innocent + Defend + Innocent x Defend
lm_gEval1 <- lm(GlobalEval ~ Innocent.D*Defend.D,    data=S1.Clean)
cbind(coef(summary(lm_gEval1)), confint(lm_gEval1))

# Innocent + Defend
lm_gEval2 <- lm(GlobalEval ~ Innocent.D+Defend.D,    data=S1.Clean)
cbind(coef(summary(lm_gEval2)), confint(lm_gEval2))
anova(lm_gEval1, lm_gEval2)

# Global Evaluations: Analyses ----------------------------------------------
  
# Innocent
lm_gEval3 <- lm(GlobalEval ~ Innocent.D+Defend.C,    data=S1.Clean)
cbind(coef(summary(lm_gEval3)), confint(lm_gEval3))

# Guilty
lm_gEval4 <- lm(GlobalEval ~ Guilty.D+Defend.C,    data=S1.Clean)
cbind(coef(summary(lm_gEval4)), confint(lm_gEval4))

# Defend
lm_gEval5 <- lm(GlobalEval ~ Innocent.C+Defend.D,    data=S1.Clean)
cbind(coef(summary(lm_gEval5)), confint(lm_gEval5))

# Prosecute
lm_gEval6 <- lm(GlobalEval ~ Innocent.C+Prosecute.D,    data=S1.Clean)
cbind(coef(summary(lm_gEval6)), confint(lm_gEval6))


# True Self Beliefs (Continuous): Create Long Dataframe -------------------
S1c.TSc <- melt(S1.Clean,
                id.vars = c("workerId", "Innocent.D", "Guilty.D", "Innocent.C", "Defend.D", "Prosecute.D", "Defend.C"),
                measure.vars = c("Good1b", "Good2b", "Good3b", "Good4b", "Good5b", "Bad1b", "Bad2b", "Bad3b", "Bad4b", "Bad5b"),
                variable.name = "Vignette", value.name = "TSc")
S1c.TSc$Moral.D   <- ifelse(S1c.TSc$Vignette == "Good1b" | S1c.TSc$Vignette == "Good2b" | 
                            S1c.TSc$Vignette == "Good3b" | S1c.TSc$Vignette == "Good4b" |
                            S1c.TSc$Vignette == "Good5b", 0, 1)
S1c.TSc$Immoral.D <- ifelse(S1c.TSc$Moral.D == 1, 0, 1)
S1c.TSc$Moral.C   <- ifelse(S1c.TSc$Moral.D == 1, 1, -1)


# True Self Beliefs (Continuous): Find best fitting model -----------------
lm_TSc1 <- lmer(TSc ~ Innocent.D*Defend.D*Moral.D      + (1|workerId)       + (1|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
lm_TSc2 <- lmer(TSc ~ Innocent.D*Defend.D*Moral.D      + (Moral.D|workerId) + (1|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
anova(lm_TSc1, lm_TSc2)

lm_TSc3 <- lmer(TSc ~ Innocent.D*Defend.D*Moral.D      + (Moral.D|workerId) + (Defend.D|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
anova(lm_TSc2, lm_TSc3)

lm_TSc4 <- lmer(TSc ~ Innocent.D*Defend.D*Moral.D      + (Moral.D|workerId) + (Defend.D + Innocent.D|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
anova(lm_TSc3, lm_TSc4)

lm_TSc5 <- lmer(TSc ~ Innocent.D*Defend.D + Innocent.D*Moral.D + Defend.D*Moral.D + (Moral.D|workerId) + (Defend.D|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
anova(lm_TSc3, lm_TSc5)

lm_TSc6 <- lmer(TSc ~ Innocent.D+Defend.D+Moral.D + (Moral.D|workerId) + (Defend.D|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
anova(lm_TSc5, lm_TSc6)


# True Self Beliefs (Continuous): Analyses --------------------------------

# Moral x Defend
lm_TSc7 <- lmer(TSc ~ Innocent.C*Defend.D + Innocent.C*Moral.D + Defend.D*Moral.D       + (Moral.D|workerId) + (Defend.D|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSc7)), confint(lm_TSc7, method = "Wald")[8:14, ])

# Moral x Prosecute
lm_TSc8 <- lmer(TSc ~ Innocent.C*Prosecute.D + Innocent.C*Moral.D + Prosecute.D*Moral.D + (Moral.D|workerId) + (Prosecute.D|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSc8)), confint(lm_TSc8, method = "Wald")[8:14, ])

# Moral x Innocent
lm_TSc9 <- lmer(TSc ~ Innocent.D*Defend.C + Innocent.D*Moral.D + Defend.C*Moral.D     + (Moral.D|workerId) + (Defend.C|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSc9)), confint(lm_TSc9, method = "Wald")[8:14, ])

# Moral x Guilty
lm_TSc10 <- lmer(TSc ~ Guilty.D*Defend.C + Guilty.D*Moral.D + Defend.C*Moral.D         + (Moral.D|workerId) + (Defend.C|Vignette), data=S1c.TSc,
                control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSc10)), confint(lm_TSc10, method = "Wald")[8:14, ])


# True Self Beliefs (Continuous): Descriptives --------------------------------
  
# Bootstrap Function: Role x Morality
S1c.TSc.f <- function(data, indices){
  mean(predict(lm_TSc7, data[indices, ]))
}

# Bootstrap Inputs: Role x Morality
S1c.TSc.New  <- S1c.TSc
Conditions   <- cbind("Defend" = c(0, 0, 1, 1), "Moral" = c(0, 1, 0, 1)) 
Summary.TSc  <- matrix(nrow=length(Conditions[,1]), ncol = 5)

# Run Bootstrap: Role x Morality
for(x in 1:length(Conditions[,1])){
  Summary.TSc[x, 1:2]     <- Conditions[x, 1:2]
  S1c.TSc.New["Defend.D"] <- Conditions[x, 1]
  S1c.TSc.New["Moral.D"]  <- Conditions[x, 2]
  Boot.TSc                <- boot(S1c.TSc.New, S1c.TSc.f, R = 1000)
  Summary.TSc[x, 3]       <- Boot.TSc[[1]]
  Summary.TSc[x, 4:5]     <- quantile(Boot.TSc[[2]], c(0.025, 0.975))
}
colnames(Summary.TSc) <- c("Help", "Moral", "P", "lower.ci", "upper.ci")
Summary.TSc

# Bootstrap Function: Innocent x Morality
S1c.TSc.f <- function(data, indices){
  mean(predict(lm_TSc9, data[indices, ]))
}

# Bootstrap Inputs: Innocent x Morality
S1c.TSc.New  <- S1c.TSc
Conditions   <- cbind("Innocent" = c(0, 0, 1, 1), "Moral" = c(0, 1, 0, 1)) 
Summary.TSc  <- matrix(nrow=length(Conditions[,1]), ncol = 5)

# Run Bootstrap: Innocent x Morality
for(x in 1:length(Conditions[,1])){
  Summary.TSc[x, 1:2]       <- Conditions[x, 1:2]
  S1c.TSc.New["Innocent.D"] <- Conditions[x, 1]
  S1c.TSc.New["Moral.D"]    <- Conditions[x, 2]
  Boot.TSc                  <- boot(S1c.TSc.New, S1c.TSc.f, R = 1000)
  Summary.TSc[x, 3]         <- Boot.TSc[[1]]
  Summary.TSc[x, 4:5]       <- quantile(Boot.TSc[[2]], c(0.025, 0.975))
}
colnames(Summary.TSc) <- c("Innocent", "Moral", "P", "lower.ci", "upper.ci")
Summary.TSc
  
  
# True Self Beliefs (Binary): Create long dataframe ----------------------------------

# Create long data frame
S1c.TSb     <- melt(S1.Clean,
                    id.vars = c("workerId", "Innocent.D", "Guilty.D", "Innocent.C", "Defend.D", "Prosecute.D", "Defend.C"),
                    measure.vars = colnames(S1.Clean[, 45:54]),
                    variable.name = "Vignette", value.name = "TSb")
S1c.TSb$TSb <- as.integer(S1c.TSb$TSb)
S1c.TSb$Moral.D   <- as.integer(ifelse(is.element(S1c.TSb$Vignette, colnames(S1.Clean[, 45:49])), 0, 1))
S1c.TSb$Immoral.D <- as.integer(ifelse(S1c.TSb$Moral.D == 1, 0, 1))
S1c.TSb$Moral.C   <- as.integer(ifelse(S1c.TSb$Moral.D == 1, 1, -1))

# True Self Beliefs (Binary): Find best fitting model ---------------------

# Run models for tests of random effects structures
lm_TSb1 <- glmer(TSb ~ Innocent.D*Prosecute.D*Moral.D + (1|workerId)       + (1|Vignette), 
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
lm_TSb2 <- glmer(TSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (1|Vignette), 
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
lm_TSb3 <- glmer(TSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Innocent.D|Vignette), 
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
lm_TSb4 <- glmer(TSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Prosecute.D|Vignette), 
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
lm_TSb5 <- glmer(TSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Prosecute.D+Innocent.D|Vignette), 
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
lm_TSb6 <- glmer(TSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Prosecute.D*Innocent.D|Vignette), 
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Test random effects structures
anova(lm_TSb1, lm_TSb2)
anova(lm_TSb2, lm_TSb3)
anova(lm_TSb2, lm_TSb4)
anova(lm_TSb2, lm_TSb5)
anova(lm_TSb2, lm_TSb6)

# Run models for tests of fixed effects structures
lm_TSb7 <- glmer(TSb ~ Guilty.D*Moral.D + Guilty.D*Defend.D + Moral.D*Defend.D + (Moral.D|workerId) + (1|Vignette),
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
lm_TSb8 <- glmer(TSb ~ Guilty.D+Moral.D+Defend.D + (Moral.D|workerId) + (1|Vignette),
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Test fixed effects structures
anova(lm_TSb2, lm_TSb7)
anova(lm_TSb7, lm_TSb8)

# True Self Beliefs (Binary): Analyses ------------------------------------

# Moral x Innocent
lm_TSb9 <- glmer(TSb ~ Innocent.D*Moral.D + Innocent.D*Defend.C + Moral.D*Defend.C + (Moral.D|workerId) + (1|Vignette),
                  data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSb9)),
      "OR" = exp(coef(summary(lm_TSb9))[, 1]),
      exp(confint(lm_TSb9, method = "Wald")[5:11, ]))

# Moral x Guilty
lm_TSb10 <- glmer(TSb ~ Guilty.D*Moral.D + Guilty.D*Defend.C + Moral.D*Defend.C + (Moral.D|workerId) + (1|Vignette),
                  data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSb10)),
      "OR" = exp(coef(summary(lm_TSb10))[, 1]),
      exp(confint(lm_TSb10, method = "Wald")[5:11, ]))

# Moral x Defend
lm_TSb11 <- glmer(TSb ~ Innocent.C*Moral.D + Innocent.C*Defend.D + Moral.D*Defend.D + (Moral.D|workerId) + (1|Vignette),
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSb11)),
      "OR" = exp(coef(summary(lm_TSb11))[, 1]),
      exp(confint(lm_TSb11, method = "Wald")[5:11, ]))

# Moral x Prosecute
lm_TSb12 <- glmer(ifelse(TSb == 1, 0, 1) ~ Innocent.C*Moral.D + Innocent.C*Prosecute.D + Moral.D*Prosecute.D + (Moral.D|workerId) + (1|Vignette),
                 data=S1c.TSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_TSb12)),
      "OR" = exp(coef(summary(lm_TSb12))[, 1]),
      exp(confint(lm_TSb12, method = "Wald")[5:11, ]))


# True Self Beliefs (Binary): Descriptives --------------------------------

# Bootstrap Function: Role x Morality
S1c.TSb.f <- function(data, indices){
  mean(predict(lm_TSb9, data[indices, ], type = "response"))
}

# Bootstrap Inputs: Role x Morality
S1c.TSb.New  <- S1c.TSb
Conditions   <- cbind("Innocent" = c(0, 0, 1, 1), "Moral" = c(0, 1, 0, 1)) 
Summary.TSb  <- matrix(nrow=length(Conditions[,1]), ncol = 5)

# Run Bootstrap: Role x Morality
for(x in 1:length(Conditions[,1])){
  Summary.TSb[x, 1:2]     <- Conditions[x, 1:2]
  S1c.TSb.New["Innocent.D"] <- Conditions[x, 1]
  S1c.TSb.New["Moral.D"]  <- Conditions[x, 2]
  Boot.TSb                <- boot(S1c.TSb.New, S1c.TSb.f, R = 1000)
  Summary.TSb[x, 3]       <- Boot.TSb[[1]]
  Summary.TSb[x, 4:5]     <- quantile(Boot.TSb[[2]], c(0.025, 0.975))
}
colnames(Summary.TSb) <- c("Innocent", "Moral", "P", "lower.ci", "upper.ci")
Summary.TSb

# Bootstrap Function: Innocent x Morality
S1c.TSb.f <- function(data, indices){
  mean(predict(lm_TSb9, data[indices, ], type = "response"))
}

# Bootstrap Inputs: Innocent x Morality
S1c.TSb.New  <- S1c.TSb
Conditions   <- cbind("Innocent" = c(0, 0, 1, 1), "Moral" = c(0, 1, 0, 1)) 
Summary.TSb  <- matrix(nrow=length(Conditions[,1]), ncol = 5)

# Run Bootstrap: Innocent x Morality
for(x in 1:length(Conditions[,1])){
  Summary.TSb[x, 1:2]       <- Conditions[x, 1:2]
  S1c.TSb.New["Innocent.D"] <- Conditions[x, 1]
  S1c.TSb.New["Moral.D"]    <- Conditions[x, 2]
  Boot.TSb                  <- boot(S1c.TSb.New, S1c.TSb.f, R = 1000)
  Summary.TSb[x, 3]         <- Boot.TSb[[1]]
  Summary.TSb[x, 4:5]       <- quantile(Boot.TSb[[2]], c(0.025, 0.975))
}
colnames(Summary.TSb) <- c("Innocent", "Moral", "P", "lower.ci", "upper.ci")
Summary.TSb

# Surface Self Beliefs (Binary): Create Long Dataframe --------------------
S1c.SSb           <- melt(S1.Clean,
                          id.vars = c("workerId", "Innocent.D", "Guilty.D", "Innocent.C", "Defend.D", "Prosecute.D", "Defend.C"),
                          measure.vars = colnames(S1.Clean[, 58:67]),
                          variable.name = "Vignette", value.name = "SSb")
S1c.SSb$SSb       <- as.integer(S1c.SSb$SSb)
S1c.SSb$Moral.D   <- as.integer(ifelse(is.element(S1c.SSb$Vignette, colnames(S1.Clean[, 58:62])), 0, 1))
S1c.SSb$Immoral.D <- as.integer(ifelse(S1c.SSb$Moral.D == 1, 0, 1))
S1c.SSb$Moral.C   <- as.integer(ifelse(S1c.SSb$Moral.D == 1, 1, -1))

# Surface Self Beliefs (Binary): Find Best Fitting Model ------------------

  # Random intercepts only
  lm_SSb1 <- glmer(SSb ~ Innocent.D*Prosecute.D*Moral.D + (1|workerId)       + (1|Vignette), 
                   data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
  
  # Random slope for Moral
  lm_SSb2 <- glmer(SSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (1|Vignette), 
                   data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
  anova(lm_SSb1, lm_SSb2)

  # Random slope for Moral and Innocent
  lm_SSb3 <- glmer(SSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Innocent.D|Vignette), 
                   data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
  anova(lm_SSb2, lm_SSb3)

  # Random slope for Moral and Prosecute
  lm_SSb4 <- glmer(SSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Prosecute.D|Vignette), 
                   data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
  anova(lm_SSb2, lm_SSb4)

  # Random slope for Moral, Innocent and Prosecute
  lm_SSb5 <- glmer(SSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Prosecute.D+Innocent.D|Vignette), 
                   data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
  anova(lm_SSb2, lm_SSb5)

  # Random slope for Moral and Prosecute x Innocent
  lm_SSb6 <- glmer(SSb ~ Innocent.D*Prosecute.D*Moral.D + (Moral.D|workerId) + (Prosecute.D*Innocent.D|Vignette),
                   data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
  anova(lm_SSb2, lm_SSb6)

  # Drop 3-way Interaction
  lm_SSb7 <- glmer(SSb ~ Innocent.D*Moral.D + Innocent.D*Prosecute.D + Moral.D*Prosecute.D + (Moral.D|workerId) + (1|Vignette),
                   data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
  anova(lm_SSb2, lm_SSb7)


# Surface Self Beliefs (Binary): Analyses ---------------------------------

# Moral x Defend x Innocent
lm_SSb8  <- glmer(SSb ~ Moral.D*Defend.D*Innocent.D      + (Moral.D|workerId)   + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb8)),
      "OR" = exp(coef(summary(lm_SSb8))[, 1]),
      exp(confint(lm_SSb8, method = "Wald")[5:12, ]))

# Moral x Defend x Guilty
lm_SSb9  <- glmer(SSb ~ Moral.D*Defend.D*Guilty.D        + (Moral.D|workerId)   + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb9)),
      "OR" = exp(coef(summary(lm_SSb9))[, 1]),
      exp(confint(lm_SSb9, method = "Wald")[5:12, ]))

# Moral x Prosecute x Innocent
lm_SSb10 <- glmer(SSb ~ Moral.D*Prosecute.D*Innocent.D   + (Moral.D|workerId)   + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb10)),
      "OR" = exp(coef(summary(lm_SSb10))[, 1]),
      exp(confint(lm_SSb10, method = "Wald")[5:12, ]))

# Moral x Prosecute x Guilty
lm_SSb11 <- glmer(SSb ~ Moral.D*Prosecute.D*Guilty.D     + (Moral.D|workerId)   + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb11)),
      "OR" = exp(coef(summary(lm_SSb11))[, 1]),
      exp(confint(lm_SSb11, method = "Wald")[5:12, ]))

# Immoral x Defend x Innocent
lm_SSb12  <- glmer(SSb ~ Immoral.D*Defend.D*Innocent.D    + (Immoral.D|workerId) + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb12)),
      "OR" = exp(coef(summary(lm_SSb12))[, 1]),
      exp(confint(lm_SSb12, method = "Wald")[5:12, ]))

# Immoral x Defend x Guilty
lm_SSb13  <- glmer(SSb ~ Immoral.D*Defend.D*Guilty.D      + (Immoral.D|workerId) + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb13)),
      "OR" = exp(coef(summary(lm_SSb13))[, 1]),
      exp(confint(lm_SSb13, method = "Wald")[5:12, ]))

# Immoral x Prosecute x Innocent
lm_SSb14 <- glmer(SSb ~ Immoral.D*Prosecute.D*Innocent.D + (Immoral.D|workerId) + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb14)),
      "OR" = exp(coef(summary(lm_SSb14))[, 1]),
      exp(confint(lm_SSb14, method = "Wald")[5:12, ]))

# Immoral x Prosecute x Guilty
lm_SSb15 <- glmer(SSb ~ Immoral.D*Prosecute.D*Guilty.D   + (Immoral.D|workerId) + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb15)),
      "OR" = exp(coef(summary(lm_SSb15))[, 1]),
      exp(confint(lm_SSb15, method = "Wald")[5:12, ]))

# Moral x Prosecute
lm_SSb16 <- glmer(SSb ~ Moral.D*Defend.D*Innocent.C   + (Moral.D|workerId)   + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb16)),
      "OR" = exp(coef(summary(lm_SSb16))[, 1]),
      exp(confint(lm_SSb16, method = "Wald")[5:12, ]))

# Moral x Prosecute
lm_SSb17 <- glmer(SSb ~ Immoral.D*Defend.D*Innocent.C   + (Immoral.D|workerId)   + (1|Vignette),
                  data=S1c.SSb, family = "binomial", control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
cbind(coef(summary(lm_SSb17)),
      "OR" = exp(coef(summary(lm_SSb17))[, 1]),
      exp(confint(lm_SSb17, method = "Wald")[5:12, ]))
  
  
# Surface Self Beliefs (Binary): Descriptives --------------------------------

# Bootstrap Function: Role x Morality
S1c.SSb.f <- function(data, indices){
  mean(predict(lm_SSb8, data[indices, ], type = "response"))
}

# Bootstrap Inputs: Role x Morality
S1c.SSb.New  <- S1c.SSb
Conditions   <- cbind("Innocent" = c(0, 0, 0, 0, 1, 1, 1, 1),
                      "Defend"   = c(0, 0, 1, 1, 0, 0, 1, 1),
                      "Moral"    = c(0, 1, 0, 1, 0, 1, 0, 1)) 
Summary.SSb  <- matrix(nrow=length(Conditions[,1]), ncol = 6)

# Run Bootstrap: Role x Morality
for(x in 1:length(Conditions[,1])){
  Summary.SSb[x, 1:3]       <- Conditions[x, 1:3]
  S1c.SSb.New["Innocent.D"] <- Conditions[x, 1]
  S1c.SSb.New["Defend.D"]   <- Conditions[x, 2]
  S1c.SSb.New["Moral.D"]    <- Conditions[x, 3]
  Boot.SSb                  <- boot(S1c.SSb.New, S1c.SSb.f, R = 1000)
  Summary.SSb[x, 4]         <- Boot.SSb[[1]]
  Summary.SSb[x, 5:6]       <- quantile(Boot.SSb[[2]], c(0.025, 0.975))
}
colnames(Summary.SSb) <- c("Innocent", "Defend", "Moral", "P", "lower.ci", "upper.ci")
Summary.SSb
  
# True Self Beliefs (Continuous + ANOVA): Create Long Dataframe -------------------
S1c.TSc.aov <- melt(S1.Clean,
               id.vars = c("workerId", "Innocent.D", "Guilty.D", "Innocent.C", "Defend.D", "Prosecute.D", "Defend.C"),
               measure.vars = c("TSpos.C", "TSneg.C"),
               variable.name = "Vignette", value.name = "TSc")
S1c.TSc.aov$Moral.D   <- ifelse(S1c.TSc.aov$Vignette == "TSpos.C", 0, 1)
S1c.TSc.aov$Immoral.D <- ifelse(S1c.TSc.aov$Moral.D == 1, 0, 1)
S1c.TSc.aov$Moral.C   <- ifelse(S1c.TSc.aov$Moral.D == 0, 1, -1)


# True Self Beliefs (Continuous + ANOVA): Analyses --------------------------------

aov_TSc <- aov(TSc ~ Innocent.C*Defend.D*Moral.D + Error(workerId/Moral.D), data = S1c.TSc.aov)
summary(aov_TSc)
DenMSE <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[5]]
DenDf  <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Df"]][[5]]

# Moral @ Innocent
aov_TSc <- aov(TSc ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSc.aov[S1c.TSc.aov$Innocent.C == 1,])
NumMSE  <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Guilty
aov_TSc <- aov(TSc ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSc.aov[S1c.TSc.aov$Innocent.C == -1,])
NumMSE  <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Defend
aov_TSc <- aov(TSc ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSc.aov[S1c.TSc.aov$Defend.C == 1,])
NumMSE  <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Prosecute
aov_TSc <- aov(TSc ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSc.aov[S1c.TSc.aov$Defend.C == -1,])
NumMSE  <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSc)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# True Self Beliefs (Continuous + ANOVA): Descriptives --------------------------------

aov.TSc.D <- function(x){
  se <- sd(x)/sqrt(length(x))
  cbind("mean" = mean(x), "lower" = mean(x)-(1.96*se), "upper" = mean(x)+(1.96*se))
}

aggregate(TSc ~ Moral.C*Defend.C, data = S1c.TSc.aov, aov.TSc.D)
aggregate(TSc ~ Moral.C*Innocent.C, data = S1c.TSc.aov, aov.TSc.D)
# True Self Beliefs (Binary + ANOVA): Create Long Dataframe -------------------
S1c.TSb.aov <- melt(S1.Clean,
                    id.vars = c("workerId", "Innocent.D", "Guilty.D", "Innocent.C", "Defend.D", "Prosecute.D", "Defend.C"),
                    measure.vars = c("TSpos.B", "TSneg.B"),
                    variable.name = "Vignette", value.name = "TSb")
S1c.TSb.aov$Moral.D   <- ifelse(S1c.TSb.aov$Vignette == "TSpos.B", 0, 1)
S1c.TSb.aov$Immoral.D <- ifelse(S1c.TSb.aov$Moral.D == 1, 0, 1)
S1c.TSb.aov$Moral.C   <- ifelse(S1c.TSb.aov$Moral.D == 0, 1, -1)


# True Self Beliefs (Binary + ANOVA): Analyses --------------------------------

aov_TSb <- aov(TSb ~ Innocent.C*Defend.D*Moral.D + Error(workerId/Moral.D), data = S1c.TSb.aov)
summary(aov_TSb)
DenMSE <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[5]]
DenDf  <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[5]]

# Moral @ Innocent
aov_TSb <- aov(TSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSb.aov[S1c.TSb.aov$Innocent.C == 1,])
NumMSE  <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Guilty
aov_TSb <- aov(TSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSb.aov[S1c.TSb.aov$Innocent.C == -1,])
NumMSE  <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Defend
aov_TSb <- aov(TSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSb.aov[S1c.TSb.aov$Defend.C == 1,])
NumMSE  <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Prosecute
aov_TSb <- aov(TSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.TSb.aov[S1c.TSb.aov$Defend.C == -1,])
NumMSE  <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_TSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# True Self Beliefs (Binary + ANOVA): Descriptives --------------------------------

aov.TSb.D <- function(x){
  se <- sd(x)/sqrt(length(x))
  cbind("mean" = mean(x), "lower" = mean(x)-(1.96*se), "upper" = mean(x)+(1.96*se))
}

aggregate(TSb ~ Moral.C*Defend.C, data = S1c.TSb.aov, aov.TSc.D)
aggregate(TSb ~ Moral.C*Innocent.C, data = S1c.TSb.aov, aov.TSc.D)

# Surface Self Beliefs (Binary + ANOVA): Create Long Dataframe -------------------
S1c.SSb.aov <- melt(S1.Clean,
                    id.vars = c("workerId", "Innocent.D", "Guilty.D", "Innocent.C", "Defend.D", "Prosecute.D", "Defend.C"),
                    measure.vars = c("SSpos.B", "SSneg.B"),
                    variable.name = "Vignette", value.name = "SSb")
S1c.SSb.aov$Moral.D   <- ifelse(S1c.SSb.aov$Vignette == "SSpos.B", 0, 1)
S1c.SSb.aov$Immoral.D <- ifelse(S1c.SSb.aov$Moral.D == 1, 0, 1)
S1c.SSb.aov$Moral.C   <- ifelse(S1c.SSb.aov$Moral.D == 0, 1, -1)

# Surface Self Beliefs (Binary + ANOVA): Analyses --------------------------------

aov_SSb <- aov(SSb ~ Innocent.C*Defend.D*Moral.D + Error(workerId/Moral.D), data = S1c.SSb.aov)
summary(aov_SSb)
DenMSE <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[5]]
DenDf  <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[5]]

# Moral x Defend @ Innocent
aov_SSb <- aov(SSb ~ Moral.D*Defend.D + Error(workerId/Moral.D), data = S1c.SSb.aov[S1c.SSb.aov$Innocent.C == 1,])
NumMSE  <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Defend, Innocent
aov_SSb <- aov(SSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.SSb.aov[S1c.SSb.aov$Defend.C == 1 & S1c.SSb.aov$Innocent.C == 1,])
NumMSE  <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Prosecute, Innocent
aov_SSb <- aov(SSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.SSb.aov[S1c.SSb.aov$Defend.C == -1 & S1c.SSb.aov$Innocent.C == 1,])
NumMSE  <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral x Defend @ Guilty
aov_SSb <- aov(SSb ~ Moral.D*Defend.D + Error(workerId/Moral.D), data = S1c.SSb.aov[S1c.SSb.aov$Innocent.C == -1,])
NumMSE  <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Defend, Guilty
aov_SSb <- aov(SSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.SSb.aov[S1c.SSb.aov$Defend.C == 1 & S1c.SSb.aov$Innocent.C == -1,])
NumMSE  <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Moral @ Prosecute, Guilty
aov_SSb <- aov(SSb ~ Moral.D + Error(workerId/Moral.D), data = S1c.SSb.aov[S1c.SSb.aov$Defend.C == -1 & S1c.SSb.aov$Innocent.C == -1,])
NumMSE  <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Mean Sq"]][[1]]
NumDf   <- summary(aov_SSb)[["Error: workerId:Moral.D"]][[1]][["Df"]][[1]]
f       <- NumMSE/DenMSE
p       <- pf(f, NumDf, DenDf, lower.tail = FALSE)
cbind("NumDf" = NumDf, "DenDf" = DenDf, "f" = f, "p" = p)

# Surface Self Beliefs (Binary + ANOVA): Descriptives --------------------------------

aov.SSb.D <- function(x){
  se <- sd(x)/sqrt(length(x))
  cbind("mean" = mean(x), "lower" = mean(x)-(1.96*se), "upper" = mean(x)+(1.96*se))
}

aggregate(SSb ~ Moral.C*Defend.C*Innocent.C, data = S1c.SSb.aov, aov.SSb.D)
