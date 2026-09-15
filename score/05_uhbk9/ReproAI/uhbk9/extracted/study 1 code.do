clear *
insheet using "Coronavirus acc v sharing (3.13.20)_USA w cases info.csv"

////////////////
// PRE-PROCESS DATA

destring *, replace force

// generate variables for demographics etc
gen Ldist10=log(min_dist_10)
gen white=ethnicity==1
gen college=education>=6
replace college=. if education==. | education<0

// score attention checks
gen passedS1=(screen1_4==1 & screen1_7==1 & screen1_1==. & screen1_2==. & screen1_3==. & screen1_5==. & screen1_6==. & screen1_8==. & screen1_9==.)
gen passedS2=(screen2_3==1 & screen2_5==1 & screen2_1==. & screen2_2==. & screen2_4==. & screen2_6==. )
gen passedS3=screen3_2==3
gen attention=passedS1+passedS2+passedS3
gen attentive=attention>=2
gen inattentive=1-attentive

// exploratory analysis of relationship between covid concern/news and IVs (Table 2)
pwcorr covid_concern_1 covid_news crt_acc sciknow demrep_c Ldist10 mms , star(0.05 ) sig
reg covid_con crt_acc sciknow demrep_c Ldist10 mms age gender white college, b
reg covid_news crt_acc sciknow demrep_c Ldist10 mms age gender white college, b


// reshape data into long format, one row per rating
replace fake1_1=v104 if v104~=.
replace fake1_2=fake1_20 if fake1_20~=.
replace fake1_3=fake1_30 if fake1_30~=.
replace fake1_4=fake1_40 if fake1_40~=.
replace fake1_5=fake1_50 if fake1_50~=.
replace fake1_6=fake1_60 if fake1_60~=.
replace fake1_7=fake1_70 if fake1_70~=.
replace fake1_8=fake1_80 if fake1_80~=.
replace fake1_9=fake1_90 if fake1_90~=.
replace fake1_10=fake1_100 if fake1_100~=.
replace fake1_11=fake1_110 if fake1_110~=.
replace fake1_12=fake1_120 if fake1_120~=.
replace fake1_13=fake1_130 if fake1_130~=.
replace fake1_14=fake1_140 if fake1_140~=.
replace fake1_15=fake1_150 if fake1_150~=.
replace real1_1=v119 if v119~=.
replace real1_2=real1_20 if real1_20~=.
replace real1_3=real1_30 if real1_30~=.
replace real1_4=real1_40 if real1_40~=.
replace real1_5=real1_50 if real1_50~=.
replace real1_6=real1_60 if real1_60~=.
replace real1_7=real1_70 if real1_70~=.
replace real1_8=real1_80 if real1_80~=.
replace real1_9=real1_90 if real1_90~=.
replace real1_10=real1_100 if real1_100~=.
replace real1_11=real1_110 if real1_110~=.
replace real1_12=real1_120 if real1_120~=.
replace real1_13=real1_130 if real1_130~=.
replace real1_14=real1_140 if real1_140~=.
replace real1_15=real1_150 if real1_150~=.
replace fake1_1=v134 if v134~=.
replace fake1_1=fake1_11 if fake1_11~=.
replace fake1_2=fake1_21 if fake1_21~=.
replace fake1_3=fake1_31 if fake1_31~=.
replace fake1_4=fake1_41 if fake1_41~=.
replace fake1_5=fake1_51 if fake1_51~=.
replace fake1_6=fake1_61 if fake1_61~=.
replace fake1_7=fake1_71 if fake1_71~=.
replace fake1_8=fake1_81 if fake1_81~=.
replace fake1_9=fake1_91 if fake1_91~=.
replace fake1_10=fake1_101 if fake1_101~=.
replace fake1_11=fake1_111 if fake1_111~=.
replace fake1_12=fake1_121 if fake1_121~=.
replace fake1_13=fake1_131 if fake1_131~=.
replace fake1_14=fake1_141 if fake1_141~=.
replace fake1_15=fake1_151 if fake1_151~=.
replace real1_1=v149 if v149~=.
replace real1_1=real1_11 if real1_11~=.
replace real1_2=real1_21 if real1_21~=.
replace real1_3=real1_31 if real1_31~=.
replace real1_4=real1_41 if real1_41~=.
replace real1_5=real1_51 if real1_51~=.
replace real1_6=real1_61 if real1_61~=.
replace real1_7=real1_71 if real1_71~=.
replace real1_8=real1_81 if real1_81~=.
replace real1_9=real1_91 if real1_91~=.
replace real1_10=real1_101 if real1_101~=.
replace real1_11=real1_111 if real1_111~=.
replace real1_12=real1_121 if real1_121~=.
replace real1_13=real1_131 if real1_131~=.
replace real1_14=real1_141 if real1_141~=.
replace real1_15=real1_151 if real1_151~=.
replace fake1_1=v164 if v164~=.
replace fake1_1=fake1_12 if fake1_12~=.
replace fake1_2=fake1_22 if fake1_22~=.
replace fake1_3=fake1_32 if fake1_32~=.
replace fake1_4=fake1_42 if fake1_42~=.
replace fake1_5=fake1_52 if fake1_52~=.
replace fake1_6=fake1_62 if fake1_62~=.
replace fake1_7=fake1_72 if fake1_72~=.
replace fake1_8=fake1_82 if fake1_82~=.
replace fake1_9=fake1_92 if fake1_92~=.
replace fake1_10=fake1_102 if fake1_102~=.
replace fake1_11=fake1_112 if fake1_112~=.
replace fake1_12=fake1_122 if fake1_122~=.
replace fake1_13=fake1_132 if fake1_132~=.
replace fake1_14=fake1_142 if fake1_142~=.
replace fake1_15=fake1_152 if fake1_152~=.
replace real1_1=v179 if v179~=.
replace real1_1=real1_12 if real1_12~=.
replace real1_2=real1_22 if real1_22~=.
replace real1_3=real1_32 if real1_32~=.
replace real1_4=real1_42 if real1_42~=.
replace real1_5=real1_52 if real1_52~=.
replace real1_6=real1_62 if real1_62~=.
replace real1_7=real1_72 if real1_72~=.
replace real1_8=real1_82 if real1_82~=.
replace real1_9=real1_92 if real1_92~=.
replace real1_10=real1_102 if real1_102~=.
replace real1_11=real1_112 if real1_112~=.
replace real1_12=real1_122 if real1_122~=.
replace real1_13=real1_132 if real1_132~=.
replace real1_14=real1_142 if real1_142~=.
replace real1_15=real1_152 if real1_152~=.
drop real fake
gen id=_n
reshape long real1_ fake1_, i(id) j(item_num)
drop if item_num>15
gen tmp=_n
rename real1_ rating1
rename fake1_ rating0
reshape long rating, i(tmp) j(real)
drop tmp
replace item_num=item_num+real*15

