* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 3c - Phase 1 (Image Creation).
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Preprocess raw data from Inquisit
* 2) Compute questionnaire scores.
* 3) Exploratory Analyses of Phase 1.
* 4) Preprocess raw data from Inquisit for Reverse Correlation.

*************************************************************************************************.


*** Instruction for OSF:
*** this file documents how raw data from phase 1 was processed.
*** section 3 includes exploratory analyses of the explicit ratings of the target person.
*** for our primary analyses please consult the files for phase 2: dfg_as_study3c_phase2_osf.sps.


*************************************************************************************************.
* 1) Preprocess raw data from Inquisit (Documentation)
* this section documents how raw data from inquisit was processed. 
*************************************************************************************************.


* import raw data from inquisit (phase 1 of the study).

GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie3\studie3c\data\as_rcic4_all.dat"
  /DELCASE=LINE
  /DELIMITERS="\t"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  date F6.0
  time A8
  subject F8.0
  variables.currentgroupnumber F1.0
  blockcode A13
  blocknum F3.0
  trialcode A28
  trialnum F3.0
  response A512
  correct F1.0
  latency F8.0
  stimulusnumber1 F3.0
  stimulusitem1 A831
  stimulusnumber2 F3.0
  stimulusitem2 A443
  stimulusnumber3 F3.0
  stimulusitem3 A50.
CACHE.
EXECUTE.
DATASET NAME DataSet3 WINDOW=FRONT.



FREQUENCIES subject.


sort cases by subject.
exe.


*** incomplete: 26 (only 4 trials...), 67 (wsc missing), 23 (demog incomplete).
CROSSTABS subject by blockcode.

*** exclude aborted starts and recode double IDs (some IDs were given twice by the experimenter - recode to get unique IDs).
if subject = 44 and time = "19:58:08" subject = 46.
exe.

* exclude experimenter test trials.
select if subject NE 999.

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
   vector expl_(16).
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
AGGREGATE outfile = "D:\Uni\Forschung\dfg\studie3\studie3c\data\dfg_as_study3c_phase1.sav"
   /break = subject
/group = mean(variables.currentgroupnumber)
   /suspicion1 = max(suspicion1)
/suspicion2 = max(suspicion2)
/comment = max(comment)
/panas_1 to panas_20 = mean(panas_1 to panas_20)
/expl_1 to expl_16 = mean(expl_1 to expl_16)
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
get file "D:\Uni\Forschung\dfg\studie3\studie3c\data\dfg_as_study3c_phase1.sav".


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
expl_1	 "David S. hilft gerne anderen, solange er weiß, dass es ihm zuerst gut geht."
expl_2	 "David S. kümmert sich zuerst um sich selbst und versucht dann, dafür zu sorgen, dass es anderen gut geht."
expl_3	 "Wenn es David S. nicht gut geht, kann man nicht von ihm erwarten, dass er versucht, sich um andere zu kümmern."
expl_4	 "David S. glaubt, jeder sollte für sich selbst sorgen."
expl_5	 "David S. achtet auf seinen eigenen Vorteil und kümmert sich nicht darum, was mit anderen passiert."
expl_6	 "David S. interessiert sich nur für seine Belange."
expl_7	 "Ich glaube, ich würde David S. mögen."
expl_8	 "Ich finde David S. sympathisch."
expl_9	 "Ich glaube, David S. ist berechnend."
expl_10	 "Ich glaube, David S. ist geizig."
expl_11	 "Ich glaube, David S. ist warmherzig."
expl_12	 "Ich glaube, David S. ist gerissen."
expl_13	 "Ich glaube, David S. ist vertrauenswürdig."
expl_14	 "Ich glaube, David S. ist rücksichtslos."
expl_15	 "Ich glaube, David S. ist skrupellos."
expl_16	 "Ich glaube, David S. ist ehrlich."
.

VALUE LABELS group 1 "jewish / holocaust" 2 "christian / holocaust" 3 "jewish / control" 4 "christian / control".
VALUE LABELS sex 1 "female" 2 "male".
VALUE LABELS bildung 1 "Hauptschule" 2 "Realschule" 3 "Gymnasium" 4 "Universität" 0 "keiner" 9 "sonstiger".
VALUE LABELS religion 1 "Chr. Katholisch" 2 "Chr. Evangelisch" 3 "Muslimisch" 4 "Jüdisch" 0 "keiner" 9 "andere".
VALUE LABELS uv_jew 0 "Christian" 1 "Jewish".
VALUE LABELS uv_hol 0 "Control" 1 "Holocaust".

save outfile = "D:\Uni\Forschung\dfg\studie3\studie3c\data\dfg_as_study3c_phase1.sav".





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



*** items assessing likeability and self-interest of the target person.
recode expl_9 expl_10 expl_12 expl_14 expl_15 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into expl_9r expl_10r expl_12r expl_14r expl_15r.
exe.


RELIABILITY
  /VARIABLES=expl_1 expl_2 expl_3 expl_4 expl_5 expl_6
  /SCALE('self interest') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=expl_7 expl_8 expl_11 expl_13 expl_16 expl_9r expl_10r expl_12r expl_14r expl_15r
  /SCALE('likeability') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute self_interest = mean(expl_1, expl_2, expl_3, expl_4, expl_5, expl_6).
