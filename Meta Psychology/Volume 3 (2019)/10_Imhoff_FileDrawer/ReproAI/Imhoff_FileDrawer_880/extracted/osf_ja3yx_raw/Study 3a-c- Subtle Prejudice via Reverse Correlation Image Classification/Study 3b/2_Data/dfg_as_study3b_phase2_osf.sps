* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 3b - Phase 2 (Image Rating).
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
*** open dfg_as_study3b_phase2_OSF.sav and run the code in the analyses section (2.1 contains the primary analyses) below.
*** use dfg_as_study3b_phase2_ind_OSF.sav to run the analysis in 2.2.2 (secondary analysis).

*** note: in order to use the relative paths use the following two lines in a new syntax file.
*** INSERT file = "[insert path here]\dfg_as_study3b_phase2_osf.sps"
*** CD = YES.

*************************************************************************************************.
* 1) Data Preparation (Documentation).
*************************************************************************************************.

* open ratings of group-wise classification images.
get file "rawdata\dfg_as_study3b_phase2.sav".

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
RECODE DE01_01 (lowest thru 28 = 1) (29 thru 45 = 2) (46 thru highest = 3) into age_groups.
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

save OUTFILE = "dfg_as_study3b_phase2_OSF.sav".




*************************************************************************************************.
* 2.2) Individual classification images.
*************************************************************************************************.

* 2.2.1) Documentation of data processing. 
* In order to run the analysis reported in our publication, please see below 2.2.2.
* note: the following raw data file containing the ratings of individual classification images is not available on OSF because it is not de-identified. 
* but you can nevertheless continue with the code since the de-identified version will be opened a few lines below.

* open ratings of individual classification images.
get file "rawdata\dfg_as_study3b_phase2_ind.sav".

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
RECODE DE01_01 (lowest thru 25 = 1) (26 thru 36 = 2) (37 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES DE01_01.

save OUTFILE = "dfg_as_study3b_phase2_ind_raw_OSF.sav".

*** open de-identified version.
get file "dfg_as_study3b_phase2_ind_raw_OSF.sav".

*** match pictures with subject ids.
RENAME VARIABLES
(R002_01 = ID1)
(R002_02 = ID5)
(R002_03 = ID9)
(R002_04 = ID13)
(R002_05 = ID17)
(R002_06 = ID21)
(R002_07 = ID25)
(R002_08 = ID29)
(R002_09 = ID33)
(R002_10 = ID37)
(R002_11 = ID41)
(R002_12 = ID45)
(R002_13 = ID49)
(R002_14 = ID53)
(R002_15 = ID57)
(R002_16 = ID2)
(R002_17 = ID6)
(R002_18 = ID10)
(R002_19 = ID14)
(R002_20 = ID18)
(R002_21 = ID22)
(R002_22 = ID26)
(R002_23 = ID30)
(R002_24 = ID34)
(R002_25 = ID38)
(R002_26 = ID42)
(R002_27 = ID46)
(R002_28 = ID50)
(R002_29 = ID54)
(R002_30 = ID58)
(R002_31 = ID3)
(R002_32 = ID7)
(R002_33 = ID11)
(R002_34 = ID15)
(R002_35 = ID19)
(R002_36 = ID23)
(R002_37 = ID27)
(R002_38 = ID31)
(R002_39 = ID35)
(R002_40 = ID39)
(R002_41 = ID43)
(R002_42 = ID47)
(R002_43 = ID51)
(R002_44 = ID55)
(R002_45 = ID59)
(R002_46 = ID4)
(R002_47 = ID8)
(R002_48 = ID12)
(R002_49 = ID16)
(R002_50 = ID20)
(R002_51 = ID24)
(R002_52 = ID28)
(R002_53 = ID32)
(R002_54 = ID36)
(R002_55 = ID40)
(R002_56 = ID44)
(R002_57 = ID48)
(R002_58 = ID52)
(R002_59 = ID56)
(R002_60 = ID60)
(R003_01 = ID61)
(R003_02 = ID65)
(R003_03 = ID69)
(R003_04 = ID73)
(R003_05 = ID77)
(R003_06 = ID81)
(R003_07 = ID85)
(R003_08 = ID89)
(R003_09 = ID93)
(R003_10 = ID97)
(R003_11 = ID101)
(R003_12 = ID105)
(R003_13 = ID113)
(R003_14 = ID117)
(R003_15 = ID165)
(R003_16 = ID62)
(R003_17 = ID66)
(R003_18 = ID70)
(R003_19 = ID74)
(R003_20 = ID78)
(R003_21 = ID82)
(R003_22 = ID86)
(R003_23 = ID90)
(R003_24 = ID94)
(R003_25 = ID98)
(R003_26 = ID102)
(R003_27 = ID106)
(R003_28 = ID110)
(R003_29 = ID114)
(R003_30 = ID118)
(R003_31 = ID63)
(R003_32 = ID67)
(R003_33 = ID71)
(R003_34 = ID75)
(R003_35 = ID79)
(R003_36 = ID83)
(R003_37 = ID87)
(R003_38 = ID91)
(R003_39 = ID95)
(R003_40 = ID99)
(R003_41 = ID103)
(R003_42 = ID107)
(R003_43 = ID111)
(R003_44 = ID115)
(R003_45 = ID119)
(R003_46 = ID64)
(R003_47 = ID68)
(R003_48 = ID72)
(R003_49 = ID76)
(R003_50 = ID80)
(R003_51 = ID84)
(R003_52 = ID88)
(R003_53 = ID92)
(R003_54 = ID96)
(R003_55 = ID100)
(R003_56 = ID104)
(R003_57 = ID108)
(R003_58 = ID109)
(R003_59 = ID112)
(R003_60 = ID116)
(R003_61 = ID120).


* aggregate mean likeability ratings for each individual classification image across raters.
AGGREGATE outfile "dfg_as_study3b_phase2_ind_agg.sav"
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
ID26
ID30
ID34
ID38
ID42
ID46
ID50
ID54
ID58
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
ID48
ID52
ID56
ID60
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
ID113
ID117
ID165
ID62
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
ID109
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
ID26
ID30
ID34
ID38
ID42
ID46
ID50
ID54
ID58
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
ID48
ID52
ID56
ID60
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
ID113
ID117
ID165
ID62
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
ID109
ID112
ID116
ID120).


* open aggregated file.
get file "dfg_as_study3b_phase2_ind_agg.sav".

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

save outfile = "dfg_as_study3b_phase2_ind_agg.sav"
   /keep subject ci_like.


* match with data from phase 1.
get file "dfg_as_study3b_phase1_OSF.sav".
sort cases by subject.

match files file=*
   /file="dfg_as_study3b_phase2_ind_agg.sav"
   /by subject.
exe.

* exclude rcic trials from subjects who meet exclusion criteria (see phase 1).
select if mc_krit = 1.
exe.



* 2.2.2) Analysis of individual classification images.
* In order to run the analysis reported in our publication
* open dfg_as_study3b_phase2_ind_OSF.sav and run the code below.

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


save outfile = "dfg_as_study3b_phase2_ind_OSF.sav".


