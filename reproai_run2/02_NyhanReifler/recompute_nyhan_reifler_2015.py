"""ReproAI independent recomputation of Nyhan & Reifler (2015), JExpPoliSci.

Recomputes the six Table 2 OLS models and the bushel-trace contrast claims
from the shared reproduction data (causal-replication.dta, OSF FLoRA node
5vx27 / component "Data", guid 86zqr) using the aweight ('aw') and survey
('weight') weights.

Models (matching nyhan-reifler-causal-corrections.do):
  M1: swensenfav    ~ innuendo denial causal [aweight=aw]       (Table2 M1)
  M2: swensenfav    ~ innuendo denial causal [pweight=weight]   (Table2 M2, survey)
  M3: acceptedbribes~ innuendo denial causal [aweight=aw]       (Table2 M3)
  M4: acceptedbribes~ innuendo denial causal [pweight=weight]   (Table2 M4, survey)
  M5: resigninvest   ~ denial causal           [aweight=aw]     (Table2 M5)
  M6: resigninvest   ~ denial causal           [pweight=weight] (Table2 M6, survey)
"""
import pandas as pd
import numpy as np
import statsmodels.api as sm
from scipy import stats
import json, os

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "causal-replication.dta")
df = pd.read_stata(DATA)


def fit(dv, preds, wcol):
    d = df[[dv] + preds + [wcol]].dropna()
    X = sm.add_constant(d[preds])
    m = sm.WLS(d[dv], X, weights=d[wcol]).fit(cov_type="HC1")
    return len(d), m, preds


def contrast(m, preds, ca, cb):
    cov = m.cov_params()
    diff = m.params[ca] - m.params[cb]
    se = np.sqrt(cov.loc[ca, ca] + cov.loc[cb, cb] - 2 * cov.loc[ca, cb])
    t = diff / se
    pv = 2 * (1 - stats.t.cdf(abs(t), m.df_resid))
    return diff, se, pv


res = {}

for label, wcol, preds, dv in [
    ("M1", "aw", ["innuendo", "denial", "causal"], "swensenfav"),
    ("M2", "weight", ["innuendo", "denial", "causal"], "swensenfav"),
    ("M3", "aw", ["innuendo", "denial", "causal"], "acceptedbribes"),
    ("M4", "weight", ["innuendo", "denial", "causal"], "acceptedbribes"),
    ("M5", "aw", ["denial", "causal"], "resigninvest"),
    ("M6", "weight", ["denial", "causal"], "resigninvest"),
]:
    n, m, preds = fit(dv, preds, wcol)
    r = {"n": int(n), "coef": {k: round(float(m.params[k]), 4) for k in preds}}
    if "innuendo" in preds:
        di, sei, pvi = contrast(m, preds, "causal", "innuendo")
        r["causal_vs_innuendo"] = [round(float(di), 4), round(float(pvi), 4)]
        r["denial_vs_control"] = round(float(m.params["denial"]), 4)
    di, sei, pvi = contrast(m, preds, "causal", "denial")
    r["causal_vs_denial"] = [round(float(di), 4), round(float(pvi), 4)]
    r["se"] = {k: round(float(m.bse[k]), 4) for k in preds}
    res[label] = r

print(json.dumps(res, indent=2))
with open(os.path.join(HERE, "_recompute.json"), "w") as f:
    json.dump(res, f, indent=2)
