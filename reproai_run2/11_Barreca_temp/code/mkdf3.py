import pandas as pd, numpy as np
import statsmodels.api as sm
base=r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\11_Barreca_temp\data"
df=pd.read_pickle(base+r"\df2.pkl")
df=df.reset_index(drop=True)
mi=pd.MultiIndex.from_arrays([df["stfips"].values, df["ym"].values.astype(np.int64)])
df=df.set_index(mi)
prev=pd.MultiIndex.from_arrays([df["stfips"].values, (df["ym"].values-1).astype(np.int64)])
for v,bv in [("i1","i1_ph"),("i2","i2_ac")]:
    for b in ["b10_4","b10_9","b10_10"]:
        df[f"{v}_{b}"]=df[bv]*df[b]
sub=df[["i1_b10_10","i1_b10_9","i1_b10_4","i2_b10_10","i2_b10_9","i2_b10_4"]]
pv=sub.reindex(prev); pv.index=df.index
for c in sub.columns:
    df["L1"+c]=pv[c].values
    df["D1"+c]=sub[c].values-pv[c].values
df=df.reset_index()
df.to_pickle(base+r"\df3.pkl")
print("df3 saved", df.shape)
