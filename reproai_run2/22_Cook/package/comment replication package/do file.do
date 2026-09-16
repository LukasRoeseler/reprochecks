// preamble

use  "DATASET_ETHNOATLAS.dta", clear

datasignature
assert r(datasignature) == "1260:149(70423):3060543911:666054547"

keep if year~=. 
keep if year>=1500
keep if Barley_point_cal!=. /*Delete observations without agricultural data*/

**generate main regressors		

gen L_hier1=V33 if V33~=0           /*Jurisdictional Hierarchy Beyond Local Community: 0(missing) 1 (no political authority beyond community), 2 (one level) to 5 (for levels)*/

gen L_crop_cereals=1 if V29==6
replace L_crop_cereals=0 if L_crop_cereals==. & V29~=. & V29~=0 
gen cereals=L_crop_cereals

gen L_surplus=0 if TUDEN_MARSHALL_v93==1
replace L_surplus=1 if TUDEN_MARSHALL_v93<10 & TUDEN_MARSHALL_v93>1

gen Tax_burden=0 if SCSS_v1737==1 
replace Tax_burden=1 if SCSS_v1737==2 | SCSS_v1737==3  | SCSS_v1737==6
replace Tax_burden=2 if SCSS_v1737==4 | SCSS_v1737==5  | SCSS_v1737==7
label var Tax_burden "=0 no tax; =1 small tax; =2 regular and relevant tax"

gen depend_agric = (5-0)/2 if V5==0
replace depend_agric = 6+(15-6)/2   if V5==1
replace depend_agric = 16+(25-16)/2   if V5==2
replace depend_agric = 26+(35-26)/2   if V5==3
replace depend_agric = 36+(45-36)/2   if V5==4
replace depend_agric = 46+(55-46)/2   if V5==5
replace depend_agric = 56+(65-56)/2   if V5==6
replace depend_agric = 66+(75-66)/2   if V5==7
replace depend_agric = 76+(85-76)/2   if V5==8
replace depend_agric = 86+(100-86)/2   if V5==9
replace depend_agric = depend_agric/100

gen Cal_positive_plow1=max(Wheat_point_cal, Barley_point_cal ,Rye_point_cal)				
gen Cal_negative_plow1=max(Foxtail_Millet_point_cal , Pearl_Millet_point_cal  ,Sorghum_point_cal)	
gen Plow_advantage1 =Cal_positive_plow1-Cal_negative_plow1  

gen Animal_husbandry1b=1 if V4>0 & V4!=.
replace Animal_husbandry1b=0 if V4==0
tabulate Animal_husbandry1b, gen(dummy_Animal_husbandry1b_)

gen     Animal_cultivation2=(V39==2 | V39==3) if V39!=0
tabulate Animal_cultivation2, gen(dummy_Animal_cultivation2_)

gen Ruminants=1 if  V40==3 | V40==7
replace Ruminants=0 if Ruminants==.

gen max_cal_point_c1=max(Barley_point_cal, Buckwheat_point_cal , Dryland_Rice_point_cal ,Foxtail_Millet_point_cal, Maize_point_cal ,Oat_point_cal ,Pearl_Millet_point_cal, Rye_point_cal ,Sorghum_point_cal, Wetland_Rice_point_cal, Wheat_point_cal )
gen max_cal_point_t=max(Cassava_point_cal ,Sweet_Potato_point_cal, White_Potato_point_cal, Yams_point_cal)

label var max_cal_point_c1  "cal/ha cereal with MaxCalYield (on a circle(5cell radius)around Ethnoatlas point)(LowInput RainFed)"	
label var max_cal_point_t 	"cal/ha root/tub with MaxCalYield (on a circle(5cell radius)around Ethnoatlas point)(LowInput RainFed)"	

gen diff= max_cal_point_c1- max_cal_point_t
gen max = max(max_cal_point_c1,  max_cal_point_t)

egen std_max=std(max)
egen std_diff=std(diff)

gen sample_non_desertic=1 if  max_cal_point_t~=0 & max_cal_point_c1 ~=0 	/*non-desertic points; cereals and roots/tubers can be planted (Murdock points)*/

gen hierarchyA="1.tribe" if L_hier1==1
replace hierarchyA="2.small chiefd" if L_hier1==2
replace hierarchyA="3.large chiefd" if L_hier1==3
replace hierarchyA="4.small state" if L_hier1==4
replace hierarchyA="5.large state" if L_hier1==5

