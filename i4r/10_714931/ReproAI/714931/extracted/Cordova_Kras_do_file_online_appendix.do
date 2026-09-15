********************Online Appendix
 **************Table A2.Probability of Knowing a Victim of Intimate Partner Violence by Age of WPS
 estimates clear
melogit knowvictim  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

***************Table A3. Women’s Probability of Personally Experiencing Intimate Partner Violence
estimates clear
melogit b9a i.deam i.vaw_law i.civilpolice femiciderate Loggdp_2012 Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

**************Table A4. Examining Possible Deterrence Effects among Men
estimates clear
 meologit  b4dr   a3aer b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color if female==0 & deam==1 || cidade: , cov(uns)
 meologit  b4dr   a3aer b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color if female==0 & deam==0 || cidade: , cov(uns)
 
 meologit  b11ar   a3aer b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color if female==0 & deam==1 || cidade: , cov(uns)
 meologit  b11ar   a3aer b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color if female==0 & deam==0 || cidade: , cov(uns)
 
 *************Table A5. Examining Possible Deterrence Effects among Men in Municipalities with a WPS older than 18 years
   estimates clear
 meologit  b4dr   a3aer b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color if female==0 & num_years>18 || cidade: , cov(uns)
 meologit  b11ar   a3aer b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color if female==0 & num_years>18 || cidade: , cov(uns)
  
  ************Table A6. Effect of WPS on Attitudes toward VAW, controlling for Age of Oldest Feminist Organization
  estimates clear
meologit  b4dr   i.deam##i.female i.vaw_law##i.female c.yearscollective i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b4dr  c.num_years##i.female i.vaw_law##i.female c.yearscollective i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b11ar  i.deam##i.female i.vaw_law##i.female c.yearscollective i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)
meologit b11ar  c.num_years##i.female i.vaw_law##i.female c.yearscollective i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

***************Table A7. Effect of WPS on Attitudes toward VAW, controlling for Number of Protests by a Feminist Organization
estimates clear
meologit  b4dr   i.deam##i.female i.vaw_law##i.female c.protest_fem i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b4dr  c.num_years##i.female i.vaw_law##i.female c.protest_fem i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b11ar  i.deam##i.female i.vaw_law##i.female c.protest_fem i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)
meologit b11ar  c.num_years##i.female i.vaw_law##i.female c.protest_fem i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

***************Table A8. Effect of WPS on Attitudes toward VAW, controlling for an individual-level variable on knowledge of the Maria da Penha Law
estimates clear
meologit  b4dr   i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize c6r b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b4dr  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize c6r b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b11ar  i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize c6r b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)
meologit b11ar  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize c6r b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

***************Table A9. Effect of WPS on Attitudes toward VAW, controlling for homicide rates
estimates clear
meologit  b4dr   i.deam##i.female i.vaw_law##i.female i.civilpolice homiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b4dr  c.num_years##i.female i.vaw_law##i.female i.civilpolice homiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b11ar  i.deam##i.female i.vaw_law##i.female i.civilpolice homiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)
meologit b11ar  c.num_years##i.female i.vaw_law##i.female i.civilpolice homiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

***************Table A10. Effect of WPS on Attitudes toward VAW, controlling for Education at the Municipal Level
estimates clear
meologit  b4dr   i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.education_muni_2010 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b4dr  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate c.education_muni_2010 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)
meologit b11ar  i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.education_muni_2010 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)
meologit b11ar  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate c.education_muni_2010 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color   || cidade: , cov(uns)

********Table A11. Multicollinearity Test: Variance Inflation Factor
reg b4dr i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color, cl( cidade)
vif

reg b11ar  i.deam##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color, cl(cidade)
vif

reg b4dr  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color, cl(cidade)
 vif
 
reg b11ar  c.num_years##i.female i.vaw_law##i.female i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color, cl(cidade)
vif

 ***Table A16.Personally Experienced Intimate Partner Violence (Matched Sample)
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
 
 estimates clear
 
eststo: melogit b9a i.deam i.vaw_law i.civilpolice femiciderate c.Loggdp_2012 c.Logpopsize b4gr q91cr q91er c1r q89er i.b0.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color [pw=_weight]  || cidade: , cov(uns)

*********Table A17. Knows the Location of the Women’s Police Station in their Municipality 
melogit knowdeam1 c.num_years i.female i.b1.edlevel  classe q53r i.b1.p2a i.b1.marital_status children i.b1.color  || cidade: , cov(uns)

*********Figure A1. Predicted Probability of Knowing WPS location by Years of WPS Creation
 margins , over(female) at(num_years=(0 (2) 28))predict(mu fixedonly )
#delimit;
 marginsplot, noci
title("Panel A", size(small)  justification(center) alignment(baseline)) 
 xtit("") ytit("Mean Predicted Probability" "Knowing WPS Location in Municipality", size(small)) xsc(r(-0.5 1.5)) xlabel(, angle(horizontal) valuelabel labsize(small))
 ylabel(, format(%9.2fc) grid glcolor("217 217 217") glwidth(vthin) gmax angle(horizontal)) legend(off)
 scheme(s1color) graphregion(fcolor(white) lwidth(none)) plotregion(fcolor(white) lwidth(none));
 graph save "chart1 panelA.gph", replace;
 #delimit cr
