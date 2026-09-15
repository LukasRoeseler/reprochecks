# Manuscript Numeric-Claim Inventory — Baillon, Huang, Selim & Wakker (2018)
**"Measuring Ambiguity Attitudes for All (Natural) Events,"** Econometrica 86(5), 1839–1858. DOI 10.3982/ECTA14370.
Audited 2026-09-14 by ReproAI (DeepSeek V4 Flash via uniGPT / opencode engine), rules 2026.06.27.

Legend: ✅ identical at reported precision · ≈ close / rounding-explicable · ⚠️ discrepant · ➖ not independently checkable (reason).

## Track (a) — Formal / propositional claims

| ID | Claim (source) | Verdict | Evidence / reason |
|----|----------------|---------|-------------------|
| C1 | Def. 2.1: ambiguity aversion index `b = 1 − mc − ms` (Eq. 2) | ✅ | Algebraically internally consistent; neutrality → 0 |
| C2 | Under neutrality (ms=1/3, mc=2/3) b=0, calibrated control for likelihoods | ✅ | b(⅓,⅔)=0 (recomputed) |
| C3 | Max aversion b=1 (all m=0); min b=−1 (all m=1) | ✅ | b(0,0)=1; b(1,1)=−1 (recomputed) |
| C4 | Def. 2.2: a-insensitivity `a = 3·(1/3 − (mc−ms))` (Eq. 3) | ✅ | Algebraically internally consistent |
| C5 | a=0 under neutrality; a=1 (max, mc=ms); a<0 allowed | ✅ | a(⅓,⅔)=0; a(0.5,0.5)=1; a(0.1,0.6)=−0.5 (recomputed) |
| C6 | The two indexes are orthogonal (compl. paper) | ➖ | Referenced to Baillon et al. (2018b) working paper; not derivable from this manuscript alone |
| C7 | Eq. 4 `α = b/(2a) + ½` recovers α in the α-maxmin subclass | ➖ | Stated from companion paper; derivation not in this manuscript |

## Track (b) — Experimental / empirical claims

| ID | Claim (source) | Verdict | Evidence / reason |
|----|----------------|---------|-------------------|
| C8 | N=104 enrolled (56 male, median age 20); 42 control + 62 TP | ✅ | 42+62=104; denominator arithmetic |
| C9 | 5 TP subjects excluded → 99; control 42 / TP 57 | ✅ | 62−5=57; 42+57=99 |
| C10 | Table III means a & b, all 8 cells | ✅ | Reimplemented exactly from Supplement Table SC.I component means (linear form of indexes) |
| C11 | Table III SD & SE (SE=SD/√N), all 8 cells | ✅ | All SE·√N = SD within rounding |
| C12 | Table III medians | ➖ | Median of index ≠ index of median component summaries; needs raw data |
| C13 | Table IV (b regression) Model 1 point estimates = cell means | ✅ | Intercept −0.07, +Part1·TP −0.02, +P2·control −0.04, +P2·TP 0.00 all reproduce Table III cell means |
| C14 | Table IV SEs / significance stars / Chi2 (6.42, 18.48), N=198 | ➖ | N=198 ✓; SE/chi2 need raw clustered data |
| C15 | Control "learning effect" Part2 −0.04†; TP learning effect p=0.14 | ➖ | p=0.14 is a joint test not shown in table; needs raw data |
| C16 | Table V (a regression) Model 1 point estimates = cell means | ✅ | 0.15 + 0.19→0.34; +0.02→0.17; +0.02→0.17 all match Table III |
| C17 | Table V SEs / Chi2 (16.19, 18.36), N=198 | ➖ | N=198 ✓; others need raw data |
| C18 | Headline: TP raises a (Part1·TP 0.19*, p<0.05), robust to controls | ✅ point | Point estimate (0.19) consistent with cell means; SE/p not independently checkable (➖) |
| C19 | Table VI response time intercept 16.63, Part1·TP −4.13, R²=0.02, N=1584 | ✅ / ➖ mix | N=1584=99·2·8 ✓; narrative "~17s / ~4s longer" ✓; SE/R² need raw data |
| C20 | Spearman ρ for b-index: control 0.77 / TP 0.85 (text & Fig 1) | ✅ | Text §4.1 and Fig 1 caption agree |
| C21 | Spearman ρ for a-index: text 0.73/0.74 vs Fig 2 caption 0.77/0.70 | ⚠️ ADV-001 | Text §4.2 disagrees with Figure 2 caption on BOTH panels; cannot both be correct |
| C22 | Consistency: only TP Part-1 m13 second-elicitation higher, mean diff 0.04, p=0.01 | ➖ | Needs raw data |
| C23 | Set-monotonicity violations 0.58/0.30 (TP P1/P2), 0.36/0.24 (ctr); Wilcoxon Z=−2.61 p=.01; Mann–Whitney Z=−1.71 p=.09 | ➖ | Needs raw data |
| C24 | Weak-monotonicity violation % 5/4 (TP), 5/0 (ctr); suppl counts 3/2/2/0 | ✅ | 3/57≈5%, 2/57≈4%, 2/42≈5%, 0/42=0 — counts consistent |
| C25 | TP missed submission 5/496 (62×8) | ✅ | 62×8=496 |
| C26 | Supplement Table SA N=191 (198−7 dropped) | ✅ | 198−7=191; matches appendix |

## Coverage summary
- 7 propositional claims (C1–C7): 6 ✅, 1 ➖ (×2 external-result items counted → 5 ✅, 2 ➖).
- 19 empirical claims (C8–C26): 10 ✅, 1 ⚠️ (ADV-001), 8 ➖ (raw-data-dependent).
- Total 26 claims: 15 ✅ · 1 ⚠️ · 10 ➖ · 0 P0-impossible numbers.

## Headline result as reported
"Time pressure increases a-insensitivity (perceived ambiguity) but does not change ambiguity aversion (index b)."
Independently corroborated at the *mean/point-estimate* level only (TP a(Part1)=0.34 vs ≈0.15–0.17 elsewhere; b ≈ −0.07 to −0.11 flat) — full statistical inference (SEs, p, Chi2, R², correlations, nonparametric tests) cannot be reproduced because no raw data/code package is publicly available.
