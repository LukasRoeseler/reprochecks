import pandas as pd
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check"
tidy = pd.read_csv(base+r"\data\generated\eeg_data_tidy.csv")
print("subjects (sorted unique):", sorted(tidy['subject'].astype(str).unique())[:15], "... n=", tidy['subject'].nunique())
print("stimulus", tidy['stimulus.condition'].unique())
print("grammar", tidy['grammar.condition'].unique())
print("electrode sample", sorted(tidy['electrode'].astype(str).unique())[:15], "n=", tidy['electrode'].nunique())
print("t range", tidy['t'].min(), tidy['t'].max())
# does subj '1' or '01' Language Grammatical exist?
for s in ['1','01','001']:
    n = tidy[(tidy['subject'].astype(str)==s)&(tidy['stimulus.condition']=='Language')&(tidy['grammar.condition']=='Grammatical')]
    print(f"subject str={s} Lang Gram rows:", len(n))
