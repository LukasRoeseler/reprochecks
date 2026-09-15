#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

/******************************************************/
/******** CVD ***************************************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

drop lndrate;
gen lndrate=log(100000*dths_cvd/totalpop);

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

gen i1_b10_4=i2_ac*b10_4;
gen i1_b10_9=i2_ac*b10_9;
gen i1_b10_10=i2_ac*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen D1i1_b10_4=D1.i1_b10_4;
gen D1i1_b10_9=D1.i1_b10_9;
gen D1i1_b10_10=D1.i1_b10_10;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 
L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE7_BYCAUSE.csv, replace r2 se keep(L1_b10_10 L1i1_b10_10 L1_b10_9 L1i1_b10_9) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;





/****************************************************/
/******** RESPIRATORY ***************************************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

drop lndrate;             
gen lndrate=log(100000*dths_rpd/totalpop);

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

gen i1_b10_4=i2_ac*b10_4;
gen i1_b10_9=i2_ac*b10_9;
gen i1_b10_10=i2_ac*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen D1i1_b10_4=D1.i1_b10_4;
gen D1i1_b10_9=D1.i1_b10_9;
gen D1i1_b10_10=D1.i1_b10_10;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 
L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE7_BYCAUSE.csv, append r2 se keep(L1_b10_10 L1i1_b10_10 L1_b10_9 L1i1_b10_9) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;





/****************************************************/
/******** MVA ***************************************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

drop lndrate;             
gen lndrate=log(100000*dths_mva/totalpop);

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

gen i1_b10_4=i2_ac*b10_4;
gen i1_b10_9=i2_ac*b10_9;
gen i1_b10_10=i2_ac*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen D1i1_b10_4=D1.i1_b10_4;
gen D1i1_b10_9=D1.i1_b10_9;
gen D1i1_b10_10=D1.i1_b10_10;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 
L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE7_BYCAUSE.csv, append r2 se keep(L1_b10_10 L1i1_b10_10 L1_b10_9 L1i1_b10_9) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;





/****************************************************/
/******** INFECTIONS ***************************************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

drop lndrate;             
gen lndrate=log(100000*dths_ifd/totalpop);

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

gen i1_b10_4=i2_ac*b10_4;
gen i1_b10_9=i2_ac*b10_9;
gen i1_b10_10=i2_ac*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen D1i1_b10_4=D1.i1_b10_4;
gen D1i1_b10_9=D1.i1_b10_9;
gen D1i1_b10_10=D1.i1_b10_10;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 
L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE7_BYCAUSE.csv, append r2 se keep(L1_b10_10 L1i1_b10_10 L1_b10_9 L1i1_b10_9) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;





/******************************************************/
/******** NEOPLASM ***************************************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

drop lndrate;             
gen lndrate=log(100000*dths_neo/totalpop);

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

gen i1_b10_4=i2_ac*b10_4;
gen i1_b10_9=i2_ac*b10_9;
gen i1_b10_10=i2_ac*b10_10;

gen L1i1_b10_4=L1.i1_b10_4;
gen L1i1_b10_9=L1.i1_b10_9;
gen L1i1_b10_10=L1.i1_b10_10;

gen D1i1_b10_4=D1.i1_b10_4;
gen D1i1_b10_9=D1.i1_b10_9;
gen D1i1_b10_10=D1.i1_b10_10;

eststo clear;
eststo: xi: reg lndrate D1_b10_4 D1_b10_9 D1_b10_10 L1_b10_10 L1_b10_9 L1_b10_4 
D1i1_b10_4 D1i1_b10_9 D1i1_b10_10 
L1i1_b10_10 L1i1_b10_9 L1i1_b10_4 
devp25 devp75 sh_0000 sh_4564 sh_6599 lri i2_ac
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

esttab using TABLE7_BYCAUSE.csv, append r2 se keep(L1_b10_10 L1i1_b10_10 L1_b10_9 L1i1_b10_9) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;















