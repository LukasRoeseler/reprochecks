* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 3b - Phase 1 (Image Creation).
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Preprocess raw data from Inquisit
* 2) Compute questionnaire scores.
* 3) Exploratory analyses of Phase 1.
* 4) Preprocess raw data from Inquisit for Reverse Correlation.

*************************************************************************************************.


*** Instruction for OSF:
*** this file documents how raw data from phase 1 was processed.
*** section 3 includes exploratory analyses of the explicit ratings of the target person.
*** for our primary analyses please consult the files for phase 2: dfg_as_study3b_phase2_osf.sps.


*************************************************************************************************.
* 1) Preprocess raw data from Inquisit (Documentation)
* this section documents how raw data from inquisit was processed. 
*************************************************************************************************.


* import raw data from inquisit (phase 1 of the study).

PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie3\studie3b\data\raw\as_rcic3_ALL.dat"
  /DELCASE=LINE
  /DELIMITERS="\t"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  date AUTO
  time A8
  subject AUTO
  variables.currentgroupnumber AUTO
  blockcode AUTO
  blocknum AUTO
  trialcode AUTO
  trialnum AUTO
  response AUTO
  correct AUTO
  latency AUTO
  stimulusnumber1 AUTO
  stimulusitem1 AUTO
  stimulusnumber2 AUTO
  stimulusitem2 AUTO
  stimulusnumber3 AUTO
  stimulusitem3 AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

FREQUENCIES subject.



sort cases by subject.

*** exclude aborted starts and recode double IDs (some IDs were given twice by the experimenter - recode to get unique IDs).
if subject = 108 and time = "13:57:14" subject = 109.
if subject = 65 and time = "19:09:41" subject = 165.
if subject = 118 and time = "14:29:09" subject = 999.

* exclude experimenter test trials.
select if subject NE 999.
select if subject NE 777.
exe.


*exclude reverse correlation image classification task trials. these are prepared separately (see section 4).
select if blockcode NE "facial_davids".
exe.


*copy response variable in numeric format.
recode response (convert) into response2.
exe.


***construct variables.

*text responses from funneled debriefing after reverse correlation task which will be coded for suspicion.
string suspicion1(A512).
string suspicion2(A512).
string comment(A512).

* 20 PANAS items, suspicion questions, and explicit ratings of target person.
do if blockcode = "panas".
   vector panas_(20).
   compute panas_(stimulusnumber1) = response2.
else if trialcode = "suspicion1".
   compute suspicion1 = response.
else if trialcode = "suspicion2".
   compute suspicion2 = response.
else if blockcode = "david_fragen".
   vector expl_(10).
   compute expl_(stimulusnumber1) = response2.
end if.

exe.

* 30 items of word stem completion (wsc) task.
do if blockcode = "wsc".
   vector wsc_(30, A64).
   compute wsc_(stimulusnumber1) = response.
end if.
exe.

* 6 questions about the target person including manipulation checks.
if trialcode = 	"a" mc_a	 = response2.
if trialcode = 	"b" mc_b	 = response2.
if trialcode = 	"c" mc_c	 = response2.
if trialcode = 	"d" mc_d	 = response2.
if trialcode = 	"e" mc_e	 = response2.
if trialcode = 	"f" mc_f	 = response2.

* demographics.
if trialcode = "age" age = response2.
if trialcode = "sex" sex = response2.
if trialcode = "bildung" bildung = response2.
string bildungother(A32).
if trialcode = "bildungother" bildungother = response.
string fach(A32).
if trialcode = "fach" fach = response.
if trialcode = "migration" migration = response2.
string migration2(A32).
if trialcode = "migration2"migration2 = response.
if trialcode = "religion" religion = response2.
string religionother(A32).
if trialcode = "religionother" religionother = response.
exe.

*aggregate file to get 1 line per subject.
AGGREGATE outfile = "D:\Uni\Forschung\dfg\studie3\studie3b\data\dfg_as_study3b_phase1.sav"
   /break = subject
/group = mean(variables.currentgroupnumber)
   /suspicion1 = max(suspicion1)
/suspicion2 = max(suspicion2)
/comment = max(comment)
/panas_1 to panas_20 = mean(panas_1 to panas_20)
/expl_1 to expl_10 = mean(expl_1 to expl_10)
/wsc_1 to wsc_30 = max(wsc_1 to wsc_30)
/mc_a = mean(mc_a)
/mc_b = mean(mc_b)
/mc_c = mean(mc_c)
/mc_d = mean(mc_d)
/mc_e = mean(mc_e)
/mc_f = mean(mc_f)
/age = mean(age)
/sex = mean(sex)
/bildung = mean(bildung)
/bildungother = max(bildungother)
/fach = max(fach)
/migration = mean(migration)
/migration2 = max(migration2)
/religion = mean(religion)
/religionother = max(religionother).


