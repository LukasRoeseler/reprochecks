import os, csv, re, io, base64
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
os.makedirs(OUT, exist_ok=True)

MP3 = os.path.join(BASE, "Meta Psychology", "Volume 3 (2019)", "VOLUME3_REPROAI_SUMMARY.csv")
MP4 = os.path.join(BASE, "Meta Psychology", "Volume 4 (2020)", "VOLUME4_REPROAI_SUMMARY.csv")
NHB19 = os.path.join(BASE, "Nature Human Behavior", "VOLUME_2019_REPROAI_SUMMARY.csv")
NHB20 = os.path.join(BASE, "Nature Human Behavior", "VOLUME_2020_REPROAI_SUMMARY.csv")

def read_csv(path):
    if not os.path.exists(path):
        return []
    with open(path, encoding="utf-8") as f:
        return list(csv.DictReader(f))

def classify_verdict(v):
    v = (v or "").lower()
    if not v:
        return "not_audited"
    if "not audited" in v:
        return "not_audited"
    if "reproduce" in v and ("near-exact" in v or "exact" in v):
        return "success"
    if v.startswith("fully reproduces") or v.startswith("reproduces"):
        return "success"
    if "not reproducible" in v or "not reproduce" in v:
        return "failed"
    if "partially reprodu" in v or "substantially reprodu" in v:
        return "partial"
    if "reproduce" in v:
        return "success"
    return "not_audited"

def parse_mp(path, volume):
    rows = read_csv(path)
    studies = []
    for r in rows:
        # skip not audited rows that have no title/doi
        verdict = (r.get("reproduction_verdict") or "")
        audited = "not audited" not in verdict.lower() and "non-empirical" not in verdict.lower()
        studies.append({
            "journal": "Meta-Psychology",
            "volume": volume,
            "folder": r.get("folder", ""),
            "id": r.get("id", ""),
            "authors": r.get("first_author", ""),
            "title": r.get("title", ""),
            "doi": r.get("doi", ""),
            "open_data": r.get("open_data", ""),
            "open_materials": r.get("open_materials", ""),
            "open_repro": r.get("open_repro", ""),
            "reproduced_by": r.get("reproduced_by", ""),
            "severity": "P"+str(int(r.get("P0",0) or 0)+int(r.get("P1",0) or 0)+int(r.get("P2",0) or 0)+int(r.get("P3",0) or 0)) if False else None,
            "findings_total": int(r.get("findings_total",0) or 0),
            "claims_audited": int(r.get("claims_audited",0) or 0),
            "verdict": r.get("reproduction_verdict", ""),
            "verdict_class": classify_verdict(verdict) if audited else "not_audited",
            "caveat": r.get("key_caveat", ""),
            "audited": audited,
        })
    return studies

# Detect full-text availability for NHB papers
def nhb_fulltext(num):
    for vol in [f"Volume {num[:4]} ({num[:4]})"]:
        vd = os.path.join(BASE, "Nature Human Behavior", vol)
        if not os.path.exists(vd):
            continue
        for d in os.listdir(vd):
            if d.startswith(num + "_"):
                for fn in ["paper.pdf", "fulltext.pdf"]:
                    p = os.path.join(vd, d, fn)
                    if os.path.exists(p):
                        try:
                            with open(p, "rb") as f:
                                if f.read(5) == b"%PDF-":
                                    return True
                        except:
                            pass
    return False

def parse_nhb(path, volume):
    rows = read_csv(path)
    studies = []
    for r in rows:
        sev = r.get("severity", "").upper()
        status = r.get("status", "")
        num = r.get("num", "")
        ft = nhb_fulltext(num)
        model = "opencode/LLM (full-text audit)" if ft else "opencode/LLM (availability audit)"
        studies.append({
            "journal": "Nature Human Behavior",
            "volume": volume,
            "folder": num,
            "id": num,
            "authors": r.get("first_author", ""),
            "title": r.get("title", ""),
            "doi": "10.1038/"+num.replace("20","",1) if False else "",
            "open_data": "Yes" if sev == "P3" else ("Statement" if sev == "P2" else "No"),
            "open_materials": "Yes" if sev == "P3" else ("Statement" if sev == "P2" else "No"),
            "open_repro": sev,
            "reproduced_by": model,
            "severity": sev,
            "findings_total": 1,
            "claims_audited": 0,
            "verdict": r.get("message", ""),
            "verdict_class": "not_audited",  # NHB = availability audit, not computational reproduction
            "caveat": "Full text retrieved & claims audited" if ft else "Availability assessed from metadata/abstract",
            "audited": True,
            "fulltext": ft,
        })
    return studies

