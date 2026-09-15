# delimit ;
clear all;
set memory 400m;
set more off;

* Name of working directory;
local dir "C:\Users\davinchor\Documents\Projects\Trade-Production Line\Antras-Chor Replication Material";
cd "`dir'";

******************************************************;
* APPENDIX TABLE 6: DOWNMEASURE YEAR-BY-YEAR ;
******************************************************;

local mergelist "downstreamness IOsigmas factorintensities randdintensity dispersion";

* INDUSTRY-YEAR REGRESSIONS;

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

local dsvar downmeasure;

local logfile AppTable6.log;
local ofile AppTable6.out;
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
	
	foreach n of numlist 2000/2010 {;
	
		reg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' if year==`n', r;
		outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`n');	
		test `dsvar'X`m1' `dsvar'X`m2';
		test `dsvar'X`m2'-`dsvar'X`m1'=0;

	};
	
	foreach n of numlist 2000/2010 {;
	
		reg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' if year==`n' [aw=tot_imp], r;
		outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`n');	
		test `dsvar'X`m1' `dsvar'X`m2';
		test `dsvar'X`m2'-`dsvar'X`m1'=0;

	};
	
	
	foreach s of numlist 1/5 {;
		cap drop `dsvar'X`q`s'';
		g `dsvar'X`q`s''=`dsvar'*`q`s'';
	};

	foreach n of numlist 2000/2010 {;
	
		reg imp_intrafirm `dsvar'X`q1' `dsvar'X`q2' `dsvar'X`q3' `dsvar'X`q4' `dsvar'X`q5' `q2' `q3' `q4' `q5' 
			`wfactorcontrols' `wdisp' if year==`n', r;
		outreg2 `dsvar'X`q1' `dsvar'X`q2' `dsvar'X`q3' `dsvar'X`q4' `dsvar'X`q5' `q2' `q3' `q4' `q5' 
			`wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`n');	
		test `dsvar'X`q1' `dsvar'X`q2' `dsvar'X`q3' `dsvar'X`q4' `dsvar'X`q5';
		test `dsvar'X`q5'-`dsvar'X`q1'=0;

	};
	
	foreach n of numlist 2000/2010 {;
	
		reg imp_intrafirm `dsvar'X`q1' `dsvar'X`q2' `dsvar'X`q3' `dsvar'X`q4' `dsvar'X`q5' `q2' `q3' `q4' `q5' 
			`wfactorcontrols' `wdisp' if year==`n' [aw=tot_imp], r;
		outreg2 `dsvar'X`q1' `dsvar'X`q2' `dsvar'X`q3' `dsvar'X`q4' `dsvar'X`q5' `q2' `q3' `q4' `q5' 
			`wfactorcontrols' `wdisp' using `ofile', append `defoptions' ctitle(`n');	
		test `dsvar'X`q1' `dsvar'X`q2' `dsvar'X`q3' `dsvar'X`q4' `dsvar'X`q5';
		test `dsvar'X`q5'-`dsvar'X`q1'=0;

	};
	
log close;

