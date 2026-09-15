import numpy as np
from scipy import stats

# Study 4 Table 6 data: (product, CategoryFunction, AdFunction, Mismatch(printed), Evaluation)
rows = [
 ("Movado watch",1.19,-1.87,3.06,5.76),
 ("Ford car",1.23,-.58,1.80,5.06),
 ("Allianz financial products",2.00,-1.37,3.37,3.85),
 ("Nikon camera",2.00,.00,2.00,4.58),
 ("Jitterbug cellphone",2.19,1.18,1.01,3.12),
 ("Promise health drinks",2.19,1.47,.72,4.48),
 ("Omaha steaks",2.19,.34,1.85,5.03),
 ("Mount Sinai hospital",2.23,.84,1.38,4.03),
 ("Templeton investments",2.29,-.26,2.55,3.27),
 ("Bose music system",2.35,.76,1.59,4.00),
 ("T.Rowe Price retirement",2.42,1.84,.58,3.09),
 ("MetLife retirement",2.42,-.63,3.05,4.39),
 ("Ameritrade retirement",2.42,1.79,.63,3.06),
 ("Greenwise paper products",2.48,-1.79,4.27,5.12),
 ("Dell computer",2.54,-2.24,4.79,5.55),
 ("Allstate retirement advice",2.58,.05,2.53,3.97),
 ("BofA checking account",2.58,.00,2.58,4.70),
 ("Lipitor",2.65,2.16,.49,3.76),
 ("Vytorin",2.65,1.53,1.12,4.24),
 ("Braun electric razor",2.65,.05,2.59,5.12),
 ("Flomax",2.74,.16,2.58,4.30),
 ("Philips toothbrush",2.81,1.18,1.62,4.79),
 ("Quaker oatmeal",2.81,.61,2.20,4.85),
 ("Cypher stent",2.84,-.82,3.65,3.88),
 ("Bose headphones",2.87,1.42,1.45,3.88),
 ("Regions financial advisors",2.94,-.32,3.25,3.36),
 ("Liberty Mutual insurance",2.97,-.37,3.34,5.21),
 ("Lyrica",3.06,.87,2.20,3.33),
 ("Lunesta",3.42,.00,3.42,5.30),
 ("Mucinex",3.48,.95,2.54,5.55),
 ("APC surge protector",3.55,1.76,1.79,3.94),
 ("Kodak printer",3.94,.18,3.75,4.85),
 ("Milk (unbranded)",2.35,-1.34,3.70,5.03),
 ("Almonds (unbranded)",2.65,.76,1.88,5.18),
]

branded = [r for r in rows if "unbranded" not in r[0]]
assert len(branded)==32, len(branded)

cf = np.array([r[1] for r in branded])
af = np.array([r[2] for r in branded])
mm = np.array([r[3] for r in branded])
ev = np.array([r[4] for r in branded])

# 1) Verify printed mismatch = |CF - AF|
calc_mm = np.abs(cf-af)
print("Max |printed_mismatch - |CF-AF|| =", np.max(np.abs(mm-calc_mm)))

def report(name, x, y):
    r, p = stats.pearsonr(x, y)
    t = r*np.sqrt((len(x)-2)/(1-r**2))
    print(f"{name}: r={r:.4f}  p={p:.5f}  t={t:.3f}  (paper: see table)")

print("\n--- on 32 branded advertisements ---")
report("Mismatch score  vs Ad evaluation", mm, ev)   # paper: r=.50, p=.003
report("Category fn    vs Ad evaluation", cf, ev)      # paper: r=-.01, p=.94
report("Advertisement fn vs Ad evaluation", af, ev)    # paper: r=-.50, p=.004

# partial correlations (paper controls)
import math
def partial(x,y,z):
    rx,px = stats.pearsonr(x,y)
    rxz,pxz = stats.pearsonr(x,z)
    ryz,pyz = stats.pearsonr(y,z)
    rxy_z = (rx - rxz*ryz)/math.sqrt((1-rxz**2)*(1-ryz**2))
    n=len(x)
    t = rxy_z*math.sqrt((n-3)/(1-rxy_z**2))
    p = 2*(1-stats.t.cdf(abs(t), n-3))
    return rxy_z, t, p
print("\n--- partial correlations ---")
r,t,p = partial(ev, mm, af)
print(f"eval~mismatch | adfn: r={r:.3f} t={t:.2f} p={p:.3f}  (paper: r=.17, p=.37)")
r,t,p = partial(ev, af, mm)
print(f"eval~adfn | mismatch: r={r:.3f} t={t:.2f} p={p:.3f}  (paper: r=-.14, p=.45)")

# t-test utilitarian ads (ad fn>0, n=19?) vs symbolic ads (ad fn<0, n=10?) among branded
util = ev[af>0]
sym = ev[af<0]
print("\nutilitarian ads n=",len(util),"mean=",util.mean().round(2))
print("symbolic ads n=",len(sym),"mean=",sym.mean().round(2))
t,p = stats.ttest_ind(util,sym,equal_var=False)
print(f"Welch t = {t:.2f} p = {p:.3f} df_approx -> mean diff (paper M=4.18 vs 4.55, t(27)=-1.18, p=.25)")
