# ReproAI uhbk9 — Environment & Provenance note

## Audit identity
- Engine: `anomalyco/opencode (ReproAI)` — model **DeepSeek V4 Flash via uniGPT**
- Rules: REPRO_STANDARDS.md dated **2026.06.27**
- Audit date: **2026-09-14**
- Mode: **reimplementation** — the OSF project data *are* obtainable (project files present under `extracted/`), so the headline analyses were independently rebuilt in R and cross-checked with a second implementation (`fixest`).

## Host environment
- OS: Windows (win32), PowerShell 5.1
- R: `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` — R 4.6.1 (2026-06-24)
- R packages available & used: `fixest`, `sandwich`, `lmtest`, R base `stats` (vcov/lm).
- No Stata executable was available on the host; the authors' `.do` files and `cluster2` subroutine were re-implemented in R (two-way cluster-robust VCV, Cameron–Gelbach–Miller additive V = V_id + V_item − V_id×item).

## Provenance chain
- Manuscript text (read-only): `paper_extracted.txt` (do not modify). PDF: `paper.pdf`.
- Author data/code (read-only, reference copies kept in `extracted/`):
  - `extracted/Pennycook et al._Study 1.csv` (853 rows)
  - `extracted/Pennycook et al._Study 2.csv` (856 rows)
  - `extracted/study 1 code.do`, `extracted/study 2 code.do`
- All analysis work on copies in `exec_check/R/`; outputs in `exec_check/R/output/`.
- Originals were not modified.

## Key preprocessing facts (state explicitly, REPRO_STANDARDS §2/§3)
1. **Study 1 raw ratings are spread across presentation order-block columns.** The `Condition` code (1–4) selects the version column suffix for every subject: 1→base, 2→`.0`, 3→`.1`, 4→`.2`. A naive read of the base `Fake1_*`/`Real1_*` columns yields only ~212 real ratings and a singular regression; version selection recovers all 25590 ratings. This is the single most important data-handling step.
2. **Study 2** ratings live in the base columns; 25627 non-missing obs over 855 effective subjects gives df2=25623, matching the manuscript exactly.
3. Standardized DV (Study 1) uses sample SD; Study 2 rating rescaled to [0,1] via `(r-1)/5`, per the `.do`.

## Cross-check
- Study 1 interaction cluster-robust F recomputed by (a) hand-rolled two-way cluster VCV (`00_lib.R`) and (b) `fixest::feols(..., cluster=~id+item_num)` — both ≈ 43.7, versus manuscript 42.24. This rules out an implementation artifact and points to a data-level difference (ADV-001).
- Study 2 F reproduces exactly (17.881 vs 17.88), the strongest evidence that the shared analysis machinery is correct.

## Reproducibility verdict summary
- Study 2 (accuracy-nudge experiment): headline interaction, simple effects (d, F, p), 2.8× claim and Figure 3 `r(28)` **reproduce**.
- Study 1 (accuracy-vs-sharing): cell means, Table 1 simple effects and demographics **reproduce**, but the headline cluster-robust interaction statistic (F = 42.24 → 43.70; β −0.126 → −0.130/raw −0.520), the accuracy simple-effect F (42.24 → 52.75), and the prose "32.4%" claim (→ 31.4%) **do not reproduce** from the shipped data. Direction and significance are unchanged.
- Study 2 gender counts in the manuscript over-count N (861 vs 856; 468 vs 463 F).

## Do-not-fabricate note
✅ only where identical at reported precision; ≈ only where methodologically close; ⚠ carries cause + fix; ➖ only with an explicit reason (alpha reliabilities and Study 2 moderation p-values were not independently recomputable this pass — no item scoring keys / full moderation reruns were performed).
