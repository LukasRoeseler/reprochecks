* Encoding: windows-1252.


*12 measurement occasions, sphericity holds*

*n=15*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help15=(help15 < 5001).
VARIABLE LABELS filter_help15 'help15 < 5001 (FILTER)'.
VALUE LABELS filter_help15 0 'Not Selected' 1 'Selected'.
FORMATS filter_help15 (f1.0).
FILTER BY filter_help15.
EXECUTE.

SORT CASES  BY help15.
SPLIT FILE SEPARATE BY help15.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity\15\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity\15\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity\15\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_se_1 AV_se_2 AV_se_3 AV_se_4 AV_se_5 AV_se_6 AV_se_7 AV_se_8 AV_se_9 AV_se_10 AV_se_11 AV_se_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity\15\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity\15\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity\15\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity\15\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\15\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\15\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.

get file='C:\sphericity\15\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\15\12\ANOVA.sav'
  /COMPRESSED.


get file='C:\sphericity\15\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity\15\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity\15\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity\15\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity\15\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity\15\12\sphericity_final.sav'
  /COMPRESSED.

*MLM CS

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help15=(help15 < 5001).
VARIABLE LABELS filter_help15 'help15 < 5001 (FILTER)'.
VALUE LABELS filter_help15 0 'Not Selected' 1 'Selected'.
FORMATS filter_help15 (f1.0).
FILTER BY filter_help15.
EXECUTE.

SORT CASES  BY help15.
SPLIT FILE SEPARATE BY help15.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity\15\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\15\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity\15\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\15\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity\15\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\15\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help15=(help15 < 5001).
VARIABLE LABELS filter_help15 'help15 < 5001 (FILTER)'.
VALUE LABELS filter_help15 0 'Not Selected' 1 'Selected'.
FORMATS filter_help15 (f1.0).
FILTER BY filter_help15.
EXECUTE.

SORT CASES  BY help15.
SPLIT FILE SEPARATE BY help15.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity\15\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\15\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.



get file='C:\sphericity\15\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\15\12\MLM_UN.sav'
  /COMPRESSED.



get file='C:\sphericity\15\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\15\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\MLM_UN.sav'
  /COMPRESSED.


*Zusammenfügen...

DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\15\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\15\12\sphericity_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity\15\12\final_15_n_sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\15\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\final_15_n_sphericity_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity\15\12\final_15_n_sphericity_12.sav'
  /COMPRESSED.


*n=20*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help20=(help20 < 5001).
VARIABLE LABELS filter_help20 'help20 < 5001 (FILTER)'.
VALUE LABELS filter_help20 0 'Not Selected' 1 'Selected'.
FORMATS filter_help20 (f1.0).
FILTER BY filter_help20.
EXECUTE.

SORT CASES  BY help20.
SPLIT FILE SEPARATE BY help20.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity\20\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity\20\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity\20\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_se_1 AV_se_2 AV_se_3 AV_se_4 AV_se_5 AV_se_6 AV_se_7 AV_se_8 AV_se_9 AV_se_10 AV_se_11 AV_se_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity\20\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity\20\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity\20\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity\20\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\20\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\20\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.


get file='C:\sphericity\20\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\20\12\ANOVA.sav'
  /COMPRESSED.


get file='C:\sphericity\20\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity\20\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity\20\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity\20\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity\20\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity\20\12\sphericity_final.sav'
  /COMPRESSED.


*MLM CS

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help20=(help20 < 5001).
VARIABLE LABELS filter_help20 'help20 < 5001 (FILTER)'.
VALUE LABELS filter_help20 0 'Not Selected' 1 'Selected'.
FORMATS filter_help20 (f1.0).
FILTER BY filter_help20.
EXECUTE.

SORT CASES  BY help20.
SPLIT FILE SEPARATE BY help20.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity\20\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\20\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity\20\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\20\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity\20\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\20\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help20=(help20 < 5001).
VARIABLE LABELS filter_help20 'help20 < 5001 (FILTER)'.
VALUE LABELS filter_help20 0 'Not Selected' 1 'Selected'.
FORMATS filter_help20 (f1.0).
FILTER BY filter_help20.
EXECUTE.

SORT CASES  BY help20.
SPLIT FILE SEPARATE BY help20.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity\20\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\20\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.


