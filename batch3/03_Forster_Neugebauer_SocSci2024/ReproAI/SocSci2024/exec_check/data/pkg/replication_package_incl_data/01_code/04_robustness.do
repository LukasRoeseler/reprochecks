/*------------------------------------------------------------------------------
This do-file produces: 
- 	the additional analyses described in the section "Robustness Checks"
	
This do-file produces the following tables and figures:

- Table S11
- Table S12
- Table S13
- Table S14
- Table S15
- Table S16
- Table S17
- Table S18
- Table S19


Programs that need to be downloaded:
-	

Data needed/Data version used in paper:
- Data of the field experiment, reduced version for validation study, July 2024: validation_replication_fe.dta
- Data of the factorial survey, reduced version for validation study, July 2024: validation_replication_fs.dta
------------------------------------------------------------------------------*/


********************************************************************************
* Robustness check 1 (Supplement 4.1): Using only first vignette
********************************************************************************

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------
preserve 

	use "$data/validation_fs.dta", clear

	rename fs_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress invperc b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i.wave ///
		, cluster(ID) 
	est store main_fs_perc

	margins, by(applicant_migration) ///
		atmeans post
	est store fs_margins_migration_perc


restore

preserve 

	use "$data/validation_fs.dta", clear
	keep if vignette_nr==1

	rename fs_applicant_migration applicant_migration

	regress invperc b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i. wave ///
		, cluster(ID) 
	est store firstvig_fs
	
	margins, by(applicant_migration) ///
		atmeans post
	est store firstvig_fs_migration

restore

*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

etable, estimates(main_fs_perc firstvig_fs) export("$tables/TableS11.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***")
	

********************************************************************************
* Robustness check 2 (Supplement 4.2): Employers who decide on their own
********************************************************************************

 /*checken, ob befunde besser zu FE passen, wenn diejenigen ausgeschlossen
 werden, die gemeinsam mit Kollegen entscheiden
 */
 preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

preserve 
 
	use "$data/validation_fs.dta", clear
	keep if recruiter_responsible==1
	 
	regress invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.fs_applicant_migration i.wave ///
		, cluster(ID) 
	est store recruiter_respo_fs

restore

etable, estimates(main_fe recruiter_respo_fs) ///
		export("$tables/TableS12.docx", replace) ///
		stars(0.05 "*" 0.01 "**" 0.001 "***") 

******************************************************************************************
* Robustness Check 3 (Supplement 4.3): Restrict to those who found applicants to be realistic
******************************************************************************************

preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

preserve 
 
	use "$data/validation_fs.dta", clear
	keep if type_applicants==3 | type_applicants==4
	 
	rename fs_applicant_migration applicant_migration

	* DV: Invitation dichotomous 
	regress invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i.wave ///
			, cluster(ID) 
		est store type_applicants_fs


*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------
	etable, estimates(main_fe type_applicants_fs) ///
		export("$tables/TableS13.docx", replace) ///
		stars(0.05 "*" 0.01 "**" 0.001 "***") 
 
restore

********************************************************************************
* Robustness check 4 (Supplement 4.4) Restrict FS sample to those with intermediate SES and achievement
********************************************************************************

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------
preserve 

	use "$data/validation_fs.dta", clear

	rename fs_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration ///
		i.wave, cluster(ID) 
	est store main_fs

	margins, by(applicant_migration) ///
		atmeans post
	est store main_fs_margins_migration


restore

preserve 

	use "$data/validation_fs.dta", clear
	keep if fs_ses==2
	keep if fs_achievement==2

	rename fs_applicant_migration applicant_migration

	regress invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
		b1.occupational_field i.applicant_migration i.wave ///
		, cluster(ID) 

	est store sesachieve_fs

	margins, by(applicant_migration) ///
		atmeans post

	est store sesachieve_fs_migration

restore

*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

etable, estimates(main_fs sesachieve_fs) export("$tables/TableS14.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***")


********************************************************************************
* Robustness Check 5 (Supplement 4.5): Different Codings of the DVs
********************************************************************************

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	* Main analysis
	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe_strict
	
	* also count neutral responses as 1
	regress callback_loose i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 
	
	est store main_fe_loose
	
	* do not count test invitations as 1
	regress callback_notest i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe_notest

restore

*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

etable, estimates(main_fe_strict main_fe_loose main_fe_notest) export("$tables/TableS15.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***") 


*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------

preserve 

	use "$data/validation_fs.dta", clear

	rename fs_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	* DV: Invitation dichotomous 
		regress invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
			b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i.wave ///
			, cluster(ID) 
		est store main_fs_dich

	* DV: Invitation continuous 
		regress invperc b2.fs_applicant_education i.fs_applicant_female ///
			b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i.wave ///
			, cluster(ID) 
		est store main_fs_perc

		
	gen invperc_cut = .
		replace invperc_cut=0 if invperc <100 & invperc!=. 
		replace invperc_cut=1 if invperc==100 
		
	* DV dichotomized percentage measure
	regress invperc_cut b2.fs_applicant_education i.fs_applicant_female ///
			b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i.wave ///
			, cluster(ID) 
		est store main_fs_dich_cut
			
restore

*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

etable, estimates(main_fs_dich main_fs_perc main_fs_dich_cut) export("$tables/TableS16.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***") 


********************************************************************************
* Robustness check 6 (Supplement 4.6) Nonresponse, Restriction of FE sample to those who responded in FS
********************************************************************************

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fe.dta", clear
		
	merge 1:m ID using "$data/validation_fs.dta", keepusing(invitation_dich vignette_nr)
	keep if invitation_dich!=.
	keep if vignette_nr==1
	
	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe

	margins, by(applicant_migration) ///
		atmeans post 
		
	est store main_fe_margins_migration
	
restore

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------

preserve 

	use "$data/validation_fs.dta", clear
		
	rename fs_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i.wave ///
		, cluster(ID) 
 	est store main_fs

	margins, by(applicant_migration) ///
		atmeans post

	est store main_fs_margins_migration


restore


*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

etable, estimates(main_fe main_fs) export("$tables/TableS17.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***") 



********************************************************************************
* Different Model specifications: Logistic Regression & Random effects models (supplement 4.7)
********************************************************************************

*-------------------------------------------------------------------------------
* Logistic Regression
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fe.dta", clear

	lab var fe_applicant_migration "Applicant Migration"

	logit callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.fe_applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe_logit

restore

preserve 

	use "$data/validation_fs.dta", clear

	logit invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.fs_applicant_migration i.wave ///
		, cluster(ID) 
 	
	est store main_fs_logit

restore

etable, estimates(main_fe_logit main_fs_logit) ///
	export("$tables/TableS18.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***") 
				
*-------------------------------------------------------------------------------
* Random Effects
*-------------------------------------------------------------------------------

preserve 

	use "$data/validation_fs.dta", clear

	mixed invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.fs_applicant_migration i.wave ///
		|| ID:
 	
	est store main_fs_mixed

restore

*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

	
etable, estimates(main_fs main_fs_mixed) ///
	export("$tables/TableS19.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***") 
				



