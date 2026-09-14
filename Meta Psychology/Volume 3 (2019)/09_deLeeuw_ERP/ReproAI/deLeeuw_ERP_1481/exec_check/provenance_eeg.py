import requests, pandas as pd, numpy as np, io, os
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check"
h = {'User-Agent':'ReproAI'}
files = requests.get("https://api.osf.io/v2/nodes/zpm9t/files/osfstorage/5bbe1107ec292c00162d3219/", params={'page[size]':200}, headers=h).json()['data']
want = None
for it in files:
    nm = it['attributes']['name']
    if nm.startswith('01_') and 'Lang Gram' in nm:
        want = (it['id'], nm); break
print("fetching:", want)
mid = requests.get(f"https://api.osf.io/v2/files/{want[0]}/", headers=h).json()['data']
url = mid['links']['download']
txt = requests.get(url, headers=h).text
lines = txt.strip().splitlines()
print("raw txt lines:", len(lines), "first line head:", lines[0][:120])
# structure: 129 channels as columns, 1100 rows
ncols = len(lines[0].split())
print("ncols:", ncols)
# t = -100..999 ; rows=1100
arr = np.array([list(map(float, l.split())) for l in lines])
print("arr shape:", arr.shape)
# helper := 13 electrodes columns: indices in 129 = electrode numbers order?
# The file's 129 columns correspond to channels 1..129 in order
# We need t column: load-data.R sets t=-100:999 manually and reads cols _1.._129
t = np.arange(-100,1000)
# electrode numbers: 33,39,45,70,11,83,62,122,115,108,42,93,129 (order from load-data.R)
electrodes = [33,39,45,70,11,83,62,122,115,108,42,93,129]
# find a few t values to compare with eeg_data_tidy
tidy = pd.read_csv(base+r"\data\generated\eeg_data_tidy.csv")
sub = tidy[(tidy['subject']=='01')&(tidy['stimulus.condition']=='Language')&(tidy['grammar.condition']=='Grammatical')]
print("tidy rows for subj01 Lang Gram:", len(sub))
# compare electrode "33", t=600 and t=0
for e in [33, 129, 62]:
    col_idx = e-1  # if column order follows channel number
    for tv in [0,600,800]:
        row = np.where(t==tv)[0][0]
        rawval = arr[row, col_idx]
        tid = sub[(sub['electrode']==str(e))&(sub['t']==tv)]
        if len(tid)>0:
            print(f"elec {e} t={tv}: raw={rawval:.6f} tidy={tid['voltage'].iloc[0]:.6f} match={abs(rawval-tid['voltage'].iloc[0])<1e-9}")
        else:
            print(f"elec {e} t={tv}: not in tidy")
