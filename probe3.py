import pandas as pd
x = pd.read_excel(r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\PBR_ADR.xlsx', sheet_name=None)
out=[]
for k,v in x.items():
    out.append('===SHEET '+k+' shape '+str(v.shape))
    col1=v.columns[0]; col2=v.columns[1]
    for i,row in v.iterrows():
        a=row[col1]; b=row[col2]
        out.append(f'{i} | {a} | {b}')
p=r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\02_NyhanReifler\_PBR_dump.txt'
open(p,'w',encoding='utf-8').write('\n'.join(str(z) for z in out))
print('written',p)
