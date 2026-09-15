# Environment & Provenance Note — DOI 10.1086/662130

## Engine / authoring
- **Engine:** anomalyco/opencode (ReproAI reproducibility pipeline)
- **Authoring model:** DeepSeek V4 Flash via uniGPT
- **Rules:** REPRO_STANDARDS.md v2026.06.27
- **Audit date:** 2026-09-14

## Host environment
- **OS:** win32 (Windows); shell PowerShell 5.1
- **R:** `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` — `R version 4.6.1 (2026-06-24)`
- **Working directory:** `...\SCORE ReproAI Checks\08_662130\ReproAI\662130\`

## Inputs (untouched originals)
- `paper_extracted.txt` (1202 lines) and `paper.pdf` under `SCORE ReproAI Checks\08_662130\`.
  Read-only; neither was modified. No reference copy needed because the audit makes no writes to the paper.
- The paper is a scanned-JSTOR OCR text; equation/images are partially corrupted by OCR spacing, but all
  numeric tables (Tables 1-3) and in-text statistics are legible.

## Data / code provenance
- **Shipped with the paper:** none. `paper_extracted.txt` contains no data-availability statement and no
  repository link. The only "online appendix" reference (line ~550) is to a translation of the TS
  *instructions*, not data or code.
- **Publicly located (web search, DuckDuckGo, 2026-09-14):**
  - journals.uchicago.edu/doi/10.1086/662130 (published article)
  - jstor.org/stable/pdf/10.1086/662130.pdf
  - econstor.eu/bitstream/10419/35804/1/585924716.pdf (working paper)
  - docs.iza.org/dp3835.pdf (IZA Discussion Paper 3835)
  - No ICPSR / OSF / Dataverse / GitHub / Zenodo data or code deposit was found for this DOI.
- **Conclusion:** raw z-Tree experimental data and analysis code are **not obtainable** in this audit
  session. Independent raw-data reimplementation is therefore **not possible** → the 24 claims that
  require the dataset are marked **➖**.

## What the audit recomputed closed-form (no raw data required)
1. **Equilibrium effort predictions** from the model `e* = c·(w_high − w_low)/(4q)` (c=2250, q=60):
   every treatment's wage spread = 7.89 → e* = 73.96875 ≈ 74 (matches Table 1).
2. **One-sample t-tests** of the Table-2 means vs e*=74 from reported (mean, SD, N) — 7 rows.
3. **Mann-Whitney / Wilcoxon z → two-sided p** conversions — 8 tests.
4. **Sample-size and percentage/directional arithmetic** (total 320; OS+TS=124; OSL between OS and TS;
   finalist drop ~16; footnote-10 beliefs; TSC foot-9 t-test).

## Reproducibility of the recompute
- All checks are closed-form; **no RNG seed needed**; output is deterministic and byte-stable across runs.
- R scripts: `exec_check/01_internal_consistency.R`; outputs in `exec_check/output/`.

## Version-drift note
- R 4.6.1 built-in stats (`pt`, `pnorm`) used — no third-party packages; no version-drift risk for these
  closed-form quantities. Original analyses (2012) were almost certainly run in Stata/z-Tree; the
  closed-form checks here are tool-independent.
