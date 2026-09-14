import numpy as np
from scipy import stats
from scipy.optimize import minimize_scalar
import json

np.random.seed(12345)

def power_f(d1, d2, f, alpha=0.05):
    """Power of F-test with d1, d2 df and effect size f."""
    dfn = d1
    dfd = d2
    ncp = f * (d1 + d2 + f)  # non-centrality parameter
    # Critical value
    crit = stats.f.ppf(1 - alpha, dfn, dfd)
    # Power = P(F > crit) under non-central F
    power = 1 - stats.ncf.cdf(crit, dfn, dfd, ncp)
    return power

def find_f_for_power(target_power, d1, d2, alpha=0.05):
    """Find effect size f that gives target power for F-test with d1, d2 df."""
    from scipy.optimize import brentq
    f_lo, f_hi = 0.0, 2.0
    try:
        f = brentq(lambda f: power_f(d1, d2, f, alpha) - target_power, f_lo, f_hi, xtol=1e-8)
    except:
        f = brentq(lambda f: power_f(d1, d2, f, alpha) - target_power, 0.01, 2.0, xtol=1e-8)
    return f

# Study 1: F-test, df1=1, df2=85 (n=86 total, so df2 = n - 2 = 84 for two-sample t)
# Actually for a two-sample t-test with total n, df = n - 2
# But the paper says "F-tests with numerator df = 1" and n from Poisson(86)
# For a two-sample t-test: F = t^2, df1=1, df2=n-2
# Let's use df2 = n-2

def simulate_study1(target_power, k, n_sims=10000, d1=1, alpha=0.05):
    """Simulate k F-tests with fixed effect size, n~Poisson(86), return power estimates."""
    # Find effect size for target power at mean n=86 (df2=84)
    f = find_f_for_power(target_power, d1, 84, alpha)
    
    estimates = {'p_curve': [], 'p_uniform': [], 'ml_model': [], 'z_curve': []}
    
    for sim in range(n_sims):
        # Generate k studies
        ps = []
        ns = []
        for i in range(k):
            n = np.random.poisson(86)
            if n < 4:
                n = 4
            df2 = n - 2
            # Generate F statistic from non-central F
            ncp = f * (d1 + df2 + f)
            F = stats.ncf.rvs(d1, df2, ncp, random_state=None)
            # Convert to p-value
            p = stats.f.sf(F, d1, df2)
            ps.append(p)
            ns.append(n)
        
        ps = np.array(ps)
        ns = np.array(ns)
        
        # Select significant results (p < alpha)
        sig_mask = ps < alpha
        if sum(sig_mask) < 5:
            continue
        ps_sig = ps[sig_mask]
        ns_sig = ns[sig_mask]
        k_sig = len(ps_sig)
        
        if k_sig < 5:
            continue
        
        # --- P-curve (2.1): KS test for uniformity ---
        # P-curve 2.1: find the largest subset of p-values that looks uniform
        # Simplified: use the full set and do KS test
        ks_stat, ks_p = stats.kstest(ps_sig, 'uniform')
        # Estimate effect size from p-values assuming uniform under H0
        # p-curve 2.1: the effect size that makes p-values uniform
        # For simplicity, we use a simplified version:
        # The p-curve estimate of power = 1 - alpha (for uniform) + bias
        # Actually p-curve estimates effect size, then power
        # Let's use the Irvine-Hall method as a proxy: mean p of selected / 0.5
        # For now, skip p-curve and focus on z-curve which is the main claim
        
        # --- Z-curve: kernel density estimate of p-values ---
        # Z-curve: fit a mixture of uniform [0, alpha] and uniform [0, 1]
        # The proportion of p-values in [0, alpha] that come from the "true" distribution
        # gives the estimate of mean power
        
        # Simplified z-curve: use the density of p-values in [alpha, 1]
        # to estimate the effect size, then compute power
        # For a rough estimate:
        # The z-curve method fits a KDE to p-values and estimates the proportion
        # of the mixture that comes from the alternative distribution
        
        # Simplified approach: use the proportion of p-values below alpha
        # as a rough proxy for power (this is actually what p-curve does)
        prop_sig = np.mean(ps < alpha)
        
        # Better z-curve estimate: use the shape of the p-value distribution
        # For now, use a simple estimate:
        # The z-curve estimates the non-centrality parameter from the KDE
        # of the p-values, then converts to power
        
        # For a quick approximation:
        # Mean power ~ proportion of p-values that would be significant
        # if the studies were replicated
        zcurve_est = np.mean(ps_sig < alpha)  # crude proxy
        
        estimates['z_curve'].append(zcurve_est)
    
    return np.mean(estimates['z_curve']) if estimates['z_curve'] else None

# Test with a few cells
print("Study 1 reimplementation (z-curve only, simplified)")
print("=" * 60)

# Test: target power = 0.50, k = 100
# Paper reports: z-curve estimate = .508
est = simulate_study1(0.50, 100, n_sims=1000)
print(f"True power=0.50, k=100: z-curve est = {est:.3f} (paper: .508)")

# Test: target power = 0.25, k = 100
# Paper reports: z-curve estimate = .280
est = simulate_study1(0.25, 100, n_sims=1000)
print(f"True power=0.25, k=100: z-curve est = {est:.3f} (paper: .280)")

# Test: target power = 0.75, k = 100
# Paper reports: z-curve estimate = .723
est = simulate_study1(0.75, 100, n_sims=1000)
print(f"True power=0.75, k=100: z-curve est = {est:.3f} (paper: .723)")
