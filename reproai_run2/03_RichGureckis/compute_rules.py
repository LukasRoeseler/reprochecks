import pandas as pd, numpy as np
base = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\03_RichGureckis\downloads"

def load(fn):
    return pd.read_csv(base+"\\"+fn, dtype=str)

for fn in ["data_exp1.csv","data_exp2.csv","data_expS1.csv","data_expS2.csv"]:
    df = load(fn)
    nsub = df["uniqueid"].nunique()
    tst = (df["test"]=="True") if "test" in df.columns else False
    print(fn, "rows", len(df), "subjects", nsub, "test rows", int(tst.sum()) if tst is not False else "n/a")
