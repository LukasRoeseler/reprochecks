#!/usr/bin/env python
import pandas as pd
dir = "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
ill = pd.read_stata(dir+"/ACT_IllLvlMainWithMalProbs_FINAL_pub.dta")
d = ill[(ill['first_ep']==1) & (ill['ex_post']==0) & (ill['rdt_any']==0)].copy()
ctrl = d[d['act500']==1]
print("Table2 control (act500) N:", len(ctrl), "took_act mean:", round(ctrl['took_act'].mean(),3))
trt = d[d['act500']==0]
print("Table2 any-subsidy N:", len(trt), "took_act mean:", round(trt['took_act'].mean(),3))
# percentage increase claim: 16-23pp, 85-118%
print("control takeup:", round(ctrl['took_act'].mean(),3))
