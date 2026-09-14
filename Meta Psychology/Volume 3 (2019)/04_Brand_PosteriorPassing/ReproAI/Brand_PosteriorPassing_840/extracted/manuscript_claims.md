# Claim Inventory — Brand et al. (2019) MP.2017.840 "Cumulative Science via Bayesian Posterior Passing"

Paper: Brand, C. O., Ounsley, J. P., van der Post, D. J., & Morgan, T. J. H. (2019). Cumulative Science via Bayesian Posterior Passing: An introduction. Meta-Psychology, 3, MP.2017.840. https://doi.org/10.15626/MP.2017.840
OSF (data + code): https://doi.org/10.17605/OSF.IO/C4WN8 | GitHub: thomasmorgan/posterior-passing
Type: Monte-Carlo + MCMC simulation study comparing 4 analysis methods (ANOVA, GLMM, BGLMM, PP) plus a pooled "meta-BGLMM".
RE-AUDIT date: 2026-09-14. Engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT. Rules: REPRO_STANDARDS.md 2026.06.27.
Legend: ✅ identical/confirmed · ≈ close, behaviourally explicable · ➖ not independently checkable (reason).

## Simulation parameters (C1–C14)
| ID | Claim | Location | Check |
|----|-------|----------|-------|
| C1 | One million (1,000,000) potential participants | p7 "Data Collection" | ✅ `n_people=1000000` (main.R:41); DGM reproduced |
| C2 | 60 sequential experiments per repeat | p7 | ✅ `n_experiments_per_repeat=60` (main.R:38) |
| C3 | 80 participants per experiment | p7 | ✅ `n_participants_per_experiment=80` (main.R:39) |
| C4 | 20 participants per sex×condition cell | p7 | ✅ sex 40/40, condition 40/40 (simulation.R:24,32-33) |
| C5 | 25 binary-choice trials per participant | p7 | ✅ `n_trials_per_participant=25` (main.R:40) |
| C6 | 5 effect sizes e = 0,0.5,1,1.5,2 (log-odds interaction) | p7 | ✅ `b_sex_conds=c(0,0.5,1,1.5,2)` (main.R:26) |
| C7 | 5 between-individual variance levels 0,0.25,0.5,0.75,1 | p7 | ✅ `var_bases=c(0,0.25,0.5,0.75,1)` (main.R:27) |
| C8 | e raises avg success prob 0.5 → 0.5,0.62,0.73,0.82,0.88 | p7 | ✅ logistic(e): 0.5000,0.6225,0.7311,0.8176,0.8808 (R + Python) |
| C9 | 20 repeat simulations per (e×var) | p7 | ✅ `n_repeats=20` (main.R:37) |
| C10 | 4 methods: ANOVA, GLMM, BGLMM (JAGS), PP | p6 | ✅ main.R flags TRUE |
| C11 | Plus single "meta BGLMM" over all 60 datasets | p7 | ✅ `do_mega_bglmm=TRUE` |
| C12 | Minimally informative priors normal(0, precision 0.01) | p8 | ✅ pp_u=0, pp_prec=0.01 (analyses.R:132-133); JAGS model |
| C13 | True mean perf exactly 0; within-sex variation equal (doppelganger) | p7 | ✅ d_base=c(d,-d,d,-d) (simulation.R:6-7) |
| C14 | p = logistic(perf + e·condition·sex) DGM | p7 | ✅ lp = b_base+d_base+…+e·sex·cond (simulation.R:39) |

## Five metrics (C15–C19)
| ID | Claim | Check |
|----|-------|-------|
| C15 | Metric 1: average point estimate | ✅ meta_*_estimate_* |
| C16 | Metric 2: true positive rate (CI/credible excl. 0) | ✅ meta_*_positive_rate_* |
| C17 | Metric 3: false positive rate (e=0 only) | ✅ |
| C18 | Metric 4: average 95% CI/credible width | ✅ meta_*_uncertainty_* |
| C19 | Metric 5: average |est − true| (error) | ✅ |

