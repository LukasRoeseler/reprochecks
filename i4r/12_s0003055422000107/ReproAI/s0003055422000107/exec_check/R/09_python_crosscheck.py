import pandas as pd, numpy as np
import statsmodels.api as sm
from statsmodels.regression.mixed_linear_model import MixedLM

w = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\ReproAI\s0003055422000107\exec_check"
df = pd.read_csv(w + r"\output\t1m5_data.csv")
df["prop2f"] = df["prop2f"].astype(str)
df["rho"] = df["lag1_mfcombined10"] * df["chgvotelagged"]
df["countryc"] = df["country"].astype(str)
df["partyc"] = df["party"].astype(str)

# Cross-classified two random intercepts: groups=party, country as variance component
exog_cols = ["lag1_mfcombined10","chgvotelagged","rho","year","femaleleader2_lag",
             "cabinet_party2_lag","lag1womenpar","tier1_avemag2","natquota","weurope",
             "prop2f"]
X = pd.concat([pd.Series(np.ones(len(df)), name="Intercept"),
               df[exog_cols].replace("prop2f", "3")], axis=1)
df["prop2f_3"] = (df["prop2f"]=="3").astype(int)

md = MixedLM.from_formula(
    "pfem_new2 ~ lag1_mfcombined10 + chgvotelagged + rho + year + femaleleader2_lag + cabinet_party2_lag + lag1womenpar + tier1_avemag2 + prop2f_3 + natquota + weurope",
    groups="partyc",
    vc_formula={"country": "0 + C(countryc)"},
    data=df,
)
res = md.fit(reml=False, method="lbfgs")
print(res.summary())

# Interaction term is 'rho'
fe = res.params
print("\nPython (statsmodels MixedLM, ML) headline coefficients:")
print("Intercept           :", round(fe["Intercept"], 4))
print("lag1_mfcombined10   :", round(fe["lag1_mfcombined10"], 4))
print("chgvotelagged       :", round(fe["chgvotelagged"], 4))
print("INTERACTION(rho)    :", round(fe["rho"], 4))
print("N used:", int(res.nobs))
