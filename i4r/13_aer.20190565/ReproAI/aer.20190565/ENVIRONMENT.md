# ReproAI — Environment / Provenance Note
Package: "Vulnerability and Clientelism", AER 112(11):3627–3659 (2022), DOI 10.1257/aer.20190565
Audit: 2026-09-14 · Rules 2026.06.27 · Engine anomalyco/opencode (ReproAI), DeepSeek V4 Flash via uniGPT

## Originals (untouched)
- `paper.pdf` (1,025,078 bytes) and `paper_extracted.txt` (115,175 bytes) in
  `I4R ReproAI Checks/13_aer.20190565/`. Read-only; never modified by this audit.
- Paper metadata confirmed from `paper_extracted.txt` and the AEA article page:
  Authors Gustavo J. Bobonis, Paul J. Gertler, Marco Gonzalez-Navarro, Simeon Nichter;
  AER 112(11):3627-3659; DOI 10.1257/aer.20190565. (Note: eScholarship record predates
  print volume; the AER citation is authoritative.)

## Host environment
- OS / shell: win32, Windows PowerShell 5.1
- Python: 3.8.10 (CPython 64-bit)
- R: 4.6.1 (2026-06-24), driver Rscript
- Working directory: `I4R ReproAI Checks/13_aer.20190565/ReproAI/aer.20190565/`
- Temp scratch (pre-approved, external to workspace): `C:\Users\LROESE~1.IVV\AppData\Local\Temp\opencode`

## Reproducibility of the environment
No RNG is used anywhere: all internal-consistency checks are closed-form arithmetic
(proportions, sqrt(p(1-p)) for binary SDs, coefficient sums, counts). Results are exactly
deterministic. Python and R give identical verdicts where both were run (50 Python + 27 R,
0 mismatches overall).

## Data / code provenance for the audited paper
- Replication data & code are deposited at ICPSR: DOI **10.3886/E173341V1**,
  "Replication Data for: Vulnerability and Clientelism" (Bobonis et al. 2022), cited in the
  article's References and linked from the AEA article page ("Replication Package").
- Supplemental Appendix (online appendix Tables A1–A10, Figures A1–A2) is linked from the
  AEA article page ("Supplemental Appendix").
- **Not obtainable in this audit environment**: both the ICPSR deposit and the AEA
  supplemental appendix returned HTTP 403 (Forbidden) to this host on 2026-09-14
  (ICPSR/AEA bot protection + institutional-login gating; no GUI browser or credentials
  available in this session). All retrieval attempts are documented in this audit's console log.
- Consequence: regression point estimates could only be checked for **internal consistency**
  against the article's own reported numbers (high); they could **not** be independently
  re-estimated from raw data. Every such cell is marked **➖** in the numerical tables with
  the reason "replication data not obtainable in this environment."

## What was actually executed
1. `exec_check/01_internal_consistency.py` — 50 closed-form arithmetic checks of the
   article's own reported numbers (Tables 1–5, samples, electoral bookkeeping). Result: 50 OK / 0 mismatch.
2. `exec_check/02_r_crosscheck.R` — 27 independent re-derivations of the headline
   proportions/SD-conversions in R as a second language. Result: 27 OK / 0 mismatch.
3. Retrieval attempts for the ICPSR deposit and AEA supplemental appendix -> HTTP 403.

## Console log
`exec_check/_reproai_console.log` with `==== START/END (status: OK) ====` markers kept as evidence.

## Provenance chain for every claim verified
- Verified headroom is limited to: prose claim <-> table cell <-> arithmetic identity
  (e.g. effect size ÷ control mean = stated %; binary SD = sqrt(p(1-p)); β1+β2 = reported
  subgroup effect; 260+19+59 = 338). The chain raw -> processed -> regression -> exhibit was
  NOT traceable because the raw data and processing code could not be retrieved.
- One apparent arithmetic mismatch during development (Table 5 col-5 vs col-4 interaction sums)
  was traced to an audit-side column mis-mount and corrected; it was not a manuscript anomaly.
