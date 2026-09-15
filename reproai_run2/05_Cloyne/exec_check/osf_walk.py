import json, urllib.request, time, sys

def get(url, tries=8):
    for i in range(tries):
        try:
            with urllib.request.urlopen(url, timeout=100) as r:
                return json.loads(r.read().decode())
        except Exception as e:
            time.sleep(8)
    return None

def walk(fid, prefix, out):
    url = "https://api.osf.io/v2/files/%s/children/" % fid
    data = get(url)
    if data is None:
        out.append(prefix + "ERROR:" + fid)
        return
    for e in data.get("data", []):
        id_ = e["id"]
        kind = e["attributes"]["kind"]
        name = e["attributes"]["name"]
        out.append("%s%s\t%s\t%s" % (prefix, kind, id_, name))
        if kind == "folder":
            walk(id_, prefix + "  ", out)

out = []
walk("6605711101fc9c0349316877", "", out)
print("\n".join(out))
with open(r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check\osf_replica_list.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(out))
