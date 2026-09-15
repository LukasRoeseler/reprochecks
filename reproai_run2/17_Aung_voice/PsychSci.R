library(geoR)
library(brms) 
library(dplyr)
library(bayesboot)
library(bayestestR)
library(ggplot2)
library(emmeans)
library(patchwork)
library(bayesplot)
library(ggtext)
library(dplyr)
library(tidyverse)
library(psych)
library(GPArotation)
library(coda)

#Set global options of HPD interval for .89
emm_options(ref_grid = list(level = .89),
            contrast = list(infer = c(TRUE,TRUE)))

#Load Data
data <- read.csv(".../iPodStudyData.csv")
load(".../A_geo.rda")
load(".../A_ling.rda")


#Main model across all perceptual questions (Pre-registered)
m1 <- brm(Outcome ~ 1 + question + Pair +   
            (1|id) +  (1|voice) + (1|Region/country)  +  
            (1|gr(country1, cov = list(A_ling))) +
            (1|gr(country2, cov = list(A_geo))) ,
          data = newdata, family = bernoulli,
          data2 = list(A_ling = A_ling, A_geo = A_geo),
          prior = c(prior(normal(0, 0.5), class = b),
                    prior(student_t(3, 0, 1), class = sd)),
          iter = 5000, warmup = 1000, cores = 2, chains = 2,
          seed = 123, 
          control = list(adapt_delta = 0.999, max_treedepth = 15),
          backend = "cmdstanr",
          threads = threading(2))
save(m1, file = "m1.rda")
#Obtain marginal means and post-hoc comparisons
hpd.summary(emmeans(m1, 'question'))
hpd.summary(emmeans(m1, 'Pair'))
hpd.summary(pairs(emmeans(m1, 'Pair')), type = "response")
hpd.summary(pairs(emmeans(m1, 'question')), type = "response")
hpd.summary(emmeans(m1, 'question', 'Pair'))




#Drop empty space as a factor level in the variable
newdata$orientation <- as.factor(newdata$orientation)
newdata$orientation[newdata$orientation=='']=NA
newdata$orientation = droplevels(newdata$orientation)
#Drop empty space as a factor level in the variable
newdata$relationship <- as.factor(newdata$relationship)
newdata$relationship[newdata$relationship=='']=NA
newdata$relationship = droplevels(newdata$relationship)
#Main model across all perceptual questions, plus control variables (Pre-registered)
m2 <- brm(Outcome ~ 1 + question + Pair + age + relationship + Children + orientation + 
            (1|id) + (1|voice) + (1|Region/country) +
            (1|gr(country1, cov = list(A_ling))) +
            (1|gr(country2, cov = list(A_geo))),
          data = newdata, family = bernoulli,
          data2 = list(A_ling = A_ling, A_geo = A_geo),
          prior = c(prior(normal(0, 0.5), class = b),
                    prior(student_t(3, 0, 1), class = sd)),
          iter = 5000, warmup = 1000, cores = 2, chains = 2,
          seed = 123, thin = 5, 
          control = list(adapt_delta = 0.999, max_treedepth = 15),
          backend = "cmdstanr",
          threads = threading(2))
summary(m2, robust = T)
#Obtain HPD intervals for numeric variables age and children 
head(coda::HPDinterval(as.mcmc(m2, combine_chains = TRUE), prob = .89), 15)
#Obtain marginal means and HPD intervals for numeric variables age and children 
hpd.summary(emmeans(m2, 'relationship'))
hpd.summary(emmeans(m2, 'orientation'))
save(m2, file = "m2.rda")




#Prepare for Factor analysis (Pre-registered)
#Cross-cultural factors: health, inequality, food security
d <- read.csv(".../countrydata.csv")
#Transform into z scores
d1 <- mutate(d, Fertility = scale(Fertility),
             Homicide = scale(Homicide),
             Urban = scale(Urban),
             GDP = scale(GDP),
             Mortality = scale(Mortality),
             Gini = scale(Gini),
             YLCD = scale(YLCD),
             LExp = scale(LExp),
             GII = scale(GII),
             HDI = scale(HDI),
             HPrev = scale(HPrev),
             GFSI = scale(GFSI),
             AvgFemalePitch = scale(AvgFemalePitch),
             AvgMalePitch = scale(AvgMalePitch),
             RelationalMobility = scale(RelationalMobility))
#Replace missing values with 0 
d1[is.na(d1)] <- 0
d2 <- dplyr:: select(d1, Fertility,
                     Homicide, Urban,
                     GDP, Mortality, Gini,
                     YLCD, LExp, GII,HDI,
                     HPrev)
#Conduct factor analysis
country.fa <- principal(d2, nfactors = 2, rotate = "oblimin")
country.fa$loadings
detach("package:plyr", unload = TRUE)
country.fa.scores <- country.fa$scores%>%
  as.data.frame() %>%
  rename(health.fa = TC1, inequality.fa = TC2) 
#Combine data
country.data <- cbind(d1,country.fa.scores)
#Test for correlation
cor.test(country.data$health.fa, country.data$inequality.fa)
#create a dataset called newdata2 for cross-cultural analyses 
newdata2 <- dplyr::left_join(newdata, country.data, by = "country")  
#Correlation tests between mean F0 of each sex and other country-statistics (Exploratory)
#Male Mean F0
cor.test(country.data$AvgMalePitch, country.data$Urban)
cor.test(country.data$AvgMalePitch, country.data$LExp)
cor.test(country.data$AvgMalePitch, country.data$Fertility)
cor.test(country.data$AvgMalePitch, country.data$YLCD)
cor.test(country.data$AvgMalePitch, country.data$HDI)
cor.test(country.data$AvgMalePitch, country.data$HPrev)
cor.test(country.data$AvgMalePitch, country.data$GII)
cor.test(country.data$AvgMalePitch, country.data$Homicide)
cor.test(country.data$AvgMalePitch, country.data$Mortality)
cor.test(country.data$AvgMalePitch, country.data$Gini)
cor.test(country.data$AvgMalePitch, country.data$GDP)
cor.test(country.data$AvgMalePitch, country.data$health.fa)
cor.test(country.data$AvgMalePitch, country.data$inequality.fa)
cor.test(country.data$AvgMalePitch, country.data$GFSI)
cor.test(country.data$AvgMalePitch, country.data$RelationalMobility)
#Female Mean F0
cor.test(country.data$AvgFemalePitch, country.data$Urban)
cor.test(country.data$AvgFemalePitch, country.data$LExp)
cor.test(country.data$AvgFemalePitch, country.data$Fertility)
cor.test(country.data$AvgFemalePitch, country.data$YLCD)
cor.test(country.data$AvgFemalePitch, country.data$HDI)
cor.test(country.data$AvgFemalePitch, country.data$HPrev)
cor.test(country.data$AvgFemalePitch, country.data$GII)
cor.test(country.data$AvgFemalePitch, country.data$Homicide)
cor.test(country.data$AvgFemalePitch, country.data$Mortality)
cor.test(country.data$AvgFemalePitch, country.data$Gini)
cor.test(country.data$AvgFemalePitch, country.data$GDP)
cor.test(country.data$AvgFemalePitch, country.data$health.fa)
cor.test(country.data$AvgFemalePitch, country.data$inequality.fa)
cor.test(country.data$AvgFemalePitch, country.data$GFSI)
cor.test(country.data$AvgFemalePitch, country.data$RelationalMobility)





#Does Relational Mobility Predict F0 selection?
#Men's perception of long-term attractiveness for women's voices (Exploratory)
m17 <- brm(Outcome ~ 1 + RelationalMobility + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m17, file = "m17.rda")
summary(m17, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m17, combine_chains = TRUE), prob = .89), 4)



#Men's perception of short-term attractiveness for women's voices(Exploratory)
m18 <- brm(Outcome ~ 1 + RelationalMobility + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m18, file = "m18.rda")
summary(m18, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m18, combine_chains = TRUE), prob = .89), 4)




#Men's perception of dominance for men's voices (Exploratory)
m19 <- brm(Outcome ~ 1 + RelationalMobility + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m19, file = "m19.rda")
summary(m19, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m19, combine_chains = TRUE), prob = .89), 4)




#Men's perception of prestige for men's voices (Exploratory)
m20 <- brm(Outcome ~ 1 + RelationalMobility + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Respected"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m20, file = "m20.rda")
summary(m20, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m20, combine_chains = TRUE), prob = .89), 4)






#Women's perception of long-term attractiveness for men's voices (Exploratory)
m21 <- brm(Outcome ~ 1 + RelationalMobility + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m21, file = "m21.rda")
summary(m21, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m21, combine_chains = TRUE), prob = .89), 4)






#Women's perception of short-term attractiveness for men's voices (Exploratory)
m22 <- brm(Outcome ~ 1 + RelationalMobility + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m22, file = "m22.rda")
summary(m22, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m22, combine_chains = TRUE), prob = .89), 4)
conditional_effects(m22)





#Women's perception of flirtatiousness for women's voices (Exploratory)
m23 <- brm(Outcome ~ 1 + RelationalMobility + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Interested in Attracting Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m23, file = "m23.rda")
summary(m23, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m23, combine_chains = TRUE), prob = .89), 4)
conditional_effects(m23)




#Women's perception of attractiveness to men for women's voices (Exploratory)
m24 <- brm(Outcome ~ 1 + RelationalMobility + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive to Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m24, file = "m24.rda")
summary(m24, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m24, combine_chains = TRUE), prob = .89), 4)
conditional_effects(m24)



#Does local Relational Mobility, submeasures (meeting & choosing), social familiarity (anonymity), and time spent with strangers also Predict F0 selection?
#Men's perception of dominance for men's voices (All Exploratory)
#Local Relational Mobility
m25 <- brm(Outcome ~ 1 + localRM + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m25, file = "m25.rda")
summary(m25)
head(coda::HPDinterval(as.mcmc(m25, combine_chains = TRUE), prob = .89), 4)
hypothesis(m25, 'localRM > 0')




#Local Relational Mobility submeasures
m26 <- brm(Outcome ~ 1 + meeting + choosing + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m26, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m26, combine_chains = TRUE), prob = .89), 5)
save(m26, file = "m26.rda")




#Local Social Familiarity 
m27 <- brm(Outcome ~ 1 + anonymity + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m27, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m27, combine_chains = TRUE), prob = .89), 5)
save(m27, file = "m27.rda")



#Time Spent with Strangers
m28 <- brm(Outcome ~ 1 + strangers + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m28, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m28, combine_chains = TRUE), prob = .89), 5)
save(m28, file = "m28.rda")




#Men's perception of prestige for men's voices (All Exploratory)
#Local Relational Mobility submeasures
m29 <- brm(Outcome ~ 1 + meeting + choosing + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Respected"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m29, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m29, combine_chains = TRUE), prob = .89), 5)
save(m29, file = "m29.rda")




#Local Social Familiarity 
m30 <- brm(Outcome ~ 1 + anonymity + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Respected"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m30, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m30, combine_chains = TRUE), prob = .89), 5)
save(m30, file = "m30.rda")




#Time Spent with Strangers
m31 <- brm(Outcome ~ 1 + strangers + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Respected"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m31, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m31, combine_chains = TRUE), prob = .89), 5)
save(m31, file = "m31.rda")





#Women's perception of short-term attractiveness for men's voices (All Exploratory)
#Local Relational Mobility submeasures
m32 <- brm(Outcome ~ 1 + meeting + choosing + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m32, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m32, combine_chains = TRUE), prob = .89), 5)
save(m32, file = "m32.rda")




#Local Social Familiarity 
m33 <- brm(Outcome ~ 1 + anonymity + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m33, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m33, combine_chains = TRUE), prob = .89), 5)
save(m33, file = "m33.rda")




#Time Spent with Strangers
m34 <- brm(Outcome ~ 1 + strangers + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m34, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m34, combine_chains = TRUE), prob = .89), 5)
save(m34, file = "m34.rda")




#Men's perception of short-term attractiveness for women's voices (All Exploratory)
#Local Relational Mobility submeasures
m35 <- brm(Outcome ~ 1 + meeting + choosing + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m35, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m35, combine_chains = TRUE), prob = .89), 5)
save(m35, file = "m35.rda")




#Local Social Familiarity 
m36 <- brm(Outcome ~ 1 + anonymity + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m36, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m36, combine_chains = TRUE), prob = .89), 5)
save(m36, file = "m36.rda")



