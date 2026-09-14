import openpyxl
f = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check\data\generated\Good_Segments_Per_Category.xlsx"
wb = openpyxl.load_workbook(f)
ws = wb["Sheet1"]
rows = list(ws.iter_rows(values_only=True))
# headers at index 2
data = {}
for r in rows[3:]:
    if r[1] is None:
        continue
    pid = int(r[1])
    lg, lu, mg, mu = r[2], r[3], r[4], r[5]
    data[pid] = dict(lang_gram=lg, lang_ungram=lu, music_gram=mg, music_ungram=mu)

excluded = {8, 21, 11, 23, 25, 40}
included = [p for p in sorted(data) if p not in excluded and all(v is not None for v in [data[p]['lang_gram'],data[p]['lang_ungram'],data[p]['music_gram'],data[p]['music_ungram']])]
print("analytic sample count:", len(included))
print("analytic sample:", included)
print("excluded individuals present in sheet:", sorted([p for p in data if p in excluded]))

import statistics as st
conds = ["lang_gram", "lang_ungram", "music_gram", "music_ungram"]
for c in conds:
    vals = [data[p][c] for p in included]
    print(f"{c}: n={len(vals)} mean={st.mean(vals):.2f}")
    # also report the two language means
