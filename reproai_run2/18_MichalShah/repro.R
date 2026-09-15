library(tidyverse)
library(haven)
library(BayesFactor)
library(lsr)
library(effsize)
library(emmeans)
library(MASS)

# Study 1 -----------------------------------------------------------------


d1 <- read_sav("D:/Meta_Rep_Games/Data Study1.sav")
d1$Condition <- as_factor(d1$Condition)
 

Means <- d1 %>% group_by(Condition) %>% summarise(
  N= n(),
  Mean = mean(Recommendation),
  SD = sd(Recommendation)
)

as.data.frame(Means)

Means[1, "Mean"]-Means[3, "Mean"]


m1 <- lm(Recommendation~Condition, data = d1)
TukeyHSD(aov(m1))
summary(aov(m1))

summary(m1)

m1 <- lm(Recommendation~TotalScore+Condition, data = d1)
summary(m1_aov <- aov(m1))
summary(m1)
etaSquared(m1_aov)

pigs.emm.s <- emmeans(m1, "Condition")
pairs(pigs.emm.s)
confint(pairs(pigs.emm.s))

m1_2 <- lm(Recommendation~TotalScore*Condition, data = d1)
summary(m1_aov_2 <- aov(m1_2))
summary(m1_2)
etaSquared(m1_aov_2)
anova( m1, m1_2)

# 1 No effect size information vs. small effect no prompt
d1_1 <- d1[d1$Condition=="No effect"|
             d1$Condition=="SmallEffectNoPrompt",]
d1_1$Condition <- droplevels(d1_1$Condition)
effsize::cohen.d(Recommendation~Condition, data = d1_1)
BayesFactor::ttestBF(x=d1_1$Recommendation[d1_1$Condition=="No effect"],
                     y=d1_1$Recommendation[d1_1$Condition=="SmallEffectNoPrompt"])

# 2 No effect size information vs. large effect
d1_1 <- d1[d1$Condition=="No effect"|
             d1$Condition=="Large effect",]
d1_1$Condition <- droplevels(d1_1$Condition)
effsize::cohen.d(Recommendation~Condition, data = d1_1)
BayesFactor::ttestBF(x=d1_1$Recommendation[d1_1$Condition=="No effect"],
                     y=d1_1$Recommendation[d1_1$Condition=="Large effect"])

# 3 Small effect no prompt vs. large effect
d1_1 <- d1[d1$Condition=="Large effect"|
             d1$Condition=="SmallEffectNoPrompt",]
d1_1$Condition <- droplevels(d1_1$Condition)
effsize::cohen.d(Recommendation~Condition, data = d1_1)
BayesFactor::ttestBF(x=d1_1$Recommendation[d1_1$Condition=="SmallEffectNoPrompt"],
                     y=d1_1$Recommendation[d1_1$Condition=="Large effect"])

# 4 Small effect with prompt vs. small effect no prompt
d1_1 <- d1[d1$Condition=="SmallEffectNoPrompt"|
             d1$Condition=="SmallEffectWithPrompt",]
d1_1$Condition <- droplevels(d1_1$Condition)
effsize::cohen.d(Recommendation~Condition, data = d1_1)
BayesFactor::ttestBF(x=d1_1$Recommendation[d1_1$Condition=="SmallEffectNoPrompt"],
                     y=d1_1$Recommendation[d1_1$Condition=="SmallEffectWithPrompt"])                


p <- ggplot(data = d1, aes(x=TotalScore, y = Recommendation, colour=Condition))+
  geom_point() + geom_smooth(method = "lm")

p

p <- ggplot(data = d1, aes(x=Condition, y=Recommendation, colour = Condition, fill = Condition))+
  geom_point(position = "jitter") + geom_boxplot(colour = "black")

p


# Study 2 -----------------------------------------------------------------


d2 <- read_sav("D:/Meta_Rep_Games/Data Study 2.sav")
d2$Condition <- as_factor(d2$Condition)


