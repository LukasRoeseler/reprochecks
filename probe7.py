import pandas as pd, numpy as np
import statsmodels.api as sm
import json
p=r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\causal-replication.dta'
df=pd.read_stata(p)

def fit(dv, preds, wcol):
    cols=[dv]+preds+[wcol]
    d=df[cols].dropna()
    X=sm.add_constant(d[preds]); y=d[dv]; w=d[wcol]
    m=sm.WLS(y,X,weights=w).fit(cov_type='HC1')
    return len(d), m, preds, d

def contrast(m,preds,ca,cb):
    # coef(CA)-coef(CB) using HC1 cov
    cov=m.cov_params()
    diff = m.params[ca]-m.params[cb]
    var = cov.loc[ca,ca]+cov.loc[cb,cb]-2*cov.loc[ca,cb]
    se=np.sqrt(var)
    t=diff/se
    df_r = m.df_resid
    from scipy import stats
    pv=2*(1-stats.t.cdf(abs(t),df_r))
    return diff,se,pv

res={}
# Model 1 & 2 swensenfav
for label,wcol,svy in [("M1",'aw',False),("M2",'weight',True)]:
    n,m,preds,d=fit('swensenfav',['innuendo','denial','causal'],wcol)
    r={'n':int(n),'coef':{k:round(float(v),6) for k,v in m.params.items() if k!='const'},
       'se':{k:round(float(v),6) for k,v in m.bse.items() if k!='const'},
       'denial_vs_control':round(float(m.params['denial']),4)}
    d_i,se_i,pv_i=contrast(m,preds,'causal','innuendo')
    r['causal_vs_innuendo']=[round(d_i,4),round(float(pv_i),4)]
    res[label]=r

# Model 3 & 4 acceptedbribes
for label,wcol in [("M3",'aw'),("M4",'weight')]:
    n,m,preds,d=fit('acceptedbribes',['innuendo','denial','causal'],wcol)
    r={'n':int(n),'coef':{k:round(float(v),6) for k,v in m.params.items() if k!='const'}}
    d_i,se_i,pv_i=contrast(m,preds,'causal','denial')
    r['causal_vs_denial']=[round(d_i,4),round(float(pv_i),4)]
    res[label]=r

# Model 5 & 6 resigninvest
for label,wcol in [("M5",'aw'),("M6",'weight')]:
    n,m,preds,d=fit('resigninvest',['denial','causal'],wcol)
    r={'n':int(n),'coef':{k:round(float(v),6) for k,v in m.params.items() if k!='const'}}
    d_i,se_i,pv_i=contrast(m,preds,'causal','denial')
    r['causal_vs_denial']=[round(d_i,4),round(float(pv_i),4)]
    r['se']={k:round(float(v),4) for k,v in m.bse.items() if k!='const'}
    res[label]=r

print(json.dumps(res,indent=2))
open(r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\_recompute.json','w').write(json.dumps(res,indent=2))
