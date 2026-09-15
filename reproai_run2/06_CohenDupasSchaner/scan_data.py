#!/usr/bin/env python
import pandas as pd
dir = "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/06_CohenDupasSchaner/downloads"
for f in ["ACT_IllLvlMainWithMalProbs_FINAL_pub.dta","ACT_PharmLogPos_FINAL_pub.dta"]:
    df = pd.read_stata(dir+"/"+f)
    print("="*70)
    print("FILE:", f)
    print("shape:", df.shape)
    print("columns:", list(df.columns))
