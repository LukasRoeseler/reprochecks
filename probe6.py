import pandas as pd, numpy as np
import statsmodels.api as sm
p=r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\causal-replication.dta'
df=pd.read_stata(p)

def wls(dv, preds, w):
    d=pd.concat([df[dv], df[preds]],axis=1).dropna()
    d=pd.merge(d,df[[dv,'aw','weight']],on=dv,how='left') if False else None

def fit(dv, preds, wcol):
    cols=[dv]+preds+[wcol]
    d=df[cols].dropna()
    X=sm.add_constant(d[preds]); y=d[dv]; w=d[wcol]
    m=sm.WLS(y,X,weights=w).fit()
    # robust (sandwich) SE like svy linearized
    m2=sm.WLS(y,X,weights=w).fit(cov_type='HC1')
    return len(d), m, m2

print("=== Model 1: aweight swensenfav ~ innuendo denial causal ===")
n,m,m2=fit('swensenfav',['innuendo','denial','causal'],'aw')
print('N',n)
print(m.params[['innuendo','denial','causal','const']])
print('SE',m.bse[['innuendo','denial','causal','const']])

print("=== Model 3: aweight acceptedbribes ===")
n,m,m2=fit('acceptedbribes',['innuendo','denial','causal'],'aw')
print('N',n, m.params[['innuendo','denial','causal']], m.bse[['innuendo','denial','causal']])

print("=== Model 5: aweight resigninvest ~ denial causal ===")
n,m,m2=fit('resigninvest',['denial','causal'],'aw')
print('N',n, m.params[['denial','causal']], m.bse[['denial','causal']])

print("=== Model 2: svy swensenfav (HC1 robust) ===")
n,m,m2=fit('swensenfav',['innuendo','denial','causal'],'weight')
print('N',n, 'coef',m2.params[['innuendo','denial','causal']],'SE',m2.bse[['innuendo','denial','causal']])

print("=== Model 4: svy acceptedbribes ===")
n,m,m2=fit('acceptedbribes',['innuendo','denial','causal'],'weight')
print('N',n, 'coef',m2.params[['innuendo','denial','causal']],'SE',m2.bse[['innuendo','denial','causal']])

print("=== Model 6: svy resigninvest ===")
n,m,m2=fit('resigninvest',['denial','causal'],'weight')
print('N',n, 'coef',m2.params[['denial','causal']],'SE',m2.bse[['denial','causal']])