// generate centered condition and veracity dummies and their interaction
replace demrep=demrep-1
replace sharing=0 if acc==1
drop acc
gen acc=1-sharing
gen sharingC=sharing-0.5
gen realC=real-0.5
gen realCxsharingC=realC*sharingC

// standardize rating DV
egen zrating=std(rating)
rename rating ratingRaw
rename zrating rating

// make version of rating DV standardized within condition
egen Mrating=mean(ratingRaw), by(sharing)
egen Srating=sd(ratingRaw), by(sharing)
gen zratingByCond=(ratingRaw-Mrating)/Srating
drop Mrating Srating


// create dummies for clear claim of fact, and political content
gen CoF=1
replace CoF=0 if item_num==2 | item_num==11 | item_num==24 | item_num==26 
gen political=0
replace  political=1 if item_num==5 | item_num==12 | item_num==13 | item_num==16 | item_num==17 | item_num==24 | item_num==26 | item_num==30
gen politicalStrict=0
replace  politicalStrict=1 if item_num==5  | item_num==13 |  item_num==17 



// save headline-level accuracy ratings for using in Figure 3 of Study 2 
preserve
collapse (mean) ratingRaw real if sharing==0, by(item_num)
sort item_num
save acc_headlines_corona, replace
restore

// save headline-level accuracy ratings for dems vs reps separate (for analysis of non-political content)
preserve
collapse (mean) ratingRaw real , by(item_num demrep sharing)
drop if demrep==.
gen tmp=item_num+sharing*100
reshape wide ratingRaw, i(tmp) j(demrep)
rename ratingRaw0 ratingD
rename ratingRaw1 ratingR
drop tmp
reshape wide ratingD ratingR, i(item_num) j(sharing)
rename rating*0 acc*
rename rating*1 sharing*
gen accDiff=accD-accR
gen shareDiff=sharingD-sharingR
sort item_num
save acc_headlines_corona_demrep, replace
restore

// merge in item-level accuracy ratings from the preceeding section (for Table S3 analyses)
sort item_num
merge item_num using  acc_headlines_corona_demrep
gen ABSaccDiff=abs(accDiff )
gen ABSshareDiff=abs(shareDiff )

// create interacctions for all of the individual difference moderation analyses
gen collegeXrealC=college*realC
gen ageXrealC=age*realC
gen whiteXrealC=white*realC
replace gender=gender-1
gen genderXrealC=gender*realC
gen demrep_cXrealC=demrep_c*realC

