# Wiens (2021) MP.2019.1635 - reproduce direct analysis (2x2 ANOVA, t-tests, BF)
suppressMessages({library(readr); library(ez); library(dplyr); library(tidyr)})
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/wiens"
setwd(d)
source("BF_U_save_fig.R"); source("BF_t_save_fig.R")
dir.create(file.path(d,"figtmp"), showWarnings=FALSE)

dfraw <- read_csv2(file.path(d,"Marsh_2018_raw_means.csv"), show_col_types=FALSE)

# difference scores
speech <- function(x) x$quiet - x$neu
emotion <- function(x) x$neu - (x$neg + x$pos)/2

# Build df2 (SR-high and MI tasks)
df2 <- dfraw %>%
  mutate(speech = quiet - neu,
         emotion = neu - (neg+pos)/2,
         spvsemo = speech - emotion)

# --- t_contr equivalent ---
t_contr <- function(x, y){
  tt <- t.test(x, y, paired=FALSE, conf.level=0.95)
  c(mean(x)-mean(y), tt$conf.int[1], tt$conf.int[2], tt$p.value)
}
cat("=== t-tests (high - MI) ===\n")
for (eff in c("speech","emotion")){
  a <- df2[[eff]][df2$task=="SR-high"]; b <- df2[[eff]][df2$task=="MI"]
  r <- t_contr(a,b)
  cat(sprintf("%-8s M=%.3f  CI[%.3f, %.3f]  p=%.4f\n", eff, r[1], r[2], r[3], r[4]))
}
# speech - emotion
a <- df2$speech[df2$task=="SR-high"] - df2$emotion[df2$task=="SR-high"]
b <- df2$speech[df2$task=="MI"] - df2$emotion[df2$task=="MI"]
r <- t_contr(a,b)
cat(sprintf("%-8s M=%.3f  CI[%.3f, %.3f]  p=%.4f\n", "sp-em", r[1], r[2], r[3], r[4]))

# --- 2x2 mixed ANOVA (task between, effect within) type=3 ---
dfrawdiff <- dfraw %>%
  filter(task %in% c("SR-high","MI")) %>%
  mutate(speech = quiet - neu, emotion = neu - (neg+pos)/2) %>%
  select(-c("quiet","neu","pos","neg")) %>%
  pivot_longer(names_to="effect", values_to="recall", cols=c(speech,emotion)) %>%
  mutate(task=factor(task, levels=c("SR-high","MI")),
         effect=factor(effect, levels=c("speech","emotion")),
         subject=factor(subject))
av <- ezANOVA(dv=recall, wid=subject, within=effect, between=task, type=3, data=dfrawdiff)
cat("\n=== 2x2 ANOVA (type 3) ===\n")
print(av$ANOVA)

# --- BF analysis ---
tmp1 <- df2$speech[df2$task=="SR-high"]; tmp2 <- df2$speech[df2$task=="MI"]
speechdiff <- round(mean(tmp1)-mean(tmp2),4)
speecht <- t.test(tmp1,tmp2, mu=0, paired=FALSE, var.equal=TRUE)
speechsem <- abs(speechdiff)/abs(speecht$statistic)
speechdf <- speecht$parameter
tmp1 <- df2$emotion[df2$task=="SR-high"]; tmp2 <- df2$emotion[df2$task=="MI"]
emodiff <- round(mean(tmp1)-mean(tmp2),4)
emot <- t.test(tmp1,tmp2, mu=0, paired=FALSE, var.equal=TRUE)
emosem <- abs(emodiff)/abs(emot$statistic)
emodf <- emot$parameter
cat(sprintf("\nspeechdiff=%.3f emodiff=%.3f emosem=%.4f emodf=%.0f\n", speechdiff, emodiff, emosem, emodf))

BF10_U <- BF_U(LL=0, UL=speechdiff, meanobtained=emodiff, semobtained=emosem,
               dfobtained=emodf, filename="bfu", figpath=file.path(d,"figtmp"))
BF10_H <- BF_t(meantheory=0, sdtheory=speechdiff, dftheory=10000, meanobtained=emodiff,
               semobtained=emosem, dfobtained=emodf, tail=1, filename="bfh", figpath=file.path(d,"figtmp"))
BF10_t <- BF_t(meantheory=speechdiff, sdtheory=speechsem, dftheory=speechdf, meanobtained=emodiff,
               semobtained=emosem, dfobtained=emodf, tail=2, filename="bft", figpath=file.path(d,"figtmp"))
cat(sprintf("BF01 uniform=%.2f  half-normal=%.2f  t-dist=%.2f\n", 1/BF10_U, 1/BF10_H, 1/BF10_t))
