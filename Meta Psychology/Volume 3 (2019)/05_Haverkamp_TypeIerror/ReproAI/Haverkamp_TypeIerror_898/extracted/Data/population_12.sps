* Encoding: windows-1252.

set  RNG=MT seed=1000  workspace=1000000 MXLOOPS=1000000.


INPUT PROGRAM.

 LOOP #1 = 1 to 1000000.
 DO REPEAT x = x1 to x110.
 COMPUTE x = NORMAL(1).
 END REPEAT.
 END CASE.
 END LOOP.
 END FILE.
END INPUT PROGRAM.
execute.

compute cor=0.50.
compute x1=((1-cor)**0.5)*x1+(cor**0.5)*x20.
compute x2=((1-cor)**0.5)*x2+(cor**0.5)*x20.
compute x3=((1-cor)**0.5)*x3+(cor**0.5)*x20.
compute x4=((1-cor)**0.5)*x4+(cor**0.5)*x20.
compute x5=((1-cor)**0.5)*x5+(cor**0.5)*x20.
compute x6=((1-cor)**0.5)*x6+(cor**0.5)*x20.
compute x7=((1-cor)**0.5)*x7+(cor**0.5)*x20.
compute x8=((1-cor)**0.5)*x8+(cor**0.5)*x20.
compute x9=((1-cor)**0.5)*x9+(cor**0.5)*x20.
compute x10=((1-cor)**0.5)*x10+(cor**0.5)*x20.
compute x11=((1-cor)**0.5)*x11+(cor**0.5)*x20.
compute x12=((1-cor)**0.5)*x12+(cor**0.5)*x20.
execute.

*help variables to draw samples.

compute help=trunc(($casenum/15)).
execute.
compute help15=lag(help).
execute.
if ($casenum=1) help15=0.
compute help15=help15+1.
execute. 
delete variables help.

compute help=trunc(($casenum/20)).
execute.
compute help20=lag(help).
execute.
if ($casenum=1) help20=0.
compute help20=help20+1.
execute. 
delete variables help.

compute help=trunc(($casenum/25)).
execute.
compute help25=lag(help).
execute.
if ($casenum=1) help25=0.
compute help25=help25+1.
execute. 
delete variables help.

compute help=trunc(($casenum/30)).
execute.
compute help30=lag(help).
execute.
if ($casenum=1) help30=0.
compute help30=help30+1.
execute. 
delete variables help.

IF (MOD($casenum,2)=0) UV_1=0+0.
IF (MOD($casenum,2)<>0) UV_1=0+0.
execute.


* sphericity holds.
compute AV_se_1=x1+0+0.
compute AV_se_2=x2+0.
compute AV_se_3=x3+0.
compute AV_se_4=x4+0.
compute AV_se_5=x5+0.
compute AV_se_6=x6+0.
compute AV_se_7=x7+0.
compute AV_se_8=x8+0.
compute AV_se_9=x9+0.
compute AV_se_10=x10+0.
compute AV_se_11=x11+0.
compute AV_se_12=x12+0.


* sphericity violation.
* to create a correlation of .3 between c1 and c2 .3: (a1=0,3)**0.5.
compute a1=0.30.
compute a2=0.50.
compute u1=(1-a1-a2)**0.5.

compute c1=a1**0.5*x13+a2**0.5*x21+u1*x101.
compute c2=a1**0.5*x13+a2**0.5*x21+u1*x102.
compute c3=a1**0.5*x13+a2**0.5*x21+u1*x103.
compute c4=a1**0.5*x13+a2**0.5*x21+u1*x104.
compute c5=a1**0.5*x13+a2**0.5*x21+u1*x105.
compute c6=a1**0.5*x13+a2**0.5*x21+u1*x106.

compute x14=((1-cor)**0.5)*x14+(cor**0.5)*x21.
compute x15=((1-cor)**0.5)*x15+(cor**0.5)*x21.
compute x16=((1-cor)**0.5)*x16+(cor**0.5)*x21.
compute x17=((1-cor)**0.5)*x17+(cor**0.5)*x21.
compute x18=((1-cor)**0.5)*x18+(cor**0.5)*x21.
compute x19=((1-cor)**0.5)*x19+(cor**0.5)*x21.
execute.

compute AV_sn_1=c1+0+0.
compute AV_sn_2=x14+0.
compute AV_sn_3=c2+0.
compute AV_sn_4=x15+0.
compute AV_sn_5=c3+0.
compute AV_sn_6=x16+0.
compute AV_sn_7=c4+0.
compute AV_sn_8=x17+0.
compute AV_sn_9=c5+0.
compute AV_sn_10=x18+0.
compute AV_sn_11=c6+0.
compute AV_sn_12=x19+0.
execute.


save outfile="C:\Population_12.sav" keep   AV_se_1 AV_se_2 AV_se_3 AV_se_4 AV_se_5 AV_se_6 
AV_se_7 AV_se_8 AV_se_9 AV_se_10 AV_se_11 AV_se_12 AV_sn_1 AV_sn_2 AV_sn_3  AV_sn_4 AV_sn_5 AV_sn_6 AV_sn_7 AV_sn_8 AV_sn_9 AV_sn_10 AV_sn_11 AV_sn_12
help15 help20 help25 help30. 



get file="C:\Population_12.sav".

compute Pbn= $casenum.
execute.

VARSTOCASES
 /MAKE sphericity_holds FROM AV_se_1 AV_se_2 AV_se_3 AV_se_4 AV_se_5 AV_se_6 AV_se_7 AV_se_8 AV_se_9 AV_se_10 AV_se_11 AV_se_12 
 /INDEX=Index
 /DROP AV_sn_1 AV_sn_2 AV_sn_3 AV_sn_4 AV_sn_5 AV_sn_6 AV_sn_7 AV_sn_8 AV_sn_9 AV_sn_10 AV_sn_11 AV_sn_12.

SAVE OUTFILE='C:\Pop_long_sphericity_12.sav'
  /COMPRESSED.



get file="C:\Population_12.sav".

compute Pbn= $casenum.
execute.

VARSTOCASES
 /MAKE sphericity_violation FROM AV_sn_1 AV_sn_2 AV_sn_3 AV_sn_4 AV_sn_5 AV_sn_6 AV_sn_7 AV_sn_8 AV_sn_9 AV_sn_10 AV_sn_11 AV_sn_12
 /INDEX=Index
 /DROP AV_se_1 AV_se_2 AV_se_3 AV_se_4 AV_se_5 AV_se_6 AV_se_7 AV_se_8 AV_se_9 AV_se_10 AV_se_11 AV_se_12.

SAVE OUTFILE='C:\Pop_long_violation_12.sav'
  /COMPRESSED.















