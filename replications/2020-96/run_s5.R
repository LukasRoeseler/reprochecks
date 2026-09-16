library(lme4)
library(lmerTest)

d <- read.csv("Study 5/s5_mlm_ds.csv")
cat("n=", nrow(d), "\n")

neg2pos_vals <- sort(unique(d$neg2pos))
cat("neg2pos unique:", neg2pos_vals, "\n")
d$neg2posDUM <- ifelse(d$neg2pos==neg2pos_vals[1], 0, 1)
d$pos2negDUM <- ifelse(d$neg2pos==neg2pos_vals[2], 1, 0)

rating_subjective.agg <- aggregate(rating_subjective ~ SubjID, FUN=mean, na.rm=TRUE, data=d)
x.fm <- rating_subjective.agg$rating_subjective[match(d$SubjID, rating_subjective.agg$SubjID)]
d$crating_subjective <- d$rating_subjective - x.fm

m1 <- lmer(rating_consensual ~ crating_subjective*neg2pos + (1 | SubjID), data=d)
print(summary(m1))

cat("\n--- simple effects ---\n")
m1a <- lmer(rating_consensual ~ crating_subjective*neg2posDUM + (1 | SubjID), data=d)
print(summary(m1a)$coefficients)
m1b <- lmer(rating_consensual ~ crating_subjective*pos2negDUM + (1 | SubjID), data=d)
print(summary(m1b)$coefficients)
