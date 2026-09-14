* Encoding: UTF-8.
* Encoding: .
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 1.
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Match pretest and posttest data.
* 2) Compute questionnaire scores.
* 2.1) Pretest.
* 2.2) Posttest.
* 3) Analyses.
* 3.1) ANOVA for the basic effect: 2 (ongoing consequences vs. no ongoing consequences) × 2 (bogus pipeline vs. control).
* 3.2) t-test: implicit guilt (ongoing consequences vs. no ongoing consequences).
* 3.3) correlation between implicit guilt and anti-Semitism under bogus-pipeline conditions.
* 3.4) moderator analyses: separate hierarchical multiple regression analyses.
*************************************************************************************************.


*** Instruction for OSF: In order to run the analyses reported in our publication
*** open dfg_as_study1_OSF.sav and run the code in the analyses section below.


*************************************************************************************************.
* 1) Match pretest and posttest data. (Documentation)
*************************************************************************************************.

*** open pretest data (online survey).
get file "D:\Uni\Forschung\dfg\studie1\daten\dfg_as_study1_online_raw.sav".

*exclude ps who did not finish.
select if FINISHED = 1.
exe.

*create new variable for participant code (needed to match with posttest data).
string code(A8).
compute code = upcase(KO02_01).
exe.

sort cases by code.

*exclude CASE 481 (p had already participated before: same code and age).
select if CASE NE 481.
exe.

*sex and age for pretest sample.
FREQUENCIES SD02.
ALTER TYPE SD03_01(F3.0).
DESCRIPTIVES SD03_01.

*match with posttest data (from the lab).
*posttest data was collected with Millisecond Inquisit and is already formatted to use with SPSS (see dfg_as_study1_lab_prep_osf.sps).
match files file=*
   /file = "D:\Uni\Forschung\dfg\studie1\daten\labor\dfg_as_study1_lab.sav"
   /by code.
exe.

* exclude ps who dropped out between the first and the second testing session.
* (subject is missing for ps who did not participate in the posttest).
select if subject GT 0.
exe.

save outfile = "D:\Uni\Forschung\dfg\studie1\daten\dfg_as_study1.sav".


FREQUENCIES sex.
DESCRIPTIVES age.

***** De-Identification for the version puplished on OSF.
*delete date and time of participation.
DELETE VARIABLES STARTED LASTDATA date.

*delete participant code.
DELETE VARIABLES KO02_01 code.

*delete openended variable on country of origin.
DELETE VARIABLES SD10_01.

*Several ages occurred only once. --> form groups.
RECODE SD03_01 (lowest thru 24 = 1) (25 thru 27 = 2) (28 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
* (variable age is a duplicate from the posttest.).
DELETE VARIABLES SD03_01 age.

save outfile = "D:\Uni\Forschung\dfg\studie1\daten\dfg_as_study1_OSF.sav".


*************************************************************************************************.
* 2) Compute questionnaire scores.
* 2.1) Pretest.
*************************************************************************************************.

*antisemitism.

*primary modern antisemitism.
recode AS05_24 AS05_36 AS05_42 AS05_49 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into AS05_24r AS05_36r AS05_42r AS05_49r.
RELIABILITY
  /VARIABLES=AS05_24r AS05_36r AS05_42r AS05_38 AS05_12 AS05_18 AS05_20 AS05_26 AS05_05 AS05_49r AS05_10 AS05_28 AS05_07 AS05_22
  /SCALE('Pretest PMA') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute pre_pma = mean(AS05_24r,AS05_36r,AS05_42r,AS05_38,AS05_12,AS05_18,AS05_20,AS05_26,AS05_05,AS05_49r,AS05_10,AS05_28,AS05_07,AS05_22).