gen collegeXsharingC=college*sharingC
gen ageXsharingC=age*sharingC
gen whiteXsharingC=white*sharingC
gen genderXsharingC=gender*sharingC
gen demrep_cXsharingC=demrep_c*sharingC

gen collegeXsharingCXrealC=college*sharingC*realC
gen ageXsharingCXrealC=age*sharingC*realC
gen whiteXsharingCXrealC=white*sharingC*realC
gen genderXsharingCXrealC=gender*sharingC*realC
gen demrep_cXsharingCXrealC=demrep_c*sharingC*realC




////////////////////////
// ANALYSES

// veracity matters more for accuracy judgments than sharing judgments (unstandardized coeffs)
cluster2 rating realC sharingC realCxsharingC, tcluster(id) fcluster(item_num)
// 2 way interaction
test realCxsharingC=0
// simple effects of real
test realC+realCxsharingC*0.5=0
test realC+realCxsharingC*-0.5=0
// cohens d for simple effects (but ignore these CIs because SEs not clustered - have to calc them from main reg)
bysort sharing: esize twosample rating, by(real)
//  generates standardized coeffs (but ignore p-values because SEs arent clustered)
reg rating realC sharingC realCxsharingC, b

// similar results using logistic regression
logit2 ratingRaw realC sharingC realCxsharingC, tcluster(id) fcluster(item_num)
cluster2 zratingByCond realC sharingC realCxsharingC, tcluster(id) fcluster(item_num)
//    for plot (Figure 1)
bysort sharing real: cluster2 ratingRaw, tcluster(id) fcluster(item_num)


// robust to claim of fact and non-political (Table S3)
xi: cluster2 rating realC sharingC realCxsharingC, tcluster(id) fcluster(item_num)
xi: cluster2 rating realC sharingC realCxsharingC if CoF==1, tcluster(id) fcluster(item_num)
xi: cluster2 rating realC sharingC realCxsharingC if political==0, tcluster(id) fcluster(item_num)
xi: cluster2 rating realC sharingC realCxsharingC if politicalS==0, tcluster(id) fcluster(item_num)
xi: cluster2 rating realC sharingC realCxsharingC if ABSaccDiff<0.1, tcluster(id) fcluster(item_num)
xi: cluster2 rating realC sharingC realCxsharingC if ABSaccDiff<0.05, tcluster(id) fcluster(item_num)
xi: cluster2 rating realC sharingC realCxsharingC if ABSaccDiff<0.025, tcluster(id) fcluster(item_num)

// treatment effect for different levels of attentiveness (Table S2)
cluster2 ratingRaw realC sharingC  realCxsharingC if attention>-1, tcluster(id) fcluster(item_num)
cluster2 ratingRaw realC sharingC  realCxsharingC if attention>0, tcluster(id) fcluster(item_num)
cluster2 ratingRaw realC sharingC  realCxsharingC if attention>1, tcluster(id) fcluster(item_num)
cluster2 ratingRaw realC sharingC  realCxsharingC if attention>2, tcluster(id) fcluster(item_num)




///////////////////////
// Moderation by partisanship?
egen zdemrep=std(demrep)
gen realCXzdemrep=realC*zdemrep
gen sharingCXzdemrep=sharingC*zdemrep
gen realCXsharingCxzdemrep=realC*sharingC*zdemrep

egen zdemrep_c=std(demrep_c)
gen realCXzdemrep_c=realC*zdemrep_c
gen sharingCXzdemrep_c=sharingC*zdemrep_c
gen realCXsharingCxzdemrep_c=realC*sharingC*zdemrep_c

