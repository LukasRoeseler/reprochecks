import pandas as pd, numpy as np
import statsmodels.api as sm
from sas7bdat import SAS7BDAT

f='data/unzipped/AngristLavy_AERdata/data/base_ns.sas7bdat'
with SAS7BDAT(f) as r:
    df=r.to_data_frame()
df.columns=[c.strip() for c in df.columns]

# girls only
g = df[df['BOY']==0].copy().reset_index(drop=True)

# quartiles of lagscore within each gender-year (as SAS proc univariate per year)
def add_quartiles(d, col, pref):
    for q in [25,50,75]:
        p = d[col].quantile(q/100)
        d[f'{pref}{q//25}'] = 0
    # simpler: compute cuts
    q25,d['_p25']=None,None
    p25,p50,p75 = d[col].quantile([0.25,0.50,0.75])
    ls25=(d[col]<p25).astype(int)
    ls50=((d[col]<p50)&(ls25==0)).astype(int)
    ls75=((d[col]<p75)&(ls25+ls50==0)).astype(int)
    ls100=(1-(ls25+ls50+ls75)).astype(int)
    d['ls25']=ls25; d['ls50']=ls50; d['ls75']=ls75; d['ls100']=ls100
    return d

# process 2001 and 2000 separately then stack
parts=[]
for yr in [2001,2000]:
    d = g[g['YEAR']==float(yr)].copy()
    d = add_quartiles(d,'LAGSCORE','ls')
    if yr==2000:
        d['treated']=0; d['SEMREL']=0; d['SEMARAB']=0
    d['year01']=(d['YEAR']==2001).astype(int)
    parts.append(d)
S = pd.concat(parts, ignore_index=True)
S = S[S['MISSING_']==0].copy()
S['school_id_a']=np.where(S['YEAR']==2000, S['school_id']*100.0, S['school_id'])

# ls top quartile
S['top']=(S['ls100']==1).astype(int)
T = S[S['top']==1].copy()

# keep schools present in both 2000 and 2001
smin = T.groupby('school_id')['YEAR'].min()
smax = T.groupby('school_id')['YEAR'].max()
keep = smin[smin==2000.0].index.intersection(smax[smax==2001.0].index)
T = T[T['school_id'].isin(keep)].copy().reset_index(drop=True)
print("girls ls-top N =", len(T))

# OLS college0 ~ treated + semarab + semrel + lagscore + year01 + school_id FE
sd = pd.get_dummies(T['school_id'], prefix='sch', drop_first=True).astype(float)
X = pd.concat([T[['treated','SEMARAB','SEMREL','LAGSCORE','year01']], sd], axis=1)
y = T['COLLEGE0'].astype(float)
X = sm.add_constant(X)
m = sm.OLS(y, X.astype(float)).fit(cov_type='HC1')
print("treated coef =", m.params['treated'])
print("HC1 robust SE =", m.bse['treated'])
# also student_id cluster (single obs each ~ robust) 
m2 = sm.OLS(y, X.astype(float)).fit(cov_type='cluster',cov_kwds={'groups':T['student_id']})
print("student-cluster SE =", m2.bse['treated'])
print("Paper: 0.086, SE 0.055; SAS output: 0.0855, 0.0546")