*secondary modern antisemitism.
RELIABILITY
  /VARIABLES=AS05_17 AS05_30 AS05_48 AS05_04 AS05_11 AS05_15 AS05_19 AS05_27 AS05_31 AS05_41 AS05_33 AS05_37 AS05_44 AS05_45 AS05_47
  /SCALE('Pretest SMA') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute pre_sma = mean(AS05_17,AS05_30,AS05_48,AS05_04,AS05_11,AS05_15,AS05_19,AS05_27,AS05_31,AS05_41,AS05_33,AS05_37,AS05_44,AS05_45,AS05_47).

*modern antisemitism (primary + secondary). this is the scale used in the analyses below.
RELIABILITY
  /VARIABLES=AS05_24r AS05_36r AS05_42r AS05_38 AS05_12 AS05_18 AS05_20 AS05_26 AS05_05 AS05_49r AS05_10 AS05_28 AS05_07 AS05_22 AS05_17 AS05_30 AS05_48 AS05_04 AS05_11 AS05_15 AS05_19 AS05_27 AS05_31 AS05_41 AS05_33 AS05_37 AS05_44 AS05_45 AS05_47
  /SCALE('Pretest MA total') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute pre_ma = mean(AS05_24r,AS05_36r,AS05_42r,AS05_38,AS05_12,AS05_18,AS05_20,AS05_26,AS05_05,AS05_49r,AS05_10,AS05_28,AS05_07,AS05_22,AS05_17,
                                       AS05_30,AS05_48,AS05_04,AS05_11,AS05_15,AS05_19,AS05_27,AS05_31,AS05_41,AS05_33,AS05_37,AS05_44,AS05_45,AS05_47).

*contact to jews. 
recode AS05_14 AS05_29 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into AS05_14r AS05_29r.
RELIABILITY
  /VARIABLES=AS05_06 AS05_14r AS05_23 AS05_29r AS05_34
  /SCALE('Pretest AS Contact') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute pre_as_contact = mean(AS05_06,AS05_14r,AS05_23,AS05_29r,AS05_34).

*collective guilt/reparation items.
recode AS05_13 AS05_16 AS05_35 AS05_46 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into AS05_13r AS05_16r AS05_35r AS05_46r.
RELIABILITY
  /VARIABLES=AS05_02 AS05_03 AS05_08 AS05_09 AS05_13r AS05_16r AS05_21 AS05_25 AS05_32 AS05_35r AS05_39 AS05_40 AS05_43 AS05_46r
  /SCALE('Pretest AS Guilt/Reparation') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute pre_as_guilt = mean(AS05_02,AS05_03,AS05_08,AS05_09,AS05_13r,AS05_16r,AS05_21,AS05_25,AS05_32,AS05_35r,AS05_39,AS05_40,AS05_43,AS05_46r).

exe.

var lab pre_pma "pretest primary modern antisemitism" pre_sma "pretest secondary modern antisemitism" pre_ma "pretest modern antisemitism total".


* warmth and competence ratings of jews.

RELIABILITY
  /VARIABLES=WJ01_04 WJ01_06 WJ01_08 WJ01_12 WJ01_20
  /SCALE('Pretest warmth Jews') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute warmth = mean(WJ01_04, WJ01_06, WJ01_08, WJ01_12, WJ01_20).

RELIABILITY
  /VARIABLES=WJ01_01 WJ01_03 WJ01_11 WJ01_18
  /SCALE('Pretest competence Jews') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute competence = mean(WJ01_01, WJ01_03, WJ01_11, WJ01_18).

exe.

var lab warmth "Warmth Jews" competence "Competence Jews".


* Conspiracy Mentality.

recode CM01_05 CM01_08 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into CM01_05r CM01_08r.
exe.

RELIABILITY
  /VARIABLES=CM01_01 CM01_02 CM01_03 CM01_04 CM01_05r CM01_06 CM01_07 CM01_08r CM01_09 CM01_10 CM01_11 CM01_12
  /SCALE('Pretest Conspiracy Mentality') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute cm = mean(CM01_01, CM01_02, CM01_03, CM01_04, CM01_05r, CM01_06, CM01_07, CM01_08r, CM01_09, CM01_10, CM01_11, CM01_12).
