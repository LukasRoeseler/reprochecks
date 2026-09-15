# Environment & Provenance Note — aer.20161385 (Hjort & Poulsen 2019, AER)

## Audit identity
- **Engine:** anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT
- **Rules:** REPRO_STANDARDS.md, version 2026.06.27
- **Audit date:** 2026-09-14
- **Article:** *The Arrival of Fast Internet and Employment in Africa*, American Economic Review 2019, 109(3): 1032–1079, DOI 10.1257/aer.20161385
- **Sources on disk (untouched):** `paper.pdf` (1,469,070 B), `paper_extracted.txt` (169,115 B) in `…\I4R ReproAI Checks\15_aer.20161385\`.
  - Note: the workspace also contains a folder named `17_pol.20210812`; the DOI `aer.20161385` matches folder `15_aer.20161385`. The task's "batch item 17" label is treated as a typo for the correct folder `15_aer.20161385`.

## Host environment (this session)
- OS: Windows (win32); shell: PowerShell 5.1.
- R: `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` (R 4.6.1, 2026-06-24). Packages used: base + `jsonlite` (installed). `pdftools` NOT installed.
- Python: `Python 3.8.10` (pdfminer available) — used for an authoritative second text extraction of `paper.pdf` (`pdfminer_full.txt`) to confirm coefficient signs that the `.txt` extract had dropped (e.g., Table 3 Panel B “wants to work more” = **−0.022**).
- Stata: **NOT installed** on the audit host. The author package is Stata-based (`.do` + `.dta`), so no live Stata run was possible.
- No SPSS; not relevant to this paper.

## Data / materials availability (verified)
- Paper states a data/code-availability footnote (p. 1032) and cites the dataset in the references.
- **Replication package EXISTS and is complete** at openICPSR DOI **10.3886/E113156V1** (AEA Data & Code Repository), version V1, deposited 2019-10-12.
  - `data/`: 13 Stata `.dta` files incl. afrobarometer.dta, afrobarometer_close2landing.dta, afrobarometer_roads_electricity.dta, afrobarometertii.dta, akamai.dta, itu.dta, light.dta (104 MB), lmmis.dta, qlfs.dta (153 MB), qlfs_close2landing.dta, + DHS inputs.
  - `syntax/`: 19 files incl. t1.do, t2.do, t3-and-f6.do, t4.do, f4.do, f5.do, f7.do, fa1.do, ols_spatial_HAC.ado, reg2hdfespatial.ado.
  - `gis/`, `LICENSE.txt`.

## Why the full-data retabulation is marked ➖ in this session (not a package defect)
- `www.openicpsr.org`, `www.icpsr.umich.edu`, and `pcms.icpsr.umich.edu` answer this shell’s egress with a **Cloudflare “managed challenge” HTTP 403** (reproduced via PowerShell `Invoke-WebRequest`, `curl.exe`, and the webfetch tool on the download endpoints). The openICPSR file-download / terms flow additionally requires an interactive signed-in browser.
- No public mirror of the data/code was found (GitHub API search returned 0 results).
- Stata (the author’s analysis tool) is not installed on this host.
- **Consequence:** all regressions that require raw microdata (every coefficient, clustered SE, p-value, N–R², Table 1 exact t-statistics) are **➖ not independently re-derived this session**, with the exact public download path and the Stata recipe (equation 1 of the paper; t1–t4.do, f4/f5/f7.do) preserved in `reproai_reports/advisory_plan.json`.

## What WAS independently re-derived (no microdata needed)
- All 41 manuscript-derivable internal-consistency arithmetic checks (see `exec_check\manuscript_claims.md`, `exec_check\output\internal_consistency_checks.csv/.json`).
- Independent cross-checks in **two languages** (R 4.6.1 and Python 3.8) — full agreement:
  - R: 40 check / 1 approx / 0 discrepant.
  - Python (overlapping subset): 31 check / 1 approx / 0 discrepant.
- Provenance chain: paper.pdf → paper_extracted.txt (transcription) + pdfminer_full.txt (authoritative signs) → R/Python re-derivations → CSV/JSON → this report. Originals untouched; all work on copies under `exec_check\`.

## Provenance chain (raw → analysis → exhibit)
Confirmed for the *arithmetic claims* (C1–C41) from the published summary statistics. The raw → analysis step for the *regression coefficients* is preserved but not executed this session (see above).

## Version / dependency risks
- `jsonlite` was the only R package required and is present. No archived/removed packages were involved.
- Stata (author tool) and R/Python (auditor tools) are version-wise unrelated to any reported number; the only place version could matter is a future Stata retabulation, where Stata’s clustered-SE convention must match the paper (SEs clustered at location FE level) — flagged for the implementer.
