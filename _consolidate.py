import os, csv, json, html
from datetime import date

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
NHB = os.path.join(BASE, "Nature Human Behavior")

def read_csv(path):
    with open(path, encoding="utf-8") as f:
        return list(csv.DictReader(f))

# ---------- NHB inventory ----------
cls = {}
with open(os.path.join(NHB, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    for r in csv.DictReader(f):
        cls[r["num"]] = r["classification"]

def build_nhb(rows, volume):
    out=[]
    for r in rows:
        num=r["num"]; year=num[:4]
        sev=(r.get("severity") or "").upper()
        # detect fulltext
        folder=None; pdf_fn=None; claims=None
        vol=os.path.join(NHB, f"Volume {year} ({year})")
        if os.path.isdir(vol):
            for d in os.listdir(vol):
                if d.startswith(num+"_"):
                    folder=os.path.join(vol,d); break
        if folder:
            for fn in ("paper.pdf","fulltext.pdf"):
                p=os.path.join(folder,fn)
                if os.path.exists(p):
                    try:
                        with open(p,"rb") as f:
                            if f.read(5)==b"%PDF-": pdf_fn=fn; break
                    except: pass
            for root,dirs,files in os.walk(folder):
                if "manuscript_claims.md" in files and "ReproAI" in root:
                    try:
                        with open(os.path.join(root,"manuscript_claims.md"),encoding="utf-8") as f:
                            t=f.read()
                        m=t.rsplit("Total claims:",1)
                        if len(m)==2:
                            claims=int("".join(c for c in m[1].strip() if c.isdigit()) or 0)
                    except: pass
        ft = pdf_fn is not None
        agent = "opencode/LLM (full-text)" if ft else "opencode/LLM (metadata/abstract)"
        if not ft:
            reason = "Full text not retrieved (subscription paywall/restricted)"
        else:
            reason = "Full text (PDF) retrieved and claims audited"
        out.append({
            "journal":"Nature Human Behavior","volume":volume,"year":year,"id":num,
            "authors":r["first_author"],"title":r["title"],"severity":sev,
            "full_text_audited":ft,"claims":claims,"agent":agent,
            "outcome": {"P3":"Direct data/code link","P2":"Statement only","P1":"None"}.get(sev,sev),
            "caveat":reason+" | "+ (r.get("message","")[:120]),
        })
    return out

nhb_studies = build_nhb(read_csv(os.path.join(NHB,"VOLUME_2019_REPROAI_SUMMARY.csv")),"2019") + \
              build_nhb(read_csv(os.path.join(NHB,"VOLUME_2020_REPROAI_SUMMARY.csv")),"2020")

# ---------- MP studies ----------
def parse_mp(path, volume):
    out=[]
    for r in read_csv(path):
        verdict=(r.get("reproduction_verdict") or "")
        audited = "not audited" not in verdict.lower() and "non-empirical" not in verdict.lower()
        # severity = highest present P0..P3
        sev="n/a"
        for p in ["P3","P2","P1","P0"]:
            if int(r.get(p,0) or 0)>0: sev=p; break
        v = verdict.lower()
        lead = v.split(".")[0].strip()
        if lead.startswith("reproduces") or lead.startswith("fully"): oc="Reproduced"
        elif lead.startswith("not") or lead.startswith("cannot") or lead.startswith("can\u2019t"): oc="Not reproduced"
        elif lead.startswith("substantially") or lead.startswith("partially") or lead.startswith("partial"): oc="Partially reproduced"
        elif "reproduce" in v: oc="Reproduced"
        else: oc="Not audited"
        agent = r.get("reproduced_by","") or "none"
        if not audited: agent="n/a (not audited)"
        out.append({
            "journal":"Meta-Psychology","volume":volume,
            "year":"2019" if "2019" in volume else "2020",
            "id":r.get("id",""),"authors":r.get("first_author",""),"title":r.get("title",""),
            "severity":"n/a" if not audited else sev,
            "full_text_audited":audited,   # MP audits used full materials where audited
            "claims":int(r.get("claims_audited",0) or 0),
            "agent":agent,"outcome":oc,
            "caveat":r.get("key_caveat",""),
            "open_data":r.get("open_data",""),"open_materials":r.get("open_materials",""),"open_repro":r.get("open_repro",""),
        })
    return out

mp_studies = parse_mp(os.path.join(BASE,"Meta Psychology","Volume 3 (2019)","VOLUME3_REPROAI_SUMMARY.csv"),"3 (2019)") + \
             parse_mp(os.path.join(BASE,"Meta Psychology","Volume 4 (2020)","VOLUME4_REPROAI_SUMMARY.csv"),"4 (2020)")

all_studies = mp_studies + nhb_studies

print("MP:",len(mp_studies),"NHB:",len(nhb_studies),"Total:",len(all_studies))
print("MP audited:", sum(1 for s in mp_studies if s['full_text_audited']))
print("NHB fulltext:", sum(1 for s in nhb_studies if s['full_text_audited']))
print("NHB metadata-only:", sum(1 for s in nhb_studies if not s['full_text_audited']))

# Save consolidated data (for dashboard JS)
with open(os.path.join(OUT,"studies_consolidated.json"),"w",encoding="utf-8") as f:
    json.dump(all_studies,f,indent=2,ensure_ascii=False)
print("Saved consolidated json")
