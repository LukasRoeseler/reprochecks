#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

/*********************************************************/
/******** TABLE 8 *********************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

gen rawyear=year;

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

gen year2=year*year;
gen year3=year*year*year;

egen myear=mean(year);
gen  dyear=year-myear;
summ dyear;

gen b10_4y=b10_4*dyear;
gen b10_9y=b10_9*dyear;
gen b10_10y=b10_10*dyear;

gen L1_b10_10=L1.b10_10;
gen L1_b10_9=L1.b10_9;
gen L1_b10_4=L1.b10_4;

gen L3_b10_10=L3.b10_10;
gen L3_b10_9=L3.b10_9;
gen L3_b10_4=L3.b10_4;

gen L1_b10_10y=L1.b10_10y;
gen L1_b10_9y=L1.b10_9y;
gen L1_b10_4y=L1.b10_4y;

gen i1_b10_4=i2_ac*b10_4;
gen i1_b10_9=i2_ac*b10_9;
gen i1_b10_10=i2_ac*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen L3i1_b10_4=L3.i1_b10_4;
gen L3i1_b10_9=L3.i1_b10_9;
gen L3i1_b10_10=L3.i1_b10_10;

eststo clear;
eststo: xi: reg lndrate D1.b10_10 D1.b10_9 D1.b10_4 L1_b10_10 L1_b10_9 L1_b10_4 
D1.i1_b10_10 D1.i1_b10_9 D1.i1_b10_4 L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

eststo: xi: reg lndrate D1.b10_10 D1.b10_9 D1.b10_4 L1_b10_10 L1_b10_9 L1_b10_4 
D1.i1_b10_10 D1.i1_b10_9 D1.i1_b10_4 L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 i.statemo*year3 [aw=totalpop], cluster(stfips);

eststo: xi: reg lndrate D1.b10_10 D1.b10_9 D1.b10_4 L1_b10_10 L1_b10_9 L1_b10_4 
D1.i1_b10_10 D1.i1_b10_9 D1.i1_b10_4 L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 
[aw=totalpop] if (rawyear>=1960 & rawyear<=1961) | (rawyear>=1969 & rawyear<=1971) | (rawyear>=1979 & rawyear<=1981), cluster(stfips);

eststo: xi: reg lndrate D1.b10_10 D1.b10_9 D1.b10_4 L1_b10_10 L1_b10_9 L1_b10_4 
D1.b10_10y D1.b10_9y D1.b10_4y L1_b10_10y L1_b10_9y L1_b10_4y
D1.i1_b10_10 D1.i1_b10_9 D1.i1_b10_4 L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

eststo: xi: reg lndrate 
L3_b10_10 L3_b10_9 L3_b10_4 
L3i1_b10_10 L3i1_b10_9 L3i1_b10_4 
D1.b10_10 D1.b10_9 D1.b10_4 
D2.b10_10 D2.b10_9 D2.b10_4 
D3.b10_10 D3.b10_9 D3.b10_4 
D1.i1_b10_10 D1.i1_b10_9 D1.i1_b10_4 
D2.i1_b10_10 D2.i1_b10_9 D2.i1_b10_4 
D3.i1_b10_10 D3.i1_b10_9 D3.i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE8.csv, replace r2 se keep(L1_b10_10 L1_b10_9 L1_b10_4 L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 L3i1_b10_10 L3i1_b10_9 L3i1_b10_4) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;



