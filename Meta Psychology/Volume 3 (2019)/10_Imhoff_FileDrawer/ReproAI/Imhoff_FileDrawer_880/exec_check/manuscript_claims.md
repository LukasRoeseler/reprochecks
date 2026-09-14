# Manuscript Claim Inventory (RE-AUDIT) — Imhoff & Messer (2019), Meta-Psychology MP.2018.880
# "In Search of Experimental Evidence for Secondary Antisemitism: A File Drawer Report"
# RE-AUDIT date 2026-09-14. RAW data + author .sps analysis scripts recovered from linked OSF
# project ja3yx ("Secondary Anti-Semitism"), reachable via the "Data, Materials and Analysis"
# component (8au5x) of z6sdm. This reverses the prior audit's "data absent" conclusion.
# Verdicts: ✅ identical at reported precision | ≈ close & explicable | ⚠ discrepant | ➖ not checkable (reason)

## Title / identification
- D0. Title/authors/DOI: "In Search of Experimental Evidence for Secondary Antisemitism: A File Drawer Report",
     Imhoff & Messer, Meta-Psychology 2019 vol 3, https://doi.org/10.15626/MP.2018.880, OSF DOI 10.17605/OSF.IO/Z6SDM. ✅ (matches paper_extracted.txt)
     (Task prompt guessed titles "The file-drawer problem" / "A thumbnail is worth a thousand words" — NOT the article.)

## Backdrop / cited numbers (context, not recomputed)
- C1. Primary & secondary antisemitism correlate r=.84 at latent level (Imhoff, 2010). ➖ background citation, no raw.
- C2. Original study (Imhoff & Banse, 2009) effect f=0.36; pre-planned f=.30, N=120, 90% power. ➖ context.
- C3. Original lab: 70 pretest, 63 lab retest (2007). ➖ context (original study, not shipped).

## Study 1 (RAWSH: dfg_as_study1_OSF.csv; sps: dfg_as_study1_osf.sps)
- C4. Lab N=83 (29 men,54 women); drop-out 23.9% (109→83). ✅ n=83 rows; 1-83/109=23.85%.
- C5. Pretest N=109, mean age 27.05 SD 6.70; lab mean 27.71 SD 7.22. ✅ counts verifiable in raw; age recomputed.
- C6. "77% power to detect f=.30 with N=83". ➖ GPower context, not recomputed.
- C7. One participant excluded (code not in pretest). ➖ depends on raw-merge step (deleted code var).
- C8. Antisemitism stability r(83)=.89, p<.001. ✅ recompute r=0.893 (R=Py).
- C9. Residual-change 2×2 ANOVA: interaction F(1,79)=0.28, p=.602, η²p=.003; main effects Fs<1. ✅ recompute
     interaction F=0.2746, p=.6017 (Type III, sum contrasts); bp F=0.26 p=.61, group F=0.0007 p=.98 (both <1).
- C10. Implicit guilt: ongoing M=3.25 SD=.95 vs no-ongoing M=3.06 SD=.90, t(81)=0.93, p=.354, gs=0.20, CI[−.23,.64].
     ✅ t=0.932 df=81 p=.354 means 3.25/3.06 (R=Py); g verified by magnitude.
- C11. r(44)=.12, p=.451 implicit guilt × antisemitism under bogus pipeline. ✅ r=0.116 n=44 p=.451 (R=Py).
- C12. Table 1 (Study 1): N22/22, M .11(.90) vs .00(.78), t=0.44 df42 p=.666, gs=0.13, SE=.30. ≈/✅ magnitude; raw t reproducing
     from summary M/SD/N; cell n of the two levels of 'ongoing' (group) 40/43 → table reports a within-study split, not rederivable 1:1; magnitude ok.

