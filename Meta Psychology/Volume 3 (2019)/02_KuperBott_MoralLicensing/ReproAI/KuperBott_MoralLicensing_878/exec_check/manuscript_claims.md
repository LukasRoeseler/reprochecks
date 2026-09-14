# ReproAI Claim Inventory — RE-AUDIT
Paper: Kuper, N., & Bott, A. (2019). Has the evidence for moral licensing been inflated by
publication bias? *Meta-Psychology*, 3, MP.2018.878. https://doi.org/10.17605/MP.2018.878
OSF project: https://doi.org/10.17605/OSF.IO/H2RX7
Audit date: 2026-09-14 · Engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT
Rules: REPRO_STANDARDS.md (2026.06.27)

Legend: ✅ = reproduced at reported precision · ≈ = close/explainable · ⚠ = discrepant ·
➖ = not independently checkable (concrete reason given).

## A. Dataset comparison / method (pp. 4–6, Tables 1 & 2)
| ID | Claim | Value | Finding | Verdict |
|----|-------|-------|---------|---------|
| C1 | % effect sizes identical between the two meta-analyses | 93% (k=85) | full cross-mapping of the two original datasets not shipped | ➖ reason: requires a study-to-study map not archived; dat_old_s/b both present but no mapping script |
| C2 | ES coded differently identified | 6 | same | ➖ same reason |
| C3 | % sample sizes coded identically | 93% | same | ➖ same reason |
| C4 | % of studies with coded-N difference < 2 | 95% | same | ➖ same reason |
| C5 | studies where N differed | 6 | same | ➖ same reason |
| C6 | modified datasets: 100% ES & 100% N identical | 100%/100% | corrected files shipped (dat_new_*) but no diff script; my k=102→raw trace consistent with corrections | ≈ partial |
| C7 | excluded 3 studies / 7 ES (not licensing) | 3 studies, 7 ES | Effron(2014) 2 + Kouchaki(2011) 4 + Jordan(2011) s1 (1, already absent) | ✅ consistent |
| C8 | after independence was ensured, k=76 | 76 | my faithful reconstruction from dat_new_s: k=76 (NOA=40, EUR=30, SEA=1, NA=5) | ✅ (R and Python agree) |

## B. Headline results (Table 3 / Results, pp. 8–10)
| ID | Quantity | Manuscript | My recomputation (k=76 recon) | Verdict |
|----|-----------|-----------|------------------------------|---------|
| C9 | Naïve RE, entire dataset | d=.27 [0.19;0.35] Z=6.57 p<.001 | d=.266 [0.181;0.350] Z=6.17 p<.001 | ⚠ (d/CI reproduce; Z off by .40; dataset not archived) |
| C10 | Heterogeneity | I²=.26, Q(75)=175.77, p<.001 | recon I²=62%, Q=187.8; **paper's own Q implies I²=57%, not 26%** | ⚠ P1 internal contradiction |
| C11 | k | 76 | 76 | ✅ |
| C12 | PET-PEESE slope (entire) | b=1.36 t(74)=2.73 p=.008 | b=1.24 t=2.43 p=.018 | ⚠ (direction ✅) |
| C13 | PET-PEESE intercept (entire) | d=−.05 [−.26;.16] t(74)=−.46 p=.64 | d=−.03 t=−.27 p=.79 | ≈ |
| C14 | 3-PSM corrected d (entire) | d=.18 [.06;.29] Z=3.11 p=.002 | d=.266, X²(1)=5.31 p=.021 | ⚠ |
| C15 | 3-PSM fit improvement (entire) | χ²(1)=3.42 p=.065 | recon 5.31 p=.021; shipped k=102 11.67 p=.0006 | ⚠ |

## C. Culture subgroups (Table 3)
| ID | Group | Manuscript | My recomputation | Verdict |
|----|-------|-----------|------------------|---------|
| C16 | NOA k=40 naïve | d=.38 [.27;.48] Z=7.01 | d=.368 [.261;.476] Z=6.74 | ≈ |
| C17 | NOA PET | d=−.13 [−.37;.12] t(38)=−1.07 p=.29; b=2.12 p<.001 | int −.104; slope 1.97 p=.001 | ≈ |
| C18 | NOA 3-PSM | d=.31 [.15;.47] Z=3.76; χ²(1)=1.02 p=.31 | d=.368, X²=1.51 p=.219 | ≈ |
| C19 | EUR k=30 naïve | d=.21 [.09;.32] Z=3.45 | d=.213 [.077;.348] Z=3.06 | ≈ |
| C20 | EUR PET | d=.10 [−.28;.48] t(28)=.54 p=.59; b=.49 p=.58 | int .10; slope .478 | ✅ |
| C21 | EUR 3-PSM | d=.11 [−.03;.24] Z=1.53; χ²(1)=2.40 p=.12 | d=.212, X²=3.59 p=.058 | ⚠ |
| C22 | SEA k=1 naïve | d=−.37 [−.75;.004] Z=−1.94 p=.052 | d=−.372 [−.744;.000] Z=−1.96 p=.050 | ✅ (excellent) |

