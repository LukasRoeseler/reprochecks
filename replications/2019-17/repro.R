suppressMessages({library(lme4); library(lmerTest)})
setwd("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/work/2019-17/Data")

sec <- function(t){cat("\n\n########################## ", t, " ##########################\n")}

############################################
# STUDY 1 - DOCTOR CONDITIONING
############################################
sec("STUDY1 CONDITIONING PAIN (expect b=-22.63, t=-7.78)")
d <- read.csv("study1_doc_condition_rating_data.csv")
d$trials_c <- d$Trials - mean(d$Trials)
d$Site <- factor(d$Site); d$Color <- factor(d$Current_color); d$Condition <- factor(d$Condition_new)
m <- lmer(Pain_Rating ~ Site + trials_c + Color + Condition + (1 + trials_c + Condition | DyadID), data=d)
print(summary(m)$coefficients)

sec("STUDY1 CONDITIONING BELIEF (expect b=24.60, t=4.84)")
q <- read.csv("study1_doc_condition_belief_data.csv")
q$Time <- factor(q$Time)
m <- lmer(Effectiveness ~ Time + (1 | DyadID), data=q)
print(summary(m)$coefficients)

sec("STUDY1 DOCTOR INTERACTION BELIEF (expect b=61.92, t=11.05)")
qi <- read.csv("study1_doc_interaction_belief_data.csv")
qi$Time <- factor(qi$Time); qi$Condition <- factor(qi$Condition_new)
m <- lmer(effectiveness ~ Time*Condition + (1 + Time + Condition | DyadID), data=qi)
print(summary(m)$coefficients)

############################################
# STUDY 1 - INTERACTION
############################################
sec("STUDY1 INTERACTION PATIENT PAIN (expect b=-7.30, t=-4.78)")
p <- read.csv("study1_pat_interaction_overall_pain_data.csv")
p$trials_c <- p$N - mean(p$N)
p$Site <- factor(p$Site); p$Condition <- factor(p$Condition_new); p$Color <- factor(p$Current_Color)
m <- lmer(Pain_Rating ~ Site + trials_c + Color + Condition + (1 + trials_c + Condition | DyadID), data=p)
print(summary(m)$coefficients)

sec("STUDY1 INTERACTION PATIENT MAX PAIN (expect b=-11.52, t=-5.63)")
c <- read.csv("study1_pat_interaction_maxcont_pain_data.csv")
c$Condition <- factor(c$Condition); c$Color <- factor(c$Current_Color); c$Site <- factor(c$Site)
m <- lmer(max_pain ~ Site + Color + trials_c + Condition + (1 + trials_c + Condition | DyadID), data=c)
print(summary(m)$coefficients)

sec("STUDY1 INTERACTION PATIENT BELIEF (expect F(1,23)=5.63, p=.03)")
pq <- read.csv("study1_pat_interaction_belief_data.csv")
pq$Time <- factor(pq$Time); pq$Condition <- factor(pq$Condition_new)
m <- lmer(effectiveness ~ Time*Condition + (1 + Time + Condition | DyadID), data=pq)
print(anova(m))

sec("STUDY1 INTERACTION EMPATHY (expect b=9.61, t=2.86)")
pq$Time <- factor(pq$Time); pq$Condition <- factor(pq$Condition_new)
m <- lmer(doc_empathy ~ Time*Condition + (1 + Time + Condition | DyadID), data=pq)
print(summary(m)$coefficients)

sec("STUDY1 INTERACTION SCR AUC (expect b=-1.67, t(20.14)=-3.20, p=.004)")
s <- read.csv("study1_pat_interaction_scr_auc_data.csv")
s$Site <- factor(s$Site); s$Color <- factor(s$Color); s$Condition <- factor(s$Condition_new)
m <- lmer(auc ~ Site + trials_c + Color + Condition + (1 + trials_c + Condition | DyadID), data=s)
print(summary(m)$coefficients)

