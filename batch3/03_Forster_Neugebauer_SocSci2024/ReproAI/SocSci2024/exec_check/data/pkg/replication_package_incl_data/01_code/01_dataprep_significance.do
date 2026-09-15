/*------------------------------------------------------------------------------
This do-file prepares: 
- 	an appended dataset containing the data from FE and FS to conduct a 
	significance test for the difference of coefficients across experiments
	
This do-file produces the following tables and figures:
-

Programs that need to be downloaded:
-	

Data needed/Data version used in paper:
- Data of the field experiment, reduced version for validation study, July 2024: validation_replication_fe.dta
- Data of the factorial survey, reduced version for validation study, July 2024: validation_replication_fs.dta
------------------------------------------------------------------------------*/


*###############################################################################
/* generate a dataset for significance tests between FE and FS */
*###############################################################################

* Open FE data and rename a few variables, so that they match the names in the FS

use "$data/validation_fe.dta", clear

keep ID callback_strict fe_applicant_female ///
	fe_applicant_migration fe_applicant_dropout occupational_field wave

rename callback_strict invitation
rename fe_applicant_female applicant_female
rename fe_applicant_migration applicant_migration

recode fe_applicant_dropout (0=2 "Abitur")(1=3 "Dropout"), gen(applicant_education)

* create an indicator for the experiment FE=0
gen experiment = 0

save "$posted/validation_fe_significance.dta", replace

* Open FS data and rename a few variables, so that they matche the names in the FE
use "$data/validation_fs.dta", clear

keep ID vignette_nr fs_applicant_education fs_applicant_migration ///
	fs_applicant_female fs_ses fs_achievement occupational_field invitation_dich wave

rename fs_applicant_female applicant_female
rename fs_applicant_migration applicant_migration
rename fs_applicant_education applicant_education
rename invitation_dich invitation	

* Create an indicator for the experiment FS=1
gen experiment = 1

* Append the two data sets and save the data
append using "$posted/validation_fe_significance.dta"
	
sort ID experiment

save "$posted/validation_significance_test.dta", replace


