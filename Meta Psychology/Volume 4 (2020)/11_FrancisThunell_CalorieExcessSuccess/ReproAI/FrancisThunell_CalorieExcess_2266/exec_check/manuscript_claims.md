# Manuscript Claims Inventory — Francis & Thunell (2020) MP.2019.2266

**Title:** Excess success in "Don't count calorie labeling out: Calorie counts on the left side of menu items lead to lower calorie food choices"
**Authors:** Gregory Francis (Purdue), Evelina Thunell (Karolinska/Purdue)
**DOI:** 10.15626/MP.2019.2266 | **OSF:** 4TGQ9 (project page) + xrdhj (R code)
**Badges (paper banner):** Open data: **No** | Open materials: Yes | Open and reproducible analysis: Yes | Analysis reproduced by: N. Brown, P. Langford | Preregistration: No
**Audit date:** 2026-09-14 | **Engine:** anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT
**Legend:** ✓ identical at reported precision · ≈ close & methodologically explicable · ⚠ discrepant (cause in report) · ➖ not independently checkable (reason)

## A. Headline / primary claims
| ID | Claim (location) | Manuscript | Reimplementation | Verdict |
|----|------------------|-----------|------------------|---------|
| C1 | Probability that a replication of the six Dallas et al. studies (same n) yields uniformly significant outcomes (Abstract) | 0.014 | Product of the six power estimates = 0.01356 (AC) / 0.01355 (Table-1 rounded) ≈ 0.014 | ✓ |
| C2 | Six independent studies each with power 0.5 → all six significant ≈ 0.5^6 ≈ 0.016 (Intro) | 0.5^6 ≈ 0.016 | 0.5^6 = 0.015625 ≈ 0.016 | ✓ |
| C3 | Study 1 estimated power (Table 1, rightmost col) | 0.4582 | Author Study1AC.R run live (seed 3947194): 0.4582 (exact); independent Python MC: 0.45847 | ✓ |
| C4 | Study 2 estimated power (Table 1) | 0.5426 | Author AnalysisAC.R: 0.5426402; closed-form pwr recompute: 0.54264 | ✓ |
| C5 | Study 3 estimated power (Table 1) | 0.3626 | Author Study3AC.R run live (seed 3947194): 0.36262 (exact); Python MC: 0.36338 | ✓ |
| C6 | Study S1 estimated power (Table 1) | 0.5358 | closed-form pwr recompute: 0.53577 | ✓ |
| C7 | Study S2 estimated power (Table 1) | 0.5667 | unseeded MC: R re-run 0.56738, Python 0.56610 — within MC SE ≈0.0016 (ADV-003) | ≈ |
| C8 | Study S3 estimated power (Table 1) | 0.4953 | unseeded MC: R re-run 0.49435, Python 0.49552 — within MC SE ≈0.0016 (ADV-003) | ≈ |
| C9 | "product of the power values in Table 1 … only 0.014" (Results) | 0.014 | 0.4582×0.5426×0.3626×0.5358×0.5667×0.4953 = 0.01355773 | ✓ |
| C10 | Study 2 Hedges' g = 0.25 (Methods prose) | 0.25 | From t=2.08, n=143/132: g=0.25037 | ✓ |

## B. Closed-form two-sample-t studies (Methods)
| ID | Claim | Manuscript | Reimplementation | Verdict |
|----|-------|-----------|------------------|---------|
| C11 | Study S1 Hedges' g (used for power) | (implied ~0.31) | From t=2.07, n=99/77: g=0.31317 | ✓ |

## C. Meta-analysis & designing-new-studies (Results / Table 2)
| ID | Claim | Manuscript | Reimplementation | Verdict |
|----|-------|-----------|------------------|---------|
| C12 | Individual standardized effect sizes | "varies from 0.15 to 0.45" | g per study: 0.451, 0.250, 0.298, 0.314, 0.262, 0.154 → range 0.154–0.451 | ✓ |
| C13 | "smaller effect sizes for the studies with larger sample sizes" (prose) | — | Broadly decreasing but not strictly monotone (Study 3 g=0.298 > S1 g=0.314 at similar n; Study2 0.250 < S2 0.262) | ≈ |
| C14 | Pooled Hedges' g* (in-text) | 0.2366 | Pooled inverse-variance g = 0.23662 (PRE n1R=55) or 0.23659 (POST n1R=54); both round to 0.2366 | ✓ |
| C15 | Table 2: 80% power → n per condition | 282 | pwr recompute = 282 (both PRE & POST g) | ✓ |
| C16 | Table 2: 85% → n | 322 | 322 (both) | ✓ |
| C17 | Table 2: 90% → n | 377 | 377 (both) | ✓ |
| C18 | Table 2: 95% → n | **465** | PRE-g gives 465; POST-g gives **466** (ADV-001) | ⚠ |
| C19 | Table 2: 99% → n | 658 | 658 (both) | ✓ |
| C20 | Table 2 half-g: 80% → 1123 · 85% → 1284 · 90% → 1502 · 95% → 1858 · 99% → 2626 | 1123/1284/1502/1858/2626 | PRE-g/2 reproduces all five; POST-g/2 gives 1123/1285/1503/1859/2627 (ADV-001) | ⚠ |
| C21 | "only one (study S3) out of six had ≥282 participants per condition" (prose) | S3 only | Highest condition-n among Studies 1,2,3,S1,S2 = 151 < 282; S3 = 337 | ✓ |
| C22 | "90% power … 377 participants … larger than any of the six studies" (prose) | 377 | max condition-n in Table 1 = 337 < 377 | ✓ |
| C23 | 80% power at half effect size requires 1123/condition; 90% → 1502 (prose) | 1123 / 1502 | matches pwr(PRE-g/2) | ✓ |

## D. Directional claims (prose §1)
| ID | Claim | Manuscript direction | Verified from Table-1 means | Verdict |
|----|-------|----------------------|------------------------------|---------|
| C24 | Studies 1, 2, S1, S2, S3: left < right calorie choice | μ_left < μ_right | 654.53<865.41; 1249.83<1362.31; 185.94<215.73; 1182.15<1302.23; 1302.03<1373.15 | ✓ |
| C25 | Study 3 (Hebrew readers): right < left | μ_right < μ_left | Left 1428.24 > Right 1308.66 | ✓ |
| C26 | Study 1/S2/S3 third (no-label) condition: left < no-label | μ_left < μ_none | 654.53<914.34; 1182.15<1373.74; 1302.03<1404.35 | ✓ |

## E. Provenance / availability
| ID | Claim | Verdict |
|----|-------|---------|
| C27 | "Simulation source code … available at OSF: https://osf.io/xrdhj/" | ✓ 12 R files retrieved (6 "plain" pre-corrigendum + 6 "AC" post-corrigendum + readmes + results). See ADV-002 about dual variants. |
| C28 | Banner "Open and reproducible analysis: Yes … Analysis reproduced by N. Brown, P. Langford" | ➖ No reproduction record/log shipped in the retrieved OSF nodes; independently reproducible here (this audit), but the editorial reproduction itself is not independently verifiable from shipped materials. |
| C29 | Banner "Open data: No" | ✓ honest — only summary statistics (means/SD/n) are needed for the TES; no raw trial data claimed. |

**Totals (C1–C29): 29 claims checked.** ✓/≈: 27 · ⚠ (ADV-001): tied to C18/C20 · ➖: 1 (C28) · ≈: C7, C8, C13 (MC drift / broad-trend, methodologically explicable).
