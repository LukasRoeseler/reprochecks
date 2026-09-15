import pandas as pd
x = pd.read_excel(r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\PBR_ADR.xlsx', sheet_name=None)
for k,v in x.items():
    print('===SHEET', k, 'shape', v.shape)
    print(v.head(30).to_string())
