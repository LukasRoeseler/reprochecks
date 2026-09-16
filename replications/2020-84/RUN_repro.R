options(warn=1)
suppressMessages({library(psych); library(reshape2); library(lme4)})

source("Functions.R")

cat("=== STAGE 1: Direct replication coding ===\n")
source("Direct_Replication_coding.R")
cat("dataset_wide n =", nrow(dataset_wide), "\n")

cat("\n=== STAGE 2: US conceptual coding ===\n")
source("US_conceptual_coding.R")
cat("Temple_study n =", nrow(Temple_study), "\n")

cat("\n=== STAGE 3: NL conceptual coding ===\n")
source("NL_conceptual_coding.R")
cat("dataset n =", nrow(dataset), "\n")

cat("\n\n########## HEADLINE STATS ##########\n")

### Figure 1a correlations (direct replication) ---------------------
direct_a <- data.frame(dataset_wide$Dlogeda_threat_spider_0_12, dataset_wide$DlogedaHibbing_threat_wounded_0_12, dataset_wide$DlogedaHibbing_disgust_maggots_0_12)
names(direct_a) <- c("Spider","Wounded","Maggots")
cat("\n--- Fig1a direct repl correlation matrix (N: ", sum(complete.cases(direct_a)), ") ---\n")
print(round(cor(direct_a, use="complete.obs"), 3))
cat("alpha(direct): "); print(alpha(direct_a)$total$raw_alpha)

### Figure 1b threat extensions ---------------------
pre_reg_threat <- data.frame(dataset_wide$Dlogeda_threat_spider_0_12, dataset_wide$DlogedaHibbing_threat_wounded_0_12, dataset_wide$DlogedaHibbing_threat_gun_0_12, dataset_wide$DlogedaHibbing_threat_dog_0_12, dataset_wide$Dlogeda_threat_crowd_0_12, dataset_wide$DlogedaHibbing_threat_twintowers_0_12)
names(pre_reg_threat) <- c("Spider","Wounded","Gun","Dog","Crowd","9-11")
cat("\n--- Fig1b threat extensions corr matrix ---\n")
print(round(cor(pre_reg_threat, use="complete.obs"), 3))
cat("alpha(pre_reg_threat): "); print(alpha(pre_reg_threat)$total$raw_alpha)

### Figure 1c disgust extensions ---------------------
pre_reg_disgust <- data.frame(dataset_wide$DlogedaHibbing_disgust_maggots_0_12, dataset_wide$DlogedaHibbing_disgust_toilet_0_12, dataset_wide$DlogedaHibbing_disgust_wound_0_12, dataset_wide$DlogedaHibbing_disgust_deaddog_0_12, dataset_wide$DlogedaHibbing_disgust_Vomit_0_12, dataset_wide$DlogedaHibbing_disgust_worms_0_12)
names(pre_reg_disgust) <- c("Maggots","Toilet","Wound","Deaddog","Vomit","Worms")
cat("\n--- Fig1c disgust extensions corr matrix ---\n")
print(round(cor(pre_reg_disgust, use="complete.obs"), 3))
cat("alpha(pre_reg_disgust): "); print(alpha(pre_reg_disgust)$total$raw_alpha)

### Figure 1d US conceptual ---------------------
US_concept <- data.frame(Temple_study$Dlogeda_Snake, Temple_study$Dlogeda_Dog, Temple_study$Dlogeda_911)
names(US_concept) <- c("Snake","Dog","911")
cat("\n--- Fig1d US conceptual corr matrix (N: ", sum(complete.cases(US_concept)), ") ---\n")
print(round(cor(US_concept, use="complete.obs"), 3))
cat("alpha(US_concept): "); print(alpha(US_concept)$total$raw_alpha)

### Figure 1e NL conceptual ---------------------
NL_concept <- data.frame(dataset$snake_change, dataset$dog_change, dataset$herdingdog_change, dataset$gun_change)
names(NL_concept) <- c("Snake","Dog","Herdingdog","Gun")
cat("\n--- Fig1e NL conceptual corr matrix (N: ", sum(complete.cases(NL_concept)), ") ---\n")
print(round(cor(NL_concept, use="complete.obs"), 3))
cat("alpha(NL_concept): "); print(alpha(NL_concept)$total$raw_alpha)

cat("\n\n### FIGURE 2 REGRESSIONS ###\n")

### Direct replication (Figure 2 row 1): Oxley index on social & econ conservatism ---
cat("\n--- Direct replication: zero1(oxley_social) ~ scale(Oxley08_threat) + controls ---\n")
m <- lm(zero1(oxley_social) ~ scale(Oxley08_threat) + age + Gender + Income + Education + first_eight + study_event + payment + threat_eda_below2, data=dataset_wide)
print(coef(summary(m))["scale(Oxley08_threat)",])
cat("N =", summary(m)$df[1]+summary(m)$df[2], "\n")
cat("\n--- Direct replication: zero1(oxley_econ) ~ scale(Oxley08_threat) + controls ---\n")
m2 <- lm(zero1(oxley_econ) ~ scale(Oxley08_threat) + age + Gender + Income + Education + first_eight + study_event + payment + threat_eda_below2, data=dataset_wide)
print(coef(summary(m2))["scale(Oxley08_threat)",])

