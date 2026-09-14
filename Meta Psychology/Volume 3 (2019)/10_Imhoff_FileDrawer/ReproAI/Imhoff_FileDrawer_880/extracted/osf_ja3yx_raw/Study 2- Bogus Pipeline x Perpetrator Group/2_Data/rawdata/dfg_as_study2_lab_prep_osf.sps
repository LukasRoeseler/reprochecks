* Encoding: UTF-8.
*** this syntax file documents how posttest data (lab study) from study2 was processed.
*** Raw data comes from Millisecond Inquisit.
*** this file is only for documentation, because participant codes
*** which are used to match data with pretest data are deleted for de-identification.

GET DATA  /TYPE=TXT
  /FILE="D:\Studien\Antisemitismus\DFG_Studien\studie2\data\t2\inquisit\dfg_as_study2_lab_raw.dat"
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
  blockcode A16
  blocknum F2.0
  trialcode A22
  trialnum F3.0
  response A512
  correct F1.0
  latency F8.0
  stimulusnumber1 F3.0
  stimulusitem1 A590
  stimulusnumber2 F3.0
  stimulusitem2 A182
  stimulusnumber3 F3.0
  stimulusitem3 A51
  sdlatency A18
  percentcorrect F3.0
  meanlatency A18
  picture.itb_pics.currentitemnumber F3.0
  picture.itb_pics.selectedvalue F3.0.
CACHE.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.


sort cases by subject.
FREQUENCIES subject.

CROSSTABS subject by blockcode.

sort cases by date.

** recode double IDs (some IDs were given twice by the experimenter - recode to get unique IDs).
if subject = 206 and time = "13:34:23" subject = 1206.

** exclude experimenter test trials.
select if subject NE 999.
exe.

*** dataprep.

recode response (convert) into response2.
exe.

string code(A8).
if trialcode = "code1" and correct = 1 code = response.
exe.

if trialcode = "age" age = response2.
if trialcode = "sex" sex = response2.



*** ITB. latency based measure of prejudice.
**exclude RTs GE mean+/-2SD; natural log(RT) (vala2012). 
sort cases by subject blockcode.
split file by subject blockcode.
DESCRIPTIVES latency /save.
split file off.

do if blockcode = "itb".
   if zlatency GE 2 or zlatency LE -2 latency = $sysmis.
end if.
exe.

compute loglatency = ln(latency).
exe.

do if blockcode = "itb".
do if stimulusnumber2 = 1.
   vector itb1_(8).
   compute itb1_(stimulusnumber3) = latency.
else if stimulusnumber2 = 2.
   vector itb2_(8).
   compute itb2_(stimulusnumber3) = latency.
else if stimulusnumber2 = 3.
   vector itb3_(8).
   compute itb3_(stimulusnumber3) = latency.
else if stimulusnumber2 = 4.
   vector itb4_(8).
   compute itb4_(stimulusnumber3) = latency.
else if stimulusnumber2 = 5.
   vector itb5_(8).
   compute itb5_(stimulusnumber3) = latency.
else if stimulusnumber2 = 6.
   vector itb6_(8).
   compute itb6_(stimulusnumber3) = latency.
end if.
end if.
exe.

do if blockcode = "itb".
do if stimulusnumber2 = 1.
   vector logitb1_(8).
   compute logitb1_(stimulusnumber3) = loglatency.
else if stimulusnumber2 = 2.
   vector logitb2_(8).
   compute logitb2_(stimulusnumber3) = loglatency.
else if stimulusnumber2 = 3.
   vector logitb3_(8).
   compute logitb3_(stimulusnumber3) = loglatency.
else if stimulusnumber2 = 4.
   vector logitb4_(8).
   compute logitb4_(stimulusnumber3) = loglatency.
else if stimulusnumber2 = 5.
   vector logitb5_(8).
   compute logitb5_(stimulusnumber3) = loglatency.
else if stimulusnumber2 = 6.
   vector logitb6_(8).
   compute logitb6_(stimulusnumber3) = loglatency.
end if.
end if.
exe.


*** anti-semitism bzw. prejudice against chinese.
do if trialcode = "v_jew" or trialcode = "v_chin".
   vector prejudice_(21).
   compute prejudice_(stimulusnumber1) = response2.
end if.
exe.



*** MC & suspicion probe.

if trialcode = "mc_a" mc_a = correct.
if trialcode = "mc_b1" or trialcode = "mc_b2" mc_b = correct.

string suspicion1(A512) suspicion2(A512) comment(A512).
if trialcode = "suspicion1" suspicion1 = response.
if trialcode = "suspicion2" suspicion2 = response.
if trialcode = "comment" comment = response.
exe.



