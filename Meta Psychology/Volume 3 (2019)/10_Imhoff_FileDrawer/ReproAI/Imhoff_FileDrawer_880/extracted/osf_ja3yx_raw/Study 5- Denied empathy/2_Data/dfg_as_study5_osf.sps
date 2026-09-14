* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 5.
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Preprocess raw data from Inquisit
* 2) Compute questionnaire scores.
* 3) Analyses.

*************************************************************************************************.


*** Instruction for OSF: In order to run the analyses reported in our publication
*** open dfg_as_study5_OSF.sav and run the code in the analyses section below.


*************************************************************************************************.
* 1) Preprocess raw data from Inquisit (Documentation)
* this section documents how raw data from inquisit was processed. 
*************************************************************************************************.

* import raw data from inquisit.

GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie5\data\raw\sek_as_isr3_emp_all.dat"
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
  blocknum F1.0
  trialcode A16
  trialnum F2.0
  response A24
  correct F1.0
  latency F7.0
  stimulusnumber1 F2.0
  stimulusitem1 A254
  stimulusnumber2 F1.0
  stimulusitem2 A88
  stimulusnumber3 F2.0
  stimulusitem3 A20.
CACHE.
EXECUTE.
DATASET NAME DataSet3 WINDOW=FRONT.


FREQUENCIES subject.
sort cases by subject.

* exclude ps who dropped out during the study.
if subject = 17 subject = 999.
if subject = 53 subject = 999.
exe.

* exclude ps above and test runs by the experimenter.
select if subject NE 999.
exe.

*copy response variable in numeric format.
recode response (convert) into response2.
exe.

***construct variables.

* demographics.
if trialcode = "age" age = response2.
if trialcode = "sex" sex = response2.
if trialcode = "bildung" bildung = response2.
string bildungother(A32).
if trialcode = "bildungother" bildungother = response.
string fach(A32).
if trialcode = "fach" fach = response.
if trialcode = "citizen" citizen = response2.
if trialcode = "migr" migr = response2.
string migrother(A32).
if trialcode = "migrother" migrother = response.
exe.

* items on reactions to videos including the empathy items and national identification items.
do if trialcode = "raketen_items".
   vector empathy_(26).
   compute empathy_(stimulusnumber3) = response2.
else if trialcode = "sozialdemo_items".
   vector support_(6).
   compute support_(stimulusnumber2) = response2.
else if trialcode = "ni".
   vector ni_(16).
   compute ni_(stimulusnumber1) = response2.
end if.

*aggregate file to get 1 line per subject.
AGGREGATE outfile = "D:\Uni\Forschung\dfg\studie5\data\dfg_as_study5.sav"
/BREAK = subject
/age = mean(age)
/sex = mean(sex)
/bildung = mean(bildung)
/bildungother = max(bildungother)
/fach = max(fach)
/citizen = mean(citizen)
/migr = mean(migr)
/migrother = max(migrother)
/empathy_1 to empathy_26 = mean(empathy_1 to empathy_26)
/support_1 to support_6 = mean(support_1 to support_6)
/ni_1 to ni_16 = mean(ni_1 to ni_16).

* open donation data which were recorded separately in an online survey.
get file "D:\Uni\Forschung\dfg\studie5\data\dfg_as_study5_donations.sav".
* REF contains subject ID from inquisit. rename to match with inquisit data.
RENAME VARIABLES (REF = subject).
ALTER TYPE subject (F8.0).

select if subject NE 999.
exe.
sort cases by subject.

* match donation answers with rest of data that was recorded with inquisit.
MATCH FILES file = *
   /file = "D:\Uni\Forschung\dfg\studie5\data\dfg_as_study5.sav"
   /by subject.
exe.

* compute condition variable. experimental conditions were defined by subject ID (odd and even numbers).
compute group = mod(subject, 2).
exe.

VALUE LABELS group 1 "holocaust reminder" 0 "control".

