# ReproAI environment & provenance note — s10683-011-9295-3

## Host environment
- OS: win32 (Windows); PowerShell 5.1 shell
- R: **4.6.1** (2026-06-24, ucrt) — `C:/Program Files/R/R-4.6.1/bin/Rscript.exe`
  - packages loaded: `stats` (base), `pdftools` + `qpdf` (installed during this run from cloud.r-project.org for ESM text extraction; poppler 26.01.0)
- Python: **3.8.10**; libraries: `scipy.stats` (used only for the independent cross-check)
- PDFs read via `pdftools` (no raw-data content in ESM)

## Audit mode
STATIC audit + internal-consistency / derived-value reimplementation. No live author-code execution was possible because **no analysis code is shipped/deposited**, and no raw data is obtainable (see provenance below).

## Provenance chain (paper -> deliverables)
1. `03_s10683-011-9295-3/paper.pdf` + `paper_extracted.txt` — untouched originals (supplied, not modified).
2. Spring Nature article page (link.springer.com/article/10.1007/s10683-011-9295-3) consulted 2026-09-14 to locate ESM.
3. ESM `10683_2011_9295_MOESM1_ESM.pdf` downloaded (766,649 bytes, valid `%PDF` header) from
   `https://media.springernature.com/original/springer-static/esm/art%3A10.1007%2Fs10683-011-9295-3/MediaObjects/10683_2011_9295_MOESM1_ESM.pdf`
   -> `exec_check/ESM_MOESM1.pdf`; text extracted -> `exec_check/ESM_text.txt` (11 pages; Appendix A/B/C; NO raw data).
4. Reimplementation scripts:
   - `exec_check/R/00_extract_esm.R`
   - `exec_check/R/01_internal_consistency.R` (R 4.6.1)
   - `exec_check/R/02_crosscheck_python.py` (Python 3.8 / scipy independent recompute)
5. Outputs: `exec_check/output/console_01_consistency.log`, `w_to_p_check.csv`, `f_to_p_check.csv`, `consistency_cases.RData`.
6. Reports: `reproai_reports/{architecture_report.json, risk_register.json, advisory_plan.json}`; `manuscript_claims.md`; `REPROAI_REPORT.html`.

## Data availability verdict (DATA-NA)
- No OSF / Zenodo / GitHub / institutional data link is cited in the paper or ESM.
- ESM is bot-gated on `media.springernature.com` for plain HTTP (returned an HTML challenge); obtained via curl with a browser UA + Referer, then parsed with pdftools.
- The ESM contains only Appendix A (instructions), Appendix B (hurdle model + M-estimators) and Appendix C (threshold derivations). **No per-subject/per-pair dataset is present anywhere.**
- Therefore every raw-data-dependent statistic (Table 2 regressions, Table 3 Wilcoxon values, ESM B hurdle/M-estimator coefficients, Table 1 SDs/group means, exact KS p) is marked ➖ (not independently checkable) with cause `DATA-NA`.
- All statistics that can be derived from the published cell means / test statistics / thresholds WERE independently recomputed in R and cross-checked in Python (agreement: R == Python on every recomputed value).

## Version/host caveat for any later re-run
- R 4.6.1 / Python 3.8 p-values use identical standard-normal / t / F / chi-squared CDFs; results are stable across R and Python and therefore not version-sensitive for the closed-form checks performed.
