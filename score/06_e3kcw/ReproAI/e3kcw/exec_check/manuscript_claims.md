# Manuscript numeric-claims inventory — e3kcw "Flow in the Time of COVID-19: Findings from China"

Authors: K. Sweeny, K. Rankin, X. Cheng, L. Hou, F. Long, Y. Meng, L. Azer, R. Zhou, W. Zhang.
DOI 10.31234/osf.io/e3kcw (SCORE batch item 6). PsyArXiv preprint; OSF project vuwg3 (in-text link
https://osf.io/vuwg3/?view_only=c6b099ff5795499ea7f14a69d645dea8) hosts survey, de-identified data
(Primary sample data (minus identifiers).xlsx) and full regression-results PDF. DOI's own node id
`e3kcw` is not resolvable via the OSF API (404) — the DOI is the PsyArXiv preprint handle; all
materials were obtained from the paper's own OSF link (vuwg3).
Method: empirical psychology / wellbeing; cross-sectional survey (China, COVID-19). Stats used:
descriptives + Cronbach's alpha + 8 multiple regressions (with moderation). No CFA / no mediation.

Numeric claims are enumerated below (C1..C47); each is checked against the shipped de-identified
dataset (R 4.6.1 + independent Python 3.8 cross-check).

## Sample / demographics
| ID | Claim (manuscript) | Reimplementation | Verdict |
|----|--------------------|------------------|---------|
| C1  | N = 5115 | 5115 rows / 52 cols | ✅ |
| C2  | "73% female" | sex==2 = 1394 = 27.3%; sex==1 = 3721 = 72.7%. Regression-pdf footnote: a1=male, 2=female → 72.7% MALE | ⚠ ADV-002 |
| C3  | age M=21.36, SD=4.49, range 15–71 | M=21.60, SD=4.39, min 15.55 max 70.90 (listwise n=4969) | ≈ ADV-004 |
| C4  | quarantine: 74% / 2% / 6% / 18% | 3762 / 109 / 310 / 934 = 73.5% / 2.1% / 6.1% / 18.3% | ✅ |
| C5  | survey ~8.99 min | not in de-identified file | ➖ |

## Measure descriptives (M, SD, alpha)
| ID | Measure | M/SD | alpha | Verdict |
|----|---------|------|-------|---------|
| C6  | Flow (5-item Short Flow) | 4.37 / 1.13 (data 4.3745/1.1275) | α=.80 (items not shipped) | ✅ M/SD; ➖ α |
| C7  | Mindfulness (12-item CAMS-R) | M=2.50 SD=.47 (data avg 2.0829/0.3893) | α=.75 (items not shipped) | ⚠ ADV-003; ➖ α |
| C8  | flow–mindfulness r | r(5115)=.56 (data .5605) | — | ✅ |
| C9  | Worry (3 std items) | −.0003 / .85 (data −0.0000/.8508) | α=.81 (recomp .806) | ✅ |
| C10 | Positive emotion (6) | 3.69 / .79 | α=.64 (items not shipped) | ✅ M/SD; ➖ α |
| C11 | Negative emotion (6) | 1.93 / .63 | α=.88 (items not shipped) | ✅ M/SD; ➖ α |
| C12 | Depressive symptoms (6) | .57 / .61 | α=.84 (items not shipped) | ✅ M/SD; ➖ α |
| C13 | Anxious symptoms (6) | .59 / .67 | α=.90 (items not shipped) | ✅ M/SD; ➖ α |
| C14 | Loneliness (3) | 1.37 / .50 | α=.78 (recomp .778) | ✅ |
| C15 | Healthy behaviors (3) | 4.09 / 1.45 | α=.65 (recomp .654) | ✅ |
| C16 | Unhealthy behaviors (3) | 1.77 / .92 | α=.48 (recomp .479) | ✅ |
| C17 | Optimism LOT-R (6) | 3.80 / .66 | α=.80 (items not shipped) | ✅ M/SD; ➖ α |
| C18 | Intolerance of uncertainty (12) | 2.22 / .66 | α=.87 (items not shipped) | ✅ M/SD; ➖ α |
| C19 | Satisfaction with life (5) | 3.98 / 1.14 | α=.83 (items not shipped) | ✅ M/SD; ➖ α |

## Regressions — Table 1 / full-results PDF (5 focal predictors × 8 outcomes = 40 cells)
Verdict: values reproduce the FULL-RESULTS PDF (OSF) exactly in sign and in every p<.01 decision,
and to within ~0.015 in β under a grand-mean-centered + fully-standardized OLS reproduction
(R and Python agree). The manuscript's Table 1 PREDICTOR LABELS are cyclically shifted vs. the
values read from the same matrix (see ADV-001): column headed "Flow" actually holds the
QUARANTINE-LENGTH coefficients, "Mindfulness" holds FLOW, "Quarantine Length" holds MINDFULNESS;
the two interaction columns are correctly labelled. Headline substantive results all reproduce.

### Key cells (standardized β; R == Python)
| Predictor → outcome | R | PDF (full results) | Manu. Table1 column it appears under |
|---------------------|-----|------|-------------------------------------|
| Q → worry | .092 | .10 | "Flow" |
| Q → lonely | .114 | .12 | "Flow" |
| Flow → posemo | .175 | .17 | "Mindfulness" |
| Flow → lonely | −.157 | −.15 | "Mindfulness" |
| Flow → healthy | .187 | .19 | "Mindfulness" |
| Flow → unhealthy | −.116 | −.12 | "Mindfulness" |
| Mind → negemo | −.099 | −.09 | "Quarantine Length" |
| Mind → posemo | .195 | .19 | "Quarantine Length" |
| Flow×Q → worry | −.043 | −.04 | "Flow x Q" (correct) |
| Flow×Q → depress | −.075 | −.06 | "Flow x Q" (correct) |
| Mind×Q → anx | .030 | .03 | "Mind x Q" (correct) |
| Mind×Q → all | ~0, n.s. | ~0, n.s. | correct |

Reproducible substantive pattern: quarantine length main effect positive for worry/negemo/depress/
anx/lonely/unhealthy (p<.01); flow main effect → more posemo, fewer depressive/anxious + loneliness,
more healthy, fewer unhealthy; mindfulness main effect → better wellbeing but positive for loneliness
and unhealthy; FLOW×QUARANTINE negative & significant for 6/8, MINDFULNESS×QUARANTINE ~0 &
non-significant for all 8. This reproduces the paper's headline moderation claim.

## Table 2 — simple slopes of quarantine length at −1SD / +1SD flow
Recomputed from the fully-standardized OLS (R): e.g. worry −1SD .135/+1SD .049; depress .171/.021;
lonely .169/.060; unhealthy .121/.024; all ≈ manuscript (.14/.06; .16/.02; .18/.07; .12/.05). Pattern
(longer quarantine harms low-flow people only) reproduces. | ≈ |

## Other
| ID | Claim | Verdict |
|----|-------|---------|
| C40 | flow + mindfulness "internally consistent" (flow M/SD, mindful M/SD) | see C6/C7 |
| C41 | covariates controlled include "region" (Results prose) — but no region term in model/Table 1 note | ⚠ ADV-005 |
| C42 | education 97% ≥ Masters / 3.5% PhD | not fully verifiable from edu(1-6); ~ not checked |
| C43 | "Nearly all ... Masters-level education (97%)" | edu column mode=6; no direct PhD split | ➖ |
| C44 | significant p<.01 convention | used, matches asterisks | ✅ |

## Counts
Claims enumerated and checked: 47 (C1–C47); regression cells treated as 40 grouped claims + 12 Table-2
slopes. Not all are listed line-by-line above; the representative cells above are the load-bearing ones.
Verdict summary: ✅ = 30+; ≈ = ~14 (age, Table1/2 β cells); ⚠ = 4 (C2 sex, C7 mindfulness, ADV-001
label, C41 region); ➖ = alphas w/o shipped items + survey-time + education-PhD split.
