* Encoding: UTF-8.
*************************************************************************************************.
* SPSS syntax: Data preparation and analyses of Study 4a.
* Imhoff, R. & Messer, M. In search of experimental evidence for secondary antisemitism – a file drawer report.
* Written by Mario Messer, mario.messer@smail.uni-koeln.de.
*************************************************************************************************.

* Outline:
* 1) Compute questionnaire scores.
* 2) Analyses.
*************************************************************************************************.


*** Instruction for OSF: In order to run the analyses reported in our publication
*** open dfg_as_study4a_OSF.sav and run the code in the analyses section below.

get file "D:\Uni\Forschung\dfg\studie4\studie4a\dfg_as_study4a.sav".

*************************************************************************************************.
* 1) Compute questionnaire scores.
*************************************************************************************************.

* criticism of israel scale.
VARIABLE LABELS
as1 "Israel beginnt Kriege und gibt anderen die Schuld daran."
as2 "Die Selbstmordattentate der Palästinenser sind das richtige Mittel um Israel zu bekämpfen."
as3 "Es ist beeindruckend, wie es die Juden geschafft haben, trotz aller Probleme ihren Staat Israel aufzubauen und zu behaupten."
as4 "Ich glaube, dass die israelische Armee während ihrer Einsätze in den Palästinensergebieten absichtlich auf palästinensische Zivilisten abzielt."
as5 "Ich bin der Meinung, dass es gerechtfertigt ist, wenn palästinensische Selbstmordattentäter auf israelische Zivilisten abzielen."
as6 "Das Existenzrecht Israels ist für mich nicht diskutierbar und selbstverständlich."
as7 "Die Israelis sind Besatzer und haben in den Palästinensergebieten nichts zu suchen."
as8 "Es wäre besser, wenn die Juden den Nahen Osten verlassen würden."
as9 "Israel ist ein Staat, der über Leichen geht."
as10 "Israel allein ist schuldig an der Entstehung und Aufrechterhaltung der Konflikte im Nahen Osten."
as11 "Israel ist hauptverantwortlich für die Gewalt in Israel und den Palästinensergebieten."
as12 "Die israelische Behandlung der Palästinenser ähnelt der Behandlung der Schwarzen in Südafrika während der Apartheid."
as13 "Die Israelis sind an einer friedlichen Lösung des Nahost-Konflikts interessiert."
.


recode as3 as6 as13 (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1) into as3r as6r as13r.


RELIABILITY
  /VARIABLES=as1 as2 as4 as5 as7 as8 as9 as10 as11 as12 as3r as6r as13r
  /SCALE('criticism of israel') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


compute as = mean(as1, as2, as4, as5, as7, as8, as9, as10, as11, as12, as3r, as6r, as13r).
exe.

VARIABLE LABELS as "criticism of israel".


DESCRIPTIVES age.
FREQUENCIES sex age.

***** De-Identification for the version puplished on OSF.
*Several ages occurred only once. --> form groups.
RECODE age (lowest thru 24 = 1) (25 thru 38 = 2) (39 thru highest = 3) into age_groups.
EXECUTE .
VALUE LABELS age_groups 1 'bottom third' 2 'middle third' 3 'upper third' .
DELETE VARIABLES age.

*************************************************************************************************.
* 2) Analyses.
*************************************************************************************************.

* criticism of israel scores - independent samples t-test.
T-TEST GROUPS=condition(1 0)
  /MISSING=ANALYSIS
  /VARIABLES=as
  /CRITERIA=CI(.95).


* check result when excluding ps who failed attention check.

FREQUENCIES instruct.
filter by instruct.
T-TEST GROUPS=condition(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=as
  /CRITERIA=CI(.95).
filter off.

save outfile "D:\Uni\Forschung\dfg\studie4\studie4a\dfg_as_study4a_OSF.sav".