mp19 = parse_mp(MP3, "3 (2019)")
mp20 = parse_mp(MP4, "4 (2020)")
nhb19 = parse_nhb(NHB19, "2019")
nhb20 = parse_nhb(NHB20, "2020")

all_mp = mp19 + mp20
all_nhb = nhb19 + nhb20

print("MP audited 19:", sum(1 for s in mp19 if s['audited']), "/", len(mp19))
print("MP audited 20:", sum(1 for s in mp20 if s['audited']), "/", len(mp20))
print("NHB 2019:", len(nhb19), " NHB 2020:", len(nhb20))
print("NHB full-text 2019:", sum(1 for s in nhb19 if s['fulltext']))
print("NHB full-text 2020:", sum(1 for s in nhb20 if s['fulltext']))

# ---------- Figures ----------
def b64fig(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode()

# Figure 1: Open data / materials / reproducible-analysis rates
def openness_rate(studies, key):
    n = len([s for s in studies if s['title']])
    if n == 0:
        return 0
    yes = sum(1 for s in studies if (s.get(key) or "").lower() in ("yes", "true"))
    return 100*yes/n

groups = ["MP 2019", "MP 2020", "NHB 2019", "NHB 2020"]
data_rates = [openness_rate(mp19,"open_data"), openness_rate(mp20,"open_data"),
              nhb_p3_19 := (100*sum(1 for s in nhb19 if s['severity']=="P3")/max(1,len(nhb19))),
              nhb_p3_20 := (100*sum(1 for s in nhb20 if s['severity']=="P3")/max(1,len(nhb20)))]
repro_rates = [openness_rate(mp19,"open_repro"), openness_rate(mp20,"open_repro"),
               nhb_p3_19, nhb_p3_20]

# For NHB, open_data = P3 (direct link). For MP open_data badge.
fig, ax = plt.subplots(figsize=(9,5))
x = np.arange(4); w=0.38
b1 = ax.bar(x-w/2, data_rates, w, label="Open data/code (direct link)", color="#2c6fbb")
b2 = ax.bar(x+w/2, repro_rates, w, label="Open/reproducible analysis", color="#8A2BE2")
ax.set_ylabel("Share of published articles (%)")
ax.set_title("Open data & reproducible-analysis availability by journal-volume")
ax.set_xticks(x); ax.set_xticklabels(groups)
for bars in (b1,b2):
    for b in bars:
        ax.annotate(f"{b.get_height():.0f}%", (b.get_x()+b.get_width()/2, b.get_height()+1.5),
                    ha="center", fontsize=9)
ax.legend(); ax.set_ylim(0,105); ax.grid(axis="y", alpha=0.3)
f1 = os.path.join(OUT, "fig1_open_availability.png"); fig.savefig(f1,dpi=150,bbox_inches="tight"); plt.close(fig)

# Figure 2: MP reproduction outcomes
cats = ["success","partial","failed","not_audited"]
labels = ["Reproduced","Partially\nreproduced","Not\nreproduced","Not\naudited"]
mp19_counts = [sum(1 for s in mp19 if s['verdict_class']==c) for c in cats]
mp20_counts = [sum(1 for s in mp20 if s['verdict_class']==c) for c in cats]
fig, ax = plt.subplots(figsize=(9,5))
x=np.arange(len(cats)); w=0.38
ax.bar(x-w/2, mp19_counts, w, label="MP Vol 3 (2019)", color="#2c6fbb")
ax.bar(x+w/2, mp20_counts, w, label="MP Vol 4 (2020)", color="#8A2BE2")
ax.set_xticks(x); ax.set_xticklabels(labels)
ax.set_ylabel("Number of studies"); ax.set_title("Meta-Psychology computational reproduction outcomes")
for i in range(len(cats)):
    ax.annotate(mp19_counts[i],(x[i]-w/2,mp19_counts[i]+0.1),ha="center",fontsize=9)
    ax.annotate(mp20_counts[i],(x[i]+w/2,mp20_counts[i]+0.1),ha="center",fontsize=9)
ax.legend(); ax.grid(axis="y",alpha=0.3)
f2 = os.path.join(OUT,"fig2_mp_outcomes.png"); fig.savefig(f2,dpi=150,bbox_inches="tight"); plt.close(fig)

# Figure 3: NHB data/code availability severity
for sev in ["P1","P2","P3"]:
    pass
nhb19_sev = [sum(1 for s in nhb19 if s['severity']=="P1"),sum(1 for s in nhb19 if s['severity']=="P2"),sum(1 for s in nhb19 if s['severity']=="P3")]
nhb20_sev = [sum(1 for s in nhb20 if s['severity']=="P1"),sum(1 for s in nhb20 if s['severity']=="P2"),sum(1 for s in nhb20 if s['severity']=="P3")]
fig, ax = plt.subplots(figsize=(9,5))
lbl_sev=["P1: No availability","P2: Statement only","P3: Direct link"]
x=np.arange(3); w=0.38
ax.bar(x-w/2, nhb19_sev, w, label="NHB Volume 2019", color="#2c6fbb")
ax.bar(x+w/2, nhb20_sev, w, label="NHB Volume 2020", color="#8A2BE2")
ax.set_xticks(x); ax.set_xticklabels(lbl_sev)
ax.set_ylabel("Number of articles"); ax.set_title("NHB data/code availability severity")
for i in range(3):
    ax.annotate(nhb19_sev[i],(x[i]-w/2,nhb19_sev[i]+1),ha="center",fontsize=9)
    ax.annotate(nhb20_sev[i],(x[i]+w/2,nhb20_sev[i]+1),ha="center",fontsize=9)
ax.legend(); ax.grid(axis="y",alpha=0.3)
f3 = os.path.join(OUT,"fig3_nhb_severity.png"); fig.savefig(f3,dpi=150,bbox_inches="tight"); plt.close(fig)

b64_1 = b64fig(plt.figure()) if False else None

# Save aggregated JSON for report
import json
with open(os.path.join(OUT,"comparison_data.json"),"w",encoding="utf-8") as f:
    json.dump({
        "figures": {"fig1":f1,"fig2":f2,"fig3":f3},
        "mp19":mp19,"mp20":mp20,"nhb19":nhb19,"nhb20":nhb20,
        "stats":{
            "mp19_total":len(mp19),"mp20_total":len(mp20),
            "mp19_audited":sum(1 for s in mp19 if s['audited']),"mp20_audited":sum(1 for s in mp20 if s['audited']),
            "nhb19_total":len(nhb19),"nhb20_total":len(nhb20),
            "nhb19_p3":sum(1 for s in nhb19 if s['severity']=="P3"),"nhb20_p3":sum(1 for s in nhb20 if s['severity']=="P3"),
            "nhb19_p2":sum(1 for s in nhb19 if s['severity']=="P2"),"nhb20_p2":sum(1 for s in nhb20 if s['severity']=="P2"),
            "nhb19_p1":sum(1 for s in nhb19 if s['severity']=="P1"),"nhb20_p1":sum(1 for s in nhb20 if s['severity']=="P1"),
            "nhb19_ft":sum(1 for s in nhb19 if s['fulltext']),"nhb20_ft":sum(1 for s in nhb20 if s['fulltext']),
        }
    }, f, indent=2, ensure_ascii=False)

print("Figures written:", f1, f2, f3)
print("Stats:", {k:v for k,v in json.load(open(os.path.join(OUT,'comparison_data.json'),encoding='utf-8'))['stats'].items()})
