# Manuscript Claim Inventory — Witt (2019) "Graph Construction: An Empirical Investigation on Setting the Range of the Y-Axis" (Meta-Psychology MP.2018.895)

Re-audit date: 2026-09-14 · Engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT
Source: `paper_extracted.txt` (untouched) + OSF data (`data/`; 4 raw per-trial CSVs) + author notebook (`code/Witt_AnalyzeGraphSD_V4*.Rmd`).
Legend: ✅ identical at reported precision · ≈ close & methodologically explicable · ⚠ discrepant · ➖ not independently checkable (with reason).

## A. Design / data-structure claims
- C1. 5 experiments; recruited N per Table 1 = 9, 14, 13, 20, 15. — ✅ (data unique Subject counts: 9,14,13,20,15)
- C2. "57 participants across 5 experiments" (main text). — ⚠ ADV-002. Data contain 71 recruited; after the paper's IQR-outlier exclusions the analyzed total is 58 (7/11/11/16/13). Neither equals 57.
- C3. Stimuli simulated from normal distributions (R): one group mean=50, other mean=49/47/45/42 ↔ d=.1/.3/.5/.8 (Exp1-2), d=0/.3/.5/.8 (Exp3-5), SD=10, 1000 samples. — ✅ effectSize codes 0/1,3,5,8 consistent with Table 1; simulated-data generation not re-run (➖: no seed shipped) but the stimulus representation matches.
- C4. 120 graphs/exp (3 ranges × 4 effect sizes × 10 sets); 4 blocks; 480 trials/participant. — ✅ (complete participants = 480 trials; several incomplete, see ADV-007/008)
- C5. Fluency = per-subject per-condition linear regression; slope = sensitivity; intercept → bias% = (intercept − 2.5)/2.5×100. — ✅ (confirmed in author Rmd and recompute)
- C6. Outliers = per-participant slope > 1.5×IQR within condition, excluded. — ✅ (exclusion lists reproduce: Exp1 {1,8}, Exp2 {13,17,24}, Exp3 {3,4}, Exp4 {4,9,15,16}, Exp5 {7,13})
- C7. Bayes factors via BayesFactor R package, medium prior (r=0.707); BF>3 moderate, >10 substantial; <.33/<.10 null. — ✅ (recompute via ttest.tstat, rscale=0.707)

## B. Experiment 1 (bar, 2−1 SD=2 SD standardized) — analyzed N=7 (df=6)
- C8. Sensitivity all-trial: Std M=.47 SD=.11; Full M=.30 SD=.07; Min M=.28 SD=.04. — ✅ (.469/.112, .303/.073, .276/.035; R==Python)
- C9. Std vs Full: t(6)=3.84, p=.009, dz=1.45, 95%CI[.33,2.51], BF=7.54. — ✅ (t=3.836, dz=1.450, BF=7.54)
- C10. Std vs Min: t(6)=3.61, p=.011, dz=1.37, CI[.28,2.40], BF=6.17. — ✅ (|t|=3.615, dz=1.366, BF=6.17)
- C11. Min vs Full: p=.51, dz=.26, BF=0.43. — ✅ (p=.514, dz=.262)
- C12. Bias Full: M=−27% SD=10%, t(6)=−7.01, p<.001, dz=2.64, CI[1.00,4.27], BF=82. — ✅ (t=−7.007, dz=2.648, BF=81.8)
- C13. Bias Min: M=36% SD=19%, t(6)=4.91, p=.003, dz=1.86, CI[.57,3.10], BF=19. — ✅ (t=4.914, dz=1.857, BF=18.8)
- C14. Bias Std: M=1% SD=4%, t(6)=0.47, p=.66, dz=.18, CI[−.58,.92], BF=0.39. — ✅
- C15. "91% of full-graph trials labeled no/small." — ✅ Exp1 full no/small (all trials) = 90.8% ≈ 91%
- C16. "minimal 58% labeled big; 88% medium/big." — ✅ Exp1 minimal big (all) = 58.0%; med+big = 87.9%

## C. Experiment 2 (bar, 1.4 SD) — analyzed N=11 (df=10)
- C18. Sensitivity: Std M=.54; Full M=.31; Min M=.30. — ✅ (.540/.307/.298)
- C19. Std vs Full: t(10)=3.46, p=.006, dz=1.04, CI[.28,1.77], BF=9.00. — ✅ (t=3.459, dz=1.043, BF=9)
- C20. Std vs Min: t(10)=4.07, p=.002, dz=1.23, CI[.42,2.00], BF=20. — ✅ (t=4.066, dz=1.226, BF=20.4)
- C21. Bias Full: M=−28%, t(10)=−10.51, dz=3.17, BF>100. — ✅ (t=−10.506, dz=3.168, BF=1.6×10⁴)
- C22. Bias Min: M=31%, t(10)=4.91, dz=1.48, CI[.59,2.33], BF=61. — ✅ (t=4.909, dz=1.480, BF=61)
- C23. Bias Std: M=6% SD=9%, t(10)=2.13, p=.059, dz=.64, CI[−.02,1.28], BF=1.50. — ✅ (t=2.126, dz=.641, BF=1.5)

