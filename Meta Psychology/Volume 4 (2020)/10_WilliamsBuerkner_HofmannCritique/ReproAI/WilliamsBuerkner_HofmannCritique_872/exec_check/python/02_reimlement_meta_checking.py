import csv, math, sys
import numpy as np
from scipy.special import gammaln
from scipy.optimize import minimize_scalar

print("==== START (status: running) ====")
print("Python", sys.version.split()[0])

def hedges_g(m1, sd1, n1, m2, sd2, n2):
    sp = math.sqrt(((n1-1)*sd1**2 + (n2-1)*sd2**2)/(n1+n2-2))
    d = (m1 - m2)/sp
    df = n1 + n2 - 2
    J = math.exp(gammaln(df/2.0) - 0.5*math.log(df/2.0) - gammaln((df-1)/2.0))
    g = d*J
    v = (1.0/n1 + 1.0/n2 + d**2/(2.0*(n1+n2))) * J**2
    return g, v

def smcr_point(m_pre, sd_pre, m_post, n, r=0.7):
    d = (m_post - m_pre)/sd_pre
    return d

# load raw data
rows = []
with open('dat.csv') as fh:
    rdr = csv.DictReader(fh)
    for r in rdr:
        rows.append(r)

def num(x):
    if x.strip()=='NA' or x.strip()=='': return None
    return float(x)

# Part A: independent Hedges' g (SMD) recompute from raw post data
sams = {r['name'] + '|' + r['measure']: r for r in rows}
gg = []
for r in rows:
    if r['name'].startswith('Averbeck'):
        continue  # hand-coded
    g, v = hedges_g(num(r['oxyMean_post']), num(r['oxySd_post']), float(r['oxyN']),
                    num(r['plaMean_post']), num(r['plaSd_post']), float(r['plaN']))
    gg.append((r['name'], round(g,4), round(v,4)))
print("\n--- Independent Hedges' g (SMD) from raw post data ---")
for nm,g,v in gg:
    print(f"{nm:40s} g={g: .4f} v={v: .4f}")

# Part B: SMCR point estimates independently
smcr_pt = []
for r in rows:
    if r['name'].startswith('Averbeck'):
        continue
    do = smcr_point(num(r['oxyMean_pre']), num(r['oxySd_pre']), num(r['oxyMean_post']), float(r['oxyN']))
    dp = smcr_point(num(r['plaMean_pre']), num(r['plaSd_pre']), num(r['plaMean_post']), float(r['plaN']))
    smcr_pt.append((r['name'], do-dp))
print("\n--- Independent SMCR point estimates (oxyprev-placebo) ---")
for nm, d in smcr_pt:
    print(f"{nm:40s} SMCR={d: .4f}")

# ---- Load R/escalc derived effect sizes as shared per-study input ----
studies = []
with open('output/derived_effect_sizes.csv') as fh:
    rdr = csv.DictReader(fh)
    for row in rdr:
        studies.append({
            'name': row['name'], 'disorder': row['disorder'].strip(),
            'overall': int(row['overall']), 'psycho_tot': int(row['psycho_tot']),
            'SMD_neg': float(row['SMD_post_neg']), 'vSMD': float(row['vSMD_post']),
            'SMCR_neg': float(row['SMCR_neg']), 'vSMCR': float(row['vSMCR']),
        })

def reml_fe(y, v):
    """REML random-effects meta-analysis. returns (mu, se, tau2)."""
    def nll_logtau2(logt):
        t2 = math.exp(logt)
        w = 1.0/(v + t2)
        m = np.sum(w*y)/np.sum(w)
        ll = -0.5*np.sum(np.log(v+t2)) - 0.5*math.log(np.sum(w)) - 0.5*np.sum(w*(y-m)**2)
        return -ll
    res = minimize_scalar(nll_logtau2, bounds=(-12, 2), method='bounded')
    t2 = math.exp(res.x)
    w = 1.0/(v + t2)
    m = np.sum(w*y)/np.sum(w)
    se = math.sqrt(1.0/np.sum(w))
    return m, se, t2

yall_smcr = np.array([s['SMCR_neg'] for s in studies])
vall_smcr = np.array([s['vSMCR'] for s in studies])
yall_smd  = np.array([s['SMD_neg'] for s in studies])
vall_smd  = np.array([s['vSMD'] for s in studies])
ov_smcr = np.array([s['overall'] for s in studies])==1
ov_smd  = np.array([s['overall'] for s in studies])==1