sec("STUDY1 PATIENT FACIAL (expect b=-0.14, t(17.02)=-2.86, p=.01)")
f <- read.csv("study1_pat_interaction_facial_data.csv")
f$trials_c <- f$N - mean(f$N)
f$Site <- factor(f$Site); f$Condition <- factor(f$Condition_new); f$Color <- factor(f$Current_Color)
m <- lmer(pred_PainRating ~ Site + trials_c + Condition + Color + (1 + trials_c + Condition |DyadID), data=f,
          control=lmerControl(optimizer="Nelder_Mead",optCtrl=list(maxfun=40000)))
print(summary(m)$coefficients)

sec("STUDY1 DOCTOR FACIAL (expect b=-0.10, t(17.78)=-2.43, p=.03)")
fd <- read.csv("study1_doc_interaction_facial_data.csv")
fd$trials_c <- fd$N - mean(fd$N)
fd$Site <- factor(fd$Site); fd$Condition <- factor(fd$Condition_new); fd$Color <- factor(fd$Current_Color)
m <- lmer(pred_PainRating ~ Site + trials_c + Condition + Color + (1 + Condition + trials_c |DyadID), data=fd,
          control=lmerControl(optimizer="Nelder_Mead",optCtrl=list(maxfun=40000)))
print(summary(m)$coefficients)

############################################
# STUDY 2 - CONDITIONING
############################################
sec("STUDY2 CONDITIONING PAIN (expect b=-22.93, t=-10.07)")
d <- read.csv("study2_doc_condition_rating_data.csv")
d$trials_c <- d$Trials - mean(d$Trials)
d$Site <- factor(d$Site); d$Condition <- factor(d$Condition_new)
m <- lmer(Pain_Rating ~ Site + trials_c + Condition + (1 + trials_c + Condition | DyadID), data=d)
print(summary(m)$coefficients)

sec("STUDY2 CONDITIONING BELIEF (expect b=16.49, t=3.35)")
q <- read.csv("study2_doc_condition_belief_data.csv")
q$Time <- factor(q$Time)
m <- lmer(Effectiveness ~ Time + (1 | DyadID), data=q)
print(summary(m)$coefficients)

############################################
# STUDY 2 - INTERACTION
############################################
sec("STUDY2 INTERACTION PATIENT PAIN (expect Cond x Order F(1,38.10)=12.34, p=.001)")
p <- read.csv("study2_pat_interaction_rating_data.csv")
p$trials_c <- p$Trials - mean(p$Trials)
p$Site <- factor(p$Site); p$Temperature <- factor(p$Temperature); p$Counterbalance <- factor(p$Counterbalance)
p$Condition <- factor(p$Condition_new); p$Experimenter <- factor(p$Experimenter); p$CurrentColor <- factor(p$Current_Color)
m <- lmer(Pain_Rating ~ Site + CurrentColor + trials_c + Experimenter*Condition + Temperature*Condition + Counterbalance*Condition + (1 + trials_c + Condition | DyadID), data=p)
print(anova(m))

sec("STUDY2 INTERACTION PATIENT BELIEF (expect Time x Cond x Order F(1,81.58)=9.99, p=.002)")
pq <- read.csv("study2_pat_interaction_belief_data.csv")
pq$Time <- factor(pq$Time_new); pq$Counterbalance <- factor(pq$Counterbalance); pq$Condition <- factor(pq$Condition_new)
pq$Temperature <- factor(pq$Temperature); pq$Experimenter <- factor(pq$Experimenter)
m <- lmer(effectiveness ~ Experimenter + Temperature + Time*Condition*Counterbalance + (1 + Time + Condition | DyadID), data=pq)
print(anova(m))

sec("STUDY2 DOCTOR INTERACTION BELIEF (Time x Cond x Order)")
dq <- read.csv("study2_doc_interaction_belief_data.csv")
dq$Temperature <- factor(dq$Temperature); dq$Experimenter <- factor(dq$Experimenter); dq$Time <- factor(dq$Time)
dq$Counterbalance <- factor(dq$Counterbalance); dq$Condition <- factor(dq$Condition_new)
m <- lmer(effectiveness ~ Temperature + Experimenter + Time*Condition*Counterbalance + (1 + Time + Condition | DyadID), data=dq)
print(anova(m))

