import pandas as pd, numpy as np
from scipy import stats
import json, os

wrk = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\07_Witt_GraphConstruction\ReproAI\Witt_GraphConstruction_895"
def cc(g): return {'full':1,'sd':2,'small':3,'min':3,'minimal':3}[g.lower()]

files = {1:('axisSize 1-24.csv',[1,8]),2:('axisSize 1-24.csv',[13,17,24]),
         3:('axisRangeEBv2 1-14.csv',[3,4]),4:('axisRangeLineV2 1-20.csv',[4,9,15,16]),
         5:('axisRangeLine 1-14.csv',[7,13])}

def reg(df, s, c, dcrit=None, centering='raw'):
    d = df[(df.Subject==s) & (df.cond==c)]
    if dcrit is not None: d = d[d.effectSize>dcrit]
    if centering=='raw':
        x = d.cd.values-2.5; y=d.resp.values
    else:
        x = d.cd.values-d.cd.mean(); y=d.resp.values
    b = np.cov(x,y)[0,1]/np.var(x)
    a = y.mean()-b*x.mean()
    return b,a

results={}; pair_rows=[]
per_long=[]
for exp,(f,excl) in files.items():
    df=pd.read_csv(os.path.join(wrk,'data',f))
    if 'axisRange' in df.columns: df=df.rename(columns={'axisRange':'graphType'})
    if exp==1: df=df[df.Subject<10]
    elif exp==2: df=df[df.Subject>9]
    # build corr & cond
    df['cd']=np.nan
    df.loc[df.effectSize==0,'cd']=1; df.loc[df.effectSize==1,'cd']=1.5
    df.loc[df.effectSize==3,'cd']=2; df.loc[df.effectSize==5,'cd']=3; df.loc[df.effectSize==8,'cd']=4
    df['cond']=df.graphType.map(cc)
    df=df[df.cond.notna()]
    subj=[s for s in sorted(set(df.Subject)) if s not in excl]
    rows=[]
    for s in subj:
        for c in (1,2,3):
            bl,ai=reg(df,s,c,dcrit=None,centering='raw'); be,ae=reg(df,s,c,dcrit=1,centering='center'); bn,an=reg(df,s,c,dcrit=None,centering='center')
            rows.append(dict(subj=s,cond=c,coef=bl,bias=(ai-2.5)/2.5*100,coef_eff=be,coef_noeff=bn))
    A=pd.DataFrame(rows)
    g=A.groupby('cond')
    results[exp]=dict(N=len(subj),
        slope_full=[round(g.get_group(1).coef.mean(),3),round(g.get_group(1).coef.std(),3)],
        slope_sd=[round(g.get_group(2).coef.mean(),3),round(g.get_group(2).coef.std(),3)],
        slope_min=[round(g.get_group(3).coef.mean(),3),round(g.get_group(3).coef.std(),3)],
        bias_full=[round(g.get_group(1).bias.mean(),2),round(g.get_group(1).bias.std(),2)],
        bias_sd=[round(g.get_group(2).bias.mean(),2),round(g.get_group(2).bias.std(),2)],
        bias_min=[round(g.get_group(3).bias.mean(),2),round(g.get_group(3).bias.std(),2)])
    w=A.pivot(index='subj',columns='cond',values='coef')
    for (a,b,lab) in [(2,1,'SDvsFull'),(3,2,'MinvsSD'),(3,1,'MinvsFull')]:
        t,p=stats.ttest_rel(w[a],w[b]); d=abs(t)/np.sqrt(len(w))
        pair_rows.append(dict(exp=exp,comp=lab,df=len(w)-1,t=round(t,4),p=round(p,5),dz=round(d,3)))
    for c,nm in [(1,'full'),(2,'sd'),(3,'min')]:
        t,p=stats.ttest_1samp(g.get_group(c).bias,0); d=abs(t)/np.sqrt(len(w))
        pair_rows.append(dict(exp=exp,comp='bias1s_'+nm,df=len(w)-1,t=round(t,4),p=round(p,5),dz=round(d,3)))
    A['exp']=exp; per_long.append(A)

print(json.dumps(results,indent=1))
print("\n=== SLOPE T-TESTS (df, t, p, dz) ===")
for r in pair_rows: print(r['exp'],r['comp'],'df',r['df'],'t',r['t'],'p',r['p'],'dz',r['dz'])

P=pd.concat(per_long)
print("\n=== POOLED ===")
# pooled percentages from raw trial data with per-exp exclusions
trial=[]
for exp,(f,excl) in files.items():
    dd=pd.read_csv(os.path.join(wrk,'data',f))
    if 'axisRange' in dd.columns: dd=dd.rename(columns={'axisRange':'graphType'})
    if exp==1: dd=dd[dd.Subject<10]
    elif exp==2: dd=dd[dd.Subject>9]
    dd=dd[~dd.Subject.isin(excl)]
    dd['cond']=dd.graphType.map(cc); dd=dd[dd.cond.notna()]
    trial.append(dd)
T=pd.concat(trial)
full=T[T.cond==1]; mini=T[T.cond==3]
print("full no/small %:", round(100*(full.resp<3).mean(),1))
print("minimal big d>0 %:", round(100*(mini[mini.effectSize>0].resp==4).mean(),1))
print("minimal med/big d>0 %:", round(100*(mini[mini.effectSize>0].resp>2).mean(),1))
gb=P.groupby('cond').bias
print("pooled bias full/sd/min:", round(gb.mean()[1],2), round(gb.mean()[2],2), round(gb.mean()[3],2))