// no 3-way interaction between sharing, veracity, and demrep
cluster2 rating realC sharingC zdemrep realCxsharingC realCXzdemrep sharingCXzdemrep realCXsharingCxzdemrep, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzdemrep=0
//     interaction between demrep and veracity in acc
disp _b[realCXzdemrep]+_b[realCXsharingCxzdemrep]*-0.5=0
test realCXzdemrep+realCXsharingCxzdemrep*-0.5=0
//     simple effect of demrep for real in acc
disp _b[zdemrep]+_b[realCXzdemrep]*0.5+_b[realCXsharingCxzdemrep]*-0.5*0.5 +_b[sharingCXzdemrep]*-0.5=0
test zdemrep+realCXzdemrep*0.5+realCXsharingCxzdemrep*-0.5*0.5 +sharingCXzdemrep*-0.5=0
//     simple effect of demrep for false in acc
disp _b[zdemrep]+_b[realCXzdemrep]*-0.5+_b[realCXsharingCxzdemrep]*-0.5*-0.5 +_b[sharingCXzdemrep]*-0.5=0
test zdemrep+realCXzdemrep*-0.5+realCXsharingCxzdemrep*-0.5*-0.5 +sharingCXzdemrep*-0.5=0
//     interaction between demrep and veracity in sharing
disp _b[realCXzdemrep]+_b[realCXsharingCxzdemrep]*0.5=0
test realCXzdemrep+realCXsharingCxzdemrep*0.5=0
//     simple effect of demrep for real in sharing
disp _b[zdemrep]+_b[realCXzdemrep]*0.5+_b[realCXsharingCxzdemrep]*0.5*0.5 +_b[sharingCXzdemrep]*0.5=0
test zdemrep+realCXzdemrep*0.5+realCXsharingCxzdemrep*0.5*0.5 +sharingCXzdemrep*0.5=0
//     simple effect of demrep for false in sharing
disp _b[zdemrep]+_b[realCXzdemrep]*-0.5+_b[realCXsharingCxzdemrep]*-0.5*0.5 +_b[sharingCXzdemrep]*0.5=0
test zdemrep+realCXzdemrep*-0.5+realCXsharingCxzdemrep*-0.5*0.5 +sharingCXzdemrep*0.5=0

// WITH CONTROLS
// no 3-way interaction between sharing, veracity, and demrep
cluster2 rating realC sharingC zdemrep realCxsharingC realCXzdemrep sharingCXzdemrep realCXsharingCxzdemrep age gender college white ageXrealC genderXrealC collegeXrealC whiteXrealC collegeXsharingC ageXsharingC whiteXsharingC genderXsharingC  collegeXsharingCXrealC ageXsharingCXrealC whiteXsharingCXrealC genderXsharingCXrealC , tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzdemrep=0
//     interaction between demrep and veracity in acc
disp _b[realCXzdemrep]+_b[realCXsharingCxzdemrep]*-0.5=0
test realCXzdemrep+realCXsharingCxzdemrep*-0.5=0
//     simple effect of demrep for real in acc
disp _b[zdemrep]+_b[realCXzdemrep]*0.5+_b[realCXsharingCxzdemrep]*-0.5*0.5 +_b[sharingCXzdemrep]*-0.5=0
test zdemrep+realCXzdemrep*0.5+realCXsharingCxzdemrep*-0.5*0.5 +sharingCXzdemrep*-0.5=0
//     simple effect of demrep for false in acc
disp _b[zdemrep]+_b[realCXzdemrep]*-0.5+_b[realCXsharingCxzdemrep]*-0.5*-0.5 +_b[sharingCXzdemrep]*-0.5=0
test zdemrep+realCXzdemrep*-0.5+realCXsharingCxzdemrep*-0.5*-0.5 +sharingCXzdemrep*-0.5=0
//     interaction between demrep and veracity in sharing
disp _b[realCXzdemrep]+_b[realCXsharingCxzdemrep]*0.5=0
test realCXzdemrep+realCXsharingCxzdemrep*0.5=0
//     simple effect of demrep for real in sharing
disp _b[zdemrep]+_b[realCXzdemrep]*0.5+_b[realCXsharingCxzdemrep]*0.5*0.5 +_b[sharingCXzdemrep]*0.5=0
test zdemrep+realCXzdemrep*0.5+realCXsharingCxzdemrep*0.5*0.5 +sharingCXzdemrep*0.5=0
//     simple effect of demrep for false in sharing
disp _b[zdemrep]+_b[realCXzdemrep]*-0.5+_b[realCXsharingCxzdemrep]*-0.5*0.5 +_b[sharingCXzdemrep]*0.5=0
test zdemrep+realCXzdemrep*-0.5+realCXsharingCxzdemrep*-0.5*0.5 +sharingCXzdemrep*0.5=0


 
////////////////////////
// Moderation by CRT?
egen zcrt=std(crt_acc)
gen realCXzcrt=realC*zcrt
gen sharingCXzcrt=sharingC*zcrt
gen realCXsharingCxzcrt=realC*sharingC*zcrt

