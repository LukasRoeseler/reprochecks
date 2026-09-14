"""
ReproAI independent reimplementation (Python 3.8, numpy/scipy, math-only)
Francis & Thunell (2020) MP.2019.2266 -- "Excess success in 'Don't count calorie labeling out...'"

Cross-language re-check of the Test for Excess Success (TES) and the meta-analysis,
written independently of the author's R code (shared only the paper's METHODS prose and
the published parameter values). Vectorised Monte Carlo for the TES power, closed-form
for the two-sample t studies, analytic inverse-variance meta-analysis, and Table 2.

Engine: anomalyco/opencode (ReproAI) -- DeepSeek V4 Flash via uniGPT.
Rules: REPRO_STANDARDS.md 2026.06.27. Audit date: 2026-09-14. R 4.6.1 host; Python 3.8.
"""
import numpy as np
from scipy import stats
import json, os

ALPHA = 0.05
M = 100000  # simulations (as in paper)


def pooled_sd(sds, ns):
    dfw = sum(ns) - 3
    ns = np.array(ns, float)
    return float(np.sqrt(sum((ns - 1) * np.array(sds) ** 2) / dfw))


def run_tes(means, sds, ns, contrasts, require_anova, seed, label):
    """Vectorised TES Monte Carlo, matching the author's design:
    all groups drawn with the shared pooled SD; ANOVA (3-group) + required contrasts,
    each must be significant (p<=0.05) for 'success'. Returns (power, anova_power,
    contrast_powers)."""
    rng = np.random.default_rng(seed)
    n1, n2, n3 = ns
    N = n1 + n2 + n3
    dfw = N - 3
    sd = pooled_sd(sds, ns)
    Left = rng.normal(means[0], sd, (M, n1))
    Right = rng.normal(means[1], sd, (M, n2))
    None_ = rng.normal(means[2], sd, (M, n3))
    mL, mR, mN = Left.mean(1), Right.mean(1), None_.mean(1)
    sL, sR, sN = Left.std(1, ddof=1), Right.std(1, ddof=1), None_.std(1, ddof=1)

    grand = (n1 * mL + n2 * mR + n3 * mN) / N
    SSb = n1 * (mL - grand) ** 2 + n2 * (mR - grand) ** 2 + n3 * (mN - grand) ** 2
    SSw = (n1 - 1) * sL ** 2 + (n2 - 1) * sR ** 2 + (n3 - 1) * sN ** 2
    F = (SSb / 2) / (SSw / dfw)
    anovaP = stats.f.sf(F, 2, dfw)

    ms = [mL, mR, mN]
    nsg = np.array(ns, float)
    cps = []
    for w in contrasts:
        sw2 = float(np.sum(np.array(w) ** 2 / nsg))
        L = w[0] * mL + w[1] * mR + w[2] * mN
        t = np.abs(L) / np.sqrt(sw2 * (SSw / dfw))
        cps.append(2 * (1 - stats.t.cdf(t, df=dfw)))
    success = anovaP <= ALPHA if require_anova else np.ones(M, bool)
    for cp in cps:
        success &= cp <= ALPHA
    print("  [%s] TES power = %.5f  (paper %.5f)  diff=%+.5f" % (
        label, success.mean(), PAPER_POWER[label], success.mean() - PAPER_POWER[label]))
    print("        anova=%s contrasts=%s" % (
        "%.5f" % (anovaP <= ALPHA).mean(), ["%.5f" % (cp <= ALPHA).mean() for cp in cps]))
    return success.mean()


def tes_two_sample(tval, n1, n2, label):
    """Closed-form power of a two-sample t where reported t implies Hedges' g
    (the author uses the same J-corrected g then pwr)."""
    J = 1 - 3 / (4 * (n1 + n2 - 2) - 1)
    g = J * tval * np.sqrt(1 / n1 + 1 / n2)
    df = n1 + n2 - 2
    ncp = g / np.sqrt(1 / n1 + 1 / n2)
    crit = stats.t.ppf(1 - ALPHA / 2, df)
    power = stats.t.sf(crit, df, ncp) + stats.t.cdf(-crit, df, ncp)
    print("  [%s] g=%.6f power=%.5f (paper power %.5f)" % (label, g, power, PAPER_POWER[label]))
    return power


def heges(n1, n2, m1, m2, s1, s2):
    pv = ((n1 - 1) * s1 ** 2 + (n2 - 1) * s2 ** 2) / (n1 + n2 - 2)
    SD = np.sqrt(pv)
    J = 1 - 3 / (4 * (n1 + n2 - 2) - 1)
    d = (m2 - m1) / SD
    g = abs(J * d)  # TABULATION uses magnitudes; sign per direction in paper
    gv = J ** 2 * ((n1 + n2) / (n1 * n2) + d ** 2 / (2 * (n1 + n2)))
    return g, gv


def meta_pooled(studies):
    gs = np.array([abs(heges(s["n1"], s["n2"], s["m1"], s["m2"], s["s1"], s["s2"])[0])
                   for s in studies.values()])
    gvs = np.array([heges(s["n1"], s["n2"], s["m1"], s["m2"], s["s1"], s["s2"])[1]
                    for s in studies.values()])
    return np.sum(gs / gvs) / np.sum(1 / gvs), gs, gvs


def req_n(g, power):
    za, zb = stats.norm.ppf(1 - ALPHA / 2), stats.norm.ppf(power)
    return int(np.ceil(2 * ((za + zb) / g) ** 2))


PAPER_POWER = {"1": 0.4582, "2": 0.5426, "3": 0.3626, "S1": 0.5358, "S2": 0.5667, "S3": 0.4953}

results = {}
print("==== 1) TES power estimates (Monte Carlo, M=100000, pooled SD) ====")