#Time Spent with Strangers
m37 <- brm(Outcome ~ 1 + strangers + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m37, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m37, combine_chains = TRUE), prob = .89), 5)
save(m37, file = "m37.rda")





#Men's perception of long-term attractiveness for men's voices (All Exploratory)
#Local Relational Mobility submeasures
m38 <- brm(Outcome ~ 1 + meeting + choosing + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m38, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m38, combine_chains = TRUE), prob = .89), 5)
save(m38, file = "m38.rda")




#Local Social Familiarity 
m39 <- brm(Outcome ~ 1 + anonymity + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m39, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m39, combine_chains = TRUE), prob = .89), 5)
save(m39, file = "m39.rda")



#Time Spent with Strangers
m40 <- brm(Outcome ~ 1 + strangers + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m40, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m40, combine_chains = TRUE), prob = .89), 5)
save(m40, file = "m40.rda")





#Women's perception of flirtatiousness for women's voices (All Exploratory)
#Local Relational Mobility submeasures
m41<- brm(Outcome ~ 1 + meeting + choosing + AvgFemalePitch + 
            (1|id) + (1|voice) + (1|Region/country) +
            (1|gr(country1, cov = list(A_ling))) +
            (1|gr(country2, cov = list(A_geo))),
          data = newdata2[which(newdata2$question == "Interested in Attracting Men"),], family = bernoulli,
          data2 = list(A_ling = A_ling, A_geo = A_geo),
          prior = c(prior(normal(0, 0.5), class = b),
                    prior(student_t(3, 0, 1), class = sd)),
          iter = 5000, warmup = 1000, cores = 2, chains = 2,
          seed = 123, 
          control = list(adapt_delta = 0.999, max_treedepth = 15),
          backend = "cmdstanr",
          threads = threading(2))
summary(m41, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m41, combine_chains = TRUE), prob = .89), 5)
save(m41, file = "m41.rda")




#Local Social Familiarity 
m42 <- brm(Outcome ~ 1 + anonymity + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Interested in Attracting Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m42, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m42, combine_chains = TRUE), prob = .89), 5)
save(m42, file = "m42.rda")



#Time Spent with Strangers
m43 <- brm(Outcome ~ 1 + strangers + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Interested in Attracting Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m43, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m43, combine_chains = TRUE), prob = .89), 5)
save(m43, file = "m43.rda")





#Women's perception of attractiveness to men for women's voices (All Exploratory)
#Local Relational Mobility submeasures
m44 <- brm(Outcome ~ 1 + meeting + choosing + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive to Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m44, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m44, combine_chains = TRUE), prob = .89), 5)
save(m44, file = "m44.rda")




#Local Social Familiarity 
m45 <- brm(Outcome ~ 1 + anonymity + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive to Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m45, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m45, combine_chains = TRUE), prob = .89), 5)
save(m45, file = "m45.rda")




#Time Spent with Strangers
m46 <- brm(Outcome ~ 1 + strangers + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive to Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m46, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m46, combine_chains = TRUE), prob = .89), 5)
save(m46, file = "m46.rda")




#Women's perception of long-term attractiveness for men's voices (All Exploratory)
#Local Relational Mobility submeasures
m47 <- brm(Outcome ~ 1 + meeting + choosing + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m47, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m47, combine_chains = TRUE), prob = .89), 5)
save(m47, file = "m47.rda")




#Local Social Familiarity 
m48 <- brm(Outcome ~ 1 + anonymity + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m48, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m48, combine_chains = TRUE), prob = .89), 5)
save(m48, file = "m48.rda")




#Time Spent with Strangers
m49 <- brm(Outcome ~ 1 + strangers + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m49, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m49, combine_chains = TRUE), prob = .89), 5)
save(m49, file = "m49.rda")




#Men's perception of prestige for men's voices (Exploratory)
#Local Relational Mobility
m50 <- brm(Outcome ~ 1 + localRM + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Respected"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m50, file = "m50.rda")
summary(m50, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m50, combine_chains = TRUE), prob = .89), 4)




#Women's perception of short-term attractiveness for men's voices (Exploratory)
#Local Relational Mobility
m51 <- brm(Outcome ~ 1 + localRM + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m51, file = "m51.rda")
summary(m51, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m51, combine_chains = TRUE), prob = .89), 4)



#Women's perception of long-term attractiveness for men's voices (Exploratory)
#Local Relational Mobility
m52 <- brm(Outcome ~ 1 + localRM + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m52, file = "m52.rda")
summary(m52, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m52, combine_chains = TRUE), prob = .89), 4)

#Men's perception of short-term attractiveness for women's voices (All Exploratory)
m53 <- brm(Outcome ~ 1 + localRM + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m53, file = "m53.rda")
summary(m53, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m53, combine_chains = TRUE), prob = .89), 4)


#Men's perception of long-term attractiveness for women's voices (Exploratory)
#Local Relational Mobility
m54 <- brm(Outcome ~ 1 + localRM + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive for a Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m54, file = "m54.rda")
summary(m54, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m54, combine_chains = TRUE), prob = .89), 4)




#Women's perception of flirtatiousness for women's voices (Exploratory)
#Local Relational Mobility
m55 <- brm(Outcome ~ 1 + localRM + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Interested in Attracting Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m55, file = "m55.rda")
summary(m55, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m55, combine_chains = TRUE), prob = .89), 4)



#Women's perception of attractiveness to Men for women's voices (Exploratory)
#Local Relational Mobility
m56 <- brm(Outcome ~ 1 + localRM + AvgFemalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Attractive to Men"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m56, file = "m56.rda")
summary(m56, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m56, combine_chains = TRUE), prob = .89), 4)




#Men's perception of dominance for men's voices (Exploratory)
m57 <- brm(Outcome ~ 1 + Homicide + GII + Gini + HDI + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m57, file = "m57.rda")
summary(m57, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m57, combine_chains = TRUE), prob = .89), 6)
hypothesis(m57, "Homicide > 0")





#Men's perception of prestige for men's voices (Exploratory)
m58 <- brm(Outcome ~ 1 + Homicide + GII + Gini + HDI + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Respected"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m58, file = "m58.rda")
summary(m58, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m58, combine_chains = TRUE), prob = .89), 6)
hypothesis(m58, "Homicide > 0")






#Women's perception of Short-term Attractiveness for men's voices (Exploratory)
m59 <- brm(Outcome ~ 1 + Homicide + GII + Gini + HDI + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m59, file = "m59.rda")
summary(m59, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m59, combine_chains = TRUE), prob = .89), 6)




#Women's perception of Short-term Attractiveness for men's voices (Exploratory)
m60 <- brm(Outcome ~ 1 + Homicide + GII + Gini + HDI + AvgMalePitch + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m60, file = "m60.rda")
summary(m60, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m60, combine_chains = TRUE), prob = .89), 6)




#Men's assessment of dominance and prestige differ dependent on their age? (Exploratory)
m61 <- brm(Outcome ~ 1 + question * age +   Pair +
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Respected" |
                                   newdata2$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m61, file = "m61.rda")
summary(m61, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m61, combine_chains = TRUE), prob = .89),7)
hypothesis(m61, 'questionWinaPhysicalFight:age < 0')
#Trend analysis: post-hoc comparison between slopes
mPostHoc <- emtrends(m61, pairwise ~ question, var = "age")
confint(mPostHoc, adjust = "none", level = 0.89)