// CRT has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zcrt realCxsharingC realCXzcrt sharingCXzcrt realCXsharingCxzcrt, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzcrt=0
//     interaction between CRT and veracity in acc
disp _b[realCXzcrt]+_b[realCXsharingCxzcrt]*-0.5=0
test realCXzcrt+realCXsharingCxzcrt*-0.5=0
//     simple effect of CRT for real in acc
disp _b[zcrt]+_b[realCXzcrt]*0.5+_b[realCXsharingCxzcrt]*-0.5*0.5 +_b[sharingCXzcrt]*-0.5=0
test zcrt+realCXzcrt*0.5+realCXsharingCxzcrt*-0.5*0.5 +sharingCXzcrt*-0.5=0
//     simple effect of CRT for false in acc
disp _b[zcrt]+_b[realCXzcrt]*-0.5+_b[realCXsharingCxzcrt]*-0.5*-0.5 +_b[sharingCXzcrt]*-0.5=0
test zcrt+realCXzcrt*-0.5+realCXsharingCxzcrt*-0.5*-0.5 +sharingCXzcrt*-0.5=0
//     interaction between CRT and veracity in sharing
disp _b[realCXzcrt]+_b[realCXsharingCxzcrt]*0.5=0
test realCXzcrt+realCXsharingCxzcrt*0.5=0
//     simple effect of CRT for real in sharing
disp _b[zcrt]+_b[realCXzcrt]*0.5+_b[realCXsharingCxzcrt]*0.5*0.5 +_b[sharingCXzcrt]*0.5=0
test zcrt+realCXzcrt*0.5+realCXsharingCxzcrt*0.5*0.5 +sharingCXzcrt*0.5=0
//     simple effect of CRT for false in sharing
disp _b[zcrt]+_b[realCXzcrt]*-0.5+_b[realCXsharingCxzcrt]*-0.5*0.5 +_b[sharingCXzcrt]*0.5=0
test zcrt+realCXzcrt*-0.5+realCXsharingCxzcrt*-0.5*0.5 +sharingCXzcrt*0.5=0

// WITH CONTROLS
// CRT has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zcrt realCxsharingC realCXzcrt sharingCXzcrt realCXsharingCxzcrt age gender college white demrep_c ageXrealC genderXrealC collegeXrealC whiteXrealC demrep_cXrealC collegeXsharingC ageXsharingC whiteXsharingC genderXsharingC demrep_cXsharingC collegeXsharingCXrealC ageXsharingCXrealC whiteXsharingCXrealC genderXsharingCXrealC demrep_cXsharingCXrealC, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzcrt=0
//     interaction between CRT and veracity in acc
disp _b[realCXzcrt]+_b[realCXsharingCxzcrt]*-0.5=0
test realCXzcrt+realCXsharingCxzcrt*-0.5=0
//     simple effect of CRT for real in acc
disp _b[zcrt]+_b[realCXzcrt]*0.5+_b[realCXsharingCxzcrt]*-0.5*0.5 +_b[sharingCXzcrt]*-0.5=0
test zcrt+realCXzcrt*0.5+realCXsharingCxzcrt*-0.5*0.5 +sharingCXzcrt*-0.5=0
//     simple effect of CRT for false in acc
disp _b[zcrt]+_b[realCXzcrt]*-0.5+_b[realCXsharingCxzcrt]*-0.5*-0.5 +_b[sharingCXzcrt]*-0.5=0
test zcrt+realCXzcrt*-0.5+realCXsharingCxzcrt*-0.5*-0.5 +sharingCXzcrt*-0.5=0
//     interaction between CRT and veracity in sharing
disp _b[realCXzcrt]+_b[realCXsharingCxzcrt]*0.5=0
test realCXzcrt+realCXsharingCxzcrt*0.5=0
//     simple effect of CRT for real in sharing
disp _b[zcrt]+_b[realCXzcrt]*0.5+_b[realCXsharingCxzcrt]*0.5*0.5 +_b[sharingCXzcrt]*0.5=0
test zcrt+realCXzcrt*0.5+realCXsharingCxzcrt*0.5*0.5 +sharingCXzcrt*0.5=0
//     simple effect of CRT for false in sharing
disp _b[zcrt]+_b[realCXzcrt]*-0.5+_b[realCXsharingCxzcrt]*-0.5*0.5 +_b[sharingCXzcrt]*0.5=0
test zcrt+realCXzcrt*-0.5+realCXsharingCxzcrt*-0.5*0.5 +sharingCXzcrt*0.5=0




