library(plyr)
library(tidyverse)

source("analysis_functions.r")

data = read.csv('../data/data_exp1.csv')
questiondata = read.csv('../data/questiondata_exp1.csv')

###### DEMOGRAPHICS #######

table(questiondata$gender)

###### QUESTION DATA ######

questiondata = questiondata %>% filter(exclude == 0)

# summarize post-experiment questions
endquestions = questiondata %>%
    group_by(condition) %>%
        dplyr::summarize(meanpercent = mean(dangerpercent[dangerpercent>=0], na.rm=TRUE),
                  numdimrel = mean(numdimchecked),
                  bonus = mean(finalscore),
                  proprightrule = sum(rightdimensions)/n(),
                  proptrap = sum(trapdimensions)/n(),
                  n = n())
endquestions

###### MAIN EXPERIMENT DATA ######

# graph main experiment data
data$test = as.logical(data$test)
data$correct = as.logical(data$correct)
data$condition = as.factor(data$condition)
data = data %>% filter(exclude == 0)

rules <- get_rule_proportions(data)


rules$condition <- plyr::revalue(rules$condition, c("contingent"="Contingent",
                                     "full_info"="Full info",
                                     "individuated"="Individuated",
                                     "occluded"="Occluded"))

g <- rules_graph(rules)
g <- g + scale_x_continuous(breaks=c(1,2,3,4,5),
                       labels=c(1,2,3,4,"test"),
                       limits=c(1,5)) +
  theme(axis.text.x=element_text(angle=c(0, 0, 0, 0, -45), hjust=c(.5,.5,.5,.5,0)))
g

pdf("figures/exp1_rule.pdf", height=6, width=10)
g
dev.off()
png("figures/exp1_rule.png", height=6, width=10,  units="in", res=300)
g
dev.off()




# learning data analysis

learning <- data %>%
  filter(!test) %>%
  group_by(condition, uniqueid)

learningsummary <- learning %>%
  dplyr::summarize(reward=sum(reward),
            approachprop=sum(response))


firstblock <- learning %>%
  filter(block ==  0) %>%
  dplyr::summarize(approachprop=mean(response))

firstblock = firstblock %>%  dplyr::filter(condition %in% c('contingent', 'full_info'))

conditions = factor(firstblock$condition, levels=c('contingent', 'full_info'),
                    labels=c("Contingent", "Full info."))

out = fit_stan_model(conditions,
               firstblock$approachprop, "twosample_continuous.stan")
cond_mu=out[['cond_mu']]

g1 = create_stan_graph(cond_mu) + xlab("2D rule score at test")

create_stan_pairwise(cond_mu)

out$fit


# test data analysis

test <- data %>%
  filter(test) %>%
  group_by(condition, uniqueid)

# rule scores at test
testrule <- test %>%
  mutate(twodimrule = (!dim3 & !dim2 & !response) | ((dim3 | dim2) & response),
         onedimrule1 = (dim2 & response) | (!dim2 & !response),
         onedimrule2 = (dim3 & response) | (!dim3 & !response)) %>%
  dplyr::summarize(twodimscore = mean(twodimrule),
            onedimscore1 = mean(onedimrule1),
            onedimscore2 = mean(onedimrule2)) %>%
  mutate(onedimscore = pmax(onedimscore1, onedimscore2))

testrule %>% dplyr::summarize(onedim=mean(onedimscore), twodim=mean(twodimscore))


# Stan Analyses
conditions = factor(testrule$condition, levels=c('contingent', 'full_info'),
                    labels=c("Contingent", "Full info."))



##Claim ID: g44qqk

out = fit_stan_model(conditions, testrule$twodimscore, 'twosample_continuous.stan')
cond_mu=out[['cond_mu']]


g1 = create_stan_graph(cond_mu) + xlab("2D rule score at test")
create_stan_pairwise(cond_mu)



g1$data
#calculate the posterior distribution of the difference
sim_posterior = cond_mu$`Full info.`- cond_mu$Contingent 
g1_diff = quantile(sim_posterior, c(0.025, 0.975))
g1_diff