#Women's assessment of short and long-term attractiveness differ dependent on the society's homicide rates? (Exploratory)
m62 <- brm(Outcome ~ 1 + question * Homicide +    
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata2[which(newdata2$question == "Short Term" |
                                   newdata2$question == "Long Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m62, file = "m62.rda")
summary(m62, robust = TRUE)
head(coda::HPDinterval(as.mcmc(m62, combine_chains = TRUE), prob = .89), 9)
#Trend analysis: post-hoc comparison between slopes
mPostHoc1 <- emtrends(m62, pairwise ~ question, var = "Homicide")
confint(mPostHoc1, adjust = "none", level = 0.89)
emmip(m62, question ~ Homicide, cov.reduce = FALSE)











#Conduct Robustness test to see if  first language, ability to tell differences, heard clearly, or understood what was said in the recordings matter for F0 selection?
#Drop empty space as a factor level in the variable
newdataa <- newdata
newdataa$first_language <- as.factor(newdataa$first_language)
newdataa$first_language[newdataa$first_language=='']=NA
newdataa$first_language = droplevels(newdataa$first_language)

newdataa$Tell_dif <- as.factor(newdataa$Tell_dif)
newdataa$Tell_dif[newdataa$Tell_dif=='']=NA

newdataa$heard <- as.factor(newdataa$heard)
newdataa$heard[newdataa$heard=='']=NA

newdataa$Understood <- as.factor(newdataa$Understood)
newdataa$Understood[newdataa$Understood=='']=NA






#Male Voices
m66 <- brm(Outcome ~ 1 + first_language +  heard + Tell_dif + Understood + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdataa[which(newdataa$question == "Short Term" |
                                   newdataa$question == "Long Term" |
                                   newdataa$question == "Respected" |
                                   newdataa$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, thin = 5, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m66, robust = T)
head(coda::HPDinterval(as.mcmc(m66, combine_chains = TRUE), prob = .89), 15)
save(m66, file = "m66.rda")






#Female Voices 
m67 <- brm(Outcome ~ 1 +  first_language +  heard + Tell_dif + Understood + 
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdataa[which(newdataa$question == "Attractive for a Long Term"|
                                   newdataa$question == "Attractive for a Short Term"|
                                   newdataa$question == "Attractive to Men"|
                                   newdataa$question == "Interested in Attracting Men"),],
           family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, thin = 5, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
summary(m67, robust = T)
head(coda::HPDinterval(as.mcmc(m67, combine_chains = TRUE), prob = .89), 15)
save(m67, file = "m67.rda")



#Create dataset for SOI_Women
country.data1 <- country.data[ which(country.data$SOI_Women > 0), ]
country.data1$SOI_Women <- scale(country.data1$SOI_Women)
plot(country.data1$SOI_Women, country.data1$health.fa)
newdata3 <- dplyr::left_join(newdata, country.data1, by = "country")  

#Attractiveness assessment for men's voices
m68 <- brm(Outcome ~ 1 + SOI_Women + AvgMalePitch +    
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata3[which(newdata3$question == "Short Term"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m68, file = "m68.rda")
summary(m68, robust = T)
head(coda::HPDinterval(as.mcmc(m68, combine_chains = TRUE), prob = .89), 9)





#Main model across all perceptual questions (Exploratory; note newdata4 is full-samples aged 12-96)
m69 <- brm(Outcome ~ 1 + question + Pair +   
             (1|id) +  (1|voice) + (1|Region/country)  +  
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))) ,
           data = newdata4, family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m69, file = "m69.rda")
summary(m69, robust = T)
head(coda::HPDinterval(as.mcmc(m69, combine_chains = TRUE), prob = .89), 9)




#Men's assessment of dominance and prestige differ dependent on their age? (Exploratory; full-samples)
m70 <- brm(Outcome ~ 1 + question * age +   Pair +
             (1|id) + (1|voice) + (1|Region/country) +
             (1|gr(country1, cov = list(A_ling))) +
             (1|gr(country2, cov = list(A_geo))),
           data = newdata4[which(newdata4$question == "Respected" |
                                   newdata4$question == "Win a Physical Fight"),], family = bernoulli,
           data2 = list(A_ling = A_ling, A_geo = A_geo),
           prior = c(prior(normal(0, 0.5), class = b),
                     prior(student_t(3, 0, 1), class = sd)),
           iter = 5000, warmup = 1000, cores = 2, chains = 2,
           seed = 123, 
           control = list(adapt_delta = 0.999, max_treedepth = 15),
           backend = "cmdstanr",
           threads = threading(2))
save(m70, file = "m70.rda")
summary(m70, robust = T)
#Obtain HPD intervals for numeric variables age and children 
head(coda::HPDinterval(as.mcmc(m70, combine_chains = TRUE), prob = .89), 15)
hypothesis(m70, 'questionWinaPhysicalFight:age < 0')













#Robustness tests models seperately for male voices only, female voices only, and male and female voices on attractiveness questions only
#Run main model for male voices (Exploratory)
#Include perceptual questions and experimental manipulations as predictors
malem1 <- brm(Outcome ~ 1 + question + Pair +  
                (1|id) +  (1|voice) + (1|Region/country)  +
                (1|gr(country1, cov = list(A_ling))) +
                (1|gr(country2, cov = list(A_geo))),
              data = newdata[which(newdata$question == "Short Term" |
                                     newdata$question == "Long Term" |
                                     newdata$question == "Respected" |
                                     newdata$question == "Win a Physical Fight"),],
              family = bernoulli,
              data2 = list(A_ling = A_ling, A_geo = A_geo),
              prior = c(prior(normal(0, 0.5), class = b),
                        prior(student_t(3, 0, 1), class = sd)),
              iter = 5000, warmup = 1000, cores = 2, chains = 2,
              seed = 123, 
              control = list(adapt_delta = 0.999, max_treedepth = 15),
              backend = "cmdstanr",
              threads = threading(2))
save(malem1, file = "malem1.rda")
b <- (emmeans(malem1, 'question'))
b1 <- pairs(emmeans(malem1, 'question'), type = 'response')
b1a <- (emmeans(malem1, 'Pair'))
b1b <- pairs(emmeans(malem1, 'Pair'), type = "response")
b1c <- (emmeans(malem1, 'question', 'Pair'))
hpd.summary(b1, prob = .89)
hpd.summary(b1a, prob = .89)
hpd.summary(b1b, prob = .89)
hpd.summary(b1c, prob = .89)





#Run main model for female voices only (Exploratory)
#Include perceptual questions and experimental manipulations as predictors
femalem1 <- brm(Outcome ~ 1 + question + Pair +  
                  (1|id) +  (1|voice) + (1|Region/country)  +
                  (1|gr(country1, cov = list(A_ling))) +
                  (1|gr(country2, cov = list(A_geo))),
                data = newdata[which(newdata$question == "Attractive for a Long Term"|
                                       newdata$question == "Attractive for a Short Term"|
                                       newdata$question == "Attractive to Men"|
                                       newdata$question == "Interested in Attracting Men"),],
                family = bernoulli,
                data2 = list(A_ling = A_ling, A_geo = A_geo),
                prior = c(prior(normal(0, 0.5), class = b),
                          prior(student_t(3, 0, 1), class = sd)),
                iter = 5000, warmup = 1000, cores = 2, chains = 2,
                seed = 123, 
                control = list(adapt_delta = 0.999, max_treedepth = 15),
                backend = "cmdstanr",
                threads = threading(2))
save(femalem1, file = "femalem1.rda")



c <- (emmeans(femalem1, 'question'))
c1 <- pairs(emmeans(femalem1, 'question'), type = 'response')
c2 <- (emmeans(femalem1, 'Pair'))
c3 <- pairs(emmeans(femalem1, 'Pair'), type = 'response')
head(coda::HPDinterval(as.mcmc(femalem2, combine_chains = TRUE), prob = .89), 13)
c4 <- emmeans(femalem2, 'relationship')
c5 <- emmeans(femalem2, 'orientation')

c6 <- (emmeans(femalem1, 'question', 'Pair'))
hpd.summary(c, prob = .89)
hpd.summary(c1, prob = .89)
hpd.summary(c2, prob = .89)
hpd.summary(c3, prob = .89)
hpd.summary(c4, prob = .89)
hpd.summary(c5, prob = .89)


#Run main model for male and female voices only on attractiveness (Exploratory)
longshortm1 <- brm(Outcome ~ 1 + question + Pair +  
                     (1|id) +  (1|voice) + (1|Region/country)  +
                     (1|gr(country1, cov = list(A_ling))) +
                     (1|gr(country2, cov = list(A_geo))),
                   data = newdata[which(newdata$question == "Attractive for a Long Term"|
                                          newdata$question == "Attractive for a Short Term"|
                                          newdata$question == "Short Term"|
                                          newdata$question == "Long Term"),],
                   family = bernoulli,
                   data2 = list(A_ling = A_ling, A_geo = A_geo),
                   prior = c(prior(normal(0, 0.5), class = b),
                             prior(student_t(3, 0, 1), class = sd)),
                   iter = 5000, warmup = 1000, cores = 2, chains = 2,
                   seed = 123, 
                   control = list(adapt_delta = 0.999, max_treedepth = 15),
                   backend = "cmdstanr",
                   threads = threading(2))
save(longshortm1, file = "longshortm1.rda")




ls1 <- (emmeans(longshortm1, 'question'))
ls2 <- pairs(emmeans(longshortm1, 'question'), type = 'response')
ls3 <- (emmeans(longshortm1, 'Pair'))
ls4 <- pairs(emmeans(longshortm1, 'Pair'), type = 'response')
ls5 <- (emmeans(longshortm1, 'question', 'Pair'))
hpd.summary(ls1, prob = .89)
hpd.summary(ls2, prob = .89)
hpd.summary(ls3, prob = .89)
hpd.summary(ls4, prob = .89)
hpd.summary(ls5, prob = .89)
hpd.summary(ls6, prob = .89)
hpd.summary(ls7, prob = .89)























#Create Figures
#Create Fig 1. (see OSF)
library(maps)
library(dplyr)
library(ggplot2)
world_map <- map_data("world") %>% filter(region != "Antarctica") %>% fortify
country_map <- data.frame(region = c('UK', 'USA', 'Uganda', 'El Salvador',
                                     'Singapore', 'Peru', 'New Zealand',
                                     'Netherlands', 'Nicaragua', 'Mexico',
                                     'Madagascar', 'South Korea', 'Iran',
                                     'India','Spain', 'Denmark', 'Germany',
                                     'Colombia', 'China', 'Chile', 'Canada',
                                     'Brazil'))

country_map1 <- map_data("world", region = c('UK', 'USA', 'Uganda', 'El Salvador',
                                             'Singapore', 'Peru', 'New Zealand',
                                             'Netherlands', 'Nicaragua', 'Mexico',
                                             'Madagascar', 'South Korea', 'Iran',
                                             'India','Spain', 'Denmark', 'Germany',
                                             'Colombia', 'China', 'Chile', 'Canada',
                                             'Brazil'))

country.lab.data <- country_map1 %>%
  group_by(region) %>%
  summarise(long = mean(long), lat = mean(lat))

country.lab.data$region <- as.factor(country.lab.data$region)


country.lab.data <- country.lab.data %>%                               
  mutate(long = replace(long, long == 147.19879097231, 174.7645)) 
country.lab.data <- country.lab.data %>%     
  mutate(lat = replace(lat, lat == -40.8626786681144, -36.8509))
country.lab.data <- country_lab_data



#Note that newdata4 below was not uploaded on OSF. It contains full dataset, including those under 16 and above 40.
long1 <- newdata4 %>% group_by(country) %>% count(sex)
long1$Sample_size <- (long1$n)/24 #Each participant has 24 rows of questions
library(plyr)
long1$country <- as.factor(tolower(long1$country))
long1$sex <- revalue(long1$sex, c("F" = "Women", "M" = "Men"))
long1$country <- revalue(long1$country, c("us" = "USA",
                                          "ug" = "Uganda",
                                          "sv" = "El Salvador",
                                          "sg" = "Singapore",
                                          "pe" = "Peru",
                                          "nz" = "New Zealand",
                                          "nl" = "Netherlands",
                                          "ni" = "Nicaragua",
                                          "mx" = "Mexico",
                                          "mg" = "Madagascar",
                                          "kr" = "South Korea",
                                          "ir" = "Iran",
                                          "in" = "India",
                                          "gb" = "UK",
                                          "es" = "Spain",
                                          "dk" = "Denmark",
                                          "de" = "Germany",
                                          "co" = "Colombia",
                                          "cn" = "China",
                                          "cl" = "Chile",
                                          "ca" = "Canada",
                                          "br" = "Brazil"))
long1$region <- long1$country



detach("package:plyr", unload = TRUE)
library(reshape2)
df <- df[-c(4,6)]

data_wide <- dcast(long1, region ~ sex, value.var="Sample_size")
df= country.lab.data %>% left_join(data_wide,by="region")
df$radius <- (df$Women+df$Men)/15
df$region <- as.factor(df$region)
library(plyr)
df$radius <- as.numeric(revalue(as.character(df$radius), c("72.2" = "14.0", 
                                                           "15.3333333333333" = "11.0",
                                                           "40.6" = "13.0")))
df$Total <- (df$Men) + (df$Women)

library(scatterpie)
library(ggrepel)

map <- ggplot()+
  geom_map(data = world_map, map = world_map,
           aes(x= long, y = lat, group = group, map_id = region),
           fill="white", colour = "black", size = 0.5)+
  geom_map(data = country_map1, map = world_map,
           aes(fill = region, map_id = region),
           colour = "black",  
           size = 0.5) + 
  geom_scatterpie(data = df,
                  aes(x=long, y=lat, group=region, r = radius), cols=c("Men", "Women"), alpha=.8) +
  scale_fill_manual(values = c("grey","grey","grey","grey","grey","grey","grey","grey",
                               "grey","grey","grey","skyblue1","grey","grey",
                               "grey","grey","grey","grey","grey","grey",
                               "grey","grey","grey","firebrick3"), breaks = c("Men", "Women"), name = "")+ theme_classic(base_family = "serif")+
  coord_quickmap() + geom_label_repel(data = df, size = 3, max.overlaps = 50,
                                      aes(x=long, y=lat, label = paste0("n = ", Total))) + theme(legend.position = c(0.5,0.1),
                                                                                                 legend.key.size = unit(0.8, 'cm'),
                                                                                                 legend.text = element_text(size=6),
                                                                                                 legend.direction = "horizontal",
                                                                                                 panel.grid.major = element_blank(),
                                                                                                 panel.grid.minor = element_blank(),
                                                                                                 panel.background = element_blank(),
                                                                                                 axis.title=element_blank(),
                                                                                                 axis.text=element_blank(),
                                                                                                 axis.ticks=element_blank(),
                                                                                                 axis.line = element_blank()) 

svg(file="Fig1.svg", width = 7, height = 5)
map
dev.off()









#Create Fig 2. (made on Canva; see OSF)









#Create Fig 3. 
library(ggplot2)
library(dplyr)

#Figure plot
group_cols <- c('country', 'question')
#Make into long_format
long <- newdata2 %>%
  group_by(!!!syms(group_cols)) %>% 
  summarize(Mean = mean(Outcome, na.rm = T))
#Make into two decimal
long$Mean <- as.numeric(format(round(long$Mean, 2)))
#Make into lower fonts
long$country <- tolower(long$country)
long$country <- plyr:: revalue(long$country, c("us" = "USA",
                                               "ug" = "Uganda",
                                               "sv" = "El Salvador",
                                               "sg" = "Singapore",
                                               "pe" = "Peru",
                                               "nz" = "New Zealand",
                                               "nl" = "Netherlands",
                                               "ni" = "Nicaragua",
                                               "mx" = "Mexico",
                                               "mg" = "Madagascar",
                                               "kr" = "South Korea",
                                               "ir" = "Iran",
                                               "in" = "India",
                                               "gb" = "Scotland",
                                               "es" = "Spain",
                                               "dk" = "Denmark",
                                               "de" = "Germany",
                                               "co" = "Colombia",
                                               "cn" = "China",
                                               "cl" = "Chile",
                                               "ca" = "Canada",
                                               "br" = "Brazil"))

long.health <- long %>% 
  filter(question == "Short Term")
long.health$Country <- long.health$country

country.data1 <- country.data %>% 
  mutate(country = sub("(.)", "\\U\\1", country, perl=TRUE))

country.data1[country.data1 == "Korea"] <- "South Korea"
country.data1[country.data1 == "Madgascar"] <- "Madagascar"
country.data1[country.data1 == "NewZealand"] <- "New Zealand"





long.RM.Dom <- long %>% 
  filter(question == "Win a Physical Fight")
long.RM.Dom$Country <- long.RM.Dom$country

long.RM.Dom <- dplyr::left_join(long.RM.Dom, country.data1, by = "Country")
long.RM.Dom <- long.RM.Dom %>% 
  filter(RelationalMobility != 0)



#Plot for the effects of Relational Mobility
m19Fig <- conditional_effects(m19, effects = "RelationalMobility", resolution = 1000,
                              spaghetti = T, 
                              nsamples = 100) %>% 
  plot(spaghetti_args = c(colour = "lightblue1")) 
m19Figa <- m19Fig[[1]] + theme_classic() + geom_smooth(method = lm, se = FALSE, color = "skyblue4", size = 3) +
  scale_x_continuous(name="Relational Mobility") +
  scale_y_continuous(name = "Probability of Choosing Masculine Stimuli ")+
  theme_classic(base_family = "serif") + 
  theme(text = element_text(size = 15),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black")) + 
  geom_jitter(data = long.RM.Dom, aes(x = RelationalMobility, y = as.numeric(Mean)), size = 2.5) +
  geom_text_repel(data = long.RM.Dom, aes(x = RelationalMobility, y = as.numeric(Mean), label= Country),inherit.aes = FALSE, size = 2.5) 

m19Figa




long.RM.Pre <- long %>% 
  filter(question == "Respected")
long.RM.Pre$Country <- long.RM.Pre$country

long.RM.Pre <- dplyr::left_join(long.RM.Pre, country.data1, by = "Country")
long.RM.Pre <- long.RM.Pre %>% 
  filter(RelationalMobility != 0)



#Plot for the effects of Relational Mobility on Prestige
m20Fig <- conditional_effects(m20, effects = "RelationalMobility", resolution = 1000,
                              spaghetti = T, 
                              nsamples = 100) %>% 
  plot(spaghetti_args = c(colour = "lightblue1")) 
m20Figa <- m20Fig[[1]] + theme_classic() + geom_smooth(method = lm, se = FALSE, color = "skyblue4", size = 3) +
  scale_x_continuous(name="Relational Mobility") +
  scale_y_continuous(name = "Probability of Choosing Masculine Stimuli ")+
  theme_classic(base_family = "serif") + 
  theme(text = element_text(size = 15),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black")) +
  geom_jitter(data = long.RM.Pre, aes(x = RelationalMobility, y = as.numeric(Mean)), size = 2.5) +
  geom_text_repel(data = long.RM.Pre, aes(x = RelationalMobility, y = as.numeric(Mean), label= Country),inherit.aes = FALSE, size = 2.5,
                  max.overlaps = 15) 

m20Figa




long.RM.Fli <- long %>% 
  filter(question == "Interested in Attracting Men")
long.RM.Fli$Country <- long.RM.Fli$country

long.RM.Fli <- dplyr::left_join(long.RM.Fli, country.data1, by = "Country")
long.RM.Fli <- long.RM.Fli %>% 
  filter(RelationalMobility != 0)

#Plot for the effects of Relational Mobility on Prestige
m23Fig <- conditional_effects(m23, effects = "RelationalMobility", resolution = 1000,
                              spaghetti = T, 
                              nsamples = 100) %>% 
  plot(spaghetti_args = c(colour = "#cd5c5caa")) 
m23Figa <- m23Fig[[1]] + theme_classic() + geom_smooth(method = lm, se = FALSE, color = "firebrick4", size = 3) +
  scale_x_continuous(name="Relational Mobility") +
  scale_y_continuous(name = "Probability of Choosing Masculine Stimuli ")+
  theme_classic(base_family = "serif") + 
  theme(text = element_text(size = 15),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black"))  +
  geom_jitter(data = long.RM.Fli, aes(x = RelationalMobility, y = as.numeric(Mean)), size = 2.5) +
  geom_text_repel(data = long.RM.Fli, aes(x = RelationalMobility, y = as.numeric(Mean), label= Country),inherit.aes = FALSE, size = 2.5,
                  max.overlaps = 25) 
m23Figa






long.Hom.ST <- long %>% 
  filter(question == "Short Term")
long.Hom.ST$Country <- long.Hom.ST$country

long.Hom.ST <- dplyr::left_join(long.Hom.ST, country.data1, by = "Country")






library(ggplot2)
library(dplyr)

#Figure plot
group_cols <- c('country', 'question')
#Make into long_format
long <- newdata2 %>%
  group_by(!!!syms(group_cols)) %>% 
  summarize(Mean = mean(Outcome, na.rm = T))
#Make into two decimal
long$Mean <- as.numeric(format(round(long$Mean, 2)))
#Make into lower fonts
long$country <- tolower(long$country)
long$country <- plyr:: revalue(long$country, c("us" = "USA",
                                               "ug" = "Uganda",
                                               "sv" = "El Salvador",
                                               "sg" = "Singapore",
                                               "pe" = "Peru",
                                               "nz" = "New Zealand",
                                               "nl" = "Netherlands",
                                               "ni" = "Nicaragua",
                                               "mx" = "Mexico",
                                               "mg" = "Madagascar",
                                               "kr" = "South Korea",
                                               "ir" = "Iran",
                                               "in" = "India",
                                               "gb" = "Scotland",
                                               "es" = "Spain",
                                               "dk" = "Denmark",
                                               "de" = "Germany",
                                               "co" = "Colombia",
                                               "cn" = "China",
                                               "cl" = "Chile",
                                               "ca" = "Canada",
                                               "br" = "Brazil"))

library(grid)
library(gridExtra)

a <- ggplot(aes(factor(long$question, level = c("Attractive for a Long Term",
                                                "Attractive for a Short Term",
                                                "Attractive to Men",
                                                "Interested in Attracting Men",
                                                "Long Term",
                                                "Short Term",
                                                "Respected",
                                                "Win a Physical Fight")), long$country, fill= long$Mean), data = long) +
  geom_tile(colour = "black") + theme_minimal() + 
  coord_equal(ratio=0.9)+ geom_text(label = sprintf("%0.2f", round(long$Mean, digits = 2)) , color = "black", size = 3) +
  scale_fill_gradientn(colours = c("hotpink4","hotpink","#FFCCFF", "white", "#00CCFF", "dodgerblue","dodgerblue4"),
                       limits = c(0,1), position = "bottom") +
  ggtitle("") + 
  theme_classic(base_family = "serif") + labs(fill = "Percentage") +
  
  theme(legend.background = element_blank(), text = element_text(family = "serif", size = 12),
        axis.text.y = element_text(hjust = 0),
        axis.text.x = element_text(angle = 45, hjust = 0, colour = c("hotpink","hotpink","hotpink","hotpink","dodgerblue","dodgerblue","dodgerblue","dodgerblue" )),
        axis.title.x=element_blank (),
        axis.title.y=element_blank (),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        axis.line.x = element_blank(),
        axis.line.y = element_blank()) + 
  scale_x_discrete(labels =c("Attractive for a Long Term" = "Long-term Att",
                             "Attractive for a Short Term" = "Short-term Att",
                             "Attractive to Men" = "Att to Men",
                             "Interested in Attracting Men" = "Flirtiousness",
                             "Long Term" = "Long-term Att",
                             "Short Term" = "Short-term Att",
                             "Respected" = "Prestige",
                             "Win a Physical Fight" = "Formidability"), position = "top") +
  scale_y_discrete(limits = rev(unique(sort(long$country)))) 

#Save as seperate Figures for Fig.3
svg(file="Fig19a.svg", width = 3, height = 2.5)
m19Figa
dev.off()

svg(file="Fig20a.svg", width = 3, height = 2.5)
m20Figa
dev.off()

svg(file="Fig23a.svg", width = 3, height = 2.5)
m23Figa
dev.off()



svg(file="Figmean.svg", width = 17, height = 7.5)
a
dev.off()














































#Create the plot of vocalizer sex across questions
#Create the plot of vocalizer sex across questions
sex.emm <- add_grouping((emmeans(m1, "question")), 'Sex', 'question', c("Women","Women", "Women", "Women", "Men", "Men", "Men", "Men"))
#Obtain marginal means and pairwise comparisons
hpd.summary(emmeans(sex.emm, 'Sex'), prob = .89)
hpd.summary(pairs(emmeans(sex.emm, 'Sex'), prob = .89), type = "response")
#Plot these effect of vocalizer sex on masculinized and feminized choices
#Adjust for random effects
#Find random effects sd #Use colnames((as.matrix(m1$fit)))
m1.sigmaA = as.matrix(m1$fit)[,11:16]
m1SDA <- sqrt(apply(m1.sigmaA^2, 1, sum))
sex.rgrd <- regrid(emmeans(sex.emm, 'Sex'), bias.adjust = TRUE, sigma = m1SDA)
#Plot separately for different colors for each sex
#Plot for male voice
color_scheme <- c("skyblue1", "#000000",
                  "skyblue1", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
#Plot for Male Questions
FigSexMale <- bayesplot::mcmc_areas(as.mcmc(sex.rgrd), pars = c("Sex Men"),
                                    prob = .89, point_est = "none") + 
  theme_classic(base_family = "serif")+
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0.1,0.9)) + 
  scale_y_discrete(labels =c("Sex Men" = "Male Voices"))
#Plot for Female Questions
color_scheme <- c("firebrick3", "#000000",
                  "firebrick3", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
FigSexFemale <- bayesplot::mcmc_areas(as.mcmc(sex.rgrd), prob = 0.89, pars = c("Sex Women"), point_est = "none") +
  theme_classic(base_family = "serif")+ 
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0.1,0.9))+ 
  scale_y_discrete(labels =c("Sex Women" = "Female Voices")) + xlab("")
FigSex = FigSexMale / FigSexFemale

FigSex[[1]] = FigSex[[1]] + theme(axis.text.x = element_blank(),
                                  axis.ticks.x = element_blank(),
                                  axis.title.x = element_blank(),
                                  axis.line.x = element_blank(),
                                  axis.text.y = element_text(color = "black"),
                                  axis.ticks.length = unit(0, "pt"),
                                  text = element_text(size = 20),
                                  plot.margin=grid::unit(c(0,0,0,0), "mm")) 
FigSex[[2]] = FigSex[[2]] + theme(text = element_text(size = 20),
                                  axis.text.x = element_text(color = "black"),
                                  axis.text.y = element_text(color = "black"),
                                  plot.margin=grid::unit(c(0,0,0,0), "mm")) 




#Create the plot of perceptual questions
#Adjust for random effects
question.rgrd <- regrid(emmeans(m1, 'question'), bias.adjust = TRUE, sigma = m1SDA)
#Plot separately for different colors for each sex
#Plot for male questions
color_scheme <- c("skyblue1", "#000000",
                  "skyblue1", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
malequestion <- bayesplot::mcmc_areas(as.mcmc(question.rgrd), prob = 0.89,  point_est = "none", pars = c("question Long Term", 
                                                                                                         "question Respected",
                                                                                                         "question Short Term",
                                                                                                         "question Win a Physical Fight"))+
  theme_classic(base_family = "serif") + 
  scale_y_discrete(labels =c("question Long Term" = "Long-term Attractiveness",
                             "question Short Term" = "Short-term Attractiveness",
                             "question Respected" = "Prestige",
                             "question Win a Physical Fight" = "Formidability"),
                   limits=c("question Short Term","question Long Term","question Respected","question Win a Physical Fight")) +
  geom_vline(xintercept = 0.5, linetype = 3) +  scale_x_continuous(limits = c(0.1,0.9))
#Plot for female questions
color_scheme <- c("firebrick3", "#000000",
                  "firebrick3", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
femalequestion <- bayesplot::mcmc_areas(as.mcmc(question.rgrd), prob = 0.89,  point_est = "none", pars = c("question Attractive for a Long Term",
                                                                                                           "question Attractive for a Short Term",
                                                                                                           "question Attractive to Men",
                                                                                                           "question Interested in Attracting Men")) + 
  scale_y_discrete(labels =c("question Attractive for a Long Term" = "Long-term Attractiveness",
                             "question Attractive for a Short Term" = "Short-term Attractiveness",
                             "question Attractive to Men" = "Attractiveness to Men",
                             "question Interested in Attracting Men" = "Flirtatiousness"),
                   limits=c("question Interested in Attracting Men","question Attractive for a Short Term","question Attractive to Men","question Attractive for a Long Term"))+
  theme_classic(base_family = "serif")+  
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0.1,0.9)) +  xlab("")

Figquestion = malequestion / femalequestion

Figquestion[[1]] = Figquestion[[1]] + theme(axis.text.x = element_blank(),
                                            axis.ticks.x = element_blank(),
                                            axis.title.x = element_blank(),
                                            axis.line.x = element_blank(),
                                            axis.text.y = element_text(color = "black"),
                                            axis.ticks.length = unit(0, "pt"),
                                            text = element_text(size = 20),
                                            plot.margin=grid::unit(c(0,0,0,0), "mm"))
Figquestion[[2]] = Figquestion[[2]] + theme(text = element_text(size = 20),
                                            axis.text.y = element_text(color = "black"),
                                            axis.text.x = element_text(color = "black"),
                                            plot.margin=grid::unit(c(0,0,0,0), "mm"))

Figquestion


#Create the plot of manipulated stimulus type
#Adjust for random effects
stimulus.rgrd <- regrid(emmeans(m1, 'Pair'), bias.adjust = TRUE, sigma = m1SDA)
color_scheme <- c("blanchedalmond", "#000000",
                  "blanchedalmond", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Figstimulus <- bayesplot::mcmc_areas(as.mcmc(stimulus.rgrd), prob = 0.89) + 
  scale_y_discrete(labels =c("Pair 1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "Pair 2SD Feminized and Mean" = "2SD Feminized \n and Mean",
                             "Pair 2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean"),
                   limits=c("Pair 2SD Masuclinized and Mean", "Pair 1SD Masuclinized and Feminized", "Pair 2SD Feminized and Mean"))+
  theme_classic(base_family = "serif")+ 
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0.1,0.9)) +  xlab("Probability of Choosing Masculine Stimuli")


Figstimulus = Figstimulus + theme(text = element_text(size = 20),
                                  axis.text.y = element_text(color = "black"),
                                  axis.text.x = element_text(color = "black"),
                                  plot.margin=grid::unit(c(0,0,0,0), "mm"))

#Create the plot of perceptual question across manipulated stimulus type
#Adjust for random effects
percstimulus.rgrd <- regrid(emmeans(m1,'question','Pair'), bias.adjust = TRUE, sigma = m1SDA)
percstimulus.data <- emmip(percstimulus.rgrd, question ~ Pair , CIs = TRUE, plotit = F)
Figps <- as.data.frame(percstimulus.data)
levels(Figps$question) <- c("Long-term Attractiveness", "Short-term Attractiveness", "Attractiveness to Men", "Flirtatiousness",
                            "Long-termAttractiveness ", "Prestige", "Short-term Attractiveness ", "Formidability")

Figps$Perception <- ordered(Figps$question, levels = c("Long-termAttractiveness ", "Short-term Attractiveness ", "Prestige", "Formidability",
                                                       "Long-term Attractiveness", "Short-term Attractiveness", "Attractiveness to Men", "Flirtatiousness"))

Figps <- ggplot(Figps, aes(xvar, yvar, group = Perception)) + geom_line(aes(color = Perception, linetype = Perception), position = position_dodge(width = 0.4))+ 
  geom_point(aes(color = Perception), size = 3, position=position_dodge(.4))+
  geom_point(aes(shape = Perception), size = 5, position=position_dodge(.4))+
  scale_color_manual(values=c("skyblue1","skyblue1","skyblue1","skyblue1","firebrick3", "firebrick3", "firebrick3","firebrick3"))+
  scale_fill_manual(values=c("skyblue1","skyblue1","skyblue1","skyblue1","firebrick3", "firebrick3", "firebrick3","firebrick3"))+
  geom_linerange(aes(ymin=LCL, ymax=UCL), width=.2, fill = NULL, 
                 position=position_dodge(.4)) +
  scale_shape_manual(values = c(0:8))+
  theme_classic(base_family = "serif") +
  scale_x_discrete(labels =c("2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean",
                             "1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "2SD Feminized and Mean" = "2SD Feminized \n and Mean"),
                   limits=c("2SD Masuclinized and Mean", "1SD Masuclinized and Feminized", "2SD Feminized and Mean")) +  ylab("Probability of Choosing Masculine Stimuli") +  
  xlab("Stimulus Pair") +
  guides(fill=guide_legend(
    keywidth=0.05,
    keyheight=0.05,
    default.unit="cm")
  )

Figps = Figps + theme(text = element_text(size = 20),
                      axis.text.y = element_text(color = "black"),
                      axis.text.x = element_text(color = "black"),
                      legend.key.size = unit(0.05, "mm"),
                      legend.spacing = unit(0.05, "mm"),
                      legend.title = element_blank(),
                      legend.text = element_text(size = 10),
                      legend.position = 'top',
                      legend.background = element_rect(fill = "white", color = "black"),
                      plot.margin=grid::unit(c(0,0,0,0), "mm")) + geom_hline(yintercept = 0.5, linetype = "dotted")
Figps

Figmain <- ((FigSex / Figquestion / Figstimulus ) + plot_layout(heights = c(1, 1, 3, 2)) | (Figps + theme(plot.margin = unit(c(0,0,0,5), "pt")))) + 
  plot_layout(widths = c(1, 1.5)) 
svg(file="Figmain.svg", width = 15.5, height = 9)
Figmain
dev.off()











#Creat Supplementary Figure
#Plot for the effects of age & perception for male judging male voices
ageMen<- conditional_effects(m61, effects = "age:question", resolution = 1000,
                             spaghetti = T, 
                             nsamples = 100)[1]
ageMen <- as.data.frame(ageMen)
ageMenFig <- ggplot(ageMen, aes(x = as.numeric(age.question.age), y = as.numeric(age.question.estimate__))) +theme_classic() +
  geom_smooth(aes(group = age.question.question, color = age.question.question),method = "lm", size = 3) +
  scale_x_continuous(lim = c(15,40), breaks = seq(15,40,5),name="Age") +
  scale_y_continuous(lim = c(0.6,0.75), breaks = seq(0.6,0.75,0.02), name = "Probability of Choosing Masculine Stimuli")+
  labs(color = "Perception") +
  theme_classic(base_family = "serif") + 
  theme(text = element_text(size = 15), legend.position="top",
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black")) + scale_color_manual(labels = c("Prestige", "Formidability"), values = c("lightsteelblue4", "dodgerblue4")) 

ageMen1<- conditional_effects(m70, effects = "age:question", resolution = 1000,
                              spaghetti = T, 
                              nsamples = 100)[1]
ageMen1 <- as.data.frame(ageMen1)
ageMenFig1 <- ggplot(ageMen1, aes(x = as.numeric(age.question.age), y = as.numeric(age.question.estimate__))) +theme_classic() +
  geom_smooth(aes(group = age.question.question, color = age.question.question),method = "lm", size = 3) +
  scale_x_continuous(name="Age") +
  scale_y_continuous(lim = c(0.5,0.75), breaks = seq(0.5,0.75,0.05), name = "Probability of Choosing Masculine Stimuli")+
  labs(color = "Perception") +
  theme_classic(base_family = "serif") + 
  theme(text = element_text(size = 15), legend.position="top",
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black")) + scale_color_manual(labels = c("Prestige", "Formidability"), values = c("lightsteelblue4", "dodgerblue4")) 




#Plot for the effects of homicide & perception for female judging male voices on attractiveness
homicideWomen<- conditional_effects(m62, effects = "Homicide:question", resolution = 1000,
                                    spaghetti = T, 
                                    nsamples = 100)[1]
homicideWomen <- as.data.frame(homicideWomen)
homicideWomenFig <- ggplot(homicideWomen, aes(x = as.numeric(Homicide.question.Homicide), y = as.numeric(Homicide.question.estimate__))) +theme_classic() +
  geom_smooth(aes(group = Homicide.question.question, color = Homicide.question.question),method = "lm", size = 3.5) +
  scale_x_continuous(lim = c(-1,3.5), breaks = seq(-1,3.5,.5),name="Homicide Rates") +
  scale_y_continuous(lim = c(0.56,0.68), breaks = seq(0.56,0.68,0.02), name = "Probability of Choosing Masculine Stimuli")+
  labs(color = "Perception") +
  theme_classic(base_family = "serif") + 
  theme(text = element_text(size = 15), legend.position="top",
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black")) + scale_color_manual(labels = c("Long-term Attractiveness","Short-term Attractiveness"), values = c("dimgray", "blue4")) 

svg(file="FigS1.svg", width = 15, height = 5)
ageMenFig + ageMenFig1 + homicideWomenFig
dev.off()




















#Create Figure S2.
#Create post-hoc comparison plots for perceptual questions
#Create post-hoc comparison plots for perceptual questions
posthocquestion.rgrd <- pairs(emmeans(m1, 'question'), type = "response")
#Plot separately for different colors for each sex
#Plot for male questions
color_scheme <- c("#1E90FF", "#000000",
                  "#1E90FF", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
posthocquestion <- as.data.frame(hpd.summary(pairs(emmeans(m1, 'question')), type = "response"))
#require ggtext
posthoc <- ggplot(posthocquestion, aes(y = contrast, x = odds.ratio)) + geom_point() + geom_pointrange(xmin =  posthocquestion$lower.HPD, xmax =  posthocquestion$upper.HPD)+
  scale_y_discrete(labels =c("Attractive for a Long Term / Attractive for a Short Term" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Short-term Attractiveness</span>",
                             "Attractive for a Long Term / Attractive to Men" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Attractiveness to Men</span>",
                             "Attractive for a Long Term / Interested in Attracting Men" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Flirtatiousness</span>",
                             "Attractive for a Long Term / Long Term" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Long-term Attractiveness</span>",
                             "Attractive for a Long Term / Respected" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Prestige</span>",
                             "Attractive for a Long Term / Short Term" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Attractive for a Long Term / Win a Physical Fight" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Attractive for a Short Term / Attractive to Men" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Attractiveness to Men</span>",
                             "Attractive for a Short Term / Interested in Attracting Men" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Flirtatiousness</span>",
                             "Attractive for a Short Term / Long Term" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Long-term Attractiveness</span>",
                             "Attractive for a Short Term / Respected" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Prestige</span>",
                             "Attractive for a Short Term / Short Term" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Attractive for a Short Term / Win a Physical Fight" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Attractive to Men / Interested in Attracting Men" = "<span style='color:hotpink'>Attractiveness to Men</span><span style='color:black'> / </span><span style='color:hotpink'>Flirtatiousness</span>",
                             "Attractive to Men / Long Term" = "<span style='color:hotpink'>Attractiveness to Men</span><span style='color:black'> / </span><span style='color:dodgerblue'>Long-term Attractiveness</span>",
                             "Attractive to Men / Respected" = "<span style='color:hotpink'>Attractiveness to Men</span><span style='color:black'> / </span><span style='color:dodgerblue'>Prestige</span>",
                             "Attractive to Men / Short Term" = "<span style='color:hotpink'>Attractiveness to Men</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Attractive to Men / Win a Physical Fight" = "<span style='color:hotpink'>Attractiveness to Men</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Interested in Attracting Men / Long Term" = "<span style='color:hotpink'>Flirtatiousness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Long-term Attractiveness</span>",
                             "Interested in Attracting Men / Respected" = "<span style='color:hotpink'>Flirtatiousness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Prestige</span>",
                             "Interested in Attracting Men / Short Term" = "<span style='color:hotpink'>Flirtatiousness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Interested in Attracting Men / Win a Physical Fight" = "<span style='color:hotpink'>Flirtatiousness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Long Term / Respected" = "<span style='color:dodgerblue'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Prestige</span>",
                             "Long Term / Short Term" = "<span style='color:dodgerblue'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Long Term / Win a Physical Fight" = "<span style='color:dodgerblue'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Respected / Short Term" = "<span style='color:dodgerblue'>Prestige</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Respected / Win a Physical Fight" = "<span style='color:dodgerblue'>Prestige</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Short Term / Win a Physical Fight" = "<span style='color:dodgerblue'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>"),
                   limits=c("Interested in Attracting Men / Win a Physical Fight","Attractive for a Short Term / Win a Physical Fight","Interested in Attracting Men / Respected","Interested in Attracting Men / Long Term","Attractive for a Short Term / Respected","Attractive for a Short Term / Long Term","Attractive to Men / Win a Physical Fight","Attractive to Men / Respected","Interested in Attracting Men / Short Term","Attractive for a Short Term / Short Term","Attractive to Men / Long Term","Attractive to Men / Short Term","Attractive for a Long Term / Win a Physical Fight","Attractive for a Long Term / Respected","Short Term / Win a Physical Fight","Attractive for a Long Term / Long Term","Attractive for a Short Term / Attractive to Men","Long Term / Win a Physical Fight","Attractive for a Long Term / Short Term","Respected / Win a Physical Fight","Long Term / Respected","Attractive for a Short Term / Interested in Attracting Men","Long Term / Short Term","Attractive to Men / Interested in Attracting Men","Respected / Short Term","Attractive for a Long Term / Attractive to Men","Attractive for a Long Term / Attractive for a Short Term","Attractive for a Long Term / Interested in Attracting Men")) + 
  theme(axis.text.y = element_markdown(angle = 0)) + 
  geom_vline(xintercept = 1, linetype = 3) +  scale_x_continuous(limits = c(0,2.5)) + 
  ylab('') + xlab('Masculine Stimuli Choice Differences (Odds Ratio)') +
  theme(text = element_text(size = 25, family = "serif"),panel.background = element_blank(),
        axis.line.x = element_line(size = 1, colour = "black", linetype=1),
        axis.line.y = element_line(size = 1, colour = "black", linetype=1),
        plot.margin=grid::unit(c(0,0,0,0), "mm")) 

svg(file="Figposthoc.svg", width = 15, height = 9)
posthoc
dev.off()




























#Create Figure S3.
conditional_effects(m66)
Tell_dif <- conditional_effects(m66, prob = 0.89, robust = T, effects = "Tell_dif")
Tell_dif1 <- plot(Tell_dif, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(labels= c("Always", "Sometimes", "Never"),
                                                                                     name="Heard a Difference between the Two Voices") +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Male Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black")) 

Language <- conditional_effects(m66, prob = 0.89, robust = T, effects = "first_language")
Language1 <- plot(Language, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(name="First Language") +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Male Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, color = "black"),
        axis.text.y = element_text(color = "black")) 

Heard <- conditional_effects(m66, prob = 0.89, robust = T, effects = "heard")
Heard1 <- plot(Heard, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(name="Heard the Recordings Clearly", labels = c("No", "Yes")) +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Male Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black")) 

Understood <- conditional_effects(m66, prob = 0.89, robust = T, effects = "Understood")
Understood1 <- plot(Understood, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(name="Understood What Was Said in the Recordings", labels = c("No", "Yes")) +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Male Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black")) 
#Combine figures
library(patchwork)
svg(file="FigMale.svg", width = 15, height = 9)
(Understood1 + Heard1 + Tell_dif1)/ Language1 
dev.off()





















#Create Figure S4.
#Create Figures for female voices
Tell_dif2 <- conditional_effects(m67, prob = 0.89, robust = T, effects = "Tell_dif")
Tell_dif3 <- plot(Tell_dif2, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(labels= c("Always", "Sometimes", "Never"),
                                                                                      name="Heard a Difference between the Two Voices") +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Female Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black")) 

Language2 <- conditional_effects(m67, prob = 0.89, robust = T, effects = "first_language")
Language3 <- plot(Language2, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(name="First Language") +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Female Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, color = "black"),
        axis.text.y = element_text(color = "black")) 

Heard2 <- conditional_effects(m67, prob = 0.89, robust = T, effects = "heard")
Heard3 <- plot(Heard2, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(name="Heard the Recordings Clearly", labels = c("No", "Yes")) +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Female Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black")) 

Understood2 <- conditional_effects(m67, prob = 0.89, robust = T, effects = "Understood")
Understood3 <- plot(Understood2, plot = FALSE)[[1]] +  theme_classic() + scale_x_discrete(name="Understood What Was Said in the Recordings", labels = c("No", "Yes")) +
  scale_y_continuous(lim = c(0,1), breaks = seq(0,1,0.2), name = "Probability of Choosing Masculine Stimuli \n for Female Voices")+
  theme_classic(base_family = "serif") + geom_hline(yintercept = 0.5, linetype = 3)+
  theme(text = element_text(size = 15),axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black")) 
#Combine figures
svg(file="FigFemale.svg", width = 15, height = 9)
(Understood3 + Heard3 + Tell_dif3)/ Language3
dev.off()









#Create Fig. S5
#Plot for masculinized preferences across questions related to male voices
#Adjust for random effects
#Plot for masculinized preferences across questions related to male voices
#Adjust for random effects
model.sigmaB = as.matrix(malem1$fit)[,7:12]
totSDB <- sqrt(apply(model.sigmaB^2, 1, sum))
#Plot for question
model.rgrdb <- regrid(b, bias.adjust = TRUE, sigma = totSDB)
#Plot for male voice
color_scheme <- c("skyblue1", "#000000",
                  "skyblue1", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Fig2b <- bayesplot::mcmc_areas(as.mcmc(model.rgrdb), prob = 0.89, point_est = "none", 
                               pars = c("question Long Term", 
                                        "question Respected",
                                        "question Short Term",
                                        "question Win a Physical Fight")) + 
  xlab("Probability of Choosing Masculine Stimuli") +
  theme_classic(base_family = "serif") + 
  scale_y_discrete(labels =c("question Long Term" = "Long-term Attractiveness",
                             "question Short Term" = "Short-term Attractiveness",
                             "question Respected" = "Prestige",
                             "question Win a Physical Fight" = "Dominance"),
                   limits=c("question Short Term","question Long Term","question Respected","question Win a Physical Fight")) + 
  geom_vline(xintercept = 0.5, linetype = 2) +  scale_x_continuous(limits = c(-0.5,1.5)) + theme(text = element_text(size = 20),
                                                                                                 axis.text.y = element_text(color = "black"),
                                                                                                 axis.text.x = element_text(color = "black"),
                                                                                                 plot.margin=grid::unit(c(0,0,0,0), "mm"),
                                                                                                 axis.ticks.length = unit(0, "pt"))



#Plot for masculinized preferences across Pairs related to male voices
#Adjust for random effects
#Plot for masculinized preferences across Pairs related to male voices
#Adjust for random effects
model.rgrdb1b <- regrid(b1a, bias.adjust = TRUE, sigma = totSDB)
#Plot for Pairs
color_scheme <- c("lightblue", "#000000",
                  "lightblue", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Fig2d <- bayesplot::mcmc_areas(as.mcmc(model.rgrdb1b), prob = 0.89, point_est = "none") +
  scale_y_discrete(labels =c("Pair 1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "Pair 2SD Feminized and Mean" = "2SD Feminized \n and Mean",
                             "Pair 2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean"),
                   limits=c("Pair 2SD Masuclinized and Mean", "Pair 1SD Masuclinized and Feminized", "Pair 2SD Feminized and Mean"))+
  theme_classic(base_family = "serif")+ 
  geom_vline(xintercept = 0.5, linetype = 2) + scale_x_continuous(limits = c(0.2,0.9)) +  
  xlab("Probability of Choosing Masculine Stimuli") +
  theme(text = element_text(size = 20), axis.ticks.length = unit(0, "pt"),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black"),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))

#Plot for Questions and Pairs for Male Voices
#Adjust for random effects
model.rgrdb1c <- regrid(b1c, bias.adjust = TRUE, sigma = totSDB)
f1 <- as.data.frame(emmip(model.rgrdb1c, question ~ Pair , CIs = TRUE, plotit = F))
Fig2f <- as.data.frame(f1)
levels(Fig2f$question) <- c("Long-term Attractiveness ", "Prestige", "Short-term Attractiveness ", "Dominance")
Fig2f$Perception <- ordered(Fig2f$question, levels = c("Long-term Attractiveness ", "Short-term Attractiveness ", "Prestige", "Dominance"))

Fig2f <- ggplot(Fig2f, aes(xvar, yvar, group = Perception)) + geom_line(aes(color = Perception, linetype = Perception), position = position_dodge(width = 0.2))+ 
  geom_point(aes(color = Perception), size = 3, position=position_dodge(.2))+
  geom_point(aes(shape=Perception), size = 5, position=position_dodge(.2))+
  geom_linerange(aes(ymin=LCL, ymax=UCL), width=.2,
                 position=position_dodge(.2)) +
  scale_color_manual(values=c("skyblue1","skyblue1","skyblue1","skyblue1"))+
  scale_y_continuous(limits = c(0.2,0.85)) + 
  scale_shape_manual(values = c(0:8))+
  theme_classic(base_family = "serif") +
  scale_x_discrete(labels =c("2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean",
                             "1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "2SD Feminized and Mean" = "2SD Feminized \n and Mean"),
                   limits=c("2SD Masuclinized and Mean", "1SD Masuclinized and Feminized", "2SD Feminized and Mean")) +  ylab("Probability of Choosing Masculine Stimuli") +  xlab("Stimulus Pair") +
  guides(color =guide_legend(nrow=2,byrow=TRUE)) + 
  ylab("Probability of Choosing Masculine Stimuli") +
  geom_hline(yintercept = 0.5, linetype = 3) +
  theme(text = element_text(size = 20),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black"),
        legend.key.size = unit(0.05, "mm"),
        legend.spacing = unit(0.05, "mm"),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        legend.position = 'top',
        legend.background = element_rect(fill = "white", color = "black"),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))  

#Plot for masculinized preferences across female voices
#Adjust for random effects
model.sigmaC = as.matrix(femalem1$fit)[,7:12]
totSDC <- sqrt(apply(model.sigmaC^2, 1, sum))
#Plot for question
model.rgrdc <- regrid(c, bias.adjust = TRUE, sigma = totSDC)
#Plot for female voice
color_scheme <- c("firebrick3", "#000000",
                  "firebrick3", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Fig2c <- bayesplot::mcmc_areas(as.mcmc(model.rgrdc), prob = 0.89,
                               point_est = "none", 
                               pars = c("question Attractive for a Long Term",
                                        "question Attractive for a Short Term",
                                        "question Attractive to Men",
                                        "question Interested in Attracting Men")) + 
  theme_classic(base_family = "serif") + 
  xlab("Probability of Choosing Masculine Stimuli") +
  scale_y_discrete(labels =c("question Attractive for a Long Term" = "Long-term Attractiveness",
                             "question Attractive for a Short Term" = "Short-term Attractiveness",
                             "question Attractive to Men" = "Attractiveness to Men",
                             "question Interested in Attracting Men" = "Flirtatiousness"),
                   limits=c("question Interested in Attracting Men",
                            "question Attractive for a Short Term",
                            "question Attractive to Men",
                            "question Attractive for a Long Term")) + 
  geom_vline(xintercept = 0.5, linetype = 2) +  scale_x_continuous(limits = c(0.2,0.9)) + theme(text = element_text(size = 20),
                                                                                                axis.text.y = element_text(color = "black"),
                                                                                                axis.text.x = element_text(color = "black"),
                                                                                                plot.margin=grid::unit(c(0,0,0,0), "mm"),axis.ticks.length = unit(0, "pt"))

#Plot for masculinized preferences across Pairs related to female voices
#Adjust for random effects
model.rgrdc2 <- regrid(c2, bias.adjust = TRUE, sigma = totSDC)
#Plot for Pairs
color_scheme <- c("indianred", "#000000",
                  "indianred", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Fig2e <- bayesplot::mcmc_areas(as.mcmc(model.rgrdc2), prob = 0.89,
                               point_est = "none") +
  scale_y_discrete(labels =c("Pair 1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "Pair 2SD Feminized and Mean" = "2SD Feminized \n and Mean",
                             "Pair 2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean"),
                   limits=c("Pair 2SD Masuclinized and Mean", "Pair 1SD Masuclinized and Feminized", "Pair 2SD Feminized and Mean"))+
  theme_classic(base_family = "serif")+ 
  geom_vline(xintercept = 0.5, linetype = 2) + scale_x_continuous(limits = c(0.2,0.9)) +  
  xlab("Probability of Choosing Masculine Stimuli") + theme(text = element_text(size = 20),
                                                            axis.text.y = element_text(color = "black"),
                                                            axis.text.x = element_text(color = "black"),
                                                            plot.margin=grid::unit(c(0,0,0,0), "mm"),
                                                            axis.ticks.length = unit(0, "pt"))






#Plot for Questions and Pairs for Female Voices
c4 <- (emmeans(femalem1, 'question', 'Pair'))
hpd.summary(c4, prob = .89)
#Adjust for random effects
model.rgrdc4 <- regrid(c4, bias.adjust = TRUE, sigma = totSDC)
g1 <- as.data.frame(emmip(model.rgrdc4, question ~ Pair , CIs = TRUE, plotit = F))
Fig2g <- as.data.frame(g1)
levels(Fig2g$question) <- c("Long-term Attractiveness ", "Short-term Attractiveness ", "Attractiveness to Men", "Flirtatiousness")
Fig2g$Perception <- Fig2g$question

Fig2g <- ggplot(Fig2g, aes(xvar, yvar, group = Perception)) + geom_line(aes(color = Perception, linetype = Perception), position = position_dodge(width = 0.2))+ 
  geom_point(aes(color = Perception), size = 3, position=position_dodge(.2))+
  geom_point(aes(shape=Perception), size = 5, position=position_dodge(.2))+
  geom_linerange(aes(ymin=LCL, ymax=UCL), width=.2,
                 position=position_dodge(.2)) +
  scale_y_continuous(limits = c(0.2,0.85)) + 
  scale_color_manual(values=c("firebrick3", "firebrick3", "firebrick3","firebrick3"))+
  scale_shape_manual(values = c(5:8))+
  theme_classic(base_family = "serif") +
  scale_x_discrete(labels =c("2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean",
                             "1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "2SD Feminized and Mean" = "2SD Feminized \n and Mean"),
                   limits=c("2SD Masuclinized and Mean", "1SD Masuclinized and Feminized", "2SD Feminized and Mean")) +  xlab("Stimulus Pair") +
  guides(color =guide_legend(nrow=2,byrow=TRUE)) + 
  geom_hline(yintercept = 0.5, linetype = 3) +
  ylab("Probability of Choosing Masculine Stimuli") +
  theme(text = element_text(size = 20),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black"),
        legend.key.size = unit(0.05, "mm"),
        legend.spacing = unit(0.05, "mm"),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        legend.position = 'top',
        legend.background = element_rect(fill = "white", color = "black"),
        plot.margin=grid::unit(c(0,0,0,0), "mm"))  





#Plot for masculinized preferences across male and female voices
#Adjust for random effects
#Plot for masculinized preferences across male and female voices
#Adjust for random effects
model.sigmals = as.matrix(longshortm1$fit)[,7:12]
totSDls <- sqrt(apply(model.sigmals^2, 1, sum))
#Plot for question
model.rgrdls <- regrid(ls1, bias.adjust = TRUE, sigma = totSDls)

#Plot for male voice
color_scheme <- c("skyblue1", "#000000",
                  "skyblue1", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Fig3a1 <- bayesplot::mcmc_areas(as.mcmc(model.rgrdls), prob = 0.89,
                                point_est = "none", 
                                pars = c("question Long Term",
                                         "question Short Term")) + 
  theme_classic(base_family = "serif") + 
  xlab("Probability of Masculinized Preferences") +
  scale_y_discrete(labels =c("question Long Term" = "Long-term Attractiveness",
                             "question Short Term" = "Short-term Attractiveness"),
                   limits=c("question Short Term",
                            "question Long Term")) + 
  geom_vline(xintercept = 0.5, linetype = 2) +  scale_x_continuous(limits = c(0.2,0.9)) 
#Plot for female voice
color_scheme <- c("firebrick3", "#000000",
                  "firebrick3", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Fig3a2 <- bayesplot::mcmc_areas(as.mcmc(model.rgrdls), prob = 0.89,
                                point_est = "none", 
                                pars = c("question Attractive for a Long Term",
                                         "question Attractive for a Short Term")) + 
  theme_classic(base_family = "serif") + 
  xlab("Probability of Choosing Masculine Stimuli") +
  scale_y_discrete(labels =c("question Attractive for a Long Term" = "Long-term Attractiveness",
                             "question Attractive for a Short Term" = "Short-term Attractiveness"),
                   limits=c("question Attractive for a Short Term",
                            "question Attractive for a Long Term")) + 
  geom_vline(xintercept = 0.5, linetype = 2) +  scale_x_continuous(limits = c(0.2,0.9)) 


Fig3a = Fig3a1 / Fig3a2

Fig3a[[1]] = Fig3a[[1]] + theme(axis.text.x = element_blank(),
                                axis.ticks.x = element_blank(),
                                axis.title.x = element_blank(),
                                axis.line.x = element_blank(),
                                axis.text.y = element_text(color = "black"),
                                axis.ticks.length = unit(0, "pt"),
                                text = element_text(size = 20),
                                plot.margin=grid::unit(c(0,0,0,0), "mm")) 
Fig3a[[2]] = Fig3a[[2]] + theme(text = element_text(size = 20),
                                axis.text.x = element_text(color = "black"),
                                axis.text.y = element_text(color = "black"),
                                axis.ticks.length = unit(0, "pt"),
                                plot.margin=grid::unit(c(0,0,0,0), "mm"))
Fig3a

#Plot for masculinized preferences across Pairs related to male and female voices
#Adjust for random effects
model.rgrdls3 <- regrid(ls3, bias.adjust = TRUE, sigma = totSDls)
#Plot for Pairs
color_scheme <- c("gray", "#000000",
                  "gray", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Fig3b <- bayesplot::mcmc_areas(as.mcmc(model.rgrdls3), prob = 0.89,
                               point_est = "none") +
  scale_y_discrete(labels =c("Pair 1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "Pair 2SD Feminized and Mean" = "2SD Feminized \n and Mean",
                             "Pair 2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean"),
                   limits=c("Pair 2SD Masuclinized and Mean", "Pair 1SD Masuclinized and Feminized", "Pair 2SD Feminized and Mean"))+
  theme_classic(base_family = "serif")+ 
  geom_vline(xintercept = 0.5, linetype = 2) + scale_x_continuous(limits = c(0.2,0.9)) +  
  xlab("Probability of Choosing Masculine Stimuli") + theme(text = element_text(size = 20),
                                                            axis.text.y = element_text(color = "black"),
                                                            axis.text.x = element_text(color = "black"),
                                                            plot.margin=grid::unit(c(0,0,0,0), "mm"),
                                                            axis.ticks.length = unit(0, "pt"))


#Plot for Questions and Pairs for Male and Female Voices
#Adjust for random effects
model.rgrdls5 <- regrid(ls5, bias.adjust = TRUE, sigma = totSDls)
h1 <- as.data.frame(emmip(model.rgrdls5, question ~ Pair , CIs = TRUE, plotit = F))
Fig3c <- as.data.frame(h1)
levels(Fig3c$question) <- c("Long-term Attractiveness", "Short-term Attractiveness", "Long-term Attractiveness ", "Short-term Attractiveness ")
Fig3c$Perception <- Fig3c$question 



Fig3c <- ggplot(Fig3c, aes(xvar, yvar, group = Perception)) + geom_line(aes(color = Perception, linetype = Perception), position = position_dodge(width = 0.2))+ 
  geom_point(aes(color = Perception), size = 3, position=position_dodge(.2))+
  geom_point(aes(shape=Perception), size = 5, position=position_dodge(.2))+
  geom_linerange(aes(ymin=LCL, ymax=UCL), width=.2,
                 position=position_dodge(.2)) +
  scale_y_continuous(limits = c(0.2,0.85)) + 
  scale_color_manual(values=c("firebrick3","firebrick3","skyblue1", "skyblue1"))+
  scale_shape_manual(values = c(5,6,0,1))+
  theme_classic(base_family = "serif") +
  scale_x_discrete(labels =c("2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean",
                             "1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "2SD Feminized and Mean" = "2SD Feminized \n and Mean"),
                   limits=c("2SD Masuclinized and Mean", "1SD Masuclinized and Feminized", "2SD Feminized and Mean")) +  xlab("Stimulus Pair") +
  guides(color =guide_legend(nrow=2,byrow=TRUE)) + 
  ylab("Probability of Choosing Masculine Stimuli") +
  geom_hline(yintercept = 0.5, linetype = 3) +
  theme(text = element_text(size = 20),
        axis.text.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black"),
        legend.key.size = unit(0.05, "mm"),
        legend.spacing = unit(0.05, "mm"),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        legend.position = 'top',
        legend.background = element_rect(fill = "white", color = "black"),
        plot.margin=grid::unit(c(0,0,0,0), "mm")) 
Fig3c

#Create Seperate Figures for Fig. S5 in the manuscript

Fig3c <- (Fig3a + plot_layout(heights = c(1, 1))| Fig3b | Fig3c)  + plot_layout(widths = c(1,1,1.5))  
svg(file="Fig3c.svg", width = 22, height = 6)
Fig3c 
dev.off()


Fig3b <- (Fig2c | Fig2e | Fig2g) + plot_layout(widths = c(1,1,1.5)) 
svg(file="Fig3b.svg", width = 22, height = 6)
Fig3b
dev.off()

Fig3a <- (Fig2b | Fig2d | Fig2f) + plot_layout(widths = c(1,1,1.5)) 
svg(file="Fig3a.svg", width = 22, height = 6)
Fig3a
dev.off()
















#Create Fig. S6
posthocquestion1 <- as.data.frame(hpd.summary(pairs(emmeans(malem1, 'question')), type = "response"))
#require ggtext
posthoc1 <- ggplot(posthocquestion1, aes(y = contrast, x = odds.ratio)) + geom_point() + geom_pointrange(xmin =  posthocquestion1$lower.HPD, xmax =  posthocquestion1$upper.HPD)+
  scale_y_discrete(labels =c("Long Term / Respected" = "<span style='color:dodgerblue'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Prestige</span>",
                             "Long Term / Short Term" = "<span style='color:dodgerblue'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Long Term / Win a Physical Fight" = "<span style='color:dodgerblue'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Respected / Short Term" = "<span style='color:dodgerblue'>Prestige</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Respected / Win a Physical Fight" = "<span style='color:dodgerblue'>Prestige</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>",
                             "Short Term / Win a Physical Fight" = "<span style='color:dodgerblue'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Dominance</span>"),
                   limits=c("Short Term / Win a Physical Fight","Long Term / Win a Physical Fight","Long Term / Respected","Respected / Win a Physical Fight","Long Term / Short Term","Respected / Short Term")) + 
  theme(axis.text.y = element_markdown(angle = 0)) + 
  geom_vline(xintercept = 1, linetype = 3) +  scale_x_continuous(limits = c(0,2.5)) + 
  ylab('') + xlab(' ') +
  theme(text = element_text(size = 25, family = "serif"),panel.background = element_blank(),
        axis.line.x = element_line(size = 1, colour = "black", linetype=1),
        axis.line.y = element_line(size = 1, colour = "black", linetype=1),
        plot.margin=grid::unit(c(0,0,0,0), "mm")) 


posthocquestion2 <- as.data.frame(hpd.summary(pairs(emmeans(femalem1, 'question')), type = "response"))
#require ggtext
posthoc2 <- ggplot(posthocquestion2, aes(y = contrast, x = odds.ratio)) + geom_point() + geom_pointrange(xmin =  posthocquestion2$lower.HPD, xmax =  posthocquestion2$upper.HPD)+
  scale_y_discrete(labels =c("Attractive for a Long Term / Attractive for a Short Term" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Short-term Attractiveness</span>",
                             "Attractive for a Long Term / Attractive to Men" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Attractiveness to Men</span>",
                             "Attractive for a Long Term / Interested in Attracting Men" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Flirtatiousness</span>",
                             "Attractive for a Short Term / Attractive to Men" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Attractiveness to Men</span>",
                             "Attractive for a Short Term / Interested in Attracting Men" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Flirtatiousness</span>",
                             "Attractive to Men / Interested in Attracting Men" = "<span style='color:hotpink'>Attractiveness to Men</span><span style='color:black'> / </span><span style='color:hotpink'>Flirtatiousness</span>"),
                   limits=c("Attractive for a Short Term / Attractive to Men","Attractive for a Short Term / Interested in Attracting Men","Attractive to Men / Interested in Attracting Men","Attractive for a Long Term / Attractive to Men","Attractive for a Long Term / Attractive for a Short Term","Attractive for a Long Term / Interested in Attracting Men")) + 
  theme(axis.text.y = element_markdown(angle = 0)) + xlab(' ') + ylab('') +
  geom_vline(xintercept = 1, linetype = 3) +  scale_x_continuous(limits = c(0,2.5)) + 
  theme(text = element_text(size = 25, family = "serif"),panel.background = element_blank(),
        axis.line.x = element_line(size = 1, colour = "black", linetype=1),
        axis.line.y = element_line(size = 1, colour = "black", linetype=1),
        plot.margin=grid::unit(c(0,0,0,0), "mm")) 

posthocquestion3 <- as.data.frame(hpd.summary(pairs(emmeans(longshortm1, 'question')), type = "response"))
#require ggtext
posthoc3 <- ggplot(posthocquestion3, aes(y = contrast, x = odds.ratio)) + geom_point() + geom_pointrange(xmin =  posthocquestion3$lower.HPD, xmax =  posthocquestion3$upper.HPD)+
  scale_y_discrete(labels =c("Attractive for a Long Term / Attractive for a Short Term" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:hotpink'>Short-term Attractiveness</span>",
                             "Attractive for a Long Term / Long Term" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Long-term Attractiveness</span>",
                             "Attractive for a Long Term / Short Term" = "<span style='color:hotpink'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Attractive for a Short Term / Long Term" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Long-term Attractiveness</span>",
                             "Attractive for a Short Term / Short Term" = "<span style='color:hotpink'>Short-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>",
                             "Long Term / Short Term" = "<span style='color:dodgerblue'>Long-term Attractiveness</span><span style='color:black'> / </span><span style='color:dodgerblue'>Short-term Attractiveness</span>"),
                   limits=c("Attractive for a Short Term / Long Term","Attractive for a Short Term / Short Term","Attractive for a Long Term / Long Term","Attractive for a Long Term / Short Term","Long Term / Short Term","Attractive for a Long Term / Attractive for a Short Term")) + 
  theme(axis.text.y = element_markdown(angle = 0)) + 
  geom_vline(xintercept = 1, linetype = 3) +  scale_x_continuous(limits = c(0,2.5)) + 
  ylab('') + xlab('Masculine Stimuli Choice Differences (Odds Ratio)') +
  theme(text = element_text(size = 25, family = "serif"),panel.background = element_blank(),
        axis.line.x = element_line(size = 1, colour = "black", linetype=1),
        axis.line.y = element_line(size = 1, colour = "black", linetype=1),
        plot.margin=grid::unit(c(0,0,0,0), "mm")) 
posthoc3


Figposthoc123 <- (posthoc1 / posthoc2 / posthoc3) +  plot_annotation(tag_levels = 'A')
svg(file="Figposthoc123.svg", width = 15.5, height = 9)
Figposthoc123
dev.off()















#Create Fig. 5.
#Create the plot of vocalizer sex across questions
#Create the plot of vocalizer sex across questions
sex.emm <- add_grouping((emmeans(m69, "question")), 'Sex', 'question', c("Women","Women", "Women", "Women", "Men", "Men", "Men", "Men"))
#Obtain marginal means and pairwise comparisons
hpd.summary(emmeans(sex.emm, 'Sex'), prob = .89)
hpd.summary(pairs(emmeans(sex.emm, 'Sex'), prob = .89), type = "response")
#Plot these effect of vocalizer sex on masculinized and feminized choices
#Adjust for random effects
#Find random effects sd #Use colnames((as.matrix(m1$fit)))
m1.sigmaA = as.matrix(m69$fit)[,11:16]
m1SDA <- sqrt(apply(m69.sigmaA^2, 1, sum))
sex.rgrd <- regrid(emmeans(sex.emm, 'Sex'), bias.adjust = TRUE, sigma = m1SDA)
#Plot separately for different colors for each sex
#Plot for male voice
color_scheme <- c("skyblue1", "#000000",
                  "skyblue1", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
#Plot for Male Questions
FigSexMale <- bayesplot::mcmc_areas(as.mcmc(sex.rgrd), pars = c("Sex Men"),
                                    prob = .89, point_est = "none") + 
  theme_classic(base_family = "serif")+
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0,1)) + 
  scale_y_discrete(labels =c("Sex Men" = "Male Voices"))
#Plot for Female Questions
color_scheme <- c("firebrick3", "#000000",
                  "firebrick3", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
FigSexFemale <- bayesplot::mcmc_areas(as.mcmc(sex.rgrd), prob = 0.89, pars = c("Sex Women"), point_est = "none") +
  theme_classic(base_family = "serif")+ 
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0,1))+ 
  scale_y_discrete(labels =c("Sex Women" = "Female Voices")) + xlab("")
FigSex = FigSexMale / FigSexFemale

FigSex[[1]] = FigSex[[1]] + theme(axis.text.x = element_blank(),
                                  axis.ticks.x = element_blank(),
                                  axis.title.x = element_blank(),
                                  axis.line.x = element_blank(),
                                  axis.text.y = element_text(color = "black"),
                                  axis.ticks.length = unit(0, "pt"),
                                  text = element_text(size = 20),
                                  plot.margin=grid::unit(c(0,0,0,0), "mm")) 
FigSex[[2]] = FigSex[[2]] + theme(text = element_text(size = 20),
                                  axis.text.x = element_text(color = "black"),
                                  axis.text.y = element_text(color = "black"),
                                  plot.margin=grid::unit(c(0,0,0,0), "mm")) 




#Create the plot of perceptual questions
#Adjust for random effects
question.rgrd <- regrid(emmeans(m69, 'question'), bias.adjust = TRUE, sigma = m1SDA)
#Plot separately for different colors for each sex
#Plot for male questions
color_scheme <- c("skyblue1", "#000000",
                  "skyblue1", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
malequestion <- bayesplot::mcmc_areas(as.mcmc(question.rgrd), prob = 0.89,  point_est = "none", pars = c("question Long Term", 
                                                                                                         "question Respected",
                                                                                                         "question Short Term",
                                                                                                         "question Win a Physical Fight"))+
  theme_classic(base_family = "serif") + 
  scale_y_discrete(labels =c("question Long Term" = "Long-term Attractiveness",
                             "question Short Term" = "Short-term Attractiveness",
                             "question Respected" = "Prestige",
                             "question Win a Physical Fight" = "Formidability"),
                   limits=c("question Short Term","question Long Term","question Respected","question Win a Physical Fight")) +
  geom_vline(xintercept = 0.5, linetype = 3) +  scale_x_continuous(limits = c(0,1))
#Plot for female questions
color_scheme <- c("firebrick3", "#000000",
                  "firebrick3", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
femalequestion <- bayesplot::mcmc_areas(as.mcmc(question.rgrd), prob = 0.89,  point_est = "none", pars = c("question Attractive for a Long Term",
                                                                                                           "question Attractive for a Short Term",
                                                                                                           "question Attractive to Men",
                                                                                                           "question Interested in Attracting Men")) + 
  scale_y_discrete(labels =c("question Attractive for a Long Term" = "Long-term Attractiveness",
                             "question Attractive for a Short Term" = "Short-term Attractiveness",
                             "question Attractive to Men" = "Attractiveness to Men",
                             "question Interested in Attracting Men" = "Flirtatiousness"),
                   limits=c("question Interested in Attracting Men","question Attractive for a Short Term","question Attractive to Men","question Attractive for a Long Term"))+
  theme_classic(base_family = "serif")+  
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0,1)) +  xlab("")

Figquestion = malequestion / femalequestion

Figquestion[[1]] = Figquestion[[1]] + theme(axis.text.x = element_blank(),
                                            axis.ticks.x = element_blank(),
                                            axis.title.x = element_blank(),
                                            axis.line.x = element_blank(),
                                            axis.text.y = element_text(color = "black"),
                                            axis.ticks.length = unit(0, "pt"),
                                            text = element_text(size = 20),
                                            plot.margin=grid::unit(c(0,0,0,0), "mm"))
Figquestion[[2]] = Figquestion[[2]] + theme(text = element_text(size = 20),
                                            axis.text.y = element_text(color = "black"),
                                            axis.text.x = element_text(color = "black"),
                                            plot.margin=grid::unit(c(0,0,0,0), "mm"))

Figquestion


#Create the plot of manipulated stimulus type
#Adjust for random effects
stimulus.rgrd <- regrid(emmeans(m69, 'Pair'), bias.adjust = TRUE, sigma = m1SDA)
color_scheme <- c("blanchedalmond", "#000000",
                  "blanchedalmond", "#000000",
                  "#000000", "#000000")
color_scheme_set(color_scheme)
Figstimulus <- bayesplot::mcmc_areas(as.mcmc(stimulus.rgrd), prob = 0.89) + 
  scale_y_discrete(labels =c("Pair 1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "Pair 2SD Feminized and Mean" = "2SD Feminized \n and Mean",
                             "Pair 2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean"),
                   limits=c("Pair 2SD Masuclinized and Mean", "Pair 1SD Masuclinized and Feminized", "Pair 2SD Feminized and Mean"))+
  theme_classic(base_family = "serif")+ 
  geom_vline(xintercept = 0.5, linetype = 3) + scale_x_continuous(limits = c(0,1)) +  xlab("Probability of Choosing Masculine Stimuli")


Figstimulus = Figstimulus + theme(text = element_text(size = 20),
                                  axis.text.y = element_text(color = "black"),
                                  axis.text.x = element_text(color = "black"),
                                  plot.margin=grid::unit(c(0,0,0,0), "mm"))

#Create the plot of perceptual question across manipulated stimulus type
#Adjust for random effects
percstimulus.rgrd <- regrid(emmeans(m69,'question','Pair'), bias.adjust = TRUE, sigma = m1SDA)
percstimulus.data <- emmip(percstimulus.rgrd, question ~ Pair , CIs = TRUE, plotit = F)
Figps <- as.data.frame(percstimulus.data)
levels(Figps$question) <- c("Long-term Attractiveness", "Short-term Attractiveness", "Attractiveness to Men", "Flirtatiousness",
                            "Long-termAttractiveness ", "Prestige", "Short-term Attractiveness ", "Formidability")

Figps$Perception <- ordered(Figps$question, levels = c("Long-termAttractiveness ", "Short-term Attractiveness ", "Prestige", "Formidability",
                                                       "Long-term Attractiveness", "Short-term Attractiveness", "Attractiveness to Men", "Flirtatiousness"))

Figps <- ggplot(Figps, aes(xvar, yvar, group = Perception)) + geom_line(aes(color = Perception, linetype = Perception), position = position_dodge(width = 0.4))+ 
  geom_point(aes(color = Perception), size = 3, position=position_dodge(.4))+
  geom_point(aes(shape = Perception), size = 5, position=position_dodge(.4))+
  scale_color_manual(values=c("skyblue1","skyblue1","skyblue1","skyblue1","firebrick3", "firebrick3", "firebrick3","firebrick3"))+
  scale_fill_manual(values=c("skyblue1","skyblue1","skyblue1","skyblue1","firebrick3", "firebrick3", "firebrick3","firebrick3"))+
  geom_linerange(aes(ymin=LCL, ymax=UCL), width=.2, fill = NULL, 
                 position=position_dodge(.4)) +
  scale_shape_manual(values = c(0:8))+
  theme_classic(base_family = "serif") +
  scale_x_discrete(labels =c("2SD Masuclinized and Mean" = "2SD Masculinized \n and Mean",
                             "1SD Masuclinized and Feminized" = "1SD Masculinized \n and Feminized",
                             "2SD Feminized and Mean" = "2SD Feminized \n and Mean"),
                   limits=c("2SD Masuclinized and Mean", "1SD Masuclinized and Feminized", "2SD Feminized and Mean")) +  ylab("Probability of Choosing Masculine Stimuli") +  
  xlab("Stimulus Pair") +
  guides(fill=guide_legend(
    keywidth=0.05,
    keyheight=0.05,
    default.unit="cm")
  )

Figps = Figps + theme(text = element_text(size = 20),
                      axis.text.y = element_text(color = "black"),
                      axis.text.x = element_text(color = "black"),
                      legend.key.size = unit(0.05, "mm"),
                      legend.spacing = unit(0.05, "mm"),
                      legend.title = element_blank(),
                      legend.text = element_text(size = 10),
                      legend.position = 'top',
                      legend.background = element_rect(fill = "white", color = "black"),
                      plot.margin=grid::unit(c(0,0,0,0), "mm")) + geom_hline(yintercept = 0.5, linetype = "dotted")
Figps

FigmainS8 <- ((FigSex / Figquestion / Figstimulus ) + plot_layout(heights = c(1, 1, 3, 2)) | (Figps + theme(plot.margin = unit(c(0,0,0,5), "pt")))) + 
  plot_layout(widths = c(1, 1.5)) 
svg(file="FigmainS8.svg", width = 15.5, height = 9)
FigmainS8
dev.off()









