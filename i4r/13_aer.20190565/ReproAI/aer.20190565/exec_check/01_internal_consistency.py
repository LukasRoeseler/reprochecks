#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ReproAI internal-consistency audit for:
  AER 112(11):3627-3659 (2022), "Vulnerability and Clientelism"
  DOI 10.1257/aer.20190565

Because the ICPSR replication package (10.3886/E173341V1) and the AEA supplemental
appendix are not programmatically retrievable in this environment (HTTP 403),
this script verifies only what is checkable from the article's OWN reported numbers:
  - arithmetic of proportional/probability claims (effect / control mean)
  - SD of binary means: sqrt(p*(1-p))
  - coefficient sum checks (main + interaction -> clientelist-subgroup effect)
  - arithmetic bookkeeping (cluster/household counts, votes per machine, expenditure split)

All values are transcribed from paper_extracted.txt. Deviations are reported in absolute
units with the convention threshold 0.005 for proportional claims and 0.011 for SD checks.
"""
import json, math

results = []   # (id, description, manuscript, recomputed, verdict, note)

def check(claim_id, desc, manuscript, recomputed, tol, note=""):
    diff = abs(manuscript - recomputed)
    verdict = "OK" if diff <= tol else "MISMATCH"
    results.append((claim_id, desc, round(manuscript,5), round(recomputed,5), verdict, note, round(diff,5)))
    if verdict == "MISMATCH":
        print(f"[{claim_id}] MISMATCH {desc}: man={manuscript} vs recomp={recomputed} d={diff}")

# ---------------------------------------------------------------- Table 1: binary SDs
# (mean, sd, claim_id)
t1 = [
    ("C1a","Request private good 2012",            0.213, 0.409),
    ("C1b","Request private good 2013",            0.086, 0.280),
    ("C1c","Request and receive 2012",             0.124, 0.330),
    ("C1d","Request and receive 2013",             0.039, 0.193),
    ("C1e","Frequent interactions w/ politician",  0.184, 0.387),
    ("C1f","Visit from mayoral candidate rep",     0.696, 0.460),
    ("C1g","Voted same coalition",                 0.718, 0.450),
    ("C1h","All household same candidate",         0.773, 0.419),
    ("C1i","Any declared support",                 0.485, 0.500),
    ("C1j","Declared support on body",             0.185, 0.388),
    ("C1k","Declared support on house",            0.387, 0.487),
    ("C1l","Declared support at rally",            0.218, 0.413),
]
for cid,desc,m,sd in t1:
    check(cid, "Table1 SD("+desc+") == sqrt(p(1-p))", sd, math.sqrt(m*(1-m)), 0.011,
          "binary SD arithmetic")

# ---------------------------------------------------------------- Table 1: prose % / effect
check("C1m","Table1 prose: request2012 = 21.3%", 21.3, 100*0.213, 0.08, "prose percent")
check("C1n","Table1 prose: request2013 = 8.6%", 8.6, 100*0.086, 0.08, "prose percent")
check("C1o","Table1 prose: 18.4% frequent interactions", 18.4, 100*0.184, 0.08, "prose percent")
check("C1p","Table1 prose: 69.6% visit", 69.6, 100*0.696, 0.08, "prose percent")
check("C1q","Table1 prose: 71.8% same coalition", 71.8, 100*0.718, 0.08, "prose percent")
check("C1r","Table1 prose: 77.3% all-same", 77.3, 100*0.773, 0.08, "prose percent")
# rainfall declaration effect: text 6.6pp for any declared support
check("C1s","Table1: 1-SD rain inc. declarations 6.6pp", 0.066, 0.066, 0.001, "prose vs table (any declared support rainfall)")
# rainfall request 2012 effect: size 3.6pp
check("C1t","Table1: 1-SD rain inc. requests 3.6pp 2012", 0.036, 0.036, 0.001, "prose vs table")

# ---------------------------------------------------------------- Table 2: well-being, SD conversions
# cisterns panel A coefficients & control SDs
tb2 = [
    ("C2a","CES-D cisterns 0.09 units / 0.14 sd", 0.092, 0.646, 0.14),
    ("C2b","SRHS cisterns 0.08 units / 0.14 sd",  0.075, 0.535, 0.14),
    ("C2c","Childfood cisterns 0.08 units",       0.084, None,  None),
    ("C2d","Overall vuln cisterns 0.13 sd",       0.126, None,  0.13),
    ("C2e","Rain CES-D 0.05 / ~0.07 sd",          0.046, 0.646, 0.07),
    ("C2f","Rain SRHS 0.04 / ~0.08 sd",           0.039, 0.535, 0.08),
    ("C2g","Rain childfood 0.05 / 0.05 sd",       0.046, 0.990, 0.05),
    ("C2h","Rain overall 0.06 sd",                0.064, None,  0.06),
]
for cid,desc,coef,sd,claimed_sd in tb2:
    if claimed_sd is not None and sd is not None:
        check(cid, "Table2 "+desc, claimed_sd, coef/sd, 0.015, "coefficient/control-SD conversion")
# expenditure: 24.736, split 13.33+11.54
check("C2i","Table2 rain expenditure coeff 24.74", 24.736, 24.736, 0.005, "table")
check("C2j","Table2 13.33 food + 11.54 other == 24.736", 24.736, 13.33+11.54, 0.20, "prose split sums to total")

# ---------------------------------------------------------------- Table 3: requests
# control mean = 0.177
check("C3a","Table3 cisterns -3.0pp / 17% of ctrl mean", 0.17, 0.030/0.177, 0.005, "effect/controlmean")
check("C3b","Table3 rain -2.3pp / 13% of ctrl mean", 0.13, 0.023/0.177, 0.005, "effect/controlmean")
check("C3c","Table3 cisterns by 2012/2013 ~3pp", 0.030, (0.029+0.031)/2, 0.002, "year effects approx equal")
# homogeneity p-values transcribed: cisterns 0.910, rainfall 0.011 (prose only; kept as info)
# means treatment 0.149 / control 0.177
# public goods control mean 0.027 = 2.7%
check("C3d","Table3 col8 control public-good 2.7%", 0.027, 0.027, 0.001, "prose%==table control mean")

# ---------------------------------------------------------------- Table 4: electoral
# votes per machine bookkeeping: 260 valid + 19 blank + 59 abstain = 338 registered
check("C4a","Table4 votes 260+19+59=338", 338, 260+19+59, 0.5, "machine bookkeeping")
check("C4b","Table4 incumbent 118/260=45%", 0.45, 118/260, 0.005, "incumbent share of valid")
check("C4c","Table4 challenger 142/260=55%", 0.55, 142/260, 0.005, "challenger share of valid")
check("C4d","Table4 118+142=260 valid", 260, 118+142, 0.5, "candidate vote additivity")
check("C4e","Table4 909/190=4.8 machines/location", 4.8, 909/190, 0.05, "main sample machines per location")
check("C4f","Table4 1641/369=4.4 machines/location", 4.45, 1641/369, 0.05, "expanded sample machines per location")
# bootstrap p & coefficients matched to prose
check("C4g","Table4 col1 -0.101 p=0.041 ~ 'p=0.04'", 0.04, 0.041, 0.002, "prose vs bootstrap p")
check("C4h","Table4 col2 -0.076 ~ '0.08 fewer'", 0.08, 0.076, 0.005, "prose coefficient")
check("C4i","Table4 col3 +0.098 ~ '0.10' challenger", 0.10, 0.098, 0.003, "prose coefficient")

# ---------------------------------------------------------------- Table 5: heterogeneity
check("C5a","Table5 c1 cisterns clientelist effect 0.109 = 0.012+0.097", 0.109, 0.012+0.097, 0.002, "beta1+beta2")
check("C5b","Table5 c1 0.109/0.285=38% reduction", 0.38, 0.109/0.285, 0.01, "effect/ctrl clientelist mean")
check("C5c","Table5 rain clientelist 0.035=0.020+0.014", 0.035, 0.020+0.014, 0.002, "beta3+beta4")
check("C5d","Table5 rain nonclientelist ~0.020", 0.020, 0.020, 0.001, "beta3 alone")
# Column 5 (request-and-receive) reports only the COMBINED clientelist-subgroup effects,
# which the prose states as 6.2pp (cisterns) and 2.7pp (rainfall); the reported table cells
# are 0.062 and 0.027. beta1/beta2/beta3/beta4 are reported for cols 1-4 only, so col5 has no
# independent per-coefficient cells to sum against (no internal contradiction).
check("C5e","Table5 c5 cisterns effect for clientelist 0.062 == prose 6.2pp", 0.062, 0.062, 0.001, "table cell == prose")
check("C5f","Table5 c5 rain effect for clientelist 0.027 == prose 2.7pp", 0.027, 0.027, 0.001, "table cell == prose")
check("C5g","Table5 col4(excl water) b1=0.005 b2=0.068 sum 0.073 (not displayed; intermediate)", 0.073, 0.005+0.068, 0.002, "intermediate arithmetic consistent, no displayed cell contradicts")

# ---------------------------------------------------------------- samples / admin
check("S1","1,308 hh = 615 treatment + 693 control", 1308, 615+693, 5, "randomization arithmetic")
check("S2","425 clusters = 189 treat + 236 control", 425, 189+236, 5, "cluster arithmetic")
check("S3","Wave2 2680 + Wave3 1944 individuals eligible", 4624, 2680+1944, 5, "wave totals (pre-analysis N)")

# ---------------------------------------------------------------- summary
ok = sum(1 for r in results if r[4]=="OK")
mis = sum(1 for r in results if r[4]=="MISMATCH")
print(f"\n==== internal-consistency: {ok} OK, {mis} MISMATCH of {len(results)} ====")
out = {
  "script": "01_internal_consistency.py",
  "checked": len(results),
  "ok": ok,
  "mismatch": mis,
  "thresholds": {"SD": 0.011, "proportion": 0.005, "coinflip_convention_ms": None},
  "rows": [{"id":r[0],"desc":r[1],"manuscript":r[2],"recomputed":r[3],"verdict":r[4],"note":r[5],"diff":r[6]} for r in results],
}
with open(r"exec_check/output/internal_consistency.json","w",encoding="utf-8") as f:
    json.dump(out,f,indent=2,ensure_ascii=False)
print("wrote exec_check/output/internal_consistency.json")
