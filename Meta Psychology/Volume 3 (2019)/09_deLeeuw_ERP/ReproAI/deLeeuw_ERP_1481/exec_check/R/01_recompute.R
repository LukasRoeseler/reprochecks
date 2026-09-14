suppressMessages({
  library(readr)
  library(dplyr)
  library(BayesFactor)
  library(ez)
})

setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check")

technical.problems <- c(8, 21)
too.few.segments <- c(11, 23, 25, 40)
excluded.subjects <- c(technical.problems, too.few.segments)

cat("==== Recompute de Leeuw et al. 2019 ====\n")

# ---- Demographics on analytic sample ----
dem <- read_csv('data/raw/demographic_data.csv', show_col_types=FALSE) %>%
  filter(!Subject %in% excluded.subjects)
dem.sum <- dem %>% summarize(mean.age=mean(Age), sd.age=sd(Age), min=min(Age), max=max(Age),
                             mean.years=mean(YearsMusicalExperience), sd.years=sd(YearsMusicalExperience),
                             mean.hpw=mean(HoursPerWeek), sd.hpw=sd(HoursPerWeek))
print("DEMOGRAPHIC SUMMARY"); print(round(dem.sum, 4)); cat("N =", nrow(dem), "\n")

# ---- Behavioral accuracy ----
beh <- read_csv('data/generated/beh_data_tidy.csv', show_col_types=FALSE) %>%
  filter(!subject_id %in% excluded.subjects) %>%
  filter(!syntax_cat %in% c('Filler-Gram','Filler-Ungram'))
summary.beh <- beh %>% group_by(syntax_cat, subject_id) %>%
  summarize(accuracy = mean(correct)*100, .groups='drop') %>%
  group_by(syntax_cat) %>% summarize(mean=mean(accuracy), sd=sd(accuracy))
print("BEHAVIORAL SUMMARY (Table 1)"); print(summary.beh, digits=6)

# ---- EEG data ----
eeg.data <- read_csv('data/generated/eeg_data_tidy.csv', show_col_types=FALSE,
    col_types = cols(electrode=col_factor(levels=NULL), subject=col_factor(levels=NULL),
                     stimulus.condition=col_factor(levels=NULL), grammar.condition=col_factor(levels=NULL))) %>%
  filter(!subject %in% excluded.subjects)
cat("EEG rows:", nrow(eeg.data), "\n")

lateral.electrodes <- c(33,39,42,45,70,83,93,108,115,122)
midline.electrodes <- c(11,62,129)
p600.time.window <- 500:800

# ---- Table 2: four ANOVAs ----
mk <- function(data){ data %>% group_by(subject, electrode, grammar.condition) %>%
  summarize(mean.amplitude = mean(voltage), .groups='drop') }
lang.mid <- mk(filter(eeg.data, electrode %in% midline.electrodes, t %in% p600.time.window, stimulus.condition=='Language'))
lang.lat <- mk(filter(eeg.data, electrode %in% lateral.electrodes, t %in% p600.time.window, stimulus.condition=='Language'))
mus.mid  <- mk(filter(eeg.data, electrode %in% midline.electrodes, t %in% p600.time.window, stimulus.condition=='Music'))
mus.lat  <- mk(filter(eeg.data, electrode %in% lateral.electrodes, t %in% p600.time.window, stimulus.condition=='Music'))

run.anova <- function(d, label){
  a <- ezANOVA(d, dv=mean.amplitude, wid=subject, within=c('electrode','grammar.condition'))
  cat("----", label, "----\n")
  print(a$ANOVA, digits=6)
}

run.anova(lang.mid, "Language Midline (Table 2)")
run.anova(lang.lat, "Language Lateral (Table 2)")
run.anova(mus.mid, "Music Midline (Table 2)")
run.anova(mus.lat, "Music Lateral (Table 2)")

