import pandas as pd
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check"
excluded = {8,21,11,23,25,40}
beh = pd.read_csv(base+r"\data\generated\beh_data_tidy.csv")
print("correct dtype:", beh['correct'].dtype, "values:", beh['correct'].unique())
beh2 = beh[~beh['subject_id'].isin(excluded)]
beh2 = beh2[~beh2['syntax_cat'].isin(['Filler-Gram','Filler-Ungram'])].copy()
beh2['correct_num'] = beh2['correct'].astype(int)
acc = beh2.groupby(['syntax_cat','subject_id'])['correct_num'].mean()*100
res = acc.groupby('syntax_cat').agg(['mean','std'])
print(res)
raw = pd.read_csv(base+r"\data\raw\behavioral_data_raw.csv", low_memory=False)
print("raw cols", list(raw.columns))
print("raw rows", len(raw))
print(raw['syntax_cat'].value_counts() if 'syntax_cat' in raw.columns else 'no syntax_cat')