egen rainmean_std=std(rainmean) 
egen atemp_std=std(atemp) 
egen elevation_std=std(elevation) 
egen ruggedness_std=std(ruggedness) 
egen abslat_std=std(abslat) 
egen river_std=std(river) 
egen distcoast_std=std(distcoast) 
egen popd95_std=std(popd95) 
egen histpopd_std=std(histpopd)  
egen historicpopdB_std=std(historicpopdB)  
egen Plow_advantage1_std=std(Plow_advantage1) 
gen Plow_advantage1_std_7squared= Plow_advantage1_std*Plow_advantage1_std
egen ramank_std=std(ramank) 
egen suit_GalOz_std=std(suit_GalOz) 
egen irrigation_dep_std=std(irrigation_dep) 

tab dummy_continental3, gen(continent3_d)

tab dummy_continental_ref1, gen(continental_ref1_d) 

keep if sample_non_desertic==1

gen const=1

* labeling preamble

label var cereals "CerMain"
label var std_max "LandProd"
label var depend_agric "Dep. Agri."
label var std_diff "CerAdv"

*** table 1, second stage

eststo clear
eststo: ivreg2  L_hier1  cereals 					,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff)  	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) 							continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) std_max 					continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) depend_agric  			continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 		,cluster(iso)	

local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols'),     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals =  std_diff ) 	`selected_regressors2' if  missing_var==0, cluster(iso) ffirst

esttab , ///
b(3) se(3) stats(N widstat r2, fmt(%9.0g %9.2f %9.3f) labels("Observations" "F-Statistic" "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(cereals std_max depend_agric) ///
mgroups("DV: Jursdictional hierarchy beyond local community (1-5 scale)",pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("OLS" "2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes

*** table 1, first stage

eststo clear
eststo: ivreg2  cereals   std_diff  	if L_hier1!=.,cluster(iso)			 	
eststo: ivreg2  cereals   std_diff continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		if L_hier1!=.,cluster(iso)		 	
eststo: ivreg2  cereals   std_diff std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		if L_hier1!=.,cluster(iso)		 	
eststo: ivreg2  cereals   std_diff  depend_agric continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 	if L_hier1!=.,cluster(iso)	
eststo: ivreg2  cereals  std_diff  	`selected_regressors2' if  missing_var==0 & L_hier1!=., cluster(iso) ffirst

esttab , ///
b(3) se(3) stats(N  , fmt(%9.0g %9.2f %9.3f) labels("Observations"  "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(std_diff) ///
mgroups("First Stage",pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes


*** table 2

eststo clear

	eststo: ivreg2  L_hier1  (cereals =  std_diff) 	std_max depend_agric i.dummy_continental3  if sample_non_desertic==1,cluster(iso)		 	

forval i = 1(1)4{
	capture drop indicator
	gen indicator = .
	replace indicator = 0 if L_hier1<=`i' & L_hier1!=.
	replace indicator = 1 if L_hier1>`i' & L_hier1!=.
	
	eststo: ivreg2  indicator  (cereals =  std_diff) 	std_max depend_agric i.dummy_continental3 if sample_non_desertic==1,cluster(iso)		 	

}

forval i = 1(1)4{
	capture drop indicator
	gen indicator = .
	replace indicator = 0 if L_hier1==`i' & L_hier1!=.
	replace indicator = 1 if L_hier1==`i'+1 & L_hier1!=.
	
	eststo: ivreg2  indicator  (cereals =  std_diff) 	std_max depend_agric i.dummy_continental3 if sample_non_desertic==1,cluster(iso)		 	

}

esttab , ///
b(3) p(3) label stats(N widstat, label("Obs." "F-stat") fmt(%11.0gc %11.2f)) star(* 0.10 ** 0.05 *** 0.01) keep() nocons nonotes  ///
mgroups("5-Scale" "Ind. for above level" "Ind. for one above level",pattern(1 1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
mtitles("5-Scale" "Tribe" "S. Chf." "L. Chf" "S. State" "Tribe" "S. Chf." "L. Chf" "S. State") ///
indicate( ///
"Cont. FE = *dummy_continental3* " ///
, labels("Y" " "))

*** table 3

merge 1:1 id_Ethnoat using "PaperLatLongClimate.dta"
drop _merge

capture drop Climate_*

*groups by main climate
gen Climate_equatorial = (ClimateRaster==1|ClimateRaster==2|ClimateRaster==3|ClimateRaster==4)
gen Climate_arid = (ClimateRaster==5|ClimateRaster==6|ClimateRaster==7|ClimateRaster==8)
gen Climate_warm = (ClimateRaster==9|ClimateRaster==10|ClimateRaster==11|ClimateRaster==12|ClimateRaster==13|ClimateRaster==14|ClimateRaster==15|ClimateRaster==16|ClimateRaster==17)
gen Climate_snow = (ClimateRaster==18|ClimateRaster==19|ClimateRaster==20|ClimateRaster==21|ClimateRaster==22|ClimateRaster==23|ClimateRaster==24|ClimateRaster==25|ClimateRaster==26|ClimateRaster==27|ClimateRaster==28|ClimateRaster==29|ClimateRaster==30)
gen Climate_polar = (ClimateRaster==31|ClimateRaster==32)

eststo clear

eststo: ivreg2  L_hier1  cereals Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar			,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar 	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) 							continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) std_max 					continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) depend_agric  			continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 	Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar	,cluster(iso)	

local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols'),     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals =  std_diff ) 	`selected_regressors2' if  missing_var==0, cluster(iso) ffirst

cap drop missing_var
local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols') Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar ,     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals =  std_diff ) 	`selected_regressors2' Climate_equatorial	Climate_arid Climate_warm Climate_snow Climate_polar  if  missing_var==0, cluster(iso) ffirst

esttab , ///
keep(cereals  std_max depend_agric) ///
label stats(N widstat r2,label("Observations" "F-Statistic" "R2") fmt (%9.0f %9.2f %9.3f)) nolz ///
starl(* 0.10 ** 0.05 *** 0.01)  nocons p(3) b(3) nogaps nonotes nomtitles ///se(3) 
indicate( ///
"Continent FE = *continent3* " ///
, labels("Yes" "No"))


*** table 4

capture drop w_std_diff
winsor std_diff, gen(w_std_diff) p(0.03) highonly

count if std_diff!=. & sample_non_desertic==1 & cereals!=. & L_hier1!=. & std_diff!=w_std_diff
count if std_diff!=. & sample_non_desertic==1 & cereals!=. & L_hier1!=.

eststo clear
eststo: ivreg2  L_hier1  cereals 					,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  w_std_diff)  	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  w_std_diff) 							continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  w_std_diff) std_max 					continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  w_std_diff) depend_agric  			continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 		,cluster(iso)	

