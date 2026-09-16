import pandas as pd, numpy as np, sys
from scipy import stats
sys.stdout.reconfigure(encoding='utf-8')

BASE = r"C:\Users\LROESE~1.IVV\AppData\Local\Temp\opencode\repro_pilot\work\wunbq\wunbq"

def read(f):
    return pd.read_csv(BASE + "/" + f, encoding="latin-1")

beh = "BehavioralData/"
exp1 = read(beh + "exp1_data")
exp2 = read(beh + "exp2_data")
exp3 = read(beh + "exp3_data")
norm = read(beh + "norm_data")

def cleanup_cond(s):
    # R uses "condition" field which contains newline formatting; normalize
    return s.replace("\n", " ").strip()

exp1["condx"] = exp1["condition"].map(cleanup_cond)
exp2["condx"] = exp2["condition"].map(cleanup_cond)
exp3["condx"] = exp3["condition"].map(cleanup_cond)

print("="*70)
print("EXP 1  — summary per condition (teach_num: red=0, yellow=1)")
print("="*70)
exp1["teach_num"] = np.where(exp1["teach"]=="yellow",1,0)
s = exp1.groupby("condx").agg(n=("teach","count"), n_red=("teach",lambda x:(x=="red").sum()),
                              n_yellow=("teach",lambda x:(x=="yellow").sum()),
                              mean=("teach_num","mean"), sd=("teach_num","std"))
print(s)

print("\nBinomial tests (Exp1), exact by R binom.test:")
# replicates R binom.test (Clopper-Pearson)
def rbinom(x,n,alt,p=0.5):
    return stats.binomtest(x,n,p=p,alternative=alt)
tests = [
    ("Rewards & Costs",       "less"),
    ("Different Costs",       "less"),
    ("Different Rewards",     "greater"),
    ("Medium Cost Conflict",  "greater"),
    ("High Cost Conflict",    "two-sided"),
    ("Extra-High Cost Conflict","less"),
]
for cond, alt in tests:
    row = exp1[exp1["condx"]==cond]
    nred = (row["teach"]=="red").sum()
    n = len(row)
    # note: script's High Cost test erroneously used med_cost n; recompute correctly here with n_high
    bt = rbinom(nred,n,alt)
    print(f"  {cond:28s} n_red={nred} n={n} p={bt.pvalue:.5f}")

print("\nFisher's exact Medium vs Extra-High Cost Conflict:")
med = exp1[exp1["condx"]=="Medium Cost Conflict"]
xh  = exp1[exp1["condx"]=="Extra-High Cost Conflict"]
tab = pd.crosstab(pd.concat([med,xh])["condx"], pd.concat([med,xh])["teach"])
print(tab)
print(stats.fisher_exact(tab.values, alternative="two-sided"))

print("\nLinear effect GLM across conflict conditions (contr.poly):")
conf = exp1[exp1["condx"].isin(["Medium Cost Conflict","High Cost Conflict","Extra-High Cost Conflict"])].copy()
conf["teach_num"] = np.where(conf["teach"]=="red",1,0)
levels = ["Medium Cost Conflict","High Cost Conflict","Extra-High Cost Conflict"]
lin = {-1: 0, 0: 1, 1: 2}[0]  # placeholder
lin_coef = {"Medium Cost Conflict":-1.0,"High Cost Conflict":0.0,"Extra-High Cost Conflict":1.0}
conf["lin"] = conf["condx"].map(lin_coef)
import statsmodels.api as sm
from statsmodels.genmod.families import Binomial
X = sm.add_constant(conf["lin"])
m = sm.GLM(conf["teach_num"], X, family=Binomial()).fit()
print("GLM summary:")
print(m.summary())

print("\n\nEXP 2  Teach vs Play")
print("="*70)
exp2["teach_num"]=np.where(exp2["teach"]=="red",0,1)
print(pd.crosstab(exp2["condx"], exp2["teach"]))
tab=pd.crosstab(exp2["condx"], exp2["teach"])
print("Fisher Teach vs Play:", stats.fisher_exact(tab.values, alternative="two-sided"))
for cond in ["Teach","Play"]:
    row=exp2[exp2["condx"]==cond]
    ny=(row["teach"]=="yellow").sum(); nr=(row["teach"]=="red").sum()
    # Teach binomial uses n_yellow two-sided; Play uses n_red two-sided
    bt = rbinom(ny if cond=="Teach" else nr, len(row), "two-sided")
    print(f"  {cond}: n_yellow={ny} n_red={nr} n={len(row)} p_two-sided={bt.pvalue:.5f}")

print("\n\nEXP 3  Exploration vs Instruction")
print("="*70)
print(pd.crosstab(exp3["condx"], exp3["teach"]))
tab=pd.crosstab(exp3["condx"], exp3["teach"])
print("Fisher Expl vs Inst:", stats.fisher_exact(tab.values, alternative="two-sided"))
for cond in ["Exploration","Instruction"]:
    row=exp3[exp3["condx"]==cond]
    ny=(row["teach"]=="yellow").sum()
    bt = rbinom(ny, len(row), "two-sided")
    print(f"  {cond}: n_yellow={ny} n={len(row)} p_two-sided={bt.pvalue:.5f}")

print("\n\nCross-experiment Fisher tests")
print("="*70)
def f(t):
    return stats.fisher_exact(t, alternative="two-sided")
# Teach vs High Cost
hc = exp1[exp1["condx"]=="High Cost Conflict"]["teach"]
te = exp2[exp2["condx"]=="Teach"]["teach"]
m = np.array([[ (hc=="red").sum(), (hc=="yellow").sum()],[ (te=="red").sum(),(te=="yellow").sum()]])
print("Teach vs High Cost Conflict"); print(m); print(" Fisher:", f(m))
# Play vs High Cost
pl = exp2[exp2["condx"]=="Play"]["teach"]
m = np.array([[ (hc=="red").sum(), (hc=="yellow").sum()],[ (pl=="red").sum(),(pl=="yellow").sum()]])
print("Play vs High Cost Conflict"); print(m); print(" Fisher:", f(m))
# Exploration vs Different Costs
dc = exp1[exp1["condx"]=="Different Costs"]["teach"]
exl = exp3[exp3["condx"]=="Exploration"]["teach"]
m = np.array([[ (dc=="red").sum(), (dc=="yellow").sum()],[ (exl=="red").sum(),(exl=="yellow").sum()]])
print("Exploration vs Different Costs"); print(m); print(" Fisher:", f(m))
# Instruction vs Different Costs
ins = exp3[exp3["condx"]=="Instruction"]["teach"]
m = np.array([[ (dc=="red").sum(), (dc=="yellow").sum()],[ (ins=="red").sum(),(ins=="yellow").sum()]])
print("Instruction vs Different Costs"); print(m); print(" Fisher:", f(m))
