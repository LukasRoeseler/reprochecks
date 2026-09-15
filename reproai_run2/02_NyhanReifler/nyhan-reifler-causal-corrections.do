**********************************************
*Replication code for                        *
*Displacing Misinformation about Events:     *
*An Experimental Test of Causal Corrections  *
*Brendan Nyhan and Jason Reifler             *
*Forthcoming, JEPS                           *
**********************************************

clear all

cd "C:\Users\billc\Downloads"

use "causal-replication.dta", clear

/*Table 2 - note lincom results correspond to significance test table in appendix*/
reg swensenfav innuendo denial causal [aweight=aw]

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

svy: reg swensenfav innuendo denial causal

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

reg acceptedbribes innuendo denial causal [aweight=aw]

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

svy: reg acceptedbribes innuendo denial causal  

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

reg resigninvest denial causal [aweight=aw]

lincom causal-denial

svy: reg resigninvest denial causal 

lincom causal-denial

/*Figures 1-3*/

preserve

collapse (mean) swensenfav resigninvest acceptedbribes (semean) swensenfavse=swensenfav resigninvestse=resigninvest acceptedbribesse=acceptedbribes [aweight=aw],by(swensenrand) 

foreach var of varlist swensenfav resigninvest acceptedbribes {
gen `var'll=`var'-(1.96*`var'se)
gen `var'ul=`var'+(1.96*`var'se)
}

twoway (scatter swensenfav swensenrand, ytitle("") mcolor(black) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) scheme(s2mono) yscale(r(1 3.25)) xlabel(1 `" "No reason"  "given" "' 2 `" "Innuendo"  "only" "' 3 `" "Innuendo +"  "allegation denial" "' 4 `" "Innuendo +"  "denial + causal" "',labsize(*.8)) ylabel(1 `" "Very"  "unfavorable" "' 2 `" "Somewhat"  "unfavorable" "' 3 `" "Slightly"  "unfavorable" "',nogrid labsize(*.8) angle(0)) yscale(r(1(1)3)) xscale(r(.75 4.25)) xtick(none) xmtick(none) xtitle("Reason for resignation",margin(medsmall) size(*.8))) (rspike swensenfavul swensenfavll swensenrand,lcolor(black) legend(off))
graph export "fig1.eps",replace

twoway (scatter acceptedbribes swensenrand, ytitle("")  mcolor(black) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) scheme(s2mono) yscale(r(1 3.25)) xlabel(1 `" "No reason"  "given" "' 2 `" "Innuendo"  "only" "' 3 `" "Innuendo +"  "allegation denial" "' 4 `" "Innuendo +"  "denial + causal" "',labsize(*.8)) ylabel(1 `" "Not at all"  "likely" "' 2 `" "A little"  "likely" "' 3 `" "Moderately"  "likely" "' 4 `" "Very"  "likely" "',nogrid labsize(*.8) angle(0)) yscale(r(1(1)3)) xscale(r(.75 4.25)) xtick(none) xmtick(none) xtitle("Reason for resignation",margin(medsmall) size(*.8))) (rspike acceptedbribesul acceptedbribesll swensenrand,lcolor(black) legend(off))
graph export "fig2.eps",replace

drop if swensenrand==1

