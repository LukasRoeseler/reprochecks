# delimit ;
clear all;
set memory 400m;
set more off;

* Name of working directory;
local dir "C:\Users\davinchor\Documents\Projects\Trade-Production Line\Antras-Chor Replication Material";
cd "`dir'";

********************************************;
* APPENDIX TABLES 1 & 2: SUMMARY STATISTICS ;
********************************************;

local mergelist "downstreamness IOsigmas factorintensities randdintensity dispersion
	intermediation contractibility inputimportance";

use USIOrelatedparty, clear;
collapse (sum) imp_non imp_rel, by(io2002 year);
gen imp_intrafirm = imp_rel/(imp_non+imp_rel);
gen tot_imp = imp_rel+imp_non;
la var imp_intrafirm "Intrafirm imports";
la var tot_imp "Total imports";
drop imp_non imp_rel;
foreach f of local mergelist {;
	merge n:1 io2002 using `f';
	drop if _m==2;
	drop _m;
};
keep if substr(io2002,1,1)=="3" & imp_intrafirm~=.;
compress;


local logfile AppTable1.log;
cap erase `logfile';

cap log close;
log using `logfile', replace;

* Summary statistics for intrafirm trade share;
bysort year: summ imp_intrafirm, det;
sort io2002 year;
bysort io2002: keep if _n==1;

* Number of industries in sample;
count if duse_tuse~=.;
count if downmeasure~=.;

* Summary statistics for industry characteristics;

local factorcontrols "ls_l_0005 lk_l_0005 lkequip_l_0005 lkplant_l_0005 lm_l_0005 lus_randd_intensity_0005";
local wfactorcontrols "w1ls_l_0005 w1lk_l_0005 w1lkequip_l_0005 w1lkplant_l_0005 w1lm_l_0005 w1lus_randd_intensity_0005";
local disp "disp3_2000";
local wdisp "w1disp3_2000";
local robustcontrols "vadd_vship_0005 inputimportance2 BJRSinterm nRj1l";
local wrobustcontrols "nw1Rj1l";

local indvarlist1 "duse_tuse downmeasure fshare"; 
foreach v of local indvarlist1 {;
	summ `v', det;
};	

local indvarlist2 "`factorcontrols' `disp' `robustcontrols'"; 
foreach v of local indvarlist2 {;
	summ `v', det;
};	

local indvarlist3 "w1sigma `wfactorcontrols' `wdisp' `wrobustcontrols'"; 
foreach v of local indvarlist3 {;
	summ `v', det;
};	

log close;


# delimit ;
* Correlations between downstreamness and industry characteristics;

local logfile AppTable2.log;
cap erase `logfile';

cap log close;
log using `logfile', replace;

local indvarlist2 "`factorcontrols' `disp' `robustcontrols'"; 
foreach v of local indvarlist2 {;
	pwcorr duse_tuse `v', sig;
	pwcorr downmeasure `v', sig;
};	

local indvarlist3 "w1sigma `wfactorcontrols' `wdisp' `wrobustcontrols'"; 
foreach v of local indvarlist3 {;
	pwcorr duse_tuse `v', sig;
	pwcorr downmeasure `v', sig;
};	

log close;


# delimit ;
* Share of unreported trade flows;
* Footnote 18;

use USIOrelatedparty, clear;
collapse (sum) imp_non imp_rel imp_not, by(year);
gen imp_notshare = imp_not/(imp_non + imp_rel + imp_not);
summ imp_notshare, det;


use USIOrelatedparty, clear;
collapse (sum) imp_non imp_rel imp_not, by(io2002 year);
gen imp_notshare = imp_not/(imp_non + imp_rel + imp_not);
gen tot_imp = imp_non + imp_rel + imp_not;
gen tot_imp2 = imp_non + imp_rel;
gen ln_imp_notshare = ln(imp_notshare);
gen ln_tot_imp = ln(tot_imp);
gen ln_tot_imp2 = ln(tot_imp2);

pwcorr ln_imp_notshare ln_tot_imp ln_tot_imp2 if year>=2000 & year<=2010, sig;