get file='C:\sphericity\20\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\20\12\MLM_UN.sav'
  /COMPRESSED.



get file='C:\sphericity\20\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\20\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\MLM_UN.sav'
  /COMPRESSED.


DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\20\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\20\12\sphericity_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity\20\12\final_20_n_sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\20\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\final_20_n_sphericity_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity\20\12\final_20_n_sphericity_12.sav'
  /COMPRESSED.



*n=25*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help25=(help25 < 5001).
VARIABLE LABELS filter_help25 'help25 < 5001 (FILTER)'.
VALUE LABELS filter_help25 0 'Not Selected' 1 'Selected'.
FORMATS filter_help25 (f1.0).
FILTER BY filter_help25.
EXECUTE.

SORT CASES  BY help25.
SPLIT FILE SEPARATE BY help25.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity\25\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity\25\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity\25\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_se_1 AV_se_2 AV_se_3 AV_se_4 AV_se_5 AV_se_6 AV_se_7 AV_se_8 AV_se_9 AV_se_10 AV_se_11 AV_se_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity\25\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity\25\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity\25\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity\25\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\25\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\25\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.


get file='C:\sphericity\25\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\25\12\ANOVA.sav'
  /COMPRESSED.


get file='C:\sphericity\25\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity\25\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity\25\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity\25\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity\25\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity\25\12\sphericity_final.sav'
  /COMPRESSED.


*MLM CS

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help25=(help25 < 5001).
VARIABLE LABELS filter_help25 'help25 < 5001 (FILTER)'.
VALUE LABELS filter_help25 0 'Not Selected' 1 'Selected'.
FORMATS filter_help25 (f1.0).
FILTER BY filter_help25.
EXECUTE.

SORT CASES  BY help25.
SPLIT FILE SEPARATE BY help25.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity\25\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\25\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity\25\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\25\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity\25\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\25\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help25=(help25 < 5001).
VARIABLE LABELS filter_help25 'help25 < 5001 (FILTER)'.
VALUE LABELS filter_help25 0 'Not Selected' 1 'Selected'.
FORMATS filter_help25 (f1.0).
FILTER BY filter_help25.
EXECUTE.

SORT CASES  BY help25.
SPLIT FILE SEPARATE BY help25.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity\25\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\25\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.


get file='C:\sphericity\25\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\25\12\MLM_UN.sav'
  /COMPRESSED.



get file='C:\sphericity\25\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\25\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\MLM_UN.sav'
  /COMPRESSED.

DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\25\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\25\12\sphericity_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity\25\12\final_25_n_sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\25\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\final_25_n_sphericity_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity\25\12\final_25_n_sphericity_12.sav'
  /COMPRESSED.



*n=30*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help30=(help30 < 5001).
VARIABLE LABELS filter_help30 'help30 < 5001 (FILTER)'.
VALUE LABELS filter_help30 0 'Not Selected' 1 'Selected'.
FORMATS filter_help30 (f1.0).
FILTER BY filter_help30.
EXECUTE.

SORT CASES  BY help30.
SPLIT FILE SEPARATE BY help30.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity\30\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity\30\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity\30\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_se_1 AV_se_2 AV_se_3 AV_se_4 AV_se_5 AV_se_6 AV_se_7 AV_se_8 AV_se_9 AV_se_10 AV_se_11 AV_se_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity\30\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity\30\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity\30\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity\30\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\30\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\30\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.


get file='C:\sphericity\30\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\30\12\ANOVA.sav'
  /COMPRESSED.

*MANOVA-Ergebnisse bearbeiten.

get file='C:\sphericity\30\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity\30\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity\30\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity\30\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity\30\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity\30\12\sphericity_final.sav'
  /COMPRESSED.


*MLM CS

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help30=(help30 < 5001).
VARIABLE LABELS filter_help30 'help30 < 5001 (FILTER)'.
VALUE LABELS filter_help30 0 'Not Selected' 1 'Selected'.
FORMATS filter_help30 (f1.0).
FILTER BY filter_help30.
EXECUTE.

SORT CASES  BY help30.
SPLIT FILE SEPARATE BY help30.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity\30\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\30\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity\30\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\30\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity\30\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\30\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_sphericity_12.sav".

