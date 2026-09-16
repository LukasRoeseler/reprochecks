library(lme4)
library(lmerTest)

ds <- read.csv("Study 3/s3_ratings_mlm.csv")
cat("n=", nrow(ds), "\n")

cat("===== Model 1: FaceSM ~ ConceptualSM + ConceptualSM_group =====")
print(summary(lmer(FaceSM ~ ConceptualSM + ConceptualSM_group + (ConceptualSM + ConceptualSM_group | SubjID), data=ds)))

cat("===== Model 2: + ValenceSM =====")
print(summary(lmer(FaceSM ~ ConceptualSM + ConceptualSM_group + ValenceSM + (ConceptualSM + ConceptualSM_group + ValenceSM | SubjID), data=ds)))
