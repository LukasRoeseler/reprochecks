import csv
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

ROOT = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)"

# (dir, id, first_author, title, doi, open_data, open_materials, open_repro, reproduced_by,
#  p0, p1, p2, p3, claims, verdict, key_caveat)
rows = [
    ("01_Witt_SignalDetection", "MP.2018.871", "Witt",
     "Insights into Criteria for Statistical Significance from Signal Detection Analysis",
     "10.15626/MP.2018.871", "N/A", "Yes", "Yes", "Jack Davis",
     0, 0, 1, 4, 5,
     "Reproduces (near-exact). All AUCs and the AUC_p==AUC_BF equivalence reproduce to precision; strongest reproduction in the volume.",
     "Shipped optional-stopping script simulates 40 studies, not the 20 described."),
    ("02_KuperBott_MoralLicensing", "MP.2018.878", "Kuper & Bott",
     "Moral Licensing: A Replication Study (meta-analytic update)",
     "10.17605/MP.2018.878", "Yes", "Yes", "Yes", "Rickard Carlsson",
     0, 2, 2, 2, 6,
     "Partially reproduces. Main effect d~.27 and culture subgroups reproduce; headline k=76 not reproducible from archive; I2=.26 internally inconsistent.",
     "Headline sample size (k=76) and I2 do not reproduce from the archived meta-analytic data."),
    ("04_Brand_PosteriorPassing", "MP.2017.840", "Brand",
     "Bayesian Generalized Linear Mixed Models: Posterior Passing for False-Positive Control",
     "10.15626/MP.2017.840", "Yes", "Yes", "Yes", "Jack Davis",
     0, 0, 1, 3, 4,
     "Reproduces (near-exact). False-positive rates per method reproduce exactly from the shipped meta_results file; PP vs meta-BGLMM correlation near-identical.",
     "False-positive claim verified against shipped result file, not re-simulated from scratch (seed-sensitive MCMC)."),
    ("05_Haverkamp_TypeIerror", "MP.2018.898", "Haverkamp",
     "Type I Error Rates in Repeated-Measures ANOVA and Mixed-Model ANOVA: A Simulation Study",
     "10.15626/MP.2018.898", "N/A", "Yes", "Yes", "Jack Davis",
     0, 2, 2, 2, 6,
     "Partially reproduces. rANOVA / rANOVA-HF reproduce; MLM-UN headline (35% vs ~5%) NOT reproduced; prose-vs-table inconsistency (m=12 holds).",
     "MLM-UN Type I error claim not reproducible (R gives 35% vs prose ~5%); full S=5000 infeasible."),
    ("07_Witt_GraphConstruction", "MP.2018.895", "Witt",
     "Graph Construction: An Empirical Investigation on Setting the Range of the Y-Axis",
     "10.5626/MP.2018.895", "Yes", "Yes", "Yes", "Tobias Muehlmeister",
     0, 0, 2, 4, 58,
     "Reproduces (near-exact). All sensitivity/bias means, t-tests, CIs, and BFs across 5 experiments reproduce in R and Python.",
     "Author analysis script not runnable as distributed (hard-coded local path); '57 participants' count inconsistent."),
    ("09_deLeeuw_ERP", "MP.2018.1481", "de Leeuw et al.",
     "Similar event-related potentials to music and language: A replication of Patel et al. (1998)",
     "10.15626/MP.2018.1481", "Yes", "Yes", "Yes", "Martina Sladekova",
     0, 0, 1, 3, 49,
     "Reproduces (near-exact). All ANOVAs (Tables 2-3), Bayes factors (Table 4), behavioral table, and appendix RATN ANOVA reproduce exactly.",
     "Two appendix RATN Bayes-factor magnitudes ~3%/1.5% low (Monte-Carlo noise in BayesFactor)."),
    ("10_Imhoff_FileDrawer", "MP.2018.880", "Imhoff & Messer",
     "The File-Drawer Report: A Pre-registered Study of the Reproducibility of Psychological Science",
     "10.15626/MP.2018.880", "Yes", "Yes", "Yes", "Tobias Muehlmeister",
     0, 1, 2, 3, 56,
     "Partially reproduces. Core file-drawer logic reproduces; open-data / open-reproducible-analysis badges not substantiated on OSF (0 files in data component).",
     "Open data / open reproducible analysis claim not substantiated (OSF data component empty)."),
]

headers = ["folder", "id", "first_author", "title", "doi",
           "open_data", "open_materials", "open_repro", "reproduced_by",
           "P0", "P1", "P2", "P3", "findings_total", "claims_audited",
           "reproduction_verdict", "key_caveat"]

def build_row(r):
    folder, did, fa, title, doi, od, om, orr, rb, p0, p1, p2, p3, claims, verdict, caveat = r
    return [folder, did, fa, title, doi, od, om, orr, rb, p0, p1, p2, p3, p0+p1+p2+p3, claims, verdict, caveat]

data = [build_row(r) for r in rows]

# ---- CSV ----
csv_path = ROOT + r"\VOLUME3_REPROAI_SUMMARY.csv"
with open(csv_path, "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(headers)
    w.writerows(data)
print("Wrote CSV:", csv_path)

# ---- XLSX ----
wb = openpyxl.Workbook()
ws = wb.active
ws.title = "Volume 3 Summary"
hdr_fill = PatternFill("solid", fgColor="00769C")
hdr_font = Font(color="FFFFFF", bold=True)
ws.append(headers)
for c in ws[1]:
    c.fill = hdr_fill
    c.font = hdr_font
    c.alignment = Alignment(vertical="top", wrap_text=True)

for r in data:
    ws.append(r)

# styling
for row in ws.iter_rows(min_row=2):
    for c in row:
        c.alignment = Alignment(vertical="top", wrap_text=True)
    # findings total col (index 14 -> N) bold
    row[13].font = Font(bold=True)
    # severity coloring on P1 col (K)
    p1 = row[10].value
    if p1 and p1 > 0:
        row[10].fill = PatternFill("solid", fgColor="FDEBD0")
    p0 = row[9].value
    if p0 and p0 > 0:
        row[9].fill = PatternFill("solid", fgColor="FADBD8")

widths = [26, 14, 14, 52, 22, 10, 12, 12, 18, 6, 6, 6, 6, 10, 10, 52, 52]
for i, wd in enumerate(widths, start=1):
    ws.column_dimensions[get_column_letter(i)].width = wd
ws.freeze_panes = "A2"

# Totals row
total_row = ["TOTAL", "", "", "", "", "", "", "", "",
             sum(r[9] for r in data), sum(r[10] for r in data), sum(r[11] for r in data),
             sum(r[12] for r in data), sum(r[13] for r in data), sum(r[14] for r in data),
             "7 empirical papers audited", ""]
ws.append(total_row)
for c in ws[ws.max_row]:
    c.font = Font(bold=True)
    c.fill = PatternFill("solid", fgColor="E3E8ED")

xlsx_path = ROOT + r"\VOLUME3_REPROAI_SUMMARY.xlsx"
wb.save(xlsx_path)
print("Wrote XLSX:", xlsx_path)
