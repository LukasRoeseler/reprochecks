14 October 2019
Revised 20 February 2020


The files provide the R source code and related analyses. 

Analysis.R: Estimates power for study 2 and study S2. Power values for other studies are pasted in from the results of simulations. The probability of all 6 studies being totally successful is the product of the power for each of the studies. 

MetaanalysisPower.R: This code uses the means, standard deviations, and sample sizes in Dallas et al. (2017) to run a meta-analysis that pools the standardized effect sizes across the studies. The output includes a summary of the meta-analysis and sample sizes needed for different power levels based on the pooled effect size. 

Results.txt: The R console output for the R code. For the simulation studies, your numbers may vary, due to random sampling. 

Study1.R / Study3.R / StudyS2.R / StudyS3.R: Runs 100,000 simulated studies with the means, standard deviations, and sample sizes reported by Dallas et al. (2017). The simulated data is analyzed in the same way as the original paper, and the proportion of simulations that show full success is an estimate of the power (success rate) of the study. Due to random sampling, you may get slightly different numbers than what is reported in the text. 

