#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

/*********************************************************/
/******** TABLE 5: ROWS 3&4, 1931-1959 ******************/

use DATA_1900_2004;
summ increal [aw=totalpop] if(year>=1930 & year<=1959), d;
summ increal [aw=totalpop] if(year>=1960 & year<=2004), d;
clear;

use DATA_1900_2004;
keep if year>=1930 & year<=1959;

gen low=(increal<=8802.1);

egen yearmo=concat(year month);
egen statemo=concat(stfips month);

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

gen b10_10low=(low==1)*b10_10;
gen b10_9low=(low==1)*b10_9;
gen b10_4low=(low==1)*b10_4;

gen b10_10hi=(low==0)*b10_10;
gen b10_9hi=(low==0)*b10_9;
gen b10_4hi=(low==0)*b10_4;
 
gen L1_b10_10low=L1.b10_10low;
gen L1_b10_9low=L1.b10_9low;
gen L1_b10_4low=L1.b10_4low;

gen L1_b10_10hi=L1.b10_10hi;
gen L1_b10_9hi=L1.b10_9hi;
gen L1_b10_4hi=L1.b10_4hi;

eststo clear;

eststo: xi: reg lndrate 
D1.b10_4low D1.b10_9low D1.b10_10low D1.b10_4hi D1.b10_9hi D1.b10_10hi
L1_b10_4low L1_b10_9low L1_b10_10low L1_b10_4hi L1_b10_9hi L1_b10_10hi
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

keep lndrate
b10_4low b10_9low b10_10low b10_4hi b10_9hi b10_10hi
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* yearmo statemo totalpop stfips year month;
save PRE, replace;

esttab using TABLE5_ROW3.csv, replace r2 se keep(L1_b10_10* L1_b10_9*) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;

/*********************************************************/
/******** TABLE 5: ROWS 3&4, 1960-2004 *******************/

use DATA_1900_2004;
keep if year>=1960 & year<=2004;

gen low=(increal<=22393.0);

egen yearmo=concat(year month);
egen statemo=concat(stfips month);

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

gen b10_10low=(low==1)*b10_10;
gen b10_9low=(low==1)*b10_9;
gen b10_4low=(low==1)*b10_4;

gen b10_10hi=(low==0)*b10_10;
gen b10_9hi=(low==0)*b10_9;
gen b10_4hi=(low==0)*b10_4;
 
gen L1_b10_10low=L1.b10_10low;
gen L1_b10_9low=L1.b10_9low;
gen L1_b10_4low=L1.b10_4low;

gen L1_b10_10hi=L1.b10_10hi;
gen L1_b10_9hi=L1.b10_9hi;
gen L1_b10_4hi=L1.b10_4hi;


eststo clear;

eststo: xi: reg lndrate 
D1.b10_4low D1.b10_9low D1.b10_10low D1.b10_4hi D1.b10_9hi D1.b10_10hi
L1_b10_4low L1_b10_9low L1_b10_10low L1_b10_4hi L1_b10_9hi L1_b10_10hi
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

keep lndrate           
b10_4low b10_9low b10_10low b10_4hi b10_9hi b10_10hi
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* yearmo statemo totalpop stfips year month;
save POST, replace;

esttab using TABLE5_ROW3.csv, append r2 se keep(L1_b10_10* L1_b10_9*) b(4) se(4) star noparentheses order(); 
eststo clear;
clear;

/*********************************************************/
/******** TABLE 5: ROWS 3&4, COLUMNS 3 and 6 ************/

use POST;
gen post=1;
append using PRE;
replace post=0 if post==.;
summ;

gen ymdate=ym(year, month);
sort stfips ymdate;
xtset stfips ymdate;
xtdescribe;    
 
gen L1_b10_10low=L1.b10_10low;
gen L1_b10_9low=L1.b10_9low;
gen L1_b10_4low=L1.b10_4low;

gen L1_b10_10hi=L1.b10_10hi;
gen L1_b10_9hi=L1.b10_9hi;
gen L1_b10_4hi=L1.b10_4hi;

gen D1_b10_10low=D1.b10_10low;
gen D1_b10_9low=D1.b10_9low;
gen D1_b10_4low=D1.b10_4low;

gen D1_b10_10hi=D1.b10_10hi;
gen D1_b10_9hi=D1.b10_9hi;
gen D1_b10_4hi=D1.b10_4hi;

gen L1_b10_10lowpost60=L1_b10_10low*post;
gen L1_b10_9lowpost60=L1_b10_9low*post;
gen L1_b10_4lowpost60=L1_b10_4low*post;

gen L1_b10_10hipost60=L1_b10_10hi*post;
gen L1_b10_9hipost60=L1_b10_9hi*post;
gen L1_b10_4hipost60=L1_b10_4hi*post;

gen D1_b10_10lowpost60=D1_b10_10low*post;
gen D1_b10_9lowpost60=D1_b10_9low*post;
gen D1_b10_4lowpost60=D1_b10_4low*post;

gen D1_b10_10hipost60=D1_b10_10hi*post;
gen D1_b10_9hipost60=D1_b10_9hi*post;
gen D1_b10_4hipost60=D1_b10_4hi*post;

gen year2=year*year;

eststo: xi: reg lndrate 
D1.b10_4low D1.b10_9low D1.b10_10low D1.b10_4hi D1.b10_9hi D1.b10_10hi
L1_b10_4low L1_b10_9low L1_b10_10low L1_b10_4hi L1_b10_9hi L1_b10_10hi
D1_b10_4lowpost60 D1_b10_9lowpost60 D1_b10_10lowpost60 D1_b10_4hipost60 D1_b10_9hipost60 D1_b10_10hipost60
L1_b10_4lowpost60 L1_b10_9lowpost60 L1_b10_10lowpost60 L1_b10_4hipost60 L1_b10_9hipost60 L1_b10_10hipost60
devp25 devp75 sh_0000 sh_4564 sh_6599 lri
sh_0000_monthfe* sh_4564_monthfe* sh_6599_monthfe* lri_monthfe* i.yearmo i.statemo*year i.statemo*year2 [aw=totalpop], cluster(stfips);

clear;

! \rm PRE.dta;
! \rm POST.dta;