USE ALL.
COMPUTE filter_help30=(help30 < 5001).
VARIABLE LABELS filter_help30 'help30 < 5001 (FILTER)'.
VALUE LABELS filter_help30 0 'Not Selected' 1 'Selected'.
FORMATS filter_help30 (f1.0).
FILTER BY filter_help30.
EXECUTE.

SORT CASES  BY help30.
SPLIT FILE SEPARATE BY help30.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity\30\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity\30\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_holds BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.


get file='C:\sphericity\30\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity\30\12\MLM_UN.sav'
  /COMPRESSED.

get file='C:\sphericity\30\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\30\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\MLM_UN.sav'
  /COMPRESSED.

DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\30\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\30\12\sphericity_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity\30\12\final_30_n_sphericity.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity\30\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\final_30_n_sphericity_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity\30\12\final_30_n_sphericity_12.sav'
  /COMPRESSED.




*12 measurement occasions, sphericity violation*

*n=15*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help15=(help15 < 5001).
VARIABLE LABELS filter_help15 'help15 < 5001 (FILTER)'.
VALUE LABELS filter_help15 0 'Not Selected' 1 'Selected'.
FORMATS filter_help15 (f1.0).
FILTER BY filter_help15.
EXECUTE.

SORT CASES  BY help15.
SPLIT FILE SEPARATE BY help15.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity_violation\15\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity_violation\15\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity_violation\15\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_sn_1 AV_sn_2 AV_sn_3 AV_sn_4 AV_sn_5 AV_sn_6 AV_sn_7 AV_sn_8 AV_sn_9 AV_sn_10 AV_sn_11 AV_sn_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity_violation\15\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity_violation\15\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity_violation\15\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity_violation\15\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\15\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\15\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.

get file='C:\sphericity_violation\15\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\15\12\ANOVA.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\15\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity_violation\15\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity_violation\15\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\15\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\15\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity_violation\15\12\violation_final.sav'
  /COMPRESSED.

*MLM CS

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help15=(help15 < 5001).
VARIABLE LABELS filter_help15 'help15 < 5001 (FILTER)'.
VALUE LABELS filter_help15 0 'Not Selected' 1 'Selected'.
FORMATS filter_help15 (f1.0).
FILTER BY filter_help15.
EXECUTE.

SORT CASES  BY help15.
SPLIT FILE SEPARATE BY help15.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity_violation\15\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\15\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity_violation\15\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\15\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\15\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\15\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help15=(help15 < 5001).
VARIABLE LABELS filter_help15 'help15 < 5001 (FILTER)'.
VALUE LABELS filter_help15 0 'Not Selected' 1 'Selected'.
FORMATS filter_help15 (f1.0).
FILTER BY filter_help15.
EXECUTE.

SORT CASES  BY help15.
SPLIT FILE SEPARATE BY help15.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity_violation\15\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\15\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.



get file='C:\sphericity_violation\15\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\15\12\MLM_UN.sav'
  /COMPRESSED.



get file='C:\sphericity_violation\15\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\15\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\MLM_UN.sav'
  /COMPRESSED.


*Zusammenfügen...

DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\15\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\15\12\violation_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity_violation\15\12\final_15_n_violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\15\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\final_15_n_violation_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\15\12\final_15_n_violation_12.sav'
  /COMPRESSED.


*n=20*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help20=(help20 < 5001).
VARIABLE LABELS filter_help20 'help20 < 5001 (FILTER)'.
VALUE LABELS filter_help20 0 'Not Selected' 1 'Selected'.
FORMATS filter_help20 (f1.0).
FILTER BY filter_help20.
EXECUTE.

SORT CASES  BY help20.
SPLIT FILE SEPARATE BY help20.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity_violation\20\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity_violation\20\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity_violation\20\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_sn_1 AV_sn_2 AV_sn_3 AV_sn_4 AV_sn_5 AV_sn_6 AV_sn_7 AV_sn_8 AV_sn_9 AV_sn_10 AV_sn_11 AV_sn_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity_violation\20\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity_violation\20\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity_violation\20\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity_violation\20\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\20\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\20\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\20\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\20\12\ANOVA.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\20\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity_violation\20\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity_violation\20\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\20\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\20\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity_violation\20\12\violation_final.sav'
  /COMPRESSED.