////////////////////////
// Moderation by science knowledge
egen zSK=std(sciknow)
gen realCXzSK=realC*zSK
gen sharingCXzSK=sharingC*zSK
gen realCXsharingCxzSK=realC*sharingC*zSK
xtile BSK=sciknow
// SK has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zSK realCxsharingC realCXzSK sharingCXzSK realCXsharingCxzSK, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzSK=0
//     interaction between SK and veracity in acc
disp _b[realCXzSK]+_b[realCXsharingCxzSK]*-0.5=0
test realCXzSK+realCXsharingCxzSK*-0.5=0
//     simple effect of SK for real in acc
disp _b[zSK]+_b[realCXzSK]*0.5+_b[realCXsharingCxzSK]*-0.5*0.5 +_b[sharingCXzSK]*-0.5=0
test zSK+realCXzSK*0.5+realCXsharingCxzSK*-0.5*0.5 +sharingCXzSK*-0.5=0
//     simple effect of SK for false in acc
disp _b[zSK]+_b[realCXzSK]*-0.5+_b[realCXsharingCxzSK]*-0.5*-0.5 +_b[sharingCXzSK]*-0.5=0
test zSK+realCXzSK*-0.5+realCXsharingCxzSK*-0.5*-0.5 +sharingCXzSK*-0.5=0
//     interaction between SK and veracity in sharing
disp _b[realCXzSK]+_b[realCXsharingCxzSK]*0.5=0
test realCXzSK+realCXsharingCxzSK*0.5=0
//     simple effect of SK for real in sharing
disp _b[zSK]+_b[realCXzSK]*0.5+_b[realCXsharingCxzSK]*0.5*0.5 +_b[sharingCXzSK]*0.5=0
test zSK+realCXzSK*0.5+realCXsharingCxzSK*0.5*0.5 +sharingCXzSK*0.5=0
//     simple effect of SK for false in sharing
disp _b[zSK]+_b[realCXzSK]*-0.5+_b[realCXsharingCxzSK]*-0.5*0.5 +_b[sharingCXzSK]*0.5=0
test zSK+realCXzSK*-0.5+realCXsharingCxzSK*-0.5*0.5 +sharingCXzSK*0.5=0

// WITH CONTROLS
// SK has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zSK realCxsharingC realCXzSK sharingCXzSK realCXsharingCxzSK  age gender college white demrep_c ageXrealC genderXrealC collegeXrealC whiteXrealC demrep_cXrealC collegeXsharingC ageXsharingC whiteXsharingC genderXsharingC demrep_cXsharingC collegeXsharingCXrealC ageXsharingCXrealC whiteXsharingCXrealC genderXsharingCXrealC demrep_cXsharingCXrealC, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzSK=0
// 2 way on discernment
test realCXzSK=0
//     interaction between SK and veracity in acc
disp _b[realCXzSK]+_b[realCXsharingCxzSK]*-0.5=0
test realCXzSK+realCXsharingCxzSK*-0.5=0
//     simple effect of SK for real in acc
disp _b[zSK]+_b[realCXzSK]*0.5+_b[realCXsharingCxzSK]*-0.5*0.5 +_b[sharingCXzSK]*-0.5=0
test zSK+realCXzSK*0.5+realCXsharingCxzSK*-0.5*0.5 +sharingCXzSK*-0.5=0
//     simple effect of SK for false in acc
disp _b[zSK]+_b[realCXzSK]*-0.5+_b[realCXsharingCxzSK]*-0.5*-0.5 +_b[sharingCXzSK]*-0.5=0
test zSK+realCXzSK*-0.5+realCXsharingCxzSK*-0.5*-0.5 +sharingCXzSK*-0.5=0
//     interaction between SK and veracity in sharing
disp _b[realCXzSK]+_b[realCXsharingCxzSK]*0.5=0
test realCXzSK+realCXsharingCxzSK*0.5=0
//     simple effect of SK for real in sharing
disp _b[zSK]+_b[realCXzSK]*0.5+_b[realCXsharingCxzSK]*0.5*0.5 +_b[sharingCXzSK]*0.5=0
test zSK+realCXzSK*0.5+realCXsharingCxzSK*0.5*0.5 +sharingCXzSK*0.5=0
//     simple effect of SK for false in sharing
disp _b[zSK]+_b[realCXzSK]*-0.5+_b[realCXsharingCxzSK]*-0.5*0.5 +_b[sharingCXzSK]*0.5=0
test zSK+realCXzSK*-0.5+realCXsharingCxzSK*-0.5*0.5 +sharingCXzSK*0.5=0









