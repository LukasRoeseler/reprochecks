import pandas as pd
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check"
raw = pd.read_csv(base+r"\data\raw\behavioral_data_raw.csv", low_memory=False)
tidy = pd.read_csv(base+r"\data\generated\beh_data_tidy.csv")

# replicate load-data.R logic
keep_syn = ['Grammatical','Ungrammatical','Filler-Ungram','Filler-Gram','In-Key','Distant-Key']
d = raw[raw['stimulus_type'] != 'NULL']
d = d[d['syntax_cat'].isin(keep_syn)].copy()
d = d[['subject_id','rt','key_press','stimulus_type','syntax_cat']]
d['correct'] = ((d['key_press']==65) & (d['syntax_cat'].isin(['Grammatical','In-Key','Filler-Gram']))) | \
               ((d['key_press']==85) & (d['syntax_cat'].isin(['Ungrammatical','Distant-Key','Filler-Ungram'])))
d = d.reset_index(drop=True)

t = tidy.reset_index(drop=True)
# compare
print("raw-derived rows:", len(d), "tidy rows:", len(t))
comp = pd.concat([d['subject_id'].astype(str).str.zfill(2) + '|' + d['syntax_cat'] + '|' + d['key_press'].astype(str),
                  t['subject_id'].astype(str) + '|' + t['syntax_cat'] + '|' + t['key_press'].astype(str)], axis=1)
print("row keys equal:", (comp.iloc[:,0]==comp.iloc[:,1]).all())
print("correct equal:", (d['correct'].astype(bool)).equals(t['correct'].astype(bool)))
print("rt equal:", (d['rt'].astype(str)).equals(t['rt'].astype(str)))
# subject_id type in tidy
print("tidy subject_id dtype:", t['subject_id'].dtype, "sample:", sorted(t['subject_id'].astype(str).unique())[:8])
print("subject 8 rows in tidy:", (t['subject_id']==8).sum())
print("subject 8 presence (str):", (t['subject_id'].astype(str)=='8').sum())