*MLM CS

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help20=(help20 < 5001).
VARIABLE LABELS filter_help20 'help20 < 5001 (FILTER)'.
VALUE LABELS filter_help20 0 'Not Selected' 1 'Selected'.
FORMATS filter_help20 (f1.0).
FILTER BY filter_help20.
EXECUTE.

SORT CASES  BY help20.
SPLIT FILE SEPARATE BY help20.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity_violation\20\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\20\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity_violation\20\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\20\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\20\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\20\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help20=(help20 < 5001).
VARIABLE LABELS filter_help20 'help20 < 5001 (FILTER)'.
VALUE LABELS filter_help20 0 'Not Selected' 1 'Selected'.
FORMATS filter_help20 (f1.0).
FILTER BY filter_help20.
EXECUTE.

SORT CASES  BY help20.
SPLIT FILE SEPARATE BY help20.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity_violation\20\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\20\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.


get file='C:\sphericity_violation\20\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\20\12\MLM_UN.sav'
  /COMPRESSED.



get file='C:\sphericity_violation\20\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\20\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\MLM_UN.sav'
  /COMPRESSED.


DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\20\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\20\12\violation_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity_violation\20\12\final_20_n_violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\20\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\final_20_n_violation_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\20\12\final_20_n_violation_12.sav'
  /COMPRESSED.



*n=25*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help25=(help25 < 5001).
VARIABLE LABELS filter_help25 'help25 < 5001 (FILTER)'.
VALUE LABELS filter_help25 0 'Not Selected' 1 'Selected'.
FORMATS filter_help25 (f1.0).
FILTER BY filter_help25.
EXECUTE.

SORT CASES  BY help25.
SPLIT FILE SEPARATE BY help25.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity_violation\25\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity_violation\25\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity_violation\25\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_sn_1 AV_sn_2 AV_sn_3 AV_sn_4 AV_sn_5 AV_sn_6 AV_sn_7 AV_sn_8 AV_sn_9 AV_sn_10 AV_sn_11 AV_sn_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity_violation\25\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity_violation\25\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity_violation\25\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity_violation\25\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\25\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\25\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\25\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\25\12\ANOVA.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\25\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity_violation\25\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity_violation\25\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\25\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\25\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity_violation\25\12\violation_final.sav'
  /COMPRESSED.


*MLM CS

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help25=(help25 < 5001).
VARIABLE LABELS filter_help25 'help25 < 5001 (FILTER)'.
VALUE LABELS filter_help25 0 'Not Selected' 1 'Selected'.
FORMATS filter_help25 (f1.0).
FILTER BY filter_help25.
EXECUTE.

SORT CASES  BY help25.
SPLIT FILE SEPARATE BY help25.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity_violation\25\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\25\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity_violation\25\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\25\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\25\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\25\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help25=(help25 < 5001).
VARIABLE LABELS filter_help25 'help25 < 5001 (FILTER)'.
VALUE LABELS filter_help25 0 'Not Selected' 1 'Selected'.
FORMATS filter_help25 (f1.0).
FILTER BY filter_help25.
EXECUTE.

SORT CASES  BY help25.
SPLIT FILE SEPARATE BY help25.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity_violation\25\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\25\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.


get file='C:\sphericity_violation\25\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\25\12\MLM_UN.sav'
  /COMPRESSED.



get file='C:\sphericity_violation\25\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\25\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\MLM_UN.sav'
  /COMPRESSED.

DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\25\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\25\12\violation_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity_violation\25\12\final_25_n_violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\25\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\final_25_n_violation_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\25\12\final_25_n_violation_12.sav'
  /COMPRESSED.



*n=30*

*rANOVA

get file="C:\Population_12.sav".

USE ALL.
COMPUTE filter_help30=(help30 < 5001).
VARIABLE LABELS filter_help30 'help30 < 5001 (FILTER)'.
VALUE LABELS filter_help30 0 'Not Selected' 1 'Selected'.
FORMATS filter_help30 (f1.0).
FILTER BY filter_help30.
EXECUTE.

SORT CASES  BY help30.
SPLIT FILE SEPARATE BY help30.

OMS
  /SELECT TABLES
  /IF COMMANDS=['GLM'] LABELS =['Innersubjektfaktoren' 'Zwischensubjektfaktoren' 'Tests der Innersubjektkontraste' 'Tests der Zwischensubjekteffekte']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Mauchly-Test auf Sphärizität'