compute expl_like = mean(expl_7, expl_8, expl_11, expl_13, expl_16, expl_9r, expl_10r, expl_12r, expl_14r, expl_15r).
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

FREQUENCIES
wsc_1 to wsc_10.

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

do if wsc_6 = "Holocaust" or wsc_6 = "ocaust" or wsc_6 = "Holokaust".
   compute wsc_6_hol = 1.
else.
   compute wsc_6_hol = 0.
end if.

do if wsc_7 = "Konzentrationslager".
   compute wsc_7_hol = 1.
else.
   compute wsc_7_hol = 0.
end if.

do if wsc_8 = "atorium" or wsc_8 = "atoruium" or wsc_8 = "Krematorium" or wsc_8 = "krematorium".
   compute wsc_8_hol = 1.
else.
   compute wsc_8_hol = 0.
end if.

do if wsc_9 = "sung" or wsc_9 = "Vergarsung" or wsc_9 = "Vergasen" or wsc_9 = "Vergaßung" or wsc_9 = "Vergasung".
   compute wsc_9_hol = 1.
else.
   compute wsc_9_hol = 0.
end if.

do if wsc_10 = "ichten" or wsc_10 = "ichtung" or wsc_10 = "Vernichten" or wsc_10 = "vernichtung" or wsc_10 = "Vernichtung"  or wsc_10 = "Vernichtungslager".
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
self_interest "self interest of target person"
expl_like "likeability of target person"
panas_pa "PANAS positive affect"
panas_na "PANAS negative affect"
wsc_hol_sum "WSC - sum of Holocaust related answers".


save outfile = "D:\Uni\Forschung\dfg\studie3\studie3c\data\dfg_as_study3c_phase1.sav".

** De-Identification for the version puplished on OSF.
*Several ages occurred only once. --> form groups.
FREQUENCIES age.
RECODE age (lowest thru 20 = 1) (21 thru 23 = 2) (24 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES age.

*delete variables containing distinct education profiles, fields of study and migration background.
DELETE VARIABLES bildungother fach migration2 religionother.
*these variables contain individual text participants wrote about what they thought the study was about.
DELETE VARIABLES suspicion1 suspicion2 comment.

save outfile = "D:\Uni\Forschung\dfg\studie3\studie3c\data\dfg_as_study3c_phase1_OSF.sav".







*************************************************************************************************.
* 3) Analyses of Phase 1
* note that our primary analysis is the analysis of warmth ratings of the classification images (see data and syntax files for phase2).
*************************************************************************************************.
get file "D:\Uni\Forschung\dfg\studie3\studie3c\data\dfg_as_study3c_phase1_OSF.sav".


*secondary analyses - exploration (primary analyses - see phase2).
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



GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie3\studie3c\data\as_rcic4_all.dat"
  /DELCASE=LINE
  /DELIMITERS="\t"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  date F6.0
  time A8
  subject F8.0
  variables.currentgroupnumber F1.0
  blockcode A13
  blocknum F3.0
  trialcode A28
  trialnum F3.0
  response A512
  correct F1.0
  latency F8.0
  stimulusnumber1 F3.0
  stimulusitem1 A831
  stimulusnumber2 F3.0
  stimulusitem2 A443
  stimulusnumber3 F3.0
  stimulusitem3 A50.
CACHE.
EXECUTE.
DATASET NAME DataSet3 WINDOW=FRONT.



FREQUENCIES subject.


sort cases by subject.
exe.

*** incomplete: 26 (only 4 trials...), 67 (wsc missing), 23 (demog incomplete).
CROSSTABS subject by blockcode.

*** exclude aborted starts and recode double IDs (some IDs were given twice by the experimenter - recode to get unique IDs).
if subject = 44 and time = "19:58:08" subject = 46.
exe.

* exclude experimenter test trials.
select if subject NE 999.


* select Reverse Correlation Image Classification trials.
select if trialcode = "binary_face_davids".
exe.


* data exclusion.
* we excluded participants who did not remember correctly that the target person was Jewish [vs. Christian] 
* or that he was volunteering in an organization that demands reparation payments for Holocaust survivors [vs. an organization working to protect forests] or both.
* (see above - keep participants who meet mc_krit = 1).

select if subject NE 35
and subject NE 39
and subject NE 67
and subject NE 79
and subject NE 95
and subject NE 103
and subject NE 111
and subject NE 4
and subject NE 20
and subject NE 24
and subject NE 40
and subject NE 44
and subject NE 52
and subject NE 84
and subject NE 96
and subject NE 116
and subject NE 120
and subject NE 49
and subject NE 69
and subject NE 77
and subject NE 113
and subject NE 10
and subject NE 26
and subject NE 34
and subject NE 38
and subject NE 50
and subject NE 70
and subject NE 78
and subject NE 94
and subject NE 114
and subject NE 118.

save outfile = "D:\Uni\Forschung\dfg\studie3\studie3c\data\dfg_as_study3c_RC_OSF.sav"
    /drop date time.

