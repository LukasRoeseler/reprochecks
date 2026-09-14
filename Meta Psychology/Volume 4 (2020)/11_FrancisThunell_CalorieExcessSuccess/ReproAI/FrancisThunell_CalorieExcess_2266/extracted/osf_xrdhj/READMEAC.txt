14 June 2020

Greg Francis and Evelina Thunell
Contact: gfrancis@purdue.edu

The files provide the R source code and related analyses. 

Analysis.R: Estimates power for study 2 and study S2. Power values for other studies are pasted in from the results of simulations. The probability of all 6 studies being totally successful is the product of the power for each of the studies. 

MetaanalysisPower.R: This code uses the means, standard deviations, and sample sizes in Dallas et al. (2017) to run a meta-analysis that pools the standardized effect sizes across the studies. The output includes a summary of the meta-analysis and sample sizes needed for different power levels based on the pooled effect size. 

Results.txt: The R console output for the R code. For the simulation studies, your numbers may vary, due to random sampling. 

Study1.R / Study3.R / StudyS2.R / StudyS3.R: Runs 100,000 simulated studies with the means, standard deviations, and sample sizes reported by Dallas et al. (2017). The simulated data is analyzed in the same way as the original paper, and the proportion of simulations that show full success is an estimate of the power (success rate) of the study. Due to random sampling, you may get slightly different numbers than what is reported in the text. 

Dallas et al. published a corrigendum on April 9, 2020 that revised the sample size for one condition in Study 1 and the sample size, mean, and standard deviation for a condition in Study 3. We updated our simulation analyses accordingly, and the paper reflects these updated settings. The corresponding files are

AnalysisAC.R: Same as above, but with updated values for studies 1 and 3 based on the new information in the corrigendum. The product of power estimates across studies is unchanged to 3 decimal places (after rounding). 

MetaanalysisPowerAC.R: The sample size change in Study 1 causes only a very small change to the estimated effect size. The pooled effect size estimate is unchanged to three decimal places (to four places after rounding). None of the power calculations are changed. 

Study1AC.R: Same as above, with changes to the sample size for the Right label condition. 

Study3AC.R: Same as above, with changes to the sample size, mean, and standard deviation for the No label condition. 

 