#delimit;
set matsize 11000;
set maxvar 12000;
set linesize 140;

use DATA_1900_2004;
summ b10* [aw=totalpop], sep(0);

collapse (sum) b10* [aw=totalpop], by(stfips year);

summ b10*, sep(0);

keep b10*;

gen bin = .;
local n=1;
forvalues i=1/10 {;
summ b10_`i';
replace bin=r(mean) in `n';
local n=`n'+1;
};

keep if _n<=10;

gen x=_n;

label define x 1 "<10" 2 "10-19" 3 "20-29" 4 "30-39" 5 "40-49" 6 "50-59" 7 "60-69" 8 "70-79" 9 "80-89" 10 ">90";
label value x x;

list, clean;

graph bar bin, over(x) graphr(color(white)) ytit("Number of Days Per Year") 
	saving(Figure1.gph, replace) legend(off) yscale(noline) 
	ylab(0 10 20 30 40 50 60 70, grid glcolor(gs14) glwidth(thin)) bar(1, lcolor(black) fcolor(blue)) 
	yline(0, lcolor(black)); 
clear;




