# Claims Inventory — Rousselet & Wilcox (2020) Meta-Psychology MP.2019.1630
## "Reaction Times and other Skewed Distributions: Problems with the Mean and the Median"
### Re-audit (2026-09-14) — DeepSeek V4 Flash via uniGPT / anomalyco opencode

Verdict legend: ✅ identical at reported precision · ≈ close (Monte-Carlo / convention, methodologically explicable) · ⚠ discrepant · ➖ not independently checkable (with reason).

## TABLE 1 — 12 ex-Gaussian distributions: population mean/median/skewness
Medians/skewness (mean = µ+τ = 600 for all). Verified two ways: (a) author's committed `miller_exg_param.RData`, (b) independent R reimplementation of `retimes::rexgauss` (rnorm+rexp) with set.seed(4), n=1,000,000.

| ID | µ | σ | τ | manuscript median | reimpl | verdict | manuscript skew | reimpl | verdict |
|----|----|----|----|----|----|----|----|----|----|
| C1 | 300|20|300 | 509 | 509 | ✅ | 92 | 92 | ✅ |
| C2 | 300|50|300 | 512 | 512 | ✅ | 88 | 88 | ✅ |
| C3 | 350|20|250 | 524 | 524 | ✅ | 76 | 76 | ✅ |
| C4 | 350|50|250 | 528 | 528 | ✅ | 72 | 72 | ✅ |
| C5 | 400|20|200 | 540 | 540 | ✅ | 60 | 60 | ✅ |
| C6 | 400|50|200 | 544 | 544 | ✅ | 55 | 55 | ✅ |
| C7 | 450|20|150 | 555 | 555 | ✅ | 45 | 45 | ✅ |
| C8 | 450|50|150 | 562 | 562 | ✅ | 38 | 38 | ✅ |
| C9 | 500|20|100 | 572 | 572 | ✅ | 29 | 29 | ✅ |
| C10| 500|50|100 | 579 | 579 | ✅ | 21 | 21 | ✅ |
| C11| 550|20|50  | 588 | 588 | ✅ | 12 | 12 | ✅ |
| C12| 550|50|50  | 594 | 594 | ✅ | 6  | 6  | ✅ |
(C13–C24 = the 12 skewness values above; ✅.)

## TABLE 2 — median mean-bias (ms) for 12 distributions × 10 sample sizes (n = 4…100)
120 integer cells. Three independent evaluations:
- Author's committed `sim_miller1988.RData` + notebook formula → paper: **73/120 exact, 118/120 within ±2, max dev 3** (⚠).
- Fresh R reimplementation (set.seed(21), 10,000 sims) → paper: **64/120 exact, 117/120 within ±2, max dev 3**.
- Independent Python (numpy, own seed) → paper: **68/120 exact, 117/120 within ±2, max dev 3**.

| ID | A | verdict |
|----|----|----|
| C25 | Table 2 printed integers (120 cells) | ⚠ — Monte-Carlo table; shipped reproducibility data does NOT regenerate the printed integers exactly (73/120); all 120 agree within ±3 ms (118/120 within ±2). Qualitative bias pattern (bias ↑ with skewness, ↓ with n) fully reproduced. |

## §2 Bias, Figure 1 & bootstrap bias-correction illustrations
| ID | quantity | manuscript | reimpl | verdict |
|----|----|----|----|----|
| C26 | population median (Fig 1 distribution) | 508.7 | 508.7 | ✅ |
| C27 | mean bias, n=10, 1000 samples | 2.5 ms | 2.5 ms | ✅ |
| C28 | median bias, n=10, 1000 samples | 15.1 ms | 15.4 ms | ≈ (MC) |
| C29 | median bias, n=100, 1000 samples | 0.7 ms | 0.9 ms | ≈ (MC) |
| C30 | single sample median | 535.6 ms | not byte-reproducible | ➖ (see ADV-002) |
| C31 | bootstrap mean 722.6 / bias 187 / BC 348.6 | 722.6 / 187 / 348.6 | not byte-reproducible | ➖ (see ADV-002) |
| C32 | 100 experiments avg 515.1 / 498.8 | 515.1 / 498.8 | not byte-reproducible | ➖ (see ADV-002) |
| C33 | 1000 experiments avg 522.1 / 508.6 | 522.1 / 508.6 | not byte-reproducible | ➖ (see ADV-002) |