sec("STUDY2 INTERACTION SCR AUC (expect Cond x Order F(1,398.55)=11.00, p<.001)")
s <- read.csv("study2_pat_interaction_scr_auc_data.csv")
sm <- aggregate(auc ~ DyadID+Trials+Condition+Counterbalance+Current_Color+Experimenter+Condition_new+Temperature+Site, data=s, mean)
sm$trials_c <- sm$Trials - mean(sm$Trials)
sm$Site <- factor(sm$Site); sm$Color <- factor(sm$Current_Color); sm$Counterbalance <- factor(sm$Counterbalance)
sm$Condition <- factor(sm$Condition_new); sm$Temperature <- factor(sm$Temperature); sm$Experimenter <- factor(sm$Experimenter)
m <- lmer(auc ~ Temperature + Experimenter + Counterbalance*Condition + Site + trials_c + Color + (1 + trials_c + Condition | DyadID), data=sm)
print(anova(m))

############################################
# STUDY 3 - CONDITIONING
############################################
sec("STUDY3 CONDITIONING PAIN (expect b=-31.92, t=-11.02)")
d <- read.csv("study3_doc_condition_rating_data.csv")
d$trials_c <- d$Trials - mean(d$Trials)
d$Site <- factor(d$Site); d$Color <- factor(d$Current_color); d$Condition <- factor(d$Condition_new)
m <- lmer(Pain_Rating ~ Site + trials_c + Color + Condition + (1 + trials_c + Condition| DyadID), data=d)
print(summary(m)$coefficients)

sec("STUDY3 CONDITIONING BELIEF (expect b=25.89, t(29)=6.55)")
q <- read.csv("study3_doc_condition_belief_data.csv")
q$Time <- factor(q$Time)
m <- lmer(Effectiveness ~ Time + (1 | DyadID), data=q)
print(summary(m)$coefficients)

sec("STUDY3 DOCTOR INTERACTION BELIEF (expect b=62.57, t(37.18)=18.57)")
qi <- read.csv("study3_doc_interaction_belief_data.csv")
qi$Time <- factor(qi$Time); qi$Condition <- factor(qi$Condition)
m <- lmer(effectiveness ~ Time*Condition + (1 + Time + Condition | DyadID), data=qi)
print(summary(m)$coefficients)

############################################
# STUDY 3 - INTERACTION
############################################
sec("STUDY3 INTERACTION PATIENT PAIN (expect b=-3.70, t(27.30)=-2.42, p=.02)")
p <- read.csv("study3_pat_interaction_rating_data.csv")
p$trials_c <- p$N - mean(p$N)
p$Site <- factor(p$Site); p$Condition <- factor(p$Condition_new); p$Color <- factor(p$Current_Color)
m <- lmer(Pain_Rating ~ Site + trials_c + Color + Condition + (1 + trials_c + Condition | DyadID), data=p)
print(summary(m)$coefficients)

sec("STUDY3 INTERACTION PATIENT BELIEF (expect Time x Cond F(1,178)=4.98, p=.03)")
pq <- read.csv("study3_pat_interaction_belief_data.csv")
pq$Time <- factor(pq$Time); pq$Condition <- factor(pq$Condition)
m <- lmer(effectiveness ~ Time*Condition + (1 + Condition | DyadID), data=pq)
print(anova(m))

sec("STUDY3 INTERACTION EMPATHY (expect b=6.88, t(96.03)=2.38, p=.02)")
pq$Time <- factor(pq$Time); pq$Condition <- factor(pq$Condition)
m <- lmer(doc_empathy ~ Time*Condition + (1 + Condition | DyadID), data=pq)
print(summary(m)$coefficients)

sec("STUDY3 INTERACTION SCR AUC (expect b=-1.37, t(285.60)=-2.04, p=.04)")
s <- read.csv("study3_pat_interaction_scr_auc_data.csv")
s$Site <- factor(s$Site); s$Color <- factor(s$Current_Color); s$Condition <- factor(s$Condition_new)
m <- lmer(auc ~ Site + Color + Drift + trials_c + Condition + (1 + Drift + trials_c + Condition | DyadID), data=s)
print(summary(m)$coefficients)

sec("DONE")
