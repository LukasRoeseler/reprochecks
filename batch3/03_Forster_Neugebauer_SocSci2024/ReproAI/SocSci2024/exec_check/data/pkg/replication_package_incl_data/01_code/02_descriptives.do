
/*------------------------------------------------------------------------------
This do-file produces: 
- 	the descriptive statistics in the main text
	
This do-file produces the following tables and figures:
- Table 2
- Table S5
- Table S6

Programs that need to be downloaded:
-	

Data needed/Data version used in paper:
- Data of the field experiment, reduced version for validation study, July 2024: validation_replication_fe.dta
- Data of the factorial survey, reduced version for validation study, July 2024: validation_replication_fs.dta
------------------------------------------------------------------------------*/


* Numbers in Table 2 - Left Panel (FE)
preserve 
 
	use "$data/validation_fe.dta"

	sum callback_strict

	fre  occupational_field

restore


* Numbers in Table 2 - Right Panel (FS)
preserve 

	use "$data/validation_fs.dta"

	sum invitation_dich
	
	recode recruiter_responsible (min/-1=.)

	fre  occupational_field recruiter_responsible
	
	sum socdesire_std time_use survatt_std

restore

* Correlation matrices - Appendix 

* Table S5

preserve 

	use "$data/validation_fs", clear
	corr fs_applicant_female fs_applicant_migration fs_applicant_education fs_ses fs_achievement

restore

* Table S6

preserve 

	use "$data/validation_fe", clear
	corr fe_applicant_female fe_applicant_migration fe_applicant_education

restore
