# Environment / provenance note — Sanders et al. 2024 (10.1038/s41562-023-01712-8)

## Engine & session
- Engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT
- Rules: REPRO_STANDARDS.md version 2026.06.27
- Audit date: 2026-09-14
- Host: Windows, PowerShell 5.1
- R: 4.6.1 (2026-06-24, ucrt) — Rscript at C:\Program Files\R\R-4.6.1\bin\Rscript.exe
- metafor: version 5.0-1 (authors' method cites R 4.3.0; version drift is non-load-bearing for closed-form pooled estimates)
- Other R packages: dplyr, tidyr, effectsize, correlation (used for the reanalysis)
- Python: 3.8.10 at C:\Users\lroesele.IVV5NET\AppData\Local\Programs\Python\Python38\python.exe (independent recompute; std-lib only)

## Source materials (untouched)
- paper.pdf, paper_extracted.txt (working directory root) — not modified.
- Repository snapshot cloned (shallow) from https://github.com/motivation-and-Behaviour/screen_umbrella
  into a temp work area and copied (read-only reference) into exec_check/repo_data, exec_check/repo_R, exec_check/_targets.R.

## Data-cleaning sentinel (critical to reproduce)
- The shared Studies.csv uses "-999", "" and "#N/A" as missing-value sentinels.
- The authors' loader (R/utils.R read_sheet) reads with na = c("-999","", "#N/A").
- Any reimplementation MUST map these to NA before the mean-N imputation
  (clean_studies.R: study_n imputed with round(mean(study_n, na.rm=TRUE)) within effect).
  Without this, metafor fails with "One or more sample sizes are <= 0" (27 effects) — this was
  diagnosed and corrected in this audit; no paper value was at fault.

## Seed / RNG handling
- The re-analysis is closed-form (random-effects meta-analysis, DerSimonian-Laird / restricted-likelihood
  in metafor). No MCMC, no jitter, no permutation — no RNG and therefore no seed is load-bearing.
- Python cross-check uses the same closed-form DL estimator on Fisher-z (no RNG).
- Consequently results are deterministic across runs.

## Verify-by-tool split
- PRIMARY (authoritative): R + metafor reproducing the authors' run_metaanalysis
  (rma measure="COR", per-effect) on the shared study-level data. 18/18 quoted effects match.
- SECONDARY (independent second language): Python 3.8 std-lib DL-on-Fisher-z for 8 headline effects;
  agrees in direction/magnitude; point estimates within implementation tolerance once the full metric
  vocabulary could be encoded.

## What is NOT covered
- No end-to-end run of the full targets graph (would require installing the pinned renv set incl.
  webshot/webshot2 + Python PDF-merge tooling; not executed to avoid environment side-effects).
- The exact 217->102 risk-of-bias denominator mapping and the de-duplicated aggregate totals are
  pipeline-internal (see ADV-001) and were not re-derived by hand.
- External background citations (PROSPERO record text, Parry et al., Hale & Guan, etc.) were not
  independently re-checked (marked ➖ in the claim inventory).
