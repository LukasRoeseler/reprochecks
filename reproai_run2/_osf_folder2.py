import requests, time, sys

NODE = sys.argv[1]
FID = sys.argv[2]

def get_once(url):
    try:
        r = requests.get(url, timeout=20)
        if r.status_code == 200:
            return r.json()
    except Exception:
        return None
    return None

n = 0
while True:
    n += 1
    url = "https://api.osf.io/v2/nodes/{}/files/osfstorage/{}/?page[size]=100".format(NODE, FID)
    d = get_once(url)
    if d is not None:
        print("SUCCESS after {} polls".format(n), flush=True)
        for item in d.get("data", []):
            a = item["attributes"]
            dl = item.get("links", {}).get("download") or ""
            print("{}|{}|{}|{}".format(a["kind"], a["name"], item["id"], dl), flush=True)
        next_link = d.get("links", {}).get("next")
        if next_link:
            print("HAVE_NEXT " + next_link, flush=True)
        sys.exit(0)
    if n % 10 == 0:
        print("polled {} times, still failing".format(n), flush=True)
    time.sleep(5)
