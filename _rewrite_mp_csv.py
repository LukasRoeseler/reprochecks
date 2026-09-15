import csv, io, sys, os
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
V3 = os.path.join(BASE, "Meta Psychology", "Volume 3 (2019)", "VOLUME3_REPROAI_SUMMARY.csv")
V4 = os.path.join(BASE, "Meta Psychology", "Volume 4 (2020)", "VOLUME4_REPROAI_SUMMARY.csv")

def load(path):
    with open(path, encoding="utf-8") as f:
        return list(csv.DictReader(f))

F = {
 "MP.2018.871": dict(v="Reproduces (near-exact). All load-bearing AUCs and the central p-value-Bayes-factor redundancy claim reproduce from the author's code (bit-identical equivalence).", P0=0,P1=0,P2=1,P3=5,ft=6,cl=44),
 "MP.2018.878": dict(v="Partially reproduces. Overall effect d~0.27 and culture subgroups recover from raw data, but the packaged analysis cannot regenerate the k=76 headline tables and the reported I2 is internally inconsistent with the paper's own Q.", P0=0,P1=2,P2=2,P3=2,ft=6,cl=41),
 "MP.2017.840": dict(v="Reproduces (exact). All load-bearing figures reproduce exactly from the shipped result and the method is independently regenerated with a fixed seed.", P0=0,P1=0,P2=1,P3=3,ft=4,cl=42),
 "MP.2018.898": dict(v="Reproduces. Primary MLM-UN liberal-bias finding reproduces in direction and magnitude in independent R and Python; exact SAS/SPSS table cells are unverifiable.", P0=0,P1=0,P2=3,P3=3,ft=6,cl=23),
 "MP.2018.895": dict(v="Reproduces (near-exact). All sensitivity/bias means, t-tests, CIs, and effect sizes across all five experiments reproduce from open data in R and Python.", P0=0,P1=0,P2=5,P3=5,ft=10,cl=65),
 "MP.2018.1481": dict(v="Reproduces (near-exact). All pre-registered P600 ANOVAs and Bayes factors reproduce exactly; two appendix Bayes factors show Monte-Carlo noise.", P0=0,P1=0,P2=2,P3=2,ft=4,cl=49),
 "MP.2018.880": dict(v="Reproduces. Raw data and SPSS syntax retrieved from OSF; essentially every primary per-study statistic and the meta-analytic g~0 reproduce in R and Python.", P0=0,P1=0,P2=3,P3=2,ft=5,cl=56),
 "MP.2019.1630": dict(v="Reproduces (near-exact). All FLP real-data values and Table 1 medians/skewness reproduce exactly; illustrative Monte-Carlo Table 2 is not byte-reproduced.", P0=0,P1=0,P2=1,P3=4,ft=5,cl=56),
 "MP.2018.884": dict(v="Reproduces. Running the author's R code reproduces Table 1 exactly (all method-vs-MA differences) and the publication-bias simulation claims.", P0=0,P1=0,P2=4,P3=2,ft=6,cl=52),
 "MP.2018.874": dict(v="Partially reproduces. Study 1 Table 1 reproduces within Monte-Carlo error for all four methods, but the shipped p-uniform function has a lower/upper-tail bug and the published code URL is dead.", P0=0,P1=1,P2=2,P3=2,ft=5,cl=17),
 "MP.2019.1992": dict(v="Reproduces. OSF R code is live and reproducible; the simulation reproduces within Monte-Carlo error (all cells) supporting the multiplicity-control thesis.", P0=0,P1=0,P2=1,P3=4,ft=5,cl=16),
 "MP.2018.933": dict(v="Fully reproduces. The full TOST/SGPV relationship reproduces in R and Python and against the author's own function; prose typo and empty OSF archiving.", P0=0,P1=0,P2=1,P3=1,ft=2,cl=24),
 "MP.2018.872": dict(v="Reproduces. Core re-analysis numbers reproduce exactly from OSF data/code in live R and independent Python; version-fragile duplicate script.", P0=0,P1=0,P2=1,P3=1,ft=2,cl=24),
 "MP.2019.2266": dict(v="Reproduces. Excess-success replication probability (~0.014) reproduces from the author's R code and independent Python; provenance/hygiene findings.", P0=0,P1=0,P2=2,P3=1,ft=3,cl=29),
}

def write(path, rows):
    cols=list(rows[0].keys())
    with open(path,"w",encoding="utf-8",newline="") as f:
        w=csv.DictWriter(f,fieldnames=cols); w.writeheader(); w.writerows(rows)

# V3
rows3=load(V3)
for r in rows3:
    if r["id"] in F:
        u=F[r["id"]]
        for k in ["P0","P1","P2","P3"]: r[k]=str(u[k])
        r["findings_total"]=str(u["ft"]); r["claims_audited"]=str(u["cl"])
        r["reproduction_verdict"]=u["v"]
write(V3,rows3)
print("V3 updated:", [r["id"] for r in rows3 if r["id"] in F])

# V4
rows4=load(V4)
for r in rows4:
    # convert the bogus Niemeyer row (MP.2018.874, verdict contains 'Not audited') -> MP.2018.884
    if r["id"]=="MP.2018.874" and "not audited" in r["reproduction_verdict"].lower():
        r["id"]="MP.2018.884"; r["first_author"]="Niemeyer et al."
        r["title"]="Publication Bias in Meta-Analyses of Posttraumatic Stress Disorder Interventions"
    if r["id"] in F:
        u=F[r["id"]]
        for k in ["P0","P1","P2","P3"]: r[k]=str(u[k])
        r["findings_total"]=str(u["ft"]); r["claims_audited"]=str(u["cl"])
        r["reproduction_verdict"]=u["v"]
write(V4,rows4)
print("V4 ids:", [r["id"] for r in rows4])
