#!/usr/bin/env python
import pandas as pd
import statsmodels.formula.api as smf

dir = "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
ill = pd.read_stata(dir+"/ACT_IllLvlMainWithMalProbs_FINAL_pub.dta")

# Table 3 column 3: group==2 (endline) from all_ill_prob
d = ill[(ill['ex_post']==0) & (ill['rdt_any']==0) & (ill['took_act']==1) & (ill['act500']==0) & (ill['first_ep']==1)].copy()
d['group']=2
d['all']=1
d['young']= (d['adult']==0).astype(int)
d['mal_probC']= d['mal_prob2'] if 'mal_prob2' in d else None
print("Table3 col3 group==2 sample N:", len(d))
dc = d.dropna(subset=['mal_prob2','act60','act100','householdid'])
print("estimation N:", len(dc))
md = smf.ols("mal_prob2 ~ act60 + act100", data=dc).fit(cov_type='cluster', cov_kwds={'groups': dc['householdid']}, use_t=True)
for v in ['act60','act100']:
    pv = md.pvalues[v]
    print(f"Table3 col3 {v}: coef={md.params[v]:.4f}  se={md.bse[v]:.4f}  p={pv:.3f}")

# DV mean: sum mal_prob2 if e(sample) & act40 & rdt_any==0
est = dc
m = est.loc[(est['act40']==1) & (est['rdt_any']==0), 'mal_prob2'].mean()
print("DV mean (act40, no rdt):", round(m,3))
print("N in DV mean:", int(len(est[(est['act40']==1) & (est['rdt_any']==0)])))
