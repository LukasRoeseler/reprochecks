* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 3c - Phase 2 (Image Rating).
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Data preparation
* 2) Analyses of Phase 2.
* 2.1) Group-wise classification images (primary analysis)
* 2.2) Individual classification images
* 2.2.1) Documentation of data processing.
* 2.2.2) Analysis (secondary analysis)

*************************************************************************************************.


*** Instruction for OSF:
*** In order to run the analyses reported in our publication
*** open dfg_as_study3c_phase2_OSF.sav and run the code in the analyses section (2.1 contains the primary analyses) below.
*** use dfg_as_study3c_phase2_ind_OSF.sav to run the analysis in 2.2.2 (secondary analysis).

*** note: in order to use the relative paths use the following two lines in a new syntax file.
*** INSERT file = "[insert path here]\dfg_as_study3c_phase2_osf.sps"
*** CD = YES.



*************************************************************************************************.
* 1) Data Preparation (Documentation).
*************************************************************************************************.

* open ratings of group-wise classification images.

get file "dfg_as_study3c_phase2.sav".

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
FREQUENCIES
	/VARIABLES= DE02 DE01_01
	/FORMAT=AVALUE.



***** De-Identification for the version puplished on OSF.
*delete date and time of participation, a personal code participants generated in order to receive payment.
DELETE VARIABLES STARTED LASTDATA IV01_01.

