import pandas as pd
import numpy as np
import scipy.sparse as sp
import scipy.sparse.linalg as spla

DATA = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\11_Barreca_temp\data\DATA_1900_2004.dta'
df = pd.read_stata(DATA, convert_categoricals=False)

bins3 = ['b10_10', 'b10_9', 'b10_4']  # >90, 80-89, <40 (b10_4 combined later)

def run_period(df, lo, hi, label):
    d = df[(df.year >= lo) & (df.year <= hi)].copy()
    d = d.sort_values(['stfips', 'year', 'month']).reset_index(drop=True)
    # statemo / yearmo
    d['yearmo'] = (d['year'] * 1000 + d['month']).astype(int)
    d['statemo'] = (d['stfips'] * 1000 + d['month']).astype(int)
    d['ymdate'] = (d['year'] * 12 + (d['month'] - 1)).astype(int)
    # combine <40F
    for cc in ['b10_4', 'b10_3', 'b10_2', 'b10_1']:
        d['b10_4'] = d['b10_4'] + d[cc]
    d = d.drop(columns=['b10_1', 'b10_2', 'b10_3'])
    # month dummies
    for i in range(2, 13):
        d[f'm{i}'] = (d['month'] == i).astype(float)
    # share/lri month interactions
    for v in ['sh_0000', 'sh_4564', 'sh_6599', 'lri']:
        for i in range(2, 13):
            d[f'{v}_m{i}'] = d[v] * d[f'm{i}']
    # lags and first differences within stfips (sorted by ymdate)
    d = d.sort_values(['stfips', 'ymdate'])
    grp = d.groupby('stfips')
    for b in bins3:
        d['L1_' + b] = grp[b].shift(1)
        d['D1_' + b] = d[b] - d['L1_' + b]
    d['year2'] = d['year'] ** 2
    # outcome listwise
    model_cols = (['lndrate', 'D1_b10_4', 'D1_b10_9', 'D1_b10_10',
                   'L1_b10_10', 'L1_b10_9', 'L1_b10_4',
                   'devp25', 'devp75', 'sh_0000', 'sh_4564', 'sh_6599', 'lri']
                  + [f'sh_0000_m{i}' for i in range(2, 13)]
                  + [f'sh_4564_m{i}' for i in range(2, 13)]
                  + [f'sh_6599_m{i}' for i in range(2, 13)]
                  + [f'lri_m{i}' for i in range(2, 13)])
    base = ['stfips', 'yearmo', 'statemo', 'year', 'year2', 'totalpop', 'ymdate']
    sub = d.dropna(subset=model_cols + base).copy()
    sub = sub[model_cols + base].reset_index(drop=True)
    print(f"[{label}] rows (non-missing) = {len(sub)}")
    # ---- FE matrix Z ----
    n = len(sub)
    sm = np.array(sub['statemo'].astype(int))
    ym = np.array(sub['yearmo'].astype(int))
    yr = np.array(sub['year'].values, float)
    yr2 = np.array(sub['year2'].values, float)
    w = np.array(sub['totalpop'].values, float)
    # center year within statemo
    yr_c = yr.copy(); yr2_c = yr2.copy()
    for s in np.unique(sm):
        m = sm == s
        yr_c[m] = yr[m] - yr[m].mean()
        yr2_c[m] = yr2[m] - yr2[m].mean()
    blocks = []
    imap = {v: i for i, v in enumerate(np.unique(ym))}
    ym_idx = np.array([imap[v] for v in ym])
    blocks.append(sp.csc_matrix((np.ones(n), (np.arange(n), ym_idx)), shape=(n, len(imap))).tocsr())
    smap = {v: i for i, v in enumerate(np.unique(sm))}
    sm_idx = np.array([smap[v] for v in sm])
    blocks.append(sp.csc_matrix((np.ones(n), (np.arange(n), sm_idx)), shape=(n, len(smap))).tocsr())
    maps = {v: i for i, v in enumerate(np.unique(sm))}
    sm_idx2 = np.array([maps[v] for v in sm])
    blocks.append(sp.csc_matrix((yr_c, (np.arange(n), sm_idx2)), shape=(n, len(maps))).tocsr())
    blocks.append(sp.csc_matrix((yr2_c, (np.arange(n), sm_idx2)), shape=(n, len(maps))).tocsr())
    Z = sp.hstack(blocks).tocsr()
    del blocks, imap, smap, maps
    # ---- weight ----
    Xnames = [c for c in model_cols if c != 'lndrate']
    Xn = len(Xnames)
    Xmat = sub[Xnames].values
    y = sub['lndrate'].values
    # W-projection: M = (Z'WZ)^-1 Z'W
    WZ = Z.T.multiply(w).tocsr()
    ZWZ = (WZ @ Z).tocsr()
    M = sp.linalg.spsolve(ZWZ.tocsc(), WZ.tocsc())  # pZ x n, dense
    def res(v):
        return v - Z @ (M @ v)
    yr2_ = res(y)
    Xr = np.column_stack([res(Xmat[:, j]) for j in range(Xn)])
    # weighted OLS on residualized
    sw = np.sqrt(w)
    sw = sw / sw.sum() * n  # normalize weights like analytic weights (sum to n)
    Xw = Xr * sw[:, None]
    yw = yr2_ * sw
    coef, res_, rank, sv = np.linalg.lstsq(Xw, yw, rcond=None)
    resid = yw - Xw @ coef
    sserr = (resid ** 2).sum()
    dof = n - Xn - Z.shape[1] + 1  # approx; FE rank approx Z cols
    # cluster-robust (somewhat approximate due to FE rank)
    XtWX = Xr.T @ (w[:, None] * Xr)
    XtWX_inv = np.linalg.inv(XtWX)
    meat = np.zeros((Xn, Xn))
    st_cl = np.array(sub['stfips'].values)
    for s in np.unique(st_cl):
        mm = st_cl == s
        u = Xr[mm].T @ (w[mm] * yr2_[mm])  # X'W e within cluster (using untransformed e approx)
        meat += np.outer(u, u)
    V = XtWX_inv @ meat @ XtWX_inv
    se = np.sqrt(np.diag(V))
    out = {}
    for j, nm in enumerate(Xnames):
        out[nm] = (coef[j], se[j])
    print(f"[{label}] --- key coefficients (coef, se) ---")
    for k in ['L1_b10_10', 'L1_b10_9', 'L1_b10_4', 'D1_b10_10', 'D1_b10_9', 'D1_b10_4']:
        print(f"  {k}: {out[k][0]:.5f} (se {out[k][1]:.5f})")
    return out

for lo, hi, lab in [(1930, 2004, '1931-2004'), (1930, 1959, '1931-1959'), (1960, 2004, '1960-2004')]:
    run_period(df, lo, hi, lab)
