# delimit ;
clear all;
set memory 400m;
set more off;

* Name of working directory;
local dir "C:\Users\davinchor\Documents\Projects\Trade-Production Line\Antras-Chor Replication Material";
cd "`dir'";

********************************************************************************************************;
* APPENDIX TABLE 9: Alternative elasticity measure capturing cross-product substitutability (DUSE_TUSE) ;
********************************************************************************************************;

local mergelist "downstreamness IOsigmas33 factorintensities randdintensity dispersion";

* START WITH INDUSTRY-YEAR REGRESSIONS;

use USIOrelatedparty.dta, clear;
keep if year>=2000 & year<=2010;
collapse (sum) imp_non imp_rel, by(io2002 year);
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
compress;

foreach s of numlist 1/2 {;
	local m`s' w1M`s'sigma;
};
foreach s of numlist 1/5 {;
	local q`s' w1Q`s'sigma;
};

local dsvar duse_tuse;

local logfile AppTable9.log;
local ofile AppTable9.out;
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
	
	local wfactorcontrols "w1ls_l_0005 w1lk_l_0005 w1lm_l_0005 w1lus_randd_intensity_0005";
	local wdisp "w1disp3_2000";
	
	areg imp_intrafirm `dsvar' `wfactorcontrols' `wdisp', absorb(year) cluster(io2002);
	outreg2 `dsvar' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');
	test `dsvar';
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp', absorb(year) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;
		
	local wfactorcontrols "w1ls_l_0005 w1lkequip_l_0005 w1lkplant_l_0005 w1lm_l_0005 w1lus_randd_intensity_0005";
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp', absorb(year) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;

	* Run separate regressions for substitutes and complements subsamples;
	areg imp_intrafirm `dsvar' `wfactorcontrols' `wdisp' if `m1'==1, absorb(year) cluster(io2002);
	outreg2 `dsvar' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');
	test `dsvar';
		
	areg imp_intrafirm `dsvar' `wfactorcontrols' `wdisp' if `m2'==1, absorb(year) cluster(io2002);
	outreg2 `dsvar' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');
	test `dsvar';
	
	* Weighted regression;
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' [aw=tot_imp], absorb(year) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;
	
log close;



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
egen ctyyear=group(isocode year);
compress;

log using `logfile', append;

	foreach s of numlist 1/2 {;
		cap drop `dsvar'X`m`s'';
		g `dsvar'X`m`s''=`dsvar'*`m`s'';
	};

	local wfactorcontrols "w1ls_l_0005 w1lkequip_l_0005 w1lkplant_l_0005 w1lm_l_0005 w1lus_randd_intensity_0005";
	local wdisp "w1disp3_2000";
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp', absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;

	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' [aw=tot_imp], absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`depvar');	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;

log close;




	