/DESTINATION OUTFILE='C:\sphericity_violation\30\12\Mauchly.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Tests der Innersubjekteffekte'
/DESTINATION OUTFILE='C:\sphericity_violation\30\12\ANOVA.sav' 
VIEWER =NO FORMAT =SAV
/COLUMNS SEQUENCE =[RALL].
OMS
/SELECT TABLES
/if COMMANDS ='GLM' LABELS ='Multivariate Tests'
/DESTINATION OUTFILE='C:\sphericity_violation\30\12\MANOVA.sav' 
VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].

GLM AV_sn_1 AV_sn_2 AV_sn_3 AV_sn_4 AV_sn_5 AV_sn_6 AV_sn_7 AV_sn_8 AV_sn_9 AV_sn_10 AV_sn_11 AV_sn_12
  /WSFACTOR=time 12 Polynomial 
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time .

OMSEND.

SPLIT FILE OFF.

FILTER OFF.
USE ALL.
EXECUTE.


get file='C:\sphericity_violation\30\12\Mauchly.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.') OR (var1='Epsilon').
execute.

SELECT IF (var2<>'Untergrenze').
EXECUTE.

if (Var1='Sig.') Var2='Mauchly_p'.
EXECUTE.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var3.
execute.

SAVE OUTFILE='C:\sphericity_violation\30\12\Mauchly_Arbeitsdatei.sav'
  /COMPRESSED.

SELECT IF (var2='Mauchly_p').
EXECUTE.

RENAME VARIABLES
time = Mauchly.
execute.

compute key = $casenum.
execute.

RECODE Mauchly (Lowest thru 0.05=1) (ELSE=0) INTO Mauchly_Sig.
VARIABLE LABELS  Mauchly_Sig 'Signifikanz Mauchly-Test'.
EXECUTE.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\Mauchly_p.sav'
  /COMPRESSED.

get FILE='C:\sphericity_violation\30\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Greenhouse-Geisser').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Greenhouse_Geisser.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\Mauchly_Epsilon_Greenhouse.sav'
  /COMPRESSED.


get FILE='C:\sphericity_violation\30\12\Mauchly_Arbeitsdatei.sav'.

SELECT IF (var2='Huynh-Feldt').
EXECUTE.

RENAME VARIABLES
time = Epsilon_Huynh_Feldt.
execute.

compute key = $casenum.
execute.

DELETE VARIABLES 
Var2.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\Mauchly_Epsilon_Huynh.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\30\12\Mauchly_Epsilon_Greenhouse.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\30\12\Mauchly_p.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\30\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.

select if (var1='Sig.').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
Var2
time_Untergrenze
Fehlertime_Sphärizitätangenommen
Fehlertime_GreenhouseGeisser
Fehlertime_HuynhFeldt
Fehlertime_Untergrenze.
execute.

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\30\12\ANOVA.sav'
  /COMPRESSED.

*MANOVA-Ergebnisse bearbeiten.

get file='C:\sphericity_violation\30\12\MANOVA.sav'.
dataset name SavedOutput1 WINDOW=front.

select if (var1='Sig.').
execute.

   DELETE VARIABLES 
   Command_
   Subtype_
   Label_
   Var1
   time_WilksLambda
   time_HotellingSpur
   time_GrößtecharakteristischeWurzelnachRoy.
   execute.

   compute key = $casenum.
   execute.

SAVE OUTFILE='C:\sphericity_violation\30\12\MANOVA.sav'
    /COMPRESSED.


get file='C:\sphericity_violation\30\12\ANOVA.sav'.
dataset name SavedOutput WINDOW=front.
 
MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\30\12\Mauchly_Epsilon_Greenhouse_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /FILE='C:\sphericity_violation\30\12\MANOVA.sav'
  /BY key.
EXECUTE.

RENAME VARIABLES (time_Sphärizitätangenommen=p_Sphärizität) (time_GreenhouseGeisser=p_Greenhouse_Geisser) (time_HuynhFeldt=p_Huynh_Feldt) (time_PillaiSpur=p_MANOVA).
execute.

SAVE OUTFILE='C:\sphericity_violation\30\12\violation_final.sav'
  /COMPRESSED.


*MLM CS

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help30=(help30 < 5001).
VARIABLE LABELS filter_help30 'help30 < 5001 (FILTER)'.
VALUE LABELS filter_help30 0 'Not Selected' 1 'Selected'.
FORMATS filter_help30 (f1.0).
FILTER BY filter_help30.
EXECUTE.

