# Environment / provenance note — e3kcw

## Engine & identity
- Engine: `anomalyco/opencode (ReproAI)` — model `DeepSeek V4 Flash` served via uniGPT.
- Rules: REPRO_STANDARDS.md version **2026.06.27**.
- Audit date: **2026-09-14** (report date).
- Host OS: Microsoft Windows (win32), PowerShell 5.1.

## Package audited
- DOI: **10.31234/osf.io/e3kcw** (SCORE batch item 6). **"Flow in the Time of COVID-19: Findings
  from China"** — Sweeny, Rankin, Cheng, Hou, Long, Meng, Azer, Zhou, Zhang; PsyArXiv preprint.
- Paper type: empirical psychology / wellbeing cross-sectional survey (China, COVID-19, Feb 2020).

## Originals (NOT modified)
- `paper.pdf` and `paper_extracted.txt` in the working directory were left untouched (read-only).
- Reference sources (OSF) downloaded into `exec_check/source/`:
  - `Primary sample data (minus identifiers).xlsx` — MD5 `82ac621667427972fa765e8000dc5f77`,
    SHA256 `e6b5ebcfa1185ced6172478414090741ccccef48941c2f1f263519c19fa06c5c` — **byte-identical to
    OSF-reported hashes** (provenance integrity confirmed at download time).
  - `COVID 2020 China survey OSF.docx` — survey instrument.
  - `full_regression_results.pdf` — author full model output (all covariates), MD5 `7b2499686b9442c29915a3886dff13a3`.

## Data-source provenance chain
- Paper's in-text OSF link: `https://osf.io/vuwg3/?view_only=c6b099ff5795499ea7f14a69d645dea8`.
  OSF node **vuwg3** "COVID-19 China Survey Feb 2020" (public; date_created 2020-03-17, modified 2022-03-27).
- The DOI's own OSF node id (`e3kcw`) is **not** reachable via the OSF v2 API (HTTP 404) — the DOI is the
  PsyArXiv preprint handle; the auditable materials live on the project the paper itself links (`vuwg3`).
- Data file: 5115 rows x 52 cols (N=5115). Subscale totals shipped alongside item-level data for
  worry (3), loneliness (3) and health behaviors (6). Item-level data for flow, mindfulness, posemo,
  negemo, depress, anx, opt, iu, swls are NOT in the de-identified release (only totals), so their
  Cronbach alphas cannot be independently recomputed (marked ➖).

## Host software for recomputation
- R 4.6.1 (2026-06-24 ucrt), Rscript at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`.
  Packages: readxl, openxlsx, psych, dplyr, jsonlite, writexl.
- Python 3.8.10 (`C:\Users\lroesele.IVV5NET\AppData\Local\Programs\Python\Python38`): pandas, numpy,
  scipy, pdfplumber, openpyxl. Used for second-language cross-check of the headline numbers.
- No analysis/code file was shipped by the authors (only data + survey + full-results PDF), so live
  author-code execution was not possible; reconstruction was done to the closest documented convention
  (grand-mean-centered, fully-standardized OLS, listwise deletion of 146 age-NA cases).

## RNG
- No RNG anywhere in this pipeline (all OLS closed-form); results are deterministic and byte-reproducible.