exe.

var lab cm "Conspiracy Mentality".


* Collective Narcissism.

recode CN04_07 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into CN04_07r.
exe.

RELIABILITY
  /VARIABLES=CN04_01 CN04_02 CN04_03 CN04_04 CN04_05 CN04_06 CN04_07r CN04_08 CN04_09
  /SCALE('Pretest Collective Narcissism') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute cn = mean(CN04_01, CN04_02, CN04_03, CN04_04, CN04_05, CN04_06, CN04_07r, CN04_08, CN04_09).
exe.

var lab cn "Collective Narcissism".


* RWA.

recode RW01_01 RW01_03 RW01_05 RW01_07 RW01_09 RW01_11 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into RW01_01r RW01_03r RW01_05r RW01_07r RW01_09r RW01_11r.
exe.

RELIABILITY
  /VARIABLES=RW01_01r RW01_02 RW01_03r RW01_04 RW01_05r RW01_06 RW01_07r RW01_08 RW01_09r RW01_10 RW01_11r RW01_12
  /SCALE('Pretest RWA') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute rwa = mean(RW01_01r, RW01_02, RW01_03r, RW01_04, RW01_05r, RW01_06, RW01_07r, RW01_08, RW01_09r, RW01_10, RW01_11r, RW01_12).
exe.

var lab rwa "RWA".


* Just World Beliefs.

RELIABILITY
  /VARIABLES=JW01_01 JW01_02 JW01_03 JW01_04 JW01_05 JW01_06
  /SCALE('Pretest Just World Beliefs - general') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute jw_general = mean(JW01_01, JW01_02, JW01_03, JW01_04, JW01_05, JW01_06).

RELIABILITY
  /VARIABLES=JW02_07 JW02_08 JW02_09 JW02_10 JW02_11 JW02_12 JW02_13
  /SCALE('Pretest Just World Beliefs - personal') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute jw_personal = mean(JW02_07, JW02_08, JW02_09, JW02_10, JW02_11, JW02_12, JW02_13).

exe.

var lab jw_general "Just World Beliefs - general"  jw_personal "Just World Beliefs - personal".


* National Identification.

RELIABILITY
  /VARIABLES=NI01_01 NI01_03 NI01_05 NI01_07 NI01_09 NI01_11 NI01_13 NI01_15
  /SCALE('national attachment') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute ni_a = mean(NI01_01, NI01_03, NI01_05, NI01_07, NI01_09, NI01_11, NI01_13, NI01_15).

RELIABILITY
  /VARIABLES=NI01_02 NI01_04 NI01_06 NI01_08 NI01_10 NI01_12 NI01_14 NI01_16
  /SCALE('national glorification') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute ni_g = mean(NI01_02, NI01_04, NI01_06, NI01_08, NI01_10, NI01_12, NI01_14, NI01_16).

exe.

var lab ni_a "National Attachment".
var lab ni_g "National Glorification".

*SDO.

recode DO01_01 DO01_10 DO01_11 DO01_12 DO01_13 DO01_14 DO01_15 DO01_16 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into DO01_01r DO01_10r DO01_11r DO01_12r DO01_13r DO01_14r DO01_15r DO01_16r.
exe.

RELIABILITY
  /VARIABLES=DO01_01r DO01_02 DO01_03 DO01_04 DO01_05 DO01_06 DO01_07 DO01_08 DO01_09 DO01_10r DO01_11r DO01_12r DO01_13r DO01_14r DO01_15r DO01_16r
  /SCALE('Pretest SDO') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute sdo = mean(DO01_01r, DO01_02, DO01_03, DO01_04, DO01_05, DO01_06, DO01_07, DO01_08, DO01_09, DO01_10r, DO01_11r, DO01_12r, DO01_13r, DO01_14r, DO01_15r, DO01_16r).
