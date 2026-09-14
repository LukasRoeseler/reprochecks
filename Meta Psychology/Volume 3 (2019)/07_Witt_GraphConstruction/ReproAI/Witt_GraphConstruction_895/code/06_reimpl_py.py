import pandas as pd, numpy as np
from scipy import stats
import json, os

wrk = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\07_Witt_GraphConstruction\ReproAI\Witt_GraphConstruction_895"

def condcode(g):
    g=g.lower(); 
    if g=='full': return 1
    if g=='sd': return 2
    if g in ('small','min','minimal'): return 3
    return np.nan

def prep(df, exp):
    df=df.copy()
    df['cd']=np.nan
    df.loc[df.effectSize==0,'corr']=1
    df.loc[df.effectSize==1,'corr']=1.5
    df.loc[df.effectSize==3,'corr']=2
    df.loc[df.effectSize==5,'corr']=3
    df.loc[df.effectSize==8,'corr']=4
    df['corrC']=df['cd']-2.5
    df['cond']=df['graphType'].map(condcode)
    return df[df.cond.notna()]

def per_subj(df, excl):
    out=[]
    for s in sorted(set(df.Subject)-set(excl)):
        for cc in (1,2,3):
            d=df[(df.Subject==s)&(df.cond==cc)]
            X=d.corrC.values; Y=d.resp.values
            b=(np.cov(X,Y)[0,1]/np.var(X)); a=Y.mean()-b*X.mean()
            d2=df[(df.Subject==s)&(df.cond==cc)&(df.effectSize>1)]
            if len(d2)>2:
                X2=d2.cd.values-d2.cd.mean(); Y2=d2.resp.values
                b2=(np.cov(X2,Y2)[0,1]/np.var(X2)); a2=Y2.mean()-b2*X2.mean()
            else: b2=a2=np.nan
            d3=df[(df.Subject==s)&(df.cond==cc)&(df.effectSize<5)]
            X3=d3.cd.values-d3.cd.mean(); Y3=d3.resp.values
            b3=(np.cov(X3,Y3)[0,1]/np.var(X3)); a3=Y3.mean()-b3*X3.mean()
            out.append(dict(subj=s,cond=cc,coef=b,intercept=a,bias=(a-2.5)/2.5*100,
                            coef_eff=b2, coef_noeff=b3))
    return pd.DataFrame(out)

def pair(x,y):
    t,p=stats.ttest_rel(x,y)
    n=len(x); dz=abs(t)/np.sqrt(n)
    # noncentral t 95% CI for dz
    def ncpCI(tval,df):
        # find noncentral params for 2-sided 95%
        lo=hi=0.0
        from scipy.stats import nct
        if tval>0:
            hi=float(nct.ppf(0.975,df,nc=tval))
        # simpler: CI via cohen.d.ci formula (noncentrality)
        ncp=t*np.sqrt(1)  # for paired, lambda=t*sqrt(n)? cohen.d.ci uses n on d
        return dz
    return dict(t=t,p=p,n=n,dz=dz)

res={}
par=[]
files={1:('axisSize 1-24.csv',[1,8]),2:('axisSize 1-24.csv',[13,17,24]),
      3:('axisRangeEBv2 1-14.csv',[3,4]),4:('axisRangeLineV2 1-20.csv',[4,9,15,16]),
      5:('axisRangeLine 1-14.csv',[7,13])}
