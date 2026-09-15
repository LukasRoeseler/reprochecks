******************************************************
* TABLE 6: ROBUSTNESS CHECKS FOR DUSE_TUSE 
******************************************************

local mergelist "downstreamness IOsigmas factorintensities randdintensity dispersion intermediation contractibility inputimportance"

* INDUSTRY-YEAR REGRESSIONS

use USIOrelatedparty.dta, clear
keep if year>=2000 & year<=2010
collapse (sum) imp_non imp_rel, by(io2002 year)
gen imp_intrafirm = imp_rel/(imp_non+imp_rel)
lab var imp_intrafirm "Intrafirm imports"
gen tot_imp = imp_rel+imp_non
la var tot_imp "Total imports"
foreach f of local mergelist {
	merge n:1 io2002 using `f'
	drop if _m==2
	drop _m
}
keep if substr(io2002,1,1)=="3" & imp_intrafirm~=.
compress

foreach s of numlist 1/2 {
	local m`s' w1M`s'sigma
}
foreach s of numlist 1/5 {
	local q`s' w1Q`s'sigma
}

local dsvar duse_tuse

local logfile Table6.log
local ofile Table6.out
local defoptions "dec(3) coefastr se bracket nocons excel"
cap erase `ofile'
cap erase `logfile'

cap log close
log using `logfile', replace

	areg imp_intrafirm year, absorb(year) cluster(io2002)
	outreg2 year using `ofile', replace `defoptions'

	foreach s of numlist 1/2 {
		cap drop `dsvar'X`m`s''
		g `dsvar'X`m`s''=`dsvar'*`m`s''
	}
		
	local wfactorcontrols "w1ls_l_0005 w1lkequip_l_0005 w1lkplant_l_0005 w1lm_l_0005 w1lus_randd_intensity_0005"
	local wdisp "w1disp3_2000"

	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005, absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' inputimportance2, absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' inputimportance2 using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0

	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' BJRSinterm, absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' BJRSinterm using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nw1Rj1l, absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nw1Rj1l using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 inputimportance2 BJRSinterm nRj1l nw1Rj1l, absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 inputimportance2 BJRSinterm nRj1l nw1Rj1l using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0
	
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 [aw=tot_imp], absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' inputimportance2 [aw=tot_imp], absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' inputimportance2 using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0

	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' BJRSinterm [aw=tot_imp], absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' BJRSinterm using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nw1Rj1l [aw=tot_imp], absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' nRj1l nw1Rj1l using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0
	
	areg imp_intrafirm `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 inputimportance2 BJRSinterm nRj1l nw1Rj1l [aw=tot_imp], absorb(year) cluster(io2002)
	outreg2 `dsvar'X`m1' `dsvar'X`m2' `m2' `wfactorcontrols' `wdisp' vadd_vship_0005 inputimportance2 BJRSinterm nRj1l nw1Rj1l using `ofile', append `defoptions' ctitle(`depvar')	
	test `dsvar'X`m1' `dsvar'X`m2'
	test `dsvar'X`m2'-`dsvar'X`m1'=0

	
log close

