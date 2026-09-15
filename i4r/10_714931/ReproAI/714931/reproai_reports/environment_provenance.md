# Environment & Provenance Note — 10_714931 (DOI 10.1086/714931)

## Host environment (audit of 2026-09-14)
- OS: Windows (win32), PowerShell 5.1 shell.
- R 4.6.1 (ucrt) at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`.
  - Packages used: `readr`, `dplyr`, `lme4`, `ordinal`.
- Python 3.8.10 / 3.12.10 available (not required for the reimplementation; R used as spec'd).
- Stata: **not installed** on this host. The authors estimated all models in **Stata 15.1** (`meologit` / `melogit`).
  The R reimplementation is therefore **not a byte-for-byte Stata reproduction**; it is an independent port of the
  same model logic. Discrepancies up to ~1–2 pp in marginal predicted probabilities and ±1 in reported N are
  attributable to estimator/missing-data differences (Stata adaptive Gauss–Hermite quadrature + `margins, predict(mu fixedonly)`
  vs R `clmm`/`glmer` Laplace approximation with fixed-only b=0 prediction).

## Provenance chain
1. Manuscript full text: `paper.pdf` / `paper_extracted.txt` (untouched originals in the working folder).
2. Replication package discovered via the paper's stated Dataverse archive
   (`http://thedata.harvard.edu/dvn/dv/jop`, JOP archive) → matching dataset found by search:
   **Harvard Dataverse, The Journal of Politics Dataverse, DOI 10.7910/DVN/D2WL5I**, "State Action to Prevent
   Violence against Women …", Córdova, Abby, 2020-07-30, V1.
3. Three replication files downloaded into `extracted/`:
   - `Cordova_Kras_dataset.txt` (gzip-text `.tab`; 1501 obs × 32 vars; matches paper's N=1501 exactly).
   - `Cordova_Kras_do_file_manuscript.do` (main Table 1 + Figures 1–8 + matching).
   - `Cordova_Kras_do_file_online_appendix.do` (Tables A2–A17, Figure A1).
4. Independent R 4.6.1 reimplementation in `exec_check/scripts/`; outputs in `exec_check/output/`.
5. Originals kept untouched; all work on copies. No shipped number was intentionally altered.

## Version/provenance caveats
- The replication package is dated 2020-07-30 (V1); the manuscript is the 2021 JOP published version.
  No later package version detected on the Dataverse at audit time.
- Main-text **Table 1 (models 1–8) is not present in `paper_extracted.txt`** — the PDF table was not captured by text
  extraction (Likely an image/table object). Audit therefore cross-checks headline interactions via (a) the
  structurally identical appendix models A6–A10 and (b) R reimplementation of those same models. The reported
  coefficients are internally consistent across A6–A10 and reproduce in R, so the headline results are verified
  through those sources; the literal main Table 1 block could not be diffed cell-by-cell (➖ for that specific artifact).
