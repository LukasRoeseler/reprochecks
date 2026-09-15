suppressMessages({library(lme4); library(dplyr)})

base <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/17_Aung_voice"
d <- read.csv(file.path(base,"iPodStudyData.csv"), stringsAsFactors=FALSE)
cty <- read.csv(file.path(base,"countrydata.csv"), stringsAsFactors=FALSE)

# Reproduce country.data construction from PsychSci.R (z-scoring + factor scores omitted - only need RM and pitch)
# Replicate d1 z-score approach for RelationalMobility and AvgMalePitch/AvgFemalePitch
cd <- cty
for(v in c("RelationalMobility","AvgMalePitch","AvgFemalePitch")){
  cd[[v]] <- as.numeric(scale(cd[[v]]))
}
cd[is.na(cd)] <- 0
# build newdata2 equivalent: join by country
nd <- merge(d, cd[, c("country","RelationalMobility","AvgMalePitch","AvgFemalePitch")], by="country", all.x=TRUE, sort=FALSE)
cat("rows", nrow(nd), "\n")

fit_one <- function(question, pitchvar){
  sub <- nd[nd$question==question, ]
  f <- as.formula(paste("Outcome ~ 1 + RelationalMobility +", pitchvar, "+ (1|id) + (1|voice) + (1|Region/country)"))
  m <- glmer(f, data=sub, family=binomial(link="logit"),
             control=glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=1e5)))
  fe <- fixef(m)
  se <- sqrt(diag(vcov(m)))
  # Rename coefficients to human-readable
  out <- data.frame(coef=names(fe), est=fe, se=se, OR=exp(fe))
  rownames(out) <- NULL
  cat("\n=====", question, "|", pitchvar, " N=", nrow(sub),"=====\n")
  print(out)
  cat("--- profile-confidence 95% ---\n")
  print(confint(m, parm="beta_", method="Wald"))
}

fit_one("Win a Physical Fight", "AvgMalePitch")      # M19 Formidability
fit_one("Respected", "AvgMalePitch")                  # M20 Prestige
fit_one("Interested in Attracting Men", "AvgFemalePitch") # M23 Flirtatiousness
fit_one("Attractive to Men", "AvgFemalePitch")        # M24 Attractive
