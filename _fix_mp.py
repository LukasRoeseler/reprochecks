import os, json, io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
CON = os.path.join(BASE, "Meta Psych vs NHB", "studies_consolidated.json")

data = json.load(open(CON, encoding="utf-8"))

# keyed by id -> new fields (None = leave as is)
fix = {
 "MP.2018.871": {"outcome":"Reproduced","severity":"P2","claims":44,
   "caveat":"Near-exact/bit-identical reproduction: every load-bearing AUC and the central p-vs-BF redundancy claim reproduce from the author's code (P2=1, P3=5)."},
 "MP.2018.878": {"outcome":"Partially reproduced","severity":"P1","claims":41,
   "caveat":"Headline k=76 tables not regenerable from shipped code (definitive dataset/aggregation code never archived; P1); reported I2=.26 inconsistent with own Q(75)=175.77 (57%); overall effect d~0.27 recovers from raw data."},
 "MP.2017.840": {"outcome":"Reproduced","severity":"P2","claims":42,
   "caveat":"Clean reproduction: all load-bearing figures reproduce exactly and method independently confirmed; exact MCMC draws not regenerable without recorded seed (P2=1, P3=3)."},
 "MP.2018.898": {"outcome":"Reproduced","severity":"P2","claims":23,
   "caveat":"Primary MLM-UN liberal-bias finding reproduces in direction and magnitude in independent R and Python; exact SAS/SPSS table cells unverifiable (P2=3, P3=3)."},
 "MP.2018.895": {"outcome":"Reproduced","severity":"P2","claims":65,
   "caveat":"Near-exact: every primary statistic in all five experiments reproduces from open data; ten secondary/transparency findings (P2=5, P3=5)."},
 "MP.2018.1481": {"outcome":"Reproduced","severity":"P2","claims":49,
   "caveat":"Pre-registered P600 ANOVAs/BFs reproduce exactly; Monte-Carlo noise in two appendix Bayes factors + minor sample-consistency defect (P2=2, P3=2)."},
 "MP.2018.880": {"outcome":"Reproduced","severity":"P2","claims":56,
   "caveat":"Open-data claim substantiated (raw data + SPSS syntax on OSF); essentially every primary statistic reproduces; meta-analytic g~0 reproduces (P2=3, P3=2)."},
 "MP.2018.884": {"outcome":"Reproduced","severity":"P2","claims":52,
   "caveat":"Table 1 and all method-vs-MA differences re-run exactly; open data/code live and functional (P2=4, P3=2)."},
 "MP.2019.1630": {"outcome":"Reproduced","severity":"P2","claims":56,
   "caveat":"Exceptionally reproducible: all FLP real-data values and Table 1 reproduce exactly; illustrative M-C Table 2 not byte-reproduced (P2=1, P3=4)."},
 "MP.2018.874": {"outcome":"Partially reproduced","severity":"P1","claims":17,
   "caveat":"Study 1 Table 1 reproduces within Monte-Carlo error for all four methods, but shipped p-uniform function has a lower/upper-tail bug and the published code URL is dead (P1=1, P2=2, P3=2)."},
 "MP.2019.1992": {"outcome":"Reproduced","severity":"P2","claims":16,
   "caveat":"Refutes prior 'technical failure': OSF R code live and reproducible; 336/336 rate-cells within Monte-Carlo error (P2=1, P3=4)."},
 "MP.2018.933": {"outcome":"Reproduced","severity":"P2","claims":24,
   "caveat":"Fully reproduces: full TOST/SGPV relationship reproduces in R and Python against the author's own function; prose typo + empty OSF archiving (P2=1, P3=1)."},
 "MP.2018.872": {"outcome":"Reproduced","severity":"P2","claims":24,
   "caveat":"Core critique re-analysis reproduces exactly from OSF data/code in live R and independent Python; version-fragile duplicate script (P2=1, P3=1)."},
 "MP.2019.2266": {"outcome":"Reproduced","severity":"P2","claims":29,
   "caveat":"Excess-success result (replication probability 0.014) fully reproduces from author R code and independent Python; provenance/hygiene findings (P2=2, P3=1)."},
}

notaudited = ["MP.2019.1994","MP.2019.1995","MP.2019.1996","MP.2019.1997"]

# Handle the bogus record: MP.2018.874 labelled Niemeyer/Sample-Size -> become the real Niemeyer PTSD (MP.2018.884)
for s in data:
    if s.get("journal")=="Meta-Psychology" and s.get("id")=="MP.2018.874" and s.get("authors")=="Niemeyer":
        s["id"]="MP.2018.884"
        s["authors"]="Niemeyer et al."
        s["title"]="Publication Bias in Meta-Analyses of Posttraumatic Stress Disorder Interventions"
        s["year"]="2020"; s["volume"]="4 (2020)"
        s.update({"full_text_audited":True,"claims":51,"agent":"DeepSeek V4 Flash (uniGPT)"
                  ,"open_data":"No","open_materials":"Yes","open_repro":"Yes"})
        s.update(fix["MP.2018.884"])

for s in data:
    if s.get("journal")!="Meta-Psychology":
        continue
    sid = s.get("id")
    s["agent"] = "DeepSeek V4 Flash (uniGPT)"
    if sid in fix:
        s.update(fix[sid])
    if sid in notaudited:
        s["outcome"]="Not audited"
        s["severity"]="n/a"
        s["full_text_audited"]=False
        s["claims"]=0
        s["caveat"]="Not computationally reproduction-audited within the corpus (non-empirical or not audited)."

json.dump(data, open(CON,"w",encoding="utf-8"), ensure_ascii=False, indent=2)

from collections import Counter
mp=[s for s in data if s["journal"]=="Meta-Psychology"]
aud=[s for s in mp if s["full_text_audited"]]
print("MP total:", len(mp), "audited:", len(aud))
print("audited outcomes:", Counter(s["outcome"] for s in aud))
print("ids:", sorted(s["id"] for s in aud))
