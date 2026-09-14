* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 2.
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Match pretest and posttest data.
* 2) Compute questionnaire scores.
* 2.1) Pretest.
* 2.2) Posttest.
* 3) Analyses.
* 3.1) ANOVA: 2 (group membership of the perpetrators: in-group vs. out-group) × 2 (bogus pipeline vs. control).
* 3.2) moderator analyses: separate hierarchical multiple regression analyses.
*************************************************************************************************.


*** Instruction for OSF: In order to run the analyses reported in our publication
*** open dfg_as_study2_OSF.sav and run the code in the analyses section below.


*************************************************************************************************.
* 1) Match pretest and posttest data. (Documentation)
*************************************************************************************************.

* open pretest data (classroom testing).
get file "D:\Uni\Forschung\dfg\studie2\data\t1\dfg_as_study2_pretest_raw.sav".

* add labels for demographic variables.
VARIABLE LABELS GES "sex" ALT "age" BIL "education" POL "political orientation" MIG "migration background" TEXT "Migration other" REL1 "religion" Rel2 "religiosity".
VALUE LABELS GES 1 "male" 2 "female".
VALUE LABELS BIL 1 "kein Abschluss" 2 "Hauptschulabschluss" 3 "mittlere Reife" 4 "Fachabitur" 5 "Abitur" 6 "Studium" 7 "Promotion".
VALUE LABELS MIG 1 "Nein" 2 "In D geboren, Familie mit Migrationshintergrund" 3 "Nicht in D geboren, in D aufgewachsen" 4 "innerhalb letzte Jahre eingewandert".
VALUE LABELS REL1 1 "christlich katholisch" 2 "christlich evangelisch" 3 "christlich orthodox" 4 "muslimisch" 5 "jüdisch" 6 "ohne Konfession" 7 "sonstiges".
VALUE LABELS REL2 1 "gar nicht religiös" 2 "kaum religiös" 3 "ein wenig religiös" 4 "sehr religiös".

* prepare participant code for matching with posttest data.
string code_r(A8).
compute code_r = upcase(CODE).
sort cases by code_r.

*match with posttest data (from the lab).
*posttest data was collected with Millisecond Inquisit and is already formatted to use with SPSS.
MATCH FILES file = *
   /file = "D:\Uni\Forschung\dfg\studie2\data\t2\inquisit\dfg_as_study2_lab.sav"
   /by code_r.
exe.

*exclude experimenter trials.
select if code_r NE "".
select if code_r NE "SCC".
exe.

*sex and age for pretest sample.
FREQUENCIES GES.
DESCRIPTIVES ALT.

* exclude ps who dropped out between the first and the second testing session.
* (subject is missing for ps who did not participate in the posttest).
compute complete = 0.
if subject GT 0 complete = 1.
exe.
FREQUENCIES complete.
select if complete = 1.
exe.

* exclude ps who did not remember that the historical text they had read .
* contained information about ongoing negative consequences for the victims .
* or who did not remember who the perpetrators had been. (manipulation checks).
FREQUENCIES mc_a mc_b.
select if mc_a = 1 and mc_b = 1.
exe.


* sex and age for effective sample.
FREQUENCIES GES.
DESCRIPTIVES ALT.

save outfile = "D:\Uni\Forschung\dfg\studie2\data\dfg_as_study2.sav".


***** De-Identification for the version puplished on OSF.
*delete participant code.
DELETE VARIABLES CODE code_r.

*delete openended variable on country of origin.
DELETE VARIABLES TEXT.

* delete openended answers about suspicion and comments about the study.
DELETE VARIABLES suspicion1 suspicion2 comment.

*Several ages occurred only once. --> form groups.
RECODE ALT (lowest thru 19 = 1) (20 thru 21 = 2) (22 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
* (variable age is a duplicate from the posttest.).
DELETE VARIABLES ALT age.

save outfile = "D:\Uni\Forschung\dfg\studie2\data\dfg_as_study2_OSF.sav".



*************************************************************************************************.
* 2) Compute questionnaire scores.
* 2.1) Pretest.
*************************************************************************************************.

* Just World.

RELIABILITY
  /VARIABLES=JW1 JW2 JW3 JW4 JW5 JW6
  /SCALE('Just World general') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=JW7 JW8 JW9 JW10 JW11 JW12 JW13
  /SCALE('Just World personal') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.

compute jw_general = mean(JW1, JW2, JW3, JW4, JW5, JW6).
compute jw_personal = mean(JW7, JW8, JW9, JW10, JW11, JW12, JW13).
exe.



* Conspiracy Mentality.

recode CM5, CM8, CM9 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into CM5r, CM8r, CM9r.
exe.

RELIABILITY
  /VARIABLES=CM1, CM2, CM3, CM4, CM6, CM7, CM9, CM10, CM11, CM12, CM5r, CM8r
  /SCALE('Conspiracy Mentality') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.


