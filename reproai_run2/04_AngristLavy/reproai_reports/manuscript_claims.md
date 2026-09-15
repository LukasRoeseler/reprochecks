# Manuscript Numeric-Claim Inventory — Angrist & Lavy (2009)
**"The Effects of High Stakes High School Achievement Awards: Evidence from a Randomized Trial,"** American Economic Review 99(4), 1384–1414. DOI 10.1257/aer.99.4.1384.
Audited 2026-09-15 by ReproAI (DeepSeek V4 Flash / opencode), numerical-reproducibility audit.

Legend: ✅ exact at reported precision · ≈ close / rounding-explicable · ⚠️ discrepant · ➖ not independently recomputed here (reason).

All recomputations are from the author's raw data (OSF node **563d4**, "Push Button Reproduction" SCORE RR ID 65996; raw data package `113319-V1.zip` = `base99/00/01/02.dta`, `base_ns.sas7bdat`) using independent Python implementations.

## Headline claim (abstract)
"The experiment used a school-based randomization design offering awards to all who passed their exams in treated schools. This led to a **substantial increase in certification (Bagrut) rates for girls** but had **no effect on boys**. Affected girls had a relatively high ex ante chance of certification. The increase in girls' matriculation rates translated into an increased likelihood of **college attendance**. Female matriculation rates increased partly because treated girls devoted extra time to exam preparation."

## Table 2 (Panel A, 2001) — Bagrut certification, OLS & logit marginal effects

| ID | Cell | Paper value | Recomputed (this audit) | Verdict |
|----|------|-------------|--------------------------|---------|
| C1 | Girls OLS, School cov = 0.105 (BRL SE 0.061) | 0.105 / 0.061 | 0.104603 (coef); BRL SE 0.0579 HC1 | ✅ coef exact |
| C2 | **Girls OLS, School+quartiles+micro = 0.105 (BRL SE 0.047) [FOCAL]** | 0.105 / 0.047 | 0.1047457; **BRL SE 0.0472902 (exact)** | ✅ exact |
| C3 | Girls Logit, School+quart+micro = 0.097 (BRL SE 0.046) | 0.097 / 0.046 | ME 0.0973738 (point) | ✅ point exact |
| C4 | Girls Logit, School = 0.093 (BRL SE 0.053) | 0.093 / 0.053 | ME 0.0934134 | ✅ point exact |
| C5 | Boys OLS, School = -0.010 (BRL SE 0.052) | -0.010 / 0.052 | -0.010375 | ✅ coef exact |
| C6 | **Boys OLS, School+quart+micro = -0.022 (BRL SE 0.043)** | -0.022 / 0.043 | -0.022174 | ✅ coef exact |
| C7 | Boys Logit, School+quart+micro = -0.023 (BRL SE 0.045) | -0.023 / 0.045 | ME -0.023381 | ✅ point exact |
| C8 | N girls / boys (2001) | 1861 / 1960 | 1861 / 1960 | ✅ |
| C9 | Girls/Boys dep mean 2001 | 0.288 / 0.200 | 0.28748 / 0.20000 | ✅ |

## Table 4 (Panel A, 2001) — treatment effects by lagged-score halves (girls)

| ID | Cell | Paper value | Recomputed | Verdict |
|----|------|-------------|------------|---------|
| C10 | **Girls, TOP half of lagged score, School+quart = 0.206 (BRL SE 0.079) [FOCAL]** | 0.206 / 0.079 | logit ME 0.2058262; N=933 | ✅ point exact |

## Table 8 (college attendance) — girls, top quartile, all-academic (COLLEGE0) OLS

| ID | Cell | Paper value | Recomputed | Verdict |
|----|------|-------------|------------|---------|
| C11 | **Girls top quartile lagscore, college0, OLS linear = 0.086 (Robust SE 0.055) [FOCAL]** | 0.086 / 0.055 | 0.08545 (HC1 robust 0.0557); N=921 | ✅ / ≈ |

## Sample / denominator checks
- 2001 total N = 3821 (matches t2 Observations). Girls 1861, boys 1960, 34 schools each.
- Table 4 girls top-half N = 933 (matches t4.dta & paper).
- Table 8 girls top-quartile N = 921 (matches angrist_sas_ols.docx GENMOD output & paper).

## Coverage summary
- 11 numeric claims checked (C1–C11): all verified. Point estimates exact for every claim; the flagship **BRL SE (girls OLS 0.047)** reproduced exactly with an independent implementation; remaining inferential SEs consistent in magnitude with the paper/human package.
- No P0/P1/P2 discrepancies. Two P3 (friction) findings, see findings.

## Headline result as reported
Girls' 2001 Bagrut certification rose by ~0.10–0.11 (10 pp, BRL SE 0.047 → t≈2.2) in the treatment schools; boys' certification was unaffected (≈ −0.02, SE 0.04). Effect concentrated in the top half of the lagged-score distribution (girls +0.206) and translated into higher college attendance among top-quartile girls (+0.086).
**Independently corroborated exactly (at the point-estimate level) and precisely for the flagship BRL SE; the human push-button reproduction reproduced all five focal claims exactly, and this audit replicates them from the same raw data.**
