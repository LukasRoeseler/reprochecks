suppressMessages({library(lme4)})
base <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/17_Aung_voice"
d <- read.csv(file.path(base,"iPodStudyData.csv"), stringsAsFactors=FALSE)
cty <- read.csv(file.path(base,"countrydata.csv"), stringsAsFactors=FALSE)
cd <- cty
for(v in c("RelationalMobility","AvgMalePitch","AvgFemalePitch")){ cd[[v]] <- as.numeric(scale(cd[[v]])) }
cd[is.na(cd)] <- 0
nd <- merge(d, cd[,c("country","RelationalMobility","AvgMalePitch","AvgFemalePitch")], by="country", all.x=TRUE, sort=FALSE)

# Header table: human FLoRA frequentist b [95% CI] from RG report Table 2
human <- data.frame(
  label=c("Formidability x RM","Prestige x RM","Flirtatiousness x RM","Attractive to men x RM"),
  human_est=c(0.394,0.321,0.470,0.121),
  human_lo=c(0.072,0.097,0.269,0.003),
  human_hi=c(0.715,0.545,0.671,0.239))

qmap <- list("Formidability x RM"="Win a Physical Fight",
             "Prestige x RM"="Respected",
             "Flirtatiousness x RM"="Interested in Attracting Men",
             "Attractive to men x RM"="Attractive to Men")
pitchvar <- list("Formidability x RM"="AvgMalePitch","Prestige x RM"="AvgMalePitch",
                 "Flirtatiousness x RM"="AvgFemalePitch","Attractive to men x RM"="AvgFemalePitch")

cat("LABEL | MINE_est(OR) [95%CI] | HUMAN_est [95%CI]\n")
for(i in 1:nrow(human)){
  q <- qmap[[human$label[i]]]; pv <- pitchvar[[human$label[i]]]
  sub <- nd[nd$question==q,]
  f <- as.formula(paste("Outcome ~ 1 + RelationalMobility +",pv,"+ (1|id)+(1|voice)+(1|Region/country)"))
  m <- glmer(f, data=sub, family=binomial(), control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=1e5)))
  b <- fixef(m)["RelationalMobility"]; se=sqrt(diag(vcov(m)))["RelationalMobility"]
  cat(sprintf("%-28s OR=%.3f est=%.3f [%.3f, %.3f] | hu=%.3f [%.3f, %.3f]\n",
      human$label[i], exp(b), b, b-1.96*se, b+1.96*se, human$human_est[i], human$human_lo[i], human$human_hi[i]))
}
