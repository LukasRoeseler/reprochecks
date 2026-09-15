#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

use DATA_TABLE9;

replace q_elec=q_elec/1000;  /* electricity now in 1000 kwh */

su q_elec;
gl qmean = r(mean);
su aircon;
gl acmean = r(mean);
su p_elec;
gl pmean = r(mean);
su p_elecXaircon;
gl p_elecXairconmean = r(mean);

drop b10_7;


/** de-mean X variables **/
foreach var of varlist b10_* inctot_* homeowner rooms_* hhsize_* unitsstr_* builtyr_* {;
 egen m_`var'=mean(`var');
 replace `var'=`var'-m_`var';
};




/* column 1 */

eststo: reg q_elec p_elec aircon,  cluster(stfips);

summ q_elec;
gen qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean;
summ qmean;
drop qmean;
gl qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean;

nlcom (0.5*($acmean*((-_b[_cons]-_b[aircon])/_b[p_elec]) + (1-$acmean)*((-_b[_cons])/_b[p_elec]) - $pmean)*$qmean
       
       -

       0.5*((-_b[_cons]/_b[p_elec]) - (-_b[_cons]*($pmean/$qmean))/(($pmean/$qmean)*_b[p_elec]-1)) * (-_b[_cons]/(($pmean/$qmean)*_b[p_elec] - 1)))*0.081*1000;

di "nlcom outputs estimated consumer surplus in ($2012) Billions";	


/* column 2 */

eststo: reg q_elec p_elec aircon p_elecXaircon,  cluster(stfips);

gen qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean+_b[p_elecXaircon]*$p_elecXairconmean;
summ qmean;
drop qmean;
gl qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean+_b[p_elecXaircon]*$p_elecXairconmean;

nlcom  (0.5*($acmean*((-_b[_cons]-_b[aircon])/(_b[p_elec]+_b[p_elecXaircon]))+(1-$acmean)*((-_b[_cons])/(_b[p_elec]))-$pmean)*$qmean

       -

       0.5*((-_b[_cons]/_b[p_elec]) - (-_b[_cons]*($pmean/$qmean))/(($pmean/$qmean)*_b[p_elec]-1)) * (-_b[_cons]/(($pmean/$qmean)*_b[p_elec] - 1)))*0.081*1000;

di "nlcom outputs estimated consumer surplus in ($2012) Billions";	



/* column 3 */

eststo: reg q_elec p_elec aircon b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* ,  cluster(stfips);

	g xb3 = 0;
	foreach v of varlist b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* {;
		qui su `v';
		loc rmean = r(mean);
		qui replace xb3 = xb3 + (`rmean' * _b[`v']);
		};

gen qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean + xb3;
summ qmean;
drop qmean;
gl qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean + xb3;

nlcom  (0.5*($acmean*((-_b[_cons]-_b[aircon]-xb3)/(_b[p_elec]))+(1-$acmean)*((-_b[_cons]-xb3)/(_b[p_elec]))-$pmean)*$qmean

       -

       0.5*(((-_b[_cons]-xb3)/_b[p_elec]) - ((-_b[_cons]-xb3)*($pmean/$qmean))/(($pmean/$qmean)*_b[p_elec]-1)) * ((-_b[_cons]-xb3)/(($pmean/$qmean)*_b[p_elec] - 1)))*0.081*1000;

di "nlcom outputs estimated consumer surplus in ($2012) Billions";	



	
/* column 4 */

reg p_elec div_* aircon b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_*, cluster(stfips);
testparm div_*;

eststo: ivregress 2sls q_elec (p_elec = div_*) aircon b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* , small cluster(stfips);
	
	drop xb3;	
        g xb3 = 0;
        foreach v of varlist b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* {;
                qui su `v';
                loc rmean = r(mean);
                qui replace xb3 = xb3 + (`rmean' * _b[`v']);
                };

gen qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean + xb3;
summ qmean;
drop qmean;               
gl qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean + xb3;