## §3 Two-group bias (unequal n)
| ID | quantity | manuscript | reimpl | verdict |
|----|----|----|----|----|
| C34 | median max bias n=10 after bootstrap correction | 1.79 ms | 1.79 ms | ✅ |
| C35 | mean max bias n=10 | 0.88 ms | 0.88 ms | ✅ |

## §4 False/true positives (g&h and hierarchical means/medians)
| ID | quantity | manuscript | reimpl | verdict |
|----|----|----|----|----|
| C36 | FP for group means-of-individual-medians, unequal n, very skewed, 200 participants | ">50% of the time" | max 60.6% | ✅ (from committed `sim_gp_fp2.RData`) |
(Other §4 power/FP curves are figure-qualitative; no hard tabulated numbers in text — not separately tabulated.) | ➖ (see note) |

## §5 FLP real-data application (raw `french_lexicon_project_rt_data.RData`)
| ID | quantity | manuscript | reimpl | verdict |
|----|----|----|----|----|
| C37 | N participants | 959 | 959 | ✅ |
| C38 | trials per participant-condition | 996–1001 | 996–1001 | ✅ |
| C39 | % faster in Word (median) | 96.4% | 96.4% | ✅ |
| C40 | % faster in Word (mean) | 94.8% | 94.8% | ✅ |
| C41 | % larger parametric skewness in Word | 80% | 80.1% | ✅ |
| C42 | % larger non-parametric skewness (mean−median) in Word | 70% | 69.8% | ✅ |
| C43 | MAD of difference distributions | mean 57 / median 54 | 57 / 54 | ✅ |
| C44 | median-difference mean bias, smallest n | −10.9 ms | −10.9 ms | ✅ |
| C45 | 80% HDI of bias, smallest n | [−17.1, −2.6] | [−17.1, −2.6] | ✅ |
| C46 | bias at n=20 / n=60 | −4.8 / −1 ms | −4.8 / −1 ms | ✅ |
| C47 | median-(median) bias n=10 / n=20 | −1.9 / −0.3 ms | −1.9 / −0.3 ms | ✅ |
| C48 | mean-bias of mean (≈0) / median-bias of mean | ≈0 / 6.9 ms | −0.1 / 6.9 ms | ✅ |
| C49 | participants for 70% within 10 ms | 59 (mean) / 56 (median) | 59 / 56 | ✅ |
| C50 | participants for 90% within 20 ms | 37 / 38 | 37 / 38 | ✅ |
| C51 | deciles all-positive / all-negative | 83.2% / 1.4% | 83.2% / 1.4% | ✅ |
| C52 | Spearman monotonic increase / decrease | 52.9% / 14.9% | 52.9% / 14.9% | ✅ |
| C53 | 20%-trimmed-mean per decile | 59 66 72 77 **82** 86 89 91 89 | 59 66 72 77 **81** 86 89 91 89 | ≈ (5th decile 81 vs 82; ADV-003) |

## Cited background values (not independently checkable)
| ID | quantity | manuscript | verdict |
|----|----|----|----|
| C54 | Miller (1988) citation count | 187 (18 Apr 2019) | ➖ (Google Scholar live count) |
| C55 | Whelan (2008) citation count | 438 | ➖ (Google Scholar live count) |
| C56 | Ratcliff (1993) citation count | 1930 (24 Apr 2019) | ➖ (Google Scholar live count) |

## Totals
Total claims listed: 56 · ✅ 45 · ≈ 3 · ⚠ 1 · ➖ 7
