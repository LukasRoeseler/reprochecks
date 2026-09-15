import pandas as pd, numpy as np
base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\03_RichGureckis\downloads"

def tb(v): return v.astype(str).str.strip().map(lambda x: x in ("True","1"))

def load(fn): return pd.read_csv(base+"\\"+fn, dtype=str)

def rule_scores(data, excl_filter=True):
    df = data.copy()
    for c in ["response","dim2","dim3","test","exclude","correct"]:
        df[c]=tb(df[c]).astype(int)
    test=df[df["test"]==1]
    rows=[]
    for sub,g in test.groupby("uniqueid"):
        resp=g["response"].values
        d2=g["dim2"].values; d3=g["dim3"].values
        s1=np.mean(resp==d2); s2=np.mean(resp==d3)
        score1d=max(s1,s2)
        score2d=np.mean(g["correct"].values)  # proportion correct
        rows.append(dict(uniqueid=sub, condition=g["condition"].iloc[0],
                         exclude=g["exclude"].iloc[0]==1, score1d=score1d, score2d=score2d))
    r=pd.DataFrame(rows)
    if excl_filter: r=r[r["exclude"]==False]
    return r

def bycond(r, col):
    out={}
    for cond in ["full_info","contingent"]:
        cc=r[r["condition"]==cond]
        out[cond]=dict(n=len(cc), mean=cc[col].mean())
    return out

# ---- EXPERIMENT 1 ----
e1=load("data_exp1.csv")
r1=rule_scores(e1)
print("EXPERIMENT 1 rule scores (excluded removed)")
b1=bycond(r1,"score1d"); b2=bycond(r1,"score2d")
print("  1D  full=%.3f (n%d)  cont=%.3f (n%d)"%(b1['full_info']['mean'],b1['full_info']['n'],b1['contingent']['mean'],b1['contingent']['n']))
print("  2D  full=%.3f (n%d)  cont=%.3f (n%d)"%(b2['full_info']['mean'],b2['full_info']['n'],b2['contingent']['mean'],b2['contingent']['n']))

q1=load("questiondata_exp1.csv")
q1["dangerpercent"]=pd.to_numeric(q1["dangerpercent"],errors="coerce")
q1["excl"]=tb(q1["exclude"])
for lab,sub in [("all",q1),("not_excl",q1[~q1["excl"]]),("not_excl_neg",q1[(~q1["excl"]) & (q1["dangerpercent"]>=0)])]:
    print(f"\n  q1 dangerpercent [{lab}]")
    for cond in ["full_info","contingent"]:
        cc=sub[sub["condition"]==cond]
        print(f"    {cond:10s} n={len(cc)}  mean={cc['dangerpercent'].mean():.3f}")
# rightdimensions, trapdimensions proportions (not_excl)
q1n=q1[~q1["excl"]]
for col in ["rightdimensions","trapdimensions"]:
    q1n[col]=pd.to_numeric(q1n[col],errors="coerce")
    print(f"\n  q1 {col} proportion")
    for cond in ["full_info","contingent"]:
        cc=q1n[q1n["condition"]==cond]
        print(f"    {cond:10s} n={len(cc)}  prop={cc[col].mean():.3f}")