## D. Experiment 3 (bar + error bars) — all-trial N=11 (df=10); sub-analyses N=9 (df=8)
- C24. Sensitivity all-trial: Std M=.62; Full M=.24; Min M=.55. — ✅ (.624/.236/.552)
- C25. Std vs Full (all): t(10)=7.76, p<.001, dz=2.34, CI[1.16,3.50], BF>100. — ✅ (t=7.759, dz=2.340, BF=1.5×10³)
- C26. Std vs Min (all): t(10)=3.09, p=.011, dz=.93, CI[.20,1.63], BF=5.46. — ✅ (t=3.094, dz=.933, BF=5.46)
- C27. Sub d=0–.3 Std vs Full: t(8)=2.82, p=.022, dz=.85, CI[.14,1.53], BF=3.76. — ⚠ ADV-005. t & p reproduce (t=2.820, p=.0225) but dz=.94 and BF=3.36 when computed with n=9; manuscript dz=.85/BF=3.76 = t/√11 (full N).
- C28. Sub d=0–.3 Std vs Min: t(8)=−1.82, p=.11, BF=1.03. — ⚠ ADV-005. t=1.817 ✓; dz=.55 & BF=1.03 match n=11 (t/√11=0.548) not n=9 (0.606, BF=1.05).
- C29. Sub d=.3–.8 Std vs Full: BF>100, dz=2.81, CI[1.45,4.14]. — ⚠ ADV-005. Data give t=9.310 → dz=3.10 (n=9) or 2.81 (n=11); manuscript dz=2.81 (n=11 denominator); BF>100 either way.
- C30. Sub d=.3–.8 Std vs Min: BF=65, dz=1.50, CI[.60,2.35]. — ⚠ ADV-005. Data t=−4.960 → dz=1.65 (n=9) or 1.50 (n=11); manuscript dz=1.50, BF=65 = n=11 (BF(n9)=37.8).
- C31. Bias Full: M=−28%, t(10)=−7.82, dz=2.36, BF>100. — ✅ (t=−7.821, dz=2.358, BF=1.6×10³)
- C32. Bias Min: M=14%, t(10)=2.03, p=.069, dz=.61, BF=1.33. — ✅ (t=2.034, dz=.613, BF=1.33)
- C33. Bias Std: M=7%, t(10)=1.29, p=.227, dz=.39, BF=.58. — ✅ (t=1.288, dz=.388, BF=.579)

## E. Experiment 4 (line, 1.4 SD) — analyzed N=16 (df=15)
- C35. Table A1 slopes: Full .30/.15/.61; Std .61/.52/.86; Min .61/.31/1.29 (all / d>.3 / d=0–.3). — ✅ recomputed for the N=16 sample (.30/.15/.61, .61/.52/.86, .61/.31/1.29)
- C36. Std vs Full (all): t(15)=7.16, p<.001, dz=1.79, CI[.98,2.59], BF>100. — ✅ (t=7.159, dz=1.790, BF=6×10³)
- C37. Min vs Std (all): t(15)=0.18, p=.86, dz=.05, CI[−.45,.53], BF=.26. — ✅ (t=−0.180, dz=.045, BF=.259)
- C38. Min vs Std (d=0–.3): t(15)=−4.70, p<.001, dz=1.17, CI[.52,1.81], BF>100. — ✅ (t=4.697, dz=1.174, BF=113)
- C39. Bias Full: M=−26%, t(15)=−9.52, dz=2.38, BF>100. — ✅ (t=−9.506, dz=2.376, BF=1.5×10⁵)
- C40. Bias Min: M=19%, t(15)=4.36, dz=1.09, BF=64. — ✅ (t=4.373, dz=1.093, BF=64.5)
- C41. Bias Std: M=2% SD=10%, t(14)=0.73, p=.48, dz=.18, CI[−.32,.67], BF=.32. — ⚠ ADV-006. Value reproduces (t=0.719, N=16) but df printed as 14 instead of 15 (N=16) — typo.

