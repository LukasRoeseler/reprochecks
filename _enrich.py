import os, csv, json
from urllib.parse import quote

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
NHB = os.path.join(BASE, "Nature Human Behavior")
MP = os.path.join(BASE, "Meta Psychology")

studies = json.load(open(os.path.join(OUT, "studies_consolidated.json"), encoding="utf-8"))

# NHB doi map num->doi
nhb_doi = {}
with open(os.path.join(NHB, "ARTICLE_INVENTORY.csv"), encoding="utf-8") as f:
    for r in csv.DictReader(f):
        if r.get("num") and r.get("doi"):
            nhb_doi[r["num"]] = r["doi"]

def find_report(folder):
    """find a REPROAI_REPORT.html under a paper directory"""
    if not folder: return None
    hits=[]
    for root, dirs, files in os.walk(folder):
        if "REPROAI_REPORT.html" in files:
            hits.append(os.path.join(root,"REPROAI_REPORT.html"))
            if len(hits)>=3: break
    # prefer the deepest (most specific ReproAI project folder)
    if hits:
        hits.sort(key=len, reverse=True)
        return hits[0]
    return None

def rel_to_out(path):
    """relative path from OUT dir to path, url-encoded for file:// and webserver"""
    rel = os.path.relpath(path, OUT)
    return quote(rel.replace("\\","/"))

tech_kw = ["code unavailable","broken placeholder","404","url dead","not runnable","infeasible",
           "could not be run","does not run","hard-coded","hardcoded","cannot be run","n/a","placeholder",
           "payment","paywall"]

MP_REPORT = {
 "MP.2018.871": (MP,"Volume 3 (2019)","01_Witt_SignalDetection","Witt_SignalDetection_871"),
 "MP.2018.878": (MP,"Volume 3 (2019)","02_KuperBott_MoralLicensing","KuperBott_MoralLicensing_878"),
 "MP.2017.840": (MP,"Volume 3 (2019)","04_Brand_PosteriorPassing","Brand_PosteriorPassing_840"),
 "MP.2018.898": (MP,"Volume 3 (2019)","05_Haverkamp_TypeIerror","Haverkamp_TypeIerror_898"),
 "MP.2018.895": (MP,"Volume 3 (2019)","07_Witt_GraphConstruction","Witt_GraphConstruction_895"),
 "MP.2018.1481": (MP,"Volume 3 (2019)","09_deLeeuw_ERP","deLeeuw_ERP_1481"),
 "MP.2018.880": (MP,"Volume 3 (2019)","10_Imhoff_FileDrawer","Imhoff_FileDrawer_880"),
 "MP.2018.884": (MP,"Volume 4 (2020)","01_Niemeyer_PtsdPublicationBias","Niemeyer_PtsdPublicationBias_884"),
 "MP.2019.1630": (MP,"Volume 4 (2020)","02_Rousselet_SkewedDistributions","Rousselet_SkewedDistributions_1630"),
 "MP.2018.874": (MP,"Volume 4 (2020)","03_Brunner_PowerHeterogeneity","Brunner_PowerHeterogeneity_874"),
 "MP.2019.1992": (MP,"Volume 4 (2020)","04_Hunter_MultiplicityControl","Hunter_MultiplicityControl_1992"),
 "MP.2018.933": (MP,"Volume 4 (2020)","05_Lakens_EquivalenceTesting","Lakens_EquivalenceTesting_933"),
 "MP.2018.872": (MP,"Volume 4 (2020)","10_WilliamsBuerkner_HofmannCritique","WilliamsBuerkner_HofmannCritique_872"),
 "MP.2019.2266": (MP,"Volume 4 (2020)","11_FrancisThunell_CalorieExcessSuccess","FrancisThunell_CalorieExcess_2266"),
}

def _mp_report_folder(t):
    base, vol, paper, sub = t
    cand = os.path.join(base, vol, paper, "ReproAI", sub)
    return cand if os.path.isdir(cand) else None

MP_REPORT = {k: _mp_report_folder(v) for k, v in MP_REPORT.items()}