local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols'),     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals =  std_diff ) 	`selected_regressors2' if  missing_var==0, cluster(iso) ffirst

esttab , ///
b(3) se(3) stats(N widstat r2, fmt(%9.0g %9.2f %9.3f) labels("Observations" "F-Statistic" "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(cereals std_max depend_agric) ///
mgroups("DV: Jursdictional hierarchy beyond local community (1-5 scale)",pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("OLS" "2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes

*** table 5

eststo clear
eststo: ivreg2  L_hier1  cereals 				if V5<=5 	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff)  if V5<=5 	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) 	continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	if V5<=5 	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	if V5<=5 	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) depend_agric continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 	if V5<=5 	,cluster(iso)	

local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols') if V5<=5 ,     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals =  std_diff ) 	`selected_regressors2' if  missing_var==0 & V5<=5 , cluster(iso) ffirst

esttab, ///
b(3) se(3) stats(N widstat r2, fmt(%9.0g %9.2f %9.3f) labels("Observations" "F-Statistic" "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(cereals std_max depend_agric) ///
mgroups("DV: Jursdictional hierarchy beyond local community (1-5 scale)",pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("OLS" "2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes

*** table 6

eststo clear
eststo: ivreg2  L_hier1  cereals 				if V5>5 	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff)  if V5>5 	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) 	continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	if V5>5 	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	if V5>5 	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) depend_agric continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 	if V5>5 	,cluster(iso)	

local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols') if V5>5 ,     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals =  std_diff ) 	`selected_regressors2' if  missing_var==0 & V5>5 , cluster(iso) ffirst

esttab , ///
b(3) se(3) stats(N widstat r2, fmt(%9.0g %9.2f %9.3f) labels("Observations" "F-Statistic" "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(cereals std_max depend_agric) ///
mgroups("DV: Jursdictional hierarchy beyond local community (1-5 scale)",pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("OLS" "2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes

*** table a1

tab V29

capture drop cereals_nomiss
gen cereals_nomiss = .
replace cereals_nomiss = . if V29==0 // missing data
replace cereals_nomiss = . if V29==1 // none or none specified
replace cereals_nomiss = 0 if V29==2 // Non food crops only
replace cereals_nomiss = 0 if V29==3 // Vegetables
replace cereals_nomiss = 0 if V29==4 // Tree fruits
replace cereals_nomiss = 0 if V29==5 //  Roots or tubers
replace cereals_nomiss = 1 if V29==6 //  Cereal grains

label var cereals_nomiss "CerMain (No Missing)"

eststo clear
eststo: ivreg2  L_hier1  cereals_nomiss 					,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals_nomiss =  std_diff)  	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals_nomiss =  std_diff) 							continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals_nomiss =  std_diff) std_max 					continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals_nomiss =  std_diff) depend_agric  			continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 		,cluster(iso)	

local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols'),     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals_nomiss =  std_diff ) 	`selected_regressors2' if  missing_var==0, cluster(iso) ffirst

esttab , ///
b(3) se(3) stats(N widstat r2, fmt(%9.0g %9.2f %9.3f) labels("Observations" "F-Statistic" "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(cereals_nomiss std_max depend_agric) ///
mgroups("DV: Jursdictional hierarchy beyond local community (1-5 scale)",pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("OLS" "2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes

*** table a2

capture drop stringV5
tostring(V5), gen(stringV5)

capture drop iV5
encode stringV5, gen(iV5)

label var iV5 "Dep. Agri. FE"

eststo clear
eststo: ivreg2  L_hier1  cereals 					,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff)  	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) 							continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) std_max 					continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  		,cluster(iso)		 	
eststo: ivreg2  L_hier1  (cereals =  std_diff) i.iV5  					continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 		,cluster(iso)	

local varcontrols "std_max continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (cereals=std_diff) (`varcontrols'),     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (cereals =  std_diff ) 	`selected_regressors2' if  missing_var==0, cluster(iso) ffirst

esttab , ///
b(3) se(3) stats(N widstat r2, fmt(%9.0g %9.2f %9.3f) labels("Observations" "F-Statistic" "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(cereals std_max *V5*) ///
mgroups("DV: Jursdictional hierarchy beyond local community (1-5 scale)",pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("OLS" "2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes

*** table a3

eststo clear
eststo: ivreg2  L_hier1  std_max 				if sample_non_desertic==1	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (std_max =  std_diff)  if sample_non_desertic==1	,cluster(iso)			 	
eststo: ivreg2  L_hier1  (std_max =  std_diff) continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	if sample_non_desertic==1	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (std_max =  std_diff) cereals continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6  	if sample_non_desertic==1	,cluster(iso)		 	
eststo: ivreg2  L_hier1  (std_max =  std_diff) depend_agric continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d6 	if sample_non_desertic==1	,cluster(iso)	

local varcontrols "cereals continent3_d1 continent3_d2 continent3_d3 continent3_d4 continent3_d5 continent3_d6 rainmean_std atemp_std elevation_std ruggedness_std abslat_std latitude longitude river_std distcoast_std histpopd_std Plow_advantage1_std Plow_advantage1_std_7squared 	dummy_Animal_husbandry1b_1 dummy_Animal_husbandry1b_2 Ruminants dummy_Animal_cultivation2_2 irrigation_dep_std"
ivlasso L_hier1 (std_max=std_diff) (`varcontrols') if sample_non_desertic==1,     sqrt pnotpen(std_diff) cluster(iso) idstats
local selected_regressors= e(xselected)
local selected_regressors2= "`selected_regressors'"
macro list
capture drop missing_var
gen missing_var=0
foreach vari of local  varcontrols {
replace missing_var=1 if missing(`vari')==1
}
eststo: ivreg2  L_hier1  (std_max =  std_diff ) 	`selected_regressors2' if  missing_var==0 & sample_non_desertic==1, cluster(iso) ffirst

esttab , ///
b(3) se(3) stats(N widstat r2, fmt(%9.0g %9.2f %9.3f) labels("Observations" "F-Statistic" "R-Squared")) starl(* 0.10 ** 0.05 *** 0.01) replace keep(cereals std_max depend_agric) ///
mgroups("DV: Jursdictional hierarchy beyond local community (1-5 scale)",pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
indicate("Continent FE = *continent*") ///
mtitles("OLS" "2SLS" "2SLS" "2SLS" "2SLS" "2SLSPDS") label nonotes

*** figure 1

hist std_diff if L_hier1!=., start(-2) width(0.5) xlabel(-2(1)4) addlabel addlabopts(mlabposition(12)) freq

capture drop w_std_diff
winsor std_diff, gen(w_std_diff) p(0.03) highonly
label var w_std_diff "CerAdv, Winsorized above 3%"

hist w_std_diff if L_hier1!=., start(-2) width(0.5) xlabel(-2(1)4) addlabel addlabopts(mlabposition(12)) freq

*** figure 2

graph bar (count) L_hier1, over(V5, relabel(1 "0-5%" 2 "6-15%" 3 "16-25%" 4 "26-35%" 5 "36-45%" 6 "46-55%" 7 "56-65%" 8 "66-75%" 9 "76-85%" 10 "86-100%")) blabel(bar) ytitle("Number of Societies") title("")