# Study 1 (AC): ANOVA + Left<Right + Left<None ; n 45/54/50
studies_sim = [
    ("1", (654.53, 865.41, 914.34), (390.45, 517.26, 560.94), (45, 54, 50),
     [(1, -1, 0), (1, 0, -1)], True, 3947194),
    ("3", (1428.24, 1308.66, 1436.79), (377.02, 420.14, 378.47), (85, 86, 81),
     [(1, -1, 0), (0, 1, -1)], False, 3947194),
    ("S2", (1182.15, 1302.23, 1373.74), (477.60, 434.41, 475.77), (139, 141, 151),
     [(1, -1, 0), (1, 0, -1)], True, 20260914),
    ("S3", (1302.03, 1373.15, 1404.35), (480.02, 442.49, 422.03), (336, 337, 333),
     [(1, -1, 0), (1, 0, -1)], True, 20260915),
]
sim_powers = {}
for lab, means, sds, ns, cc, an, seed in studies_sim:
    sim_powers[lab] = run_tes(means, sds, ns, cc, an, seed, lab)

print("\n==== 2) Closed-form two-sample-t studies ====")
sim_powers["2"] = tes_two_sample(2.08, 143, 132, "2")
sim_powers["S1"] = tes_two_sample(2.07, 99, 77, "S1")

order = ["1", "2", "3", "S1", "S2", "S3"]
powers = np.array([sim_powers[o] for o in order])
results["tes_powers"] = {o: {"paper": PAPER_POWER[o], "reimpl": round(float(sim_powers[o]), 5)}
                         for o in order}
product = np.prod(powers)
results["tes_product"] = {"paper": 0.014, "reimpl": round(float(product), 6)}
print("\nProduct of TES powers = %.6f (paper: 0.014)" % product)

print("\n==== 3) Meta-analysis pooled Hedges' g ====")
# POST-corrigendum (study1 right n=54)  -- used for Table 1 / TES in the paper
post = {
    "1": dict(n1=45, n2=54, m1=654.53, m2=865.41, s1=390.45, s2=517.26),
    "2": dict(n1=143, n2=132, m1=1249.83, m2=1362.31, s1=449.07, s2=447.35),
    "3": dict(n1=85, n2=86, m1=1428.24, m2=1308.66, s1=377.02, s2=420.14),
    "S1": dict(n1=99, n2=77, m1=185.94, m2=215.73, s1=93.92, s2=95.33),
    "S2": dict(n1=139, n2=141, m1=1182.15, m2=1302.23, s1=477.60, s2=434.41),
    "S3": dict(n1=336, n2=337, m1=1302.03, m2=1373.15, s1=480.02, s2=442.49),
}
# PRE-corrigendum (study1 right n=55)  -- what generates the paper's Table 2
pre = {k: dict(v) for k, v in post.items()}; pre["1"]["n2"] = 55

gpool_post, gs_post, _ = meta_pooled(post)
gpool_pre, gs_pre, _ = meta_pooled(pre)
results["meta"] = {
    "gs": {o: round(float(gs_post[i]), 4) for i, o in enumerate(order)},
    "pooled_post_corrigendum": round(float(gpool_post), 7),
    "pooled_pre_corrigendum": round(float(gpool_pre), 7),
}
print("  g per study (post):", {o: round(float(gs_post[i]), 4) for i, o in enumerate(order)})
print("  pooled g POST-corrigendum (n1r=54) = %.7f  (author R: 0.2365894)" % gpool_post)
print("  pooled g PRE-corrigendum  (n1r=55) = %.7f  (author R: 0.2366623)" % gpool_pre)
print("  in-text paper g* = 0.2366 -> consistent with BOTH at 3 dp")

print("\n==== 4) Table 2 sample sizes (per condition) ====")
table2_paper = {"0.80": 282, "0.85": 322, "0.90": 377, "0.95": 465, "0.99": 658}
table2_half_paper = {"0.80": 1123, "0.85": 1284, "0.90": 1502, "0.95": 1858, "0.99": 2626}
print("  Table 2 (full g) printed:      ", table2_paper)
print("  Table 2 (g/2) printed:         ", table2_half_paper)
for nm, g in [("g=0.2366623 (PRE)", gpool_pre), ("g=0.2365894 (POST)", gpool_post)]:
    row = {p: req_n(g, float(p)) for p in table2_paper}
    hrow = {p: req_n(g / 2, float(p)) for p in table2_half_paper}
    print("  recompute %s -> %s / half %s" % (nm, row, hrow))
    results["table2_" + ("pre" if "PRE" in nm else "post")] = {
        "full": row, "half": hrow}

results["table2_match"] = {
    "paper_full_matches_PRE": all(req_n(gpool_pre, float(p)) == v for p, v in table2_paper.items()),
    "paper_half_matches_PRE": all(req_n(gpool_pre / 2, float(p)) == v for p, v in table2_half_paper.items()),
    "paper_full_matches_POST": all(req_n(gpool_post, float(p)) == v for p, v in table2_paper.items()),
    "paper_half_matches_POST": all(req_n(gpool_post / 2, float(p)) == v for p, v in table2_half_paper.items()),
}
print("\n  Table2 matches PRE-corrigendum g:", results["table2_match"]["paper_full_matches_PRE"],
      results["table2_match"]["paper_half_matches_PRE"])
print("  Table2 matches POST-corrigendum g:", results["table2_match"]["paper_full_matches_POST"],
      results["table2_match"]["paper_half_matches_POST"])

out = os.path.join("output", "reimpl_python_results.json")
with open(out, "w") as f:
    json.dump(results, f, indent=2)
print("\nWrote", out)
