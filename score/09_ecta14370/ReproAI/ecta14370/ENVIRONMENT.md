# Environment & Provenance Note — ECTA14370 ReproAI audit (2026-09-14)

## Host / tooling
- OS: Windows (win32); shell: PowerShell 5.1
- R: 4.6.1 (`C:\Program Files\R\R-4.6.1\bin\Rscript.exe`), packages: `pdftools`
- Python 3.8 / Stata / SPSS: not required (no author code to port — none exists publicly)
- Engine: `anomalyco/opencode (ReproAI)` — DeepSeek V4 Flash via uniGPT; rules 2026.06.27

## Artifact provenance chain
1. `SCORE ReproAI Checks\09_ecta14370\paper_extracted.txt` — supplied manuscript extraction (title/DOI confirmed: Econometrica 86(5) 2018, 1839–1858). **Untouched.**
2. `paper.pdf` — supplied. **Untouched.**
3. Supplement PDF: downloaded live from the Econometric Society article page
   `.../ecta14370-sup-0001-Supplement.pdf` (371,818 bytes) → `exec_check\output\supplement.pdf`
4. Supplement text extracted with R `pdftools::pdf_text` → `exec_check\output\supplement.txt`
5. Internal-consistency reimplementation → `exec_check\01_internal_consistency.R` → `exec_check\output\01_internal_consistency.log`
6. Console log → `exec_check\_reproai_console.log`

## Data / code availability finding
- Econometrica article page exposes **Supplement PDF only** — no "replication data" tab.
- Zenodo `es-replication-repository` community API search for `ECTA14370` → **0 hits**.
- Conclusion: **no raw data / code package is publicly available.** This 2018 paper predates Econometrica's
  mandatory data-editor replication policy (introduced ~2019–2020).
- Consequence: statistical inference (SEs, t, Chi2, R², Spearman, Wilcoxon/Mann–Whitney, medians) is NOT
  independently executable → marked ➖ with this reason. All *linear/index-level* claims plus all N/denominator
  arithmetic were independently verified from published tables (see R script log).

## Provenance gaps
- No `.RData`, lockfile, or reproducible-fit metadata ever shipped (no package exists).
- Rounds of the paper: published version audited (available online 3 Apr 2018). No superseding replication package located as of audit date.
