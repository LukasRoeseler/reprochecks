clear
insheet using "Coronavirus asking acc (3.15.20)_USA_dist_pop_gdp.csv"


//////////////////
// PRE-PROCESS DATA

destring *, replace force

// reshape data into long format, one row per rating
drop real fake
gen id=_n
reshape long real1_ fake1_, i(id) j(item_num)
gen tmp=_n
rename real1_ rating1
rename fake1_ rating0
reshape long rating, i(tmp) j(real)
drop tmp
drop if rating==.
replace item_num=item_num+real*15

// recode partisanship variable
replace demrep=demrep-1

// generate condition dummies and interactions with veracity
gen treatment=condition==2
gen control=1-treatment
gen realxtreatment = real*treatment
gen realxcontrol= real*control

// create dummies for clear claim of fact, and political content
gen CoF=1
replace CoF=0 if item_num==2 | item_num==11 | item_num==24 | item_num==26 
gen political=0
replace  political=1 if item_num==5 | item_num==12 | item_num==13 | item_num==16 | item_num==17 | item_num==24 | item_num==26 | item_num==30
gen politicalStrict=0
replace  politicalStrict=1 if item_num==5  | item_num==13 |  item_num==17 

// make binary version of rating for visualization
gen Brating=rating>3
replace Brating=. if rating==.
replace rating=(rating-1)/5

// code attention checks
gen passedS1=(screen1_4==1 & screen1_7==1 & screen1_1==. & screen1_2==. & screen1_3==. & screen1_5==. & screen1_6==. & screen1_8==. & screen1_9==.)
gen passedS2=(screen2_3==1 & screen2_5==1 & screen2_1==. & screen2_2==. & screen2_4==. & screen2_6==. )
gen passedS3=screen3_2==3
gen attention=passedS1+passedS2+passedS3
gen attentive=attention>=2
tabulate attention







////////////////////////
// ANALYSIS


// treatment increases discernment (produces undstandardized coeffs)
cluster2 rating real treatment realxtreatment, tcluster(id) fcluster(item_num)
// interaction
test realxtreatment=0
// simple effect of real in control
disp _b[real]
test real=0
// simple effect of real in treatment 
disp _b[real]+_b[realxtreatment]
test real+realxtreatment=0
// standardized coeffs (but ignore p values because this reg doesnt cluster SEs)
reg rating real treatment realxtreatment
// effect size for simple effects of veracity (but ignore these CIs because SEs not clustered - have to calc them from main reg)
bysort treatment: esize twosample rating, by(real)
// means and CIs for plots 
//       Figure 2 (discertized DV)
bysort real treatment: cluster2 Brating, tcluster(id) fcluster(item_num)
//       Figure S1 (raw means)
bysort real treatment: cluster2 rating, tcluster(id) fcluster(item_num)
   

// robustness to different levels of filtering on attentiveness - Table S5
cluster2 rating real treatment realxtreatment if attention>-1, tcluster(id) fcluster(item_num)
cluster2 rating real treatment realxtreatment if attention>0, tcluster(id) fcluster(item_num)
cluster2 rating real treatment realxtreatment if attention>1, tcluster(id) fcluster(item_num)
cluster2 rating real treatment realxtreatment if attention>2, tcluster(id) fcluster(item_num)





// headline-level analysis  (Figure 3)
preserve
// calculate item-level avg sharing rates by condition
collapse (mean) rating real , by(item_num treatment)
reshape wide rating, i(item_num) j(treatment)
// calculate treatment effect for each item
gen treatmentEffect=rating1-rating0
// merge in perceived accuracy data from Study 1
sort item_num
merge item_num using acc_headlines_corona
// create Fig 3
twoway (scatter treatmentEffect ratingRaw if real==0)  (scatter treatmentEffect ratingRaw if real==1), name(all)
// calculate correlation
pwcorr treatmentEffect ratingRaw, sig
restore



// robustness to claim of fact and non-Parisan headlines  (Table S6)
//    merge in partisan diffs in percevied accuracy from Study 1
sort item_num
merge item_num using  acc_headlines_corona_demrep
gen ABSaccDiff=abs(accDiff )
gen ABSshareDiff=abs(shareDiff )
//   regs for table S6
xi: cluster2 rating real treatment realxtreatment, tcluster(id) fcluster(item_num)
xi: cluster2 rating real treatment realxtreatment if CoF==1, tcluster(id) fcluster(item_num)
xi: cluster2 rating real treatment realxtreatment if political==0, tcluster(id) fcluster(item_num)
xi: cluster2 rating real treatment realxtreatment if politicalS==0, tcluster(id) fcluster(item_num)
xi: cluster2 rating real treatment realxtreatment if ABSaccDiff<0.1, tcluster(id) fcluster(item_num)
xi: cluster2 rating real treatment realxtreatment if ABSaccDiff<0.05, tcluster(id) fcluster(item_num)
xi: cluster2 rating real treatment realxtreatment if ABSaccDiff<0.025, tcluster(id) fcluster(item_num)





// No significant moderation effects

// no 3-way interaction with Democrat v Republican
egen zdemrep=std(demrep)
gen realXzdemrep=real*zdemrep
gen treatmentXzdemrep=treatment*zdemrep
gen realXtreatmentxzdemrep=real*treatment*zdemrep
cluster2 rating real treatment zdemrep realxtreatment realXzdemrep treatmentXzdemrep realXtreatmentxzdemrep, tcluster(id) fcluster(item_num)

// no 3-way interaction with CRT
egen zcrt=std(crt_acc)
gen realXzcrt=real*zcrt
gen treatmentXzcrt=treatment*zcrt
gen realXtreatmentxzcrt=real*treatment*zcrt
cluster2 rating real treatment zcrt realxtreatment realXzcrt treatmentXzcrt realXtreatmentxzcrt, tcluster(id) fcluster(item_num)

// no 3-way interaction with science knowledgeegen
egen zSK=std(sciknow)
gen realXzSK=real*zSK
gen treatmentXzSK=treatment*zSK
gen realXtreatmentxzSK=real*treatment*zSK
cluster2 rating real treatment zSK realxtreatment realXzSK treatmentXzSK realXtreatmentxzSK, tcluster(id) fcluster(item_num)

// no 3 way interaction with MMS
egen zMMS=std(mms)
gen realXzMMS=real*zMMS
gen treatmentXzMMS=treatment*zMMS
gen realXtreatmentxzMMS=real*treatment*zMMS
cluster2 rating real treatment zMMS realxtreatment realXzMMS treatmentXzMMS realXtreatmentxzMMS, tcluster(id) fcluster(item_num)

// no 3 way interaction with distance to nearest epicenter
egen zdist10=std(log(min_dist_10))
gen realXzdist10=real*zdist10
gen treatmentXzdist10=treatment*zdist10
gen realXtreatmentxzdist10=real*treatment*zdist10
cluster2 rating real treatment zdist10 realxtreatment realXzdist10 treatmentXzdist10 realXtreatmentxzdist10, tcluster(id) fcluster(item_num)



