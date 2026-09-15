# Claim inventory — "The Arrival of Fast Internet and Employment in Africa"
**Hjort & Poulsen, American Economic Review 2019, 109(3): 1032–1079, DOI 10.1257/aer.20161385**
Audit engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT. Rules 2026.06.27. Audit date 2026-09-14.

Legend: ✅ internally consistent / confirmed · ≈ close, base/rounding-sensitive · ⚠ discrepant · ➖ not independently re-derivable this session (reason given).

Every numbered claim C1–C41 below is re-derived in the R script `01_internal_consistency.R` and independently cross-checked in Python `01b_python_crosscheck.py` (full agreement between the two languages). Coefficients/SEs/N reported in the tables are transcribed from the manuscript; because the raw microdata could not be downloaded in this session (see §0), table coefficients themselves carry verdict ➖ for *recomputation-from-data*, while their *arithmetic self-consistency* is ✅.

## §0 Access / provenance (why Coefficients are ➖ for re-derivation)
- The manuscript states (p. 1032, fn †): “Go to https://doi.org/10.1257/aer.20161385 to visit the article page for additional materials…”. The AEA article page links to the replication package, which **exists and is complete** at openICPSR **DOI 10.3886/E113156V1** (AEA Data & Code Repository), deposited 2019-10-12, V1.
- Package contents (verified via directory listing): `data/` (13 Stata `.dta` — afrobarometer, afrobarometer_close2landing, afrobarometer_roads_electricity, afrobarometertii, akamai, itu, light [104 MB], lmmis, qlfs [153 MB], qlfs_close2landing, + DHS inputs on page 2), `syntax/` (19 files incl. t1–t4.do, f4/f5/f7.do, fa1.do, ols_spatial_HAC.ado, reg2hdfespatial.ado, …), `gis/`, `LICENSE.txt`.
- **This session could not download the binary data.** `www.openicpsr.org`, `www.icpsr.umich.edu`, and `pcms.icpsr.umich.edu` return a Cloudflare “managed challenge” 403 to this shell’s egress (PowerShell, curl, and the webfetch tool all observed it on download endpoints), and the openICPSR file-download flow requires a signed-in browser. No public mirror was found (GitHub search: 0 results). Stata itself is also not installed on this host (only R 4.6.1 and Python 3.8). Therefore live retabulation of every regression coefficient is ➖ this session, with the concrete re-run recipe preserved in `advisory_plan.json`.
- The internal-consistency claims below need only the published summary values and are ✅/≈.

## A. Headline employment-rate results (Table 3 / abstract / IV-B)
| ID | Quantity | Manuscript | Re-derived | Verdict |
|----|----------|-----------|-----------|---------|
| C1 | DHS effect (pp), N, mean | 0.046 (0.014), N=59,914, mean 0.68 | — (needs qlfs/dhs microdata) | ➖ coefficients; ✅ arithmetic (mean 0.68 matches Table 1) |
| C2 | Afrobarometer effect (pp), N, mean | 0.077 (0.037), N=7,918, mean 0.58 | — | ➖ coefficients; ✅ mean 0.58 matches Table 1 |
| C3 | SA-QLFS effect (pp), N, mean | 0.022 (0.008), N=280,641, mean 0.72 | — | ➖ coefficients; ✅ mean 0.72 matches Table 1 |
| C4 | Abstract % conversion, DHS | 4.6 pp → “6.9%” | 0.046/0.68 = 6.76% (pooled base); 0.046/0.67 = 6.87% (connected base 0.67 from Table 1) | ≈ (P3 ADV-002: base is connected 0.67, not the Table 3 mean 0.68) |
| C5 | Abstract % conversion, Afrobarometer | 7.7 pp → “13.2%” | 0.077/0.58 = 13.28% | ✅ |
| C6 | Abstract % conversion, SA-QLFS | 2.2 pp → “3.1%” | 0.022/0.72 = 3.06% | ✅ |
| C7 | IV-B “wants to work more” | prose: reduces by 2.2% | Table 3 Panel B col 2 = **−0.022** (0.008) — sign confirmed from PDF (pdfminer_full.txt) | ✅ (minus was dropped in paper_extracted.txt extraction; PDF confirms −0.022; prose “percent” for a pp change is loose, see ADV-003) |

