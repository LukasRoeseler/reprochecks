# Provenance & environment note — Cloyne (2013) ReproAI audit

## Audit identity
- Study: Cloyne (2013), AER 103(4):1507–28, DOI 10.1257/aer.103.4.1507.
- Human reproduction category (FLoRA): "Computationally reproducible" (per task brief).
- Audit date: 2026-09-15. Engine: opencode/ReproAI.

## What was obtained
- **Paper abstract & article metadata:** from aeaweb.org article page (fetched live). Full text is paywalled;
  headline abstract claim (0.6 on impact / 2.5 over three years) confirmed.
- **AER Online Appendix (Supplemental Appendix) PDF, 446 KB:** downloaded from aeaweb.org/articles/materials/2190;
  text extracted with pdfminer → `output_supplement.txt`. Details data construction, tax-shock series (1945/1955–2009),
  VAR/Figure set, robustness figures.
- **Human FLoRA reproduction report:** *I4R Discussion Paper 132* (Kopecky, Campbell, Brodeur, Johannesson, Lusher,
  Tsoy, 2024), "Robustness Report on Cloyne (2013)". Recovered via the Wayback Machine (EconStor original is behind
  the "Anubis" anti-bot proof-of-work) → `I4R_DP132.pdf` → extracted `output_i4r.txt`. Contains the exact reproduced
  baseline impact (0.599) / peak (2.458) and all robustness tables.
- **OSF "AER Robustness Project"** (node `w7vpu`; the task-given `osf.io/4qnf7` is the file GUID of
  `Robustness reports/discretionary-tax-changes-FINAL.pdf` in that node): enumerated. This project hosts the *survey
  robustness materials* of the AER meta-study by the same I4R team — it does **not** contain Cloyne's macro/tax data.
- **ICPSR replication-package manifest** (10.3886/E112651V1): project V1, folder `20111351_data` containing
  `data.xlsx`, `Table2.m`, `Figures3to9.m`, `Figure1and2.m`, `Figure10.m`, `table1.wf1` (EViews), `ReadMe.pdf`
  (+ `LICENSE.txt`). File list obtained from the browser-rendered OpenICPSR folder page.

## What could NOT be obtained (and why)
- **Raw data/code files (data.xlsx, *.m, table1.wf1, ReadMe.pdf) could NOT be downloaded.** OpenICPSR's `/download`
  and `/download/terms` routes answer a Cloudflare *managed challenge* even to a real headless Chromium (Playwright) —
  distinct from the `/view` HTML pages, which render. ICPSR's new deposit host redirects anonymous downloads to a
  Keycloak login. No third-party mirror exists (checked Zenodo, GitHub, Wayback CDX). Therefore the raw series is not
  retrievable in this environment, and a from-scratch VAR impulse-response recomputation was not feasible.

## Numeric verification performed (without raw data)
- Internal-consistency of the published human reproduction (I4R DP132 Table 1): recomputed z = coef/SE and 95% CI =
  coef ± 1.96·SE for impact & peak across the three reported columns; all within rounding. See `output/i4r_consistency.csv`.
- Cross-source agreement: abstract (0.6 / 2.5) ↔ I4R author-code reproduction (0.599 / 2.458) ↔ Stata reproduction
  (0.567 / 2.226).

## Environment
- OS: Windows (win32), PowerShell 5.1. Python 3.8.10 (pdfminer, requests, playwright, numpy, pandas, statsmodels),
  R 4.6.1 available but not required. Browser: Playwright Chromium (headless) for Cloudflare/OpenICPSR enumeration.
