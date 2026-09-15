# Independent recompute (Python, second language) of the headline pooled effects.
# DerSimonian-Laird random-effects meta-analysis on Fisher-z, back-transformed.
import math, csv, os

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\08_s41562-023-01712-8\ReproAI\s41562-023-01712-8\exec_check"
TARGETS = {
    "60496_003": ("Internet use -> Depression", 0.25, -999),  # paper r, p<0.001
    "47783_001": ("Screen use general -> Literacy", -0.14, -999),
    "47569_001": ("Screen use general -> Learning", -0.11, -999),
    "50271_001": ("Touch screen intervention -> Learning", 0.21, -999),
    "8556_119":  ("TV -> Body composition", 0.06, -999),
    "6524_005":  ("TV -> Sleep duration (adolescents)", -0.06, -999),
    "41430_001": ("Video games numeracy -> Numeracy", 0.32, -999),
    "47429_003": ("Social media -> Risky sexual behaviour", 0.21, -999),
}

D_METRICS = {"adjusted smd","average effect size","cohen d","cohen's d","effect size (type unclear)",
    "g","g+","hedge's g","hedges g","hedges' d","hedge's d","hedges' g","median effect size",
    "pooled mean effect size","smd","standard mean difference","standardised difference in the means",
    "standardized mean difference","standarised mean difference","std mean difference",
    "std. mean difference","standardised mean difference"}
R_METRICS = {"attenuated correlation (uncorrected correlation)","corrected correlation","correlation",
    "correlation coefficient","pearson's r","weighted mean correlation coefficient",
    "r = uncorrected sample-weighted mean effect size"}
Z_METRICS = {"fisher z","fisher's z","z fischer","z fisher","fisher\u2019s z"}
B_METRICS = {"beta","beta coefficient","standardised regression coefficient"}
MD_METRICS = {"mean","mean difference","pooled mean difference","pre-post difference mean",
    "unstandardized mean difference","weighted mean","weighted mean difference"}

def d_to_r(d): return d / math.sqrt(d*d + 4.0)

def to_r(metric, est, sd=None):
    m = metric.strip().lower()
    if m in R_METRICS:
        return est
    if m in B_METRICS:
        return est
    if m in D_METRICS:
        return d_to_r(est)
    if m in Z_METRICS:
        return math.tanh(est)
    if m in MD_METRICS:
        if est is not None and sd and sd == sd and sd != 0:
            return d_to_r(est / sd)
        return None
    return None

rows = []
with open(os.path.join(BASE, "repo_data", "Studies.csv"), newline='', encoding='utf-8-sig') as f:
    rdr = csv.DictReader(f)
    for row in rdr:
        iid = row["Effect Size ID"].strip()
        if iid not in TARGETS: 
            continue
        est = row["Estimate"].strip()
        if est == "" : continue
        try: est = float(est)
        except: continue
        try: n = float(row["Study N"])
        except: n = float('nan')
        if n <= 0 or (n != n): n = float('nan')  # -999 sentinel -> missing
        try: sd = float(row["Standard Deviation"])
        except: sd = float('nan')
        r_est = to_r(row["Metric"], est, sd)
        if r_est is None or r_est != r_est: 
            continue
        rows.append([iid, r_est, n])

from collections import defaultdict
grp = defaultdict(list)
for iid, r, n in rows: grp[iid].append((r, n))

def fisher_z(r): return 0.5*math.log((1+r)/(1-r))
def inv_z(z): return math.tanh(z)

print(f"{'effect':10} {'paper_r':>8} {'py_pooled_r':>10} {'py_ci95':>16} {'k':>3} {'N':>8}")
for iid, (desc, prec, _) in TARGETS.items():
    dat = [x for x in grp.get(iid, [])]
    if not dat: 
        print(f"{iid:10} {desc:<38} NO STUDY DATA"); continue
    # missing N imputation by mean within effect (mirrors paper)
    ns = [n for r,n in dat if n==n]
    mn = round(sum(ns)/len(ns)) if ns else float('nan')
    zs=[]; vs=[]; ks=[]
    for r,n in dat:
        if n!=n: n=mn
        z=fisher_z(r); v=1.0/(n-3); w=1.0/v
        zs.append(z); vs.append(v); ks.append(n)
    # DerSimonian-Laird tau^2
    k=len(zs)
    W=[1/v for v in vs]; Q=sum(W[i]*(zs[i]-sum(w*z for w,z in zip(W,zs))/sum(W))**2 for i in range(k))
    C=sum(W)-sum(w*w for w in W)/sum(W)
    tau2=max(0,(Q-(k-1))/C)
    W2=[1.0/(v+tau2) for v in vs]
    zp=sum(w*z for w,z in zip(W2,zs))/sum(W2)
    vp=1.0/sum(W2); se=math.sqrt(vp)
    lo=inv_z(zp-1.96*se); hi=inv_z(zp+1.96*se); rp=inv_z(zp)
    N=sum(ks)
    print("%-10s %-40s %8.3f [%5.3f,%5.3f] %3d %8d" % (iid, desc, rp, lo, hi, int(k), int(N)))