compute cm = mean(CM1, CM2 ,CM3, CM4, CM6, CM7, CM9, CM10, CM11, CM12, CM5r, CM8r).
exe.


* RWA.

recode RWA1 RWA3 RWA5 RWA7 RWA9 RWA11 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into RWA1r RWA3r RWA5r RWA7r RWA9r RWA11r.
exe.


RELIABILITY
  /VARIABLES=RWA1r RWA3r RWA5r RWA7r RWA9r RWA11r RWA2 RWA4 RWA6 RWA8 RWA10 RWA12
  /SCALE('RWA') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.


compute rwa = mean(RWA1r, RWA3r, RWA5r, RWA7r, RWA9r, RWA11r, RWA2, RWA4, RWA6, RWA8, RWA10, RWA12).
exe.


* SDO.

recode SDO1 SDO10 SDO11 SDO12 SDO13 SDO14 SDO15 SDO16 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into SDO1r SDO10r SDO11r SDO12r SDO13r SDO14r SDO15r SDO16r.
exe.


RELIABILITY
  /VARIABLES=SDO1r SDO10r SDO11r SDO12r SDO13r SDO14r SDO15r SDO16r SDO2 SDO3 SDO4 SDO5 SDO6 SDO7 
    SDO8 SDO9
  /SCALE('SDO') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

compute sdo = mean(SDO1r, SDO10r, SDO11r, SDO12r, SDO13r, SDO14r, SDO15r, SDO16r, SDO2, SDO3, SDO4, SDO5, SDO6, SDO7, SDO8, SDO9).
exe.



* GASP guilt and shame proneness.

RELIABILITY
  /VARIABLES=GASP1 GASP9 GASP14 GASP16
  /SCALE('Pretest GASP Guilt-Negative-Behaviour-Evaluation') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=GASP2 GASP5 GASP11 GASP15
  /SCALE('Pretest GASP Guilt-Repair') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=GASP3 GASP6 GASP10 GASP13
  /SCALE('Pretest GASP Shame-Negative-Self-Evaluation') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=GASP4 GASP7 GASP8 GASP12
  /SCALE('Pretest GASP Shame-Withdraw') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


compute gasp_guilt_nbe = mean(GASP1, GASP9, GASP14, GASP16).
compute gasp_guilt_r = mean(GASP2, GASP5, GASP11, GASP15).
compute gasp_shame_nse = mean(GASP3, GASP6, GASP10, GASP13).
compute gasp_shame_w = mean(GASP4, GASP7, GASP8, GASP12).
exe.

var lab gasp_guilt_nbe "GASP Guilt-Negative-Behaviour-Evaluation"
gasp_guilt_r "GASP Guilt-Repair"
gasp_shame_nse "GASP Shame-Negative-Self-Evaluation"
gasp_shame_w "GASP Shame-Withdraw".


* Collective Narcissism.

recode NI7 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into NI7r.
exe.

RELIABILITY
  /VARIABLES=NI1 NI2 NI3 NI4 NI5 NI6 NI7r NI8 NI9
  /SCALE('Pretest Collective Narcissism') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute cn = mean(NI1, NI2, NI3, NI4, NI5, NI6, NI7r, NI8, NI9).
exe.

var lab cn "Collective Narcissism".


* Antisemitism.

recode AS1 AS6 AS10 AS11 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into AS1r AS6r AS10r AS11r.
exe.


*secondary modern antisemitism.
RELIABILITY
  /VARIABLES=AS12 AS14 AS15 AS16 AS18
  /SCALE('AS-SMA') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

compute sma=mean(AS12, AS14, AS15, AS16, AS18).
exe.

*modern antisemitism (10 items parallel to prejudice against chinese).
RELIABILITY
  /VARIABLES=AS2 AS3 AS4 AS5 AS7 AS8 AS1r AS6r AS9 AS10r
  /SCALE('prejudice against jews (10 AS Items)') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

compute prejudice_j = mean(AS2, AS3, AS4, AS5, AS7, AS8, AS1r, AS6r, AS9, AS10r).
exe.



*** prejudice against chinese.

recode AC1 AC6 AC10 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into AC1r AC6r AC10r.
exe.

RELIABILITY
  /VARIABLES=AC2 AC3 AC4 AC5 AC7 AC8 AC1r AC6r AC9 AC10r
  /SCALE('prejudice against chinese (10 AC Items)') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

compute prejudice_c = mean(AC2, AC3, AC4, AC5, AC7, AC8, AC1r, AC6r, AC9, AC10r).
exe.



*************************************************************************************************.
*************************************************************************************************.
* 2.2) Posttest. (lab data)
*************************************************************************************************.
*************************************************************************************************.

** prejudice. (item numbers)
*** Items 1-10 = prejudice against jews/chinese (same as in pretest).
*** Items 11-14 = guilt.
*** Items 15-21 = only in jewish victims condition: additional PMA & SMA items (items also in pretest).

