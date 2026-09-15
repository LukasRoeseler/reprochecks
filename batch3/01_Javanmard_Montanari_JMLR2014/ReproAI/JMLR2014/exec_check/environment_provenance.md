# Environment & provenance note — JMLR 2014 audit

Audit date: 2026-09-14. Engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT. Rules 2026.06.27.

## Host environment (audit host)
- OS: Windows (win32), working dir `C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\ReproAI Checks III\01_Javanmard_Montanari_JMLR2014\`
- Interpreter A (reimplementation): Python 3.8.10 (`C:\Users\lroesele.IVV5NET\AppData\Local\Programs\Python\Python38\python.exe`)
  - numpy 1.24.4, scipy 1.10.1 (scikit-learn NOT installed; LASSO implemented from scratch)
- Interpreter B (verification / optional): R 4.6.1 (`C:\Program Files\R\R-4.6.1\bin\Rscript.exe`), glmnet 5.0, quadprog 1.5.8
- Version-gap note: authors (2014) used R (glmnet era ~1.x; hdi); the audit host cannot install hdi, so competitor columns were not reproduced.

## Provenance chain
- Source of truth: `paper.pdf` + `paper_extracted.txt` (full text; never modified).
- Claim inventory: `exec_check/manuscript_claims.md` (28 claims C1–C28).
- Reimplementation: `exec_check/run_sim.py` → `exec_check/output/simulation_results.json`, `simulation_report.txt`.
- Reports: `reproai_reports/architecture_report.json`, `risk_register.json`, `advisory_plan.json`.
- Human-readable report: `REPROAI_REPORT.html`.

## Provenance of the paper's own artifacts
- JMLR article ships NO code, NO data, NO seed (JMLR does not require it).
- §1.1 cites an R implementation URL (stanford.edu/~montanar/sslasso/); not reachable/archived here → treated as unavailable.
- Riboflavin data cited to Buhlmann et al. (2014); not provided in the working directory.

## What the numbers depend on
- Reimplementation uses a FRESH random design realization (no author seed) → bit-for-bit identity not expected.
- CI machinery: debiased estimator Eq (5); M from QP (4) solved as a box-QP (n>p, feasible, |MΣ̂−I|_∞=µ verified); variance σ²[MΣ̂Mᵀ]_ii/n; half-width Φ⁻¹(1−α/2)σ̂√([MΣ̂Mᵀ]_ii/n).
- σ̂: alternating approximation to the Sun–Zhang scaled LASSO (df-corrected residual). Known deviation: strong-signal σ̂ ≈ √(1+θ0ᵀΣθ0) (e.g. 1.86 at b=0.5); drives length/coverage gaps.
