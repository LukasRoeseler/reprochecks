# Manuscript numeric-claims inventory

Paper: Flesia, L., Monaro, M., Mazza, C., Fietta, V., Colicino, E., Segatto, B., & Roma, P. (2020).
Predicting Perceived Stress Related to the Covid-19 Outbreak through Stable Psychological Traits and
Machine Learning Models. *J. Clin. Med.* 9(10), 3350. Preprint DOI `10.31234/osf.io/yb2h8`;
published DOI `10.3390/jcm9103350`. OSF project backing the preprint: node `e285f` `yb2h8_v1`.

Audit date: 2026-09-14. Methodology: static audit + independent R 4.6.1 and Python 3.8 recomputation
of every summary-statistic-based value that can be checked WITHOUT raw participant-level data or
analysis code (none were shipped; only the summary-level supplement PDF `jcm-09-03350-s001`).

Verdict key: `OK` = reproduces at reported precision (or is arithmetic that checks out);
`CHECK` = inconsistent / cannot be made to agree; `NA` = not independently recomputable (no raw
data / no code / stochastic without seed+code).

## A. Sample construction (section 2.2) — all reproduce
| ID | Claim | Value (paper) | Result |
|----|-------|---------------|--------|
| C1  | Volunteers / duplicates excluded / final N | 2072 → 19 excluded → 2053 | OK (2072−19=2053) |
| C2  | Sex composition | 1555 F + 480 M + 18 other = 2053 | OK |
| C3  | Mean age (SD), range | 35.81 (13.19), 18–83 | OK (matches suppl S1: 35.81/13.19) |
| C4  | Mean education (SD), range | 15.35 (3.43), 5–21 | CHECK (suppl S1 says 15.36/3.43 — 0.01-yr drift; P3) |
| C5  | High/low stress classes (excl. 18 other) | high n=393 + low n=1642 = 2035 | OK (2035 = 2053−18) |
| C6  | Train/test split, 20% test | train 1628 (314 high + 1314 low), test 407 (79 high + 328 low) | OK (1628+407=2035; 407 = 20.00% of 2035) |

## B. Section 3.1 — one-sample t-tests & Cohen's d (recomputed from reported M/SD + normative means)
| ID | Claim | Value (paper) | Recompute | Verdict |
|----|-------|---------------|-----------|---------|
| C7  | Whole-sample PSS-10 mean (SD) | 18.81 (6.25) | NA (no raw data) | ➖ |
| C8  | Males PSS-10 mean (SD) | 16.71 (6.91) | NA | ➖ |
| C9  | Females PSS-10 mean (SD) | 19.44 (6.79) | NA | ➖ |
| C10 | Male one-sample t, p, d, CI | t(479)=4.79, p<.001, d=0.22, CI(0.13,0.31) | t=4.788, d=0.219 | ✅ (≈) |
| C11 | Female one-sample t, p, d, CI | t(1554)=18.21, p<.001, d=0.46, CI(0.41,0.51) | t=18.236, d=0.462 | ≈ (rounding) |

## C. Section 3.2 — Regression 1 (sociodemographic), Table 1 — NOT recomputable
| ID | Claim | Value (paper) | Verdict |
|----|-------|---------------|---------|
| C12 | Model fit | R²=0.103, adj R²=0.101, F-change(1,2029)=12.009, F(5,2029)=46.65, RMSE=6.56 | ➖ (no raw data/code) |
| C13 | Table 1 coefficients (B, SE, t, p, CI): Intercept 25.342/0.987/25.665; Age −0.121; Gender(male) −2.406; Education −0.081; Household 0.453; Income −0.463 | | ➖ |

## D. Section 3.3 — Regression 2 (traits), Table 2 — NOT recomputable
| ID | Claim | Value (paper) | Verdict |
|----|-------|---------------|---------|
| C14 | Model fit | R²=0.356, adj R²=0.352, F-change(1,2022)=5.908, F(12,2022)=101.49, RMSE=5.57 | ➖ |
| C15 | Table 2 coefficients incl. Intercept 36.238, ES −0.959, COPEpos −2.357, Age −0.070, BSCS −0.127, Gender −1.883, COPEavoid 1.411, Household 0.406, Conscientiousness 0.276, COPESupp 0.519, Income −0.283, IntLOC −0.145 | | ➖ |
| C16 | ΔR² per predictor (0.221 ES … 0.002) | | ➖ |

