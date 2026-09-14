* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 3a - Phase 1 (Image Creation).
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
*** for our primary analyses please consult the files for phase 2: dfg_as_study3a_phase2_osf.sps.


*************************************************************************************************.
* 1) Preprocess raw data from Inquisit (Documentation)
* this section documents how raw data from inquisit was processed. 
*************************************************************************************************.

* import raw data from inquisit (phase 1 of the study).
GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie3\studie3a\data\all_18062013.dat"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS="\t"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  date F6.0
  time A8
  subject F3.0
  values.group F1.0
  blockcode A13
  blocknum F1.0
  trialcode A18
  trialnum F3.0
  response A512
  correct F1.0
  latency F8.0
  stimulusnumber1 F3.0
  stimulusitem1 A54
  stimulusnumber2 F3.0
  stimulusitem2 A53
  stimulusnumber3 F3.0
  stimulusitem3 A46.
CACHE.
EXECUTE.
DATASET NAME DatenSet1 WINDOW=FRONT.

sort cases by subject.
FREQUENCIES subject.
CROSSTABS time by subject.

*** exclude aborted starts and recode double IDs (some IDs were given twice by the experimenter - recode to get unique IDs).
if subject = 1 and time = "10:03:57" subject = 101.
if subject = 1 and time = "10:12:39" subject = 201.
if subject = 1 and time = "10:21:08" subject = 301.
if subject = 2 and time = "10:24:30" subject = 102.
if subject = 3 and time = "10:16:10" subject = 999.
if subject = 4 and time = "10:37:50" subject = 104.
if subject = 4 and time = "10:48:15" subject = 204.
if subject = 4 and time = "12:04:43" subject = 304.
if subject = 5 subject = 999.

* subject 6 time 10:19:16 read the text and aborted after that. restarted with subject 6 time 10:23:56.
* recode group variable to match the text the subject had read.
if subject = 6 and time = "10:19:16" subject = 999.
if subject = 6 and time = "10:23:56" values.group = 3.

if subject = 6 and time = "10:57:04" subject = 106.
if subject = 8 and time = "11:35:26" subject = 108.
if subject = 9 and time = "11:54:13" subject = 109.
if subject = 10 and time = "11:55:10" subject = 110.
if subject = 11 and time = "11:56:22" subject = 111.
if subject = 12 and time = "11:59:48" subject = 112.
if subject = 13 and time = "11:20:54" subject = 113.
if subject = 13 and time = "12:44:42" subject = 213.
if subject = 14 and time = "11:46:02" subject = 114.
if subject = 14 and time = "12:56:56" subject = 214.
if subject = 15 and time = "13:01:55" subject = 115.
if subject = 16 and time = "13:07:33" subject = 116.
if subject = 16 and time = "13:15:37" subject = 216.
if subject = 17 and time = "13:17:41" subject = 117.
if subject = 20 and time = "14:13:30" subject = 220.
if subject = 52 and time = "12:57:31" subject = 53.
*exclude parts of subject 61 because of a restart.
if subject = 61 and time = "09:32:51" subject = 999.
if subject = 72 and time = "11:17:35" subject = 172.
if subject = 74 subject = 999.

*exclude test runs by the experimenter.
select if subject < 800.
exe.

sort cases by subject.

FREQUENCIES subject.

*exclude reverse correlation image classification task trials in this file. these are prepared separately.
select if blockcode NE "facial_davids".
exe.

*copy response variable in numeric format.
recode response (convert) into response2.
exe.


***construct variables.

*text responses from funneled debriefing after reverse correlation task which will be coded for suspicion.
string suspicion1(A512) suspicion2(A512) suspicion3(A512) suspicion4(A512) suspicion5(A512) suspicion6(A512).
if trialcode = "suspicion1" suspicion1 = response.
if trialcode = "suspicion2" suspicion2 = response.
if trialcode = "suspicion3" suspicion3 = response.
if trialcode = "suspicion4" suspicion4 = response.
if trialcode = "suspicion5" suspicion5 = response.
if trialcode = "suspicion6" suspicion6 = response.