*Several ages occurred only once. --> form groups.
RECODE DE01_01 (lowest thru 29 = 1) (30 thru 38 = 2) (39 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES DE01_01.


*** reliability of warmth and competence ratings for all 4 classification images.
* use classification images based on effective sample from phase 1 (= filtered).

RELIABILITY
  /VARIABLES=R005_01 R005_02 R005_03 R005_04
  /SCALE('jewish/holocaust: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R005_06 R005_07 R005_08 R005_09
  /SCALE('jewish/holocaust: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R006_01 R006_02 R006_03 R006_04
  /SCALE(' christian/holocaust: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R006_06 R006_07 R006_08 R006_09
  /SCALE(' christian/holocaust: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.


RELIABILITY
  /VARIABLES=R007_01 R007_02 R007_03 R007_04
  /SCALE(' jewish/control: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R007_06 R007_07 R007_08 R007_09
  /SCALE(' jewish/control: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R008_01 R008_02 R008_03 R008_04
  /SCALE('christian/control: warmth') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=R008_06 R008_07 R008_08 R008_09
  /SCALE('christian/control: competence') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

* compute warmth and competence scores for each group-wise classification image.
compute jhol_warmth = mean(R005_01, R005_02, R005_03, R005_04).
compute jhol_comp = mean(R005_06, R005_07, R005_08, R005_09).
compute chol_warmth = mean(R006_01, R006_02, R006_03, R006_04).
compute chol_comp = mean(R006_06, R006_07, R006_08, R006_09).
compute jctr_warmth = mean(R007_01, R007_02, R007_03, R007_04).
compute jctr_comp = mean(R007_06, R007_07, R007_08, R007_09).
compute cctr_warmth = mean(R008_01, R008_02, R008_03, R008_04).
compute cctr_comp = mean(R008_06, R008_07, R008_08, R008_09).
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
* 2.1) Group-wise classification images.
*************************************************************************************************.

DESCRIPTIVES VARIABLES=jctr_warmth jctr_comp jhol_warmth jhol_comp cctr_warmth cctr_comp chol_warmth chol_comp
  /STATISTICS=MEAN STDDEV MIN MAX.


* 2 (group membership of the target person: Jewish vs. Christian) × 2 (Holocaust is mentioned vs. control information) repeated measures ANOVA.
* warmth ratings.
GLM cctr_warmth chol_warmth jctr_warmth jhol_warmth
  /WSFACTOR=jüdisch 2 Polynomial holocaust 2 Polynomial 
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(holocaust*jüdisch) PROFILE(jüdisch*holocaust)
  /PRINT=DESCRIPTIVE ETASQ TEST(MMATRIX)
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=jüdisch holocaust jüdisch*holocaust.




* competence ratings (exploration; not included in our publication).
GLM cctr_comp chol_comp jctr_comp jhol_comp
  /WSFACTOR=jüdisch 2 Polynomial holocaust 2 Polynomial 
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(holocaust*jüdisch) PROFILE(jüdisch*holocaust)
  /PRINT=DESCRIPTIVE ETASQ TEST(MMATRIX)
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=jüdisch holocaust jüdisch*holocaust.


***.
* NOTE: for exploratory analyses of the explicit ratings of the target person see the syntax file of phase 1.

save outfile = "dfg_as_study3c_phase2_OSF.sav".







*************************************************************************************************.
* 2.2) Individual classification images.
*************************************************************************************************.

* 2.2.1) Documentation of data processing. 
* In order to run the analysis reported in our publication, please see below 2.2.2.
* note: the following raw data file containing the ratings of individual classification images is not available on OSF because it is not de-identified. 
* but you can nevertheless continue with the code since the de-identified version will be opened a few lines below.

* open ratings of individual classification images.
get file "rawdata\dfg_as_study3c_phase2_ind.sav".

* exclude ps who did not finish.
select if LASTPAGE GE 4.
exe.

***** De-Identification for the version puplished on OSF.
*delete date and time of participation, a personal code participants generated in order to receive payment.
DELETE VARIABLES STARTED LASTDATA IV01_01.

*Several ages occurred only once. --> form groups.
alter type DE01_01(F3.0).
FREQUENCIES VARIABLES=DE01_01
  /ORDER=ANALYSIS.
RECODE DE01_01 (lowest thru 28 = 1) (29 thru 38 = 2) (39 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES DE01_01.

save OUTFILE = "dfg_as_study3c_phase2_ind_raw_OSF.sav".

*** open de-identified version.
get file "dfg_as_study3c_phase2_ind_raw_OSF.sav".

*** match pictures with subject ids.
RENAME VARIABLES
(R004_01 = ID1)
(R004_02 = ID5)
(R004_03 = ID9)
(R004_04 = ID13)
(R004_05 = ID17)
(R004_06 = ID21)
(R004_07 = ID25)
(R004_08 = ID29)
(R004_09 = ID33)
(R004_10 = ID37)
(R004_11 = ID41)
(R004_12 = ID45)
(R004_13 = ID49)
(R004_14 = ID53)
(R004_15 = ID57)
(R004_16 = ID2)
(R004_17 = ID6)
(R004_18 = ID10)
(R004_19 = ID14)
(R004_20 = ID18)
(R004_21 = ID22)
(R004_23 = ID30)
(R004_24 = ID34)
(R004_25 = ID38)
(R004_26 = ID42)
(R004_27 = ID50)
(R004_28 = ID54)
(R004_29 = ID58)
(R004_30 = ID62)
(R004_31 = ID3)
(R004_32 = ID7)
(R004_33 = ID11)
(R004_34 = ID15)
(R004_35 = ID19)
(R004_36 = ID23)
(R004_37 = ID27)
(R004_38 = ID31)
(R004_39 = ID35)
(R004_40 = ID39)
(R004_41 = ID43)
(R004_42 = ID47)
(R004_43 = ID51)
(R004_44 = ID55)
(R004_45 = ID59)
(R004_46 = ID4)
(R004_47 = ID8)
(R004_48 = ID12)
(R004_49 = ID16)
(R004_50 = ID20)
(R004_51 = ID24)
(R004_52 = ID28)
(R004_53 = ID32)
(R004_54 = ID36)
(R004_55 = ID40)
(R004_56 = ID44)
(R004_57 = ID46)
(R004_58 = ID48)
(R004_59 = ID52)
(R004_60 = ID56)
(R005_01 = ID61)
(R005_02 = ID65)
(R005_03 = ID69)
(R005_04 = ID73)
(R005_05 = ID77)
(R005_06 = ID81)
(R005_07 = ID85)
(R005_08 = ID89)
(R005_09 = ID93)
(R005_10 = ID97)
(R005_11 = ID101)
(R005_12 = ID105)
(R005_13 = ID109)
(R005_14 = ID113)
(R005_15 = ID117)
(R005_16 = ID66)
(R005_17 = ID70)
(R005_18 = ID74)
(R005_19 = ID78)
(R005_20 = ID82)
(R005_21 = ID86)
(R005_22 = ID90)
(R005_23 = ID94)
(R005_24 = ID98)
(R005_25 = ID102)
(R005_26 = ID106)
(R005_27 = ID110)
(R005_28 = ID114)
(R005_29 = ID118)
(R005_30 = ID63)
(R005_31 = ID67)
(R005_32 = ID71)
(R005_33 = ID75)
(R005_34 = ID79)
(R005_35 = ID83)
(R005_36 = ID87)
(R005_37 = ID91)
(R005_38 = ID95)
(R005_39 = ID99)
(R005_40 = ID103)
(R005_41 = ID107)
(R005_42 = ID111)
(R005_43 = ID115)
(R005_44 = ID119)
(R005_45 = ID60)
(R005_46 = ID64)
(R005_47 = ID68)
(R005_48 = ID72)
(R005_49 = ID76)
(R005_50 = ID80)
(R005_51 = ID84)
(R005_52 = ID88)
(R005_53 = ID92)
(R005_54 = ID96)
(R005_55 = ID100)
(R005_56 = ID104)
(R005_57 = ID108)
(R005_58 = ID112)
(R005_59 = ID116)
(R005_60 = ID120).


* aggregate mean likeability ratings for each individual classification image across raters.
AGGREGATE outfile "dfg_as_study3c_phase2_ind_agg.sav"
/ID1
ID5
ID9
ID13
ID17
ID21
ID25
ID29
ID33
ID37
ID41
ID45
ID49
ID53
ID57
ID2
ID6
ID10
ID14
ID18
ID22
ID30
ID34
ID38
ID42
ID50
ID54
ID58
ID62
ID3
ID7
ID11
ID15
ID19
ID23
ID27
ID31
ID35
ID39
ID43
ID47
ID51
ID55
ID59
ID4
ID8
ID12
ID16
ID20
ID24
ID28
ID32
ID36
ID40
ID44
ID46
ID48
ID52
ID56
ID61
ID65
ID69
ID73
ID77
ID81
ID85
ID89
ID93
ID97
ID101
ID105
ID109
ID113
ID117
ID66
ID70
ID74
ID78
ID82
ID86
ID90
ID94
ID98
ID102
ID106
ID110
ID114
ID118
ID63
ID67
ID71
ID75
ID79
ID83
ID87
ID91
ID95
ID99
ID103
ID107
ID111
ID115
ID119
ID60
ID64
ID68
ID72
ID76
ID80
ID84
ID88
ID92
ID96
ID100
ID104
ID108
ID112
ID116
ID120 = mean(
ID1
ID5
ID9
ID13
ID17
ID21
ID25
ID29
ID33
ID37
ID41
ID45
ID49
ID53
ID57
ID2
ID6
ID10
ID14
ID18
ID22
ID30
ID34
ID38
ID42
ID50
ID54
ID58
ID62
ID3
ID7
ID11
ID15
ID19
ID23
ID27
ID31
ID35
ID39
ID43
ID47
ID51
ID55
ID59
ID4
ID8
ID12
ID16
ID20
ID24
ID28
ID32
ID36
ID40
ID44
ID46
ID48
ID52
ID56
ID61
ID65
ID69
ID73
ID77
ID81
ID85
ID89
ID93
ID97
ID101
ID105
ID109
ID113
ID117
ID66
ID70
ID74
ID78
ID82
ID86
ID90
ID94
ID98
ID102
ID106
ID110
ID114
ID118
ID63
ID67
ID71
ID75
ID79
ID83
ID87
ID91
ID95
ID99
ID103
ID107
ID111
ID115
ID119
ID60
ID64
ID68
ID72
ID76
ID80
ID84
ID88
ID92
ID96
ID100
ID104
ID108
ID112
ID116
ID120).

* open aggregated file.
get file  "dfg_as_study3c_phase2_ind_agg.sav".

* flip file to have 1 line per subject and the mean likeability rating of individual classification image as a new variable.
flip.

* create new subject variable to match with existing file from phase1. ID corresponds to unique subject ID.
string subject(A8).
compute subject = substr(CASE_LBL, 3, 3).
exe.

ALTER TYPE subject(F8.0).
sort cases by subject.

*mean likeability rating of individual classification image.
rename variables (var001 = ci_like).

VARIABLE LABELS ci_like "mean likeability rating of individual classification image".

save outfile = "dfg_as_study3c_phase2_ind_agg.sav"
   /keep subject ci_like.

* match with data from phase 1.
get file "dfg_as_study3c_phase1_OSF.sav".
sort cases by subject.

match files file=*
   /file="dfg_as_study3c_phase2_ind_agg.sav"
   /by subject.
exe.



* exclude rcic trials from subjects who meet exclusion criteria (see phase 1).
select if mc_krit = 1.
exe.



* 2.2.2) Analysis of individual classification images.
* In order to run the analysis reported in our publication
* open dfg_as_study3c_phase2_ind_OSF.sav and run the code below.

* likeability scores were then submitted to a
* 2 (group membership of the target person: Jewish vs. Christian) × 2 (Holocaust is mentioned vs. control information)
* between subjects ANOVA.
UNIANOVA ci_like BY uv_jew uv_hol
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(uv_hol*uv_jew)
  /CRITERIA=ALPHA(0.05)
    /PRINT=ETASQ DESCRIPTIVE
  /DESIGN=uv_jew uv_hol uv_jew*uv_hol.

save outfile = "dfg_as_study3c_phase2_ind_OSF.sav".