*open aggregated file.
get file "D:\Uni\Forschung\dfg\studie3\studie3b\data\dfg_as_study3b_phase1.sav".


* construct new variables representing both IVs:
* group membership of the target person: Jewish vs. Christian.
* Holocaust is mentioned vs. control information.
recode group (1=1) (2=0) (3=1) (4=0) into uv_jew.
recode group (1=1) (2=1) (3=0) (4=0) into uv_hol.
exe.

VARIABLE LABELS
panas_1 "aktiv"
panas_2 "interessiert"
panas_3 "freudig erregt"
panas_4 "stark"
panas_5 "angeregt"
panas_6 "stolz"
panas_7 "begeistert"
panas_8 "wach"
panas_9 "entschlossen"
panas_10 "aufmerksam"
panas_11 "bekümmert"
panas_12 "verärgert"
panas_13 "schuldig"
panas_14 "erschrocken"
panas_15 "feindselig"
panas_16 "gereizt"
panas_17 "beschämt"
panas_18 "nervös"
panas_19 "durcheinander"
panas_20 "ängstlich"
wsc_1 "Depo_________"
wsc_2 "Endl_________"
wsc_3 "Erm__________"
wsc_4 "Gask_________"
wsc_5 "Geno_________"
wsc_6 "Hol_________"
wsc_7 "Konz_________"
wsc_8 "Krem_________"
wsc_9 "Verga_________"
wsc_10 "Vern_________"
wsc_11 "Akte_________"
wsc_12 "Alte_________"
wsc_13 "Bewe_________"
wsc_14 "Einw_________"
wsc_15 "Empf_________"
wsc_16 "Erfa_________"
wsc_17 "Fort_________"
wsc_18 "Funk_________"
wsc_19 "Gymn_________"
wsc_20 "Hint_________"
wsc_21 "Kilo_________"
wsc_22 "Krei_________"
wsc_23 "Lieb_________"
wsc_24 "Mono_________"
wsc_25 "Nage_________"
wsc_26 "Pers_________"
wsc_27 "Rege_________"
wsc_28 "Rück_________"
wsc_29 "Stei_________"
wsc_30 "Zusa_________"
expl_1 "Wie sehr würden Sie David S. wohl mögen?"
expl_2 "Wie sympathisch erscheint Ihnen David S.?"
expl_3 "Wie berechnend erscheint Ihnen David S.?"
expl_4 "Wie geizig erscheint Ihnen David S.?"
expl_5 "Wie warmherzig erscheint Ihnen David S.?"
expl_6 "Wie gerissen erscheint Ihnen David S.?"
expl_7 "Wie vertrauenswürdig erscheint Ihnen David S.?"
expl_8 "Wie rücksichtslos erscheint Ihnen David S.?"
expl_9 "Wie skrupellos erscheint Ihnen David S.?"
expl_10 "Wie ehrlich erscheint Ihnen David S.?"
uv_jew "IV group membership"
uv_hol "IV Holocaust".

VALUE LABELS group 1 "jewish / holocaust" 2 "christian / holocaust" 3 "jewish / control" 4 "christian / control".
VALUE LABELS sex 1 "female" 2 "male".
VALUE LABELS bildung 1 "Hauptschule" 2 "Realschule" 3 "Gymnasium" 4 "Universität" 0 "keiner" 9 "sonstiger".
VALUE LABELS religion 1 "Chr. Katholisch" 2 "Chr. Evangelisch" 3 "Muslimisch" 4 "Jüdisch" 0 "keiner" 9 "andere".
VALUE LABELS uv_jew 0 "Christian" 1 "Jewish".
VALUE LABELS uv_hol 0 "Control" 1 "Holocaust".

save outfile = "D:\Uni\Forschung\dfg\studie3\studie3b\data\dfg_as_study3b_phase1.sav".



*************************************************************************************************.
* 2) Compute Questionnaire Scores
*************************************************************************************************.


** Manipulation check (questions c and f). construct variables representing correct vs. incorrect answers.
recode mc_a (4=1) (else = 0) into mc_a_correct.
recode mc_b (3=1) (else = 0) into mc_b_correct.
recode mc_d (4=1) (else = 0) into mc_d_correct.
recode mc_e (2=1) (else = 0) into mc_e_correct.

do if uv_jew = 1.
  recode mc_c (2=1) (else = 0) into mc_c_correct.
ELSE if uv_jew = 0.
  recode mc_c (1=1) (else = 0) into mc_c_correct.
end if.

do if uv_hol = 1.
  recode mc_f (2=1) (else = 0) into mc_f_correct.
ELSE if uv_hol = 0.
  recode mc_f (3=1) (else = 0) into mc_f_correct.
end if.
exe.

* product of manipulation check answers (used for exclusions).
compute mc_krit = mc_c_correct*mc_f_correct.
exe.