*openended question: describe person in own words.
string mc_open(A512).
if trialcode = "mc_open" mc_open = response.
exe.

*warmth and competence rating: 20 items.
do if trialcode = "david_fragen".
   vector david_expl_(20).
   compute david_expl_(stimulusnumber1) = response2.
end if.
exe.

*10 questions about the target person including manipulation checks.
if trialcode = 	"mc_a" mc_a	 = response2.
if trialcode = 	"mc_b" mc_b	 = response2.
if trialcode = 	"mc_c" mc_c	 = response2.
if trialcode = 	"mc_d" mc_d	 = response2.
if trialcode = 	"mc_e" mc_e	 = response2.
if trialcode = 	"mc_f" mc_f	 = response2.
if trialcode = 	"mc_g" mc_g	 = response2.
if trialcode = 	"mc_h" mc_h	 = response2.
if trialcode = 	"mc_i" mc_i	 = response2.
if trialcode = 	"mc_j" mc_j	 = response2.
exe.

*demographics.
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

* 14 antisemitism items.
do if trialcode = "as".
   vector as_(14).
   compute as_(stimulusnumber1) = response2.
end if.
exe.

*questions about the purpose of the study and whether ps received informations about the study before participation.
string nachbefragung1(A512) nachbefragung2(A512).
if trialcode = "nachbefragung1" nachbefragung1 = response.
if trialcode = "nachbefragung2" nachbefragung2 = response.
exe.

*construct group variable.
if trialcode = "suspicion6" group = values.group.
exe.


*aggregate file to get 1 line per subject.
AGGREGATE outfile = "D:\Uni\Forschung\dfg\studie3\studie3a\data\dfg_as_study3a_phase1.sav"
   /BREAK = subject
   /group = mean(group)
   /suspicion1 = max(suspicion1)
/suspicion2 = max(suspicion2)
/suspicion3 = max(suspicion3)
/suspicion4 = max(suspicion4)
/suspicion5 = max(suspicion5)
/suspicion6 = max(suspicion6)
/mc_open = max(mc_open)
/david_expl_1 = mean(david_expl_1)
/david_expl_2 = mean(david_expl_2)
/david_expl_3 = mean(david_expl_3)
/david_expl_4 = mean(david_expl_4)
/david_expl_5 = mean(david_expl_5)
/david_expl_6 = mean(david_expl_6)
/david_expl_7 = mean(david_expl_7)
/david_expl_8 = mean(david_expl_8)
/david_expl_9 = mean(david_expl_9)
/david_expl_10 = mean(david_expl_10)
/david_expl_11 = mean(david_expl_11)
/david_expl_12 = mean(david_expl_12)
/david_expl_13 = mean(david_expl_13)
/david_expl_14 = mean(david_expl_14)
/david_expl_15 = mean(david_expl_15)
/david_expl_16 = mean(david_expl_16)
/david_expl_17 = mean(david_expl_17)
/david_expl_18 = mean(david_expl_18)
/david_expl_19 = mean(david_expl_19)
/david_expl_20 = mean(david_expl_20)
/mc_a = mean(mc_a)
/mc_b = mean(mc_b)
/mc_c = mean(mc_c)
/mc_d = mean(mc_d)
/mc_e = mean(mc_e)
/mc_f = mean(mc_f)
/mc_g = mean(mc_g)
/mc_h = mean(mc_h)
/mc_i = mean(mc_i)
/mc_j = mean(mc_j)
/age = mean(age)
/sex = mean(sex)
/bildung = mean(bildung)
/bildungother = max(bildungother)
/fach = max(fach)
/migration = mean(migration)
/migration2 = max(migration2)
/religion = mean(religion)
/religionother = max(religionother)
/as_1 = mean(as_1)
/as_2 = mean(as_2)
/as_3 = mean(as_3)
/as_4 = mean(as_4)
/as_5 = mean(as_5)
/as_6 = mean(as_6)
/as_7 = mean(as_7)
/as_8 = mean(as_8)
/as_9 = mean(as_9)
/as_10 = mean(as_10)
/as_11 = mean(as_11)
/as_12 = mean(as_12)
/as_13 = mean(as_13)
/as_14 = mean(as_14)
/nachbefragung1 = max(nachbefragung1)
/nachbefragung2 = max(nachbefragung2).