## E. Section 3.4 — Machine learning (Table 3) — NOT recomputable from raw data
| ID | Claim | Value (paper) | Verdict |
|----|-------|---------------|---------|
| C17 | CFS-selected predictor set (7) | age, income, COPEavoid, COPEpos, BSCS, ES, agreeableness | ➖ (no code/data) |
| C18 | ML metrics, 4 algos × 2 classes (ROC, P, R, F) | see Table 3 | F-measure recomputed from P/R: 8/8 ✅ (internal); ROC/P/R ➖ |
| C19 | ROC range in test set | 0.70–0.78 | ≈ (range 0.697–0.782) |
| C20 | Best sensitivity (logistic, high class) | 0.759 | ➖ (match Table 3) |
| C21 | Abstract claim | "sensitivity greater than 76%" | CHECK — 0.759 is 75.9%, NOT >76%; Discussion says "approaching 0.759" (P3) |

## F. Supplement Table S2 — item-level independent-samples t-tests (means/SDs → t, d)
Two-sample pooled t (df = 393+1642−2 = 2033, matches reported df). d magnitude = |M_hi−M_lo|/SDpool.
| ID | Item | reported t / |d| | recomputed t / |d| | Verdict |
|----|------|------------|----------------|---------|
| C22a | 1 | 27.950 / 1.57 | 15.263 / 0.857 | ⚠ INCONSISTENT |
| C22b | 2 | 28.040 / 1.58 | 27.990 / 1.572 | ✅ |
| C22c | 3 | 29.480 / 1.66 | 29.353 / 1.648 | ✅ |
| C22d | 4 | 22.750 / 1.28 | 22.544 / 1.266 | ✅ |
| C22e | 5 | 19.820 / 1.11 | 19.715 / 1.107 | ✅ |
| C22f | 6 | 18.060 / 1.01 | 18.100 / 1.016 | ✅ |
| C22g | 7 | 18.710 / 1.05 | 18.595 / 1.044 | ✅ |
| C22h | 8 | 23.200 / 1.30 | 23.286 / 1.308 | ✅ |
| C22i | 9 | 23.958 / 1.35 | 24.086 / 1.353 | ✅ |
| C22j | 10 | 33.972 / 1.91 | 33.996 / 1.909 | ✅ |
Reported t and d are mutually consistent for ALL 10 items (t = |d|·√(n1·n2/(n1+n2)), √ratio=17.807);
only Item 1's reported group MEANS are inconsistent with its (mutually consistent) t/d pair.

## G. Supplement Table S1 — descriptives & correlations
| ID | Claim | Verdict |
|----|-------|---------|
| C23 | Descriptive stats, all / low / high (means, SDs, %) | NA cross-source; internally plausible; age/education checked in C3/C4 |
| C24 | Correlation matrices (r, p, 95% CI) vs PSS-10 | CIs approx. consistent under Fisher-z (all within ~0.02); cell-level p-values ➖ (extraction alignment + no raw data) |

## H. Supplementary-materials data claim
| ID | Claim | Verdict |
|----|-------|---------|
| C25 | Paper §2.1/§2.2 "Data are provided in the Supplementary Materials" and Discussion "open access data reported in the Supplementary Materials" | ⚠ Only summary tables (S1–S4) are shipped; no raw participant data, no raw item responses, no JASP/WEKA analyses, no code on OSF node e285f (public, zero children, 1 file = supplement PDF). ➖ for all raw-data-dependent headline stats. |

Counts: 25 claim IDs (C1–C25), of which C22 covers 10 sub-claims (C22a–j), C13/C15 cover multiple
coefficients. Total numeric sub-claims checked: **46** (26 fully recomputable arithmetic/summary checks;
20 regression/ML/raw-data-dependent checks marked not independently recomputable). By verdict:
**OK/≈ 20; ⚠ 3 (C4, C21, C22a, C25 — C25 is ⚠-availability); ➖ ~22.**