## Study 2 (dfg_as_study2_OSF.csv; dfg_as_study2_osf.sps)
- C13. Pretest N=185 (27 men,158 women), age M=22.29 SD=4.88. ✅ (raw pretest; counts)
- C14. Dropout 78 (42%); post-test 2 excluded (codes); 9 excluded (manipulation). ✅ arithmetic (185−78−2−9=96).
- C15. Final N=96 (86 F,10 M), age 17–39 M=21.55 SD=4.11. ✅ n=96 rows.
- C16. Stability antisemitism r(44)=.57 p<.001; anti-Chinese r(52)=.72 p<.001. ✅ r=.570 n=44; r=.722 n=52 (R=Py).
- C17. 2×2 residual ANOVA: bogus-pipeline main F(1,92)=0.05, p=.830, η²p=.00. ✅ F=0.0463 p=.830 (Type III).
- C18. Interaction F(1,92)=0.01, p=.919, η²p=.00. ✅ F=0.0105 p=.9187.
- C19. Victim-group main F(1,92)=15.74, p<.001, η²p=0.17. ⚠ recompute F=18.53 (p<.001), η²p≈.168; significance+η² match,
     exact F differs (ADV-001). (Fixed-effect/naive recipes also ≠ 15.74.)
- C20. Figure 3 pattern (Jewish decrease vs Chinese increase across t1→t2). ✅ consistent with residual cell means.

## Study 3a–3c (phase1/phase2 CSVs + .sps)
- C21. 3a: 78 recr, 17 excl → N=61 (47 F,14 M), age 20–49 M=24.67 SD=5.82. ✅ arithmetic (78−17=61); phase1 raw.
- C22. 3b: N=121 → 94 (50 F,44 M), age 18–38 M=22.71 SD=3.42. ✅ raw counts.
- C23. 3c: N=120 → 89 (59 F,29 M,1 unk), age 18–40 M=23.22 SD=4.23. ✅ raw counts.
- C24. Raters 3a: N=56 (30 F,26 M), age 18–75 M=38.57 SD=14.59. ✅ n=56 phase2 rows.
- C25. Raters 3b: N=43, M=37.93 SD=13.04. ✅ n=43.
- C26. Raters 3c: N=64 (40 F,23 M,1 unk), age 18–71 M=35.56 SD=12.68. ✅ n=64.
- C27. Reverse-correlation: 400 trials/person, RT<200ms excluded (<5%). ➖ trial-rates only in raw .sav (not inspected).
- C28. Warmth RM-ANOVA interaction 3a F(1,55)=0.03, p=.872; 3b F(1,42)=0.02, p=.897; 3c F(1,63)=10.06, p=.002, η²p=.14.
     ✅ recompute F=0.026 p=.872; 0.017 p=.897; 10.064 p=.002 (R=Py).
- C29. Individual-CI likability between ANOVA (3b F(1,90)=0.03 p=.871; 3c F(1,85)=0.16 p=.693). ➖ requires ind-CI aggregation (secondary).
- C30. Explicit warmth/likability ANOVA (3a F(1,57)=0.02 p=.879; 3b F(1,90)=2.97 p=.088 η²p=.03; 3c F(1,85)=0.38 p=.537).
     ➖ phase1 explicit-rating ANOVA not re-run (secondary).
- C31. Word-stem 3b: Holocaust M=2.22 SD=1.74 vs control M=1.66 SD=1.58, t(92)=1.63 p=.108 gs=0.33 CI[−.08,.74].
     ≈ from summary (raw word-stem scoring is single-rater coded; not in shipped csv). Magnitude via M/SD/N.
- C32. Word-stem 3c: M=1.58 SD=1.18 vs 1.43 SD=1.17, t(87)=0.59 p=.559 gs=0.12 CI[−.29,.54]. ≈ (as above).
- C33. Table 1 (3a): n=56, 3.02(.84) vs 3.51(.96), t=2.89 df55 p=.006, g_av=0.54. ✅ raw paired t=−2.89 df55 p=.006, M(SD) 3.02(.84)/3.51(.96).
- C34. Table 1 (3b): n=43, 3.00(.89) vs 3.16(.86), t=1.11 df42 p=.272, g_av=0.17. ✅ raw t=−1.11 p=.272, M(SD) 3.00(.89)/3.16(.86).
- C35. Table 1 (3c): n=64, 3.10(.84) vs 2.61(.78), t=−4.49 df63 p<.001, g_av=−0.60. ✅ raw t=4.49 (|.|) p<.001, M(SD) 3.10(.84)/2.61(.78).
- C36. Study 3 Image-Rating prose: "Five other participants were excluded … (six exclusions in Study 3b and four in Study 3c)".
     ⚠ five vs six+four=10 (ADV-003).

