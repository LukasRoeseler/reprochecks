import math
# Independent Python cross-check of the summary-level reproductions already done in R
print("==== Python independent cross-check ====")
# Section 3.1 one-sample t and Cohen's d
for name,M,SD,n,mu,trep,drep in [("Males",16.71,6.91,480,15.2,4.79,0.22),
                                  ("Females",19.44,6.79,1555,16.3,18.21,0.46)]:
    se=SD/math.sqrt(n); t=(M-mu)/se; d=(M-mu)/SD
    print("%s: t_calc=%.3f (rep %.2f)  d_calc=%.3f (rep %.2f)"%(name,t,trep,d,drep))
# Table 3 F-measure
ml=[("Log","High",0.349,0.759,0.478),("Log","Low",0.919,0.659,0.767),
    ("SVM","High",0.337,0.747,0.465),("SVM","Low",0.914,0.646,0.757),
    ("NB","High",0.361,0.709,0.479),("NB","Low",0.909,0.698,0.790),
    ("RF","High",0.438,0.532,0.480),("RF","Low",0.881,0.835,0.858)]
ok=0
for a,c,P,R,Fr in ml:
    Fc=2*P*R/(P+R)
    good=abs(Fc-Fr)<=0.005
    ok+=good
    print("%s-%s F_calc=%.3f F_rep=%.3f %s"%(a,c,Fc,Fr,"OK" if good else "CHECK"))
print("F-measure agreement: %d/8"%ok)
# Table S2 item1 inconsistency highlight: means vs reported t/d
k=math.sqrt(393*1642/(393+1642))
for it,Mhi,Sdhi,Mlo,Sdlo,tr,dr in [(1,2.62,0.91,1.84,0.91,27.95,1.57),
                                   (2,3.09,0.80,1.60,0.98,28.04,1.58),
                                   (10,2.92,0.89,1.19,0.91,33.972,1.908)]:
    sp=math.sqrt(((393-1)*Sdhi**2+(1642-1)*Sdlo**2)/(2033))
    se=sp*math.sqrt(1/393+1/1642)
    tc=(Mhi-Mlo)/se
    dc=(Mhi-Mlo)/sp
    print("Item %d: t_calc=%.3f (rep %.3f) d_mag_calc=%.3f (rep %.3f)"%(it,tc,tr,dc,dr))
print("Note: item 1 means (2.62/1.84) give t~15.3, but reported t=27.95 & d=1.57 (which are mutually consistent) imply mean diff ~1.43.")
print("==== END ====")
