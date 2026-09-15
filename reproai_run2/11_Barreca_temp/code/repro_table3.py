import pandas as pd, numpy as np, sys
import statsmodels.api as sm

base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\11_Barreca_temp\data"
df = pd.read_pickle(base + r"\df.pkl")

def build(d, label):
    d = d.copy()
    d["year2"] = d["year"]**2
    d["yearmo"] = d["year"]*1000 + d["month"]
    # month FE 2..12
    for m in range(2,13):
        d[f"m{m}"] = (d["month"]==m).astype(float)
    for v in ["sh_0000","sh_4564","sh_6599","lri"]:
        for m in range(2,13):
            d[f"{v}_m{m}"] = d[v]*d[f"m{m}"]
    # state dummies 2..max
    states = sorted(d["stfips"].unique())
    for s in states[1:]:
        d[f"s{int(s)}"] = (d["stfips"]==s).astype(float)
        d[f"s{int(s)}_y"] = d[f"s{int(s)}"]*d["year"]
        d[f"s{int(s)}_y2"] = d[f"s{int(s)}"]*d["year2"]
    # yearmo dummies
    yms = sorted(d["yearmo"].unique())
    for y in yms[1:]:
        d[f"ym{int(y)}"] = (d["yearmo"]==y).astype(float)
    fixed = ["D1_b10_4","D1_b10_9","D1_b10_10","L1_b10_10","L1_b10_9","L1_b10_4",
             "devp25","devp75","sh_0000","sh_4564","sh_6599","lri"]
    cols = fixed + [c for c in d.columns if (c.startswith("sh_0000_m") or c.startswith("sh_4564_m") or c.startswith("sh_6599_m") or c.startswith("lri_m"))]
    cols += [c for c in d.columns if c.startswith("ym")]
    cols += [c for c in d.columns if (c.startswith("s") and ("_y" in c or "_y2" in c)) or c.startswith("s") and c[1:].isdigit()]
    X = d[cols].astype(float)
    y = d["lndrate"].astype(float).values
    w = d["totalpop"].astype(float).values
    X = X.values
    # drop rows with NaN in X or y
    ok = ~(np.isnan(y)) & ~np.isnan(X).any(axis=1) & (w>0)
    X, y, w, st = X[ok], y[ok], w[ok], d["stfips"].values[ok]
    k = np.linalg.matrix_rank(X)
    print(f"[{label}] n={len(y)} rank(X)= {k} of {X.shape[1]}")
    return X, y, w, st, cols

def fit(label, lo, hi):
    d = df[(df["year"]>=lo)&(df["year"]<=hi)]
    X,y,w,st,cols = build(d, f"{lo}-{hi}")
    Xw = sm.add_constant(X, has_constant="add")
    mod = sm.WLS(y, Xw, weights=w)  # awa
    res = mod.fit(cov_type="cluster", cov_kwds={"groups": st})
    # Stata aweights: point estimate same as WLS with w -> yes (aweight=w). 
    names = ["const"]+cols
    focal = ["L1_b10_10","L1_b10_9","L1_b10_4"]
    print(f"== {label} ==")
    for f in focal:
        idx = names.index(f)
        b = res.params[idx]; se = res.bse[idx]; p = res.pvalues[idx]
        print(f"  {f}: b={b:.5f} se={se:.5f} p={p:.1e}  n={int(res.nobs)}")

fit("1931-2004", 1930, 2004)
fit("1931-1959", 1930, 1959)
fit("1960-2004", 1960, 2004)
