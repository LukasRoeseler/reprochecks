import requests, time, json, sys

NODE = sys.argv[1]
FID = sys.argv[2]

def get(url, tries=100):
    for i in range(tries):
        try:
            r = requests.get(url, timeout=45)
            if r.status_code == 200:
                return r.json()
        except Exception:
            pass
        if i % 10 == 0:
            print("  retry", i, flush=True)
        time.sleep(4)
    return None

d = None
while d is None:
    url = "https://api.osf.io/v2/nodes/{}/files/osfstorage/{}/?page[size]=100".format(NODE, FID)
    d = get(url)
    if d is None:
        print("unreachable, waiting 60s", flush=True)
        time.sleep(60)

for item in d.get("data", []):
    a = item["attributes"]
    dl = item.get("links", {}).get("download") or ""
    print("{}|{}|{}|{}".format(a["kind"], a["name"], item["id"], dl), flush=True)
