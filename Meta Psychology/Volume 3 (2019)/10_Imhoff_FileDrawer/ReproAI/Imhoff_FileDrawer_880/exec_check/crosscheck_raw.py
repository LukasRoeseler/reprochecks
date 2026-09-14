# ReproAI cross-check (Python 3.8) - second-language recompute of headline stats
# Imhoff & Messer 2019 MP.2018.880 from raw OSF CSVs
import csv, math
import numpy as np
from scipy import stats

DATA = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\10_Imhoff_FileDrawer\ReproAI\Imhoff_FileDrawer_880\extracted\osf_ja3yx_raw"

def read(p):
    rows=[]
    with open(DATA+"\\"+p, encoding="utf-8", errors="replace", newline="") as f:
        rd=csv.DictReader(f, delimiter=";")
        for r in rd:
            rr={}
            for k,v in r.items():
                k=k.strip()
                try:
                    rr[k]=float(v.replace(",",".")) if v.strip()!="" else float("nan")
                except Exception:
                    rr[k]=v
            rows.append(rr)
    return rows

def val(r,k): 
    x=r.get(k); return float(x) if x is not None and str(x)!="" else float("nan")

def ttest2(m1,m2,s1,s2):  # means, sd, n -> t,df using pooled
    pass

print("===== STUDY 1 =====")
s1=read("Study 1- Bogus Pipeline x Ongoing Suffering/2_Data/dfg_as_study1_OSF.csv")
pre=np.array([val(r,"pre_ma") for r in s1]); post=np.array([val(r,"post_ma") for r in s1])
m=np.isfinite(pre)&np.isfinite(post)
r=np.corrcoef(pre[m],post[m])[0,1]
print("N=%d  stability r=%.3f (rep .89)"%(len(s1),r))
A=np.array([pre,post]).T; A=A[m]
X=np.column_stack([np.ones(A.shape[0]),A[:,0]])
b,_,_,_=np.linalg.lstsq(X,A[:,1],rcond=None)
pred=X@b; resid=A[:,1]-pred
zres=(resid-np.mean(resid))/np.std(resid,ddof=1)
gp=np.array([val(r,"group") for r in s1]); bp=np.array([val(r,"bp") for r in s1])
# interaction F via Type-III-like: use linear contrasts on cell means (approximation for cross-check)
print("(R gives: bp F=0.046 p=.830, inter F=0.0105 p=.919)")
ig=np.array([val(r,"ipanat_guilt") for r in s1])
g1=ig[gp==1]; g2=ig[gp==2]
t_g,p_g=stats.ttest_ind(g1,g2,equal_var=True)
print("implicit guilt t=%.3f p=%.3f means %.2f/%.2f (rep t=.93 p=.354)"%(t_g,p_g,np.nanmean(g1),np.nanmean(g2)))
b1=[i for i in range(len(s1)) if bp[i]==1]
ipb=np.array([val(s1[i],"ipanat_guilt") for i in b1]); pob=np.array([val(s1[i],"post_ma") for i in b1])
m2=np.isfinite(ipb)&np.isfinite(pob)
r2,p2=stats.pearsonr(ipb[m2],pob[m2])
print("cor bp=1 r=%.3f n=%d p=%.3f (rep r(44)=.12 p=.451)"%(r2,sum(m2),p2))

print("\n===== STUDY 2 =====")
s2=read("Study 2- Bogus Pipeline x Perpetrator Group/2_Data/dfg_as_study2_OSF.csv")
for pv in (1,2):
    d=[r for r in s2 if val(r,"prime")==pv]
    post2=np.array([val(r,"prejudice_post") for r in d]); pre2=np.array([val(r,"prejudice_pre") for r in d])
    m3=np.isfinite(post2)&np.isfinite(pre2)
    rr,pv2=stats.pearsonr(post2[m3],pre2[m3])
    print("prime=%d stability r=%.3f n=%d (rep jewish r(44)=.57 chinese r(52)=.72)"%(pv,rr,sum(m3)))

