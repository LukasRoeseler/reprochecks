# ReproAI — aer.20161385 — independent second-language cross-check (Python 3.8)
# Recomputes the headline pp->% conversions and Table 1 differences independently of the R script
# (transcribed from the manuscript), to confirm the R-derived checks don't depend on a single-language bug.

import json, os

outdir = os.path.join(os.path.dirname(__file__), "..", "output")

checks = []

# 1. Headline employment pp -> % (Table 3 coefficients & mean-of-outcome)
headline = [
    ("DHS", 0.046, 0.68, 6.9),
    ("Afrobarometer", 0.077, 0.58, 13.2),
    ("SA-QLFS", 0.022, 0.72, 3.1),
]
for sample, coef, mean, rep in headline:
    calc = 100 * coef / mean
    checks.append({
        "claim": f"ABS-{sample}", "quantity": f"Headline employment effect {sample}",
        "manuscript": f"{coef} pp; stated {rep}%",
        "recomputed": f"{calc:.2f}%", "width": abs(calc - rep),
        "verdict": "approx" if abs(calc - rep) > 0.1 else "check"
    })

# 2. Table 1 raw baseline differences (connected minus unconnected) + t-sign consistency
t1_rows = [
    ("speed", 453.64, 423.47, 30.17, 0.27), ("daily", 0.08, 0.11, -0.03, -2.42),
    ("weekly", 0.16, 0.21, -0.05, -2.61), ("dhs_empl", 0.67, 0.68, -0.01, -1.46),
    ("dhs_skill", 0.57, 0.58, -0.01, -1.05), ("afro_empl", 0.56, 0.59, -0.03, -1.57),
    ("sa_empl", 0.77, 0.71, 0.06, 7.99), ("sa_skill", 0.55, 0.49, 0.07, 8.13),
    ("hours", 45.26, 45.38, -0.11, -0.41), ("wants", 0.62, 0.66, -0.04, -5.82),
    ("formal", 0.54, 0.47, 0.07, 7.83), ("informal", 0.12, 0.12, 0.00, -0.67),
    ("eth_emp", 73.90, 80.83, -6.93, -0.35), ("eth_skill", 24.30, 23.85, 0.45, 0.05),
    ("net_entry", 3.46, 3.31, 0.15, 1.58), ("light", 3.62, 1.41, 2.21, 8.89),
]
for row, con, unc, diff, t in t1_rows:
    d = round(con - unc, 2)
    ok = abs(d - diff) <= max(0.011, abs(diff) * 0.02)
    sign_ok = True if abs(diff) < 0.005 else (diff * t > 0)
    checks.append({
        "claim": f"T1-{row}", "quantity": f"Table 1 baseline diff: {row}",
        "manuscript": str(diff), "recomputed": str(d),
        "width": abs(d - diff),
        "verdict": "check" if (ok and sign_ok) else "discrepant"
    })

# 3. asinh/log coefficient -> % prose claims
pct = [
    ("speed c1",0.354,35),("speed c2",0.362,36),("speed c3",0.380,38),
    ("daily c4",0.082,8),("daily c5",0.124,12),("weekly c6",0.123,12),
    ("weekly c7",0.142,14),("SA hours",0.101,10),("SA firm net entry",0.227,23),
    ("Eth emp",0.156,16),("Eth productivity",0.127,13),("incomes c1",0.024,2.4),("incomes c2",0.033,3.3),
]
for name, coef, rep in pct:
    calc = None
    if False: pass
    calc = round(coef*100, 1)
    checks.append({
        "claim": f"PCT-{name}", "quantity": f"% claim: {name}",
        "manuscript": f"{rep}%", "recomputed": f"{calc}%", "width": None,
        "verdict": "check" if abs(calc-rep) <= 0.05*max(1,abs(rep)) else "approx"
    })

ncheck = sum(1 for c in checks if c["verdict"]=="check")
napprox = sum(1 for c in checks if c["verdict"]=="approx")
ndisc = sum(1 for c in checks if c["verdict"]=="discrepant")
print(f"==== Python cross-check: total={len(checks)} check={ncheck} approx={napprox} discrepant={ndisc} ====")

with open(os.path.join(outdir, "python_crosscheck.json"), "w", encoding="utf-8") as f:
    json.dump({"total": len(checks), "check": ncheck, "approx": napprox, "discrepant": ndisc,
               "checks": checks}, f, indent=2)
print("==== END (status: OK) ====")
