import requests, time, sys

OUTDIR = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\01_Robertson_news"

def get(url, tries=80):
    for i in range(tries):
        try:
            r = requests.get(url, timeout=45)
            if r.status_code == 200:
                return r.json()
        except Exception:
            pass
        if i % 10 == 0:
            print("  retry", i, url, flush=True)
        time.sleep(4)
    return None

# Poll the scripts folder until it returns
fid = "66c7746ed2d4b0664b0b5586"
url = "https://api.osf.io/v2/nodes/bfhdw/files/osfstorage/{}/?page[size]=100".format(fid)
d = None
while d is None:
    d = get(url)
    if d is None:
        print("scripts folder unreachable, retrying in 60s", flush=True)
        time.sleep(60)

import json
with open(r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\_scripts_folder.json", "w", encoding="utf-8") as f:
    json.dump(d, f, indent=1)
print("GOT scripts folder items:", len(d.get("data", [])), flush=True)
for item in d.get("data", []):
    a = item["attributes"]
    print("ITEM:", a["kind"], a["name"], item["id"], item.get("links", {}).get("download"), flush=True)
