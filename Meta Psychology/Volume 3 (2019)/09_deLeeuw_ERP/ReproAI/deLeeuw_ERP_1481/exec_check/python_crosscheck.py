import pandas as pd
import numpy as np
import scipy.stats as st

base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check"
excluded = {8,21,11,23,25,40}
lateral = [33,39,42,45,70,83,93,108,115,122]
midline = [11,62,129]

def rm_anova_2w(cells):
    # cells: dict (subj, A, B) -> value. A and B within-subject, balanced.
    keys = list(cells.keys())
    subs = sorted(set(k[0] for k in keys))
    A = sorted(set(k[1] for k in keys)); B = sorted(set(k[2] for k in keys))
    na, nb = len(A), len(B)
    n = len(subs)
    Y = np.full((n, na, nb), np.nan)
    for (s,a,b),v in cells.items():
        Y[subs.index(s), A.index(a), B.index(b)] = v
    grand = Y.mean()
    a_means = Y.mean(axis=(0,2))          # (na,)
    b_means = Y.mean(axis=(0,1))          # (nb,)
    ab_means = Y.mean(axis=0)             # (na,nb)
    s_means = Y.mean(axis=(1,2))          # (n,)
    sa_means = Y.mean(axis=2)             # (n,na)
    sb_means = Y.mean(axis=1)             # (n,nb)
    SS_T = np.sum((Y-grand)**2)
    SS_A = n*nb*np.sum((a_means-grand)**2)
    SS_B = n*na*np.sum((b_means-grand)**2)
    SS_AB = n*np.sum((ab_means - a_means[:,None] - b_means[None,:] + grand)**2)
    SS_S = na*nb*np.sum((s_means-grand)**2)
    SS_SA = nb*np.sum((sa_means - s_means[:,None] - a_means[None,:] + grand)**2)
    SS_SB = na*np.sum((sb_means - s_means[:,None] - b_means[None,:] + grand)**2)
    SS_SAB = SS_T - SS_A - SS_B - SS_AB - SS_S - SS_SA - SS_SB
    df_A, df_B, df_AB = na-1, nb-1, (na-1)*(nb-1)
    df_SA = (n-1)*(na-1); df_SB=(n-1)*(nb-1); df_SAB = (n-1)*(na-1)*(nb-1)
    out={}
    out['A'] = ((SS_A/df_A)/(SS_SA/df_SA), df_A, df_SA, 1-st.f.cdf((SS_A/df_A)/(SS_SA/df_SA), df_A, df_SA))
    out['B'] = ((SS_B/df_B)/(SS_SB/df_SB), df_B, df_SB, 1-st.f.cdf((SS_B/df_B)/(SS_SB/df_SB), df_B, df_SB))
    out['AB'] = ((SS_AB/df_AB)/(SS_SAB/df_SAB), df_AB, df_SAB, 1-st.f.cdf((SS_AB/df_AB)/(SS_SAB/df_SAB), df_AB, df_SAB))
    return out

eeg = pd.read_csv(base+r"\data\generated\eeg_data_tidy.csv")
eeg = eeg[~eeg['subject'].isin(excluded)]
eeg = eeg[(eeg['t']>=500)&(eeg['t']<=800)]
print("rows in p600:", len(eeg))

def prep(df, elecs):
    d = df[df['electrode'].isin(elecs)]
    g = d.groupby(['subject','grammar.condition','electrode'], as_index=False)['voltage'].mean()
    return {(r[1], r[2], r[3]): r[4] for r in g.itertuples()}

language = eeg[eeg['stimulus.condition']=='Language']
music = eeg[eeg['stimulus.condition']=='Music']

for name, df, elecs in [("Lang Midline", language, midline),("Lang Lateral",language,lateral),
                        ("Music Midline",music,midline),("Music Lateral",music,lateral)]:
    cells = prep(df, elecs)
    r = rm_anova_2w(cells)
    print(f"--- {name} (B=grammar, A=electrode) ---")
    print(f"  electrode F={r['A'][0]:.4f} df=({r['A'][1]},{r['A'][2]}) p={r['A'][3]:.6f}")
    print(f"  grammar   F={r['B'][0]:.4f} df=({r['B'][1]},{r['B'][2]}) p={r['B'][3]:.6f}")
    print(f"  GxE       F={r['AB'][0]:.4f} df=({r['AB'][1]},{r['AB'][2]}) p={r['AB'][3]:.6f}")

# Difference waves: need per subject/electrode/stimulus difference (ungrammatical - grammatical) averaged over time
def diff_prep(df, elecs):
    d = df[df['electrode'].isin(elecs)]
    p = d.pivot_table(index=['subject','electrode','t','stimulus.condition'], columns='grammar.condition', values='voltage')
    p['diff'] = p['Ungrammatical'] - p['Grammatical']
    g = p.groupby(['subject','electrode','stimulus.condition'])[['diff']].mean().reset_index()
    return {(r[1], r[3], r[2]): r.diff for r in g.itertuples()}

for name, elecs in [("Diff Midline", midline),("Diff Lateral", lateral)]:
    cells = diff_prep(eeg, elecs)
    r = rm_anova_2w(cells)
    print(f"--- {name} (A=stimulus, B=electrode) ---")
    print(f"  stimulus F={r['A'][0]:.4f} df=({r['A'][1]},{r['A'][2]}) p={r['A'][3]:.6f}")
    print(f"  electrode F={r['B'][0]:.4f} df=({r['B'][1]},{r['B'][2]}) p={r['B'][3]:.6f}")
    print(f"  SxE       F={r['AB'][0]:.4f} df=({r['AB'][1]},{r['AB'][2]}) p={r['AB'][3]:.6f}")

# Behavioral accuracy cross-check
beh = pd.read_csv(base+r"\data\generated\beh_data_tidy.csv")
beh = beh[~beh['subject_id'].isin(excluded)]
beh = beh[~beh['syntax_cat'].isin(['Filler-Gram','Filler-Ungram'])]
acc = beh.groupby(['syntax_cat','subject_id'])['correct'].mean()*100
res = acc.groupby('syntax_cat').agg(['mean','std'])
print("--- Behavioral accuracy (Table 1) ---")
print(res.round(2))
