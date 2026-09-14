# ReproAI Per-Paper Audit Brief (Meta-Psychology Vol 4, 2020)

Follow this brief TOGETHER WITH the standing discipline in `C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\REPRO_STANDARDS.md` and the house-style HTML example at `C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\R2 Provenau\REPROAI_REPORT.html`.

## Your job
Produce a full ReproAI reproducibility audit for ONE empirical article and save everything under its paper folder.

## Working directory
`C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)\<PAPERFOLDER>\`
- `paper.pdf` and `paper_extracted.txt` already exist (extracted full text of the article — read it for the claim inventory).
- Do NOT modify `paper.pdf` or `paper_extracted.txt`.

## Required deliverables (save inside the paper folder, in a subfolder `ReproAI/<paper>/`):
1. `REPROAI_REPORT.html` — the full audit, in the Provenau house style:
   - Header: engine (record "anomalyco/opencode — DeepSeek-V4-Flash"), rules (REPRO_STANDARDS.md date), audit date (today is 2026-09-10), package identifier, mode (static / live / reimplementation).
   - Bottom line: severity table P0/P1/P2/P3 + one-paragraph verdict.
   - Independent reimplementation table.
   - Numerical reproducibility tables (Quantity | Manuscript | Reimplementation | Verdict) using ✅/≈/⚠/➖ legend.
   - Findings grouped P0→P3, ADV-001 style, each with evidence (exact numbers + source) and a fix.
   - "What this audit does not guarantee" section.
   - Artifacts on disk table.
2. Supporting artifacts: R/Python reimplementation scripts, output CSVs/logs, `reproai_reports/` JSON files (architecture_report.json, risk_register.json, advisory_plan.json), and a claims inventory file.
3. Report your headline results back in your final message (NOT visible to the user): number of findings by severity, count of claims checked, what reproduced vs not, and the verdict sentence.

## How to do it (compressed ReproAI discipline)
- §1 CLAIM INVENTORY FIRST: enumerate every numeric claim in the paper (descriptives, each test + its effect size, each p, each percentage, sample sizes, every in-text number and its page/section). Number them C1..Cn. Get it complete before checking.
- §2 TRACE TO PRIMITIVE SOURCE: download the linked OSF/data/code (OSF API: `https://api.osf.io/v2/files/` or the provided OSF project page). Prefer raw data over summary files. State conventions (effect size formula, sphericity correction, rounding threshold).
- Check each claim individually: ✅ identical / ≈ close & explicable / ⚠ discrepant / ➖ not independently checkable (with concrete reason).
- §5 INDEPENDENT RECOMPUTE: re-run headline stats in R (R 4.6.1 is at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`) or Python (3.8). Prefer running the author's own code on a copy of the data; if that fails, reimplement from the raw source.
- §3 CONVENTIONS: match the paper's actual formula before calling anything a discrepancy (check partial-vs-classical η², sphericity, meta-analysis model, etc.).
- Live execution (§6) only if the exact tool is available; otherwise say so and do an independent reimplementation (do NOT claim a tool you didn't run).
- If statistical results are seed-sensitive (simulations, MCMC), run multiple times / fixed seed and quantify drift; note this.
- Simulated-data papers: if "Open data: Not applicable" and only code/sim is available, REIMPLEMENT the simulation from the paper's described parameters and report agreement. If that is infeasible, mark claims ➖ with the reason.
- §7 beyond numbers: check prose-vs-table consistency, directional claims, impossible arithmetic, denominators, internal consistency.
- §8 self-audit before finishing: no recomputed value may contradict your own verdict; every ⚠ has a cause+fix; every ➖ has a reason; severity justified by impact on primary results.
- §9 severity rubric: P0 blocker / P1 high (primary stat not reproducible) / P2 medium (secondary/prose-vs-table) / P3 low (hygiene).
- §11 provenance/environment: record OSF snapshot date, tool versions.

## Environment notes
- Windows / PowerShell 5.1. Do NOT use `&&`. Use `;` or `if ($?)`. Use call operator `& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" script.R` for R.
- Python 3.8 at `python` with pandas, numpy, scipy, openpyxl, pdfplumber, matplotlib (3.7.5).
- For OSF bulk download use the OSF API or `osfclient` (pip install osfclient if needed) or direct file GUID URLs.
- Keep all your work on COPIES inside `<paper>/ReproAI/<paper>/` — never modify originals.

Return in your FINAL message only: paper ID/name, empiricism confirmation, claims checked (count), findings by severity (P0/P1/P2/P3 counts), headline reproducible result, verdict paragraph, and the path to the report.
