import pandas as pd, numpy as np, scipy.stats as st
import statsmodels.api as sm

DATA = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\downloads\orig\jeps\JEPS replication\causal-replication.dta'
d = pd.read_stata(DATA)

def wls_fit(ycol, xcols, wcol='aw'):
    m = d[[ycol]+xcols+[wcol]].dropna()
    Y = m[ycol].values
    X = sm.add_constant(m[xcols].values)
    w = m[wcol].values
    res = sm.WLS(Y, X, weights=w).fit()
    names = ['const']+xcols
    return res, m, names

def diff_test(res, names, a, b):
    ia, ib = names.index(a), names.index(b)
    diff = res.params[ia]-res.params[ib]
    cp = np.asarray(res.cov_params())
    var = cp[ia,ia]+cp[ib,ib]-2*cp[ia,ib]
    se = np.sqrt(var)
    t = diff/se
    p = 2*(1-st.t.cdf(abs(t), res.df_resid))
    return diff, t, p

print('='*70)
print('MODEL 1: reg swensenfav innuendo denial causal [aweight=aw]')
res,m,names = wls_fit('swensenfav',['innuendo','denial','causal'])
print('n =', len(m))
for nm in names:
    print(f'  {nm:10s} coef={res.params[names.index(nm)]:.3f} se={res.bse[names.index(nm)]:.3f}')
for a,b in [('denial','innuendo'),('causal','innuendo'),('causal','denial')]:
    diff,t,p = diff_test(res,names,a,b)
    print(f'  lincom {a}-{b}: {diff:.3f}  t={t:.2f}  p={p:.4f}')

print('='*70)
print('MODEL 2: svy: reg swensenfav innuendo denial causal  (survey-weighted OLS)')
print('  -> requires survey design (strata/psu); replicating as WLS with aw *only* approximates coefs, NOT svy SEs')

print('='*70)
print('MODEL 3: reg acceptedbribes innuendo denial causal [aweight=aw]')
res,m,names = wls_fit('acceptedbribes',['innuendo','denial','causal'])
print('n =', len(m))
for nm in names:
    print(f'  {nm:10s} coef={res.params[names.index(nm)]:.3f} se={res.bse[names.index(nm)]:.3f}')
for a,b in [('denial','innuendo'),('causal','innuendo'),('causal','denial')]:
    diff,t,p = diff_test(res,names,a,b)
    print(f'  lincom {a}-{b}: {diff:.3f}  t={t:.2f}  p={p:.4f}')

print('='*70)
print('MODEL 5: reg resigninvest denial causal [aweight=aw]')
res,m,names = wls_fit('resigninvest',['denial','causal'])
print('n =', len(m))
for nm in names:
    print(f'  {nm:10s} coef={res.params[names.index(nm)]:.3f} se={res.bse[names.index(nm)]:.3f}')
diff,t,p = diff_test(res,names,'causal','denial')
print(f'  lincom causal-denial: {diff:.3f}  t={t:.2f}  p={p:.4f}')

print('='*70)
print('MODEL 4 & 6 (svy) need survey design; coefficients same as weighted but SEs differ.')
print('Per-cluster/strata design vars present in dta:')
design_cols = [c for c in d.columns if c in ('_svy_stratum','_svy_psu','_svy_weight','n',) ]
print(design_cols)