VARIABLE LABELS
empathy_1	 "mitfühlend"
empathy_2	 "warmherzig"
empathy_3	 "Anteil nehmend"
empathy_4	 "weichherzig"
empathy_5	 "zärtlich"
empathy_6	 "ergriffen"
empathy_7	 "aufgeschreckt"
empathy_8	 "betrübt"
empathy_9	 "aufgewühlt"
empathy_10	 "bekümmert"
empathy_11	 "bestürzt"
empathy_12	 "beunruhigt"
empathy_13	 "besorgt"
empathy_14	 "verstört"
empathy_15	 "aktiv"
empathy_16	 "interessiert"
empathy_17	 "entschlossen"
empathy_18	 "stark"
empathy_19	 "angeregt"
empathy_20	 "stolz"
empathy_21	 "durcheinander"
empathy_22	 "ängstlich"
empathy_23	 "verärgert"
empathy_24	 "schuldig"
empathy_25	 "feindselig"
empathy_26	 "beschämt"
support_1	 "Die soziale Ungleichheit in Israel ist vergleichbar mit der in anderen Industriestaaten."
support_2	 "Ich kann mich gut mit dem Anliegen der Demonstranten identifizieren."
support_3	 "Die im Beitrag gezeigte Protestform ist unangemessen."
support_4	 "Ich teile den Ärger der Menschen über hohe Wohnungspreise."
support_5	 "Die Forderungen der Demonstranten kommen mir übertrieben vor."
support_6	 "Ich bin beunruhigt über die schwierige soziale Lage, die im Beitrag gezeigt wurde."
ni_1	 "Ich liebe Deutschland."
ni_2	 "Andere Nationen können eine Menge von uns lernen."
ni_3	 "Deutsch zu sein ist ein wichtiger Teil meiner Identität."
ni_4	 "Wenn man in der heutigen Welt wissen will, was zu tun ist, dann muss man auf unsere nationalen Autoritäten hören."
ni_5	 "Es ist mir wichtig für meine Nation einen eigenen Beitrag zu leisten."
ni_6	 "Die Bundeswehr ist die beste Armee der Welt."
ni_7	 "Es ist mir wichtig, mich als Deutsche(r) zu sehen."
ni_8	 "Eines der wichtigsten Dinge, die Kinder lernen müssen, ist der Respekt vor unseren nationalen Autoritäten."
ni_9	 "Ich stehe voll hinter meiner Nation."
ni_10	 "Verglichen mit anderen Nationen ist Deutschland eine sehr moralische Nation."
ni_11	 "Es ist mir wichtig, dass jeder mich als Deutsche(r) sieht."
ni_12	 "Es ist illoyal, wenn Deutsche Deutschland kritisieren."
ni_13	 "Es ist mir wichtig, meinem Land zu dienen."
ni_14	 "Deutschland ist in jeder Hinsicht besser, als andere Nationen."
ni_15	 "Wenn ich über Deutsche rede, sage ich für gewöhnlich 'wir' statt 'sie'."
ni_16	 "Es gibt gute Gründe für jedes Gesetz und jede Regelung, die von unseren nationalen Autoritäten gemacht wurden."
DO07_01 "donation pledge to Keren Hayesod (max. 50 EUR)"
bildung "education"
citizen "citizenship"
migr "migration background".

VALUE LABELS bildung 1 "Hauptschule" 2 "Realschule" 3 "Gymnasium" 4 "Universität" 0 "keiner" 9 "other".
VALUE LABELS citizen 1 "German" 2 "other".
VALUE LABELS migr 0 "no migration background" 1 "Eastern Europe" 2 "Turkey" 3 "Arab States" 9 "other".
VALUE LABELS sex 1 "female" 2 "male".

FREQUENCIES sex age.
DESCRIPTIVES age.



***** De-Identification for the version puplished on OSF.
*delete date and time of participation.
DELETE VARIABLES STARTED LASTDATA.

* delete openended response about purpose of study (suspicion check).
DELETE VARIABLES SU01_01.


*delete variables containing distinct education profiles, fields of study and details about migration background.
DELETE VARIABLES bildungother fach migrother.

*Several ages occurred only once. --> form groups.
RECODE age (lowest thru 20 = 1) (21 thru 23 = 2) (24 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES age.


*************************************************************************************************.
* 2) Compute Questionnaire scores.
*************************************************************************************************.

RELIABILITY
  /VARIABLES=empathy_1 empathy_2 empathy_3 empathy_4 empathy_5 empathy_6
  /SCALE('empathy') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute empathy = mean(empathy_1, empathy_2, empathy_3, empathy_4, empathy_5, empathy_6).
exe.


RELIABILITY
  /VARIABLES=empathy_7 empathy_8 empathy_9 empathy_10 empathy_11 empathy_12 empathy_13 empathy_14
  /SCALE('distress') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute distress = mean(empathy_7, empathy_8, empathy_9, empathy_10, empathy_11, empathy_12, empathy_13, empathy_14).
exe.

* national identification scales.
RELIABILITY
  /VARIABLES=ni_1 ni_3 ni_5 ni_7 ni_9 ni_11 ni_13 ni_15
  /SCALE('ni_attachment') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

RELIABILITY
  /VARIABLES=ni_2 ni_4 ni_6 ni_8 ni_10 ni_12 ni_14 ni_16
  /SCALE('ni_glorification') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

compute ni_a = mean(ni_1, ni_3, ni_5, ni_7, ni_9, ni_11, ni_13, ni_15).
compute ni_g = mean(ni_2, ni_4, ni_6, ni_8, ni_10, ni_12, ni_14, ni_16).
exe.

VARIABLE LABELS ni_a "national attachment" ni_g "national glorification".




*************************************************************************************************.
* Analyses.
*************************************************************************************************.

T-TEST GROUPS=group(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=empathy DO07_01
  /CRITERIA=CI(.95).


* Moderation analysis: national glorification.
* save standardized variables.
DESCRIPTIVES VARIABLES=DO07_01 empathy ni_a ni_g
  /SAVE
  /STATISTICS=MEAN STDDEV MIN MAX.

* effect coded group variable (Holocaust = 1; control = -1).
recode group (0=-1) (1=1) into Zgroup.
exe.

* product terms representing all possible two-way and three-way interactions.
compute grnia = Zgroup*Zni_a.
compute grnig = Zgroup*Zni_g.
compute niag = Zni_a*Zni_g.
compute grniag = Zgroup*Zni_a*Zni_g.
exe.


* hierarchical multiple regression analysis.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Zempathy
  /METHOD=ENTER Zgroup Zni_a Zni_g
  /METHOD=ENTER grnia grnig niag
  /METHOD=ENTER grniag.



save outfile = "D:\Uni\Forschung\dfg\studie5\data\dfg_as_study5_OSF.sav".
