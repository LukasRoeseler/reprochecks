# Environment / Provenance note

**Audit host:** win32 (Windows), PowerShell 5.1 shell.
**Engine:** anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT. Rules version 2026.06.27. Audit date 2026-09-14.
**R:** `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` — R 4.6.1 (2026-06-24 ucrt), platform x86_64-w64-mingw32,
RNGkind Mersenne-Twister. Recommended packages used: survival, nnet, MASS (all present, verified in 00_environment.R).

## Provenance chain
- **Shipped originals (untouched, read-only):** `paper.pdf`, `paper_extracted.txt` in the SCORE batch folder
  `07_0022002714547903\`. Last modified 15.09.2026.
- **Artifact identity:** `paper_extracted.txt` is the **ICIP Working Paper 2012/5 (November 2012)** preprint by
  Laia Balcells & Stathis N. Kalyvas, "Does Warfare Matter? Severity, Duration, and Outcomes of Civil Wars",
  41 pages, ISSN 2013-5793 (online).
- **Version of record:** the stated DOI **10.1177/0022002714547903** resolves to the Journal of Conflict Resolution
  **58(8):1390–1418 (2014)** — a later, revised publication. The audited text is therefore a **pre-print**, not the
  version of record (ADV-002).

## Data & replication availability (searched 2026-09-14)
- No replication URL/data/code appears anywhere in `paper_extracted.txt` (regex scan for http/replic/dataverse/OSF/github
  -> only institutional/formatting URLs: icip.cat, ggdc.net, chicagomanualofstyle.org, workscited4u.com, citationmachine.net).
  The paper references an "Online Appendix" (coding rules/codebooks) but gives no URL.
- Harvard Dataverse API searches: exact-title phraseless search `"Severity, Duration, and Outcomes of Civil Wars"` -> 0 datasets;
  `Balcells Kalyvas Warfare Matter` and `Kalyvas technologies of rebellion` -> no dataset for this article (found only the related
  "Marxist Paradox" (APSR, 2025) and other Balcells datasets). JCR Dataverse page is JS-rendered and returned no matching entry.
- **Conclusion:** no replication package is obtainable for this article. Source-level model coefficients (Tables 1–8) are
  therefore marked ➖ (not independently reproducible) with this documented reason.

## What was actually run
R 4.6.1 scripts under `exec_check\scripts\`:
- `00_environment.R` -> `output\00_environment.txt` (host/packages).
- `01_internal_consistency.R` -> `output\01_internal_consistency.txt` (arithmetic sample-accounting and cross-table N checks).

No regression was re-estimated because no data is available; this is a **static audit + arithmetic consistency** pass.
