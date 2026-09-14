## ReproAI RE-AUDIT (2026-09-14) - Python 3.8 cross-language reimplementation.
## Haverkamp & Beauducel (2019), MP.2018.898.
## Purpose: recompute Type I error rates in a SECOND language (numpy/scipy/
## statsmodels) so that a bug in the R reimplementation cannot reproduce itself.
## Reimplements: (1) classical rANOVA + Huynh-Feldt, (2) MLM-CS via MixedLM,
## (3) MLM-UN via a multivariate-normal GLS with an unstructured covariance
## (independent of R's nlme::gls).
import numpy as np
from numpy.linalg import solve
from scipy import stats as st
import statsmodels.api as sm
from statsmodels.regression.mixed_linear_model import MixedLM
import pandas as pd

def gen_cov(m, sphericity):
    R = np.full((m, m), 0.5)
    np.fill_diagonal(R, 1.0)
    if sphericity == "violation":
        odd = [i for i in range(m) if (i + 1) % 2 == 1]  # 1-indexed odd
        for i in odd:
            for j in odd:
                if i != j:
                    R[i, j] = 0.8
    return R

def draw(n, m, sp, Sg):
    rng = np.random.default_rng()
    L = np.linalg.cholesky(Sg)
    Z = rng.standard_normal((n, m))
    return Z @ L.T

# ---------------- rANOVA + Huynh-Feldt ----------------
def ranova_p(Y):
    n, m = Y.shape
    tm = Y.mean(0); gm = Y.mean()
    SS_t = n * np.sum((tm - gm) ** 2)
    smean = Y.mean(1)
    resid = Y - tm[None, :] - (smean - gm)[:, None]
    SS_e = np.sum(resid ** 2)
    df1 = m - 1; df2 = (m - 1) * (n - 1)
    F = (SS_t / df1) / (SS_e / df2)
    p_assumed = 1 - st.f.cdf(F, df1, df2)
    S = np.cov(Y, rowvar=False)
    # orthonormalised helment contrasts -> GG epsilon
    H = np.zeros((m, m - 1))
    for k in range(m - 1):
        H[:k + 1, k] = 1
        H[k + 1, k] = -(k + 1)
    Hn = H / np.sqrt((H ** 2).sum(0))
    Sstar = Hn.T @ S @ Hn
    eig = np.linalg.eigvalsh(Sstar)
    eps_GG = eig.sum() ** 2 / ((m - 1) * (eig ** 2).sum())
    eps_HF = (n * (m - 1) * eps_GG - 2) / ((m - 1) * (n - 1 - (m - 1) * eps_GG))
    eps_HF = min(1, eps_HF)
    p_hf = 1 - st.f.cdf(F, eps_HF * df1, eps_HF * df2)
    return p_assumed, p_hf

def run_ranova(S_seed):
    S, seed = S_seed
    np.random.seed(seed)
    rows = []
    for m in (9, 12):
        for sp in ("hold", "violation"):
            Sg = gen_cov(m, sp)
            for n in (15, 20, 25, 30):
                pa = np.empty(S); ph = np.empty(S)
                for s in range(S):
                    Y = draw(n, m, sp, Sg)
                    pa[s], ph[s] = ranova_p(Y)
                rows.append(dict(m=m, sphericity=sp, n=n, S=S,
                                 rANOVA=(pa < 0.05).mean(),
                                 rANOVA_HF=(ph < 0.05).mean()))
    return pd.DataFrame(rows)

# ---------------- MLM-CS via statsmodels MixedLM ----------------
def mlm_cs_p(Y):
    n, m = Y.shape
    df = []
    for i in range(n):
        for t in range(m):
            df.append((i, t, Y[i, t]))
    d = pd.DataFrame(df, columns=["id", "t", "y"])
    d["id"] = d["id"].astype(object)
    md = MixedLM.from_formula("y ~ t", groups="id", data=d)
    fit = md.fit(reml=True)
    return fit.pvalues["t"]

def run_mlm_cs(seed=1):
    np.random.seed(seed)
    rows = []
    for m, sp, n in [(9, "hold", 15), (9, "hold", 30), (12, "hold", 15), (12, "hold", 30),
                     (9, "violation", 15), (9, "violation", 30),
                     (12, "violation", 15), (12, "violation", 30)]:
        Sg = gen_cov(m, sp)
        p = []
        for s in range(300):
            Y = draw(n, m, sp, Sg)
            p.append(mlm_cs_p(Y))
        rows.append(dict(m=m, sphericity=sp, n=n, S=300, MLM_CS=(np.array(p) < 0.05).mean()))
    return pd.DataFrame(rows)

# ---------------- MLM-UN via multivariate-normal GLS ----------------
## Model: Y[n,m]; Y_i ~ N(X B, Sigma) with X common trend t, Sigma unstructured.
## Pooled covariance + GLS (asymptotic/normal test, mirroring asymptotic df that
## inflates the UN Type I error for small n).
def mlm_un_p(Y):
    n, m = Y.shape
    t = np.arange(1, m + 1, dtype=float)
    # de-mean per occasion to estimate pooled Sigma
    Yc = Y - Y.mean(0)
    S = (Yc.T @ Yc) / (n - 1)
    S = (S + S.T) / 2 + 1e-9 * np.eye(m)
    # GLS beta estimate (common trend)
    X = np.tile(t[:, None], (n, 1))             # (n*m,1)
    y = Y.reshape(-1)
    Vinv = np.linalg.inv(S)
    Vbdiag = np.kron(np.eye(n), Vinv)
    XtV = X.T @ Vbdiag
    beta = solve(XtV @ X, XtV @ y)[0]
    cov_beta = 1.0 / (XtV @ X)[0, 0]
    z = beta / np.sqrt(cov_beta)
    p = 2 * (1 - st.norm.cdf(abs(z)))
    return p

def run_mlm_un(m, sp, n, S, seed):
    np.random.seed(seed)
    Sg = gen_cov(m, sp)
    p = []
    for s in range(S):
        Y = draw(n, m, sp, Sg)
        p.append(mlm_un_p(Y))
    return (np.array(p) < 0.05).mean()

if __name__ == "__main__":
    import sys
    outdir = sys.argv[1] if len(sys.argv) > 1 else "output"
    print("==== Python 3.8 cross-language recompute: Haverkamp & Beauducel 2019 ====")
    import scipy
    print("numpy", np.__version__, "scipy", scipy.__version__, "statsmodels",
          sm.__version__ if hasattr(sm, "__version__") else "?")
    for seed in (1, 2):
        df = run_ranova((2000, seed))
        fn = f"{outdir}/py_ranova_s2000_seed{seed}.csv"
        df.to_csv(fn, index=False)
        print("--- rANOVA seed", seed, "->", fn)
        print(df.to_string(index=False))
    dcs = run_mlm_cs(1)
    fcs = f"{outdir}/py_mlm_cs_s300_seed1.csv"
    dcs.to_csv(fcs, index=False)
    print("--- MLM-CS (statsmodels) ->", fcs); print(dcs.to_string(index=False))
    for (m, sp, n, S, seed) in [(9, "hold", 15, 400, 1)]:
        val = run_mlm_un(m, sp, n, S, seed)
        print(f"--- MLM-UN (Python, m={m} sp={sp} n={n} S={S}): {val:.4f}")
        print(f"{val:.4f}", file=open(f"{outdir}/py_mlm_un_result.txt", "w"))
    print("==== done ====")
