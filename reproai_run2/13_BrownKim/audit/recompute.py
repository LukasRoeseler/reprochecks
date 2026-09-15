import pandas as pd
import numpy as np
import scipy.stats as st
import json

BASE = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\13_BrownKim'
DATA = BASE + r'\data\zip_extract\mnsc.2013.1794-sm-data'

df = pd.read_excel(DATA + r'\STATA_data.xlsx')
print("N subjects:", len(df))

# ---- Claim pp36jq: 61/101 = 60% preferred early resolution ----
choice = df['choice'].dropna()
early_cnt = int((choice == 1).sum())
late_cnt = int((choice == 2).sum())
ind_cnt = int((choice == 3).sum())
n = len(choice)
print(f"\n[pp36jq] choice==1 (early): {early_cnt}/{n} = {100*early_cnt/n:.4f}%")
print(f"[pp36jq] late={late_cnt}, indifferent={ind_cnt}")
print(f"[pp36jq] 'early' col mean/sum: sum={df['early'].sum()} mean={df['early'].mean():.6f}")

# ---- Claim q7w3nr: 68% types 3 or 4 ----
# classification: assign each subject to type with max posterior
post = df[['type1_post','type2_post','type3_post','type4_post']].values
type_idx = np.argmax(post, axis=1) + 1  # 1..4
type34 = int(np.sum(np.isin(type_idx, [3,4])))
print(f"\n[q7w3nr] subjects classified as type3 or type4 (argmax rule): {type34}/{n} = {100*type34/n:.4f}%")
# alternative: early_post>0.5
ep = df['early_post'].dropna()
print(f"[q7w3nr] early_post>0.5 count: {int((ep>0.5).sum())}/{len(ep)} = {100*(ep>0.5).mean():.4f}%")
print(f"[q7w3nr] Table4 fractions from paper 0.407+0.288=69.5%")
# direct alpha<rho from section 5.2 estimated alpha/rho
sub = df[['alpha','rho']].dropna()
print(f"[q7w3nr] among {len(sub)} with alpha&rho, alpha<rho: {(sub['alpha']<sub['rho']).sum()} = {100*(sub['alpha']<sub['rho']).mean():.4f}%")

# ---- Claim x64975: regress early ~ early_post ----
x = df['early_post'].values
y = df['early'].values
X = np.column_stack([np.ones(len(x)), x])
beta, res, rank, sv = np.linalg.lstsq(X, y, rcond=None)
yhat = X @ beta
resid = y - yhat
n = len(y); k = X.shape[1]
dof = n - k
sigma2 = resid @ resid / dof
cov = sigma2 * np.linalg.inv(X.T @ X)
se = np.sqrt(np.diag(cov))
t = beta / se
p = 2*(1-st.t.cdf(np.abs(t), dof))
print(f"\n[x64975] OLS early ~ early_post, N={n}")
print(f"  intercept coef={beta[0]:.7f} se={se[0]:.6f}")
print(f"  early_post coef={beta[1]:.7f} se={se[1]:.6f} t={t[1]:.3f} p={p[1]:.4f}")
print("  target: 0.2008457 (0.1077694), p=0.065")

# ---- Claim j6o1rx: Erickson-Whited higher-order moments ----
# Errors-in-variables regression y = a + b*x*, x=observed with measurement error.
# EW uses higher-order moments estimators. Implement the Biased-corrected / higher-order moments
# Method-of-Moments estimator (Erickson-Whited). We'll compute beta_HOM via sample moments of (x,y).
# Model: y = a + b*x*, x = x* + u. EW2/EW3 estimators based on 2nd/3rd moments.
def ew_mm(y, x):
    y = y.astype(float); x = x.astype(float)
    # demean
    yd = y - y.mean(); xd = x - x.mean()
    # second moments
    mxy = (xd*yd).mean()
    myy = (yd*yd).mean()
    mxx = (xd*xd).mean()
    # third moments
    mxxy = (xd*xd*yd).mean()
    mxyy = (xd*yd*yd).mean()
    mxx_3 = (xd**3).mean()
    mxxx = mxx_3
    myyy = (yd**3).mean()
    # EW1995: b from ratio of third moments
    # estimates: b2 = mxyy/mxxy ... various
    return dict(mxx=mxx, mxy=mxy, myy=myy, mxxy=mxxy, mxyy=mxyy, mxxx=mxxx, myyy=myyy)

m = ew_mm(y, x)
print("\n[j6o1rx] moments raw:", {k: round(v,6) for k,v in m.items()})

# Implement the closed-form "higher-order moments estimators" for EIV with one regressor (Erickson 1989 / EW).
# Define weighted estimator. We'll do the classic EW2 estimator b_EW = (a set). 
# Alternative: use the ratio-based estimator of the true coefficient:
# b_HOM = (mxxy / mxxx)  -> estimator based on third-order moment restrictions? Let's compute several candidates.
n = len(x)
xd = x - x.mean(); yd = y - y.mean()
s_xy = (xd*yd).mean()
s_xx = (xd*xd).mean()
s_yy = (yd*yd).mean()
m3_x = (xd**3).mean()
m3_y = (yd**3).mean()
m2x_y = (xd**2*yd).mean()
m2y_x = (xd*yd**2).mean()

# EW "third-order central moment" estimator for b:  b = m2y_x/mx2y? 
candidates = {
 'b1=m2yx/mx2y': m2y_x/m2x_y,
 'b2=mxxx/mxxy': m3_x/m2x_y,
 'b3=myyy/mxyy': m3_y/m2y_x,
 'b4=sqrt(myy/mxx)': np.sqrt(s_yy/s_xx),
}
print("[j6o1rx] candidate EW-type slope estimates:")
for kk,v in candidates.items():
    print(f"   {kk}: {v:.6f}")

# A proper EW HOM estimator: several consistent estimators exist; combine via minimizer of a distance.
# Use EW's own numerical estimator that minimizes g(b,g) moment conditions. 
# We'll implement the EW (1995) estimator numerically below.
print("\ntarget j6o1rx: 0.5072804")

# ---- Descriptive recompute from raw inputs.xls (choice task) ----
# inputs.xlsx sheets: risk1,risk2,time1,time2,eis1,eis2,resolution(?)
import os
ixl = None
for cand in [DATA+r'\inputs.xlsx', DATA+r'\inputs.xls']:
    if os.path.exists(cand):
        ixl = cand
print("\nraw inputs file found:", ixl)
if ixl:
    xl = pd.ExcelFile(ixl)
    print("  sheets:", xl.sheet_names)

# Store results
summary = {
 "pp36jq_early_frac": round(100*early_cnt/n,4),
 "pp36jq_early_n": early_cnt,
 "q7w3nr_type34_argmax_pct": round(100*type34/n,4),
 "x64975_ols_coef": round(float(beta[1]),7),
 "x64975_ols_se": round(float(se[1]),6),
 "x64975_ols_p": round(float(p[1]),4),
}
with open(BASE+r'\audit\recompute_output.json','w') as f:
    json.dump(summary, f, indent=2)
print("\nSAVED", summary)
