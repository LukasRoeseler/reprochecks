# ReproAI re-audit: independent SECOND-LANGUAGE (Python) z-curve reimplementation.
# Faithful port of the author's zcurve() to Python (scipy), used to cross-check the
# R reimplementation of Study 1 (heterogeneity in sample size only) without reusing
# the author's R code. Mirrors the author's algorithm:
#   Z = qnorm(1 - p/2); drop Z>6 (highp); reflect Z about 2*cv; KDE on [2,6] w/ 100 nodes;
#   fit mixture of 3 truncated normals minimizing sum|ab diff|; estimate mean power.
import numpy as np
from scipy import stats, integrate
from scipy.optimize import minimize
from scipy.stats import gaussian_kde

np.random.seed(20260914)

# ---- z-curve estimator (port of author's zcurve) ----
def zcurve_py(pvalues, ncomp=3, alpha=0.05):
    pvalues = np.asarray(pvalues, dtype=float)
    if pvalues.max() > alpha:
        raise ValueError("all tests must be significant")
    Z = stats.norm.ppf(1 - pvalues / 2.0)
    highp = np.mean(Z > 6.0)
    cv = stats.norm.ppf(1 - alpha / 2.0, 0, 1)
    Z = Z[Z < np.inf]
    Zlt = Z[Z < 6.0]
    if Zlt.size < 3:
        return np.nan
    augZ = np.concatenate([Zlt, 2 * cv - Zlt])
    # kernel density estimate on [2,6] with 100 nodes
    z = np.linspace(2, 6, 100)
    kde = gaussian_kde(augZ)  # Silverman default bw (Scott) - close to R default
    gap = z[1] - z[0]
    kurve = kde.evaluate(z)
    kurve = kurve / (np.sum(kurve) * gap)

    def adiff(theta):
        mu = theta[:ncomp]
        w = np.abs(theta[ncomp:])
        w = w / w.sum()
        dens = stats.norm.pdf(z[:, None], loc=mu[None, :])      # (100, ncomp)
        dens = dens / (np.sum(dens, axis=0) * gap)              # normalize each
        est = dens @ w                                          # weighted sum
        return np.sum(np.abs(est - kurve))

    x0 = np.concatenate([np.sort(stats.uniform.rvs(0, 6, ncomp)), np.full(ncomp, 1.0 / ncomp)])
    bounds = [(-6, 6)] * ncomp + [(0, 1)] * ncomp
    res = minimize(adiff, x0, method="L-BFGS-B", bounds=bounds,
                   options={"maxiter": 80, "maxfun": 800})
    mu = res.x[:ncomp]
    w = np.abs(res.x[ncomp:]); w = w / w.sum()
    l = np.sum(w * (1 - stats.norm.cdf(cv, loc=mu)))
    est = l * (1 - highp) + 1.0 * highp
    return est

# ---- simulation: significant F tests, variable n~Poisson(86), fixed effect size ----
alpha = 0.05
MEANN = 86
d1 = 1

def rn_sig(k):
    return np.maximum(np.random.poisson(MEANN, k), 3)

def expPower_f2(f2, nmc=200000):
    n = np.maximum(np.random.poisson(MEANN, nmc), 3)
    crit = stats.f.ppf(1 - alpha, d1, n - 2)
    return np.mean(1 - stats.ncf.cdf(crit, d1, n - 2, n * f2))

def findF2(target):
    if target <= 0.05:
        return 0.0
    lo, hi = 1e-4, 4.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if expPower_f2(mid) > target:
            hi = mid
        else:
            lo = mid
    return 0.5 * (lo + hi)

def genSigF(k, f2):
    n = rn_sig(k)
    ncp = n * f2
    crit = stats.f.ppf(1 - alpha, d1, n - 2)
    g = 1 - stats.ncf.cdf(crit, d1, n - 2, ncp)
    U = np.random.uniform(0, 1, k)
    FF = stats.ncf.ppf(1 - g * U, d1, n - 2, ncp)
    pv = stats.f.sf(FF, d1, n - 2)
    return pv

paper = {0.05: 0.049, 0.25: 0.280, 0.50: 0.508, 0.75: 0.723}
nsims = 200
k = 100
print("Python z-curve reimplementation (k=100, mean over %d sims)" % nsims)
for tp in [0.50, 0.75]:
    f2 = findF2(tp)
    ests = []
    for s in range(nsims):
        pv = genSigF(k, f2)
        e = zcurve_py(pv)
        if not np.isnan(e):
            ests.append(e)
    m = float(np.mean(ests)); sd = float(np.std(ests)); se = sd / np.sqrt(len(ests))
    print("true=%.2f zcurve=%.3f (SE=%.4f) paper=%.3f delta=%.3f n=%d" %
          (tp, m, se, paper[tp], m - paper[tp], len(ests)))
