# Environment & provenance note — ReproAI audit of Flesia et al. (2020) / yb2h8

Audit date: 2026-09-14 · Engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT ·
Rules version: 2026.06.27 · Mode: static audit + independent reimplementation (summary-level).

## Host environment
- OS: Windows (win32); shell: PowerShell 5.1
- R: `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` — R version 4.6.1 (2026-06-24 ucrt)
- Python: 3.8.10 (`AppData\Local\Programs\Python\Python38`), pdfminer 20231228 (PDF text
  extraction). No PyMuPDF/PyPDF2 available.
- Original analysis tools named by the authors: **JASP 0.14** (statistics; per ref. [66]) and
  **WEKA 3.9** (machine learning; per ref. [79]). Neither is installed/used here; not required
  because no author code or data were shipped.

## Provenance chain
1. Paper full text: `SCORE ReproAI Checks\01_yb2h8\paper_extracted.txt` + `paper.pdf` (provided, read-only — NOT modified).
2. DOI resolution: `10.31234/osf.io/yb2h8` -> PsyArXiv preprint `yb2h8_v1`, provider psyarxiv,
   underlying OSF node `e285f`.
3. OSF API v2 (`api.osf.io/v2/preprints/yb2h8_v1/`, `.../nodes/e285f/`, `.../nodes/e285f/files/osfstorage/`,
   `.../nodes/e285f/children/`) confirmed:
   - preprint title matches the audited paper; published DOI `10.3390/jcm9103350`.
   - node `e285f` is **public**, **0 children**, and contains **1 file**: the supplement PDF.
4. Supplement downloaded from `https://osf.io/download/x7kjw/` -> `jcm-09-03350-s001 (2).pdf`
   (202,610 bytes). Downloaded-file hashes match OSF metadata exactly:
   - MD5    `6666FCE72E59C0F3831000C703028DB3`
   - SHA256 `57B617226C10B5302BE47AFC62A763575A3D280C871553B9159A3F8686124524`
5. Supplement text extracted with pdfminer -> `supplement_extracted.txt` (Tables S1–S4:
   descriptive statistics, PSS-10 item analysis, predictor list, ML parameters).
6. **No raw participant data, no raw item responses, no JASP/WEKA files, and no analysis code**
   exist anywhere under the DOI/OSF project. All raw-data-dependent headline statistics
   (Tables 1–3, regression fits, ML metrics) are therefore marked not-independently-checkable.

## Reconciliation of headline claims against shipped materials
- Present and reproducible (summary-level): N/exclusion arithmetic (C1–C6), §3.1 one-sample
  t-tests & Cohen's d for males/females (C10–C11), Table 3 F-measures from precision/recall
  (8/8), Table S2 item t-tests & d for 9/10 items, Table S1 correlation CIs (approx).
- Not reproducible from raw data (➖): Tables 1–2 regression coefficients, R²/adj-R²/F-change,
  Table 3 ROC/precision/recall/sensitivity, WEKA CFS feature selection.
- Findings: ADV-001 (P1, data/analysis not shipped as promised), ADV-002 (P2, Table S2 Item 1
  mean-vs-t/d inconsistency), ADV-003 (P2, unstated d sign convention), ADV-004 (P3, abstract
  ">76%" vs 0.759), ADV-005 (P3, education 15.35 vs 15.36).

## Version/drift note
The audit reflects OSF content as of 2026-09-14. If the authors later add raw data or code, all
headline statistics should be re-run end-to-end; the current verdict is bounded to the shipped
summary-level materials.