AGGREGATE outfile = "D:\Studien\Antisemitismus\DFG_Studien\studie2\data\t2\inquisit\dfg_as_study2_lab_agg.sav"
   /break= subject
   /group = mean(variables.currentgroupnumber)
   /CODE suspicion1 suspicion2 comment = max(code suspicion1 suspicion2 comment)
   /age sex mc_a mc_b = mean(age sex mc_a mc_b)
   /itb1_1 to itb1_8 = mean(itb1_1 to itb1_8)
   /itb2_1 to itb2_8 = mean(itb2_1 to itb2_8)
   /itb3_1 to itb3_8 = mean(itb3_1 to itb3_8)
   /itb4_1 to itb4_8 = mean(itb4_1 to itb4_8)
   /itb5_1 to itb5_8 = mean(itb5_1 to itb5_8)
   /itb6_1 to itb6_8 = mean(itb6_1 to itb6_8)
   /logitb1_1 to logitb1_8 = mean(logitb1_1 to logitb1_8)
   /logitb2_1 to logitb2_8 = mean(logitb2_1 to logitb2_8)
   /logitb3_1 to logitb3_8 = mean(logitb3_1 to logitb3_8)
   /logitb4_1 to logitb4_8 = mean(logitb4_1 to logitb4_8)
   /logitb5_1 to logitb5_8 = mean(logitb5_1 to logitb5_8)
   /logitb6_1 to logitb6_8 = mean(logitb6_1 to logitb6_8)
   /prejudice_1 to prejudice_21 = mean(prejudice_1 to prejudice_21).

get file "D:\Studien\Antisemitismus\DFG_Studien\studie2\data\t2\inquisit\dfg_as_study2_lab_agg.sav".
   
recode group (1=1) (2=1) (3=2) (4=2) into prime.
recode group (1=1) (2=2) (3=1) (4=2) into itb_cond.
compute bp = 0.
if subject LT 200 bp = 1.
exe.

VALUE LABELS prime 1 "jewish victims" 2 "chinese victims"
   /itb_cond 1 "pics A" 2 "pics B"
   /bp 0 "control" 1 "bp"
   /sex 1 "male" 2 "female".

FREQUENCIES prime itb_cond bp.
CROSSTABS prime by bp.


FREQUENCIES code.
FREQUENCIES mc_a mc_b.


** manually correct codes for 9 ps using the codes noted by the experimenter, see code-zuordnungen.txt.
** NOTE: codes are deleted for the version published on OSF!.
*if subject = 164 CODE = "deleted".
*if subject = 115 CODE = "deleted".
*if subject = 282 CODE = "deleted".
*if subject = 173 CODE = "deleted".
*if subject = 279 CODE = "deleted".
*if subject = 256 CODE = "deleted".
*if subject = 212 CODE = "deleted".
*if subject = 205 CODE = "deleted".
*if subject = 203 CODE = "deleted".
*exe.


string code_r(A8).
compute code_r = upcase(CODE).
sort cases by code_r.


*** ITB.
*** itb1 & 2 = chinese; 3 & 4 = israeli; 5 & 6 = german.
*** traits: 1-4 = positive; 5-8=negative.

compute itb_c_pos = mean(itb1_1 to itb1_4, itb2_1 to itb2_4).
compute itb_c_neg = mean(itb1_5 to itb1_8, itb2_5 to itb2_8).
compute itb_i_pos = mean(itb3_1 to itb3_4, itb4_1 to itb4_4).
compute itb_i_neg = mean(itb3_5 to itb3_8, itb4_5 to itb4_8).
compute itb_g_pos = mean(itb5_1 to itb5_4, itb6_1 to itb6_4).
compute itb_g_neg = mean(itb5_5 to itb5_8, itb6_5 to itb6_8).

compute itb_c = mean(itb_c_pos, itb_c_neg).
compute itb_i = mean(itb_i_pos, itb_i_neg).
compute itb_g = mean(itb_g_pos, itb_g_neg).
exe.

*** ln transformed for analyses.
compute logitb_c_pos = mean(logitb1_1 to logitb1_4, logitb2_1 to logitb2_4).
compute logitb_c_neg = mean(logitb1_5 to logitb1_8, logitb2_5 to logitb2_8).
compute logitb_i_pos = mean(logitb3_1 to logitb3_4, logitb4_1 to logitb4_4).
compute logitb_i_neg = mean(logitb3_5 to logitb3_8, logitb4_5 to logitb4_8).
compute logitb_g_pos = mean(logitb5_1 to logitb5_4, logitb6_1 to logitb6_4).
compute logitb_g_neg = mean(logitb5_5 to logitb5_8, logitb6_5 to logitb6_8).

compute logitb_c = mean(logitb_c_pos, logitb_c_neg).
compute logitb_i = mean(logitb_i_pos, logitb_i_neg).
compute logitb_g = mean(logitb_g_pos, logitb_g_neg).
exe.

*diff scores.
compute logitb_c_diff = logitb_g-logitb_c.
compute logitb_i_diff = logitb_g-logitb_i.
exe.


save outfile = "D:\Studien\Antisemitismus\DFG_Studien\studie2\data\t2\inquisit\dfg_as_study2_lab.sav".


