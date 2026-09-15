# Load data
library(readxl)
data <- read_excel("Ohtsubo_et_al2014Study2a_data.xls", 
                   sheet = "Sheet3", skip = 1)
# Load necessary library
library(tidyverse)


# Intimacy scale ----------------------------------------------------------
# According to the article (see quotation below), the Intimacy scale should have only 4 items despite the fact that the dataset contains 
# 10 items in the "Intimacy Questionnaire" column. I had to figure out, which 4 items belong to the Intimacy scale. 
# (p. 241: "After ﬁnishing the quiz game, the participants ﬁlled out the questionnaires containing four intimacy items: understanding (If
# you became friends with the partner, how well do you think this person would understand you?), validation (If you became friends
# with the partner, how much do you think this person would accept you?), caring (How much did the partner care for you?),
# and an additional reversed item corresponding to caring (How much do you agree that this partner had little concern for you?).
# These items were rated on a 7-point scale (1 = not at all to 7 = very much). The four items were aggregated as the intimacy score).

#  First I translated all items (r1:r10) of the Intimacy scale provided by the dataset.
# Credit: DeepL
# r1 = Your partner cared about you.
# r2 = Your partner will not help you if you are in trouble
# r3 = I would like to be friends with my partner.
# r4 = I don't think your partner is interested in you at all.
# r5 = I think you and your partner would make good friends.
# r6 = Your partner will accept you as a friend.
# r7 = Your partner is likely to understand you if you become friends.
# r8 = Partner is a caring person
# r9 = Partner is a kind person
# r10 = Partners are meddlers.

# Based on the translations I have chosen items r7 (understanding), r6 (validation), r1 (caring), and r4 (reversed caring)
# and calculated an aggregated score.
# First I had to recode item n. 4:
data <- data %>% 
  mutate(r4rec = recode(r4,"1"= 7, "2" = 6, "3" = 5, "4" = 4, 
                        "5" = 3, "6" = 2, "7" = 1,))
# and then I have calculated aggregated score:
data <- data %>% 
  mutate(intimacy_scale = (r1 + r4rec + r6 + r7)/4)
# I have verified that intimacy scale constructed by me (intimacy_scale) has the same values than scale with the same name (Intimacy)
# preexisting in the dataset
which(data$intimacy_scale != data$Intimacy)

# Show sample size
data %>% summarize(sum(complete.cases(Intimacy)))

# Identification of excluded participant ----------------------------------
# The article contains only brief information about excluding 1 participant: "after excluding one participant who suspected
# the use of deceptive procedures" (p. 241). There is no further information, nor in the excel data, which specific participant was excluded.
# Therefore my first step was to find out, which one it was.

# show number of male (coded as 0) and female (coded as 1) gender participants
data %>% count(sex)
# The method section contains the following information: "Participants were 29 Japanese undergraduates (10 males and 19 females" (p. 241) 
# The original dataset contains information from 11 males and 19 females. This means that one excluded participant should have male gender. 
# Based on the information about the mean and standard deviation of age reported in the article ("10 males and 19 females, 
# Mage ± SD = 19.3 ± 0.89", p. 241) the one excluded participant should be case n. 3, 12, 13, 22, or 25. 
# Only when excluding one of these participants does mean and SD of age match with the information in the article.
data %>% slice(-3) %>% summarise(mean(age), sd((age)))
data %>% slice(-12) %>% summarise(mean(age), sd((age)))
data %>% slice(-13) %>% summarise(mean(age), sd((age)))
data %>% slice(-22) %>% summarise(mean(age), sd((age)))
data %>% slice(-25) %>% summarise(mean(age), sd((age)))


# Comparison of attention and no attention --------------------------------
# The next step was to compare two groups using the independent samples t-test with Intimacy being the dependent variable
# and cnd being independent variable (with no clue whether 1 or 2 depict attention condition). Since the article does not mention 
# anything related to equality of variances or Welch test, I assumed the authors have used the Student t-test.
# Since it was still unclear to me, which one specific participant was excluded, I had to repeat the analysis 5 times and compare its 
# results with the results reported in the article for a possible match.
attempt1 <- data %>% slice(-3)
attempt2 <- data %>% slice(-12) 
attempt3 <- data %>% slice(-13) 
attempt4 <- data %>% slice(-22) 
attempt5 <- data %>% slice(-25) 
attempts <- list(attempt1,attempt2, attempt3, attempt4, attempt5)
funtest <- function(x){t.test(Intimacy ~ cnd, data = x, var.equal = TRUE, alternative = "two.sided")}
lapply(attempts, funtest)

# Based on the results of the t-tests the excluded participant should be participant n. 22 or n. 25 (row in the dataset). 
# Both are male gender, have the same age, and are producing (when excluding one of them) identical results of the t-test. 
# From the responses to other items in the dataset:
newdata <-  data %>% slice(c(22,25))
# it is impossible to find out, which one (of these two) was excluded. There is no clue. Therefore, I have continued with two t-tests,
# with the sequential exclusion of one (attempt4) and then the other (attempt5) participant:

# Load necessary package for reporting effect size
library(rstatix)
# Little edit to produce exact p-values:
options(scipen = 999)
# Attention condition is coded as 1, no attention condition is coded as 2 (information is present in the excel data file)
t.test(Intimacy ~ cnd, data = attempt4, var.equal = TRUE, alternative = "two.sided")
attempt4 %>% cohens_d(Intimacy ~ cnd, var.equal = TRUE)
t.test(Intimacy ~ cnd, data = attempt5, var.equal = TRUE, alternative = "two.sided")
attempt5 %>% cohens_d(Intimacy ~ cnd, var.equal = TRUE)

# Calculate means and SDs for Intimacy
attempt4 %>% group_by(cnd) %>% summarize(mean(Intimacy), sd(Intimacy))
attempt5 %>% group_by(cnd) %>% summarize(mean(Intimacy), sd(Intimacy))
