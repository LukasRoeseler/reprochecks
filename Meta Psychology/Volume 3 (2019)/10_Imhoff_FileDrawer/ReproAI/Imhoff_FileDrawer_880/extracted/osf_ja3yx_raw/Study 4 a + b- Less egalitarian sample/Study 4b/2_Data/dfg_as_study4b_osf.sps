* Encoding: UTF-8.

*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 4b.
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Compute questionnaire scores.
* 2) Analyses.
*************************************************************************************************.


*** Instruction for OSF: In order to run the analyses reported in our publication
*** open dfg_as_study4b_OSF.sav and run the code in the analyses section below.

get file "D:\Uni\Forschung\dfg\studie4\studie4b\dfg_as_study4b.sav".


count missings = as1 to as18 (SYSMIS).
exe.
FREQUENCIES missings.
select if missings LT 10.
exe.


DESCRIPTIVES age.
FREQUENCIES sex age.

***** De-Identification for the version puplished on OSF.
* delete openended answers on national identity content, other religion, other political party and comment about the study.
DELETE VARIABLES ni_content religion_other party_other Anmerkungen.
*Several ages occurred only once. --> form groups.
RECODE age (lowest thru 20 = 1) (21 thru 26 = 2) (27 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES age.

*************************************************************************************************.
* 1) Compute questionnaire scores.
*************************************************************************************************.


recode as1 as2 as3 as7 as8 as13 as14 as15 as18 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) 
   into as1r as2r as3r as7r as8r as13r as14r as15r as18r.
exe.



*criticism of Israel.
RELIABILITY
  /VARIABLES=as4 as5 as6 as9 as10 as11 as12 as16 as17 as1r as2r as3r as7r 
    as8r as13r as14r as15r as18r
  /SCALE('antiisrael') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


compute antiisr = mean(as4, as5, as6, as9, as10, as11, as12, as16, as17, as1r, as2r, as3r, as7r, as8r, as13r, as14r, as15r, as18r).
exe.

VARIABLE LABELS antiisr "criticism of israel".


* national identification (ni).
RELIABILITY
  /VARIABLES=ni1 ni3 ni5
  /SCALE('ni-attachment') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute ni_a = mean(ni1, ni3, ni5).
exe.

RELIABILITY
  /VARIABLES=ni2 ni4 ni6
  /SCALE('ni-glorification') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute ni_g = mean(ni2, ni4, ni6).
exe.

VARIABLE LABELS ni_a "national attachment" ni_g "national glorification".

*************************************************************************************************.
* 2) Analyses.
*************************************************************************************************.

* criticism of israel scores - independent samples t-test.
*MAIN ANALYSIS.
T-TEST GROUPS=condition(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=antiisr
  /CRITERIA=CI(.95).



*Moderator analysis.

*standardize variables.
DESCRIPTIVES VARIABLES=ni_a ni_g antiisr
  /SAVE
  /STATISTICS=MEAN STDDEV MIN MAX.

* effect code condition (Holocaust = 1; control = -1).
recode condition (0=-1) (1=1) into Zcondition.
exe.

* compute product terms representing all possible two-way and three-way interactions.
compute conia = Zcondition*Zni_a.
compute conig = Zcondition*Zni_g.
compute niag = Zni_a*Zni_g.
compute coniag3 = Zcondition*Zni_a*Zni_g.
exe.

* hierarchical multiple regression analysis.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Zantiisr
  /METHOD=ENTER Zcondition Zni_a Zni_g
  /METHOD=ENTER conia conig niag
  /METHOD=ENTER coniag3.



*** sample characteristics.

FREQUENCIES party.
DESCRIPTIVES ni_a ni_g.


** check main result when excluding participants who missed attention check.
FREQUENCIES instruct.

filter by instruct.
T-TEST GROUPS=condition(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=antiisr
  /CRITERIA=CI(.95).
filter off.

save outfile "D:\Uni\Forschung\dfg\studie4\studie4b\dfg_as_study4b_OSF.sav".