# ---- Difference waves (Table 3) ----
difference.waves <- eeg.data %>%
  group_by(subject, electrode, t, stimulus.condition) %>%
  mutate(difference.voltage = voltage - lag(voltage)) %>%
  filter(!is.na(difference.voltage)) %>%
  select(subject, t, electrode, stimulus.condition, difference.voltage) %>%
  ungroup()

mid.diff <- difference.waves %>% filter(electrode %in% midline.electrodes, t %in% p600.time.window) %>%
  group_by(subject, electrode, stimulus.condition) %>% summarize(mean.amplitude=mean(difference.voltage), .groups='drop') %>% as.data.frame()
lat.diff <- difference.waves %>% filter(electrode %in% lateral.electrodes, t %in% p600.time.window) %>%
  group_by(subject, electrode, stimulus.condition) %>% summarize(mean.amplitude=mean(difference.voltage), .groups='drop') %>% as.data.frame()

a.mid <- ezANOVA(mid.diff, dv=mean.amplitude, wid=subject, within=c('stimulus.condition','electrode'))
cat("---- Difference-wave Midline (Table 3) ----\n"); print(a.mid$ANOVA, digits=6)
a.lat <- ezANOVA(lat.diff, dv=mean.amplitude, wid=subject, within=c('stimulus.condition','electrode'))
cat("---- Difference-wave Lateral (Table 3) ----\n"); print(a.lat$ANOVA, digits=6)

# ---- Bayes factors (Table 4) ----
set.seed(12604)
bf.mid <- anovaBF(mean.amplitude ~ stimulus.condition * electrode + subject, data=mid.diff, whichRandom="subject")
cat("---- BF midline ----\n"); print(extractBF(bf.mid))
cat("BF electrode-only vs electrode+stimulus:", extractBF(bf.mid)$bf[1]/extractBF(bf.mid)$bf[3], "\n")

set.seed(12604)
bf.lat <- anovaBF(mean.amplitude ~ stimulus.condition * electrode + subject, data=lat.diff, whichRandom="subject")
cat("---- BF lateral ----\n"); print(extractBF(bf.lat))
cat("BF electrode-only vs full:", extractBF(bf.lat)$bf[1]/extractBF(bf.lat)$bf[4], "\n")
cat("BF full vs main-effects-only:", extractBF(bf.lat)$bf[4]/extractBF(bf.lat)$bf[3], "\n")

# ---- RATN (appendix) ----
RATN.tw <- 300:400
RATN <- eeg.data %>%
  filter(electrode %in% lateral.electrodes, t %in% RATN.tw, stimulus.condition=='Music') %>%
  mutate(hemisphere = ifelse(electrode %in% c(33,39,42,45,70), "left","right")) %>%
  mutate(electrode.site = ifelse(electrode %in% c(33,122),"F", ifelse(electrode %in% c(39,115),"A",
      ifelse(electrode %in% c(42,93),"W", ifelse(electrode %in% c(45,108),"T","O"))))) %>%
  group_by(subject, electrode.site, grammar.condition, hemisphere) %>% summarize(mean.amplitude=mean(voltage), .groups='drop')
RATN$electrode.site <- as.factor(RATN$electrode.site); RATN$hemisphere <- as.factor(RATN$hemisphere)
cat("---- RATN ANOVA (appendix) ----\n")
RATN.anova <- ezANOVA(RATN, dv=mean.amplitude, wid=subject, within=c('electrode.site','grammar.condition','hemisphere'))
print(RATN.anova$ANOVA, digits=6)

set.seed(12604)
bf.RATN <- anovaBF(mean.amplitude ~ electrode.site * grammar.condition * hemisphere + subject, data=data.frame(RATN), whichRandom="subject")
cat("RATN: full model BF (1/bf[18]):\n")
cat(1/bf.RATN[18], "\n")

# RATN: find index of the model with grammar.condition + subject (the winning model)
summ <- suppressMessages(summary(bf.RATN))
print(summ)