for exp,(f,excl) in files.items():
    df=pd.read_csv(os.path.join(wrk,'data',f))
    if 'axisRange' in df.columns: df=df.rename(columns={'axisRange':'graphType'})
    if exp<=2:
        if exp==1: df=df[df.Subject<10]
        else: df=df[df.Subject>9]
    df=prep(df,exp)
    A=per_subj(df,excl)
    m=A.groupby('cond').coef.mean(); s=A.groupby('cond').coef.std()
    me=A.groupby('cond').coef_eff.mean(); se=A.groupby('cond').coef_eff.std()
    mb=A.groupby('cond').bias.mean(); sb=A.groupby('cond').bias.std()
    res[exp]=dict(N=len(set(A.subj)),
        slope_full=[round(m[1],3),round(s[1],3)],slope_sd=[round(m[2],3),round(s[2],3)],slope_min=[round(m[3],3),round(s[3],3)],
        deff_full=[round(me[1],3),round(se[1],3)],deff_sd=[round(me[2],3),round(se[2],3)],deff_min=[round(me[3],3),round(se[3],3)],
        bias_full=[round(mb[1],2),round(sb[1],2)],bias_sd=[round(mb[2],2),round(sb[2],2)],bias_min=[round(mb[3],2),round(sb[3],2)])
    w=A.pivot(index='subj',columns='cond',values='coef')
    for (a,b,lab) in [(2,1,'SDvsFull'),(3,2,'MinvsSD'),(3,1,'MinvsFull')]:
        t,p=stats.ttest_rel(w[a],w[b])
        par.append(dict(exp=exp,comp=lab,t=round(t,4),p=round(p,5),dz=round(abs(t)/np.sqrt(len(w)),3)))
    # bias one-sample
    for cc,nm in [(1,'full'),(2,'sd'),(3,'min')]:
        t,p=stats.ttest_1samp(A[A.cond==cc].bias,0)
        par.append(dict(exp=exp,comp='bias1s_'+nm,t=round(t,4),p=round(p,5),dz=round(abs(t)/np.sqrt(len(set(A.subj))),3)))

print("=== PER-EXPERIMENT SLOPES/Bias (reimpl) ===")
print(json.dumps(res,indent=1))

# pooled percentages & pooled bias across all experiments (with per-exp exclusions)
pool=[]
pool_cols={}
for exp,(f,excl) in files.items():
    df=pd.read_csv(os.path.join(wrk,'data',f))
    if 'axisRange' in df.columns: df=df.rename(columns={'axisRange':'graphType'})
    if exp<=2:
        if exp==1: df=df[df.Subject<10]
        else: df=df[df.Subject>9]
    df=df[~df.Subject.isin(excl)]
    df=prep(df,exp)
    df['exp']=exp
    pool.append(df)
P=pd.concat(pool)
print("\n=== POOLED PERCENTAGES (d>0 trials for big, all for no/small) ===")
full=P[(P.cond==1)]
mini=P[(P.cond==3)]
print("full no/small (<3) %:", round(100*(full.resp<3).mean(),1))
print("minimal big (==4) d>0 %:", round(100*(mini[mini.effectSize>0].resp==4).mean(),1))
print("minimal med/big (>2) d>0 %:", round(100*(mini[mini.effectSize>0].resp>2).mean(),1))
print("minimal d in .1-.8 (effectSize>0) big %:", round(100*(mini[mini.effectSize>0].resp==4).mean(),1))

# pooled bias
P2=P.copy()
Aall=[]
for exp,(f,excl) in files.items():
    df=pd.read_csv(os.path.join(wrk,'data',f))
    if 'axisRange' in df.columns: df=df.rename(columns={'axisRange':'graphType'})
    if exp<=2:
        if exp==1: df=df[df.Subject<10]
        else: df=df[df.Subject>9]
    df=pd.read_csv(os.path.join(wrk,'data',f))
    if 'axisRange' in df.columns: df=df.rename(columns={'axisRange':'graphType'})
    if exp<=2:
        if exp==1: df=df[df.Subject<10]
        else: df=df[df.Subject>9]
    df=prep(df,excl)
    Aall.append(per_subj(df,excl))
AA=pd.concat(Aall)
print("\n=== POOLED BIAS by condition (saveAll combined) ===")
gb=AA.groupby('cond').bias
print("full:", round(gb.mean()[1],2), "sd:", round(gb.mean()[2],2), "min:", round(gb.mean()[3],3))


