#!/usr/bin/env python
import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf

dir = "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
df = pd.read_stata(dir+"/ACT_IllLvlMainWithMalProbs_FINAL_pub.dta")

# Table 2 sample selection
d = df[(df['first_ep']==1) & (df['ex_post']==0) & (df['rdt_any']==0)].copy()
d['act_any'] = (d['act40']==1) | (d['act60']==1) | (d['act100']==1)
d['act_any'] = d['act_any'].astype(int)

print("Table 2 sample N:", len(d))
print("took_act mean in control:", d.loc[d['act_any']==0,'took_act'].mean())

outcomes = ['took_act','took_act_chem','took_act_hc','care_chem','care_hc','care_nothing','took_maltest','took_antibio']

# Spec 1: pooled act_any
base_cov = ['act_any','totstrata','ex_post','B_head_age_imputed','B_head_age_missing']

def run(o, treat_vars):
    cols = [o]+treat_vars+['totstrata','ex_post','B_head_age_imputed','B_head_age_missing','householdid']
    dc = d.dropna(subset=cols).copy()
    f = f"{o} ~ " + " + ".join(treat_vars) + " + C(totstrata) + ex_post + B_head_age_imputed + B_head_age_missing"
    md = smf.ols(f, data=dc).fit(cov_type='cluster', cov_kwds={'groups': dc['householdid']}, use_t=True)
    return md, dc

print("\n==== SPEC 1 (act_any pooled) ====")
for o in outcomes:
    md, dc = run(o, ['act_any'])
    b = md.params['act_any']; se = md.bse['act_any']
    print(f"{o:16s} act_any coef={b:.4f}  se={se:.4f}  N={int(md.nobs)}")

# Spec 2: act40 act60 act100
print("\n==== SPEC 2 (act40 act60 act100) ====")
for o in outcomes:
    md, dc = run(o, ['act40','act60','act100'])
    for v in ['act40','act60','act100']:
        print(f"{o:16s} {v} coef={md.params[v]:.4f}  se={md.bse[v]:.4f}")
    print(f"              N={int(md.nobs)}")

# DV means (control group, act500==0)
for o in outcomes:
    m = d.loc[(d['act500']==0) & (d['act_any']==0), o].mean()
    print(f"DV mean control ({o}): {m:.3f}")
