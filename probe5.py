import pandas as pd, numpy as np
p=r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\causal-replication.dta'
df=pd.read_stata(p)
for w in ['weight','aw']:
    s=df[w].notna()
    print(w,'n',s.sum(),'sum',df.loc[s,w].sum(),'mean',df.loc[s,w].mean())
# subset swensenfav nonmissing
sub=df[df['swensenfav'].notna()]
print('swensenfav n',len(sub))
for w in ['weight','aw']:
    print(w,'sum over swensenfav sub',sub[w].sum())
sub2=df[df['acceptebribes' if 'acceptebribes' in df else 'acceptedbribes'].notna()]
sub2=df[df['acceptedbribes'].notna()]
print('acceptedbribes n',len(sub2),[sub2[w].sum() for w in ['weight','aw']])
sub3=df[df['resigninvest'].notna()]
print('resigninvest n',len(sub3),[sub3[w].sum() for w in ['weight','aw']])
