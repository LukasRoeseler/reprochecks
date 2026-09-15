#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

/*********************************************************/
/******** TABLE 6: PANEL A, 1931-1959 *******************/

use DATA_1900_2004;
keep if year>=1930 & year<=1959;

gen yearmo=year*1000 + month;
gen statemo=stfips*1000 + month;

quiet tab month, gen(monthfe);
drop monthfe1;

forvalues i=2/12 {;
 gen sh_0000_monthfe`i'=sh_0000*monthfe`i';
 gen sh_4564_monthfe`i'=sh_4564*monthfe`i';
 gen sh_6599_monthfe`i'=sh_6599*monthfe`i';
 gen lri_monthfe`i'=lri*monthfe`i';
};

summ;

gen ymdate=ym(year, month);
sort stfips ymdate;
xtset stfips ymdate;
xtdescribe;    

replace b10_4=b10_4+b10_3+b10_2+b10_1;

gen L1_b10_10=L1.b10_10;
gen L1_b10_9=L1.b10_9;
gen L1_b10_4=L1.b10_4;

gen D1_b10_10=D1.b10_10;
gen D1_b10_9=D1.b10_9;
gen D1_b10_4=D1.b10_4;

gen i1_b10_4=i1_ph*b10_4;
gen i1_b10_9=i1_ph*b10_9;
gen i1_b10_10=i1_ph*b10_10;

gen i2_b10_4=electrification_rate*b10_4;
gen i2_b10_9=electrification_rate*b10_9;
gen i2_b10_10=electrification_rate*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen L1i2_b10_4=L1.i2_b10_4;
gen L1i2_b10_9=L1.i2_b10_9;
gen L1i2_b10_10=L1.i2_b10_10;

gen D1i1_b10_4=D1.i1_b10_4;
gen D1i1_b10_9=D1.i1_b10_9;
gen D1i1_b10_10=D1.i1_b10_10;

gen D1i2_b10_4=D1.i2_b10_4;
gen D1i2_b10_9=D1.i2_b10_9;
gen D1i2_b10_10=D1.i2_b10_10;

gen year2=year*year;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_4 L1_b10_9 L1_b10_10 
D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 L1i1_b10_4 L1i1_b10_9 L1i1_b10_10 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i1_ph
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_4 L1_b10_9 L1_b10_10 
D1i2_b10_4 D1i2_b10_9 D1i2_b10_10 L1i2_b10_4 L1i2_b10_9 L1i2_b10_10 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri electrification_rate 
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_4 L1_b10_9 L1_b10_10 D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 
D1i2_b10_4 D1i2_b10_9 D1i2_b10_10 L1i1_b10_4 L1i1_b10_9 L1i1_b10_10 L1i2_b10_4 L1i2_b10_9 L1i2_b10_10  
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i1_ph electrification_rate
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE6.csv, replace r2 se keep(L1_b10_10 L1i1_b10_10 L1i2_b10_10 L1_b10_9 L1i1_b10_9 L1i2_b10_9) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;

/*********************************************************/
/******** TABLE 6: PANEL B, 1960-2004 *******************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

gen yearmo=year*1000 + month;
gen statemo=stfips*1000 + month;

quiet tab month, gen(monthfe);
drop monthfe1;

forvalues i=2/12 {;
 gen sh_0000_monthfe`i'=sh_0000*monthfe`i';
 gen sh_4564_monthfe`i'=sh_4564*monthfe`i';
 gen sh_6599_monthfe`i'=sh_6599*monthfe`i';
 gen lri_monthfe`i'=lri*monthfe`i';
};

summ;

gen ymdate=ym(year, month);
sort stfips ymdate;
xtset stfips ymdate;
xtdescribe;    

replace b10_4=b10_4+b10_3+b10_2+b10_1;

gen L1_b10_10=L1.b10_10;
gen L1_b10_9=L1.b10_9;
gen L1_b10_4=L1.b10_4;

gen D1_b10_10=D1.b10_10;
gen D1_b10_9=D1.b10_9;
gen D1_b10_4=D1.b10_4;

gen i1_b10_4=i1_ph*b10_4;
gen i1_b10_9=i1_ph*b10_9;
gen i1_b10_10=i1_ph*b10_10;

gen i2_b10_4=i2_ac*b10_4;
gen i2_b10_9=i2_ac*b10_9;
gen i2_b10_10=i2_ac*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen L1i2_b10_4=L1.i2_b10_4;
gen L1i2_b10_9=L1.i2_b10_9;
gen L1i2_b10_10=L1.i2_b10_10;

gen D1i1_b10_4=D1.i1_b10_4;
gen D1i1_b10_9=D1.i1_b10_9;
gen D1i1_b10_10=D1.i1_b10_10;

gen D1i2_b10_4=D1.i2_b10_4;
gen D1i2_b10_9=D1.i2_b10_9;
gen D1i2_b10_10=D1.i2_b10_10;

gen year2=year*year;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_4 L1_b10_9 L1_b10_10 
D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 L1i1_b10_4 L1i1_b10_9 L1i1_b10_10 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i1_ph
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_4 L1_b10_9 L1_b10_10 
D1i2_b10_4 D1i2_b10_9 D1i2_b10_10 L1i2_b10_4 L1i2_b10_9 L1i2_b10_10 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_4 L1_b10_9 L1_b10_10 D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 
D1i2_b10_4 D1i2_b10_9 D1i2_b10_10 L1i1_b10_4 L1i1_b10_9 L1i1_b10_10 L1i2_b10_4 L1i2_b10_9 L1i2_b10_10
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i1_ph i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE6.csv, append r2 se keep(L1_b10_10 L1i1_b10_10 L1i2_b10_10 L1_b10_9 L1i1_b10_9 L1i2_b10_9) b(4) se(4) star noparentheses order();
clear;


