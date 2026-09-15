***NOTE: This is a shorten ACT_MainPaperTables_REPLICATION.do file version which runs only analysis related to data presented in Tables 2, 3, 4 and 6. It runs on three datasets, which is the reason why activation of other datasets are prevented (see below). The path to files is specified, please, change, if needed when repeating the analysis.


* ****************************************************************************************
* PROGRAM: ACT_MainPaperTables_REPLICATION
* PURPOSE: This code replicates all main and appendix A tables and figures 
*	for the published version of "Price Subsidies, Diagnostic Tests, and Targeting of 
* 	Malaria Treatment: Evidence from a Randomized Controlled Trial"
* *****************************************************************************************


* FILE NAMES
* MAIN DATASETS
	global all_main ACT_AllMain_FINAL_pub 
	global all_ill_prob ACT_IllLvlMainWithMalProbs_FINAL_pub
* The activation command for the following dataset has been made inactive
	*global hh_follow_all ACT_HHFollowUp_All_FINAL_pub
	global chem_main_long ACT_PharmLogPos_FINAL_pub
* The activation command for the following two datasets has been made inactive
	*global baselines_mal ACT_BaselineMal_FINAL_pub
	*globa pharma_txn ACT_NonProjectTxns_FINAL_pub


* put the file path to the replication data in quotation marks after the finaldata global
* put the file path to the FDO do file in quotation marks after the dofiles global
* note: you must end you file paths with a slash: / for Mac, \ for PC for hte FDR code to run
	global finaldata "C:\Users\38164\Desktop\Cohen_AmEcoRev_2015_2lb5"
	global dofiles "C:\Users\38164\Desktop\Cohen_AmEcoRev_2015_2lb5"

	
cd "$finaldata"
	
* SET ADDITIONAL CONTROLS FOR SPECS
global cont "B_head_age_imputed B_head_age_missing"

* YOU MUST SET THE doFDR GLOBAL TO 'Yes' AND RUN CODE CONTINUOUSLY FROM THE TOP ALL THE WAY DOWN TO
*	APPENDIX TABLE A7 TO CREATE APPENDIX TABLE A7! (Note -- in order to run tables one by one you
*	should set doFDR to 'No')
 global doFDR "Yes"
* global doFDR "No"

clear
set more off 
set mem 500m
set matsize 1000

mat fdr=J(1000,3,.)
	local ftable=2
	local frow=1

		
* **************************************************************************************
* TABLE 2 :: IMPACT OF ACT AND RDT SUBSIDY ON CARE SEEKING, ACCESS
* **************************************************************************************
use $all_ill_prob, clear
	set more off
	if "$doFDR" == "No" {
		local ftable=1
		local frow=1
		}
keep if  first_ep==1 & ex_post==0 & rdt_any==0
	g byte ses_low= head_lit==0 if head_lit!=.	
	g young= LOG_patient_age<14
	g act_any= act40 | act60 | act100