exe.

var lab sdo "SDO".


* TOSCA- guilt and shame proneness.

RELIABILITY
  /VARIABLES=SE01_03 SE02_01 SE03_03 SE04_04 SE05_04 SE06_04 SE07_03 SE08_04 SE09_03 SE10_03 SE11_02
  /SCALE('Pretest TOSCA Guilt') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=SE01_01 SE02_02 SE03_01 SE04_03 SE05_01 SE06_02 SE07_04 SE08_02 SE09_02 SE10_01 SE11_03
  /SCALE('Pretest TOSCA Shame') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=SE01_02 SE02_04 SE03_04 SE04_02 SE05_03 SE06_03 SE07_01 SE08_01 SE09_04 SE10_04 SE11_01
  /SCALE('Pretest TOSCA Detached') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=SE01_04 SE02_03 SE03_02 SE04_01 SE05_02 SE06_01 SE07_02 SE08_03 SE09_01 SE10_02 SE11_04
  /SCALE('Pretest TOSCA Externalization') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute tosca_guilt = mean(SE01_03, SE02_01, SE03_03, SE04_04, SE05_04, SE06_04, SE07_03, SE08_04, SE09_03, SE10_03, SE11_02).
compute tosca_shame = mean(SE01_01, SE02_02, SE03_01, SE04_03, SE05_01, SE06_02, SE07_04, SE08_02, SE09_02, SE10_01, SE11_03).
compute tosca_detached = mean(SE01_02, SE02_04, SE03_04, SE04_02, SE05_03, SE06_03, SE07_01, SE08_01, SE09_04, SE10_04, SE11_01).
compute tosca_externalization = mean(SE01_04, SE02_03, SE03_02, SE04_01, SE05_02, SE06_01, SE07_02, SE08_03, SE09_01, SE10_02, SE11_04).
exe.

var lab
tosca_guilt "TOSCA Guilt proneness"
tosca_shame "TOSCA shame proneness"
tosca_detached "TOSCA detached"
tosca_externalization "TOSCA externalization".

* Angstbewältigungs-Inventar (Mainz Coping Inventory)
* Vigilance and Avoidance in 8 scenarios.