## D. Moderators (prose, pp. 7–10)
| ID | Claim | Manuscript | My recomputation | Verdict |
|----|-------|-----------|------------------|---------|
| C23 | culture NA>SEA (as S&S, uncorrected) | β=.71 Z=2.34 p=.019 | k102 region model NOA=0.876 (model-dependent) | ≈ |
| C24 | corrected EUR vs SEA ns | β=.54 Z=1.76 p=.078 | β=.540 Z=1.66 p=.096 | ✅ β exact |
| C25 | corrected NA vs EUR | β=.17 Z=2.17 p=.030 | NOA−EUR≈.148 | ≈ |
| C26 | comparison (corrected) | β=−.19 Z=−1.97 p=.049 | β=−.185 Z=−1.93 p=.054 | ≈ (p .049 vs .054) |
| C27 | comparison (uncorrected) | β=−.42 Z=−3.72 p<.001 | β=−.421 Z=−3.72 p<.001 (dat_old_s k=106) | ✅ EXACT |
| C28 | two d>3 ES in immoral cond. (uncorrected) | two ES | Mazar & Zhong yi=3.19, 3.55 present in dat_old_s | ✅ |
| C29 | meta-reg +se effect | β=1.20 Z=2.00 p=.045 | β=1.05 Z=1.69 p=.091 | ⚠ |
| C30 | PET+mods NA vs SEA | β=.66 Z=2.26 p=.024 | NOA .644 Z=2.02 p=.043 | ≈ |
| C31 | PET+mods NA vs EUR | β=.15 Z=1.98 p=.048 | NOA−EUR≈.144 | ≈ |
| C32 | 3-PSM+mods comparison | β=−.14 Z=−1.49 p=.14 | weightr-with-mods not archived to reproduce exactly | ≈/➖ |

## E. Power, abstract, recommendations
| ID | Claim | Manuscript | Finding | Verdict |
|----|-------|-----------|---------|---------|
| C33 | n required, d=.18, 80%, one-tailed | n=766 | 2·(z₍.05₎+z₍.8₎)²/0.18² = 764 | ≈ (764 vs 766) |
| C34 | "PET d=−0.05 p=.64 and 3-PSM d=0.18 p=.002" | abstract | consistent with Table 3 (self-consistent) | ✅ |
| C35 | overlap region d=0.06–0.16 for both methods | discussion | PET CI[−.26;.16] ∩ 3PSM CI[.06;.29]=[.06;.16] | ✅ |
| C36 | prior MA estimates d=.31/.32; fail-safe N=4531; n=801/1274/3134 | background | cited from elsewhere; no raw source in archive | ➖ not from archive |

## F. Open-code / appendix
| ID | Claim | Manuscript | Finding | Verdict |
|----|-------|-----------|---------|---------|
| C37 | k=76 aggregation/exclusion code & dataset shipped | implied | NOT in archive; shipped code runs only on k=102 | ⚠ P1 |
| C38 | "analysis reproduced the results" badge (Carlsson) | p.14 | shipped code reproduces k=102, NOT the k=76 tables | ⚠ P1 |
| C39 | Appendix Fig A1 3-PSM averaging simulation (bias > d=.10) | appendix | simulation code not shipped | ➖ |
| C40 | Fig 3 selection-threshold exploration (d≈0 for p=.05–.15; fit p<.001; Bonferroni n=981) | exploratory | code not shipped | ➖ |
| C41 | Funnel plots Fig 1 & 2 asymmetry | visual | no k=76 funnel data shipped | ➖ |

## Rollup
Verified/exact (✅): C7, C8, C11, C20, C22, C24(β), C27, C28, C34, C35.
Approximate (≈): C6, C13, C16–C19, C23, C25, C26, C30, C31, C33.
Discrepant (⚠, with P1/P2 findings): C9, C10, C12, C14, C15, C21, C29, C37, C38.
Not checkable (➖): C1–C5, C32, C36, C39, C40, C41.

Headline verdict: the sample construction (k=76; NOA=40/EUR=30/SEA=1) and the overall effect d≈0.27
(CI ≈[0.18;0.35]) ARE recoverable from a faithful re-derivation of the archived raw data, and the
uncorrected comparison moderator (β=−.42) and SEA value (−.372) reproduce exactly/well. But the
exact published k=76 statistics (Z=6.57, I²=.26, 3-PSM/PET precise values) are NOT reproducible
from the archive as shipped — the k=76 dataset and aggregation code were never shipped, the shipped
code analyses a different k=102 set, and I²=.26 is internally inconsistent with the paper's own
Q(75)=175.77 (⇒I²=57%).
