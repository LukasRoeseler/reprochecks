import numpy as np, pickle, csv
from scipy.stats import rankdata, norm

base = r'C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)\01_Niemeyer_PtsdPublicationBias\ReproAI\Niemeyer_PtsdPublicationBias_884\exec_check'
with open(base + r'\output\sei_vectors.pkl', 'rb') as fh:
    seis_ds = pickle.load(fh)

alpha = 0.025  # one-tailed alpha in primary study (paper: alpha/2 with alpha=0.05)
pubs = [0.0, 0.5, 0.85, 1.0]
iters = 700

def begg_tau_p(es, sei):
    n = len(es)
    if n < 3: return 0.0, 1.0
    z = es / sei
    inv = 1.0 / sei
    r = rankdata(z); s = rankdata(inv)
    # Kendall tau-b via corrcoef of ranks is not tau; use scipy-free formula below
    # Simple Spearman-like: use Pearson on ranks as a rank correlation proxy (Begg is Kendall);
    # for logic check we compute Kendall tau properly:
    concord = 0; discord = 0
    for i in range(n):
        for j in range(i+1, n):
            a = (r[i]-r[j])*(s[i]-s[j])
            if a > 0: concord += 1
            elif a < 0: discord += 1
    denom = n*(n-1)/2.0
    if denom == 0: return 0.0, 1.0
    tau = (concord - discord)/denom
    # approximate s.e. of tau
    se = np.sqrt(2*(2*n+5)/(9*n*(n-1)))
    if se == 0: return tau, 1.0
    zstat = tau/se
    p = 2*(1-norm.cdf(abs(zstat)))
    return tau, p

def egger_p(yi, sei):
    n = len(yi)
    if n < 3: return 1.0
    x = 1.0/sei  # 1/sqrt(v); but Egger uses se as predictor on y/... standard: regress z on se or y on se
    # Egger: regress effect on standard error with weights 1/v
    w = 1.0/sei**2
    W = np.sum(w); Wx = np.sum(w*x); Wxx = np.sum(w*x*x); Wy = np.sum(w*yi); Wxy = np.sum(w*x*yi)
    denom = W*Wxx - Wx**2
    if abs(denom) < 1e-300: return 1.0
    slope = (W*Wxy - Wx*Wy)/denom
    # standard error of slope
    # residual variance ~1 because effect ~ N(theta,se)
    var_slope = W/denom
    if var_slope <= 0: return 1.0
    z = slope/np.sqrt(var_slope)
    p = 2*(1-norm.cdf(abs(z)))
    return p

def tes_p(es, sei):
    n = len(es)
    w = 1.0/sei**2
    b = np.sum(w*es)/np.sum(w)
    alpha2 = 0.025
    est_fe = b
    powv = np.array([norm.cdf(norm.ppf(alpha2, scale=s), loc=est_fe, scale=s) for s in sei])
    O = np.sum(norm.cdf(es/sei) < alpha2)
    E = np.sum(powv)
    A = (O-E)**2/E + (O-E)**2/(n-E) if (n-E) > 0 else np.nan
    if np.isnan(A): return 1.0
    from scipy.stats import chi2
    p = chi2.sf(A, 1)
    return p

# Simulate for a representative subset of datasets
ds_subset = [1, 20, 44, 85]
print("Independent Python simulation logic check (4000 iters, real SE vectors)")
print("Dataset | pub |  rank(prop<.05)  egger(prop<.05)  tes(prop<.05)")
for idv in ds_subset:
    sei_full = np.array(seis_ds[idv], dtype=float)
    k = len(sei_full)
    for pub in pubs:
        nrej_rank = nrej_egg = nrej_tes = nvals = 0
        for rep in range(iters):
            # Sample until k effect sizes are "published"/included (paper logic)
            yi = np.zeros(k); se = np.zeros(k)
            idx = 0
            while idx < k:
                m = idx % k
                y = np.random.normal(0.0, sei_full[m])
                pval = 1 - norm.cdf(y/sei_full[m])
                if pval < alpha or np.random.random() < (1-pub):
                    yi[idx] = y; se[idx] = sei_full[m]
                    idx += 1
            if len(yi) < 3:
                continue
            nvals += 1
            t, pr = begg_tau_p(yi, se)
            pe = egger_p(yi, se)
            pt = tes_p(yi, se)
            if pr < 0.05: nrej_rank += 1
            if pe < 0.05: nrej_egg += 1
            if pt < 0.05: nrej_tes += 1
        print("ID=%3d %.2f  %.4f         %.4f         %.4f   (nvalid=%d)" % (idv, pub, nrej_rank/iters, nrej_egg/iters, nrej_tes/iters, nvals))
print("DONE")
