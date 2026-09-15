import pandas as pd, numpy as np
base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\03_RichGureckis\downloads"
df = pd.read_csv(base+"\\data_exp1.csv", dtype=str)

def tb(v): return v.astype(str).str.strip().map(lambda x: x in ("True","1"))
df["response"]=tb(df["response"]).astype(int)
df["correct"]=tb(df["correct"]).astype(int)
df["test"]=tb(df["test"])
df["dim2"]=tb(df["dim2"]).astype(int)
df["dim3"]=tb(df["dim3"]).astype(int)
df["exclude"]=tb(df["exclude"])
df["pred2d"]=(df["dim2"]&df["dim3"]).astype(int)

# check: does correct == pred2d?
print("correct==pred2d agreement:", np.mean(df["correct"]==df["pred2d"]))
for phase,lab in [(False,"train"),(True,"test")]:
    sub = df[df["test"]==phase]
    print(f"\n== Exp1 {lab} phase ==")
    for cond in ["full_info","contingent"]:
        cc = sub[sub["condition"]==cond]
        acc = cc["correct"].mean()
        print(f"  {cond:10s} n={cc['uniqueid'].nunique():3d} rows={len(cc)} accuracy(match correct)={acc:.4f}")
# per subject 2D accuracy then mean
print("\nPer-subject test 2D accuracy means (all subjects):")
for cond in ["full_info","contingent"]:
    cc = df[(df["test"]) & (df["condition"]==cond)]
    per = cc.groupby("uniqueid")["correct"].mean()
    print(f"  {cond:10s} mean={per.mean():.4f}  n={len(per)}")
