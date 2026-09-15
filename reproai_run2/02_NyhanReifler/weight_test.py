import pandas as pd, numpy as np, scipy.stats as st
import statsmodels.api as sm

DATA = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\downloads\orig\jeps\JEPS replication\causal-replication.dta'
d = pd.read_stata(DATA)

def wls(ycol, xcols, wcol):
    m = d[[ycol]+xcols+[wcol]].dropna()
    Y = m[ycol].values; X = sm.add_constant(m[xcols].values); w = m[wcol].values
    res = sm.WLS(Y, X, weights=w).fit()
    return res, m, ['const']+xcols

def diff(res, names, a, b):
    ia, ib = names.index(a), names.index(b)
    cp = np.asarray(res.cov_params())
    return res.params[ia]-res.params[ib]

for wcol in ['aw','weight']:
    print('##### weight =', wcol)
    res,m,names = wls('swensenfav',['innuendo','denial','causal'],wcol)
    print('  MODEL2 svy swensenfav: denial coef=%.3f' % res.params[names.index('denial')],
          ' causal-innuendo diff=%.3f' % diff(res,names,'causal','innuendo'))
    res,m,names = wls('acceptedbribes',['innuendo','denial','causal'],wcol)
    print('  MODEL4 svy acceptedbribes: causal-denial diff=%.3f' % diff(res,names,'causal','denial'))
    res,m,names = wls('resigninvest',['denial','causal'],wcol)
    print('  MODEL6 svy resigninvest: causal-denial diff=%.3f' % diff(res,names,'causal','denial'))