////////////////////////
// Moderation by MMS
egen zMMS=std(mms)
gen realCXzMMS=realC*zMMS
gen sharingCXzMMS=sharingC*zMMS
gen realCXsharingCxzMMS=realC*sharingC*zMMS
xtile BMMS=mms
// MMS has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zMMS realCxsharingC realCXzMMS sharingCXzMMS realCXsharingCxzMMS, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzMMS=0
//     interaction between MMS and veracity in acc
disp _b[realCXzMMS]+_b[realCXsharingCxzMMS]*-0.5=0
test realCXzMMS+realCXsharingCxzMMS*-0.5=0
//     simple effect of MMS for real in acc
disp _b[zMMS]+_b[realCXzMMS]*0.5+_b[realCXsharingCxzMMS]*-0.5*0.5 +_b[sharingCXzMMS]*-0.5=0
test zMMS+realCXzMMS*0.5+realCXsharingCxzMMS*-0.5*0.5 +sharingCXzMMS*-0.5=0
//     simple effect of MMS for false in acc
disp _b[zMMS]+_b[realCXzMMS]*-0.5+_b[realCXsharingCxzMMS]*-0.5*-0.5 +_b[sharingCXzMMS]*-0.5=0
test zMMS+realCXzMMS*-0.5+realCXsharingCxzMMS*-0.5*-0.5 +sharingCXzMMS*-0.5=0
//     interaction between MMS and veracity in sharing
disp _b[realCXzMMS]+_b[realCXsharingCxzMMS]*0.5=0
test realCXzMMS+realCXsharingCxzMMS*0.5=0
//     simple effect of MMS for real in sharing
disp _b[zMMS]+_b[realCXzMMS]*0.5+_b[realCXsharingCxzMMS]*0.5*0.5 +_b[sharingCXzMMS]*0.5=0
test zMMS+realCXzMMS*0.5+realCXsharingCxzMMS*0.5*0.5 +sharingCXzMMS*0.5=0
//     simple effect of MMS for false in sharing
disp _b[zMMS]+_b[realCXzMMS]*-0.5+_b[realCXsharingCxzMMS]*-0.5*0.5 +_b[sharingCXzMMS]*0.5=0
test zMMS+realCXzMMS*-0.5+realCXsharingCxzMMS*-0.5*0.5 +sharingCXzMMS*0.5=0

// WITH CONTROLS
// MMS has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zMMS realCxsharingC realCXzMMS sharingCXzMMS realCXsharingCxzMMS  age gender college white demrep_c ageXrealC genderXrealC collegeXrealC whiteXrealC demrep_cXrealC collegeXsharingC ageXsharingC whiteXsharingC genderXsharingC demrep_cXsharingC collegeXsharingCXrealC ageXsharingCXrealC whiteXsharingCXrealC genderXsharingCXrealC demrep_cXsharingCXrealC, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzMMS=0
//     interaction between MMS and veracity in acc
disp _b[realCXzMMS]+_b[realCXsharingCxzMMS]*-0.5=0
test realCXzMMS+realCXsharingCxzMMS*-0.5=0
//     simple effect of MMS for real in acc
disp _b[zMMS]+_b[realCXzMMS]*0.5+_b[realCXsharingCxzMMS]*-0.5*0.5 +_b[sharingCXzMMS]*-0.5=0
test zMMS+realCXzMMS*0.5+realCXsharingCxzMMS*-0.5*0.5 +sharingCXzMMS*-0.5=0
//     simple effect of MMS for false in acc
disp _b[zMMS]+_b[realCXzMMS]*-0.5+_b[realCXsharingCxzMMS]*-0.5*-0.5 +_b[sharingCXzMMS]*-0.5=0
test zMMS+realCXzMMS*-0.5+realCXsharingCxzMMS*-0.5*-0.5 +sharingCXzMMS*-0.5=0
//     interaction between MMS and veracity in sharing
disp _b[realCXzMMS]+_b[realCXsharingCxzMMS]*0.5=0
test realCXzMMS+realCXsharingCxzMMS*0.5=0
//     simple effect of MMS for real in sharing
disp _b[zMMS]+_b[realCXzMMS]*0.5+_b[realCXsharingCxzMMS]*0.5*0.5 +_b[sharingCXzMMS]*0.5=0
test zMMS+realCXzMMS*0.5+realCXsharingCxzMMS*0.5*0.5 +sharingCXzMMS*0.5=0
//     simple effect of MMS for false in sharing
disp _b[zMMS]+_b[realCXzMMS]*-0.5+_b[realCXsharingCxzMMS]*-0.5*0.5 +_b[sharingCXzMMS]*0.5=0
test zMMS+realCXzMMS*-0.5+realCXsharingCxzMMS*-0.5*0.5 +sharingCXzMMS*0.5=0