print("\n--- REML random-effects OVERALL meta-analysis (independent Python) ---")
ms, ses, t2s = reml_fe(yall_smcr[ov_smcr], vall_smcr[ov_smcr])
print(f"SMCR overall: ES={ms:.4f} SE={ses:.4f} z={ms/ses:.4f} p={2*(1-0.5*(1+math.erf(abs(ms/ses)/math.sqrt(2)))):.4g} tau2={t2s:.4f}")
ms2, ses2, t2s2 = reml_fe(yall_smd[ov_smd], vall_smd[ov_smd])
print(f"SMD  overall: ES={ms2:.4f} SE={ses2:.4f} z={ms2/ses2:.4f} p={2*(1-0.5*(1+math.erf(abs(ms2/ses2)/math.sqrt(2)))):.4g} tau2={t2s2:.4f}")

def qtest_p(y, v, mu):
    Q = np.sum((y-mu)**2/v)
    # chi2 p
    from scipy.stats import chi2
    return Q, chi2.sf(Q, len(y)-1)

Q, Qp = qtest_p(yall_smcr[ov_smcr], vall_smcr[ov_smcr], ms)
print(f"SMCR Q={Q:.4f} p={Qp:.4f}")
Q2, Qp2 = qtest_p(yall_smd[ov_smd], vall_smd[ov_smd], ms2)
print(f"SMD  Q={Q2:.4f} p={Qp2:.4f}")

def reml_mixed(y, v, X):
    """REML mixed-effects meta-regression. Returns beta, se, tau2, QE p."""
    k = len(y)
    from scipy.stats import chi2
    def nll(logt):
        t2 = math.exp(logt)
        Vinv = 1.0/(v + t2)
        XtVX = X.T @ (X * Vinv[:,None])
        XtVy = X.T @ (y*Vinv)
        beta = np.linalg.solve(XtVX, XtVy)
        resid = y - X@beta
        val = resid.T @ (resid*Vinv)
        sign, logdet = np.linalg.slogdet(XtVX)
        ll = -0.5*np.sum(np.log(v+t2)) - 0.5*logdet - 0.5*val
        return -ll
    res = minimize_scalar(nll, bounds=(-12, 2), method='bounded')
    t2 = math.exp(res.x)
    Vinv = 1.0/(v + t2)
    XtVX = X.T @ (X * Vinv[:,None])
    beta = np.linalg.solve(XtVX, X.T@(y*Vinv))
    cov = np.linalg.inv(XtVX)
    se = np.sqrt(np.diag(cov))
    resid = y - X@beta
    QE = np.sum(resid**2/(v+t2))
    QEp = chi2.sf(QE, k - X.shape[1])
    return beta, se, t2, QE, QEp

disorders = sorted(set(s['disorder'] for s in studies))
print("\ndisorder levels:", disorders)

def moderator_table(y, v):
    X = np.array([[1.0 if s['disorder']==d else 0.0 for d in disorders] for s in studies])
    beta, se, t2, QE, QEp = reml_mixed(y, v, X)
    print(f"  tau2={t2:.4f}  QE p={QEp:.4f}")
    from scipy.stats import norm
    for j,d in enumerate(disorders):
        z = beta[j]/se[j]
        p = 2*(1-norm.cdf(abs(z)))
        print(f"  {d:16s} ES={beta[j]:.4f} SE={se[j]:.4f} z={z:.4f} p={p:.4f}")

print("\n--- Independent REML moderator ~ disorder (Table 1) ---")
print("SMCR:")
moderator_table(yall_smcr, vall_smcr)
print("SMD:")
moderator_table(yall_smd, vall_smd)

# psycho_tot subsets
pt_smcr = np.array([s['psycho_tot'] for s in studies])==1
ms_pt, ses_pt, _ = reml_fe(yall_smcr[pt_smcr], vall_smcr[pt_smcr])
print(f"\npsycho_tot SMCR: ES={ms_pt:.4f} z={ms_pt/ses_pt:.4f} p={2*(1-0.5*(1+math.erf(abs(ms_pt/ses_pt)/math.sqrt(2)))):.4g}")
ms_pt2, ses_pt2, _ = reml_fe(yall_smd[pt_smcr], vall_smd[pt_smcr])
print(f"psycho_tot SMD : ES={ms_pt2:.4f} z={ms_pt2/ses_pt2:.4f} p={2*(1-0.5*(1+math.erf(abs(ms_pt2/ses_pt2)/math.sqrt(2)))):.4g}")

# negative-direction counts
smcr_neg_vals = yall_smcr[ov_smcr]
smd_neg_vals = yall_smd[ov_smd]
print("\n--- negative-direction outcome counts (overall set, n=16) ---")
print("SMCR(oxy-placebo) negative count:", int(np.sum(smcr_neg_vals<0)))
print("SMD(oxy-placebo) negative count:", int(np.sum(smd_neg_vals<0)))
print("==== END (status: OK) ====")
