suppressMessages({library(lme4)})
base <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/17_Aung_voice"
d <- read.csv(file.path(base,"iPodStudyData.csv"), stringsAsFactors=FALSE)
# Within-manufactured-pitch effect: Outcome is choosing masculinized vs feminized voice?
# Pair codes: 1SD/clips 2SD. Check pitch contrast - outcome~Pair gives pitch effect
d$female_choice <- as.numeric(d$Outcome) # outcome 1
d$pair <- d$Pair
# Men's perception of male voices: question Win a Physical Fight, Respected
for(q in c("Win a Physical Fight","Respected","Interested in Attracting Men")){
  sub <- d[d$question==q,]
  m <- glmer(Outcome ~ 1 + Pair +(1|id)+(1|voice)+(1|Region/country), data=sub, family=binomial(),
             control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=1e5)))
  cat("\n=== ",q," main pitch effects ===\n")
  print(fixef(m)); print(exp(fixef(m)))
}
