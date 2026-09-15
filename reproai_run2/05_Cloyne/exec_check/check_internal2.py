import csv, glob, os

# Independent numeric checks on the human FLoRA reproduction (I4R DP132, Kopecky et al. 2024)
# Baseline: response of log GDP per capita to a 1%-of-GDP tax DECREASE; VAR p=4 endog (log gdp_pc, cons_pc, inv_pc), q=12 on exogenous tax shock, trend. (Cloyne 2013 Fig 3)

rows = [
    # method, impact, impact_se, impact_z, impact_lo95, impact_hi95, peak, peak_se, peak_z, peak_lo95, peak_hi95
    ("Author code (Matlab)", 0.599, 0.295, 2.033, 0.033, 1.189, 2.458, 0.797, 3.083, 0.937, 4.009),
    ("Author code - Adj. SEs", 0.599, 0.293, 2.044, 0.023, 1.180, 2.458, 1.012, 2.267, 0.385, 4.390),
    ("Stata reproduction", 0.567, 0.294, 1.925, -0.010, 1.144, 2.226, 0.981, 2.269, 0.303, 4.150),
]

out = []
for name, bi,sei,zi,loi,hei, bp,sep,zp,lop,hep in rows:
    z_check_i = bi/sei
    z_check_p = bp/sep
    ci_i = (bi-1.96*sei, bi+1.96*sei)
    ci_p = (bp-1.96*sep, bp+1.96*sep)
    out.append({
        "method": name,
        "impact": bi, "impact_se": sei, "reported_z_impact": zi, "recomputed_z_impact": round(z_check_i,3),
        "impact_95_reported": "[%.3f,%.3f]"%(loi,hei), "impact_95_from_se": "[%.3f,%.3f]"%ci_i,
        "peak": bp, "peak_se": sep, "reported_z_peak": zp, "recomputed_z_peak": round(z_check_p,3),
        "peak_95_reported": "[%.3f,%.3f]"%(lop,hep), "peak_95_from_se": "[%.3f,%.3f]"%ci_p,
    })

print("=== I4R DP132 reproduction internal-consistency (z = coef/SE; 95% CI = coef +/- 1.96*SE) ===")
for r in out:
    print(r["method"])
    print("  impact z rep %.3f vs recalc %.3f   peak z rep %.3f vs recalc %.3f" % (r["reported_z_impact"], r["recomputed_z_impact"], r["reported_z_peak"], r["recomputed_z_peak"]))
    print("  impact 95 CI reported {}  (from SE) {}".format(r["impact_95_reported"], r["impact_95_from_se"]))
    print("  peak 95 CI reported {}  (from SE) {}".format(r["peak_95_reported"], r["peak_95_from_se"]))

print()
print("=== Cross-source headline claim check ===")
print("Paper abstract: '1% tax cut increases GDP by 0.6% on impact and 2.5% over three years'")
print("I4R author-code reproduction: impact 0.599, peak 2.458  -> consistent with abstract rounding")
print("I4R Stata reproduction: impact 0.567, peak 2.226")

with open(r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check\output\i4r_consistency.csv","w",newline="",encoding="utf-8") as f:
    w=csv.DictWriter(f,fieldnames=list(out[0].keys())); w.writeheader(); w.writerows(out)
print("Wrote output/i4r_consistency.csv")

