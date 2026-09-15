# Manuscript numeric-claims inventory
## Altmann, Falk & Wibral (2012), *J. Labor Economics* 30(1):149–174, DOI 10.1086/662130
### Audited by DeepSeek V4 Flash (uniGPT) via anomalyco/opencode (ReproAI), rules 2026.06.27, audit date 2026-09-14

Legend: ✅ identical at reported precision · ≈ close, methodologically explicable (rounding) ·
⚠ discrepant · ➖ not independently checkable (no raw data/code obtainable; reason given).

## A. Table 1 — parameters & equilibrium predictions (design constants / closed-form)
- C1  c = 2,250 (all treatments) — ✅ design constant
- C2  q = 60 (all treatments) — ✅ design constant
- C3  w_low = 5.73 (all) — ✅ design constant
- C4  OS: w_med = 13.62 → e* = 74 — ✅ recomputed e*=73.97 (script 01)
- C5  TS: w_med = 12.11, w_high = 20; e*_1 = 74, e*_2 = 74 — ✅ e*_2 recomputed c(w_h-w_m)/(4q)=73.97
- C6  THS: w_med = 12.11, w_high = 18.49, w_top = 26.38; e*=74 all stages — ✅ final stage top spread 7.89→73.97
- C7  OSL: w_med = 17.57/9.68; e*_1 = 74 — ✅ lottery spread 7.89→73.97
- C8  "Equilibrium effort 74 in both stages of TS and in OS" (§III.A) — ✅ (C4–C5)

## B. Table 2 — behavior summary (each = mean, median, min, max, SD, N)
- C9  OS k1: 71.7 / 75 / 0 / 125 / 29.1 / N60 — ➖ need raw data; one-sample t vs 74 = ✅ logical
- C10 TS k1: 84.8 / 84 / 40 / 125 / 19.7 / N64 — ➖ raw data
- C11 TS k2: 76.7 / 79.5 / 14 / 125 / 26.5 / N32 — ➖ raw data
- C12 THS k1: 79.2 / 78.5 / 40 / 117 / 16.2 / N64 — ➖ raw data
- C13 THS k2: 83.1 / 81 / 59 / 125 / 17.3 / N32 — ➖ raw data
- C14 THS k3: 74.6 / 77 / 8 / 116 / 23.9 / N16 — ➖ raw data
- C15 OSL k1: 77.3 / 78 / 1 / 125 / 25.8 / N100 — ➖ raw data
- C16 "efforts on average very close to Nash; 71.7 slightly below 74, median 75 marginally above" — ✅ via C9 reported
- C17 "almost 20% higher" TS k1 (84.8) vs OS (71.7): ratio 1.183 ≈ 18% — ✅ arithmetic

## C. One-sample t-tests of reported means vs e*=74 (recomputed from reported mean/SD/N, script 01)
- C18 OS vs 74: paper p=.534 → recompute p=.543 (Δ .009) — ≈ rounding (mean/SD at 1 decimal)
- C19 TS k1 vs 74: paper p<.001 → recompute t=4.386, p<.0001 — ✅
- C20 TS k2 vs 74: paper p=.565 → recompute p=.569 (Δ .004) — ≈ rounding
- C21 THS k1 vs 74: paper p=.013 → recompute p=.013 — ✅
- C22 THS k2 vs 74: paper p=.006 → recompute p=.006 — ✅
- C23 THS k3 vs 74: paper p=.918 → recompute p=.921 (Δ .003) — ≈ rounding
- C24 OSL vs 74: paper p=.199 → recompute p=.204 (Δ .005) — ≈ rounding

