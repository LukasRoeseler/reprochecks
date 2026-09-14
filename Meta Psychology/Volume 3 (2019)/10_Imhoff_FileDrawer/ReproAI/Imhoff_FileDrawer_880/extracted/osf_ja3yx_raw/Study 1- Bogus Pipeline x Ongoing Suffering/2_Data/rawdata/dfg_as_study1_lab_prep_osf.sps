* Encoding: UTF-8.
*** this syntax file documents how posttest data (lab study) from study1 was processed.
*** Raw data comes from Millisecond Inquisit.
*** this file is only for documentation, because participant codes
*** which are used to match data with pretest data are deleted for de-identification.

GET DATA  /TYPE=TXT
  /FILE="D:\Uni\Forschung\dfg\studie1\daten\labor\dfg_as_study1_lab_raw.dat"
  /ENCODING='UTF8'
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
  blockcode A11
  blocknum F3.0
  trialcode A18
  trialnum F3.0
  response A32
  correct F1.0
  latency F8.0
  stimulusnumber1 F2.0
  stimulusitem1 A590
  stimulusnumber2 F1.0
  stimulusitem2 A51
  stimulusnumber3 F1.0
  stimulusitem3 A20
  sdlatency A18
  percentcorrect F3.0
  meanlatency A18.
CACHE.
EXECUTE.
DATASET NAME DatenSet1 WINDOW=FRONT.

FREQUENCIES subject.

** recode double IDs (some IDs were given twice by the experimenter - recode to get unique IDs).
if subject = 26 and time = "11:38:35" subject = 27.
if subject = 26 and time = "12:06:47" subject = 28.

** exclude experimenter test trials.
select if subject LT 100.
exe.

** manually correct codes for 4 ps using the codes noted by the experimenter, see codes.txt.
** no matching pretest data for subject 67 -> exclude below.
** NOTE: codes are deleted for the version published on OSF!.
*do if trialcode = "code1" and correct = 1.
*   if subject = 51 response = "deleted".
*   if subject = 54 response = "deleted".
*   if subject = 78 response = "deleted".
*   if subject = 79 response = "deleted".
*end if.

exe.


recode response (convert) into response2.
exe.

do if trialcode = "code1" and correct = 1.
   string code(A8).
   compute code = upcase(response). 
else if trialcode = "age".
   compute age = response2.
else if trialcode = "sex".
   compute sex = response2.
end if.
exe.


do if trialcode = "ipanat1".
   vector ipanat1_(12).
   compute ipanat1_(stimulusnumber1) = response2.
else if trialcode = "ipanat2".
   vector ipanat2_(12).
   compute ipanat2_(stimulusnumber1) = response2.
else if trialcode = "ipanat3".
   vector ipanat3_(12).
   compute ipanat3_(stimulusnumber1) = response2.
else if trialcode = "ipanat4".
   vector ipanat4_(12).
   compute ipanat4_(stimulusnumber1) = response2.
else if trialcode = "ipanat5".
   vector ipanat5_(12).
   compute ipanat5_(stimulusnumber1) = response2.
else if trialcode = "ipanat6".
   vector ipanat6_(12).
   compute ipanat6_(stimulusnumber1) = response2.
end if.
exe.


do if trialcode = "gefühlsfb".
   vector expl_affect_(12).
   compute expl_affect_(stimulusnumber1) = response2.
else if trialcode = "frabo".
   vector as_(49).
   compute as_(stimulusnumber1) = response2.
else if trialcode = "mc1" or trialcode = "mc2".
   compute mc = correct.
end if.
exe.



AGGREGATE outfile = "D:\Uni\Forschung\dfg\studie1\daten\labor\dfg_as_study1_lab_agg.sav"
   /BREAK = subject
   /group = mean(variables.currentgroupnumber)
   /code = max(code)
   /age = mean(age)
   /sex = mean(sex)
   /date = mean(date)
   /ipanat1_1 to ipanat1_12 = mean(ipanat1_1 to ipanat1_12)
   /ipanat2_1 to ipanat2_12 = mean(ipanat2_1 to ipanat2_12)
   /ipanat3_1 to ipanat3_12 = mean(ipanat3_1 to ipanat3_12)
   /ipanat4_1 to ipanat4_12 = mean(ipanat4_1 to ipanat4_12)
   /ipanat5_1 to ipanat5_12 = mean(ipanat5_1 to ipanat5_12)
   /ipanat6_1 to ipanat6_12 = mean(ipanat6_1 to ipanat6_12)
   /expl_affect_1 to expl_affect_12 = mean(expl_affect_1 to expl_affect_12)
   /as_1 to as_49 = mean(as_1 to as_49)
   /mc = mean(mc).

get file = "D:\Uni\Forschung\dfg\studie1\daten\labor\dfg_as_study1_lab_agg.sav".

** match with file containing bogus pipeline condition which was recorded manually.
match files file = "D:\Uni\Forschung\dfg\studie1\daten\labor\bp.sav"
   /file = "D:\Uni\Forschung\dfg\studie1\daten\labor\dfg_as_study1_lab_agg.sav"
   /by subject.
exe.

var lab group "Priming".
val lab group 1 "ongoing consequences" 2 "no ongoing consequences".

CROSSTABS group by bp.

sort cases by code.

*exclude experimenter test trials (code = SCC) and 1 p because there was no matching pretest data for the participant code provided.
select if code NE "SCC".
exe.

save outfile = "D:\Uni\Forschung\dfg\studie1\daten\labor\dfg_as_study1_lab.sav".
