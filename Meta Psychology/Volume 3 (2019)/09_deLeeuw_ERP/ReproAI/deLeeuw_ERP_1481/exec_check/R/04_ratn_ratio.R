suppressMessages({ library(readr); library(dplyr); library(BayesFactor); library(ez) })
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check")
excluded.subjects <- c(8,21,11,23,25,40)
lateral.electrodes <- c(33,39,42,45,70,83,93,108,115,122)
eeg.data <- read_csv('data/generated/eeg_data_tidy.csv', show_col_types=FALSE,
    col_types = cols(electrode=col_factor(levels=NULL), subject=col_factor(levels=NULL),
        stimulus.condition=col_factor(levels=NULL), grammar.condition=col_factor(levels=NULL))) %>%
    filter(!subject %in% excluded.subjects)
RATN.tw <- 300:400
RATN <- eeg.data %>%
  filter(electrode %in% lateral.electrodes, t %in% RATN.tw, stimulus.condition=='Music') %>%
  mutate(hemisphere = ifelse(electrode %in% c(33,39,42,45,70), "left","right")) %>%
  mutate(electrode.site = ifelse(electrode %in% c(33,122),"F", ifelse(electrode %in% c(39,115),"A",
      ifelse(electrode %in% c(42,93),"W", ifelse(electrode %in% c(45,108),"T","O"))))) %>%
  group_by(subject, electrode.site, grammar.condition, hemisphere) %>% summarize(mean.amplitude=mean(voltage), .groups='drop')
RATN$electrode.site <- as.factor(RATN$electrode.site)
RATN$hemisphere <- as.factor(RATN$hemisphere)
set.seed(12604)
bf.RATN <- anovaBF(mean.amplitude ~ electrode.site * grammar.condition * hemisphere + subject,
                   data=data.frame(RATN), whichRandom="subject")
ebf <- extractBF(bf.RATN)
cat("BF values (relative to subject-only denominator):\n")
for (i in 1:18) cat(i, "bf=", ebf$bf[i], "\n")
cat("ratio full(model18)/model17:", ebf$bf[18]/ebf$bf[17], "\n")
cat("=> data are 1/(ratio) times less likely under full vs no-3way model:", 1/(ebf$bf[18]/ebf$bf[17]), "\n")
cat("ratio full/model2 (winning grammar+subject):", ebf$bf[18]/ebf$bf[2], "\n")
