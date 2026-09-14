#!/usr/bin/env python
# ReproAI cross-check (Python 3.8) - Lakens & Delacre (2020) MP.2018.933
# Independent second-language recompute of headline numeric claims.
import numpy as np
from scipy import stats
import os

np.random.seed(20260914)
OUT = "exec_check/output"
os.makedirs(OUT, exist_ok=True)
lines = []
def log(s):
    lines.append(s)
    print(s)

# ---- Figure 1: one-sample TOST p + SGPV, n=30, sd=2, eq=[143,147] ----
def tost_p(m, n, sd, lo, hi):
    se = sd/np.sqrt(n)
    t_lo = (m-lo)/se; t_hi = (m-hi)/se
    p_lo = stats.t.sf(t_lo, df=n-1)
    p_hi = stats.t.cdf(t_hi, df=n-1)
    return max(p_lo, p_hi)

def sgpv(lb, ub, dlb, dub):
    if ub < dlb or lb > dub: return 0.0
    if lb >= dlb and ub <= dub: return 1.0
    inter = min(ub,dub)-max(lb,dlb)
    ciw = ub-lb; h0 = dub-dlb
    return inter/ciw*max(ciw/(2*h0),1)

n,sd = 30,2.0; lo,hi = 143,147
se = sd/np.sqrt(n); tcrit = stats.t.ppf(0.975, n-1)
log("=== Figure 1 (Python) ===")
fig1ok = 0; fig1tot=0
for m in range(140,151):
    lb=m-tcrit*se; ub=m+tcrit*se
    p=tost_p(m,n,sd,lo,hi); s=sgpv(lb,ub,lo,hi)
    # reference expectations from R/author
    exp = {140:(1.0,0.0),141:(1.0,0.0),142:(0.9948,0.0),143:(0.5,0.5),144:(0.0052,1.0),
           145:(0.0,1.0),146:(0.0052,1.0),147:(0.5,0.5),148:(0.9948,0.0),149:(1.0,0.0),150:(1.0,0.0)}[m]
    ok = abs(p-exp[0])<1e-3 and abs(s-exp[1])<1e-3
    fig1ok+=ok; fig1tot+=1
log(f"Figure 1 agreement vs R: {fig1ok}/{fig1tot}")
t145=(145-lo)/se; t140=(140-lo)/se
log(f"t(29) at 145 = {t145:.2f} (paper 5.48) | at 140 = {t140:.2f} (paper -8.22)")
log(f"TOST p at 145 = {tost_p(145,n,sd,lo,hi):.2e} | SGPV={sgpv(145-tcrit*se,145+tcrit*se,lo,hi)}")

# ---- Correlation CIs (Fisher z) ----
log("=== Correlation CIs (Python) ===")
def fz(r): return 0.5*np.log((1+r)/(1-r))
def iz(z): return np.tanh(z)
def ci_r(r,nn):
    z=fz(r); sez=1/np.sqrt(nn-3); zz=1.96*sez
    return iz(z-zz), iz(z+zz)
for r,nn,exp in [(0.0,10,(-0.63,0.63)),(0.7,10,(0.13,0.92)),(0.45,30,(0.11,0.70))]:
    lb,ub=ci_r(r,nn)
    ok = abs(lb-exp[0])<0.01 and abs(ub-exp[1])<0.01
    log(f"r={r} n={nn}: CI=[{lb:.3f},{ub:.3f}] expect {exp} {'OK' if ok else 'CHECK'}")
s45=sgpv(*ci_r(0.45,30),-0.45,0.45)
log(f"SGPV overlap r=0.45: {100*s45:.2f}% (paper 58.11%)")

# ---- Figure 4: SGPV 0.76..0.91 and tail probabilities ----
log("=== Figure 4 (Python) ===")
mu4=144.5; sd4=500.0; n4=1e6; tcrit4=stats.t.ppf(0.975,n4-1); se4=sd4/np.sqrt(n4)
sg=[sgpv(m-tcrit4*se4,m+tcrit4*se4,mu4-2,mu4+2) for m in (146,145.9,145.8,145.7)]
log(f"SGPV A-D = {[round(x,2) for x in sg]} (paper 0.76 0.81 0.86 0.91)")
tails=[1-stats.norm.cdf(2,mn,0.5) for mn in (1.5,1.4,1.3,1.2)]
log(f"tails    = {[round(x,2) for x in tails]} (paper 0.16 0.12 0.08 0.05)")

# ---- extreme case: n=4, rho=0.99 --- probability future r in [-0.99,0.99] ----
log("=== extreme case sampling dist (Python simulation: future r in [-.99,.99]) ===")
rho=0.99; reps=200000; nsm=4
r_obs=[]
for _ in range(reps):
    x=np.random.randn(nsm); y=rho*x+np.sqrt(1-rho**2)*np.random.randn(nsm)
    r=np.corrcoef(x,y)[0,1]
    r_obs.append(r)
r_obs=np.array(r_obs)
frac=float(np.mean((r_obs>=-0.99)&(r_obs<=0.99)))
log(f"P(r in [-0.99,0.99]) = {100*frac:.1f}%  (cited 36%; n=4, rho=0.99, {reps} sims)")

with open(os.path.join(OUT,"reproai_python_crosscheck.txt"),"w") as f:
    f.write("\n".join(lines))
log("==== PYTHON DONE ====")
