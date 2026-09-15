# delimit ;
clear all;
set memory 400m;
set more off;

* Enter the name of your working directory here;
local dir "C:\Users\davinchor\Documents\Projects\Trade-Production Line\Antras-Chor Replication Material";
cd "`dir'";

***************************************************************************************************;
* TABLE 1: TABULATE THE TAIL VALUES OF THE DOWNSTREAMNESS MEASURES ;
***************************************************************************************************;

use USIOrelatedparty.dta, clear;
keep if year>=2000 & year<=2010;
keep io2002;
bysort io2002: keep if _n==1;
tempfile insampleiocodes;
save `insampleiocodes', replace;

use downstreamness.dta, clear;
keep io2002 duse_tuse downmeasure;
keep if substr(io2002,1,1)=="3";
merge 1:1 io2002 using `insampleiocodes';
keep if _m==3;
drop _m;
rename io2002 io_industry;
merge 1:1 io_industry using io_industry_list;
keep if (_m==1 | _m==3);
drop _m;
count;

sort duse_tuse;
list duse_tuse io_industry* in 1/10;
list duse_tuse io_industry* in 244/253;

sort downmeasure;
list downmeasure io_industry* in 1/10;
list downmeasure io_industry* in 244/253;
