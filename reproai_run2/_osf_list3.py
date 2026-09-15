import requests, sys, time, os

OUT = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\_tree_%s.txt" % sys.argv[1]

def get(url, tries=60):
    for i in range(tries):
        try:
            r = requests.get(url, timeout=40)
            if r.status_code == 200:
                return r.json()
        except Exception:
            pass
        time.sleep(3)
    return None

written = set()
def emit(line):
    with open(OUT, "a", encoding="utf-8") as f:
        f.write(line + "\n")

def walk(node, folder_id, prefix):
    url = "https://api.osf.io/v2/nodes/{n}/files/osfstorage".format(n=node)
    if folder_id:
        url += "/" + folder_id
    url += "?page[size]=100"
    data = get(url)
    if data is None:
        emit("ERR\t" + url)
        return
    for item in data.get("data", []):
        at = item["attributes"]
        kind = at["kind"]
        name = at["name"]
        path = prefix + "/" + name if prefix else name
        dl = item.get("links", {}).get("download")
        emit("{}\t{}\t{}\t{}".format(kind, path, item["id"], dl))
        if kind == "folder":
            walk(node, item["id"], path)
    nxt = data.get("links", {}).get("next")
    while nxt:
        nd = get(nxt)
        if nd is None:
            emit("ERR\t" + nxt)
            break
        for item in nd.get("data", []):
            at = item["attributes"]
            kind = at["kind"]
            name = at["name"]
            path = prefix + "/" + name if prefix else name
            dl = item.get("links", {}).get("download")
            emit("{}\t{}\t{}\t{}".format(kind, path, item["id"], dl))
            if kind == "folder":
                walk(node, item["id"], path)
        nxt = nd.get("links", {}).get("next")

node = sys.argv[1]
fid = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2].lower() != "none" else None
walk(node, fid, "")
print("DONE")
