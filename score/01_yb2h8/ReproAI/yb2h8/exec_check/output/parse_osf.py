import json
out = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\01_yb2h8\ReproAI\yb2h8\exec_check\output"
def load(fn):
    with open(out+"\\"+fn, encoding="utf-8-sig") as f:
        s=f.read()
    for enc in ("utf-8-sig","utf-8"):
        try:
            return json.loads(s.strip())
        except Exception:
            pass
    nums=[int(x) for x in s.split() if x.strip().isdigit()]
    return json.loads(bytes(nums).decode("utf-8"))
def main():
    for fn in ["osf_node_full.json","osf_children.json","osf_preprint.json"]:
        d=load(fn)
        print("FILE:",fn)
        if fn.endswith("children.json"):
            print("  children count:", len(d.get("data",[])))
        elif fn.endswith("node_full.json"):
            a=d.get("data",{}).get("attributes",{})
            print("  title:", a.get("title"))
            print("  category:", a.get("category"))
            print("  date_created:", a.get("date_created"), "modified:", a.get("date_modified"))
            print("  public:", a.get("public"))
        elif fn.endswith("preprint.json"):
            a=d.get("data",{}).get("attributes",{})
            print("  title:", a.get("title"))
            print("  published:", a.get("date_published"), "modified:", a.get("date_modified"))
            print("  version:", a.get("version"), "current:", a.get("current_version"))
            print("  preprint_doi:", a.get("preprint_doi"), "doi:", a.get("doi"))
            print("  node id:", d.get("data",{}).get("relationships",{}).get("node",{}).get("data",{}).get("id"))
        print()
main()
