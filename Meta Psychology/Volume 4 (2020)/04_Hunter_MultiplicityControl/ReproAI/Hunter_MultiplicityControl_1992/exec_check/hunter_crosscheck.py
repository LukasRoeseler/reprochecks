# ReproAI second-language cross-check (Python) of Hunter et al. (2020) MP.2019.1992
# Author simulation code is NOT available in the public OSF project (empty storage,
# fork source private). Per REPRO_STANDARDS.df section 5, headline results are
# recomputed in a SECOND language (Python) to cross-check the R reimplementation.
# Focus: no-control familywise error rates (Tables 3-4) and the flagship power
# contrast reported in the Results prose (.450 Holm all-pairs; .224 no-control 1 rep;
# .104 no-control 2 rep; .089 Bonferroni) for n=100, J=4, mu=(0,8,16,24).

import numpy as np
from scipy import stats

rng = np.random.default_rng(20260914)
ALPHA = 0.05
NSIM = 5000
SD = 20.0


def pair_p_values(grp_means, n, J):
    """Return p-values and |t| for all pairwise comparisons of a single draw.
    Equal-n two-sample pooled t-test."""
    data = rng.normal(grp_means[:, None], SD, size=(J, n))
    pairs = [(i, j) for i in range(J) for j in range(i + 1, J)]
    ps = []
    for (i, j) in pairs:
        a, b = data[i], data[j]
        ma, mb = a.mean(), b.mean()
        sp = np.sqrt(((var(a) * (n - 1)) + (var(b) * (n - 1))) / (2 * n - 2))
        t = (ma - mb) / (sp * np.sqrt(2.0 / n))
        p = 2 * (1 - stats.t.cdf(abs(t), 2 * n - 2))
        ps.append(p)
    return np.array(ps)


def var(x):
    return x.var(ddof=1)


def fwer_noc(grp_means, n, J, reps):
    """Proportion of sims where any TRUE-NULL comparison is significant in
    original AND all reps (no multiplicity control, alpha per comparison)."""
    npairs = J * (J - 1) // 2
    null_mask = np.array(
        [grp_means[i] == grp_means[j] for (i, j) in [(a, b) for a in range(J) for b in range(a + 1, J)]]
    )
    nnull = null_mask.sum()
    count = 0
    for s in range(NSIM):
        draws = [pair_p_values(grp_means, n, J) for _ in range(reps + 1)]
        # a true-null comparison is a false positive iff sig in ALL draws
        allsig = np.ones(npairs, dtype=bool)
        for d in draws:
            allsig &= (d < ALPHA)
        if allsig[null_mask].any():
            count += 1
    return count / NSIM


npairs = 6
# --- Table 3/4 no-control FWER checks ---
print("===== no-control FWER (R cross-check) =====")
# complete null, 4 groups, n=25
print("n25 J4 null NoC R0:", round(fwer_noc(np.array([0,0,0,0.0]), 25, 4, 0), 3))
print("n25 J4 null NoC R1:", round(fwer_noc(np.array([0,0,0,0.0]), 25, 4, 1), 3))
print("n100 J4 null NoC R0:", round(fwer_noc(np.array([0,0,0,0.0]), 100, 4, 0), 3))
print("n25 J4 partial NoC R0:", round(fwer_noc(np.array([0,0,0,8.0]), 25, 4, 0), 3))

# --- flagship power contrast for n=100, J=4, mu=(0,8,16,24) ---
print("===== flagship power (n=100, J=4, mu=0,8,16,24) =====")
mu = np.array([0, 8, 16, 24.0])
n, J = 100, 4
nonnull = np.array([mu[i] != mu[j] for (i, j) in [(a, b) for a in range(J) for b in range(a + 1, J)]])
# all non-null pairs are non-null here (all means distinct)

def allpairs_rate(control, reps):
    npairs = J * (J - 1) // 2
    count = 0
    for s in range(NSIM):
        draws = [pair_p_values(mu, n, J) for _ in range(reps + 1)]
        sig = [np.ones(npairs, dtype=bool) for _ in range(reps + 1)]
        # Bonferroni threshold alpha/6
        thresh = ALPHA / (J * (J - 1) // 2)
        for idx, d in enumerate(draws):
            if control == "bonf":
                sig[idx] = d < thresh
            elif control == "hol":
                # Holm stepwise
                order = np.argsort(d)
                rej = np.zeros(npairs, dtype=bool)
                for k in range(npairs):
                    if d[order[k]] <= ALPHA / (npairs - k):
                        rej[order[k]] = True
                    else:
                        break
                sig[idx] = rej
            else:
                sig[idx] = d < ALPHA
        allsig = sig[0]
        for i in range(1, reps + 1):
            allsig = allsig & sig[i]
        if allsig.all():
            count += 1
    return count / NSIM

print("Holm no-rep all-pairs (.45 proud):", round(allpairs_rate("hol", 0), 3))
print("No-control 1-rep all-pairs (.224):", round(allpairs_rate("noc", 1), 3))
print("No-control 2-rep all-pairs (.104):", round(allpairs_rate("noc", 2), 3))
print("Bonferroni no-rep all-pairs (.089):", round(allpairs_rate("bonf", 0), 3))
print("===== END (status: OK) =====")
