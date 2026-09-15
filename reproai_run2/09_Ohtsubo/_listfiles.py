import json, sys, io
d = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\09_Ohtsubo"
raw = [int(x) for x in open(d + r"\_files.json", encoding="utf-8-sig").read().split()]
s = bytes(raw).decode("utf-8")
j = json.loads(s)
out = io.open(d + r"\_files_list.txt", "w", encoding="utf-8")
out.write("count=%d\n" % len(j["data"]))
for it in j["data"]:
    a = it["attributes"]
    out.write("%s\t%s\t%s\t%s\t%s\n" % (it["id"], a.get("kind"), a.get("name"), a.get("size"), it.get("links", {}).get("download")))
out.close()
print("wrote", len(j["data"]))
