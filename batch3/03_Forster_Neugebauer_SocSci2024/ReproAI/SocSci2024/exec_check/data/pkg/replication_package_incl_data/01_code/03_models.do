/*------------------------------------------------------------------------------
This do-file produces: 
- 	the main results regarding H1, H2 and H3 
	
This do-file produces the following tables and figures:
- 	Figure 3
-	Figure 4
-	Figure 5
- 	Figure 6
-	Figure S1
-	Figure S2
- 	Figure S3
- 	Table S7
-	Table S8
-	Table S9
-	Table S10

Programs that need to be downloaded:
-	

Data needed/Data version used in paper:
- Data of the field experiment, reduced version for validation study, July 2024: validation_replication_fe.dta
- Data of the factorial survey, reduced version for validation study, July 2024: validation_replication_fs.dta
------------------------------------------------------------------------------*/


*###############################################################################
* Hypothesis 1: Topics of Varying Sensitivity
*###############################################################################

********************************************************************************
* H1: Topic: Ethnic Background
********************************************************************************

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
	margins, by(applicant_migration) ///
		atmeans ///
		post 
		
	est store main_fe_migration

restore

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
		est store main_fs

	margins, by(applicant_migration) ///
		atmeans ///
		post

	est store main_fs_margins_migration

restore

*-------------------------------------------------------------------------------
* Joint plot
*-------------------------------------------------------------------------------

