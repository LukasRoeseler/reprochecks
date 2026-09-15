import pandas as pd, numpy as np
base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\03_RichGureckis\downloads"

def load(fn):
    return pd.read_csv(base+"\\"+fn, dtype=str)

def to_bool(v):
    v = v.astype(str).str.strip()
    return v.map(lambda x: x in ("True","1"))

def compute_experiment(fn, test_is_numeric=False):
    df = load(fn)
    for c in ["response","dim2","dim3","test","exclude"]:
        df[c] = to_bool(df[c])
    tst = df["test"]
    testdf = df[tst]
    results = []
    for sub, g in testdf.groupby("uniqueid"):
        resp = g["response"].astype(int).values
        d2 = g["dim2"].astype(int).values
        d3 = g["dim3"].astype(int).values
        pred2d = (d2 & d3)
        score2d = np.mean(resp == pred2d)
        rule_d2 = d2
        rule_d3 = d3
        s1 = np.mean(resp == rule_d2)
        s2 = np.mean(resp == rule_d3)
        score1d = max(s1, s2)
        cond = g["condition"].iloc[0]
        excl = g["exclude"].iloc[0]
        results.append(dict(uniqueid=sub, condition=cond, exclude=excl,
                            score1d=score1d, score2d=score2d, ntrials=len(g)))
    r = pd.DataFrame(results)
    for label, sub in [("ALL", r), ("NOT_EXCLUDED", r[r["exclude"]==False])]:
        print(f"  [{label}] n={len(sub)}")
        for cond in ["full_info","contingent"]:
            cc = sub[sub["condition"]==cond]
            if len(cc)==0: continue
            print(f"    {cond:10s} n={len(cc):3d}  1D={cc.score1d.mean():.4f}  2D={cc.score2d.mean():.4f}")
    return r

print("EXPERIMENT 1")
exp1_all = compute_experiment("data_exp1.csv")
print("EXPERIMENT 1 (excluded only)")
print(exp1_all[exp1_all["exclude"]==True][["uniqueid","condition","exclude"]].to_string())
