*******Variable labels

****Dependent variables
*Intolerance toward VAW: b4dr
*Bystander intervention attitudes: b11ar
*Knows victim of intimate Partner Violence (IPV): knowvictim (1=Yes; 0=No)
*Experienced IPV personally: b9a (1=Yes; 0=No)

****Independent variables
*Sex: female (1=Female; 0=Male)
*Women's Police Station (WPS): deam (1=Yes; 0=No)
*Years of WPS Creation: num_years
*VAW legislation: vaw_law (1=Yes; 0=No)
*Regular police: civilpolice (1=Yes; 0=No)
*Femicide rate: femiciderate 
*Log GDP per capita: Loggdp_2012
*Log population size: Logpopsize
*VAW private issue: b4gr
*Approves traditional gender roles: q91cr
*Perceives gender descrimination: q91er
*Perceives state supports victims: c1r
*Government approval: q89er
*Education level: edlevel 
* Perceived social class: classe
* Wealth: q53r
* Age cohort: p2a (18-43=1; 35-50=2; 50+=3)
*Marital status: marital_status (baseline category=single)
*Children: children (number of children)
*Racial self-identification: color (baseline category=white)
*Age of oldest feminist organization: yearscollective
*Number of Protests by a Feminist Organization: protest_fem 
*Knowledge of the Maria da Penha Law: c6r
*Homicide rates: homiciderate
*Education at the municipal level: education_muni_2010
*Knows the Location of the Women’s Police Station in their Municipality: knowdeam1
*State punishes aggressions against women: a3aer


***Run code with dataset file: Cordova_Kras_dataset_data popular V1.dta

************Table 1 in Manuscript: Determinants of Attitudes toward Violence against Women
estimates clear

meologit  b4dr   i.female i.deam i.vaw_law i.civilpolice femiciderate Loggdp_2012 Logpopsize  b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit  b4dr   i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b4dr i.female c.num_years  i.vaw_law i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color || cidade: , cov(uns)
meologit b4dr  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b11ar i.female i.deam i.vaw_law i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color || cidade: , cov(uns)
meologit b11ar  i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)
meologit b11ar  i.female c.num_years  i.vaw_law i.civilpolice femiciderate Loggdp_2012 Logpopsize  b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns) 
meologit b11ar  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

********Figure 1 in Manuscript, panel A
estimates clear
meologit  b4dr   i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
margins , over(female) at(deam=(0 1))expression(predict(mu fixedonly outcome(5)))
 #delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Strongly Agree VAW should not be Tolerated", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
********Figure 1 in Manuscript, panel B
 margins , over(female) at(deam=(0 1))contrast (effects overjoint) expression(predict(mu fixedonly outcome(5)))
  #delimit;
  marginsplot, ciopts(lpattern(dash))
title("Panel B", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Difference in Mean Predicted Probabilities between men and women", size(small))  xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin)  angle(horizontal)) yline(0)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelB.gph", replace;
 #delimit cr
 
  graph combine "chart1 panelA.gph" "chart1 panelB.gph", rows(1) xcommon imargin(small)   graphregion(color(white)) plotregion(color(white))
 graph save "chart1 combined.gph", replace
 
 
 ****Figure 2 in Manuscript, panel A
 eststo: meologit b4dr  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)

margins , over(female) at(num_years=(0 (2) 28))expression(predict(mu fixedonly outcome(5)))
#delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Strongly Agree VAW should not be Tolerated", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
  ****Figure 2 in Manuscript, panel B
 margins , over(female) at(num_years=(0 (2) 28))contrast(overjoint effects) expression(predict(mu fixedonly outcome(5)))
 marginsplot
  #delimit;
  marginsplot, ciopts(lpattern(dash))
title("Panel B", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Difference in Mean Predicted Probabilities between Men and Women", size(small))  xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin)  angle(horizontal)) yline(0)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelB.gph", replace;
 #delimit cr

  graph combine "chart1 panelA.gph" "chart1 panelB.gph", rows(1) xcommon imargin(small)   graphregion(color(white)) plotregion(color(white))
 graph save "chart2 combined.gph", replace
 
 ***Figure 3 in Manuscript, Panel A
 meologit b11ar  i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)
 margins , over(female) at(deam=(0 1))expression(predict(mu fixedonly outcome(5)))
 #delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Strongly Agree with Bystander Intervention", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
 
 ***Figure 3 in Manuscript, Panel B
 margins , over(female) at(deam=(0 1))contrast (overjoint effects) expression(predict(mu fixedonly outcome(5)))
  #delimit;
 marginsplot, ciopts(lpattern(dash))