nlcom  (0.5*($acmean*((-_b[_cons]-_b[aircon]-xb3)/(_b[p_elec]))+(1-$acmean)*((-_b[_cons]-xb3)/(_b[p_elec]))-$pmean)*$qmean

       -

       0.5*(((-_b[_cons]-xb3)/_b[p_elec]) - ((-_b[_cons]-xb3)*($pmean/$qmean))/(($pmean/$qmean)*_b[p_elec]-1)) * ((-_b[_cons]-xb3)/(($pmean/$qmean)*_b[p_elec] - 1)))*0.081*1000;

di "nlcom outputs estimated consumer surplus in ($2012) Billions";	




/* column 5 */

gen pp_b10_1=p_elec*b10_1;
gen pp_b10_2=p_elec*b10_2;
gen pp_b10_3=p_elec*b10_3;
gen pp_b10_4=p_elec*b10_4;
gen pp_b10_5=p_elec*b10_5;
gen pp_b10_6=p_elec*b10_6;
gen pp_b10_8=p_elec*b10_8;
gen pp_b10_9=p_elec*b10_9;
gen pp_b10_10=p_elec*b10_10;

forvalues i=2/9 {;
 gen pp_rooms_`i'=p_elec*rooms_`i';
};

forvalues i=2/6 {;
 gen pp_hhsize_`i'=p_elec*hhsize_`i';
};

logit aircon p_elec pp_* b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* , cluster(stfips);
predict xb_ac if e(sample);

g xb_noac = 1-xb_ac;                      
g       selection = (xb_noac * ln(xb_noac) / xb_ac  ) + ln(xb_ac)   if aircon == 1;
replace selection = (xb_ac   * ln(xb_ac)   / xb_noac) + ln(xb_noac) if aircon == 0;

gen term1=(xb_noac*ln(xb_noac)/(1-xb_noac)) + ln(xb_ac);
gen term0=(xb_ac*ln(xb_ac)/(1-xb_ac)) + ln(xb_noac);

summ aircon term1 term0 selection;

summ term1;
gl term1 = r(mean);
summ term0;
gl term0 = r(mean);


reg p_elec div_* aircon b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* selection, cluster(stfips);
testparm div_*;

eststo: ivregress 2sls q_elec (p_elec = div_*) aircon b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* selection, small cluster(stfips);

        drop xb3;
        g xb3 = 0;
        foreach v of varlist b10_* hhsize_* inctot_* homeowner rooms_* builtyr_* unitsstr_* {;
                qui su `v';
                loc rmean = r(mean);
                qui replace xb3 = xb3 + (`rmean' * _b[`v']);
                };
gl xb3=xb3;

gen qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean + xb3 + _b[selection]*$term1*$acmean + _b[selection]*$term0*(1-$acmean);
summ qmean;
drop qmean;               
gl qmean = _b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean + xb3 + _b[selection]*$term1*$acmean + _b[selection]*$term0*(1-$acmean);

gl S = $acmean*_b[selection]*($term0) + (1-$acmean)*_b[selection]*($term1);


nlcom  1000*0.081*0.5*(( ($acmean*((-_b[_cons]-_b[aircon]-$xb3-_b[selection]*$term1)/(_b[p_elec]))) + (1-$acmean)*((-_b[_cons]-$xb3-_b[selection]*$term0)/(_b[p_elec])) - $pmean )*(_b[_cons]+_b[aircon]*$acmean+_b[p_elec]*$pmean + $S))

-
       1000*0.081*0.5*(((-_b[_cons]-$xb3-$S)/_b[p_elec]) - ((-_b[_cons]-$xb3-$S)*($pmean/$qmean))/(($pmean/$qmean)*_b[p_elec]-1)) * (-_b[_cons]-$xb3-$S)/(($pmean/$qmean)*_b[p_elec] - 1);

di "nlcom outputs estimated consumer surplus in ($2012) Billions";	