*open aggregated file.
get file "D:\Uni\Forschung\dfg\studie3\studie3a\data\dfg_as_study3a_phase1.sav".
sort cases by subject.

sort cases by group.

* construct new variables representing both IVs:
* group membership of the target person: Jewish vs. Christian.
* Holocaust is mentioned vs. control information.
recode group (1=1) (2=1) (3=0) (4=0) into uv_jew.
recode group (1=0) (2=1) (3=0) (4=1) into uv_hol.
exe.

VARIABLE LABELS suspicion1 "Beschreiben Sie in Ihren eigenen Worten, worum es Ihrer Meinung nach in dieser Studie geht."
suspicion2 "Glaubten Sie zu irgendeinem Zeitpunkt, dass die Studie etwas anderes untersucht, als das, was Ihnen mitgeteilt wurde?"
suspicion3 "Beeinflusste dies Ihr Verhalten in irgendeiner Weise?"
suspicion4 "Hatten Sie den Eindruck, dass bestimmte Reaktionen von Ihnen erwartet wurden?"
suspicion5 "Welchen Zweck haben wir Ihrer Meinung nach mit der Beschreibung von David verfolgt?"
suspicion6 "Welche Information zu David hielten Sie für relevant in Bezug auf die Studie?"
mc_open "Bitte beschreiben Sie David kurz in eigenen Worten."
david_expl_1 "selbstsicher"
david_expl_2 "einsam"
david_expl_3 "intelligent"
david_expl_4 "warm"
david_expl_5 "phantasievoll"
david_expl_6 "aufrichtig"
david_expl_7 "wissbegierig"
david_expl_8 "freundlich"
david_expl_9 "lebhaft"
david_expl_10 "gesetzestreu "
david_expl_11 "kompetent"
david_expl_12 "gutmütig"
david_expl_13 "besorgt "
david_expl_14 "tüchtig"
david_expl_15 "gesellig "
david_expl_16 "ehrlich"
david_expl_17 "ängstlich"
david_expl_18 "unabhängig"
david_expl_19 "ruhig "
david_expl_20 "vertrauenswürdig"
mc_a "David lebt in"
mc_b "David hält Vorträge zu"
mc_c "David hat studiert:"
mc_d "David arbeitet ehrenamtlich in einer Organisation für"
mc_e "David lebt in"
mc_f "David ist"
mc_g "Davids Aufgabe im Hilfsprojekt ist"
mc_h "David spielt"
mc_i "Davids Sohn heißt"
mc_j "David engagiert sich"
as_1 "Das Verhältnis zwischen Deutschen und Juden ist nach wie vor geprägt von den Spuren der Vergangenheit."
as_2 "Sollte die von mir präferierte Partei einen Kandidaten nominieren, der Jude ist, wäre ich damit einverstanden, dass ein Jude deutscher Kanzler wird."
as_3 "Die Juden besitzen wieder zuviel Macht und Einfluss in der Welt."
as_4 "Juden haben viel zum deutschen kulturellen Leben beigetragen."
as_5 "Bei der Politik, die Israel macht, kann ich gut verstehen, dass man etwas gegen Juden hat."
as_6 "Die Juden nutzen die Erinnerung an den Holocaust heute für ihren eigenen Vorteil aus."
as_7 "Ich kann mich leicht schuldig fühlen für die negativen Folgen, die durch Deutsche veranlasst wurden."
as_8 "Viele Juden versuchen, aus der Vergangenheit des Dritten Reiches heute ihren Vorteil zu ziehen."
as_9 "Manchmal habe ich das Gefühl, dass die Juden unser schlechtes Gewissen ausnutzen."
as_10 "Durch die israelische Politik werden mir die Juden immer unsympathischer."
as_11 "Die Juden sollten aufhören, sich ständig darüber zu beschweren, was ihnen in Nazi-Deutschland widerfahren ist."
as_12 "Juden sorgen mit ihren Ideen immer für Unfrieden."
as_13 "Juden werden in Deutschland als unantastbare Moralinstitution gesehen."
as_14 "Oft wird zuviel auf jüdisches Leid im 2. Weltkrieg geschaut und vergessen, dass es auch andere Opfer gab."
nachbefragung1 "Beschreiben Sie in Ihren eigenen Worten, worum es Ihrer Meinung nach in dieser Studie geht."
nachbefragung2 "Hatten Sie irgendwelche Informationen über diese Studie bevor Sie teilnahmen"
uv_jew "IV group membership"
uv_hol "IV Holocaust".

