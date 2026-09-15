# NHB Code Re-execution Status & Runbook

**Status (honest):** The Meta-Psychology vs NHB report's *Meta-Psychology* results are genuine
code re-executions. The *NHB* results, as currently published, are **full-text availability/claims
audits** — the model read each paper's PDF and logged data/code availability and the statistical
claims it could find, but did **not** download and re-run the authors' code. The `status`
values historically labelled `reproduced / partial / not_reproduced` for NHB mean
*data/code link present / statement only / no statement*, **not** actual recomputation. This
runbook records the step taken toward genuine re-execution and what remains.

## What was done

1. **Fixed OSF access.** `api.osf.io` JSON API times out on this network, but
   `files.osf.io/v1/resources/<node>/providers/osfstorage/...` works. A recursive downloader was
   built on that endpoint (`osf_fetch2.py`).
2. **Downloaded the NHB corpus** (~29 GB, 21,434 files):
   * OSF: **44 of 48** projects succeeded (4 failed: `y2mdw` 2020-37, `pcjwf` 2020-48, `jmiwn` 2020-61, `uwq2t` 2020-82)
   * GitHub: **37 of 38** repos cloned (1 failed: `EtienneTho/musical-timbre-s` 2020-08)
   * Figshare: **0 of 2** (both failed: 2019-48, 2020-71)
   * **71 papers** have at least one downloaded source; manifest: `nhb_reexec_manifest.json`
3. **Proven genuine re-execution works** for R-based papers (e.g., 2019-02 Kristal — the author's
   `Transport Analysis 201910.R` + `study1.csv` re-ran and produced real tables).

## Genuine re-execution of the R/Python subset (this pass)

The feasible **R** subset was actually re-executed where the archived repo made faithful
reproduction possible. For every paper below the author's own scripts were run on the author's
own downloaded data (using R 4.6.1; where the author authored under R < 4.0, the only change
applied was the standard `stringsAsFactors=TRUE` compatibility shim, never an alteration of the
analysis). Each verdict is genuine — verified against the published paper where the numbers
could be reached.

| Paper | Language | Verdict | Evidence |
|-------|----------|---------|----------|
| 2019-02 (Kristal) | R | **Reproduced** | Author `Transport Analysis 201910.R` ran on `study1.csv`, producing the reported tables |
| 2019-10 (Lees, Exp 1) | R | **Partially reproduced** | Beta-regressions replicate EXACTLY: Meta-P opposition b=1.405 (paper 1.40), OR=4.075 (4.08), z=8.784 (8.78); Control opposition b=1.224 (1.22), OR=3.401 (3.40), z=8.147 (8.15). Post-hoc emmeans + LMM robustness also match. Remaining experiments (2–6, Study 5, Suppl A/B) not yet re-run |
| 2020-39 (Yamada) | R | Ran, incomplete | GLMM fitting ran; script's bootstrap/Monte-Carlo section is computationally prohibitive and did not complete in time budget |
| 2020-31 (2020) | R | Could not complete as-archived | Reproduction RData present (3.9M rows) but `source_timestamp_conversion.csv` + `county_turnout_estimates.csv` not archived; model not faithfully rebuildable |
| 2020-34 (Lisi) | R | Could not complete | Needs non-CRAN packages `mlisi` + `bmsR` (GitHub) and numerical lookup tables; heavy Bayesian model comparison |
| 2019-42 (Strimling) | R | Could not complete | Raw GSS download not in repo + missing intermediate `.rds`; multi-stage pipeline |
| 2019-27 (Smaldino) | R+Java | Could not complete | Agent-based simulation output data not archived; R reads author's local Dropbox path |
| 2020-94 | R | Could not complete | Rmd needs `org_and_cult_haldrates_before_gams.csv` not archived; claims (1960/52) from other analyses |
| 2020-43 (Allen) | R | Could not complete | Raw `hwf_data_renorm_reformat.csv` from author's Dropbox not archived |

The **Python** papers in the corpus are dominated by heavy machine-learning / notebook /
sequential-Monte-Carlo pipelines (e.g., 2020-17 `SMC2.py`, 2019-03, 2019-17 `.ipynb`) requiring
TF/torch/Stan plus long compute; a faithful Python re-execution requires a full per-repo venv +
GPU/CPU budget and was not completed in this pass. No Python paper is claimed as re-executed.

**MATLAB:** 15 papers are **not re-executed because no MATLAB license (or a free Octave)
is available in this environment.** Without a MATLAB license the `.m`/`.mat` analyses cannot be
run; obtaining Octave would cover most but not all (some use toolbox functions). This is a
licensing/availability limitation, not a methodological one.

## Feasibility profile (71 papers with sources)

| Language | Papers | Notes |
|----------|--------|-------|
| R        | 30     | R 4.6.1 + 694 packages installed; genuine re-execution feasible |
| Python   | 19     | Python 3.8 present; needs per-repo deps |
| MATLAB   | 15     | **Blocked** — no MATLAB/Octave in environment |
| C/C++    | 6      | needs compilation toolchain |
| Stan     | 2      | needs C++ toolchain / rstan |
| Julia    | 2      | blocked (no Julia) |
| data(.mat)| 12    | dependency of MATLAB scripts |

## What remains for a full, honest re-execution

1. Obtain a **MATLAB license or GNU Octave** (15 MATLAB papers blocked without it).
2. Per-paper: read the analysis script(s), install the required R/Python/Stan packages,
   set correct working directories/data paths, run, and compare every extracted claim
   (d/r/p/effect sizes in each paper's `claims` list) to the recomputed values.
3. Re-labelling: only then should an NHB `status` be changed to a genuine
   *reproduced / partially reproduced / not reproduced* verdict. Until then the NHB outcomes
   remain availability-based and should be labelled as such in the report.

## Invariant
No NHB verdict is labelled as a code re-execution unless the author's code was actually
downloaded, run, and the numbers independently verified. The current report does **not**
claim this for NHB.