title("Panel B", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Difference in Mean Predicted Probabilities between Men and Women", size(small))  xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin)  angle(horizontal)) yline(0)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelB.gph", replace;
 #delimit cr
 
  graph combine "chart1 panelA.gph" "chart1 panelB.gph", rows(1) xcommon imargin(small)   graphregion(color(white)) plotregion(color(white))
 graph save "chart3 combined.gph", replace
 
****Figure 4 in Manuscript, Panel A
meologit b11ar  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

 margins , over(female) at(num_years=(0 (2) 28))expression(predict(mu fixedonly outcome(5)))
 #delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Strongly Agree with Bystander Intervention", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
 
 ****Figure 4 in Manuscript, Panel B
 margins , over(female) at(num_years=(0 (2) 28))contrast(overjoint effects) expression(predict(mu fixedonly outcome(5)))
  #delimit;
 marginsplot, ciopts(lpattern(dash))
title("Panel B", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Difference in Mean Predicted Probabilities between Men and Women", size(small))  xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin)  angle(horizontal)) yline(0)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart2 panelB.gph", replace;
 #delimit cr
 
  graph combine "chart1 panelA.gph" "chart2 panelB.gph", rows(1) xcommon imargin(small)   graphregion(color(white)) plotregion(color(white))
 graph save "chart4 combined.gph", replace

 
****Figure 5 in Manuscript, Panel A (Knows IPV victim)
estimates clear
melogit knowvictim  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

margins , over(female) at(num_years=(0 (2) 28))predict(mu fixedonly)
 #delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Knowing victim", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
 
 ****Figure 5 in Manuscript, Panel B

 margins , over(female) contrast (overjoint effects) at(num_years=(0 (2) 28))predict(mu fixedonly)
 #delimit;
 marginsplot, ciopts(lpattern(dash))
title("Panel B", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Difference in Mean Predicted Probabilities", size(small))  xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin)  angle(horizontal)) yline(0)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelB.gph", replace;
 #delimit cr

    graph combine "chart1 panelA.gph" "chart1 panelB.gph", rows(1) xcommon imargin(small)   graphregion(color(white)) plotregion(color(white))
 graph save "chart5 combined.gph", replace
 
 ****Figure 6 in Manuscript (Personally Experiencing IPV) 
estimates clear
melogit b9a i.deam i.vaw_law i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

margins ,  at(deam=(0 1)) post


preserve
cap which parmest
if _rc ssc inst parmest
cap which eclplot
if _rc ssc inst eclplot

parmest , saving(myfile, replace)
u myfile, clear

encode parm, gen(myparm)
qui sum myparm
local hyr=string(r(max))
format  estimate %4.2f
sdecode estimate, gen(pnames)

gen deam = regexs(1) if (regexm(parm, "([0-9]*)"))


destring deam, replace
label define deam 1"No WPS" 2"WPS", modify
label value deam deam 

gen estimatev2=estimate/2	

 #delimit;
graph twoway bar estimate deam, vertical  lcolor(gs0) lwidth(vvvthin)  barwidth(.5) fintensity(inten100)
|| sc  estimatev2 deam , msymbol(S)  msize(ehuge) mlwidth(vvthin) mfcolor(white) mlcolor(gs0) mlabel(pnames) mlabposition(0) mlabsize(small) mlabcolor(black) 
legend(off) 
ytit(""Mean Predicted Probability" "Personally experienced VAW"") xtit(" ") 
xlabel(1(1)2, angle(horizontal)nogrid valuelabel labsize(small)) yscale(r(0)) ylab(#6,angle(horizontal) nogrid valuelabel labsize(small) format(%4.2f) nogrid) 
graphregion(color(white)) plotregion(color(white) margin(bargraph)) ; 
#delimit cr
graph save "Figure.gph", replace
restore

***Figure 7 top panel in Manuscript (based on Matched sample)
 ssc install psmatch2, replace
 clear
***NOTE: Before running the code, specify the folder where you saved the dataset on your computer

 use"C:\Users\Abby Cordova\Dropbox\Research Project on Violence Against Women\Police Paper Data Popular\Paper\Submitted\Revisions\Revised Paper\Replication Files\Cordova_Kras_dataset_data popular V1.dta"
 
 tempfile design
 
 collapse ( mean) b4dr deam homiciderate Loggdp_2012 Logpopsize , by(cidade)
 
 * Estimate C using cluster- level variable
 logit deam homiciderate Loggdp_2012 Logpopsize 
 
 * Estimate the  propensity score for each unit
  predict pscore1, pr
  
    *** psmatch2 with nearest neighbor with calipher, replace and common support
  **** Caliper is set to 0.25 standard deviation of the ps
  sum pscore1
  scalar cal =r(sd)*0.25
  
  ***using pstch2 to get the weight
  psmatch2 deam homiciderate Loggdp_2012 Logpopsize,  outcome(b4dr) caliper(`=scalar(cal)')  neighbor(5) common
  pstest homiciderate Loggdp_2012 Logpopsize, sum both
 
 keep cidade _*
 sort cidade
 save "`design'", replace
 
 clear

 use"C:\Users\Abby Cordova\Dropbox\Research Project on Violence Against Women\Police Paper Data Popular\Paper\Submitted\Revisions\Revised Paper\Replication Files\Cordova_Kras_dataset_data popular V1.dta"
 sort cidade
 merge cidade using "`design'"
 
 
 ******Multilevel Model using matched sample. Dependent Variable: Intolerance toward VAW
 estimates clear
meologit  b4dr  i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color [pw=_weight] || cidade: , cov(uns)

 margins , over(female) at(deam=(0 1))expression(predict(mu fixedonly outcome(5)))
 #delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Strongly Agree VAW should not be tolerated", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
 
 margins , over(female) at(deam=(0 1))contrast (overjoint effects) expression(predict(mu fixedonly outcome(5)))
  #delimit;
 
  marginsplot, ciopts(lpattern(dash)) 
title("Panel B", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Difference in Mean Predicted Probabilities", size(small))  xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin)  angle(horizontal)) yline(0)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelB.gph", replace;
 #delimit cr
 
     graph combine "chart1 panelA.gph" "chart1 panelB.gph", rows(1) xcommon imargin(small)   graphregion(color(white)) plotregion(color(white))
 graph save "chart7A combined.gph", replace

 ***Figure 7 lower panel in Manuscript (based on Matched sample)
 ssc install psmatch2, replace
 clear
***NOTE: Before running the code, specify the folder where you saved the dataset on your computer

 use"C:\Users\Abby Cordova\Dropbox\Research Project on Violence Against Women\Police Paper Data Popular\Paper\Submitted\Revisions\Revised Paper\Replication Files\Cordova_Kras_dataset_data popular V1.dta"
 
 tempfile design
 
 collapse ( mean) b4dr deam homiciderate Loggdp_2012 Logpopsize , by(cidade)
 
 * Estimate C using cluster- level variable
 logit deam homiciderate Loggdp_2012 Logpopsize 
 
 * Estimate the  propensity score for each unit
  predict pscore1, pr
  
    *** psmatch2 with nearest neighbor with calipher, replace and common support
  **** Caliper is set to 0.25 standard deviation of the ps
  sum pscore1
  scalar cal =r(sd)*0.25
  
  ***using pstch2 to get the weight
  psmatch2 deam homiciderate Loggdp_2012 Logpopsize,  outcome(b4dr) caliper(`=scalar(cal)')  neighbor(5) common
  pstest homiciderate Loggdp_2012 Logpopsize, sum both
 
 keep cidade _*
 sort cidade
 save "`design'", replace
 
 clear

 use"C:\Users\Abby Cordova\Dropbox\Research Project on Violence Against Women\Police Paper Data Popular\Paper\Submitted\Revisions\Revised Paper\Replication Files\Cordova_Kras_dataset_data popular V1.dta"
 sort cidade
 merge cidade using "`design'"
 
 ******Multilevel Model using matched sample. Dependent Variable: Support for bystander intervention
 
estimates clear
meologit b11ar  i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color [pw=_weight] || cidade: , cov(uns)

 margins , over(female) at(deam=(0 1))expression(predict(mu fixedonly outcome(5)))
 #delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Strongly Agree with Bystander Intervention", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
 
 margins , over(female) at(deam=(0 1))contrast (overjoint effects) expression(predict(mu fixedonly outcome(5)))
  #delimit;
    set level 90;
 marginsplot, ciopts(lpattern(dash)) 
title("Panel B", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Difference in Mean Predicted Probabilities", size(small))  xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin)  angle(horizontal)) yline(0)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelB.gph", replace;
 #delimit cr
 
    graph combine "chart1 panelA.gph" "chart1 panelB.gph", rows(1) xcommon imargin(small)   graphregion(color(white)) plotregion(color(white))
 graph save "chart1 combined.gph", replace

 