*age and sex of whole sample.
FREQUENCIES sex.
DESCRIPTIVES age.

* data exclusion.
* we excluded participants who did not remember correctly that the target person was Jewish [vs. Christian] 
* or that he was volunteering in an organization that demands reparation payments for Holocaust survivors [vs. an organization working to protect forests] or both.
select if mc_krit = 1.
exe.

*age and sex of effective sample.
FREQUENCIES VARIABLES=sex age
  /ORDER=ANALYSIS.
DESCRIPTIVES VARIABLES=age
  /STATISTICS=MEAN STDDEV MIN MAX.



* 10 items assessing likeability of the target person.
recode expl_3 expl_4 expl_6 expl_8 expl_9 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into expl_3r expl_4r expl_6r expl_8r expl_9r.
exe.


RELIABILITY
  /VARIABLES=expl_3r expl_4r expl_6r expl_8r expl_9r expl_1 expl_2 expl_5 expl_7 expl_10
  /SCALE(' likeability of the target person') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.

compute expl_like = mean(expl_3r, expl_4r, expl_6r, expl_8r, expl_9r, expl_1, expl_2, expl_5, expl_7, expl_10).
exe.


* PANAS positive affect.
RELIABILITY
  /VARIABLES=panas_1 panas_2 panas_3 panas_4 panas_5 panas_6 panas_7 panas_8 panas_9 panas_10
  /SCALE('PANAS positive affect') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.

* PANAS negative affect.
RELIABILITY
  /VARIABLES=panas_11 panas_12 panas_13 panas_14 panas_15 panas_16 panas_17 panas_18 panas_19 
    panas_20
  /SCALE('PANAS negative affect') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.

compute panas_pa = mean (panas_1, panas_2, panas_3, panas_4, panas_5, panas_6, panas_7, panas_8, panas_9, panas_10).
compute panas_na = mean (panas_11, panas_12, panas_13, panas_14, panas_15, panas_16, panas_17, panas_18, panas_19, panas_20).
exe.



*** Word Stem Completion task (WSC). 
* count Holocaust related answers on critical items (coded manually).


do if wsc_1 = "Deportation" or wsc_1 = "Deportieren" or wsc_1 = "Deportiert" or wsc_1 = "rtation" or wsc_1 = "rtieren" or wsc_1 = "rtierung".
   compute wsc_1_hol = 1.
ELSE.
    compute wsc_1_hol = 0.
end if.

do if wsc_2 = "endlösung" or wsc_2 = "Endlösung" or  wsc_2 = "ösung".
   compute wsc_2_hol = 1.
else.
   compute wsc_2_hol = 0.
end if.

do if wsc_3 = "Ermordung" or wsc_3 = "ordung".
   compute wsc_3_hol = 1.
ELSE.
   compute wsc_3_hol = 0.
end if.

do if wsc_4 = "ammer" or wsc_4 = "gaskammer" or wsc_4 = "Gaskammer".
   compute wsc_4_hol = 1.
else.
   compute wsc_4_hol = 0.
end if.

do if wsc_5 = "Genozid" or wsc_5 = "Genozit" or wsc_5 = "zid" or wsc_5 = "zit".
   compute wsc_5_hol = 1.
else.
   compute wsc_5_hol = 0.
end if.

do if wsc_6 = "Holocaust" or wsc_6 = "ocaust".
   compute wsc_6_hol = 1.
else.
   compute wsc_6_hol = 0.
end if.

do if wsc_7 = "Konzentrationslager".
   compute wsc_7_hol = 1.
else.
   compute wsc_7_hol = 0.
end if.

do if wsc_8 = "atorium" or wsc_8 = "atoruium" or wsc_8 = "Krematorium".
   compute wsc_8_hol = 1.
else.
   compute wsc_8_hol = 0.
end if.

do if wsc_9 = "sung" or wsc_9 = "Vergarsung" or wsc_9 = "Vergasen" or wsc_9 = "Vergaßung" or wsc_9 = "Vergasung".
   compute wsc_9_hol = 1.
else.
   compute wsc_9_hol = 0.
end if.

do if wsc_10 = "ichten" or wsc_10 = "ichtung" or wsc_10 = "Vernichten" or wsc_10 = "vernichtung" or wsc_10 = "Vernichtung".
   compute wsc_10_hol = 1.
else.
   compute wsc_10_hol = 0.
end if.

exe.


* WSC score: sum of Holocaust related answers.
compute wsc_hol_sum = sum(wsc_1_hol, wsc_2_hol, wsc_3_hol, wsc_4_hol, wsc_5_hol, wsc_6_hol, wsc_7_hol, wsc_8_hol, wsc_9_hol, wsc_10_hol).
exe.


