# Manuscript numeric claims — Forster & Neugebauer (2024)

**Article:** Forster, A. G., & Neugebauer, M. (2024). "Factorial Survey Experiments to Predict Real-World
Behavior: A Cautionary Tale from Hiring Studies." *Sociological Science* 11, 886–906. DOI 10.15195/v11.a32.

**Auditor convention (declared up front):**
- Effect measure: linear-probability-model coefficients (OLS). FE standard errors are HC1-robust
  (`vce(robust)` in Stata); FS standard errors are cluster-robust at the employer (ID) level
  (`vce(cluster ID)`), both reimplemented with the `sandwich` package (HC1 / vcovCL).
- Percentiles p33/p66 use Stata's `egen pctile` default ("altdef", linear interpolation, index
  p·(n+1)) = R `quantile(..., type=6)`. Version "validation_fe" / "validation_fs" data, July 2024.
- ✅ identical at reported precision · ≈ close/methodologically explicable · ⚠ discrepant · ➖ not
  independently checkable (with reason).

The shipped replication package also reproduces these claims in Stata (code `01_code/*.do`); a
byte-for-byte Stata re-run was NOT executed because Stata is not installed on the audit host. All
claims below were independently regenerated in **R 4.6.1** directly from the shipped `.dta` files.

## Sample / data structure
| ID | Claim | Manuscript (page) | Reimplementation | Verdict |
|----|-------|-------------------|------------------|---------|
| C1 | N field experiment = 3,002 applications | abstract, p.891 | 3,002 rows | ✅ |
| C2 | N FS respondents who completed survey = 480 | p.892 | 480 distinct IDs | ✅ |
| C3 | FS response rate = 16% | p.892 | 480/3002 = 0.1599 | ✅ |
| C4 | 8×480 = 3,840 vignette ratings | p.892 | 3,840 rows; 8 per respondent | ✅ |
| C5 | FE mean invitation probability = 0.54, SD 0.50 | Table 2 | 0.5410, SD 0.4984 | ✅ |
| C6 | FS mean invitation probability = 0.59, SD 0.49 | Table 2 | 0.5932, SD 0.4913 | ✅ |
| C7 | FE occupational-field N: 655/398/1261/688 | Table 2 | 655/398/1261/688 | ✅ |
| C8 | FE occupational-field proportions: 0.22/0.13/0.42/0.23 | Table 2 | 0.218/0.133/0.420/0.229 | ✅ |
| C9 | FS occupational-field N: 512/560/1944/824 | Table 2 | 512/560/1944/824 | ✅ |
| C10 | FS occupational-field proportions: 0.13/0.15/0.50/0.22 | Table 2 | 0.133/0.146/0.506/0.215 | ⚠ see ADV-001 |
| C11 | FS hiring responsibility: alone 632 (0.16), resp.+colleagues 2,984 (0.78), colleagues 224 (0.06) | Table 2 | 632/2984/224 | ✅ |
| C12 | Text: "94% solely or jointly responsible … 6% colleagues" | p.895 | 0.16+0.78=0.94; 0.06 | ✅ |
| C13 | SDB scale standardized: mean 0, SD 1, N 3,840 | Table 2 | ~0 (1), N 3840 | ✅ |
| C14 | Attitudes-to-surveys scale standardized: mean 0, SD 1, N 3,840 | Table 2 | ~0 (1), N 3840 | ✅ |
| C15 | Avg processing time per vignette = 30.78 (SD 11.63), N 3,840 | Table 2 | 30.7848 (11.6254) | ✅ |

## H1 — topic sensitivity
| ID | Claim | Manuscript | Reimplementation | Verdict |
|----|-------|-----------|------------------|---------|
| C16 | FE ethnic effect = −0.07 (7 pp), significant | p.896 / Fig 3 | −0.0703 (HC1) | ✅ |
| C17 | FS ethnic effect = −0.001, n.s. | p.896 / Fig 3 | −0.0012 (cluster) | ✅ |
| C18 | Ethnicity disparity (FE−FS interaction) b=0.070, SE=0.023, sig @0.01 | p.897 | b=0.0697, SE=0.0226 | ✅ |
| C19 | FE education (dropout vs Abitur) effect = +2.8 pp, n.s. | p.897 / Fig 3 | +0.0278 | ✅ |
| C20 | FS education (Abitur+college vs Abitur) effect = −0.05 (5 pp), significant | p.897 / Fig 3 | −0.0502 | ✅ |
| C21 | Education disparity interaction b=−0.080, SE=0.026, sig @0.01 | p.897 | b=−0.0801, SE=0.0259 | ✅ |
| C22 | FS intermediate-HS disadvantage = 12.2 pp | p.897 | 1-vs-2 coef −0.1216 | ✅ |

## H2 — social desirability
| ID | Claim | Manuscript | Reimplementation | Verdict |
|----|-------|-----------|------------------|---------|
| C23 | SDB cut-offs p33/p66 = −0.29 / 0.53 | p.895 | −0.289 / 0.528 | ✅ |
| C24 | SDB group N: low/intermed/high = 1600/1272/968 | Fig 4 note | 1600/1272/968 | ✅ |
| C25 | In all 3 SDB groups the FS ethnic effect is insignificant (~0) | p.898 | b: −0.0015 / +0.0079 / −0.0055 (all n.s.) | ✅ |

## H3 — effort
| ID | Claim | Manuscript | Reimplementation | Verdict |
|----|-------|-----------|------------------|---------|
| C26 | Response-time cut-offs p33/p66 = 24.50 / 33.25 | p.896 | 24.5 / 33.25 | ✅ |
| C27 | Response-time group N: 1280/1264/1296 | Fig 5 note | 1280/1264/1296 | ✅ |
| C28 | Survey-attitudes cut-offs p33/p66 = −0.26 / 0.42 | p.896 | −0.264 / 0.418 | ✅ |
| C29 | Survey-attitudes group N: 1720/936/1184 | Fig 6 note | 1720/936/1184 | ✅ |
| C30 | In all 3 response-time groups the FS ethnic effect is insignificant (~0) | p.899 | b: −0.0095 / +0.0103 / −0.0108 (all n.s.) | ✅ |
| C31 | In all 3 survey-attitude groups the FS ethnic effect is insignificant (~0) | p.899 | b: −0.0019 / +0.0070 / −0.0041 (all n.s.) | ✅ |

## Robustness / prose
| ID | Claim | Manuscript | Reimplementation | Verdict |
|----|-------|-----------|------------------|---------|
| C32 | "61 percent" of recruiters found profiles realistic (type_applicants 3/4) | p.900 | 2016+328 = 0.6104 of 3840 | ✅ |
| C33 | 120-sec distraction cut-off: no retained vignette >120 s | footnote 5, p.902 | time_use max 77.5 s | ✅ |

**Coverage:** 33 claims (C1–C33). 31 ✅ · 1 ⚠ (C10, cosmetic rounding, ADV-001) · 1 hygiene note ·
0 ➖. Every headline parameter (all H1/H2/H3 coefficients, SEs, interactions, group Ns, cut-offs,
descriptives, Ns) was independently recomputed in R from the shipped `.dta` and agrees with the paper.
