import pandas as pd, numpy as np, sys, json
sys.stdout.reconfigure(encoding='utf-8')
base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\12_AntrasChor\data"

d = pd.read_stata(base + r"\downstreamness.dta")
s = pd.read_stata(base + r"\IOsigmas.dta")
f = pd.read_stata(base + r"\factorintensities.dta")
r = pd.read_stata(base + r"\randdintensity.dta")
disp = pd.read_stata(base + r"\dispersion.dta")
m = d.merge(s, on="io2002", how="left")

out = {}
out["rows_downstreamness"] = int(len(d))
for c in ["duse_tuse", "downmeasure"]:
    x = d[c].dropna()
    out[c] = {"n": int(len(x)), "mean": round(float(x.mean()), 4),
              "sd": round(float(x.std()), 4), "min": round(float(x.min()), 4),
              "max": round(float(x.max()), 4)}

# Median split consistency
sub = m.dropna(subset=["w1sigma", "w1M1sigma", "w1M2sigma"])
med = sub["w1sigma"].median()
lo = sub["w1sigma"] < med
out["w1sigma_median"] = round(float(med), 4)
out["M1sigma_frac_below_median"] = round(float((sub.loc[lo, "w1M1sigma"] == 1).mean()), 4)
out["M1sigma_frac_above_median"] = round(float((sub.loc[~lo, "w1M1sigma"] == 1).mean()), 4)
out["M2sigma_frac_below_median"] = round(float((sub.loc[lo, "w1M2sigma"] == 1).mean()), 4)
out["M2sigma_frac_above_median"] = round(float((sub.loc[~lo, "w1M2sigma"] == 1).mean()), 4)
out["both_M1M2_1"] = int(((sub["w1M1sigma"] == 1) & (sub["w1M2sigma"] == 1)).sum())

# Interaction column consistency (stale precomputed vars in downstreamness.dta)
mm = m.dropna(subset=["M1duse_tuse", "w1M1sigma", "duse_tuse"])
calc = mm["duse_tuse"] * mm["w1M1sigma"]
out["M1duse_matches_duse_times_M1sigma"] = round(float((np.abs(mm["M1duse_tuse"] - calc) < 1e-9).mean()), 4)
mmc = m.dropna(subset=["M2duse_tuse", "w1M2sigma", "duse_tuse"])
calcc = mmc["duse_tuse"] * mmc["w1M2sigma"]
out["M2duse_matches_duse_times_M2sigma"] = round(float((np.abs(mmc["M2duse_tuse"] - calcc) < 1e-9).mean()), 4)

# Number of manufacturing industries (io2002 starting with 3)
mfg = d[d["io2002"].astype(str).str.startswith("3")]
out["n_mfg_industries_downstreamness"] = int(len(mfg))

# Regression-sample size sanity: paper Table III N=2783
out["N_tableIII_published"] = 2783

print(json.dumps(out, indent=2))