def traffic(status_journal, outcome, ft, severity, caveat):
    c = (caveat or "").lower()
    if status_journal == "MP":
        if outcome == "Reproduced": return "reproduced"
        if outcome == "Partially reproduced": return "partial"
        if outcome == "Not reproduced":
            if any(k in c for k in ["code unavailable","broken placeholder","404","url dead","placeholder","infeasible","hard-coded","hardcoded","cannot be run"]):
                return "technical"
            return "not_reproduced"
        if outcome == "Not audited": return "not_checked"
        return "not_checked"
    else:  # NHB
        if not ft: return "not_checked"      # not verified against full text (paywalled)
        if severity == "P3": return "reproduced"   # direct machine-downloadable link
        if severity == "P2": return "partial"      # statement only
        if severity == "P1": return "not_reproduced" # no availability
        return "not_checked"

def locate_paper_folder(journal, volume, id):
    base = NHB if journal=="Nature Human Behavior" else MP
    if journal=="Nature Human Behavior":
        year = id[:4]
        vol = os.path.join(base, f"Volume {year} ({year})")
        if os.path.isdir(vol):
            for d in os.listdir(vol):
                if d.startswith(id+"_"):
                    return os.path.join(vol,d)
    else:
        # volume like "3 (2019)" -> folder "Volume 3 (2019)"
        volname = "Volume "+volume
        vol = os.path.join(base, volname)
        if os.path.isdir(vol):
            for d in os.listdir(vol):
                if d.startswith("2020" if "2020" in id else "2019") or True:
                    pass
            # match by id substring or folder prefix
            for d in os.listdir(vol):
                # folder format NN_Author; id is MP.YYYY.NNNN
                # find ReproAI subfolder that has a report
                cand = os.path.join(vol,d)
                if find_report(cand):
                    # check if this is our study by scanning for id in files
                    if id_mentions(cand, id):
                        return cand
    return None

def id_mentions(folder, sid):
    # crude: look for the study id string inside report/manuscript files
    sid_short = sid.split(".")[-1] if "." in sid else sid
    for root, dirs, files in os.walk(folder):
        for fn in files:
            if fn.lower().endswith((".json",".md",".html")):
                try:
                    with open(os.path.join(root,fn), encoding="utf-8", errors="ignore") as f:
                        head = f.read(4000)
                    if sid in head or sid_short in head:
                        return True
                except: pass
    return False

for s in studies:
    journal = s["journal"]
    if journal == "Nature Human Behavior":
        s["doi"] = nhb_doi.get(s["id"], "")
        folder = None
        vol = os.path.join(NHB, f"Volume {s['year']} ({s['year']})")
        if os.path.isdir(vol):
            for d in os.listdir(vol):
                if d.startswith(s["id"]+"_"):
                    folder = os.path.join(vol,d); break
    else:
        # doi from summary stored in consolidated? we didn't store; reconstruct from id
        # MP ids like MP.2018.871
        s["doi"] = "10.15626/"+s["id"].replace("MP.","MP.") if s["id"] else ""
        folder = MP_REPORT.get(s["id"])
    rep = find_report(folder) if folder else None
    s["report"] = rel_to_out(rep) if rep else ""
    jcode = "MP" if journal == "Meta-Psychology" else "NHB"
    s["status"] = traffic(jcode, s.get("outcome",""), s.get("full_text_audited",False),
                          s.get("severity",""), s.get("caveat",""))

# report do not want to mutate original consolidated; write enriched
with open(os.path.join(OUT, "studies_dashboard.json"), "w", encoding="utf-8") as f:
    json.dump(studies, f, indent=2, ensure_ascii=False)

# summary
from collections import Counter
cnt = Counter(s["status"] for s in studies)
print("status counts:", dict(cnt))
norep = [s["id"] for s in studies if not s["report"]]
print("studies with NO report path:", len(norep), norep[:10])
nodoi = [s["id"] for s in studies if not s["doi"]]
print("studies with NO doi:", len(nodoi), nodoi[:10])