mat t= J(12,9,.)
local rowst=1
foreach group in all {
local col=1
	foreach out in took_act took_act_chem took_act_hc care_chem care_hc care_nothing took_maltest took_antibio {
	local row=`rowst'
	
* SPECIFICATION 1 (POOLED)
reg `out' act_any i.totstrata ex_post $cont if `group'==1, clu(househo)
		foreach v in act_any {
			mat t[`row',`col']= _b[`v']
				local ++row
			mat t[`row',`col']= _se[`v']
				local ++row
		if "`group'"=="all" {		
			mat fdr[`frow',1]= `ftable'
			mat fdr[`frow',2]= 2*ttail(e(df_r),abs(_b[`v']/_se[`v']))
			mat fdr[`frow',3]= _b[`v']

				local ++frow
			}				
			}

* SPECIFICATION 2
	reg `out' act40 act60 act100 i.totstrata ex_post $cont if `group'==1, clu(househo)
		foreach v in act40 act60 act100 {
			mat t[`row',`col']= _b[`v']
				local ++row
			mat t[`row',`col']= _se[`v']
				local ++row

		if "`group'"=="all" {		
			mat fdr[`frow',1]= `ftable'
			mat fdr[`frow',2]= 2*ttail(e(df_r),abs(_b[`v']/_se[`v']))
			mat fdr[`frow',3]= _b[`v']
				local ++frow
			}			
			}
		test act40=act60=act100=0
			mat t[`row',`col']= r(p)
				local ++row		
		test act40=act60=act100
			mat t[`row',`col']= r(p)
				local ++row	
		qui sum `out' if `group'==1 & act500 & e(sample)
			mat t[`row',`col']= r(mean)
				local ++row
			mat t[`row',`col']= e(N)
	local ++col
	}
	local rowst=`row'+1
	}
mat li t
	
	
* **************************************************************************************
* TABLE 3 :: TARGETING RESULTS
* **************************************************************************************
local ftable=3
	if "$doFDR" == "No" local frow=1
		
use $all_ill_prob, clear
	keep if ex_post==0 & rdt_any==0 & took_act==1 & act500==0
	keep if first_ep==1
	g group=2
	tempfile endline
		save "`endline'"

use $chem_main_long, clear
	keep if ex_post==1 & used_act==1 & act500==0
	drop if rdt_any==1
	ren LOG_patient_age LOG_patient_age1
	ren used_act_adult adult
	g group=1
	tempfile tomerge
		save "`tomerge'"
	
use $all_main, clear
	set more off
	drop if rdt_any==1 | ex_post==0 | act500
	keep if used_act==1
	replace LOG_mal_prob21=. if rdt_pos==. | ex_post==0
	ren used_act_adult adult
	g group=0
	append using "`tomerge'"	
	append using "`endline'"
		
replace all=1
g young= adult==0 

g rdt_posA= rdt_pos if group==0
g rdt_posB= rdt_pos if group==1
g mal_probA= LOG_mal_prob21 if group==0
g mal_probB= LOG_mal_prob2 if group==1
g mal_probC= mal_prob2 if group==2

mat t=J(8,3,.)
local col=1
  foreach take in rdt_posA mal_probA mal_probC {	
	local row=1
	
	foreach type in all {	
		xi: reg `take' act60 act100 if `type'==1, clu(househo)
			foreach var in act60 act100 {
				mat t[`row',`col']= _b[`var']
					local ++row
				mat t[`row',`col']= _se[`var']
				local ++row		
			mat fdr[`frow',1]= `ftable'
			mat fdr[`frow',2]= 2*ttail(e(df_r),abs(_b[`var']/_se[`var']))
			mat fdr[`frow',3]= _b[`var']
				local ++frow				
				}
	qui test act60=act100==0	
	mat t[`row',`col']= r(p)
		local ++row
		
	qui test act60=act100
	mat t[`row',`col']= r(p)
		local ++row
		
	qui sum `take' if e(sample) & act40 & rdt_any==0
		mat t[`row',`col']= r(mean)
			local ++row
		mat t[`row',`col']= e(N)
			local ++row
	}	
	local ++col
	}
mat li t

* **********************************************************************************
* TABLE 4  :: MECHANISMS
* **********************************************************************************
local ftable=4
	if "$doFDR" == "No" local frow=1
use $all_main, clear
	set more off
	drop if act500 | rdt_any==1	
		g used_act_young= used_act_baby+used_act_kid+used_act_teen
		g frac_adult= used_act_adult if used_act==1
		g rdt_pos_young= rdt_pos if ex_post & used_act_young==1
		g rdt_pos_adult= rdt_pos if ex_post & used_act_adult==1
		g finalout= rdt_pos if ex_post & used_act==1		
local col=1	
mat t=J(7,4,.)
foreach out in used_act_young used_act_adult rdt_pos_young rdt_pos_adult {
local cme "i.totstrata $cont"
	if "`out'"=="rdt_pos_adult" | "`out'"=="rdt_pos_young" local cme ""	
	local row=1
	reg `out' act60 act100 `cme', r
		foreach price in act60 act100 {
			mat t[`row',`col']= _b[`price']
				local ++row
			mat t[`row',`col']= _se[`price']
				local ++row
			
			mat fdr[`frow',1]= `ftable'
			mat fdr[`frow',2]= 2*ttail(e(df_r),abs(_b[`price']/_se[`price']))
			mat fdr[`frow',3]= _b[`price']
				local ++frow
			}
			
			test act60=act100=0
			mat t[`row',`col']= r(p)
				local ++row			
			qui sum `out' if e(sample) & act40
			mat t[`row',`col']= r(mean)
				local ++row
			mat t[`row',`col']= e(N)
				local ++row
		local ++col
	}
mat li t


* **************************************************************
* TABLE 6: TARGETING TABLE FOR RDTS
* **************************************************************
local ftable=6
	if "$doFDR" == "No" local frow=1
use $all_main, clear
	drop if act500 
	keep if ex_post==1
g rdt_pos_trt= rdt_pos if sought_treat==1
g used_rdt_trt= used_rdt if sought_treat==1
g comp_neg= used_act==0 if used_rdt==1 & rdt_pos==0
g comp_pos= used_act==1 if used_rdt==1 & rdt_pos==1
g rdt_pos_act= rdt_pos if used_act==1

foreach var in used_rdt_trt comp_neg comp_pos {
	replace `var'=. if rdt_any==0
	}
	
foreach p in act40 act60 act100 {
	g R`p'= rdt_any*`p'
	}

local rowct=1
local col=1
mat t=J(10,4,.)	
foreach group in all {
foreach out in sought_treat rdt_pos_trt rdt_pos_act {
	ren `out' `out'_all
	local row=`rowct'

	local e1 ""
		if "`out'"=="sought_treat" local e1 "i.totstrata $cont"
		
	reg `out'_`group' rdt_any act60 act100 `e1', r
		mat t[`row',`col']= _b[rdt_any]
			local ++row
		mat t[`row',`col']= _se[rdt_any]
			local ++row
		if "`group'"=="all" {		
			mat fdr[`frow',1]= `ftable'
			mat fdr[`frow',2]= 2*ttail(e(df_r),abs(_b[rdt_any]/_se[rdt_any]))
			mat fdr[`frow',3]= _b[rdt_any]
				local ++frow
			}			
	reg `out'_`group' Ract40 Ract60 Ract100 act60 act100 `e1', r
		foreach cov in Ract40 Ract60 Ract100 {
			mat t[`row',`col']= _b[`cov']
				local ++row
			mat t[`row',`col']= _se[`cov']
				local ++row
		if "`group'"=="all" {		
			mat fdr[`frow',1]= `ftable'
			mat fdr[`frow',2]= 2*ttail(e(df_r),abs(_b[`cov']/_se[`cov']))
			mat fdr[`frow',3]= _b[`cov']
				local ++frow
			}
			}
		qui sum `out'_`group' if e(sample) & rdt_any==0 & act40
			mat t[`row',`col']= r(mean)
				local ++row
			mat t[`row',`col']= e(N)
				local ++row
	ren `out'_all `out'
	local ++col	
	}
	
	foreach out in used_rdt_trt {
		ren `out' `out'_all
		local row=`rowct'
		
	sum `out'_`group' if rdt_any==1		
			mat t[`row',`col']= r(mean)
				local ++row
				local ++row

	foreach val in act40 act60 act100 {		
		sum `out'_`group' if rdt_any==1	& `val'==1
			mat t[`row',`col']= r(mean)
				local ++row
				local ++row
				}
			local ++row
			qui sum `out'_`group' if rdt_any==1		
			mat t[`row',`col']= r(N)
	ren `out'_all `out'
	local ++col
	}				
	local rowct=`row'+1
	local col=1
	}
mat li t
	

	
