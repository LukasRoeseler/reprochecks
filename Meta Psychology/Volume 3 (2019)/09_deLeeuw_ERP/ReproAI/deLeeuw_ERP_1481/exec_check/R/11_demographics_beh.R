suppressMessages({
  library(readr); library(dplyr)
})
cat("==== START recompute: demographics + exclusions + behavioral (status: running) ====\n")

base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check"
setwd(base)

technical.problems <- c(8, 21)
too.few.segments <- c(11, 23, 25, 40)
excluded.subjects <- c(technical.problems, too.few.segments)

raw.dem <- read_csv('data/raw/demographic_data.csv', show_col_types=FALSE)
cat("Demographic raw rows (subjects with data):", nrow(raw.dem), "\n")

dem <- raw.dem %>% filter(!Subject %in% excluded.subjects)
dem.sum <- dem %>% summarize(
  mean.age=mean(Age), sd.age=sd(Age), min.age=min(Age), max.age=max(Age),
  mean.years=mean(YearsMusicalExperience), sd.years=sd(YearsMusicalExperience),
  mean.hpw=mean(HoursPerWeek), sd.hpw=sd(HoursPerWeek),
  n=n())
cat("Analytic-sample demographics (N =", dem.sum$n, "):\n")
print(dem.sum)

cat("Age M(SD) =", round(dem.sum$mean.age,1), "(", round(dem.sum$sd.age,1), ")  paper: 19.8 (1.2)\n")
cat("Years experience M(SD) =", round(dem.sum$mean.years,1), "(", round(dem.sum$sd.years,1), ")  paper: 9.7 (3.3)\n")
cat("Hours/week M(SD) =", round(dem.sum$mean.hpw,1), "(", round(dem.sum$sd.hpw,1), ")  paper: 5.8 (3.4)\n")

# ---- Behavioral accuracy (Table 1) ----
beh <- read_csv('data/generated/beh_data_tidy.csv', show_col_types=FALSE) %>%
  filter(!subject_id %in% excluded.subjects) %>%
  filter(!syntax_cat %in% c('Filler-Gram','Filler-Ungram'))
summary.beh <- beh %>% group_by(syntax_cat, subject_id) %>%
  summarize(accuracy = mean(correct)*100, .groups='drop') %>%
  group_by(syntax_cat) %>% summarize(mean=mean(accuracy), sd=sd(accuracy))
cat("BEHAVIORAL ACCURACY (Table 1):\n")
print(summary.beh, digits=6)

# ---- Mean usable trials (Results, p.6) ----
eeg.data <- read_csv('data/generated/eeg_data_tidy.csv', show_col_types=FALSE,
    col_types = cols(electrode=col_factor(levels=NULL), subject=col_factor(levels=NULL),
                     stimulus.condition=col_factor(levels=NULL), grammar.condition=col_factor(levels=NULL))) %>%
  filter(!subject %in% excluded.subjects)
cat("EEG rows (analytic N=35):", nrow(eeg.data), "\n")

# usable segments per subject per condition: number of distinct t per (subject,stimulus,grammar) -> approximate trial count via electrode count
trials <- eeg.data %>% group_by(subject, stimulus.condition, grammar.condition, t) %>%
  summarize(ne=n(), .groups='drop')
cat("Total (subject x t) triplets as proxy; computing mean usable trials per condition via one reference electrode\n")
# Instead reproduce author notebook approach: mean usable trials = mean over subjects of number of distinct t values present
mtrials <- trials %>%
  group_by(subject, stimulus.condition, grammar.condition) %>%
  summarize(ntrials = n(), .groups='drop') %>%
  group_by(stimulus.condition, grammar.condition) %>%
  summarize(mean.trials = mean(ntrials), .groups='drop')
cat("Mean usable trials (paper: LG 27.7, LU 27.7, MG 33.3, MU 33.0):\n")
print(mtrials, digits=6)

cat("==== END demographics+behavioral (status: OK) ====\n")