VALUE LABELS group 1 "jewish / control" 2 "jewish / holocaust" 3 "christian / control" 4 "christian / holocaust".
VALUE LABELS sex 1 "female" 2 "male".
VALUE LABELS bildung 1 "Hauptschule" 2 "Realschule" 3 "Gymnasium" 4 "Universität" 0 "keiner" 9 "sonstiger".
VALUE LABELS religion 1 "Chr. Catholic" 2 "Chr. Protestant" 3 "Muslim" 4 "Jewish" 0 "none" 9 "other".
VALUE LABELS uv_jew 0 "Christian" 1 "Jewish".
VALUE LABELS uv_hol 0 "Control" 1 "Holocaust".



*************************************************************************************************.
* 2) Compute Questionnaire Scores
*************************************************************************************************.


** Manipulation check. construct variables representing correct vs. incorrect answers.
recode mc_a (1 = 1) (else = 0) into mc_a_correct.
recode mc_b (3 = 1) (else = 0) into mc_b_stereotype.
recode mc_c (2 = 1) (else = 0) into mc_c_correct.

do if group = 2 or group = 4.
   recode mc_d (3 = 1) (else = 0) into mc_d_correct.
ELSE.
   recode mc_d (2 = 1) (else = 0) into mc_d_correct.
end if.

recode mc_e (3 = 1) (else = 0) into mc_e_correct.

do if group = 1 or group = 2.
   recode mc_f (3 = 1) (else = 0) into mc_f_correct.
ELSE.
   recode mc_f (2 = 1) (else = 0) into mc_f_correct.
end if.

recode mc_g (1 = 1) (else = 0) into mc_g_correct.
recode mc_h (1 = 1) (else = 0) into mc_h_correct.
recode mc_i (3 = 1) (else = 0) into mc_i_correct.

do if group = 1 or group = 2.
   recode mc_j (3 = 1) (else = 0) into mc_j_correct.
ELSE.
   recode mc_j (1 = 1) (else = 0) into mc_j_correct.
end if.
exe.

*including all questions.
compute mc_correct = mean(mc_a_correct,mc_c_correct,mc_d_correct,mc_e_correct,mc_f_correct,mc_g_correct,mc_h_correct,mc_i_correct,mc_j_correct).
exe.

*only the manipulation check questions (questions f and j: group membership; d: Holocaust vs. control).
compute mc_jew = mc_f_correct*mc_j_correct.
compute mc_hol = mc_d_correct.
exe.



*age and sex of whole sample.
FREQUENCIES sex.
DESCRIPTIVES age.

* data exclusion.
* we excluded 17 participants before running the analyses because they did not remember correctly that the target person was Jewish [vs. Christian] 
* or that he was volunteering in an organization that supports Holocaust survivors [vs. an organization working to protect forests] or both.
select if mc_jew = 1 and mc_hol = 1.
exe.

*age and sex of effective sample.
FREQUENCIES VARIABLES=sex
  /ORDER=ANALYSIS.
DESCRIPTIVES VARIABLES=age
  /STATISTICS=MEAN STDDEV MIN MAX.



* Antisemitism.

recode as_2 as_4 as_7 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into as_2r as_4r as_7r.
exe.

