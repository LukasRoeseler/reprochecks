# ReproAI Environment / Provenance Note — 10.1086/700235

## Engine & rules
- Engine: **anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT**
- Rules: **REPRO_STANDARDS.md, 2026.06.27** (house discipline: claim inventory first, §1; trace to most
  primitive source §2; state conventions §3; method-note for every cannot-verify §4; second-language
  recompute §5; live execution where possible §6; prose/figures/internal consistency §7; self-audit §8;
  severity rubric §9; house output §10; provenance §11).
- Audit date: **2026-09-14**

## Audit host
- OS: Windows (win32), PowerShell 5.1 shell
- Working directory: `C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\`
- Output root: `...\ReproAI\700235\`

## Toolchain (pinned)
- **R:** `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` — R version 4.6.1 (2026-06-24 ucrt).
  Packages probed: `lmtest` present; `plm` NOT installed (no panel-econometrics reproduction was possible
  anyway — see below).
- **Python:** 3.8.10 (Python38). `pdfplumber 0.11.5`, `numpy 1.24.4`, `pandas 2.0.3`.
- **Inputs:** `paper.pdf` (1,595,134 bytes) and `paper_extracted.txt` (110,819 bytes, 1872 lines) — **untouched
  originals, never modified** (per REPRO_STANDARDS §0).

## Provenance chain
raw → article (PDF/full text) → claim inventory (manuscript_claims.md) → table transcription from PDF
(positional pdfplumber + mirrored-text reversal) → R internal-consistency recompute → findings →
REPROAI_REPORT.html + JSON artifacts.

## What was and was not reproduced
- **Not reproducible externally: ALL headline panel-regression output, standard errors/CIs/N, descriptive
  statistics, Figure 1 validation, and counterfactual magnitudes.** The published article ships **no
  replication package and no OSF/Dataverse/GitHub/Zenodo/data-availability link** anywhere in its full
  text (searched for osf|dataverse|github|zenodo|replication|"data and code"|"available at"|doi). The
  disruptive-capacity index is an original compilation from Mitchell (2013), ILO and GGDC data, but none
  of it is deposited. Therefore the R "reimplementation" here is limited to *internal-consistency* checks
  that are computable from the printed tables and prose alone.
- **Reproduced (internal, closed-form):** Table 2 monotonicity (within-SD < overall-SD, 9/9); sample-size
  reconciliation of prose vs Table 3 model info (col1 = 104 countries/1821-2013; col2 = 145/1859-2008;
  col6 = 64 fewest); prose sign/significance of the two headline results vs Tables 3 & 4; counterfactual
  arithmetic (46-yr gain / 83% ≈ twice-as-democratic; 63+37=100 decomposition; 29/54%; 49/57% etc.).
- **Discrepant:** Table 1 union-availability-bias — prose "42 points higher (0-100)" vs tabled "142"
  (col not interpretable on a 0-100 scale).

## Mirror-text caveat (affects transcription, not verdicts)
The AJS "track" PDF stores Tables 1, 3, 4 as **mirrored right-to-left text**, and negative (landlord) 
coefficient magnitudes plus many CI endpoints required manual reversal (decode_tables.py). One paired
value (Table 4 col1 disruptive: point 1.406 vs CI [2.13,3.15]) fails its own point-in-CI test in my 
transcription — judged a reversal/pairing artifact, **not** a paper error, and excluded from verdicts
(REPRO_STANDARDS §3/§12 false-positive guard).

## Version/data-drift note
No fit-time vs render-time drift applies: no code or data was shipped to audit. If the author later
provides the replication bundle, the authoritative next step is a fresh clean-session R run that matches
Tables 3 & 4 to printed precision and re-derives the counterfactuals with Simpson's rule.
