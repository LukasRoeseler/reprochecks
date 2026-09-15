clear all

cd "/Users/bnyhan/Dropbox/Misperceptions/Omidyar/CCAP Experiments/"
use CCAP2012_GSU_ALL_OUTPUT.DTA

svyset [pweight=weight]

revrs pp_newsint2 pp_trustgov
rename revpp_newsint2 pre_newsint
rename revpp_trustgov pre_trustgov

gen crooked=GSU204
recode crooked (1=4) (2=3) (3=2) (4=1)

gen trustgov=GSU201
recode trustgov (1=5) (2=4) (4=2) (5=1)

gen govtfewbig=GSU202x
recode govtfewbig (1=6) (2=5) (3=4) (4=3) (5=2) (6=1)
replace govtfewbig=5 if GSU202==1 & GSU202x==.
replace govtfewbig=2 if GSU202==2 & GSU202x==.

gen govtwaste=GSU203
recode govtwaste (1=4) (2=3) (3=2) (4=1)

factor crooked trustgov govtfewbig govtwaste,pcf

gen pre_rightdir=pp_track
recode pre_rightdir (1=3) (2=1) (3=2) 

gen pre_persfinretro=pp_persfinretro
recode pre_persfinretro (1=3) (4=2) (3=1) 

gen pre_econtrend=pp_econtrend
recode pre_econtrend (1=3) (4=2) (3=1)

gen pre_fatalism=pp_fatalism
recode pre_fatalism (1=5) (2=4) (3=2) (4=1) (5=3)

gen pre_obamaapp=pp_obamaapp
recode pre_obamaapp (1=5) (2=4) (3=2) (4=1) (5=3)

gen pre_watchtv=pp_watchtv

gen pre_iraqimp = pp_imiss_a
gen pre_econimp = pp_imiss_b
gen pre_immiimp = pp_imiss_c
gen pre_evirnimp = pp_imiss_d
gen pre_terrorimp = pp_imiss_f
gen pre_gaysimp = pp_imiss_g
gen pre_educimp = pp_imiss_h
gen pre_healthcareimp = pp_imiss_j
gen pre_socsecimp = pp_imiss_m
gen pre_deifcitimp = pp_imiss_p
gen pre_afghanistanimp = pp_imiss_q
gen pre_taxesimp = pp_imiss_r
gen pre_medicareimp = pp_imiss_s
gen pre_abortionimp = pp_imiss_t

foreach var of varlist pre_iraqimp pre_econimp pre_immiimp pre_evirnimp pre_terrorimp pre_gaysimp pp_imiss_g pre_educimp pre_healthcareimp pre_socsecimp pre_deifcitimp pre_afghanistanimp pre_taxesimp pre_medicareimp pre_abortionimp {
recode `var' (1=4) (2=3) (3=2) (4=1)
}

gen pre_party7 = pp_pid7
replace pre_party7=4 if pre_party==8

gen dem=(pre_party7<4)
gen rep=(pre_party7>4 & pre_party7<8)

gen demnolean=(pre_party7<3)
gen repnolean=(pre_party7>5 & pre_party7<8)

pwcorr crooked trustgov govtfewbig govtwaste pre_party

gen pre_polinterest=pp_polinterest
recode pre_polinterest (1=3) (2=1) (3=2) 

gen pre_polknowSA = pp_pol_know
recode pre_polknowSA (1=4) (2=3) (3=2) (4=1)

gen pre_know1=(pp_pk_ideo==2)
gen pre_know2=(pp_pk_house==2)
gen pre_know3=(pp_pk_senate==1)
gen pre_know4=(pp_pk_HMinL==1)
gen pre_know5=(pp_pk_Speaker==1)
gen pre_know6=(pp_pk_HMajL==1)
gen pre_know7=(pp_pk_SMinL==2)
gen pre_know8=(pp_pk_VP==4)
gen pre_know9=(pp_pk_SMajL==2)
gen pre_know10=(pp_pk_SCJ==5)

gen pre_polknow=pre_know1+pre_know2+pre_know3+pre_know4+pre_know5+pre_know6+pre_know7+pre_know8+pre_know9+pre_know10

gen pre_obamafav = pp_fav_obama
recode pre_obamafav (1=5) (2=4) (3=2) (4=1) (8=3)

gen pre_romneyfav = pp_fav_romn
recode pre_romneyfav (1=5) (2=4) (3=2) (4=1) (8=3)

gen vote1=W1_cmatch_romn2_alt

/* Experiment 2: Causal corrections */

*Block 1: Resign without reason (control)
*Block 2: Resign with innuendo
*Block 3: Resign with innuendo + denial statement
*Block 4: Resign with innuendo + causal statement

drop if W1_newsint!=.
drop if W3_newsint!=.

svy: tab dem 
svy: tab rep
svy: tab demnolean
svy: tab repnolean

gen swensenrand=blockrand if W2_newsint!=.
tab blockrand if W2_newsint!=., gen(swensencond)

gen swensenfav=GSU210
recode swensenfav (1=6) (2=5) (3=4) (4=3) (5=2) (6=1)
tab swensenfav

gen resigninvest=GSU211
recode resigninvest (1=4) (2=3) (3=2) (4=1)
tab resigninvest

gen acceptedbribes=GSU212
recode acceptedbribes (1=5) (2=4) (4=2) (5=1)
tab acceptedbribes

gen innuendo=(swensenrand>1 & swensenrand<5)
gen innuendoXdenial=innuendo*(swensenrand==3)
gen innuendoXcausal=innuendo*(swensenrand==4)

/*make weights per gerber and green p 117*/
gen swensenrand2=(swensenrand==2)
bysort crooked: egen numinnuendo=sum(swensenrand2)
capture drop n
gen n=1
bysort crooked: egen blocktotal=sum(n)
gen probinnuendo=numinnuendo/blocktotal

bysort crooked: egen numdenial=sum(innuendoXdenial)
capture drop n
gen n=1
gen probdenial=numdenial/blocktotal

bysort crooked: egen numcausal=sum(innuendoXcausal)
capture drop n
gen n=1
gen probcausal=numcausal/blocktotal

gen aw=.
replace aw=1/probinnuendo if swensenrand==2
replace aw=1/probdenial if innuendoXdenial==1
replace aw=1/probcausal if innuendoXcausal==1
replace aw=1/(1-probinnuendo-probdenial-probcausal) if swensenrand==1

rename innuendo oldinnuendo
gen innuendo=(swensenrand==2)
gen denial=(swensenrand==3)
gen causal=(swensenrand==4)

save "JEPS replication/causal-replication.dta", replace
