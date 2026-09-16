suppressMessages({library(dplyr); library(lme4); library(lmerTest); library(MASS); library(car)})

repo <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/github/ycleong__MotivatedPerception"
AllData <- read.csv(file.path(repo, "data", "AllData.csv"), stringsAsFactors = FALSE)
AllData$Sub <- as.factor(AllData$Sub)
AllData$Pred <- as.factor(AllData$Pred)
AllData$Want2See <- as.factor(AllData$Want2See)
AllData$Con_Rev <- factor(AllData$Con, levels = c("Coop","Comp"))

cat("rows:", nrow(AllData), "subjects:", length(unique(AllData$Sub)), "\n")

out <- function(label, mod){
  cat("\n==== ", label, " ====\n")
  s <- summary(mod)
  print(s$coefficients)
}

# Main interaction model (Fig2): Choice ~ z-scored scene prop + Con * Pred, random (Con*Pred|Sub)
cat("\nFitting main GLMM (probit, Choice ~ Cat_n_z + Con*Pred + (Con*Pred|Sub)) ...\n")
res <- glmer(Choice ~ Cat_n_z + Con * Pred + (Con * Pred | Sub), AllData,
             family = binomial(link="probit"), control = glmerControl(calc.derivs = FALSE))
out("MAIN: Choice ~ Cat_n_z + Con*Pred + (Con*Pred|Sub)", res)

thisData <- subset(AllData, Con == "Coop")
res.coop <- glmer(Choice ~ Cat_n_z + Pred + (Pred | Sub), thisData, family = binomial(link="probit"))
out("COOP: Choice ~ Cat_n_z + Pred + (Pred|Sub)", res.coop)

thisData <- subset(AllData, Con == "Comp")
res.comp <- glmer(Choice ~ Cat_n_z + Pred + (Pred | Sub), thisData, family = binomial(link="probit"))
out("COMP: Choice ~ Cat_n_z + Pred + (Pred|Sub)", res.comp)

# Performance - bias correlation (Fig2C)
intSlope <- unlist(coef(res)$Sub[["ConCoop:Pred1"]])
SubBias <- data.frame(intSlope = intSlope, Sub = unique(AllData$Sub))
performData <- subset(AllData, (Cat_n != 50) & !is.na(Choice))
performData$outcome <- (performData$Choice == 1 & performData$Cat_n > 50) | (performData$Choice == 0 & performData$Cat_n < 50)
dPerform <- performData %>% group_by(Sub) %>% summarise(avg = sum(outcome) * 0.10)
dPerform <- left_join(dPerform, SubBias, by = "Sub")
cat("\n==== Performance x Motivational Bias ====\n")
ct <- cor.test(dPerform$avg, dPerform$intSlope)
print(ct)
rb_lm <- rlm(avg ~ intSlope, data = dPerform)
print(summary(rb_lm))
cat("\nROBUST F-test (sfsmisc-style) not available; reporting rlm t.\n")

cat("\nDONE\n")
