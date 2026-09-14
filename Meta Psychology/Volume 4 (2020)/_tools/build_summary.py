import pandas as pd
df = pd.read_csv(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)\VOLUME4_REPROAI_SUMMARY.csv")
df.to_excel(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)\VOLUME4_REPROAI_SUMMARY.xlsx", index=False)
print("XLSX written")