twoway (scatter resigninvest swensenrand, ytitle("") mcolor(black) graphregion(fcolor(white) ifcolor(none)) plotregion(fcolor(none) lcolor(white) ifcolor(none) ilcolor(none)) scheme(s2mono) yscale(r(1 3.25)) xlabel(2 `" "Innuendo"  "only" "' 3 `" "Innuendo +"  "allegation denial" "' 4 `" "Innuendo +"  "denial + causal" "',labsize(*.8)) ylabel(1 `" "Not likely"  "at all" "' 2 `" "Not very"  "likely" "' 3 `" "Somewhat"  "likely" "' 4 `" "Very"  "likely" "',nogrid labsize(*.8) angle(0)) yscale(r(1(1)3)) xscale(r(1.75 4.25)) xtick(none) xmtick(none) xtitle("Reason for resignation",margin(medsmall) size(*.8))) (rspike resigninvestul resigninvestll swensenrand,lcolor(black) legend(off))
graph export "fig3.eps",replace

restore

/*Appendix*/

/*balance tests - unweighted*/
/*note the putexcel command requires Stata 13*/
putexcel B1=("Control") C1=("Innuendo") D1=("Denial") E1=("Causal") F1=("Total") using jepsbalance, replace

gen fakewt=1 /*fake survey weights*/
svyset [pweight=fakewt] /*more convenient for output of proportions*/

/*estimated - don't have exact birthdate*/
gen age=2012-pp_birthyr

gen agecat4=.
replace agecat4=1 if age>=18 & age<=29
replace agecat4=2 if age>=30 & age<=44
replace agecat4=3 if age>=45 & age<=59
replace agecat4=4 if age>=60 & age!=.

gen control=(swensenrand==1)

/*age marginals*/
putexcel A22=("Age") A23=("18-29") A24=("30-44") A25=("45-59") A26=("60+") using jepsbalance, modify

tab agecat4 swensenrand, chi
svy: tab agecat4 swensenrand

svy,subpop(control): tab agecat4 
matrix AgeControl = e(b)'
putexcel B23=matrix(AgeControl) using jepsbalance, modify

svy,subpop(innuendo): tab agecat4
matrix AgeDanger = e(b)'
putexcel C23=matrix(AgeDanger) using jepsbalance, modify

svy,subpop(denial): tab agecat4 
matrix AgeCorrection = e(b)'
putexcel D23=matrix(AgeCorrection) using jepsbalance, modify

svy,subpop(causal): tab agecat4 
matrix AgeCorrection2 = e(b)'
putexcel E23=matrix(AgeCorrection2) using jepsbalance, modify

svy: tab agecat4
matrix AgeTotal = e(b)'
putexcel F23=matrix(AgeTotal) using jepsbalance, modify

/*gender marginals*/
putexcel A4=("Gender") A5=("Male") A6=("Female") using jepsbalance, modify

tab pp_gender swensenrand, chi
svy: tab pp_gender swensenrand

svy,subpop(control): tab pp_gender
matrix GenderControl = e(b)'
putexcel B5=matrix(GenderControl) using jepsbalance, modify

svy,subpop(innuendo): tab pp_gender 
matrix GenderDanger = e(b)'
putexcel C5=matrix(GenderDanger) using jepsbalance, modify

svy,subpop(denial): tab pp_gender
matrix GenderCorrection = e(b)'
putexcel D5=matrix(GenderCorrection) using jepsbalance, modify

svy,subpop(causal): tab pp_gender
matrix GenderCorrection2 = e(b)'
putexcel E5=matrix(GenderCorrection2) using jepsbalance, modify

svy: tab pp_gender
matrix GenderTotal = e(b)'
putexcel F5=matrix(GenderTotal) using jepsbalance, modify

/*education marginals*/
putexcel A8=("Education") A9=("High School or less") A10=("Some college") A11=("College grad") A12=("Post-grad") using jepsbalance, modify

gen neweduc=pp_educ
recode neweduc (2=1) (3=2) (4=2) (5=3) (6=4)

tab pp_educ swensenrand, chi
svy: tab pp_educ swensenrand

tab neweduc swensenrand, chi
svy: tab neweduc swensenrand

svy,subpop(control): tab neweduc
matrix EducControl = e(b)'
putexcel B9=matrix(EducControl) using jepsbalance, modify

svy,subpop(innuendo): tab neweduc
matrix EducDanger = e(b)'
putexcel C9=matrix(EducDanger) using jepsbalance, modify

svy,subpop(denial): tab neweduc
matrix EducCorrection = e(b)'
putexcel D9=matrix(EducCorrection) using jepsbalance, modify

svy,subpop(causal): tab neweduc
matrix EducCorrection2 = e(b)'
putexcel E9=matrix(EducCorrection2) using jepsbalance, modify

svy: tab neweduc
matrix EducTotal = e(b)'
putexcel F9=matrix(EducTotal) using jepsbalance, modify

/*race marginals*/
gen newrace=pp_race
recode newrace (5=4) (6=4) (7=4)

putexcel A14=("Race/ethnicity") A15=("White") A16=("Black") A17=("Hispanic") A18=("Other") using jepsbalance, modify

tab pp_race swensenrand, chi
svy: tab pp_race swensenrand

tab newrace swensenrand, chi
svy: tab newrace swensenrand

svy,subpop(control): tab newrace
matrix RaceControl = e(b)'
putexcel B15=matrix(RaceControl) using jepsbalance, modify

svy,subpop(innuendo): tab newrace
matrix RaceDanger = e(b)'
putexcel C15=matrix(RaceDanger) using jepsbalance, modify

svy,subpop(denial): tab newrace
matrix RaceCorrection = e(b)'
putexcel D15=matrix(RaceCorrection) using jepsbalance, modify

svy,subpop(causal): tab newrace
matrix RaceCorrection2 = e(b)'
putexcel E15=matrix(RaceCorrection2) using jepsbalance, modify

svy: tab newrace
matrix RaceTotal = e(b)'
putexcel F15=matrix(RaceTotal) using jepsbalance, modify

/*ordered probit results*/

oprobit swensenfav innuendo denial causal [aweight=aw]

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

svy: oprobit swensenfav innuendo denial causal

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

oprobit acceptedbribes innuendo denial causal [aweight=aw]

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

svy: oprobit acceptedbribes innuendo denial causal  

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

oprobit resigninvest denial causal [aweight=aw]

lincom causal-denial

svy: oprobit resigninvest denial causal 

lincom causal-denial

/*unweighted results*/

reg swensenfav innuendo denial causal

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial 

reg acceptedbribes innuendo denial causal

lincom denial-innuendo 
lincom causal-innuendo 
lincom causal-denial

reg resigninvest denial causal

lincom causal-denial 

/*significance tests: see lincom results for Table 2 above*/

/*test for recall diffs*/
gen recall=(GSU213==3)+(GSU214==2)+(GSU215==3)

preserve

drop if swensenrand==1

reg recall denial causal [aweight=aw]

lincom causal-denial 

svy: reg recall denial causal 

lincom causal-denial 

restore