RELIABILITY
  /VARIABLES=as_3 as_5 as_6 as_8 as_9 as_10 as_11 as_12 as_13 as_14 as_2r as_4r as_7r
  /SCALE('Antisemitism') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE
  /SUMMARY=TOTAL.

compute as = mean(as_3, as_5, as_6, as_8, as_9, as_10, as_11, as_12, as_13, as_14, as_2r, as_4r, as_7r).
exe.



** explicit warmth and competence rating of target person.

RELIABILITY
  /VARIABLES=david_expl_4 david_expl_6 david_expl_8 david_expl_12 david_expl_20
  /SCALE('target person: warmth rating') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=david_expl_1 david_expl_3 david_expl_11 david_expl_18
  /SCALE('target person: competence rating') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.

compute expl_warmth = mean(david_expl_4, david_expl_6, david_expl_8, david_expl_12, david_expl_20).
compute expl_comp = mean(david_expl_1, david_expl_3, david_expl_11, david_expl_18).
exe.

VARIABLE LABELS
as "antisemitism score"
expl_warmth "explicit warmth of target person"
expl_comp "explicit competence of target person"
mc_a_correct "MC: korrekt - David lebt inDortmund"
mc_b_stereotype "MC: stereotypkonsistent - David hält Vorträge zujüdischer Musik"
mc_c_correct "MC: korrekt - David hat studiert:BWL"
mc_d_correct "MC: korrekt - David arbeitet ehrenamtlich in einer Organisation fürdie Bewahrung des Waldes/Nachkommen von Holocaustüberlebenden"
mc_e_correct "MC: korrekt - David lebt ineinem Haus"
mc_f_correct "MC: korrekt - David istChrist/Jude"
mc_g_correct "MC: korrekt - Davids Aufgabe im Hilfsprojekt istSpenden verwalten"
mc_h_correct "MC: korrekt - David spieltGitarre"
mc_i_correct "MC: korrekt - Davids Sohn heißtSimon"
mc_j_correct "MC: korrekt - David engagiert sichin der Kirche/in der Synagoge".



VARIABLE LABELS
mc_correct "MC: correct all questions"
mc_jew "MC: correct jewish/christian"
mc_hol "MC: correct Holocaust/control".

save outfile "D:\Uni\Forschung\dfg\studie3\studie3a\data\dfg_as_study3a_phase1.sav".


** De-Identification for the version puplished on OSF.
*Several ages occurred only once. --> form groups.
RECODE age (lowest thru 21 = 1) (22 thru 25 = 2) (26 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES age.

*delete variables containing distinct education profiles, fields of study and migration background.
DELETE VARIABLES bildungother fach migration2 religionother.
*these variables contain individual text participants wrote about what they thought the study was about and about their impression of the target person.
DELETE VARIABLES suspicion1 suspicion2 suspicion3 suspicion4 suspicion5 suspicion6 mc_open nachbefragung1 nachbefragung2.

save outfile "D:\Uni\Forschung\dfg\studie3\studie3a\data\dfg_as_study3a_phase1_OSF.sav".





*************************************************************************************************.
* 3) Analyses of Phase 1
* note that our primary analysis is the analysis of warmth ratings of the classification images (see data and syntax files for phase2).
*************************************************************************************************.
get file "D:\Uni\Forschung\dfg\studie3\studie3a\data\dfg_as_study3a_phase1_OSF.sav".

*secondary analyses - exploration (primary analyses - see phase2).

* 2x2 ANOVA for antisemitism.
UNIANOVA as BY uv_jew uv_hol
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(uv_hol*uv_jew)
  /EMMEANS=TABLES(uv_jew) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(uv_hol) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(uv_jew*uv_hol) 
  /PRINT=OPOWER ETASQ
  /CRITERIA=ALPHA(.05)
  /DESIGN=uv_jew uv_hol uv_jew*uv_hol.

