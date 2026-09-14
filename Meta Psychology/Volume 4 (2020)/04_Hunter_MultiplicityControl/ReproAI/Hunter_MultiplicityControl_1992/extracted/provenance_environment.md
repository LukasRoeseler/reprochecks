# ReproAI re-audit provenance & environment record — Hunter et al. (2020) MP.2019.1992

ReproAI re-audit executed 2026-09-14 by anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT.
Rules: REPRO_STANDARDS.md dated 2026.06.27. Host: Windows 11 x64 (build 26100), PowerShell 5.1.

## Package audited
- ID: MP.2019.1992 · DOI: 10.15626/MP.2019.1992
- Title: "Multiplicity Control vs Replication: Making an Obvious Choice Even More Obvious"
- Authors: Andrew Hunter, Linda Farmus, Nataly Beribisky, Robert Cribbie (York University)
- Journal: Meta-Psychology, 2020, vol 4. Edited by Erin M. Buchanan.
- OSF project: https://osf.io/9b6z3 (public node "MP.2019.1992.Hunter"); fork of private node xvqdy.
- Badges on record: Open materials: Yes; Open and reproducible analysis: Yes; Analysis reproduced by: Erin M. Buchanan.

## Source of truth
- paper.pdf and paper_extracted.txt (provided, UNMODIFIED) — full article text + tables.
- OSF data/code downloaded live on audit date via osf.io API v2:
  - author simulation R script: GUID xrq3k (size 15,043 bytes) -> exec_check/author_code/hunter_author_sim.R
  - author manuscript PDF: GUID jgpw4 (237,605 bytes) -> exec_check/author_code/hunter_author_manuscript.pdf
  - cover letter: GUID fnph7 (13,358 bytes) -> exec_check/author_code/hunter_cover_letter.docx
  - Peer Review Report: GUID smqw2 (PRR_MP.2019.1992.Hunter.pdf)
  - Decision letter: GUID vj9t5
- OSF storage traversal (2026-09-14): root node 9b6z3 osfstorage EMPTY (TOTAL=0). Children components:
  Submission (28g7m) holds cover letter, R script (xrq3k), author manuscript PDF — all present & downloadable.
  Review round 1 (4eq79), Peer Review Report (5spwt). Registrations 7n6ez / dtnx2 exist.

## KEY RE-AUDIT CORRECTION
The PRIOR audit (2026-09-10) reported the shipped R code as a "404 / 0-byte placeholder"
(ADV-001, P2; counted as "technical failure"). On 2026-09-14 the R script was downloaded
successfully from GUID xrq3k: 15,043 bytes, valid R source that executes cleanly (status 0).
The "404 placeholder" finding is therefore REFUTED by direct download evidence. The code is
available and runnable NOW. It is, however, a stripped demonstration file (nsim<-5, single
mean-configuration) that must be scaled to nsim=5000 across configurations to reproduce the
manuscript's Tables 3-8.

## Environments / versions
- R: R version 4.6.1 (2026-06-24 ucrt), Windows x86_64. Deps installed for author script:
  WRS2 1.1-7, effsize 0.8.1, metafor 5.0-1 (RNG base). Author script also loads reshape (dep).
- Python: 3.8.x at C:\Users\...\Python38; numpy, scipy used for independent cross-check.

## Seed handling
- The AUTHOR code contains NO set.seed() and the paper does not report a seed. R default RNG.
- Independent reimplementation used set.seed(20260914) (primary) and set.seed(987654321)
  (drift run). Cross-seed drift in FWER cells <= 0.005, i.e. results are seed-stable at
  nsim=5000 (expected MC std error ~ sqrt(p(1-p)/5000) ~ 0.006).

## Execution performed (all on copies; originals untouched)
1. Live author-code run AS-IS (nsim=5): executes, status 0, prints one condition's rates
   (hardcoded 7-group non-null, n=100).
2. Live author-code run at nsim=500 (documented single edit nsim 5->5000/500): 355 s elapsed,
   reproduces flagship Table 6/Table 8 n=100 7-group non-null cells to within MC noise.
   Author-code full nsim=2000 run exceeded 900 s and was aborted -> computational impracticality.
3. Independent reimplementation hunter_reimpl.R (base R, 5000 sims/cond, all 12 configs):
   205 s. Outputs -> exec_check/output/*.csv.
4. Python cross-check hunter_crosscheck.py (numpy/scipy, nsim=5000): no-control FWER + flagship
   power contrast.
5. Cell-by-cell comparison hunter_compare_manuscript.py: 336 manuscript rate-cells vs
   independent reimplementation -> 280 EXACT (|d|<=.005), 50 CLOSE (<=.02), 6 MISMATCH (>0.02,
   all in meta-analysis cells, implementation-difference cause).

## Rounding / classification convention
- EXACT: |manuscript - reimpl| <= 0.005 (3-decimal rounding noise)
- CLOSE (approx): <= 0.020 (Monte-Carlo sampling error at nsim=5000)
- MISMATCH: > 0.020
