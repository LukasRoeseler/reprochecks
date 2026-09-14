# ReproAI re-audit (2026-09-14) -- Independent SECOND-LANGUAGE (Python/scipy) recompute.
# Independent of the R author code: theorems (Fig 1/2, appendix), and Study 1 p-curve/p-uniform/ML
# columns of Table 1 with per-study df2. From-scratch in numpy/scipy using stats.ncf (noncentral F).
import numpy as np
from scipy import stats, optimize, integrate

RNG = np.random.default_rng(20260914)
alpha = 0.05
MEANN = 86.0

# ---------------- Theorems: Figure 1 (Uniform[0.05,1]) ----------------
a, b = 0.05, 1.0
before = (a + b) / 2
after = ((b**3 - a**3)/3) / ((b**2 - a**2)/2)

# ---------------- Figure 2: beta(13,6)*0.95+0.05 ----------------
def epow(k):
    f = lambda x: (0.95*x + 0.05)**k * stats.beta.pdf(x, 13, 6)
    return integrate.quad(f, 0, 1)[0]
E1, E2 = epow(1), epow(2)
before2, after2 = E1, E2 / E1

# ---------------- Appendix: locate df with E(power)=0.80, F(3,26) ----------------
crit = stats.f.ppf(1 - alpha, 3, 26)   # central F quantile
def power_expected(df):
    fun = lambda ncp, dfo=df: (1 - stats.ncf.cdf(crit, 3, 26, ncp)) * stats.chi2.pdf(ncp, dfo)
    return integrate.quad(fun, 0, np.inf, limit=300)[0]
df = optimize.brentq(lambda v: power_expected(v) - 0.8, 1, 60)

# ---------------- Study 1 estimators (per-study df2) ----------------
def rn_sig(k):
    return np.maximum(RNG.poisson(MEANN, k), 3)
def exp_power_f2(f2, nmc=200000):
    n = np.maximum(RNG.poisson(MEANN, nmc), 3)
    c = stats.f.ppf(1 - alpha, 1, n - 2)
    return np.mean(stats.ncf.sf(c, 1, n - 2, n*f2))
def find_f2(target):
    if target <= 0.05: return 0.0
    return optimize.brentq(lambda f2: exp_power_f2(f2) - target, 1e-4, 4)
def gen_sig(k, f2, rng):
    n = rn_sig(k); ncp = n*f2
    critv = stats.f.ppf(1 - alpha, 1, n-2)
    g = stats.ncf.sf(critv, 1, n-2, ncp)
    U = rng.uniform(size=k)
    FF = stats.ncf.ppf(1 - g*U, 1, n-2, ncp)
    return FF, n
def pcurve(FF, n):
    df2 = n-2; critv = stats.f.ppf(1-alpha, 1, df2)
    def KS(es0):
        pp = np.exp(stats.ncf.logsf(FF, 1, df2, n*es0) - stats.ncf.logsf(critv, 1, df2, n*es0))
        return np.max(np.abs(np.sort(pp) - np.linspace(0,1,len(pp),endpoint=False)))
    es = optimize.minimize_scalar(KS, bounds=(0,1), method='bounded').x
    return np.mean(stats.ncf.sf(critv, 1, df2, n*es))
def punif(FF, n):
    df2 = n-2; critv = stats.f.ppf(1-alpha, 1, df2); k = len(FF)
    def loss(es0):
        logP = stats.ncf.logsf(FF, 1, df2, n*es0) - stats.ncf.logsf(critv, 1, df2, n*es0)
        return (-sum(logP) - k)**2
    es = optimize.minimize_scalar(loss, bounds=(0,1), method='bounded').x
    return np.mean(stats.ncf.sf(critv, 1, df2, n*es))
def mle(FF, n):
    df2 = n-2; critv = stats.f.ppf(1-alpha, 1, df2)
    def mll(es0):
        nc = np.abs(n*es0)
        return sum(stats.ncf.logsf(critv, 1, df2, nc)) - sum(stats.ncf.logpdf(FF, 1, df2, nc))
    es = optimize.minimize_scalar(mll, bounds=(0,1), method='bounded').x
    return np.mean(stats.ncf.sf(critv, 1, df2, n*es))

paper = {"0.05":(0.059,0.058,0.057),"0.25":(0.253,0.251,0.251),
         "0.50":(0.497,0.496,0.497),"0.75":(0.747,0.746,0.747)}
nsims = 500
print("=== Study 1 p-curve/p-uniform/ML = per-study df2, Python recompute (nsims=%d) ===" % nsims)
for k in (100, 250):
    for tp in (0.25, 0.50, 0.75, 0.05):
        f2 = find_f2(tp)
        pc = pu = ml = np.empty(nsims)
        for s in range(nsims):
            FF, n = gen_sig(k, f2, RNG)
            pc[s] = pcurve(FF, n); pu[s] = punif(FF, n); ml[s] = mle(FF, n)
        pp = paper["%.2f" % tp]
        print("k=%d true=%.2f pcurve=%.3f punif=%.3f ml=%.3f  paper=(%.3f,%.3f,%.3f)" %
              (k, tp, pc.mean(), pu.mean(), ml.mean(), pp[0], pp[1], pp[2]))

print("\n=== Theorems ===")
rows = [("Fig1 before", before, 0.525), ("Fig1 after", after, 0.635),
        ("Fig2 before", before2, 0.700), ("Fig2 after", after2, 0.714),
        ("located df", df, 14.36826), ("integrate(df=14.36826)", power_expected(14.36826), 0.8000001)]
for label, comp, paperv in rows:
    d = abs(comp - paperv)
    flag = "MATCH" if d < 1e-3 else ("CLOSE" if d < 1e-2 else "DIFF")
    print("%-24s computed=%.6f paper=%.6f delta=%.2e %s" % (label, comp, paperv, d, flag))
print("DONE")
