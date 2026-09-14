* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 3a - Phase 2 (Image Rating).
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Data preparation
* 2) Analyses of Phase 2.


*************************************************************************************************.


*** Instruction for OSF:
*** In order to run the analyses reported in our publication
*** open dfg_as_study3a_phase2_OSF.sav and run the code in the analyses section below.


*************************************************************************************************.
* 1) Data Preparation (Documentation).
*************************************************************************************************.


get file "D:\Uni\Forschung\dfg\studie3\studie3a\phase2\data\dfg_as_study3a_phase2.sav".

*exclude participants who did not finish.
select if LASTPAGE GE 11.
exe.

*exclude participants who indicated that they answered randomly or purposely false and participants who indicated that they would exclude their data if they were the researcher.
select if CO01 = 2.
select if CO02 = 1.
EXECUTE.

*age variable -> numeric format.
alter type DE01_01(F3.0).
DESCRIPTIVES
    /VARIABLES= DE01_01.

*sex.
FREQUENCIES
	/VARIABLES= DE02 DE01_01
	/FORMAT=AVALUE.


***** De-Identification for the version puplished on OSF.
*delete date and time of participation, a personal code participants generated in order to receive payment.
DELETE VARIABLES STARTED LASTDATA IV01_01.

*Several ages occurred only once. --> form groups.
RECODE DE01_01 (lowest thru 29 = 1) (30 thru 48 = 2) (49 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES DE01_01.


*** reliability of warmth and competence ratings for all 4 classification images.
* use classification images based on effective sample from phase 1 (= filtered).
RELIABILITY
  /VARIABLES=R005_01 R005_02 R005_03 R005_04
  /SCALE('jewish/control: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R005_06 R005_07 R005_08 R005_09
  /SCALE('jewish/control: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R006_01 R006_02 R006_03 R006_04
  /SCALE('jewish/holocaust: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R006_06 R006_07 R006_08 R006_09
  /SCALE('jewish/holocaust: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=R007_01 R007_02 R007_03 R007_04
  /SCALE('christian/control: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R007_06 R007_07 R007_08 R007_09
  /SCALE('christian/control: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R008_01 R008_02 R008_03 R008_04
  /SCALE('christian/holocaust: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R008_06 R008_07 R008_08 R008_09
  /SCALE('christian/holocaust: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.


* compute warmth and competence scores for each group-wise classification image.
compute jctr_warmth = mean(R005_01, R005_02, R005_03, R005_04).
compute jctr_comp = mean(R005_06, R005_07, R005_08, R005_09).
compute jhol_warmth = mean(R006_01, R006_02, R006_03, R006_04).
compute jhol_comp = mean(R006_06, R006_07, R006_08, R006_09).
compute cctr_warmth = mean(R007_01, R007_02, R007_03, R007_04).
compute cctr_comp = mean(R007_06, R007_07, R007_08, R007_09).
compute chol_warmth = mean(R008_01, R008_02, R008_03, R008_04).
compute chol_comp = mean(R008_06, R008_07, R008_08, R008_09).
exe.

VARIABLE LABELS
jctr_warmth "classification image jewish/control: warmth"
jctr_comp "classification image jewish/control: competence"
jhol_warmth "classification image jewish/holocaust: warmth"
jhol_comp "classification image jewish/holocaust: competence"
cctr_warmth "classification image christian/control: warmth"
cctr_comp "classification image christian/control: competence"
chol_warmth "classification image christian/holocaust: warmth"
chol_comp "classification image christian/holocaust: competence".

*************************************************************************************************.
* 2) Analyses.
*************************************************************************************************.

DESCRIPTIVES VARIABLES=jctr_warmth jctr_comp jhol_warmth jhol_comp cctr_warmth cctr_comp chol_warmth chol_comp
  /STATISTICS=MEAN STDDEV MIN MAX.

* 2 (group membership of the target person: Jewish vs. Christian) × 2 (Holocaust is mentioned vs. control information) repeated measures ANOVA.
* warmth ratings.
GLM cctr_warmth chol_warmth jctr_warmth jhol_warmth
  /WSFACTOR=jewish 2 Polynomial holocaust 2 Polynomial 
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(holocaust*jewish) PROFILE(jewish*holocaust)
  /PRINT=DESCRIPTIVE ETASQ TEST(MMATRIX)
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=jewish holocaust jewish*holocaust.



* competence ratings (exploration; not included in our publication).
GLM cctr_comp chol_comp jctr_comp jhol_comp
  /WSFACTOR=jewish 2 Polynomial holocaust 2 Polynomial 
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(holocaust*jewish) PROFILE(jewish*holocaust)
  /PRINT=DESCRIPTIVE ETASQ TEST(MMATRIX)
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=jewish holocaust jewish*holocaust.


***.
* NOTE: for exploratory analyses of the explicit ratings of the target person see the syntax file of phase 1.

save OUTFILE = "D:\Uni\Forschung\dfg\studie3\studie3a\phase2\data\dfg_as_study3a_phase2_OSF.sav".



