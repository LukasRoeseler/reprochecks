import pandas as pd, numpy as np
base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\03_RichGureckis\downloads"
def tb(v): return v.astype(str).str.strip().map(lambda x: x in ("True","1"))
def load(fn): return pd.read_csv(base+"\\"+fn, dtype=str)

df=load("data_exp2.csv")
for c in ["response","dim2","dim3","test","exclude","correct"]:
    df[c]=tb(df[c]).astype(int)
test=df[df["test"]==1]
rows=[]
for sub,g in test.groupby("uniqueid"):
    resp=g["response"].values; d2=g["dim2"].values; d3=g["dim3"].values
    score1d=max(np.mean(resp==d2),np.mean(resp==d3)); score2d=np.mean(g["correct"].values)
    rows.append(dict(uniqueid=sub, condition=g["condition"].iloc[0], exclude=g["exclude"].iloc[0]==1,
                     score1d=score1d, score2d=score2d))
r=pd.DataFrame(rows)
r=r[r["exclude"]==False]
print("EXPERIMENT 2 rule scores by condition (excluded removed): n_total=",len(r))
print("  condition    n    1D      2D")
for cond in r["condition"].unique():
    cc=r[r["condition"]==cond]
    print("  %-10s %4d  %.3f   %.3f"%(cond,len(cc),cc.score1d.mean(),cc.score2d.mean()))

q=load("questiondata_exp2.csv")
q["dangerpercent"]=pd.to_numeric(q["dangerpercent"],errors="coerce")
q["excl"]=tb(q["exclude"])
qn=q[~q["excl"]]
for col in ["rightdimensions","trapdimensions"]:
    qn[col]=pd.to_numeric(qn[col],errors="coerce")
print("\nQuestion data proportions/means by condition (not excluded):")
print("  condition    n   danger%  rightdim  trapdim  completeLearn_yes")
for cond in qn["condition"].unique():
    cc=qn[qn["condition"]==cond]
    dp=cc["dangerpercent"].mean()
    rd=cc["rightdimensions"].mean()
    td=cc["trapdimensions"].mean()
    cl = (cc["completeLearn"].astype(str).str.strip()=="yes").mean() if "completeLearn" in cc.columns else float("nan")
    print("  %-10s %4d  %6.1f  %6.3f   %6.3f   %s"%(cond,len(cc),dp,rd,td,("n/a" if np.isnan(cl) else "%.3f"%cl)))