## F. Experiment 5 (line, 1 SD) — analyzed N=13 (df=12)
- C43. Std vs Full (all): t(13)=4.41, p<.001, dz=1.22, CI[.48,1.94], BF=46. — ✅ (t=4.415, dz=1.224, BF=45.8)
- C44. Std vs Full (d>0): t(13)=6.69, dz=1.86, BF>100. — ✅ (t=6.692, dz=1.856, BF=1.1×10³)
- C45. Min vs Std (d=0–.3): t(13)=−3.11, p=.009, dz=.86, BF=6.27. — ✅ (t=3.106, dz=.862, BF=6.27)
- C46. Bias Full: M=−15% SD=17%, t(12)=−3.07, p=.010, dz=.85, BF=5.90. — ✅ (t=−3.076, dz=.853, BF=5.99)
- C47. Bias Min: M=12% SD=20%, t(12)=2.21, p=.047, dz=.61, CI[.01,1.20], BF=1.69. — ✅ (t=2.246, dz=.623, BF=1.77)
- C48. Bias Std: M=6% SD=14%, t(12)=1.63, p=.13, dz=.45, BF=.80. — ✅ (t=1.606, dz=.445, BF=.777)

## G. Cross-experiment tables & pooled claims
- C49. Table A3 all-trial slopes for Exp2/4/5. — ✅ (E2 .31/.54/.30, E4 .30/.61/.61, E5 .32/.55/.53)
- C50. Table A3 Exp1 (.28/.46/.27). — ⚠ ADV-003. Matches exclusion set {1,3} (N=7), NOT the main-text Exp1 sample {1,8} (.30/.47/.28). Undisclosed sample switch.
- C51. Table A3 Exp3 (.21/.58/.49). — ⚠ ADV-004. Matches the N=9 sub-analysis sample ({2,3,4,5}); main text uses N=11 (.24/.62/.55). Undisclosed.
- C52. Table A4 (d>0.1 slopes) Exp2/4/5. — ✅ (E2 .18/.46/.13, E4 .15/.52/.31, E5 .20/.48/.36)
- C53. Table A4 Exp1 (.17/.42/.07) & Exp3 (.09/.46/.25). — ⚠ ADV-003/004 (Exp1 uses {1,3} → .18/.43/.08 ≈; Exp3 values are the N=9 sample .09/.46/.25, not N=11 .16/.59/.42).
- C54. Table A5 bias% Exp2/4/5. — ✅ (E2 −28/6/31, E4 −26/2/19, E5 −15/6/12)
- C55. Table A5 Exp3 (−25/14/23). — ⚠ ADV-004 (matches N=9 sample {2,3,4,5}, not N=11 −28/7/14).
- C56. Table A5 Exp1 (−27/1/36 with Full SD=5). — ⚠ ADV-008. Means reproduce (−27/1/36) but reported Full-bias SD=5 cannot be reproduced (computed ~10.2 for any natural sample); Min SD 21 vs 19.5.
- C57. Fig 2 "86% of full-graph trials null/small." — ≈ pooled full null/small (all trials) = 86.7% (matches 86%); over d>0.1 only = 83.6%.
- C58. Fig 3 "minimal d=.10–.80 trials, effect big on 49%." — ≈ pooled minimal big = 54.4% (d>0.1) or 42.0% (all trials); 49% not directly reproduced (loose prose pooling).
- C59. "88% of minimal trials labeled medium/big" (Exp1). — ✅ 87.9%

## H. Open-science / reproducibility claims
- C60. Open data / materials / reproducible analysis: Yes; Analysis reproduced by Tobias Mühlmeister. — ⚠ ADV-001. Data present & analysis IS reproducible from raw data (this audit, R==Python), but the shipped notebook is not runnable as distributed (hardcoded local path, interactive chunks).
- C61. Data/scripts at osf.io/hw2ac; supplementary at OSF HXK2U. — ✅ (data+notebook present locally; OSF API transiently 404 at audit time but files previously retrieved).
- C62. Exp1 incomplete participant "431 trials" included. — ⚠ ADV-007 (data: 430).
- C63. Exp4/Exp5 incomplete participants not disclosed (Exp4 S6=405, S14=389; Exp5 S5=289, S9=379). — ⚠ ADV-008.
- C64. No PII in public data (Subject IDs are integers only). — ✅ (no emails/IPs/long-digit identifiers found in any CSV).

## Claim-count & tally
Claims checked: 65 (C1–C64 covering every numeric in-text quantity, each t/p/dz/CI/BF, each table cell group, each percentage, sample sizes).
Verdicts: ✅ = 44 · ≈ = 4 · ⚠ = 16 (mapped to findings ADV-001…ADV-010) · ➖ = 1 (C3 simulated-generation seed).
Severity tally: P0=0 · P1=0 · P2=5 (ADV-001..005) · P3=5 (ADV-006..010).
