#!/usr/bin/env python3
"""ReproAI re-audit (2026-09-14) - independent Python recompute of Witt (2019) MP.2018.895.
Cross-language check (REPRO_S5) of the closed-form, deterministic headline statistics
(per-condition slopes, bias %, paired t-tests, one-sample t-tests, dz).
Bayes factors are computed in R (BayesFactor package); this script independently verifies
the t, p, dz, and means/SDs that feed them. No RNG used -> deterministic.
"""
import pandas as pd, numpy as np
from scipy import stats

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\07_Witt_GraphConstruction\ReproAI\Witt_GraphConstruction_895"

def condcode(g):
    g = str(g).lower()
    if g == 'full': return 1
    if g == 'sd':   return 2
    if g in ('small','min','minimal'): return 3
    return np.nan

def codecorr(e):
    m = {0:1.0, 1:1.5, 3:2.0, 5:3.0, 8:4.0}
    return [m.get(v, np.nan) for v in e]

def load(f, subjfilter=None):
    df = pd.read_csv(f"{BASE}\\data\\{f}")
    if 'axisRange' in df.columns:
        df = df.rename(columns={'axisRange':'graphType'})
    if subjfilter is not None:
        df = df[subjfilter(df)]
    df['corr'] = codecorr(df['effectSize'])
    df['corrC'] = df['corr'] - 2.5
    df['cond'] = df['graphType'].map(condcode)
    df = df.dropna(subset=['cond','corr'])
    return df

def per_subj(df, excl, dcrit=None):
    sub = df[~df['Subject'].isin(excl)]
    if dcrit is not None:
        sub = sub[sub['effectSize'] > dcrit]
    rows = []
    for s in sorted(sub['Subject'].unique()):
        for cc in (1,2,3):
            d = sub[(sub['Subject']==s) & (sub['cond']==cc)]
            X = d['corrC'].values; Y = d['resp'].values
            b, i = np.polyfit(X, Y, 1)
            rows.append((s, cc, b, i, (i-2.5)/2.5*100))
    A = pd.DataFrame(rows, columns=['subj','cond','coef','intercept','bias'])
    return A

def summarize(A):
    md = [A.loc[A['cond']==cc,'coef'].mean() for cc in (1,2,3)]
    sd = [A.loc[A['cond']==cc,'coef'].std(ddof=1) for cc in (1,2,3)]
    return md, sd

def wide(A, col):
    piv = A.pivot(index='subj', columns='cond', values=col).sort_index()
    return [piv[cc].values for cc in (1,2,3)]

def pairstats(x, y):
    t, p = stats.ttest_rel(x, y)
    n = len(x)
    dz = abs(t)/np.sqrt(n)
    return t, p, dz

def ones(x):
    t, p = stats.ttest_1samp(x, 0)
    n = len(x)
    dz = abs(t)/np.sqrt(n)
    return t, p, dz, np.mean(x), np.std(x, ddof=1)

EXPS = [
    (1, "axisSize 1-24.csv",     [1,8],      lambda d: d['Subject']<10),
    (2, "axisSize 1-24.csv",     [13,17,24], lambda d: d['Subject']>9),
    (3, "axisRangeEBv2 1-14.csv",[3,4],      None),
    (4, "axisRangeLineV2 1-20.csv",[4,9,15,16], None),
    (5, "axisRangeLine 1-14.csv",[7,13],     None),
]
print("==== PYTHON INDEPENDENT RECOMPUTE ====")
print("python", __import__('sys').version)
for exp, f, excl, filt in EXPS:
    df = load(f, filt)
    A = per_subj(df, excl)
    md, sd = summarize(A)
    wb = wide(A, 'coef'); wB = wide(A, 'bias')
    n = A['subj'].nunique()
    t_sp,fsp,dz_sp = pairstats(wb[1], wb[0])
    t_sm,fsm,dz_sm = pairstats(wb[1], wb[2])
    print(f"\n=== Exp{exp} (N={n}) ===")
    print(f"  slopes Full={md[0]:.3f}({sd[0]:.3f}) Std={md[1]:.3f}({sd[1]:.3f}) Min={md[2]:.3f}({sd[2]:.3f})")
    for lbl,(t,p,dz) in {"SDvsFull":(t_sp,fsp,dz_sp),"SDvsMin":(t_sm,fsm,dz_sm)}.items():
        print(f"  {lbl}: t={t:.3f} p={p:.4f} dz={dz:.3f}")
    for lbl,cc in {"Full bias":1,"Std bias":2,"Min bias":3}.items():
        t,p,dz,m,s = ones(wB[cc-1])
        print(f"  {lbl}: M={m:.2f} SD={s:.2f} t={t:.3f} p={p:.4f} dz={dz:.3f}")
print("\n==== DONE (status: OK) ====")