Means <- d2 %>% group_by(Condition) %>% summarise(
  N= n(),
  Mean = mean(Endorsement),
  SD = sd(Endorsement)
)

as.data.frame(Means)


m2 <- lm(Endorsement~Condition, data = d2)
TukeyHSD(aov(m2))
summary(aov(m2))

summary(m2)


m2 <- lm(Endorsement~TotalScore+Condition, data = d2)
summary(m2_aov <- aov(m2))
summary(m2)

etaSquared(m2_aov)

pigs.emm.s <- emmeans(m2, "Condition")
pairs(pigs.emm.s)
confint(pairs(pigs.emm.s))

m2_2 <- lm(Endorsement~TotalScore*Condition, data = d2)
summary(m2_aov_2 <- aov(m2_2))
summary(m2_2)


etaSquared(m2_aov_2)
anova( m2, m2_2)
# 1 No effect size information vs. small effect no prompt
d2_1 <- d2[d2$Condition=="SmallEffectNoPrompt"|
             d2$Condition=="No effect",]
d2_1$Condition <- droplevels(d2_1$Condition)
t.test(Endorsement~Condition, data = d2_1, conf.level=1-(0.05/4)/2)
effsize::cohen.d(Endorsement~Condition, data = d2_1)
BayesFactor::ttestBF(x=d2_1$Endorsement[d2_1$Condition=="SmallEffectNoPrompt"],
                     y=d2_1$Endorsement[d2_1$Condition=="No effect"])

# 2 No effect size information vs. large effect
d2_1 <- d2[d2$Condition=="Large effect"|
d2$Condition=="No effect",]
d2_1$Condition <- droplevels(d2_1$Condition)
effsize::cohen.d(Endorsement~Condition, data = d2_1)
BayesFactor::ttestBF(x=d2_1$Endorsement[d2_1$Condition=="Large effect"],
                     y=d2_1$Endorsement[d2_1$Condition=="No effect"])

# 3 Small effect no prompt vs. large effect
d2_1 <- d2[d2$Condition=="Large effect"|
             d2$Condition=="SmallEffectNoPrompt",]
d2_1$Condition <- droplevels(d2_1$Condition)
effsize::cohen.d(Endorsement~Condition, data = d2_1)
BayesFactor::ttestBF(x=d2_1$Endorsement[d2_1$Condition=="Large effect"],
                     y=d2_1$Endorsement[d2_1$Condition=="SmallEffectNoPrompt"])


# 4 Small effect with prompt vs. small effect no prompt
d2_1 <- d2[d2$Condition=="SmallEffectWithPrompt"|
             d2$Condition=="SmallEffectNoPrompt",]
d2_1$Condition <- droplevels(d2_1$Condition)
effsize::cohen.d(Endorsement~Condition, data = d2_1)
BayesFactor::ttestBF(x=d2_1$Endorsement[d2_1$Condition=="SmallEffectWithPrompt"],
                                        y=d2_1$Endorsement[d2_1$Condition=="SmallEffectNoPrompt"])

p1 <- ggplot(data = d2, aes(x=TotalScore, y = Endorsement, colour=Condition))+
  geom_point() + geom_smooth(method = "lm")

p1

p2 <- ggplot(data = d2, aes(x=Condition, y=Endorsement, colour = Condition, fill = Condition))+
  geom_point(position = "jitter") + geom_boxplot(colour = "black")

p2


# Correlation Analysis ----------------------------------------------------


cor.test(d2$Endorsement[d2$Condition=="No effect"], d2$TotalScore[d2$Condition=="No effect"])
cor.test(d2$Endorsement[d2$Condition=="SmallEffectNoPrompt"], d2$TotalScore[d2$Condition=="SmallEffectNoPrompt"])
cor.test(d2$Endorsement[d2$Condition=="SmallEffectWithPrompt"], d2$TotalScore[d2$Condition=="SmallEffectWithPrompt"])
cor.test(d2$Endorsement[d2$Condition=="Large effect"], d2$TotalScore[d2$Condition=="Large effect"])
