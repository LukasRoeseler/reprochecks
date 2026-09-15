# delimit ;
clear all;
set memory 400m;
set more off;

* Name of working directory;
local dir "C:\Users\davinchor\Documents\Projects\Trade-Production Line\Antras-Chor Replication Material";
cd "`dir'";

******************************************************************************;
* APPENDIX TABLE 8: ROBUSTNESS CHECKS FOR DOWNMEASURE (COUNTRY-INDUSTRY-YEAR) ;
******************************************************************************;

local mergelist "downstreamness IOsigmas factorintensities randdintensity dispersion 
	intermediation contractibility inputimportance";
local mergelist2 "rulelaw";

* COUNTRY-INDUSTRY-YEAR REGRESSIONS;

use USIOrelatedparty.dta, clear;
keep if year>=2000 & year<=2010;
collapse (sum) imp_non imp_rel, by(isocode io2002 year);
gen imp_intrafirm = imp_rel/(imp_non+imp_rel);
lab var imp_intrafirm "Intrafirm imports";
gen tot_imp = imp_rel+imp_non;
la var tot_imp "Total imports";
foreach f of local mergelist {;
	merge n:1 io2002 using `f';
	drop if _m==2;
	drop _m;
};
keep if substr(io2002,1,1)=="3" & imp_intrafirm~=.;
egen ctyyear = group(isocode year);
compress;

foreach s of numlist 1/2 {;
	local m`s' w1M`s'sigma;
};
foreach s of numlist 1/5 {;
	local q`s' w1Q`s'sigma;
};

foreach f of local mergelist2 {;
	merge n:1 isocode year using `f';
	drop if _m==2;
	drop _m;
};
local rauchsufflist "1l";
foreach r of local rauchsufflist {;
	gen nRj`r'Xrule = nRj`r'*rulelaw;
	gen nw1Rj`r'Xrule  = nw1Rj`r'*rulelaw;
};
compress;


local dsvar downmeasure;

local logfile AppTable8.log;
local ofile AppTable8.out;
local defoptions "dec(3) coefastr se bracket nocons excel";
cap erase `ofile';
cap erase `logfile';

cap log close;
log using `logfile', replace;

	areg imp_intrafirm year, absorb(year) cluster(io2002);
	outreg2 year using `ofile', replace `defoptions';

	foreach s of numlist 1/2 {;
		cap drop `dsvar'X`m`s'';
		g `dsvar'X`m`s''=`dsvar'*`m`s'';
	};
		
	local wfactorcontrols "w1ls_l_0005 w1lkequip_l_0005 w1lkplant_l_0005 w1lm_l_0005 w1lus_randd_intensity_0005";
	local wdisp "w1disp3_2000";

	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 [aw=tot_imp], absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' inputimportance2 [aw=tot_imp], absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' inputimportance2 using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;

	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' BJRSinterm [aw=tot_imp], absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' BJRSinterm using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nw1Rj1l [aw=tot_imp], absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nw1Rj1l using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;

	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nRj1lXrule nw1Rj1l nw1Rj1lXrule [aw=tot_imp], absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nRj1lXrule nw1Rj1l nw1Rj1lXrule using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' 
		vadd_vship_0005 inputimportance2 BJRSinterm nRj1l nRj1lXrule nw1Rj1l nw1Rj1lXrule [aw=tot_imp], absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' 
		vadd_vship_0005 inputimportance2 BJRSinterm nRj1l nRj1lXrule nw1Rj1l nw1Rj1lXrule using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;

	
log close;