VARIABLE LABELS
mc_krit "manipulation check correct"
expl_like "likeability of target person"
panas_pa "PANAS positive affect"
panas_na "PANAS negative affect"
wsc_hol_sum "WSC - sum of Holocaust related answers".


save outfile = "D:\Uni\Forschung\dfg\studie3\studie3b\data\dfg_as_study3b_phase1.sav".


** De-Identification for the version puplished on OSF.
*Several ages occurred only once. --> form groups.
RECODE age (lowest thru 21 = 1) (22 thru 23 = 2) (24 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES age.

*delete variables containing distinct education profiles, fields of study and migration background.
DELETE VARIABLES bildungother fach migration2 religionother.
*these variables contain individual text participants wrote about what they thought the study was about.
DELETE VARIABLES suspicion1 suspicion2 comment.

save outfile = "D:\Uni\Forschung\dfg\studie3\studie3b\data\dfg_as_study3b_phase1_OSF.sav".






*************************************************************************************************.
* 3) Analyses of Phase 1
* note that our primary analysis is the analysis of warmth ratings of the classification images (see data and syntax files for phase2).
*************************************************************************************************.

get file "D:\Uni\Forschung\dfg\studie3\studie3b\data\dfg_as_study3b_phase1_OSF.sav".

*secondary analyses - exploration (primary analyses - see phase2).

*descriptives of scores of interest.
sort cases by group.
split file by group.
DESCRIPTIVES VARIABLES=expl_like panas_pa panas_na wsc_hol_sum
  /STATISTICS=MEAN STDDEV MIN MAX.
split file off.

* 2x2 ANOVA for likeability of target person and PANAS scales.
UNIANOVA expl_like panas_pa panas_na BY uv_jew uv_hol
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(uv_hol*uv_jew)
  /EMMEANS=TABLES(uv_jew) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(uv_hol) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(uv_jew*uv_hol) 
  /PRINT=OPOWER ETASQ
  /CRITERIA=ALPHA(.05)
  /DESIGN=uv_jew uv_hol uv_jew*uv_hol.


* number of Holocaust related words in Holocaust vs. control condition.
T-TEST GROUPS=uv_hol(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=wsc_hol_sum
  /CRITERIA=CI(.95).




*************************************************************************************************.
* 4) Preprocess raw data from Inquisit for use in Reverse Correlation (Documentation).
*************************************************************************************************.



* import raw data from inquisit (phase 1 of the study).

PRESERVE.
 SET DECIMAL COMMA.

GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie3\studie3b\data\raw\as_rcic3_ALL.dat"
  /DELCASE=LINE
  /DELIMITERS="\t"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  date AUTO
  time A8
  subject AUTO
  variables.currentgroupnumber AUTO
  blockcode AUTO
  blocknum AUTO
  trialcode AUTO
  trialnum AUTO
  response AUTO
  correct AUTO
  latency AUTO
  stimulusnumber1 AUTO
  stimulusitem1 AUTO
  stimulusnumber2 AUTO
  stimulusitem2 AUTO
  stimulusnumber3 AUTO
  stimulusitem3 AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

FREQUENCIES subject.


sort cases by subject.

*** exclude aborted starts and recode double IDs (some IDs were given twice by the experimenter - recode to get unique IDs).
if subject = 108 and time = "13:57:14" subject = 109.
if subject = 65 and time = "19:09:41" subject = 165.
if subject = 118 and time = "14:29:09" subject = 999.

* exclude experimenter test trials.
select if subject NE 999.
select if subject NE 777.
exe.

* select Reverse Correlation Image Classification trials.
select if trialcode = "binary_face_davids".
exe.


*** recode stimulusnumber to match number of the pictures used.
compute stimulusnumber2 = stimulusnumber2 + 1.
recode stimulusnumber2 (401=1).
exe.


* data exclusion.
* we excluded participants who did not remember correctly that the target person was Jewish [vs. Christian] 
* or that he was volunteering in an organization that demands reparation payments for Holocaust survivors [vs. an organization working to protect forests] or both.
* (see above - keep participants who meet mc_krit = 1).

select if subject NE 	33
and subject NE 	41
and subject NE 	57
and subject NE 	69
and subject NE 	77
and subject NE 	101
and subject NE 	113
and subject NE 	18
and subject NE 	66
and subject NE 	74
and subject NE 	3
and subject NE 	7
and subject NE 	15
and subject NE 	19
and subject NE 	31
and subject NE 	63
and subject NE 	75
and subject NE 	87
and subject NE 	111
and subject NE 	115
and subject NE 	119
and subject NE 	4
and subject NE 	36
and subject NE 	40
and subject NE 	64
and subject NE 	68
and subject NE 	92.

save outfile = "D:\Uni\Forschung\dfg\studie3\studie3b\data\dfg_as_study3b_RC_OSF.sav"
    /drop date time.

