import pandas as pd
p=r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\causal-replication.dta'
df=pd.read_stata(p)
print('shape',df.shape)
print('cols',list(df.columns))
for c in ['swensenfav','acceptedbribes','resigninvest','innuendo','denial','causal','aw','swensenrand']:
    if c in df.columns:
        print(c, 'nonnull', df[c].notna().sum(), 'nunique', df[c].nunique())