## B. Table 1 — baseline raw differences (connected − unconnected) & t sign
| ID | Row | Connected | Unconnected | Reported diff | Re-derived | t | Verdict |
|----|-----|-----------|-------------|---------------|-----------|----|---------|
| C8 | Speed (kbps) | 453.64 | 423.47 | 30.17 | 30.17 | 0.27 | ✅ |
| C9 | Daily Internet use | 0.08 | 0.11 | −0.03 | −0.03 | −2.42 | ✅ |
| C10 | Weekly Internet use | 0.16 | 0.21 | −0.05 | −0.05 | −2.61 | ✅ |
| C11 | DHS employment | 0.67 | 0.68 | −0.01 | −0.01 | −1.46 | ✅ |
| C12 | DHS skilled | 0.57 | 0.58 | −0.01 | −0.01 | −1.05 | ✅ |
| C13 | Afrobarometer employment | 0.56 | 0.59 | −0.03 | −0.03 | −1.57 | ✅ |
| C14 | SA employment | 0.77 | 0.71 | 0.06 | 0.06 | 7.99 | ✅ |
| C15 | SA skilled | 0.55 | 0.49 | 0.07 | 0.06 (0.55−0.49=0.06; 0.07 consistent with un-rounded means) | 8.13 | ✅ (rounding) |
| C16 | Hours worked | 45.26 | 45.38 | −0.11 | −0.12 (rounding) | −0.41 | ✅ |
| C17 | Wants to work more | 0.62 | 0.66 | −0.04 | −0.04 | −5.82 | ✅ |
| C18 | Formal employment | 0.54 | 0.47 | 0.07 | 0.07 | 7.83 | ✅ |
| C19 | Informal employment | 0.12 | 0.12 | 0.00 | 0.00 (t≈−0.67 reflects sub-display-precision value) | −0.67 | ✅ |
| C20 | Ethiopia employees | 73.90 | 80.83 | −6.93 | −6.93 | −0.35 | ✅ |
| C21 | Ethiopia skilled positions | 24.30 | 23.85 | 0.45 | 0.45 | 0.05 | ✅ |
| C22 | Net firm entry/quarter | 3.46 | 3.31 | 0.15 | 0.15 | 1.58 | ✅ |
| C23 | Night-light density | 3.62 | 1.41 | 2.21 | 2.21 | 8.89 | ✅ |

All 16 t-statistics carry the same sign as their baseline difference (directionally consistent); exact |t| re-derivation from raw data is ➖ this session.

## C. Prose “%” claims derived from asinh/log coefficients
| ID | Claim (prose) | Coefficient | Re-derived % | Verdict |
|----|---------------|-------------|--------------|---------|
| C24 | Speed +35% (full sample) | 0.354 (Table 2 c1) | 35.4% | ✅ |
| C25 | Speed +36% (ex big cities) | 0.362 (c2) | 36.2% | ✅ |
| C26 | Speed +38% (+conn×time FE) | 0.380 (c3) | 38.0% | ✅ |
| C27 | Daily use +8% | 0.082 (c4) | 8.2% | ✅ |
| C28 | Daily use +12% | 0.124 (c5) | 12.4% | ✅ |
| C29 | Weekly use +12% | 0.123 (c6) | 12.3% | ✅ |
| C30 | Weekly use +14% | 0.142 (c7) | 14.2% | ✅ |
| C31 | SA hours worked ~10% | 0.101 (T3 PB c1) | 10.1% | ✅ |
| C32 | SA net firm entry ~23% | 0.227 (T7 A) | 22.7% | ✅ |
| C33 | Ethiopia total employment ~16% | 0.156 (T8 c1) | 15.6% | ✅ |
| C34 | Ethiopia total employment ~22% | 0.224 (T8 c2) | 22.4% | ✅ |
| C35 | Ethiopia firm productivity ~13% | 0.127 (T8 bottom) | 12.7% | ✅ |
| C36 | Incomes +2.4% | 0.024 (T9 c1) | 2.4% | ✅ |
| C37 | Incomes +3.3% | 0.033 (T9 c2) | 3.3% | ✅ |

## D. Sample N / mean-of-outcome consistency across tables
| ID | Item | Sources | Verdict |
|----|------|---------|---------|
| C38 | DHS employment N | 59,914 in T3, T4, T6, Table A1 | ✅ |
| C39 | Afrobarometer N | 7,918 (T3/A1); 7,900 (T4/A2); 7,902 (T6) — differing restrictions, not contradiction | ✅ |
| C40 | SA-QLFS employment N | 280,641 (T3/T4); 277,737 (T6, education-matched) | ✅ |
| C41 | Means-of-outcome ↔ Table 1 “all” column | DHS 0.68=0.68; Afro 0.58=0.58; SA 0.72=0.72; SA skilled 0.50=0.50; DHS skilled 0.58=0.58 | ✅ |

## E. Directional / qualitative claims (no separate numerics) — read, not re-derived
- Skilled employment ↑ (DHS 0.044, SA 0.014; Table 5) — coefficient sign/direction matches prose “increases … 4.4 and 1.4 percent”; unskilled statistically unaffected. ✅ directional.
- Canada-style positional skill bias; job inequality falls/unchanged by education (Table 6) — directional claims consistent with reported coefficients (DHS tertiary skilled largest 0.119); exact SEs ➖ this session.
- Firm entry mainly in ICT-intensive sectors (finance 0.158, services 0.120, Table 7) — consistent.
- WBES firm results (export/training/online communication, ~14–17% employment) are presented only in the online appendix and are ➖ from this main-text extract.

**Totals:** 41 numerical/internal-consistency claims enumerated (C1–C41); 40 ✅, 1 ≈ (C4, P3 ADV-002), 0 ⚠. Table coefficients/SEs/p-values that require raw microdata are ➖ with the public download path + Stata recipe preserved (see §0, advisory_plan.json) — this is an access/environment limitation of this audit session, not a demonstrated package defect.