SORT CASES  BY help30.
SPLIT FILE SEPARATE BY help30.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
 /DESTINATION OUTFILE='C:\sphericity_violation\30\12\MLM_CS.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\30\12\MLM_CS_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(CS).

OMSEND.

SPLIT FILE off.

get file='C:\sphericity_violation\30\12\MLM_CS.sav'.
dataset name CS WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_CS).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\30\12\MLM_CS.sav'
  /COMPRESSED.


get file='C:\sphericity_violation\30\12\MLM_CS_fit.sav'.

DATASET CLOSE CS.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.



RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_CS_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_CS.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\30\12\MLM_CS.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\MLM_CS.sav'
  /COMPRESSED.

*MLM UN

get file="C:\Pop_long_violation_12.sav".

USE ALL.
COMPUTE filter_help30=(help30 < 5001).
VARIABLE LABELS filter_help30 'help30 < 5001 (FILTER)'.
VALUE LABELS filter_help30 0 'Not Selected' 1 'Selected'.
FORMATS filter_help30 (f1.0).
FILTER BY filter_help30.
EXECUTE.

SORT CASES  BY help30.
SPLIT FILE SEPARATE BY help30.


OMS
  /SELECT TABLES
  /IF COMMANDS=['MIXED'] LABELS =['Modelldimension' 'Schätzungen von Kovarianzparametern']
  /DESTINATION VIEWER=NO.
OMS
/SELECT TABLES
/if COMMANDS ='MIXED' LABELS ='Tests auf feste Effekte, Typ III'
/DESTINATION OUTFILE='C:\sphericity_violation\30\12\MLM_UN.sav' VIEWER =NO FORMAT =SAV 
/COLUMNS SEQUENCE =[RALL].
OMS
 /SELECT TABLES
 /if COMMANDS ='MIXED' LABELS ='Informationskriterien'
 /DESTINATION OUTFILE='C:\sphericity_violation\30\12\MLM_UN_fit.sav' VIEWER =NO FORMAT =SAV 
 /COLUMNS SEQUENCE =[RALL].

MIXED sphericity_violation BY Index
 /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
 /FIXED=Index | SSTYPE(3)
 /METHOD=REML
 /REPEATED=Index | SUBJECT(Pbn) COVTYPE(UN).

OMSEND.

SPLIT FILE off.


get file='C:\sphericity_violation\30\12\MLM_UN.sav'.
dataset name UN WINDOW=front.

select if (var1='Signifikanz').
execute.

DELETE VARIABLES 
Command_
Subtype_
Label_
Var1
KonstanterTerm.
execute.

RENAME VARIABLES (Index=p_Sphärizität_MLM_UN).

compute key = $casenum.
execute.

SAVE OUTFILE='C:\sphericity_violation\30\12\MLM_UN.sav'
  /COMPRESSED.

get file='C:\sphericity_violation\30\12\MLM_UN_fit.sav'.

DATASET CLOSE UN.

DELETE VARIABLES 
Command_
Subtype_
Label_
HurvichundTsaiIC
BozdoganKriteriumCAIC
BayesKriteriumvonSchwarzBIC.
execute.

RENAME VARIABLES Eingeschränkte2LogLikelihood=Likelihood_UN_fit.
RENAME VARIABLES AkaikeInformationskriteriumAIC=Akaike_UN.
compute key = $casenum.
execute.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\30\12\MLM_UN.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\MLM_UN.sav'
  /COMPRESSED.

DATASET ACTIVATE SavedOutput.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\30\12\MLM_CS.sav'
  /BY key.
EXECUTE.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\30\12\violation_final.sav'
  /BY key.
EXECUTE.


SAVE OUTFILE='C:\sphericity_violation\30\12\final_30_n_violation.sav'
  /COMPRESSED.

MATCH FILES /FILE=*
  /TABLE='C:\sphericity_violation\30\12\Mauchly_Epsilon_Huynh.sav'
  /BY key.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\final_30_n_violation_12.sav'
  /COMPRESSED.


COMPUTE Likelihood_Differenz=Likelihood_UN_fit - Likelihood_CS_fit.
EXECUTE.

COMPUTE Df_Differenz=19.
EXECUTE.

SAVE OUTFILE='C:\sphericity_violation\30\12\final_30_n_violation_12.sav'
  /COMPRESSED.


