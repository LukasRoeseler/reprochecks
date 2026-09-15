# Manuscript claims inventory — Balcells & Kalyvas, "Does Warfare Matter? Severity, Duration, and Outcomes of Civil Wars"

- **Audited artifact:** ICIP Working Paper 2012/5 (November 2012), text extracted to `paper_extracted.txt` (untouched).
- **Version-of-record:** Journal of Conflict Resolution 58(8):1390–1418 (2014), DOI 10.1177/0022002714547903.
- **Mode:** static audit + arithmetic internal-consistency checks. NO replication package shipped, and none located on
  Harvard Dataverse / OSF (title-exact Dataverse search returned 0 datasets). Therefore every regression coefficient,
  SE, p-value, and N for the source-level models (Tables 1–8) is marked `-` (not independently checkable, reason: data/code unavailable).
- **Legend:** ✔ = verified at reported precision (arithmetic only here) · ⚠ = discrepant (internal) · – = not independently reproducible.
- The headline model results (Tables 1,2,5,6,7,8) cannot be re-implemented; listed here for inventory but all marked `-`.

## A. Duration (Section 3; Tables 1–2)
| ID | Claim | Reported | Verdict |
|----|-------|----------|---------|
| C1 | Ended civil wars in TR dataset | 142 | – (no data) |
| C2 | Avg duration of ended wars | 80.19 months | – (no data) |
| C3 | Conventional avg duration | 39.82 months | – |
| C4 | Irregular avg duration | 113.32 months | – |
| C5 | SNC avg duration | 49 months | – |
| C6 | Fn9 Stata est. mean: total/irregular/SNC/conventional | 103 / 140 / 99 / 44 | – |
| C7 | Fn1 Cold War irregular 66.34%; post-1991 conv 47.83%, SNC 26.09%, irr 26.09% (cited K&B 2010) | as stated | – (cited background) |
| C8 | Table1 M1 Irregular coeff (SE) | 1.20*** (0.23) | – |
| C9 | Table1 M1 SNC coeff (SE) | 0.83** (0.38) | – |
| C10 | Table1 M2 Post1990 | –0.59* (0.31) | – |
| C11 | Table1 M1 Obs | 1206 | ⚠ vs 147 wars / 142 ended (panel structure undocumented); ADV-005 |
| C12 | Table1 M2–M4 Obs | 899 | – (depends on 1206 construction) |
| C13 | Table2 M1 Irregular | 0.85*** (0.16) | – |
| C14 | Table2 M1 Obs | 902 | – |
| C15 | Table2 M2–M4 Obs | 611 | – |

## B. Severity (Section 4; Tables 3–6)
| ID | Claim | Reported | Verdict |
|----|-------|----------|---------|
| C16 | Table3 Conv deaths/month (SD) | 3,038.127 (7,527.209) n=36 | – |
| C17 | Table3 Irregular deaths/month (SD) | 1,257.908 (3,737.396) n=53 | – |
| C18 | Table3 SNC deaths/month (SD) | 1,015.103 (2,446.426) n=9 | – |
| C19 | Text severity: conv/irregular/SNC | 3,038 / 1,258 / 1,015 | ✔ matches Table3 (rounded) |
| C20 | Table3 obs sum | 36+53+9 = 98 | ✔ (98, matches fn12) |
| C21 | Fn12 battledeaths min/max/mean, n | 50 / 2,097,705 / 70,328.66 / 98 cases | – (scale mixing, see ADV-004) |
| C22 | Fn12 missing: conv 14 (28.5%), irr 26 (33.3%), SNC 9 (45%) | 28.5 / 33.3 / 45 | ⚠ SNC: 9/18=50.0% not 45%; conv 28.0% not 28.5% (ADV-004) |
| C23 | Table4 Conv total deaths (SD) n | 17,334.77 (54,876.5) n=122 | – |
| C24 | Table4 Irregular total (SD) n | 5,803.97 (19,131.2) n=757 | – |
| C25 | Table4 SNC total (SD) n | 1,234.217 (2,079.076) n=23 | – |
| C26 | Text severity PRIO100: conv/irr/SNC | 17,335 / 5,804 / 1,234 | ✔ matches Table4 (rounded) |
| C27 | Table4 obs sum | 122+757+23 = 902 | ✔ (902) |
| C28 | Table6 M1 Obs | 913 | ⚠ > 902 in Table4 (ADV-003) |
| C29 | Table6 M1 Conv / SNC | 0.94*** / –0.61** | – |
| C30 | Table5 M1/M2/M3 Obs | 98 / 92 / 84 | ✔ M1=98 matches Table3 |
| C31 | Table6 direction prose: conv more lethal, SNC less lethal | – | – (sign check only in text, not data) |

## C. Outcomes (Section 5; Tables 7–8)
| ID | Claim | Reported | Verdict |
|----|-------|----------|---------|
| C32 | % irregular incumbent wins (TR) | 64% | – |
| C33 | % irregular insurgent wins (TR) | ~20% | – |
| C34 | % conventional incumbent defeat | ~30% | – |
| C35 | % SNC draws | 55.56% | – |
| C36 | Table7 M1 obs | 145 | – |
| C37 | Table7 M2/M3 obs | 133 / 99 | – |
| C38 | Table7 Pseudo R² M1/M2/M3 | 0.061 / 0.153 / 0.219 | – |
| C39 | Table7 Draw SNC vs Conv (M1) | 2.41*** vs 0.99** | – (direction consistent with prose) |
| C40 | Table8 M1 obs | 212 | – |
| C41 | Table8 M2/M3 obs | 148 / 148 | – |
| C42 | Table8 Pseudo R² M1/M2/M3 | 0.047 / 0.119 / 0.189 | – |

## Summary
- Total claims inventoried: **42** (C1–C42).
- Individually checkable from the paper's own arithmetic: C19, C20, C26, C27, C30 → **5**
- Internal-consistency mismatches: C11, C22, C28 → **3** (ADV-003/004/005)
- Source-level (requires replication data/code): **34** → all `-`

Note: C7 is a citation to Kalyvas & Balcells (2010); no background-survey distribution was independently recomputed.
