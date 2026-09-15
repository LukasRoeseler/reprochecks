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

1. Install/obtain **MATLAB or GNU Octave** (15 papers blocked without it).
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
