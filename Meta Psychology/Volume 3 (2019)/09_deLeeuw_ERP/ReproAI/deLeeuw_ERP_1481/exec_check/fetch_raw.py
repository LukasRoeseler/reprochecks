import pandas as pd, numpy as np
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\exec_check"

# download 2 raw files for spot check into a temp dir
import urllib.request, json, io, urllib.error
def guid_for(name_sub):
    # we'll map from the listing we have
    return None
# We'll instead download via OSF API known file IDs. Let's get them fresh.
import requests
h = {'User-Agent':'ReproAI'}
# list raw/eeg
files = requests.get("https://api.osf.io/v2/nodes/zpm9t/files/osfstorage/5bbe1107ec292c00162d3219/", params={'page[size]':200}, headers=h).json()['data']
target_names = []
for it in files:
    nm = it['attributes']['name']
    if 'Lang Gram' in nm and '01' in nm.replace('.txt','').split('_') and nm.startswith('01_'):
        target_names.append((it['id'], nm))
    if 'Lang Ungram' in nm and nm.startswith('26_'):
        target_names.append((it['id'], nm))
print("raw files to fetch:", [t[1] for t in target_names])