////////////////////////
// Moderation by distance
egen zdist10=std(log(min_dist_10))
gen realCXzdist10=realC*zdist10
gen sharingCXzdist10=sharingC*zdist10
gen realCXsharingCxzdist10=realC*sharingC*zdist10
xtile Bdist10=min_dist_10
// dist10 has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zdist10 realCxsharingC realCXzdist10 sharingCXzdist10 realCXsharingCxzdist10, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzdist10=0
// 		interaction between dist10 and sharing
test sharingCXzdist10=0
//     interaction between dist10 and veracity in acc
disp _b[realCXzdist10]+_b[realCXsharingCxzdist10]*-0.5=0
test realCXzdist10+realCXsharingCxzdist10*-0.5=0
//     simple effect of dist10 for real in acc
disp _b[zdist10]+_b[realCXzdist10]*0.5+_b[realCXsharingCxzdist10]*-0.5*0.5 +_b[sharingCXzdist10]*-0.5=0
test zdist10+realCXzdist10*0.5+realCXsharingCxzdist10*-0.5*0.5 +sharingCXzdist10*-0.5=0
//     simple effect of dist10 for false in acc
disp _b[zdist10]+_b[realCXzdist10]*-0.5+_b[realCXsharingCxzdist10]*-0.5*-0.5 +_b[sharingCXzdist10]*-0.5=0
test zdist10+realCXzdist10*-0.5+realCXsharingCxzdist10*-0.5*-0.5 +sharingCXzdist10*-0.5=0
//     interaction between dist10 and veracity in sharing
disp _b[realCXzdist10]+_b[realCXsharingCxzdist10]*0.5=0
test realCXzdist10+realCXsharingCxzdist10*0.5=0
//     simple effect of dist10 for real in sharing
disp _b[zdist10]+_b[realCXzdist10]*0.5+_b[realCXsharingCxzdist10]*0.5*0.5 +_b[sharingCXzdist10]*0.5=0
test zdist10+realCXzdist10*0.5+realCXsharingCxzdist10*0.5*0.5 +sharingCXzdist10*0.5=0
//     simple effect of dist10 for false in sharing
disp _b[zdist10]+_b[realCXzdist10]*-0.5+_b[realCXsharingCxzdist10]*-0.5*0.5 +_b[sharingCXzdist10]*0.5=0
test zdist10+realCXzdist10*-0.5+realCXsharingCxzdist10*-0.5*0.5 +sharingCXzdist10*0.5=0

// WITH CONTROLS
// dist10 has differential impact on discernment for accuracy vs sharing
cluster2 rating realC sharingC zdist10 realCxsharingC realCXzdist10 sharingCXzdist10 realCXsharingCxzdist10   age gender college white demrep_c ageXrealC genderXrealC collegeXrealC whiteXrealC demrep_cXrealC collegeXsharingC ageXsharingC whiteXsharingC genderXsharingC demrep_cXsharingC collegeXsharingCXrealC ageXsharingCXrealC whiteXsharingCXrealC genderXsharingCXrealC demrep_cXsharingCXrealC, tcluster(id) fcluster(item_num)
// 3 way
test realCXsharingCxzdist10=0
// 		interaction between dist10 and sharing
test sharingCXzdist10=0
//     interaction between dist10 and veracity in acc
disp _b[realCXzdist10]+_b[realCXsharingCxzdist10]*-0.5=0
test realCXzdist10+realCXsharingCxzdist10*-0.5=0
//     simple effect of dist10 for real in acc
disp _b[zdist10]+_b[realCXzdist10]*0.5+_b[realCXsharingCxzdist10]*-0.5*0.5 +_b[sharingCXzdist10]*-0.5=0
test zdist10+realCXzdist10*0.5+realCXsharingCxzdist10*-0.5*0.5 +sharingCXzdist10*-0.5=0
//     simple effect of dist10 for false in acc
disp _b[zdist10]+_b[realCXzdist10]*-0.5+_b[realCXsharingCxzdist10]*-0.5*-0.5 +_b[sharingCXzdist10]*-0.5=0
test zdist10+realCXzdist10*-0.5+realCXsharingCxzdist10*-0.5*-0.5 +sharingCXzdist10*-0.5=0
//     interaction between dist10 and veracity in sharing
disp _b[realCXzdist10]+_b[realCXsharingCxzdist10]*0.5=0
test realCXzdist10+realCXsharingCxzdist10*0.5=0
//     simple effect of dist10 for real in sharing
disp _b[zdist10]+_b[realCXzdist10]*0.5+_b[realCXsharingCxzdist10]*0.5*0.5 +_b[sharingCXzdist10]*0.5=0
test zdist10+realCXzdist10*0.5+realCXsharingCxzdist10*0.5*0.5 +sharingCXzdist10*0.5=0
//     simple effect of dist10 for false in sharing
disp _b[zdist10]+_b[realCXzdist10]*-0.5+_b[realCXsharingCxzdist10]*-0.5*0.5 +_b[sharingCXzdist10]*0.5=0
test zdist10+realCXzdist10*-0.5+realCXsharingCxzdist10*-0.5*0.5 +sharingCXzdist10*0.5=0





















