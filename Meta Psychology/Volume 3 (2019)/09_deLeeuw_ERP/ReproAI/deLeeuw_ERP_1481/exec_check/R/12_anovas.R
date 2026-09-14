suppressMessages({
  library(readr); library(dplyr); library(ez); library(tidyr)
})
cat("==== START recompute: ANOVAs (Tables 2, 3) + RATN (status: running) ====\n")

base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check"
setwd(base)

excluded.subjects <- c(8, 21, 11, 23, 25, 40)

eeg.data <- read_csv('data/generated/eeg_data_tidy.csv', show_col_types=FALSE,
    col_types = cols(electrode=col_factor(levels=NULL), subject=col_factor(levels=NULL),
                     stimulus.condition=col_factor(levels=NULL), grammar.condition=col_factor(levels=NULL))) %>%
  filter(!subject %in% excluded.subjects)

lateral.electrodes <- c(33,39,42,45,70,83,93,108,115,122)
midline.electrodes <- c(11,62,129)
p600.time.window <- 500:800

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
cat("==== TABLE 2: grammaticality x electrode ANOVAs (500-800 ms) ====\n")
run.anova(lang.mid, "Language Midline")
run.anova(lang.lat, "Language Lateral")
run.anova(mus.mid,  "Music Midline")
run.anova(mus.lat,  "Music Lateral")

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

cat("==== TABLE 3: difference-wave ANOVAs (500-800 ms) ====\n")
a.mid <- ezANOVA(mid.diff, dv=mean.amplitude, wid=subject, within=c('stimulus.condition','electrode'))
cat("-- Difference Midline --\n"); print(a.mid$ANOVA, digits=6)
a.lat <- ezANOVA(lat.diff, dv=mean.amplitude, wid=subject, within=c('stimulus.condition','electrode'))
cat("-- Difference Lateral --\n"); print(a.lat$ANOVA, digits=6)

# ---- RATN (appendix) 300-400 ms, music, lateral ----
RATN.tw <- 300:400
RATN <- eeg.data %>%
  filter(electrode %in% lateral.electrodes, t %in% RATN.tw, stimulus.condition=='Music') %>%
  mutate(hemisphere = ifelse(electrode %in% c(33,39,42,45,70), "left","right")) %>%
  mutate(electrode.site = ifelse(electrode %in% c(33,122),"F", ifelse(electrode %in% c(39,115),"A",
      ifelse(electrode %in% c(42,93),"W", ifelse(electrode %in% c(45,108),"T","O"))))) %>%
  group_by(subject, electrode.site, grammar.condition, hemisphere) %>% summarize(mean.amplitude=mean(voltage), .groups='drop')
RATN$electrode.site <- as.factor(RATN$electrode.site); RATN$hemisphere <- as.factor(RATN$hemisphere)
cat("==== RATN 3-way ANOVA (appendix; paper F(4,136)=.366, p=.832) ====\n")
RATN.anova <- ezANOVA(RATN, dv=mean.amplitude, wid=subject, within=c('electrode.site','grammar.condition','hemisphere'))
print(RATN.anova$ANOVA, digits=6)

saveRDS(list(mid.diff=mid.diff, lat.diff=lat.diff, RATN=RATN), file="output/_diff_data.rds")
cat("==== END anovas (status: OK) ====\n")
