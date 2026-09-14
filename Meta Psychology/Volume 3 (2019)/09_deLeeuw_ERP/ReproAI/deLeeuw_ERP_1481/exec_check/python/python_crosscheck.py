import sys, math, re
import numpy as np
import pandas as pd
from scipy import stats

print("==== START python crosscheck (status: running) ====")
base = r"C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check"
excluded = [8,21,11,23,25,40]

# ---------- Behavioral accuracy (Table 1), independent of R ----------
beh = pd.read_csv(base + "/data/generated/beh_data_tidy.csv")
beh = beh[~beh['subject_id'].astype(int).isin(excluded)]
beh = beh[~beh['syntax_cat'].isin(['Filler-Gram','Filler-Ungram'])]
acc = beh.groupby(['syntax_cat','subject_id'])['correct'].mean()*100
t1 = acc.groupby('syntax_cat').agg(['mean','std'])
print("Table 1 behavioral accuracy (paper: LG 93.3(5.3), LU 88.2(18.0), MN 84.5(14.5), MO 69.1(15.5)):")
print(t1.round(4).to_string())

# ---------- EEG mean amplitudes ----------
eeg = pd.read_csv(base + "/data/generated/eeg_data_tidy.csv",
                  dtype={'electrode':str,'subject':str,'stimulus.condition':str,'grammar.condition':str})
eeg['subject'] = eeg['subject'].astype(int)
eeg = eeg[~eeg['subject'].isin(excluded)]
lat = [33,39,42,45,70,83,93,108,115,122]
mid = [11,62,129]
P = (500,800)

def agg(d, elecs, stim):
    d = d[(d['electrode'].isin(list(map(str,elecs)))) & (d['t']>=P[0]) & (d['t']<=P[1]) & (d['stimulus.condition']==stim)]
    g = d.groupby(['subject','electrode','grammar.condition'])['voltage'].mean().reset_index()
    return g

def between_subject_two_way(df, fa, fb, val, wid='subject'):
    # within-subjects 2-way ANOVA via SS decomposition (sphericity-assumed)
    n = df[wid].nunique()
    a = df[fa].nunique(); b = df[fb].nunique()
    grand = df[val].mean()
    ma = df.groupby(fa)[val].mean(); mb = df.groupby(fb)[val].mean()
    mab = df.groupby([fa,fb])[val].mean()
    ms = df.groupby(wid)[val].mean()
    msa = df.groupby([wid,fa])[val].mean(); msb = df.groupby([wid,fb])[val].mean()
    SS_A = n*b*((ma-grand)**2).sum(); dfA=a-1
    SS_B = n*a*((mb-grand)**2).sum(); dfB=b-1
    SS_AB = n*((mab - ma - mb + grand)**2).sum(); dfAB=(a-1)*(b-1)
    def errt(dfx, fa_fb):
        tmp = df.merge(dfx.reset_index().rename(columns={val:'_X'}), on=fa_fb, how='left')
        return tmp
    # SS_AxS
    waj = df.groupby([wid,fa])[val].mean().reset_index()
    w = waj.merge(ms.reset_index().rename(columns={val:'_ms'}), on=wid).merge(ma.reset_index().rename(columns={val:'_ma'}),on=fa)
    SS_AxS = (w['_ms'] if False else 0)
    # recompute straightforwardly
    sub = df.groupby(wid)[val].mean()
    SA = 0.0
    for (s,aa),v in msa.items():
        SA += b*(v - sub[s] - ma[aa] + grand)**2
    dfAs = (n-1)*dfA
    SB = 0.0
    for (s,bb),v in msb.items():
        SB += a*(v - sub[s] - mb[bb] + grand)**2
    dfBs = (n-1)*dfB
    SAB = 0.0
    piv = df.pivot_table(index=[wid], columns=[fa,fb], values=val)
    total = 0.0
    for (s,row) in piv.iterrows():
        for (aa,bb),x in row.items():
            total += (x - msa.get((s,aa),msa[(s,aa)]) - msb.get((s,bb),msb[(s,bb)]) - mab[(aa,bb)] + sub[s] + ma[aa] + mb[bb] - grand)**2
    dfABs = (n-1)*dfAB
    FA=(SS_A/dfA)/(SA/dfAs); FB=(SS_B/dfB)/(SB/dfBs); FAB=(SS_AB/dfAB)/(total/dfABs)
    pA=1-stats.f.cdf(FA,dfA,dfAs); pB=1-stats.f.cdf(FB,dfB,dfBs); pAB=1-stats.f.cdf(FAB,dfAB,dfABs)
    return dict(A=(FA,dfA,dfAs,pA), B=(FB,dfB,dfBs,pB), AB=(FAB,dfAB,dfABs,pAB))

results = {}
for name, elecs, stim in [("Language-Midline",mid,"Language"),("Language-Lateral",lat,"Language"),
                           ("Music-Midline",mid,"Music"),("Music-Lateral",lat,"Music")]:
    d = agg(eeg, elecs, stim)
    res = between_subject_two_way(d,'electrode','grammar.condition','voltage')
    results[name]=res
    print(f"\nTable2 {name}: Gram F={res['A'][0]:.4f} p={res['A'][3]:.5f} | Elec F={res['B'][0]:.4f} p={res['B'][3]:.5f} | GxE F={res['AB'][0]:.4f} p={res['AB'][3]:.6f}")
print("\nPython: done.")
print("==== END python crosscheck (status: OK) ====")
