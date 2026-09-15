options(warn=-1)
suppressMessages({library(lsr)})

d1 <- read.csv("s1_clean.csv")
d1$Cond <- factor(d1$Cond, levels=c("No effect","Large effect","SmallEffectNoPrompt","SmallEffectWithPrompt"))

cat("================ STUDY 1 ================\n")
cat("-- Descriptives --\n")
for(lv in levels(d1$Cond)){
  x <- d1$Rec[d1$Cond==lv]
  cat(sprintf("%-24s N=%d M=%.3f SD=%.3f\n", lv, length(x), mean(x), sd(x)))
}
cat("\n-- ANCOVA Rec ~ TotalScore + Condition (Type I) --\n")
m1 <- lm(Rec ~ TS + Cond, data=d1)
a1 <- anova(m1)
print(a1)
cat("partial eta-sq (lsr::etaSquared):\n")
print(etaSquared(aov(Rec ~ TS + Cond, data=d1)))

cat("\n-- Focal mean diffs via emmeans marginal means (model adj) --\n")
suppressMessages(library(emmeans))
emm <- emmeans(m1, "Cond")
p1 <- pairs(emm)
print(p1)
cat("CIs:\n"); print(confint(p1))

cat("\n-- Raw mean differences --\n")
mm <- tapply(d1$Rec, d1$Cond, mean)
cat("No effect - SmallNoPrompt = ", mm["No effect"]-mm["SmallEffectNoPrompt"], "\n")
cat("No effect - Large effect  = ", mm["No effect"]-mm["Large effect"], "\n")
cat("SmallNoPrompt - Large     = ", mm["SmallEffectNoPrompt"]-mm["Large effect"], "\n")
cat("SmallWithPrompt - SmallNoPrompt = ", mm["SmallEffectWithPrompt"]-mm["SmallEffectNoPrompt"], "\n")

cat("\n-- Interaction model Rec ~ TS*Cond --\n")
m1i <- lm(Rec ~ TS*Cond, data=d1)
print(anova(m1i))

cat("\n================ STUDY 2 ================\n")
d2 <- read.csv("s2_clean.csv")
d2$Cond <- factor(d2$Cond, levels=c("No effect","Large effect","SmallEffectNoPrompt","SmallEffectWithPrompt"))
cat("-- Descriptives --\n")
for(lv in levels(d2$Cond)){
  x <- d2$End[d2$Cond==lv]
  cat(sprintf("%-24s N=%d M=%.3f SD=%.3f\n", lv, length(x), mean(x), sd(x)))
}
cat("\n-- ANCOVA End ~ TotalScore + Condition --\n")
m2 <- lm(End ~ TS + Cond, data=d2)
print(anova(m2))
cat("partial eta-sq:\n"); print(etaSquared(aov(End ~ TS + Cond, data=d2)))

cat("\n-- Focal mean diffs (marginal means) --\n")
emm2 <- emmeans(m2, "Cond")
p2 <- pairs(emm2)
print(p2)
print(confint(p2))

cat("\n-- Raw mean differences --\n")
mm2 <- tapply(d2$End, d2$Cond, mean)
cat("No effect - SmallNoPrompt = ", mm2["No effect"]-mm2["SmallEffectNoPrompt"], "\n")
cat("No effect - Large effect  = ", mm2["No effect"]-mm2["Large effect"], "\n")
cat("SmallNoPrompt - Large     = ", mm2["SmallEffectNoPrompt"]-mm2["Large effect"], "\n")
cat("SmallWithPrompt - SmallNoPrompt = ", mm2["SmallEffectWithPrompt"]-mm2["SmallEffectNoPrompt"], "\n")

cat("\n-- Interaction model End ~ TS*Cond --\n")
m2i <- lm(End ~ TS*Cond, data=d2)
print(anova(m2i))

cat("\n-- Study 2 correlations End~TS by condition --\n")
for(lv in levels(d2$Cond)){
  ct <- cor.test(d2$End[d2$Cond==lv], d2$TS[d2$Cond==lv])
  cat(sprintf("%-24s r=%.3f p=%.3f\n", lv, ct$estimate, ct$p.value))
}
