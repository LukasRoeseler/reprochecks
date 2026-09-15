import pandas as pd, numpy as np
import statsmodels.api as sm

base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\11_Barreca_temp\data"
df = pd.read_pickle(base + r"\df.pkl")
# faithful: b10_4 becomes cumulative (bins 1-4) BEFORE constructing lags/diffs, like the .do file
df["b10_4"] = df["b10_4"]+df["b10_3"]+df["b10_2"]+df["b10_1"]

def build(d, label):
    d = d.copy()
    d["year2"] = d["year"]**2
    d["yearmo"] = d["year"]*1000 + d["month"]
    for m in range(2,13):
        d[f"m{m}"] = (d["month"]==m).astype(float)
    for v in ["sh_0000","sh_4564","sh_6599","lri"]:
        for m in range(2,13):
            d[f"{v}_m{m}"] = d[v]*d[f"m{m}"]
    states = sorted(d["stfips"].unique())
    for s in states[1:]:
        d[f"s{int(s)}"] = (d["stfips"]==s).astype(float)
        d[f"s{int(s)}_y"] = d[f"s{int(s)}"]*d["year"]
        d[f"s{int(s)}_y2"] = d[f"s{int(s)}"]*d["year2"]
    yms = sorted(d["yearmo"].unique())
    for y in yms[1:]:
        d[f"ym{int(y)}"] = (d["yearmo"]==y).astype(float)
    fixed = ["D1_b10_4","D1_b10_9","D1_b10_10","L1_b10_10","L1_b10_9","L1_b10_4",
             "devp25","devp75","sh_0000","sh_4564","sh_6599","lri"]
    cols = fixed + [c for c in d.columns if (c.startswith("sh_0000_m") or c.startswith("sh_4564_m") or c.startswith("sh_6599_m") or c.startswith("lri_m"))]
    cols += [c for c in d.columns if c.startswith("ym")]
    cols += [c for c in d.columns if (c.startswith("s") and (c.endswith("_y") or c.endswith("_y2")) or c.startswith("s") and c[1:5].isdigit() and len(c)<=4)]
    X = d[cols].astype(float).values
    y = d["lndrate"].astype(float).values
    w = d["totalpop"].astype(float).values
    ok = ~np.isnan(y) & ~np.isnan(X).any(axis=1) & (w>0)
    return X[ok], y[ok], w[ok], d["stfips"].values[ok], cols

def fit(label, df, lo, hi):
    d = df[(df["year"]>=lo)&(df["year"]<=hi)]
    X,y,w,st,cols = build(d, label)
    Xw = sm.add_constant(X, has_constant="add")
    res = sm.WLS(y, Xw, weights=w).fit(cov_type="cluster", cov_kwds={"groups": st})
    names = ["const"]+cols
    print(f"== {label} n={int(res.nobs)} ==")
    for v in ["D1_b10_4","D1_b10_9","D1_b10_10","L1_b10_10","L1_b10_9","L1_b10_4"]:
        i=names.index(v); b=res.params[i]; se=res.bse[i]
        print(f"   {v:12s} b={b:+.5f} se={se:.5f}")
    # sum current+lag for hot bins
    print("   D1+L1 b10_10 =", res.params[names.index("D1_b10_10")]+res.params[names.index("L1_b10_10")])
    print("   D1+L1 b10_9  =", res.params[names.index("D1_b10_9")]+res.params[names.index("L1_b10_9")])

fit("1931-2004", df, 1930, 2004)
fit("1931-1959", df, 1930, 1959)
fit("1960-2004", df, 1960, 2004)
