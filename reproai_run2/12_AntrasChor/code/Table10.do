# delimit ;
clear all;
set memory 1200m;
set matsize 4000;
set more off;

* Note: Memory requirements for this file are large;
* Name of working directory;
local dir "C:\Users\davinchor\Documents\Projects\Trade-Production Line\Antras-Chor Replication Material";
cd "`dir'";

******************************************************;
* TABLE 10: HECKMAN SELECTION ;
******************************************************;

local mergelist "downstreamness IOsigmas";
local mergelist1 "factorintensities randdintensity dispersion";
local mergelist2 "dbselection";

use USIOrelatedparty, clear;
keep if year>=2000 & year<=2010;
collapse (sum) imp_non imp_rel, by(isocode io2002 year);
gen imp_intrafirm = imp_rel/(imp_non+imp_rel);
gen tot_imp = imp_rel+imp_non;
la var imp_intrafirm "Intrafirm imports";
la var tot_imp "Total imports";
drop imp_non imp_rel;
keep if substr(io2002,1,1)=="3" & imp_intrafirm~=.;
fillin isocode io2002 year;
drop _f;
gen imp_intrafirmseen = (imp_intrafirm < .);

foreach f of local mergelist1 {;
	merge n:1 io2002 using `f';
	drop if _m==2;
	drop _m;
	cap drop M*;
	cap drop w1M*;
	cap drop Q*;
	cap drop w1Q*;
};

foreach f of local mergelist {;
	merge n:1 io2002 using `f';
	drop if _m==2;
	drop _m;
	cap drop Q*;
	cap drop w1Q*;
};

foreach f of local mergelist2 {;
	merge n:1 isocode using `f';
	drop if _m==2;
	drop _m;
};

cap drop ls_l_0005 lk_l_0005 lkequip_l_0005 lkplant_l_0005 lm_l_0005 lws_pay_0005 lrk_pay_0005 lcapex_pay_0005 lm_pay_0005 vadd_vship_0005 
		 ls_l_9605 lk_l_9605 lkequip_l_9605 lkplant_l_9605 lm_l_9605 lws_pay_9605 lrk_pay_9605 lcapex_pay_9605 lm_pay_9605 vadd_vship_9605 
		 disp1_2000 disp2_2000 disp3_2000 disp1_2005 disp2_2005 disp3_2005 w1disp1_2005 w1disp3_2005 
		 lus_randd_intensity_9806 lrandd_intensity_9806 w1vadd_vship_0005
		 fshare dfshare M1fshare M2fshare M1dfshare M2dfshare w1fshare w1dfshare w1M1fshare w1M2fshare w1M1dfshare w1M2dfshare
		 w1duse_tuse w1downmeasure w1M1duse_tuse w1M2duse_tuse w1M1downmeasure w1M2downmeasure sigma M1sigma M2sigma;
cap drop dbexport M1dbexport M2dbexport;
cap drop M1cost M2cost M1proc M2proc M1time M2time entrycost entryproc entrytime;
keep if M2dbentry~=.;
count;
* 467544 = 11 years * 168 countries * 253 industries;
egen ctyyear=group(isocode year);

cap drop M2dbentryX*;
g M2dbentryXlus_randd = M2dbentry*lus_randd_intensity_0005;
	
compress;

#delimit ;
* All years;
* Regressions on the extensive margin of trade (whether tot_imp is 0 or positive);

local logfile Table10.log;
local ofile Table10.out;
local defoptions "dec(3) coefastr se bracket nocons excel";
cap erase `ofile';
cap erase `logfile';

cap log close;
log using `logfile', replace;

keep if imp_intrafirmseen~=.;
xi, prefix(_CY) i.ctyyear;
	
areg imp_intrafirm year, absorb(ctyyear) cluster(io2002);
outreg2 year using `ofile', replace `defoptions';

local dsvarlist "duse_tuse downmeasure";

foreach dsvar of local dsvarlist {;

	foreach s of numlist 1/2 {;
		local m`s' w1M`s'sigma;
	};
	foreach s of numlist 1/2 {;
		cap drop `dsvar'X`m`s'';
		g `dsvar'X`m`s''=`dsvar'*`m`s'';
	};

	local wfactorcontrols "w1ls_l_0005 w1lkequip_l_0005 w1lkplant_l_0005 w1lm_l_0005 w1lus_randd_intensity_0005";
	local wdisp "w1disp3_2000";

	* Using just lus_randd_intensity as exclusion variable;
	local selectvar "M2dbentryXlus_randd lus_randd_intensity_0005";
	
	
	* First stage by hand;
	probit imp_intrafirmseen `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' `selectvar' _CY*, cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' `selectvar' using `ofile', append `defoptions' ctitle(probit);	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;
	test `selectvar';
	
	keep if e(sample);
	
	cap drop probitxb;
	cap drop invmills;
	predict probitxb, xb;
	gen invmills = normalden(probitxb)/normal(probitxb);
	
	* Second stage by hand;
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' invmills [aw=tot_imp] if imp_intrafirmseen==1, 
		absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' invmills using `ofile', 
		append `defoptions';
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;	
	cap drop w_resid;
	predict w_resid if e(sample), residuals;
		
	* Benchmark with no correction;
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' [aw=tot_imp] if imp_intrafirmseen==1, 
		absorb(ctyyear) cluster(io2002);
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' using `ofile', 
		append `defoptions';	
	test `dsvar'X`m1' `dsvar'X`m2';
	test `dsvar'X`m2'-`dsvar'X`m1'=0;
	
	
};
	
log close;




