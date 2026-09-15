# Environment & provenance note — APSR 10.1017/S0003055422000107

Audit performed 2026-09-14 on a Windows 11 x64 host (win32, PowerShell 5.1).

## Toolchain (pinned as actually used)
- R: **4.6.1** (`C:\Program Files\R\R-4.6.1\bin\Rscript.exe`, 2026-06-24 ucrt)
- lme4 **2.0.6** · lmerTest **3.2.1** (author's analysis used REML=FALSE = ML; equivalent spec re-run)
- Python **3.8.10** · statsmodels **0.14.1** · pandas **2.0.3**
- Author-reported fit environment (README): base R **4.1.2** (2021-11-01) with lme4/lmerTest/stargazer/etc.

## Replication package provenance
- Location: paper's Data Availability Statement (APSR p.436) → Harvard Dataverse
  **https://doi.org/10.7910/DVN/SG55BJ** ("Replication Data for: When Do Männerparteien Elect Women?...")
- Files audited (local copy, untouched reference kept): `Replication_code.R`,
  `Replication_data.RData`, `Readme.docx`.
- Engine run inside the ReproAI pipeline (opencode); originals `paper.pdf` / `paper_extracted.txt`
  were NOT modified.

## Provenance chain (raw → analysis → exhibit)
- Raw: `Replication_data.RData` → `newd` (2961 rows, 20 cols, 8 party families; RRP `newd2` = 199 rows).
- Analysis: multilevel OLS with random intercepts for `party` and `country`, `REML=FALSE`,
  on complete cases → Table 1 (N=58) / Table 2 (N=632…613) / Table 3 (N=102…125).
- Exhibit: stargazer `Table1.doc`/`Table2.doc`/`Table3.doc` in author's script; reproduced
  coefficient-for-coefficient from the RData in this audit (no `.doc` outputs were shipped, so
  byte-comparison of the exhibit files was not possible — comparison was on printed model output).

## Version/environment gap & dependency risk
- Fit-time R 4.1.2 vs audit R 4.6.1 (lme4 2.0.6/lmerTest 3.2.1). **No numeric drift observed**:
  every reproduced coefficient/SE matched the manuscript to 3 decimal places.
- `stargazer`, `directlabels`, `colorRamps`, `interplot` (used by the author's full script) are
  NOT installed on this host and are not required for the core model reproduction (lme4 + lmerTest
  suffice). Figure-only code was therefore not re-run; figures do not affect the primary inference.
- A reproducible ML multilevel fit is fragile at small N (58 obs / 22 parties / 19 countries):
  an independent Python `statsmodels` fit converges to a different local optimum (see ADV-001).

## Deliverables layout
```
ReproAI/s0003055422000107/
  REPROAI_REPORT.html            house-style audit report
  manuscript_claims.md           numbered claim inventory (C1-C32)
  exec_check/R/*.R, *.py         reimplementation + cross-check scripts
  exec_check/output/*            console logs, CSV/txt model outputs
  reproai_reports/*.json         architecture / risk / advisory
```
