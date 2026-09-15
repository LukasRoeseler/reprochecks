import pandas as pd, numpy as np
import statsmodels.api as sm
from recompute_t2 import prep, quartiles

def logit_me(df, Xvars):
    X = sm.add_constant(df[Xvars])
    m = sm.Logit(df['zakaibag'], X).fit(disp=0)
    est = m.params['treated']
    # marginal effect: set treated contribution to 0
    # xb for all, then subtract est*treated
    xb = X @ m.params
    pxb = xb - est*df['treated'].values
    p = np.exp(pxb)/(1+np.exp(pxb))
    h0 = p[df['treated'].values==1]*(1-p[df['treated'].values==1])
    h0m = h0.mean()
    ME = h0m * est
    return est, ME, h0m

df = prep('01'); df['boy']=df['boy'].astype(int)
sub = df[df['boy']==0].copy().reset_index(drop=True)
for col,v in quartiles(sub).items(): sub[col]=v
sub['ah4']=(sub['m_ahim']>=4).astype(int)
sub['top_ls']=(sub['ls75']+sub['ls100']==1).astype(int)
top = sub[sub['top_ls']==1].copy().reset_index(drop=True)
print("Girls 2001 top-half-ls N =", len(top))
# sc_main for top_ls -> control = semarab semrel ls100
Xvars=['treated','semarab','semrel','ls100']
est, ME, h0m = logit_me(top, Xvars)
print("logit coef treated =", est)
print("h0 =", h0m)
print("Marginal effect (focal) =", ME)
print("Paper: 0.206  (t4.dta 0.2058262)")