recode prejudice_1 prejudice_6 prejudice_9 prejudice_10 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into  prejudice_1r prejudice_6r prejudice_9r prejudice_10r.
exe.

sort cases by prime.
split file by prime.
RELIABILITY
  /VARIABLES=prejudice_1r prejudice_6r prejudice_9r prejudice_10r prejudice_2 prejudice_3 
    prejudice_4 prejudice_5 prejudice_7 prejudice_8
  /SCALE('prejudice') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.
split file off.


compute prejudice_post = mean(prejudice_1r, prejudice_6r, prejudice_9r, prejudice_10r, prejudice_2, prejudice_3, prejudice_4, prejudice_5, prejudice_7, prejudice_8).
exe.

*recode pretest prejudice score depending on experimental condition (jewish or chinese victims).
*prejudice_pre = prejudice_j or prejudice_c.

do if prime=1.
   compute prejudice_pre = prejudice_j.
else if prime=2.
   compute prejudice_pre = prejudice_c.
end if.
exe.



*** exploratory items.
*** collective guilt.
recode prejudice_13 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into prejudice_13r.

sort cases by prime.
split file by prime.  
  RELIABILITY
  /VARIABLES=prejudice_11 prejudice_12 prejudice_13r prejudice_14
  /SCALE('collective guilt') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.
split file off.

*** SMA (items 16, 17, 18, 19, 21).
compute sma_post = mean(prejudice_16, prejudice_17, prejudice_18, prejudice_19, prejudice_21).
exe.



save outfile = "D:\Uni\Forschung\dfg\studie2\data\dfg_as_study2_OSF.sav".



*************************************************************************************************.
*************************************************************************************************.
* 3) ANALYSES
*************************************************************************************************.
*************************************************************************************************.

get file "D:\Uni\Forschung\dfg\studie2\data\dfg_as_study2_OSF.sav".

*show cell sizes.
CROSSTABS prime by bp.

*stability of antisemitism and prejudice against chinese..
sort cases by prime.
split file by prime.
CORRELATIONS
  /VARIABLES=prejudice_post prejudice_pre
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.
split file off.



*************************************************************************************************.
* 3.1) ANOVA: 2 (group membership of the perpetrators: in-group vs. out-group) × 2 (bogus pipeline vs. control).
*************************************************************************************************.
* residual change scores were used as an index of change in anti-Semitism or prejudice against chinese..
* save standardized residuals.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT prejudice_post
  /METHOD=ENTER prejudice_pre
  /SAVE ZRESID.

*descriptives of residual change scores.
sort cases by prime bp.
split file by prime bp.
DESCRIPTIVES VARIABLES=ZRE_1
  /STATISTICS=MEAN STDDEV SEMEAN.
split file off.

* 2x2 ANOVA with residual change scores as DV.
UNIANOVA ZRE_1 BY  bp prime
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(prime*bp)
  /PRINT=ETASQ DESCRIPTIVE
  /CRITERIA=ALPHA(.05)
  /DESIGN=bp prime bp*prime.


*************************************************************************************************.
* 3.2) moderator analyses: separate hierarchical multiple regression analyses.
*************************************************************************************************.

*save standardized mean scores for all potential moderators.
DESCRIPTIVES VARIABLES=cn jw_general gasp_guilt_nbe
  /SAVE
  /STATISTICS=MEAN STDDEV MIN MAX.

*effect code group variables.
if prime=1 zprime=.5.
if prime=2 zprime=-.5.
if bp=0 zbp = -.5.
if bp=1 zbp = .5.
exe.


* Below: For all potential moderators:
* Compute product terms representing all possible two-way and three-way interactions.
* And perform a hierarchical multiple regression with residual change scores in antisemitism as DV.


* Collective Narcissism.

compute prbp = zprime*zbp.
compute prcn = zprime*zcn.
compute bpcn = zbp*zcn.
compute prbpcn = zprime*zbp*zcn.
exe.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ZRE_1
  /METHOD=ENTER zprime zbp Zcn
  /METHOD=ENTER prbp prcn bpcn
  /METHOD=ENTER prbpcn.


* Just World Beliefs.

compute prjw = zprime*zjw_general.
compute bpjw = zbp*zjw_general.
compute prbpjw = zprime*zbp*zjw_general.
exe.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ZRE_1
  /METHOD=ENTER zprime zbp Zjw_general
  /METHOD=ENTER prbp prjw bpjw
  /METHOD=ENTER prbpjw.



* GASP guilt proneness.

compute prgp = zprime*zgasp_guilt_nbe.
compute bpgp = zbp*zgasp_guilt_nbe.
compute prbpgp = zprime*zbp*zgasp_guilt_nbe.
exe.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ZRE_1
  /METHOD=ENTER zprime zbp zgasp_guilt_nbe
  /METHOD=ENTER prbp prgp bpgp
  /METHOD=ENTER prbpgp.


save outfile = "D:\Uni\Forschung\dfg\studie2\data\dfg_as_study2_OSF.sav".
