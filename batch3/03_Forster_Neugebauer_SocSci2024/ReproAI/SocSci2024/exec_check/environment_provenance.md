# Environment & provenance note — ReproAI SocSci2024 audit

## Engine / toolchain
- **Auditor engine:** anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT
- **Rules:** REPRO_STANDARDS.md version 2026.06.27
- **Audit date:** 2026-09-14
- **Host OS:** Windows (win32); PowerShell 5.1

## Statistical environment used for the independent reimplementation
- **R:** 4.6.1 — `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`
- **R packages:** haven (read .dta), dplyr, sandwich (HC1 / vcovCL cluster-robust SEs), lmtest, ggplot2, jsonlite
- **Stata:** NOT installed on this host. The authors' own code (`01_code/*.do`) is Stata 18 syntax and was
  NOT executed. All manuscript statistics were independently regenerated in R directly from the shipped
  `.dta` files, replicating the Stata model specs exactly (OLS LPM; `vce(robust)` = HC1 for the FE;
  `vce(cluster ID)` = CR1/HC1 clustered at employer for the FS; `egen pctile` default quantiles = R
  `quantile(type=6)`). This counts as the mandated **second-language** independent recompute (R vs the
  authors' Stata).

## Data provenance
- **Reproducibility package:** OSF node `x2tcp` — https://osf.io/x2tcp/
  - File: `replication_package_incl_data.zip` (79,009 bytes)
  - MD5 `d1ddb190416a09b894c2d28e2838e1c5`, SHA-256 `7dd807a420f9c4db10ef5d469135beed6e254dbe12bc88da3427745810481578`
  - Package `date_modified`: 2024-08-23; single version (current_version = 1)
  - Downloaded 2026-09-14 and verified (MD5 match). This is the same-week reference package; no stale snapshot
    concern (only one version exists on the node).
  - Shipped data: `00_data/validation_fe.dta` (3,002 × 11), `00_data/validation_fs.dta` (3,840 × 17).
  - Shipped code: `00_master.do`, `01_dataprep_significance.do`, `02_descriptives.do`, `03_models.do`, `04_robustness.do`.
- **Preregistration:** OSF node `2jrgu` — https://osf.io/2jrgu/ (public; title "Under which conditions are factorial
  survey results valid? Comparing hiring decisions between a field and a vignette experiment.", modified 2024-09-28),
  child of project `8cugv`.
- **Manuscript:** `paper.pdf` / `paper_extracted.txt` in the working directory (untouched originals).

## Data chain
raw `.dta` → R LPM models (HC1 / cluster-robust) → coefficients, SEs, pooled interaction disparities,
percentile group splits → compared to manuscript Table 2 / Figures 3–6 / prose. All work was done on
copies under `exec_check/`; originals untouched.

## Version-gap note
No reported number depended on a version-sensitive default once R was set to match Stata's conventions
(HC1/cluster SEs and `pctile` type-6). The R reimplementation should therefore be robust to R patch-level
differences within R 4.x.
