#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

/***************************************************************************************/
/******** TABLE 3: 1931-2004, Panel A, Column 1 ********/

use DATA_1900_2004;
keep if year>=1930 & year<=2004;

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

gen L1_b10_10=L1.b10_10;
gen L1_b10_9=L1.b10_9;
gen L1_b10_4=L1.b10_4;

gen D1_b10_10=D1.b10_10;
gen D1_b10_9=D1.b10_9;
gen D1_b10_4=D1.b10_4;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);
clear;







/***************************************************************************************/
/******** TABLE 3: 1931-1959, Panel A, Column 2 ********/

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

gen year2=year*year;

gen L1_b10_10=L1.b10_10;
gen L1_b10_9=L1.b10_9;
gen L1_b10_4=L1.b10_4;

gen D1_b10_10=D1.b10_10;
gen D1_b10_9=D1.b10_9;
gen D1_b10_4=D1.b10_4;

eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);
clear;






/***************************************************************************************/
/******** TABLE 3: 1960-2004, Panel A, Column 3 ********/

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

gen year2=year*year;

gen L1_b10_10=L1.b10_10;
gen L1_b10_9=L1.b10_9;
gen L1_b10_4=L1.b10_4;

gen D1_b10_10=D1.b10_10;
gen D1_b10_9=D1.b10_9;
gen D1_b10_4=D1.b10_4;

eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE3_MEAN.csv, replace r2 se keep(L1_b10_10 L1_b10_9 L1_b10_4) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;










/***************************************************************************************/
/******** TABLE 3: 1931-2004, Panel B, Column 1 ********/

use DATA_1900_2004;
keep if year>=1930 & year<=2004;

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

replace bn10_4=bn10_4+bn10_3+bn10_2+bn10_1; 
replace bx10_4=bx10_4+bx10_3+bx10_2+bx10_1; 

gen year2=year*year;

gen L1_bn10_10=L1.bn10_10;
gen L1_bn10_9=L1.bn10_9;
gen L1_bn10_4=L1.bn10_4;
gen L1_bx10_10=L1.bx10_10;
gen L1_bx10_9=L1.bx10_9;
gen L1_bx10_4=L1.bx10_4;

eststo: xi: reg lndrate 
D1.bn10_4 D1.bn10_9 D1.bn10_10 L1_bn10_10 L1_bn10_9 L1_bn10_4 
D1.bx10_4 D1.bx10_9 D1.bx10_10 L1_bx10_10 L1_bx10_9 L1_bx10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);
clear;




/***************************************************************************************/
/******** TABLE 3: 1931-1959, Panel B, Column 2 ********/

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

replace bn10_4=bn10_4+bn10_3+bn10_2+bn10_1; 
replace bx10_4=bx10_4+bx10_3+bx10_2+bx10_1; 

gen year2=year*year;

gen L1_bn10_10=L1.bn10_10;
gen L1_bn10_9=L1.bn10_9;
gen L1_bn10_4=L1.bn10_4;
gen L1_bx10_10=L1.bx10_10;
gen L1_bx10_9=L1.bx10_9;
gen L1_bx10_4=L1.bx10_4;

eststo: xi: reg lndrate 
D1.bn10_4 D1.bn10_9 D1.bn10_10 L1_bn10_10 L1_bn10_9 L1_bn10_4 
D1.bx10_4 D1.bx10_9 D1.bx10_10 L1_bx10_10 L1_bx10_9 L1_bx10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);
clear;








/*********************************************************/
/******** TABLE 3: 1960-2004, Panel B, Column 3 *********/

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

replace bn10_4=bn10_4+bn10_3+bn10_2+bn10_1; 
replace bx10_4=bx10_4+bx10_3+bx10_2+bx10_1; 

gen year2=year*year;

gen L1_bn10_10=L1.bn10_10;
gen L1_bn10_9=L1.bn10_9;
gen L1_bn10_4=L1.bn10_4;
gen L1_bx10_10=L1.bx10_10;
gen L1_bx10_9=L1.bx10_9;
gen L1_bx10_4=L1.bx10_4;

eststo: xi: reg lndrate 
D1.bn10_4 D1.bn10_9 D1.bn10_10 L1_bn10_10 L1_bn10_9 L1_bn10_4 
D1.bx10_4 D1.bx10_9 D1.bx10_10 L1_bx10_10 L1_bx10_9 L1_bx10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);
clear;

esttab using TABLE3_MINMAX.csv, replace r2 se keep(L1_bn10_10 L1_bn10_9 L1_bn10_4 L1_bx10_10 L1_bx10_9 L1_bx10_4) b(4) se(4) star noparentheses order();
eststo clear;
clear;