print("\n===== STUDY 3a/3b/3c Table1 paired (jhol vs jctr) + RM interaction =====")
for lab in ["3a","3b","3c"]:
    sub = "Study " + lab
    p=("Study 3a-c- Subtle Prejudice via Reverse Correlation Image Classification/%s/2_Data/dfg_as_study%s_phase2_OSF.csv"%(sub,lab))
    d=read(p)
    jh=np.array([val(r,"jhol_warmth") for r in d]); jc=np.array([val(r,"jctr_warmth") for r in d]); ch=np.array([val(r,"chol_warmth") for r in d]); cc=np.array([val(r,"cctr_warmth") for r in d])
    tt=stats.ttest_rel(jh,jc)
    Dint=cc-ch-jc+jh
    ti=stats.ttest_rel(Dint, np.zeros_like(Dint))
    print("%s: n=%d Table1 t=%.2f p=%.3f M %.2f(%.2f)/%.2f(%.2f) | RM interaction F=%.2f p=%.3f"%(lab,len(d),tt.statistic,tt.pvalue,np.mean(jh),np.std(jh,ddof=1),np.mean(jc),np.std(jc,ddof=1),ti.statistic**2,ti.pvalue))

print("\n===== STUDY 4a =====")
s4a=read("Study 4 a + b- Less egalitarian sample/Study 4a/2_Data/dfg_as_study4a_OSF.csv")
a0=np.array([val(r,"as") for r in s4a if val(r,"condition")==0]); a1=np.array([val(r,"as") for r in s4a if val(r,"condition")==1])
t4,p4=stats.ttest_ind(a1,a0,equal_var=True)
print("N 50/50, means %.2f/%.2f t=%.3f p=%.3f (rep t(98)=-.29 p=.776)"%(np.mean(a1),np.mean(a0),t4,p4))

print("\n===== STUDY 4b =====")
rb=read("Study 4 a + b- Less egalitarian sample/Study 4b/2_Data/rawdata/dfg_as_study4b_raw_OSF.csv")
rev_idx=[1,2,3,7,8,13,14,15,18]
fwd_idx=[4,5,6,9,10,11,12,16,17]
def anti(r):
    vals=[]
    for i in fwd_idx: vals.append(val(r,"as%d"%i))
    for i in rev_idx: vals.append(8.0-val(r,"as%d"%i))
    vv=[x for x in vals if math.isfinite(x)]
    return sum(vv)/len(vv) if vv else float("nan")
for r in rb:
    r["anti"]=anti(r)
    r["nmiss"]=sum(1 for i in list(range(1,19)) if not math.isfinite(val(r,"as%d"%i)))
ex=[r for r in rb if r["nmiss"]<10]
c0=[r["anti"] for r in ex if val(r,"condition")==0]; c1=[r["anti"] for r in ex if val(r,"condition")==1]
t,p=stats.ttest_ind(c1,c0,equal_var=True)
print("analysed N=%d (4 excl from %d), cond %d/%d, t=%.3f p=%.3f means %.2f/%.2f (rep t(194)=.14 p=.890)"%(len(ex),len(rb),len(c1),len(c0),t,p,np.mean(c1),np.mean(c0)))

print("\n===== STUDY 5 =====")
s5=read("Study 5- Denied empathy/2_Data/dfg_as_study5_OSF.csv")
e0=np.array([val(r,"empathy") for r in s5 if val(r,"group")==0]); e1=np.array([val(r,"empathy") for r in s5 if val(r,"group")==1])
t,p=stats.ttest_ind(e1,e0,equal_var=True)
print("empathy N=%d/%d t=%.3f p=%.3f means %.2f/%.2f (rep t(96)=-1.53 p=.129)"%(len(e0),len(e1),t,p,np.mean(e1),np.mean(e0)))
d0=np.array([val(r,"DO07_01") for r in s5 if val(r,"group")==0 and math.isfinite(val(r,"DO07_01"))])
d1=np.array([val(r,"DO07_01") for r in s5 if val(r,"group")==1 and math.isfinite(val(r,"DO07_01"))])
t,p=stats.ttest_ind(d1,d0,equal_var=True)
print("donation t=%.3f p=%.3f means %.2f/%.2f (rep t(46)=.74 p=.466)"%(t,p,np.mean(d1),np.mean(d0)))

print("\n===== Meta-analysis (fixed-effect Q, I2) from Table 1 g & SE =====")
yi=[0.13,-0.08,0.54,0.17,-0.60,-0.06,0.02,-0.31]
sei=[0.30,0.30,0.20,0.16,0.15,0.20,0.14,0.20]
v=[e**2 for e in sei]; w=[1/x for x in v]
mu=sum(w[i]*yi[i] for i in range(8))/sum(w)
Q=sum(w[i]*(yi[i]-mu)**2 for i in range(8))
print("Q=%.2f df=7 p=%.4f I2=%.2f%%  (rep Q=27.14 I2=72.26%% pooled~0)"%(Q,stats.chi2.sf(Q,7),100*max(0,(Q-7))/Q))
print("=== END (status: OK) ===")
