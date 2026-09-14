import pandas as pd
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check"
excluded = {8,21,11,23,25,40}
beh = pd.read_csv(base+r"\data\generated\beh_data_tidy.csv")
print("cols", list(beh.columns))
print("total rows", len(beh))
print("subject_id dtype", beh['subject_id'].dtype)
beh2 = beh[~beh['subject_id'].isin(excluded)]
beh2 = beh2[~beh2['syntax_cat'].isin(['Filler-Gram','Filler-Ungram'])]
print("after filter rows", len(beh2))
print("unique subjects:", sorted(beh2['subject_id'].unique()), "n=", beh2['subject_id'].nunique())
print("correct unique vals:", beh2['correct'].unique())
print("syntax_cat counts:\n", beh2['syntax_cat'].value_counts())
# check for any NaN correct
print("rows with NaN correct:", beh2['correct'].isna().sum())
# per subject per condition
acc = beh2.groupby(['syntax_cat','subject_id'])['correct'].mean()*100
print("subjects per condition:\n", acc.groupby('syntax_cat').count())
