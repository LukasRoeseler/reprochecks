suppressMessages({library(dplyr); library(lme4)})

repo <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/github/ycleong__MotivatedPerception"
AllData <- read.csv(file.path(repo,"data","AllData.csv"), stringsAsFactors = FALSE)
AllData$Sub <- as.factor(AllData$Sub)
AllData$Pred <- as.factor(AllData$Pred)
AllData$Want2See <- as.factor(AllData$Want2See)
AllData$Con_Rev <- factor(AllData$Con, levels=c("Coop","Comp"))
AllData_Valid <- filter(AllData, !is.na(Choice))

res <- glmer(Choice ~ Cat_n_z + Con * Pred + (Con * Pred | Sub), AllData,
             family=binomial(link="probit"), control=glmerControl(calc.derivs=FALSE))
intSlope <- unlist(coef(res)$Sub[["ConCoop:Pred1"]])

roi <- read.csv(file.path(repo,"data","roi_zstat.csv"))
roi$Sub <- as.factor(roi$Sub)
Parms <- read.csv(file.path(repo,"data","model_outputs","subject_parms","simpleFull_subjparms.csv"))
Parms$Sub <- as.factor(Parms$Sub)

cat("parms cols:", paste(names(Parms), collapse=", "), "\n")
cat("roi cols:", paste(names(roi), collapse=", "), "\n")

SubBias <- data.frame(Sub=factor(unique(AllData$Sub)), intSlope=intSlope)
df <- left_join(Parms, SubBias, by="Sub") %>% left_join(select(roi, Sub, accumbens), by="Sub")

# Neural bias per subject (lm of Prob ~ Cat_n + Con*Pred)
NeuralBias <- sapply(levels(factor(AllData$Sub)), function(s){
  d <- subset(AllData_Valid, Sub==s)
  coef(lm(Prob ~ Cat_n + Con * Pred, data=d))["ConCoop:Pred1"]
})
df$NeuralBias <- as.numeric(NeuralBias)

cat("\n==== NAcc ~ scale(z) + scale(drift_bias) [Fig6] ====\n")
m <- lm(scale(accumbens) ~ scale(z) + scale(drift_bias), df)
print(summary(m))

cat("\n==== NAcc ~ scale(z) + scale(NeuralBias) (alternate) ====\n")
m2 <- lm(scale(accumbens) ~ scale(z) + scale(NeuralBias), df)
print(summary(m2))

cat("\n==== NAcc ~ NeuralBias only ====\n")
print(summary(lm(scale(accumbens) ~ scale(NeuralBias), df)))

cat("\nDONE\n")
