import os, csv, json

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
PDFS = os.path.join(BASE, "Nature Human Behavior", "pdfs")
CLS = os.path.join(BASE, "Nature Human Behavior", "NHB_MASTER_CLASSIFICATION.csv")
INV = os.path.join(BASE, "Nature Human Behavior", "ARTICLE_INVENTORY.csv")

# map article_id -> paper
inv = {}
with open(INV, encoding="utf-8") as f:
    for r in csv.DictReader(f):
        inv[r["article_id"]] = r  # article_id like s41562-019-XXXX

cls = {}
with open(CLS, encoding="utf-8") as f:
    for r in csv.DictReader(f):
        cls[r["num"]] = r["classification"]

# PDFs in folder
pdfs = [f for f in os.listdir(PDFS) if f.lower().endswith(".pdf")]
print("PDFs in folder:", len(pdfs))

def pdf_to_paper(fname):
    fname_l = fname.lower()
    if fname_l.startswith("10.1038_"):
        aid = "s41562-" + fname_l[len("10.1038_s41562-"):].replace(".pdf", "")
        return aid
    return None

# For each pdf, determine paper and whether it's already been audited (has paper.pdf)
mapping = []
for pdf in pdfs:
    aid = pdf_to_paper(pdf)
    row = inv.get(aid) if aid else None
    if not row:
        mapping.append({"pdf": pdf, "aid": aid, "num": None, "matched": False})
        continue
    num = row["num"]
    year = num[:4]
    vol = os.path.join(BASE, "Nature Human Behavior", f"Volume {year} ({year})")
    folder = None
    for d in os.listdir(vol):
        if d.startswith(num + "_"):
            folder = os.path.join(vol, d)
            break
    # already audited?
    already = False
    if folder:
        for fn in ("paper.pdf", "fulltext.pdf"):
            p = os.path.join(folder, fn)
            if os.path.exists(p):
                try:
                    with open(p, "rb") as f:
                        if f.read(5) == b"%PDF-":
                            already = True
                except:
                    pass
    mapping.append({
        "pdf": pdf, "aid": aid, "num": num, "author": row["first_author"],
        "classification": cls.get(num), "already_audited": already, "folder": folder,
        "matched": True,
    })

not_processed = [m for m in mapping if m["matched"] and not m["already_audited"]]
print("\nPDFs present but paper NOT yet audited with them:")
for m in not_processed:
    print(f"  {m['num']} {m['author']} [{m['classification']}] <- {m['pdf']}")
print("count:", len(not_processed))
