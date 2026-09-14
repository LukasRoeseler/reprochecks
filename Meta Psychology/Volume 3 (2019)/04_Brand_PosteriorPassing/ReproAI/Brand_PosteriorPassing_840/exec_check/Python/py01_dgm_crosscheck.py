"""
py01_dgm_crosscheck.py -- RE-AUDIT cross-language check (Python 3.8) of the paper's
data-generating model + ANOVA, to confirm the R from-scratch reimplementation did not
inherit a single-language bug.

Paper convention (Brand et al. 2019, MP.2017.840):
  p = plogis(performance + e*condition*sex); performance ~ doppelganger-quadrangle
  (pop. mean exactly 0, within-sex variance equal); 80 participants/experiment, 25
  trials, 20 per sex/condition cell.
Checks: (1) e->P(correct) mapping (C8); (2) ANOVA interaction coefficient (prob scale)
UNDERestimates the log-odds truth e and declines with variance (C27) -- cross-checks the
R result (03) and the shipped table; (3) at e=0 the ANOVA false-positive rate is ~5%
(C21). A GLMM-recovery check is done in R (lme4) because Python 3.8 statsmodels has no
fast binomial GLMM and a fixed-effects logistic shows complete separation at high e.
"""
import numpy as np
from scipy.special import expit
import statsmodels.api as sm

np.random.seed(20260914)
n_people = 1_000_000
n_ppt, n_trial, n_ex = 80, 25, 60
es = [0.0, 0.5, 1.0, 1.5, 2.0]
vs = [0.0, 0.25, 0.5, 0.75, 1.0]

def make_pop(var_base):
    d = np.random.normal(0, abs(var_base), n_people // 4)
    return np.concatenate([d, -d, d, -d])

def make_experiment(pop, e):
    s0 = np.random.choice(n_people//2, n_ppt//2, replace=False)
    s1 = np.random.choice(n_people//2, n_ppt//2, replace=False) + n_people//2
    dbase = pop[np.concatenate([s0, s1])]
    sex = np.concatenate([np.zeros(n_ppt//2), np.ones(n_ppt//2)])
    dum = np.array([0]*(n_ppt//4) + [1]*(n_ppt//4))
    cond = np.concatenate([np.random.permutation(dum), np.random.permutation(dum)])
    lp = e * sex * cond + dbase
    resp = np.array([np.mean(np.random.uniform(0, 1, n_trial) < p) for p in expit(lp)])
    return sex, cond, resp

print("=== (1) e -> P(correct) mapping (paper: 0.5,0.62,0.73,0.82,0.88; e=2 -> +0.38) ===")
for e in es:
    print(f"  e={e}: P={expit(e):.4f}, increase={expit(e)-0.5:.4f}")

print("\n=== (2) ANOVA interaction (prob scale) by variance at e=2 (underestimation; R gave 0.385->0.335) ===")
for v in vs:
    pop = make_pop(v)
    e_est = []
    for r in range(20):
        sex, cond, resp = make_experiment(pop, 2.0)
        X = sm.add_constant(np.column_stack([sex, cond, sex*cond]))
        b = np.linalg.lstsq(X, resp, rcond=None)[1:]  # noqa
        b = np.linalg.lstsq(X, resp, rcond=None)[0]
        e_est.append(b[3])
    print(f"  var={v:.2f}: ANOVA interaction est = {np.mean(e_est):.3f}   (true log-odds e=2)")

print("\n=== (3) ANOVA false-positive rate at e=0 (paper 304/6000=5.07%) ===")
fp, nds = 0, 0
for v in vs:
    pop = make_pop(v)
    for r in range(8):
        for _ in range(n_ex):
            sex, cond, resp = make_experiment(pop, 0.0)
            X = sm.add_constant(np.column_stack([sex, cond, sex*cond]))
            fit = sm.OLS(resp, X).fit()
            fp += (fit.pvalues[3] < 0.05)
            nds += 1
print(f"  N datasets={nds}, FP={fp} ({100*fp/nds:.2f}%)   [paper: 5.07%; R from-scratch (seed 20260914): 5.33%]")