RELIABILITY
  /VARIABLES=RS01_01 RS01_04 RS01_05 RS01_07 RS01_09
  /SCALE('Pretest ABI 1 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS01_02 RS01_03 RS01_06 RS01_08 RS01_10
  /SCALE('Pretest ABI 1 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=RS02_01 RS02_04 RS02_05 RS02_06 RS02_10
  /SCALE('Pretest ABI 2 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS02_02 RS02_03 RS02_07 RS02_08 RS02_09
  /SCALE('Pretest ABI 2 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=RS03_01 RS03_03 RS03_06 RS03_08 RS03_10
  /SCALE('Pretest ABI 3 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS03_02 RS03_04 RS03_05 RS03_07 RS03_09
  /SCALE('Pretest ABI 3 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=RS04_02 RS04_03 RS04_06 RS04_07 RS04_09
  /SCALE('Pretest ABI 4 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS04_01 RS04_04 RS04_05 RS04_08 RS04_10
  /SCALE('Pretest ABI 4 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=RS05_01 RS05_02 RS05_06 RS05_07 RS05_08
  /SCALE('Pretest ABI 5 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS05_03 RS05_04 RS05_05 RS05_09 RS05_10
  /SCALE('Pretest ABI 5 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=RS06_01 RS06_04 RS06_08 RS06_09 RS06_10
  /SCALE('Pretest ABI 6 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS06_02 RS06_03 RS06_05 RS06_06 RS06_07
  /SCALE('Pretest ABI 6 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.



RELIABILITY
  /VARIABLES=RS07_02 RS07_03 RS07_04 RS07_08 RS07_10
  /SCALE('Pretest ABI 7 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS07_01 RS07_05 RS07_06 RS07_07 RS07_09
  /SCALE('Pretest ABI 7 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=RS08_01 RS08_03 RS08_05 RS08_07 RS08_09
  /SCALE('Pretest ABI 8 Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS08_02 RS08_04 RS08_06 RS08_08 RS08_10
  /SCALE('Pretest ABI 8 Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


* Vigilance and Avoidance in all of the 8 scenarios.

RELIABILITY
  /VARIABLES=RS01_01 RS01_04 RS01_05 RS01_07 RS01_09
RS02_01 RS02_04 RS02_05 RS02_06 RS02_10
RS03_01 RS03_03 RS03_06 RS03_08 RS03_10
RS04_02 RS04_03 RS04_06 RS04_07 RS04_09
RS05_01 RS05_02 RS05_06 RS05_07 RS05_08
RS06_01 RS06_04 RS06_08 RS06_09 RS06_10
RS07_02 RS07_03 RS07_04 RS07_08 RS07_10
RS08_01 RS08_03 RS08_05 RS08_07 RS08_09
  /SCALE('Pretest ABI gesamt Vigilanz') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=RS01_02 RS01_03 RS01_06 RS01_08 RS01_10
RS02_02 RS02_03 RS02_07 RS02_08 RS02_09
RS03_02 RS03_04 RS03_05 RS03_07 RS03_09
RS04_01 RS04_04 RS04_05 RS04_08 RS04_10
RS05_03 RS05_04 RS05_05 RS05_09 RS05_10
RS06_02 RS06_03 RS06_05 RS06_06 RS06_07
RS07_01 RS07_05 RS07_06 RS07_07 RS07_09
RS08_02 RS08_04 RS08_06 RS08_08 RS08_10
  /SCALE('Pretest ABI gesamt Vermeidung') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

*vigilance.
compute abi_vig = mean(RS01_01, RS01_04, RS01_05, RS01_07, RS01_09,
RS02_01, RS02_04, RS02_05, RS02_06, RS02_10,
RS03_01, RS03_03, RS03_06, RS03_08, RS03_10,
RS04_02, RS04_03, RS04_06, RS04_07, RS04_09,
RS05_01, RS05_02, RS05_06, RS05_07, RS05_08,
RS06_01, RS06_04, RS06_08, RS06_09, RS06_10,
RS07_02, RS07_03, RS07_04, RS07_08, RS07_10,
RS08_01, RS08_03, RS08_05, RS08_07, RS08_09).

*avoidance.
compute abi_verm = mean(RS01_02, RS01_03, RS01_06, RS01_08, RS01_10,
RS02_02, RS02_03, RS02_07, RS02_08, RS02_09,
RS03_02, RS03_04, RS03_05, RS03_07, RS03_09,
RS04_01, RS04_04, RS04_05, RS04_08, RS04_10,
RS05_03, RS05_04, RS05_05, RS05_09, RS05_10,
RS06_02, RS06_03, RS06_05, RS06_06, RS06_07,
RS07_01, RS07_05, RS07_06, RS07_07, RS07_09,
RS08_02, RS08_04, RS08_06, RS08_08, RS08_10).
exe.

var lab abi_vig "ABI Vigilance" abi_verm "ABI Avoidance".


* TIPI.

recode TI01_06 TI01_02 TI01_08 TI01_04 TI01_10 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into TI01_06r TI01_02r TI01_08r TI01_04r TI01_10r.
exe.

RELIABILITY
  /VARIABLES=TI01_01 TI01_06r
  /SCALE('Pretest TIPI Extraversion') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=TI01_02r TI01_07
  /SCALE('Pretest TIPI Agreeableness') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=TI01_03 TI01_08r
  /SCALE('Pretest TIPI Conscientiousness') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=TI01_04r TI01_09
  /SCALE('Pretest TIPI Emotional Stability') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=TI01_05 TI01_10r
  /SCALE('Pretest TIPI Openness to Experience') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


compute tipi_ex = mean (TI01_01, TI01_06r).
compute tipi_ag = mean(TI01_02r, TI01_07).
compute tipi_co = mean(TI01_03, TI01_08r).
compute tipi_em = mean(TI01_04r, TI01_09).
compute tipi_op = mean(TI01_05, TI01_10r).
exe.

var lab tipi_ex "TIPI Extraversion" tipi_ag "TIPI Agreeableness" tipi_co "TIPI Conscientiousness" tipi_em "TIPI Emotional Stability" tipi_op "TIPI Openness to Experience".


* GASP guilt and shame proneness.

RELIABILITY
  /VARIABLES=GS01_01 GS01_09 GS01_14 GS01_16
  /SCALE('Pretest GASP Guilt-Negative-Behaviour-Evaluation') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=GS01_02 GS01_05 GS01_11 GS01_15
  /SCALE('Pretest GASP Guilt-Repair') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=GS01_03 GS01_06 GS01_10 GS01_13
  /SCALE('Pretest GASP Shame-Negative-Self-Evaluation') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=GS01_04 GS01_07 GS01_08 GS01_12
  /SCALE('Pretest GASP Shame-Withdraw') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


compute gasp_guilt_nbe = mean(GS01_01, GS01_09, GS01_14, GS01_16).
compute gasp_guilt_r = mean(GS01_02, GS01_05, GS01_11, GS01_15).
compute gasp_shame_nse = mean(GS01_03, GS01_06, GS01_10, GS01_13).
compute gasp_shame_w = mean(GS01_04, GS01_07, GS01_08, GS01_12).
exe.

var lab gasp_guilt_nbe "GASP Guilt-Negative-Behaviour-Evaluation"
gasp_guilt_r "GASP Guilt-Repair"
gasp_shame_nse "GASP Shame-Negative-Self-Evaluation"
gasp_shame_w "GASP Shame-Withdraw".




*************************************************************************************************.
*************************************************************************************************.
* 2.2) Posttest.
*************************************************************************************************.
*************************************************************************************************.

*antisemitism.

*modern antisemitism.
recode as_24 as_25 as_30 as_27 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into as_24r as_25r as_30r as_27r.
exe.

RELIABILITY
  /VARIABLES=as_24r as_25r as_30r as_7 as_6 as_9 as_39 as_41 as_16 as_27r as_4 as_35 as_17 as_42 as_13 as_34 as_44 as_12 as_28 as_48 as_2 as_37 as_45 as_47 as_10 as_20 as_21 as_22 as_31
  /SCALE('posttest modern antisemitism') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute post_pma = mean(as_24r,as_25r,as_30r,as_7,as_6,as_9,as_39,as_41,as_16,as_27r,as_4,as_35,as_17,as_42).
compute post_sma = mean(as_13,as_34,as_44,as_12,as_28,as_48,as_2,as_37,as_45,as_47,as_10,as_20,as_21,as_22,as_31).
compute post_ma = mean(as_24r,as_25r,as_30r,as_7,as_6,as_9,as_39,as_41,as_16,as_27r,as_4,as_35,as_17,as_42,as_13,as_34,as_44,as_12,as_28,as_48,as_2,as_37,as_45,as_47,as_10,as_20,as_21,as_22,as_31).
exe.

*contact to jews.
recode as_19 as_11  (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into as_19r as_11r.
compute post_as_contact = mean(as_11r,as_14,as_19r,as_29,as_49).
exe.

*collective guilt/reparation items.
recode as_40 as_32 as_36 as_38 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into as_40r as_32r as_36r as_38r.
compute post_as_guilt = mean(as_3,as_5,as_8,as_15,as_18,as_23,as_26,as_32r,as_33,as_36r,as_38r,as_40r,as_43,as_46).
exe.


var lab post_pma "posttest primary modern antisemitism" post_sma "posttest secondary modern antisemitism" post_ma "posttest modern antisemitism total".



* IPANAT - implicit affect.
* 12 emotion words over 6 artificial words.
compute ipanat_freude = mean (ipanat1_1, ipanat2_1, ipanat3_1, ipanat4_1, ipanat5_1, ipanat6_1).
compute ipanat_aerger = mean (ipanat1_2, ipanat2_2, ipanat3_2, ipanat4_2, ipanat5_2, ipanat6_2).
compute ipanat_angst = mean (ipanat1_3, ipanat2_3, ipanat3_3, ipanat4_3, ipanat5_3, ipanat6_3).
compute ipanat_scham = mean (ipanat1_4, ipanat2_4, ipanat3_4, ipanat4_4, ipanat5_4, ipanat6_4).
compute ipanat_gutelaune = mean (ipanat1_5, ipanat2_5, ipanat3_5, ipanat4_5, ipanat5_5, ipanat6_5).
compute ipanat_gereiztheit = mean (ipanat1_6, ipanat2_6, ipanat3_6, ipanat4_6, ipanat5_6, ipanat6_6).
compute ipanat_furcht = mean (ipanat1_7, ipanat2_7, ipanat3_7, ipanat4_7, ipanat5_7, ipanat6_7).
compute ipanat_bedauern = mean (ipanat1_8, ipanat2_8, ipanat3_8, ipanat4_8, ipanat5_8, ipanat6_8).
compute ipanat_begeisterung = mean (ipanat1_9, ipanat2_9, ipanat3_9, ipanat4_9, ipanat5_9, ipanat6_9).
compute ipanat_wut = mean (ipanat1_10, ipanat2_10, ipanat3_10, ipanat4_10, ipanat5_10, ipanat6_10).
compute ipanat_schrecken = mean (ipanat1_11, ipanat2_11, ipanat3_11, ipanat4_11, ipanat5_11, ipanat6_11).
compute ipanat_schuldgefuehl = mean (ipanat1_12, ipanat2_12, ipanat3_12, ipanat4_12, ipanat5_12, ipanat6_12).
exe.

*construct emotion clusters. (we use ipanat_guilt for the analyses below).
compute ipanat_happiness = mean(ipanat_freude, ipanat_gutelaune, ipanat_begeisterung).
compute ipanat_anger = mean(ipanat_aerger, ipanat_gereiztheit, ipanat_wut).
compute ipanat_fear = mean(ipanat_angst, ipanat_furcht, ipanat_schrecken).
compute ipanat_guilt = mean(ipanat_scham, ipanat_bedauern, ipanat_schuldgefuehl).
exe.

* reliability of ipanat_guilt.
RELIABILITY
  /VARIABLES=ipanat1_4 ipanat1_8 ipanat1_12 ipanat2_4 ipanat2_8 ipanat2_12 ipanat3_4 ipanat3_8 
    ipanat3_12 ipanat4_4 ipanat4_8 ipanat4_12 ipanat5_4 ipanat5_8 ipanat5_12 ipanat6_4 ipanat6_8 
    ipanat6_12
  /SCALE('ipanat guilt') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


*Explicit guilt.
RELIABILITY
  /VARIABLES=expl_affect_4 expl_affect_8 expl_affect_12
  /SCALE('expl guilt') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute expl_guilt = mean(expl_affect_4, expl_affect_8, expl_affect_12).
exe.


save outfile = "D:\Uni\Forschung\dfg\studie1\daten\dfg_as_study1_OSF.sav".

*************************************************************************************************.
*************************************************************************************************.
* 3) ANALYSES
*************************************************************************************************.
*************************************************************************************************.

get file "D:\Uni\Forschung\dfg\studie1\daten\dfg_as_study1_OSF.sav".

*show cell sizes.
CROSSTABS group by bp.

*stability of antisemitism.
CORRELATIONS
  /VARIABLES=pre_ma post_ma
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.


*************************************************************************************************.
* 3.1) ANOVA for the basic effect: 2 (ongoing consequences vs. no ongoing consequences) × 2 (bogus pipeline vs. control).
*************************************************************************************************.
* residual change scores were used as an index of change in anti-Semitism.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT post_ma
  /METHOD=ENTER pre_ma
  /SAVE ZRESID.

* 2x2 ANOVA with residual change scores as DV.
UNIANOVA ZRE_1 BY  bp group
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(group*bp)
  /PRINT=ETASQ DESCRIPTIVE
  /CRITERIA=ALPHA(.05)
  /DESIGN=bp group bp*group.


*************************************************************************************************.
* 3.2) t-test: implicit guilt (ongoing consequences vs. no ongoing consequences).
*************************************************************************************************.
T-TEST GROUPS=group(1 2)
  /MISSING=ANALYSIS
  /VARIABLES=ipanat_guilt 
  /CRITERIA=CI(.95).


*************************************************************************************************.
* 3.3) correlation between implicit guilt and anti-Semitism under bogus-pipeline conditions.
*************************************************************************************************.
compute filter_bp = (bp=1).
exe.
filter by filter_bp.

CORRELATIONS
  /VARIABLES=ipanat_guilt post_ma
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

GRAPH
  /SCATTERPLOT(BIVAR)=ipanat_guilt WITH post_ma
  /MISSING=LISTWISE.

filter off.


*************************************************************************************************.
* 3.4) moderator analyses: separate hierarchical multiple regression analyses.
*************************************************************************************************.

*save standardized mean scores for antisemitism and all potential moderators.
DESCRIPTIVES VARIABLES=pre_ma cn jw_general ni_a ni_g tosca_guilt gasp_guilt_nbe
  /SAVE
  /STATISTICS=MEAN STDDEV MIN MAX.

*effect code group variables.
if group=1 zgroup=.5.
if group=2 zgroup=-.5.
if bp=0 zbp = -.5.
if bp=1 zbp = .5.
exe.


* Below: For all potential moderators:
* Compute product terms representing all possible two-way and three-way interactions.
* And perform a hierarchical multiple regression with residual change scores in antisemitism as DV.


* Collective Narcissism.

compute grbp = zgroup*zbp.
compute grcn = zgroup*zcn.
compute bpcn = zbp*zcn.
compute grbpcn = zgroup*zbp*zcn.
exe.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ZRE_1
  /METHOD=ENTER zgroup zbp Zcn
  /METHOD=ENTER grbp grcn bpcn
  /METHOD=ENTER grbpcn.



* Just World Beliefs.

compute grjw = zgroup*zjw_general.
compute bpjw = zbp*zjw_general.
compute grbpjw = zgroup*zbp*zjw_general.
exe.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ZRE_1
  /METHOD=ENTER zgroup zbp zjw_general
  /METHOD=ENTER grbp grjw bpjw
  /METHOD=ENTER grbpjw.


* National Identification.

compute grnig = zgroup*zni_g.
compute bpnig = zbp*zni_g.
compute grbpnig = zgroup*zbp*zni_g.
exe.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ZRE_1
  /METHOD=ENTER zgroup zbp zni_g
  /METHOD=ENTER grbp grnig bpnig
  /METHOD=ENTER grbpnig.



* tosca_guilt.

compute grgu = zgroup*ztosca_guilt.
compute bpgu = zbp*ztosca_guilt.
compute grbpgu = zgroup*zbp*ztosca_guilt.
exe.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ZRE_1
  /METHOD=ENTER zgroup zbp ztosca_guilt
  /METHOD=ENTER grbp grgu bpgu
  /METHOD=ENTER grbpgu.

save outfile = "D:\Uni\Forschung\dfg\studie1\daten\dfg_as_study1_OSF.sav".
