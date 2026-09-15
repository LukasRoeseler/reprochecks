#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

/** All-Age Mortality Rate **/

use DATA_1900_2004;
keep if year>=1900 & year<=1959;

collapse (sum) dths_tot (mean) totalpop uscr, by(stfips year);

drop if dths_tot==0;

gen drate=100000*dths_tot/totalpop;

summ drate [aw=totalpop];
table uscr [aw=totalpop], c(mean drate);
clear;


use DATA_1900_2004;
keep if year>=1960 & year<=2004;

collapse (sum) dths_tot (mean) totalpop uscr, by(stfips year);

drop if dths_tot==0;

gen drate=100000*dths_tot/totalpop;

summ drate [aw=totalpop];
table uscr [aw=totalpop], c(mean drate);
clear;



/** Temperature Variables **/

use DATA_1900_2004;
keep if year>=1900 & year<=1959;

replace b10_4=b10_4+b10_3+b10_2+b10_1;

collapse (sum) b10_4 b10_9 b10_10 (mean) totalpop uscr, by(stfips year);

summ b10_4 b10_9 b10_10 [aw=totalpop];
table uscr [aw=totalpop], c(mean b10_4 mean b10_9 mean b10_10);
clear;


use DATA_1900_2004;
keep if year>=1960 & year<=2004;

replace b10_4=b10_4+b10_3+b10_2+b10_1;

collapse (sum) b10_4 b10_9 b10_10 (mean) totalpop uscr, by(stfips year);

summ b10_4 b10_9 b10_10 [aw=totalpop];
table uscr [aw=totalpop], c(mean b10_4 mean b10_9 mean b10_10);
clear;
