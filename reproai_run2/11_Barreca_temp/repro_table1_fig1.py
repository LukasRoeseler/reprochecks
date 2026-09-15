import pandas as pd
import numpy as np

DATA = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\11_Barreca_temp\data\DATA_1900_2004.dta'

df = pd.read_stata(DATA, convert_categoricals=False)

def wtmean(x, w):
    return (x * w).sum() / w.sum()

print("=== TABLE 1: All-age mortality rate (per 100,000) ===")
for lo, hi, lab in [(1900, 1959, '1900-1959'), (1960, 2004, '1960-2004')]:
    d = df[(df.year >= lo) & (df.year <= hi)].copy()
    g = d.groupby(['stfips', 'year']).agg(dths=('dths_tot', 'sum'), tp=('totalpop', 'mean'))
    g = g[g.dths != 0]
    g['drate'] = 100000 * g.dths / g.tp
    print(f"{lab}: weighted-mean drate = {wtmean(g.drate, g.tp):.1f} ; raw mean = {g.drate.mean():.1f}")

print("\n=== TABLE 1: avg days in temp bins per year (state-year) ===")
for lo, hi, lab in [(1900, 1959, '1900-1959'), (1960, 2004, '1960-2004')]:
    d = df[(df.year >= lo) & (df.year <= hi)].copy()
    g = d.groupby(['stfips', 'year']).agg(b10_4=('b10_4', 'sum'), b10_9=('b10_9', 'sum'),
                                          b10_10=('b10_10', 'sum'), tp=('totalpop', 'mean'))
    print(f"{lab}: days 30-39F={wtmean(g.b10_4, g.tp):.1f}  80-89F={wtmean(g.b10_9, g.tp):.1f}  >90F={wtmean(g.b10_10, g.tp):.2f}")

print("\n=== FIGURE 1: avg days/yr in each of 10 bins (pop-weighted) ===")
g = df.groupby(['stfips', 'year']).agg(**{f'b10_{i}': (f'b10_{i}', 'sum') for i in range(1, 11)},
                                      tp=('totalpop', 'mean'))
tot = 0
for i in range(1, 11):
    v = wtmean(g[f'b10_{i}'], g.tp)
    tot += v
    print(f"b10_{i}: {v:.1f}")
print("sum:", round(tot, 1))