## Headline quantitative results (C20–C42)
| ID | Claim | Location | Check |
|----|-------|----------|-------|
| C20 | e=2 → +0.38 P(correct) (Fig 2 caption) | p8 | ✅ 0.8808−0.5000=0.3808 (R, Python) |
| C21 | e=0, N=6000: ANOVA 304 FP (5.1%) | p10 | ✅ EXACT from shipped (304, 5.067%); from-scratch R 5.33%, Python 5.42% (≈) |
| C22 | GLMM 341 FP (5.7%) | p10 | ✅ EXACT from shipped (341, 5.683%); from-scratch R 5.75% (≈) |
| C23 | BGLMM 304 FP (5.1%) | p10 | ✅ EXACT from shipped (304, 5.067%) |
| C24 | PP 2 FP over 100 e=0 sims (2%) | p10,12 | ✅ EXACT (2, 2.0%) |
| C25 | Meta BGLMM 1 FP (1%) | p10 | ✅ EXACT (1, 1.0%) |
| C26 | N=6000 datasets in e=0 FP analysis | p10 | ✅ 5 var × 20 rep × 60 expt = 6000 |
| C27 | ANOVA underestimates effect as var increases | p9,11 | ✅ shipped e=2 est 0.381→0.345; from-scratch R 0.385→0.335, Python 0.387→0.336 |
| C28 | TPR increases with e (all methods) | p9 | ✅ monotone (shipped + from-scratch) |
| C29 | For ANOVA/GLMM/BGLMM, TPR decreases with var | p9 | ✅ (shipped e=1 ANOVA 1.000→0.494; from-scratch 1.000→0.500) |
| C30 | PP: no such effect; positive whenever e≠0 | p9 | ✅ shipped PP=1.000 at e>0; from-scratch PP final CI [0.60,1.01] excludes 0 |
| C31 | Uncertainty ↓ with e, ↑ with var (all) | p10 | ✅ direction reproduced |
| C32 | ANOVA more sensitive to var than e | p10 | ✅ |
| C33 | GLMM/BGLMM confident when e high or var low; uncertain when e small/var high | p11 | ✅ |
| C34 | PP & combined BGLMM only minimally sensitive; high confidence | p11 | ✅ PP width 0.097–0.250; meta 0.160 |
| C35 | Average error low except ANOVA | p11 | ✅ |
| C36 | ANOVA underestimates when true avg high AND var high (Fig 6) | p11 | ✅ ANOVA e=2 var=1 est ~0.34 (delta −1.65) |
| C37 | PP performs almost identically to meta BGLMM | p8,11,13 | ✅ shipped cor(PP,mega)=0.9999, mean|diff|=0.0097; from-scratch: PP-final 0.815 vs pooled glm 0.895/glmer 1.053 (behavioral agreement) |
| C38 | BGLMM ≈ GLMM (minimally informative priors) | p13 | ✅ shipped mean|glmm−bglmm|=0.0055; from-scratch BGLMM beta4 median 0.289 vs GLMM fixef 0.247 (exp1) |
| C39 | PP converges within 10–15 analyses | p13 | ≈ from-scratch PP stabilizes by ~expt 5–15 (median 0.17→0.68 by expt 5, CI narrows to [0.60,1.01] by expt 20); exact "10–15" not quantified in shipped summary |
| C40 | "Only 2% of simulations produced a false-positive result" (PP) | p12 | ✅ 2/100=2.0% (C24) |
| C41 | "meta BGLMM almost identical to PP" | p13 | ✅ = C37 |
| C42 | 7 stereotype-threat meta-analyses cited (background) | p2 | ➖ literature claim, outside simulation; authors' references list self-consistent |

## Reproducibility notes (RE-AUDIT)
- Shipped `Results/meta_results_18_09_16.txt` (500 rows × 140 cols) reproduces every load-bearing figure EXACTLY (C21–C30, C34–C38), an internal-consistency check (author output ↔ paper).
- INDEPENDENT from-scratch reimplementation (this audit, R 4.6.1, fixed seed 20260914) regenerated the DGM + ANOVA + GLMM over the full 5×5 grid (6000 experiments × 2 methods) and confirmed method-level behaviour: ANOVA FP 5.33% / GLMM FP 5.75% (paper ~5.1%/5.7%), ANOVA underestimation (prob-scale ~0.34–0.39 vs log-odds ~2), unbiased GLMM recovery, TPR patterns. Exact per-count match is NOT expected (no recorded seed) but rates/patterns agree.
- INDEPENDENT Bayesian reimplementation (custom Polya-Gamma Gibbs, base R) verified BGLMM ≈ GLMM (0.289 vs 0.247), PP convergence toward the true effect within ~5–15 analyses (C39/C30), and PP-final ≈ pooled analysis (0.815 vs 0.895/1.053).
- Python 3.8 cross-check (numpy/scipy/statsmodels) independently confirmed the e→P mapping and ANOVA underestimation and gave an ANOVA FP rate of 5.42% at e=0.
- JAGS is not installed on the audit host, and Stan/brms cannot compile (no Rtools/make), so the author's exact JAGS chains were not re-run; the simulated results are verified via (a) exact shipped-table reproduction and (b) independent reimplementation of the same models.
- Limitations recorded as ADV-001..ADV-004 (see risk_register.json).