* 2x2 ANOVA for explicit warmth ratings of target person.
UNIANOVA expl_warmth BY uv_jew uv_hol
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(uv_hol*uv_jew)
  /EMMEANS=TABLES(uv_jew) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(uv_hol) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(uv_jew*uv_hol) 
  /PRINT=OPOWER ETASQ
  /CRITERIA=ALPHA(.05)
  /DESIGN=uv_jew uv_hol uv_jew*uv_hol.









*************************************************************************************************.
* 4) Preprocess raw data from Inquisit for use in Reverse Correlation (Documentation).
*************************************************************************************************.


** import raw data from inquisit (phase 1 of the study).
GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie3\studie3a\data\all_18062013.dat"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS="\t"
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  date F6.0
  time A8
  subject F3.0
  values.group F1.0
  blockcode A13
  blocknum F1.0
  trialcode A18
  trialnum F3.0
  response F8.0
  correct F1.0
  latency F8.0
  stimulusnumber1 F3.0
  stimulusitem1 A54
  stimulusnumber2 F3.0
  stimulusitem2 A53
  stimulusnumber3 F3.0
  stimulusitem3 A46.
CACHE.
EXECUTE.
DATASET NAME DatenSet1 WINDOW=FRONT.

sort cases by subject.

FREQUENCIES subject.

CROSSTABS time by subject.

*same exclusion and recoding of trials as above (see section 1).
if subject = 1 and time = "10:03:57" subject = 101.
if subject = 1 and time = "10:12:39" subject = 201.
if subject = 1 and time = "10:21:08" subject = 301.
if subject = 2 and time = "10:24:30" subject = 102.
if subject = 3 and time = "10:16:10" subject = 999.
if subject = 4 and time = "10:37:50" subject = 104.
if subject = 4 and time = "10:48:15" subject = 204.
if subject = 4 and time = "12:04:43" subject = 304.
if subject = 5 subject = 999.
if subject = 6 and time = "10:19:16" subject = 999.
if subject = 6 and time = "10:57:04" subject = 106.
if subject = 7 and time = "10:45:23" subject = 999.
if subject = 8 and time = "11:35:26" subject = 108.
if subject = 9 and time = "11:54:13" subject = 109.
if subject = 10 and time = "11:55:10" subject = 110.
if subject = 11 and time = "11:56:22" subject = 111.
if subject = 12 and time = "11:59:48" subject = 112.
if subject = 13 and time = "11:20:54" subject = 113.
if subject = 13 and time = "12:44:42" subject = 213.
if subject = 14 and time = "11:46:02" subject = 114.
if subject = 14 and time = "12:56:56" subject = 214.
if subject = 15 and time = "13:01:55" subject = 115.
if subject = 16 and time = "13:07:33" subject = 116.
if subject = 16 and time = "13:15:37" subject = 216.
if subject = 17 and time = "13:17:41" subject = 117.
if subject = 20 and time = "14:13:30" subject = 220.
if subject = 52 and time = "12:57:31" subject = 53.
if subject = 61 and time = "09:32:51" subject = 999.
if subject = 72 and time = "11:17:35" subject = 172.

select if subject < 800.
exe.


* select Reverse Correlation Image Classification trials.
select if trialcode = "binary_face_davids".
exe.

*** recode stimulusnumber to match number of the pictures used.
compute stimulusnumber2 = stimulusnumber2 + 1.
recode stimulusnumber2 (401=1).
exe.

*** exclude subjects who did not remember correctly that the target person was Jewish [vs. Christian] .
* or that he was volunteering in an organization that supports Holocaust survivors [vs. an organization working to protect forests] or both.
* (keep only subjects that meet mc_jew = 1 and mc_hol = 1 in dfg_as_study3a_phase1.sav).
select if subject NE 10 and subject NE 42 and subject NE 45 and subject NE 55 and subject NE 220 and subject NE 52
 and subject NE 54 and subject NE 81 and subject NE 3 and subject NE 6 and subject NE 12 and subject NE 1 and subject NE 4
 and subject NE 9 and subject NE 33 and subject NE 47 and subject NE 65.
exe.


save outfile = "D:\Uni\Forschung\dfg\studie3\studie3a\data\dfg_as_study3a_RC_OSF.sav".