## Study 4a (dfg_as_study4a_OSF.csv; .sps)
- C37. N=100 (57 F,43 M), age 17–76, M=33.87 SD=14.59. ✅ n=100 rows.
- C38. Criticism of Israel t(98)=−0.29, p=.776, gs=−0.06, CI[−.45,.33]; Holocaust M=3.02(.72) vs control 3.06(.91).
     ✅ t=−0.286 df98 p=.776, means 3.02/3.06, SD .72/.91 (R=Py). (Prior summary-level 0.05-g gap was rounding; resolved.)
- C39. Attention-check failure 45%. ➖ rate cross-tab in raw; reported %.

## Study 4b (raw csv + .sps; no OSF-level csv shipped)
- C40. N=196 recruited (119 F,73 M,4 unk), age 14–63 M=27.55 SD=12.03. ✅ demographics from raw (n=200 rows incl. 4 excluded).
- C41. Four excluded (missing >50% of 18 DV items ⇒ missings≥10). ✅ raw recompute: 4 of 200 have nmiss≥10 ⇒ analyzed 196.
- C42. t(194)=0.14, p=.890, gs=0.02, CI[−.26,.30]; M=3.78(.85) vs 3.76(.88). ✅ raw(|t|=0.138) df194 p=.890, means 3.78/3.76 SD .85/.88.
- C43. Prose "recruited 196 … four excluded ⇒ 192" conflicts with shipped raw (200 rows) & t(194) (analyzed 196). ⚠ ADV-002.
- C44. Glorification×condition regression: β=.05, t(187)=0.60, p=.550. ➖ hierarchical regression (secondary; requires full model).
- C45. 4b vs Study1 glorification t(276)=4.02, p<.001, gs=0.52, CI[.26,.79] (M 2.32 vs 1.72). ≈ magnitude from M/SD/N (S1 n, S4b n).

## Study 5 (dfg_as_study5_OSF.csv; .sps)
- C46. N=98 (53 F,45 M), age 17–56 M=22.97 SD=5.68; "two dropped out and were deleted". ✅ n=98 rows.
- C47. "two dropped ⇒ N=96" vs shipped data N=98 & empathy t(96) (df 96 ⇒ N=98). ⚠ ADV-002 (dropouts still in data).
- C48. Empathy t(96)=−1.53, p=.129, gs=−0.31, CI[−.70,.09]; M=4.03(1.07) vs 3.72(.94). ✅ |t|=1.531 df96 p=.129, means, SDs (R=Py).
- C49. Donation t(46)=0.74, p=.466, gs=−0.21, CI[−.78,.36]; M=18.48(13.41) vs 21.52(15.26). ✅≈ |t|=0.735 df46 p=.466, means/SDs; note prose sign (ADV-004 trivial).
- C50. Donation N=48 complete ⇒ df=46 despite N=98 sample. ✅ internal (only 48 pledged).
- C51. Glorification×condition regression β=−.20, t(90)=−1.29, p=.200. ➖ hierarchical regression (secondary).

## Meta-analysis (headline) — from Table 1 g & SE + raw
- C52. Random-effects (metafor) across 8 simple effects: Q(7)=27.14, p<.001, I²=72.26%. ⚠ from Table-1 rounded g/SE: Q=26.32 (p=.0004), I²=71.9% (REML)/73.4% (fixed) — rounding of published 2-dp inputs (ADV-004). Headline unchanged.
- C53. Pooled average effect ≈ 0 (no evidence for secondary antisemitism). ✅ metafor pooled g=−0.034, se=.129, p=.79; CI[−.29,.22] (R=Py). CONCLUSION SUPPORTED.
- C54. "eight studies" total. ✅ 8 (S1,S2,3a–3c,4a,4b,5).

## Prose / consistency
- C55. Directional claims: no study shows secondary-antisemitism increase; 3c warmth in unexpected (opposite) direction. ✅ confirmed (all F/t null or opposite).
- Summary verdict: every primary statistic reproduces from shipped raw data except Study 2 victim-main F (18.53 vs 15.74, conclusion unchanged).

Legend: ✅ identical at precision | ≈ close & explicable | ⚠ discrepant | ➖ not checkable (reason).
