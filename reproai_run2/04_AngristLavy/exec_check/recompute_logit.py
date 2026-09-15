import pandas as pd, numpy as np
import statsmodels.api as sm
from recompute_t2 import prep, quartiles

def logit_me_full(df, Xvars):
    X = sm.add_constant(df[Xvars])
    m = sm.Logit(df['zakaibag'], X).fit(disp=0)
    est = m.params['treated']
    xb = X @ m.params
    pxb = xb - est*df['treated'].values
    p = np.exp(pxb)/(1+np.exp(pxb))
    tt = df['treated'].values==1
    h0 = (p[tt]*(1-p[tt])).mean()
    return est, h0, h0*est

for gend,name in [(0,'girl'),(1,'boy')]:
    df=prep('01'); df['boy']=df['boy'].astype(int)
    sub=df[df['boy']==gend].copy().reset_index(drop=True)
    for col,v in quartiles(sub).items(): sub[col]=v
    sub['ah4']=(sub['m_ahim']>=4).astype(int)
    Xvars=['treated','semarab','semrel','ls50','ls75','ls100','educav','educem','ah4','ole5']
    est,h0,me=logit_me_full(sub,Xvars)
    print(f"{name} 2001 scqm logit: coef={est:.6f} h0={h0:.6f} ME={me:.6f}")
    
# girls sc (school covariates only)
df=prep('01'); df['boy']=df['boy'].astype(int)
sub=df[df['boy']==0].copy().reset_index(drop=True)
for col,v in quartiles(sub).items(): sub[col]=v
sub['ah4']=(sub['m_ahim']>=4).astype(int)
est,h0,me=logit_me_full(sub,['treated','semarab','semrel'])
print("girl 2001 sc logit ME:", me, "(paper 0.093 SE 0.053)")
