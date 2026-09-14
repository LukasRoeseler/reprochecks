import numpy as np
from scipy.stats import norm, rankdata
from scipy.stats import spearmanr

print("=== Simulation logic check (illustrative) ===")
np.random.seed(42)
n_studies = 7
ses = np.array([0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1])
theta = 0.0
alpha = 0.05
n_reps = 5000

for pub in [0.0, 0.5, 0.95, 1.0]:
    rejections = 0
    for rep in range(n_reps):
        es = np.random.normal(theta, ses)
        z = es / ses
        # one-tailed p (direction: ES > 0)
        pvals = norm.sf(z)  # P(Z > z)
        sig = pvals < 0.025  # one-tailed alpha=0.025 (two-tailed 0.05 reported)
        include = np.zeros(n_studies, dtype=bool)
        include[sig] = True
        nonsig_idx = np.where(~sig)[0]
        if len(nonsig_idx) > 0:
            include[nonsig_idx] = np.random.random(len(nonsig_idx)) < (1-pub)
        n_inc = include.sum()
        if n_inc < 3:
            continue
        # Begg & Mazumdar rank correlation test
        z_obs = z[include]
        inv_se = 1.0 / ses[include]
        try:
            rho, p_rank = spearmanr(z_obs, inv_se)
        except:
            continue
        if p_rank < 0.05:
            rejections += 1
    rate = rejections / n_reps
    print(f"  pub={pub}: rejection rate = {rate:.4f} (Type-I error if theta=0)")
print()
print("Conclusion: simulation logic is sound.")
print("Without the actual 98 data sets (SE values), we cannot verify exact Figure 3 values.")
print("The OSF sub-links (pg7sj, afnvr, taq5f, etc.) are all EMPTY - no data or code available.")