coefplot (main_fe_migration, label("Field experiment") offset(0)  ///
	msymbol(S) mcolor(orangebrown) msize(small) 	///	
	lcolor(orangebrown) lpattern(--) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown) )) ///
	(main_fs_margins_migration, label("Factorial survey") offset(0)  ///
	msymbol(D) mcolor(turquoise) msize(small) 	///
	lcolor(turquoise) lpattern(solid) lcolor(turquoise) 						///
	ciopts(recast(rcap) lcolor(turquoise) )), ///
	title("", size(med) color(black))									///
	vertical recast(connected) 									   		///
	yscale(range(0.4(0.05)0.7)) ///
	ylabel(0.4(0.1)0.7) ///
	ytitle("Predicted Probability of Invitation", size(small)) 	///
	xtitle("Applicant Ethnic Background", size(small)) 		   		///
	xscale(titlegap(2)) xlab(1 "German Name" 2 "Turkish Name", labsize(small)) 				   		///
	legend(position(3) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	graphregion(color(white) fcolor(white) icolor(white))	

	graph export "$figures/Figure3_ethnicity.png", replace


********************************************************************************
* H1: Topic: Dropout
********************************************************************************

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_dropout applicant_dropout

	recode applicant_dropout (0=2) (1=3)

	regress callback_strict i.applicant_dropout i.fe_applicant_female ///
	i.fe_applicant_migration i.occupational_field, vce(robust)

	margins, by(applicant_dropout) ///
		atmeans ///
		post 

	est store main_fe_dropout
		
restore


*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------

preserve 

	use "$data/validation_fs.dta", clear

	rename fs_applicant_education applicant_dropout


	* DV: Invitation dichotomous 
	regress invitation_dich b2.applicant_dropout i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field i.fs_applicant_migration ///
		, cluster(ID) 

	margins, over(applicant_dropout) ///
		atmeans ///
		post

	est store main_fs_dropout

restore


*-------------------------------------------------------------------------------
* Joint plot
*-------------------------------------------------------------------------------


coefplot (main_fs_dropout, label("Factorial survey") offset(0)  ///
	msymbol(D) mcolor(turquoise) msize(small) 	///
	lcolor(turquoise) lpattern(solid) lcolor(turquoise) 						///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(main_fe_dropout, label("Field experiment") offset(0)  ///
	msymbol(S) mcolor(orangebrown) msize(small) 	///
	lcolor(orangebrown) lpattern(--) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown))), ///
	title("", size(med) color(black))									///
	vertical recast(connected) 									   		///
	ytitle("Predicted Probability of Invitation", size(small)) 	///
	yscale(range(0.4(0.05)0.7)) ///
	ylabel(0.4(0.1)0.7) ///
	xtitle("Applicant Education", size(small)) 		   		///
	xscale(titlegap(2)) ///
	xlab(1 "Intermediate HS diploma" 2 "Abitur" 3 "Abitur + Some college", labsize(small)) /// 				   		///
	legend(position(3) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	graphregion(color(white) fcolor(white) icolor(white))	

	graph export "$figures/Figure3_dropout.png", replace
	

********************************************************************************
* H1: Joint table 
********************************************************************************

etable, estimates(main_fe main_fs) export("$tables/TableS7.docx", replace) stars(0.05 "*" 0.01 "**" 0.001 "***") 


********************************************************************************
* H1: Significance test FE FS 
********************************************************************************

/* Pool the FS and FE data and calculate interaction effects between the treatments
and the experimental condition
*/

preserve

use "$posted/validation_significance_test.dta", clear

regress invitation ///
	b2.applicant_education##i.experiment  ///
	i.applicant_migration##i.experiment ///
	i.applicant_female##i.experiment ///
	i.occupational_field##i.experiment ///
	i.wave##experiment ///
	, cluster(ID)

est store main_sig
	
etable, estimates(main_sig) export("$tables/TableS7_significance.docx", replace) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***")

restore 

*###############################################################################
* Hypothesis 2: Disposition for SDB
*###############################################################################

********************************************************************************
*** H2: Disposition for Social Desirability - Ethnic Background
********************************************************************************
estimates clear 

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------
preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------
preserve 

	use "$data/validation_fs.dta", clear
	
	drop if socdesire_std==.
	
	* Restandardize to final Sample
	
	sum socdesire_std 
	rename socdesire_std socdesire_std_old
	egen socdesire_std = std(socdesire_std_old)
	
	* Generate three groups of respondents with low, intermediate and high
	* disposition for SDB (at 33rd and 66th percentile)
	
	sum socdesire_std, detail

		egen p33 = pctile(socdesire_std), p(33)
		egen p66 = pctile(socdesire_std), p(66)
		fre p33 p66
		
		gen level_socdesire = 1 if socdesire_std<=p33 
			replace level_socdesire=2 if socdesire_std>p33 & socdesire_std<=p66
			replace level_socdesire=3 if socdesire_std>p66

	* Run analysis for the three groups of respondents separately
	
	rename fs_applicant_migration applicant_migration

	forvalue x=1/3 {

		regress invitation_dich b2.fs_applicant_education ///
			i.fs_applicant_female b2.fs_achievement b2.fs_ses ///
			b1.occupational_field i.applicant_migration i.wave ///
			if level_socdesire==`x' ///
			, cluster(ID) 
			
		est store socdesire_fs_`x'

		margins, by(applicant_migration) ///
			atmeans post

		est store socdesire_migration_`x'
	}
	
restore


*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

	etable, estimates(main_fe socdesire_fs_* ) ///
	export("$tables/TableS8.docx", replace) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***") 


*-------------------------------------------------------------------------------
* Joint plot Migration
*-------------------------------------------------------------------------------

coefplot ///
	(main_fe, label("Field experiment") ///
	msymbol(S) mcolor(orangebrown) msize(small) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown))) ///
	(socdesire_fs_1, label("FS low soc. desirability") ///
	msymbol(D) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(socdesire_fs_2, label("FS intermediate soc. desirability") ///
	msymbol(T) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(socdesire_fs_3, label("FS high soc. desirability") ///
	msymbol(O) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	, keep(1.applicant_migration) yline(0) title("") ///
	rename(1.applicant_migration = 0) ///
	legend(position(7) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	xlabel("", noticks) ///
	graphregion(color(white) fcolor(white) icolor(white)) ///
	ytitle("Effect of Ethnic Background", size(small)) vertical

graph export "$figures/Figure4.png", replace

********************************************************************************
*** H2: Disposition for Social Desirability - Dropout
********************************************************************************
estimates clear

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------
preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_dropout applicant_dropout
	recode applicant_dropout (0=2) (1=3)

	regress callback_strict i.applicant_dropout i.fe_applicant_female ///
	i.fe_applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------
preserve 

	use "$data/validation_fs.dta", clear
	
	drop if socdesire_std==.
	
	* Restandardize to final Sample
	sum socdesire_std 
	rename socdesire_std socdesire_std_old
	egen socdesire_std = std(socdesire_std_old)
	
	* Generate three groups of respondents with low, intermediate and high
	* disposition for SDB (at 33rd and 66th percentile)
	
	sum socdesire_std, detail

		egen p33 = pctile(socdesire_std), p(33)
		egen p66 = pctile(socdesire_std), p(66)
		fre p33 p66
		
		gen level_socdesire = 1 if socdesire_std<=p33 
			replace level_socdesire=2 if socdesire_std>p33 & socdesire_std<=p66
			replace level_socdesire=3 if socdesire_std>p66

	* Run analysis for the three groups of respondents separately
	
	rename fs_applicant_education applicant_dropout

	forvalue x=1/3 {

		regress invitation_dich b2.applicant_dropout ///
			i.fs_applicant_female b2.fs_achievement b2.fs_ses ///
			b1.occupational_field i.fs_applicant_migration i.wave ///
			if level_socdesire==`x' ///
			, cluster(ID) 
			
		est store socdesire_fs_`x'

		margins, by(applicant_dropout) ///
			atmeans post

		est store socdesire_migration_`x'
	}

		
restore


*-------------------------------------------------------------------------------
* Joint plot Dropout
*-------------------------------------------------------------------------------

coefplot ///
	(main_fe, label("Field experiment") ///
	msymbol(S) mcolor(orangebrown) msize(small) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown))) ///
	(socdesire_fs_1, label("FS low soc. desirability") ///
	msymbol(D) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(socdesire_fs_2, label("FS intermediate soc. desirability") ///
	msymbol(T) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(socdesire_fs_3, label("FS high soc. desirability") ///
	msymbol(O) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	, keep(3.applicant_dropout) yline(0) title("") ///
	rename(3.applicant_dropout = 0) ///
	legend(position(7) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	xlabel("", noticks) ///
	graphregion(color(white) fcolor(white) icolor(white)) ///
	ytitle("Effect of HE non-completion", size(small)) vertical

graph export "$figures/FigureS1.png", replace
	
*###############################################################################
* Hypothesis 3: Effort
*###############################################################################

********************************************************************************
*** H3 Time Use - Ethnic Background
********************************************************************************
estimates clear 

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------
preserve

	use "$data/validation_fs.dta", clear				
				
	
	* Generate three groups of respondents with low, intermediate and high
	* processing time (at 33rd and 66th percentile)
	
	sum time_use, detail
	drop if time_use==.
	egen p33 = pctile(time_use), p(33)
	egen p66 = pctile(time_use), p(66)
	fre p33 p66
	
	gen level_timeuse = 1 if time_use<=p33
		replace level_timeuse=2 if time_use>p33 & time_use<=p66
		replace level_timeuse=3 if time_use>p66
		

	* Run analysis for the three groups of respondents separately
	rename fs_applicant_migration applicant_migration

	forvalue x=1/3 {

		regress invitation_dich b2.fs_applicant_education ///
			i.fs_applicant_female b2.fs_achievement b2.fs_ses ///
			b1.occupational_field i.applicant_migration i.wave ///
			if level_timeuse==`x' ///
			, cluster(ID) 
			
		est store effort_fs_`x'

		margins, by(applicant_migration) ///
			atmeans post

		est store effortme_fs_migration_`x'
	}

restore 

*-------------------------------------------------------------------------------
* Joint table
*-------------------------------------------------------------------------------

etable, estimates(main_fe effort_fs_1 effort_fs_2 effort_fs_3 ) ///
	export("$tables/TableS9.docx", replace) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***") 


*-------------------------------------------------------------------------------
* Joint plot Ethnic Background
*-------------------------------------------------------------------------------

coefplot ///
	(main_fe, label("Field experiment") ///
	msymbol(S) mcolor(orangebrown) msize(small) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown))) ///
	(effort_fs_1, label("FS low response time") ///
	msymbol(D) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(effort_fs_2, label("FS intermediate response time") ///
	msymbol(T) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(effort_fs_3, label("FS high response time") ///
	msymbol(O) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	, keep(1.applicant_migration) yline(0) title("") ///
	rename(1.applicant_migration = 0) ///
	legend(position(7) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	xlabel("", noticks) ///
	graphregion(color(white) fcolor(white) icolor(white)) ///
	ytitle("Effect of Ethnic Background", size(small)) vertical

	graph export "$figures/Figure5.png", replace	
				

********************************************************************************
* H3 Time Use - Dropout
********************************************************************************

estimates clear
*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------
preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_dropout applicant_dropout
	recode applicant_dropout (0=2) (1=3)

	regress callback_strict i.applicant_dropout i.fe_applicant_female ///
	i.fe_applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------
preserve
	
	use "$data/validation_fs.dta", clear	
	drop if time_use==.

	* Generate three groups of respondents with low, intermediate and high
	* processing time (at 33rd and 66th percentile)
	
	sum time_use, detail
	egen p33 = pctile(time_use), p(33)
	egen p66 = pctile(time_use), p(66)
	fre p33 p66
	
	gen level_timeuse = 1 if time_use<=p33
		replace level_timeuse=2 if time_use>p33 & time_use<=p66
		replace level_timeuse=3 if time_use>p66
		
	* Run analysis for the three groups of respondents separately

	rename fs_applicant_education applicant_dropout

	forvalue x=1/3 {

		regress invitation_dich b2.applicant_dropout ///
			i.fs_applicant_female b2.fs_achievement b2.fs_ses ///
			b1.occupational_field i.fs_applicant_migration i.wave ///
			if level_timeuse==`x' ///
			, cluster(ID) 
							
		est store effort_fs_`x' 
	}

restore

*-------------------------------------------------------------------------------
* Joint plot Dropout
*-------------------------------------------------------------------------------

coefplot ///
	(main_fe, label("Field experiment") ///
	msymbol(S) mcolor(orangebrown) msize(small) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown))) ///
	(effort_fs_1, label("FS low response time") ///
	msymbol(D) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(effort_fs_2, label("FS intermediate response time") ///
	msymbol(T) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(effort_fs_3, label("FS high response time") ///
	msymbol(O) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	, keep(3.applicant_dropout) yline(0) title("") ///
	rename(3.applicant_dropout = 0) ///
	legend(position(7) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	xlabel("", noticks) ///
	graphregion(color(white) fcolor(white) icolor(white)) ///
	ytitle("Effect of HE Non-completion", size(small)) vertical

	graph export "$figures/FigureS2.png", replace

********************************************************************************
*** H3 Survey Attitudes - Ethnic Background
********************************************************************************

estimates clear 

*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_migration applicant_migration
	lab var applicant_migration "Applicant Migration"

	regress callback_strict i.fe_applicant_dropout i.fe_applicant_female ///
	i.applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------

preserve

	use "$data/validation_fs.dta", clear
	
	drop if survatt_std==.
	
	* Restandardize to final sample
	sum survatt_std 
	rename survatt_std survatt_std_old
	egen survatt_std = std(survatt_std_old)
	sum survatt_std
	

	* Generate three groups of respondents with low, intermediate and high
	* valuation of surveys (at 33rd and 66th percentile)
	
	sum survatt_std, detail

	egen p33 = pctile(survatt_std), p(33)
	egen p66 = pctile(survatt_std), p(66)
	fre p33 p66

	gen level_survatt = 1 if survatt_std<=p33
	replace level_survatt=2 if survatt_std>p33 & survatt_std<=p66
	replace level_survatt=3 if survatt_std>p66
	
	* Run analysis for the three groups of respondents separately
	rename fs_applicant_migration applicant_migration

	forvalue x=1/3 {

		regress invitation_dich b2.fs_applicant_education i.fs_applicant_female ///
			b2.fs_achievement b2.fs_ses b1.occupational_field i.applicant_migration i.wave ///
			if level_survatt==`x' ///
			, cluster(ID) 
			
		est store survatt_fs_`x'

		margins, by(applicant_migration) ///
			at(fs_applicant_education=2 fs_applicant_female=0 fs_achievement=2 fs_ses=2 ///
			occupational_field=1) post

		est store survattme_fs_migration_`x'
	}

restore
				
*-------------------------------------------------------------------------------
* Joint table 
*-------------------------------------------------------------------------------

etable, estimates(main_fe survatt_fs_1 survatt_fs_2 survatt_fs_3 ) ///
	export("$tables/TableS10.docx", replace) ///
	stars(0.05 "*" 0.01 "**" 0.001 "***") 

*-------------------------------------------------------------------------------
* Joint plot
*-------------------------------------------------------------------------------

coefplot ///
	(main_fe, label("Field experiment") ///
	msymbol(S) mcolor(orangebrown) msize(small) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown))) ///
	(survatt_fs_1, label("FS low value survey") ///
	msymbol(D) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(survatt_fs_2, label("FS intermediate value survey") ///
	msymbol(T) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(survatt_fs_3, label("FS high value survey") ///
	msymbol(O) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	, keep(1.applicant_migration) yline(0) title("") ///
	rename(1.applicant_migration = 0) ///
	legend(position(7) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	xlabel("", noticks) ///
	graphregion(color(white) fcolor(white) icolor(white)) ///
	ytitle("Effect of Ethnic Background", size(small)) vertical

	graph export "$figures/Figure6.png", replace

********************************************************************************
* H3 Survey Attitudes - Dropout
********************************************************************************
*-------------------------------------------------------------------------------
* Field experiment
*-------------------------------------------------------------------------------
preserve

	use "$data/validation_fe.dta", clear

	rename fe_applicant_dropout applicant_dropout
	recode applicant_dropout (0=2) (1=3)

	regress callback_strict i.applicant_dropout i.fe_applicant_female ///
	i.fe_applicant_migration i.occupational_field i.wave, vce(robust) 

	est store main_fe
	
restore

*-------------------------------------------------------------------------------
* Factorial Survey
*-------------------------------------------------------------------------------

preserve 

	use "$data/validation_fs.dta", clear
	
	drop if survatt_std==.
	
	* Restandardize to final sample
	sum survatt_std 
	rename survatt_std survatt_std_old
	egen survatt_std = std(survatt_std_old)
	sum survatt_std
	

	* Generate three groups of respondents with low, intermediate and high
	* valuation of surveys (at 33rd and 66th percentile)
	
	sum survatt_std, detail

	egen p33 = pctile(survatt_std), p(33)
	egen p66 = pctile(survatt_std), p(66)
	fre p33 p66

	gen level_survatt = 1 if survatt_std<=p33
	replace level_survatt=2 if survatt_std>p33 & survatt_std<=p66
	replace level_survatt=3 if survatt_std>p66
	
	* Run analysis for the three groups of respondents separately

	rename fs_applicant_education applicant_dropout

	forvalue x=1/3 {

	regress invitation_dich b2.applicant_dropout ///
		i.fs_applicant_female ///
		b2.fs_achievement b2.fs_ses b1.occupational_field ///
		i.fs_applicant_migration i.wave ///
		if level_survatt==`x' ///
		, cluster(ID) 

	est store survatt_fs_`x'

	margins, by(applicant_dropout) ///
		atmeans post

	est store survattme_fs_dropout_`x'
	}

restore


*-------------------------------------------------------------------------------
* Joint plot
*-------------------------------------------------------------------------------

coefplot ///
	(main_fe, label("Field experiment") ///
	msymbol(S) mcolor(orangebrown) msize(small) lcolor(orangebrown) ///
	ciopts(recast(rcap) lcolor(orangebrown))) ///
	(survatt_fs_1, label("FS low value survey") ///
	msymbol(D) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(survatt_fs_2, label("FS intermediate value survey") ///
	msymbol(T) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	(survatt_fs_3, label("FS high value survey") ///
	msymbol(O) mcolor(turquoise) msize(small) lcolor(turquoise) ///
	ciopts(recast(rcap) lcolor(turquoise))) ///
	, keep(3.applicant_dropout) yline(0) title("") ///
	rename(3.applicant_dropout = 0) ///
	xlabel("", noticks) ///
	legend(position(7) rows(2) size(small) rowgap(.5) bmargin(zero)) 	///
	graphregion(color(white) fcolor(white) icolor(white)) ///
	ytitle("Effect of HE Non-completion", size(small)) vertical

	graph export "$figures/FigureS3.png", replace
			
capture log close