### Extension threat index (Figure 2 row 2, Index) ---
cat("\n--- Extension Threat: zero1(social) ~ scale(threatsensitivity_scl) + controls ---\n")
m3 <- lm(zero1(social) ~ scale(threatsensitivity_scl) + age + Gender + Black + Latino + Asian + Other + Income + Education + first_eight + study_event + payment + threat_eda_below2, data=dataset_wide)
print(coef(summary(m3))["scale(threatsensitivity_scl)",])
cat("N =", summary(m3)$df[1]+summary(m3)$df[2], "\n")

### Extension disgust index (Figure 2 row 3, Index) ---
cat("\n--- Extension Disgust: zero1(social) ~ scale(disgustsensitivity_scl) + controls ---\n")
m4 <- lm(zero1(social) ~ scale(disgustsensitivity_scl) + age + Gender + Black + Latino + Asian + Other + Income + Education + first_eight + study_event + payment + disgust_eda_below2, data=dataset_wide)
print(coef(summary(m4))["scale(disgustsensitivity_scl)",])

### US conceptual (Figure 2 row 4, Index) ---
cat("\n--- US conceptual: zero1(social) ~ scale(Threatsensitivity) + controls ---\n")
m5 <- lm(zero1(social) ~ scale(Threatsensitivity) + as.factor(female) + income + as.factor(education) + as.factor(race) + tempworker + as.factor(study), data=Temple_study)
print(coef(summary(m5))["scale(Threatsensitivity)",])
cat("N =", summary(m5)$df[1]+summary(m5)$df[2], "\n")

### NL conceptual (Figure 2 row 5, Index) ---
cat("\n--- NL conceptual: zero1(socialconservatism) ~ scale(threat_scl) + controls ---\n")
m6 <- lm(zero1(socialconservatism) ~ scale(threat_scl) + as.factor(female) + age_1 + as.factor(edu_recoded), data=dataset)
print(coef(summary(m6))["scale(threat_scl)",])
cat("N =", summary(m6)$df[1]+summary(m6)$df[2], "\n")

### Pooled analyses (Figure 2 row 6) ---
cat("\n=== Pooled analyses ===\n")
data_NL <- dataset[c("socialconservatism","econ_conservative","female","age_1","edu_recoded","threat_scl")]
data_NL$econ_conservative <- zero1(data_NL$econ_conservative)
data_NL$study <- 4; data_NL$tempworker <- 0; data_NL$income <- 11
data_NL$income_missing <- 1; data_NL$age_missing <- 0
names(data_NL)[names(data_NL)=="age_1"]<-"age"
names(data_NL)[names(data_NL)=="econ_conservative"]<-"econ"
names(data_NL)[names(data_NL)=="socialconservatism"]<-"social"
names(data_NL)[names(data_NL)=="threat_scl"]<-"Threatsensitivity"
names(data_NL)[names(data_NL)=="edu_recoded"]<-"education"
data_NL$education <- car::recode(data_NL$education, "1=3; 2=2; 3=4")

data_Temple <- Temple_study[c("Threatsensitivity","social","econ","study","female","education","income","tempworker")]
data_Temple$age_missing <- 1; data_Temple$age <- 17; data_Temple$income_missing <- 0
data_Temple$social <- zero1(data_Temple$social)
data_Temple$social <- zero1(data_Temple$econ)

data_Temple_prereg <- dataset_wide[c("threatsensitivity_scl","social","econ","age","Gender","Income","Education","payment")]
data_Temple_prereg$study <- 5; data_Temple_prereg$age_missing <- 0; data_Temple_prereg$income_missing <- 0
data_Temple_prereg$payment <- ifelse(data_Temple_prereg$payment==1,0,1)
names(data_Temple_prereg)[names(data_Temple_prereg)=="payment"]<-"tempworker"
names(data_Temple_prereg)[names(data_Temple_prereg)=="threatsensitivity_scl"]<-"Threatsensitivity"
names(data_Temple_prereg)[names(data_Temple_prereg)=="Gender"]<-"female"
names(data_Temple_prereg)[names(data_Temple_prereg)=="Income"]<-"income"
names(data_Temple_prereg)[names(data_Temple_prereg)=="Education"]<-"education"
data_Temple_prereg$education <- as.numeric(data_Temple_prereg$education)
data_Temple_prereg$female <- (as.numeric(data_Temple_prereg$female)-1)
data_Temple_prereg$social <- zero1(data_Temple_prereg$social)
data_Temple_prereg$econ <- zero1(data_Temple_prereg$econ)

data_pooled <- rbind(data_NL, data_Temple, data_Temple_prereg)
cat("Pooled N =", nrow(data_pooled), "\n")

cat("\n--- Pooled: zero1(social) ~ scale(Threatsensitivity) + random intercept study ---\n")
mp1 <- lmer(zero1(social) ~ scale(Threatsensitivity) + age + as.factor(female) + as.factor(education) + tempworker + income + as.factor(study) + (1|study), data=data_pooled)
print(coef(summary(mp1))["scale(Threatsensitivity)",])
cat("\n--- Pooled: zero1(econ) ~ scale(Threatsensitivity) + random intercept study ---\n")
mp2 <- lmer(zero1(econ) ~ scale(Threatsensitivity) + age + as.factor(female) + as.factor(education) + tempworker + income + as.factor(study) + (1|study), data=data_pooled)
print(coef(summary(mp2))["scale(Threatsensitivity)",])

cat("\n\nDONE\n")
