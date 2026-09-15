import os, csv, json, glob

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
NHB = os.path.join(BASE, "Nature Human Behavior")

def read_csv(path):
    with open(path, encoding="utf-8") as f:
        return list(csv.DictReader(f))

# NHB classifications
cls = {}
with open(os.path.join(NHB, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    for r in csv.DictReader(f):
        cls[r["num"]] = r["classification"]

nhb19 = read_csv(os.path.join(NHB, "VOLUME_2019_REPROAI_SUMMARY.csv"))
nhb20 = read_csv(os.path.join(NHB, "VOLUME_2020_REPROAI_SUMMARY.csv"))

def has_real_pdf(folder):
    # look for paper.pdf or fulltext.pdf that is a real pdf
    for fn in ("paper.pdf", "fulltext.pdf"):
        p = os.path.join(folder, fn)
        if os.path.exists(p):
            try:
                with open(p, "rb") as f:
                    if f.read(5) == b"%PDF-":
                        return fn
            except:
                pass
    return None

def claims_count_from_arch(folder):
    # find extracted/manuscript_claims.md and count claims
    for root, dirs, files in os.walk(folder):
        if "manuscript_claims.md" in files and "ReproAI" in root:
            p = os.path.join(root, "manuscript_claims.md")
            try:
                with open(p, encoding="utf-8") as f:
                    txt = f.read()
                m = txt.rsplit("Total claims:", 1)
                if len(m) == 2:
                    return int("".join(ch for ch in m[1].strip() if ch.isdigit()) or 0)
            except:
                pass
    return None

def build_nhb(rows, volume):
    out = []
    for r in rows:
        num = r["num"]
        year = num[:4]
        folder = None
        vol = os.path.join(NHB, f"Volume {year} ({year})")
        if os.path.isdir(vol):
            for d in os.listdir(vol):
                if d.startswith(num + "_"):
                    folder = os.path.join(vol, d)
                    break
        pdf_fn = has_real_pdf(folder) if folder else None
        claims = claims_count_from_arch(folder) if folder else None
        sev = (r.get("severity") or "").upper()
        fulltext = pdf_fn is not None
        agent = "opencode/LLM (full-text)" if fulltext else "opencode/LLM (metadata/abstract)"
        out.append({
            "num": num, "volume": volume, "year": year,
            "authors": r["first_author"], "title": r["title"],
            "severity": sev,
            "fulltext_pdf": pdf_fn, "full_text_audited": fulltext,
            "claims": claims, "agent": agent,
            "message": r.get("message", ""), "links": r.get("links", ""),
        })
    return out

nhb19b = build_nhb(nhb19, "2019")
nhb20b = build_nhb(nhb20, "2020")

total = len(nhb19b) + len(nhb20b)
ft = sum(1 for s in nhb19b+nhb20b if s["full_text_audited"])
meta = total - ft
print(f"NHB empirical total={total}, full-text audited={ft}, metadata-only={meta}")
print(f"  2019: total={len(nhb19b)}, ft={sum(1 for s in nhb19b if s['full_text_audited'])}")
print(f"  2020: total={len(nhb20b)}, ft={sum(1 for s in nhb20b if s['full_text_audited'])}")

# Which full-text-audited papers are missing claims count?
no_claims_ft = [s["num"] for s in nhb19b+nhb20b if s["full_text_audited"] and not s["claims"]]
print("FT audited but no claims recorded:", no_claims_ft)

# Save inventory
with open(os.path.join(os.path.join(BASE,"Meta Psych vs NHB"), "nhb_inventory.json"), "w", encoding="utf-8") as f:
    json.dump({"nhb19": nhb19b, "nhb20": nhb20b}, f, indent=2, ensure_ascii=False)

# Show which metadata-only papers DO have a fulltext we could still process
meta_only = [s for s in nhb19b+nhb20b if not s["full_text_audited"]]
print("Metadata-only NHB papers:", len(meta_only))