#summary statistics for g1 anc convert to %
g1_full_info<- mean(cond_mu$`Full info.`)
g1_full_info
g1_contingent<- mean(cond_mu$Contingent)
g1_contingent
g1_diff



## Claim ID: m5xkkr

out = fit_stan_model(conditions, testrule$onedimscore, 'twosample_continuous.stan')
cond_mu=out[['cond_mu']]

g2 = create_stan_graph(cond_mu) + xlab("1D rule score at test")
create_stan_pairwise(cond_mu)

conditions = factor(questiondata$condition, levels=c('contingent', 'full_info'),
                    labels=c("Contingent", "Full info."))

g2$data
#calculate the posterior distribution of the difference
sim_posterior = cond_mu$`Full info.`- cond_mu$Contingent 
g2_diff = quantile(sim_posterior, c(0.025, 0.975))

#summary statistics for g2
mean(cond_mu$`Full info.`)
mean(cond_mu$Contingent)
g2_diff


#summary statistics for g2 anc convert to %
g2_full_info<- mean(cond_mu$`Full info.`)
g2_full_info
g2_contingent<- mean(cond_mu$Contingent)
g2_contingent
g2_diff



## Claim ID: myjqqn

out = fit_stan_model(conditions[questiondata$dangerpercent>=0],
                     questiondata$dangerpercent[questiondata$dangerpercent>=0]/100, 'twosample_continuous.stan')
cond_mu=out[['cond_mu']]

g3 = create_stan_graph(100*cond_mu) + xlab("Percent of applicants believed to be unsuitable")
create_stan_pairwise(cond_mu)

g3$data
#calculate the posterior distribution of the difference
sim_posterior = cond_mu$`Full info.`- cond_mu$Contingent 
g3_diff = quantile(sim_posterior, c(0.025, 0.975))

#summary statistics for g3 - convert to %
mean(cond_mu$`Full info.`)*100
mean(cond_mu$Contingent)*100
g3_diff

#summary statistics for g3 anc convert to %
g3_full_info<- mean(cond_mu$`Full info.`)*100
g3_full_info
g3_contingent<- mean(cond_mu$Contingent)*100
g3_contingent
g3_diff



# Claim ID: b2vooo

out = fit_stan_model(conditions, questiondata$rightdimensions, 'twosample_binary.stan')
cond_mu=out[['cond_mu']]

g4 = create_stan_graph(cond_mu) + xlab("Proportion of participants identifying both relevant dimensions")
create_stan_pairwise(cond_mu)

g4$data
#calculate the posterior distribution of the difference
sim_posterior = cond_mu$`Full info.`- cond_mu$Contingent 
g4_diff = quantile(sim_posterior, c(0.025, 0.975))

#summary statistics for g4 anc convert to %
mean(cond_mu$`Full info.`)*100
mean(cond_mu$Contingent)*100
g4_diff

#summary statistics for g3 anc convert to %
g4_full_info<- mean(cond_mu$`Full info.`)*100
g4_full_info
g4_contingent<- mean(cond_mu$Contingent)*100
g4_contingent
g4_diff




#Claim ID: m8lkk9

out = fit_stan_model(conditions, questiondata$trapdimensions, 'twosample_binary.stan')
cond_mu=out[['cond_mu']]

g5 = create_stan_graph(cond_mu) + xlab("Proportion of participants identifying a single relevant dimension")
create_stan_pairwise(cond_mu)

g5_diff = quantile(sim_posterior, c(0.025, 0.975))

g5$data
#calculate the posterior distribution of the difference
sim_posterior = cond_mu$`Full info.`- cond_mu$Contingent 
quantile(sim_posterior, c(0.025, 0.975))

#summary statistics for g5 anc convert to %
g5_full_info<- mean(cond_mu$`Full info.`)*100
g5_full_info
g5_contingent<- mean(cond_mu$Contingent)*100
g5_contingent
g5_diff






g = plot_grid(g1, g2, g3, g4, g5, ncol=1)

pdf("figures/exp1_tsm.pdf", height=6, width=10)
g
dev.off()

png("figures/exp1_tsm.png", height=6, width=10,  units="in", res=300)
g
dev.off()