## D. Mann-Whitney / Wilcoxon statistics (z → two-sided p conversion check, script 01)
- C25 Breadth: OS vs TS k1, z=2.536, p=.011 — ✅ (p(z)=.0112)
- C26 Finalists st1→st2: Wilcoxon z=2.315, p=.021 — ✅ (p=.0206)
- C27 TS k2 vs OS: z=.771, p=.441 — ✅ (p=.441)
- C28 THS final vs TS final: z=.37, p=.710 — ✅ (p=.711)
- C29 THS prefinal vs TS st1: z=.81, p=.419 — ✅ (p=.418, within .001)
- C30 THS st1 vs TS st1: z=1.85, p=.065 — ✅ (p=.064)
- C31 OSL vs OS: z=.94, p=.349 — ≈ (p=.347; needs full-precision z)
- C32 OSL vs TS: z=1.81, p=.070 — ✅ (p=.070)
- C33 Levene's test: W=5.79, p=.018 — ➖ no data
- C34 77% of TS subjects above 74; 52% in OS — ➖ no distribution
- C35 TS lowest effort 40; 20% of OS at/below 40 — ➖ no distribution

## E. Section IV.C incentive maintenance
- C36 finalists' first-stage mean 93.1 — ➖ no data
- C37 "decrease of about 16 points" (93.1→76.7 = 16.4) — ✅ arithmetic
- C38 "final engages not below equilibrium" (76.7 vs 74, p=.565) — ✅ (C20)

## F. Section IV.D THS
- C39 THS st1 vs 74 rejected p=.013 — ✅ (C21)
- C40 THS st2 vs 74 rejected p=.006 — ✅ (C22)
- C41 THS final vs 74 not rejected p=.918 — ✅ (C23)

## G. Footnote 9 (TSC control, N=32)
- C42 TSC stage-1 mean 82.4, median 83, SD 24.6, N=32 — ➖ raw data
- C43 TSC vs its e*=42: "significantly above, p<.001" — ✅ recompute t=9.29, p<.0001
- C44 TSC w_med=9.33; e*=42 (design) — ➖ (would need option-value recompute; spread implies lower e*)

## H. Section IV.E OSL
- C45 OSL avg 77.3 ">5 points above OS (71.7)": 5.6 — ✅ arithmetic
- C46 OSL lies between OS (71.7) and TS st1 (84.8) — ✅ ordering 71.7 < 77.3 < 84.8

## I. Footnote 10 (beliefs)
- C47 "median effort 84; would need second-stage effort 55; ~30% lower than actual (76.7)": 55/76.7 = 1−0.283 — ✅ arithmetic

## J. Section IV.F heterogeneity (Table 3 OLS) — no data
- C48 Table 3 cols 1–5: TS dummy 12.658***/11.907**/19.599***/6.356/6.767; P, P×TS, Constant; N=124/114/64/60/60; R²=.078/.066/.134/.031/.034 — ➖ no data/code
- C49 Baseline and interaction coefficients "individually and jointly insignificant" — ➖
- C50 "0.6-point effect of competitiveness in OS vs 3.9 in TS" — ➖
- C51 Median-split TS: below-median competitiveness 81.3, above-median 87.7 — ➖
- C52 57% of subjects solve all 4 Hit15; average 3.4 — ➖
- C53 Risk CE N=114 consistent: 124 main − 10 no-CE (footnote 7) = 114 — ✅ arithmetic
- C54 Burks et al. (2008) cited: mean 2.4, 25% solve all four — external citation, not auditable here ➖

## K. Sample sizes & earnings
- C55 320 total; OS 60 + TS 64 = 124 in two main treatments — ✅ 60+64=124
- C56 Total: 124 (OS+TS) + 64 (THS) + 100 (OSL) + 32 (TSC) = 320 — ✅ arithmetic
- C57 Avg earnings i18.75 in main treatments (incl. i4 showup + i3 questionnaire); tournament range −i0.15..i18.04 — ➖ descriptive
- C58 Session ~100 min — ➖ descriptive

### Summary counts (58 claims)
- ✅ (exact / closed-form): C1–C8, C16, C17, C19, C21, C22, C25–C30, C32, C37, C38, C39, C40, C41, C43, C45, C46, C47, C53, C55, C56 = 29
- ≈ (rounding tolerance): C18, C20, C23, C24, C31 = 5
- ➖ (no raw data/code obtainable): C9–C15, C33–C36, C42, C44, C48–C52, C54, C57, C58 = 24
- ⚠ (discrepant): 0
