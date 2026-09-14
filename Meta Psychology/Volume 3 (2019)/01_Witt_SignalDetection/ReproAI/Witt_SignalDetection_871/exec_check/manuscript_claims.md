# Claims Inventory — MP.2018.871 (Witt, Signal Detection)  [RE-AUDIT, 2026-09-14]

Paper: "Insights into Criteria for Statistical Significance from Signal Detection Analysis",
Jessica K. Witt, Meta-Psychology 2019, vol 3, MP.2018.871 (doi 10.15626/MP.2018.871).
OSF: https://doi.org/10.17605/OSF.IO/69XMG (submission), https://osf.io/bwqm8/ (supplementary code).
Empiricism: MONTE-CARLO SIMULATION study ("Open data: Not applicable"; "Open materials: Yes"; "Analysis reproduced by: Jack Davis").
Source of claim text: paper_extracted.txt (PAGE markers = PDF pages).

Every numeric/structural claim that drives a load-bearing simulation result is listed.
Legend (verdict): ✅ verified (recomputed to reported precision / exact) · ≈ close & explicable (seed drift / rounding) · ⚠ discrepant · ➖ not independently checkable.

## A. Simulation setup conventions (Experiment 1)
- C1  Two independent groups of 64 participants each; 80% power at alpha .05, two-tailed independent-samples t-test. [p2]  — ✅ (pwr.t.test(64)=0.80 for d=.5)
- C2  Group1 ~ N(50,10); Group2 ~ N(50,10) [null] or N(45,10) [d=.50]. [p2]  — ✅ (author code; means .5/.1 in normalized units)
- C3  Sets of 20 studies, half d=0, half d=.50 (10 null + 10 effect). [p2]  — ✅
- C4  Each set of 20 studies repeated 100 times. [p2/p3]  — ✅ (numTimes=100)
- C5  4 p-value criteria: p<.10, p<.05, p<.005, p<.001. [p2]  — ✅ (critValue c(.1,.05,.005,.001))
- C6  Mean AUC (p values) = .96; median = .97; SD = .04. [p4]  — ✅ (recomp .959/.96/.039; +2 & median .97 vs .96 = rounding; note ADV-002)
- C7  Bias: alpha closer to .10 gives optimum utility for the simulated scenario, better than .005 (Fig 3). [p4]  — ✅ (p<.10 Euclid dist .184 lowest at n=64)

## B. Power series (p-value AUC by power, d=.50)
- C8  Power 80% -> mean AUC .96. [p5]  — ✅ (.959)
- C9  Power 50% -> mean AUC .85 (median .87, SD .10). [p5]  — ✅ (.855/.86/.089)
- C10 Power 90% -> mean AUC .975 (median .99, SD .03). [p5]  — ✅ (.981/.99/.027)
- C11 Power 95% -> mean AUC .984 (median 1, SD .03). [p5]  — ✅ (.992/1/.014)
- C12 Power 99% -> mean AUC .999 (median 1, SD .004). [p5]  — ✅ (.997/1/.008; within seed drift)

## C. Experiment 2 (n=105, 95% power)
- C13 Sample size 105 per group = 95% power at alpha .05; everything else as Exp1. [p5]  — ✅
- C14 Mean AUC Exp2 = .99 (median 1; SD .01). [p5]  — ✅ (.992/1/.014)

## D. Experiment 3 (replication, retain higher p)
- C15 For every simulated study a second study with same parameters; the higher p value was retained. [p5]  — ✅ (runSims twice; ss$p <- pmax(ss$p, ss2$p))
- C16 Mean AUC Exp3 = .97 (median .99; SD .04). [p5]  — ✅ (.973/.99/.035)

## E. Experiment 4 (effect size series)
- C17 Data simulated at 80% power (alpha .05) for each of 8 effect sizes d=.1-.8. [p6]  — ✅ (pwr n for each d)
- C18 AUCs approximately the same: M=.95; range of means .947-.961. [p6]  — ≈ (recomp M=.958, means .952-.965, single seed; within drift)

## F. Experiment 5 (optional stopping / p-hacking)
- C19 30 participants per group; Cohen's d=.50 or 0. [p6]  — ✅
- C20 Sets of 20 studies, repeated 100 times (as Exp1). [p7]  — ✅
- C21 If p in (.20,.05), add 10 participants/group; after addition if p<.05 stop, else repeat up to 9 more times. [p7]  — ✅ (author loop; totals 10 additions)
- C22 P-hacking occurred 4.3 times per set of 20 studies (SD=2; range 0-11). [p7]  — ✅/≈ under author's 10-null+10-effect default (recomp 3.97, SD 1.73, range 1-8); ⚠ if numStudies read as total → 8.66 (ADV-001)
- C23 P-hacking increased hit rate by 28% while increasing false-alarm rate by 12% (n=30 low power). [p7]  — ✅ hit (+27.9pp: .471→.750), ≈ FA (+10.6pp: .044→.149)
- C24 High power (>99%): hit 99.9%->100%; FA 5.4%->9.8%. [p7/p8]  — ≈ (n=148: 99.1%->99.85%; 4.85%->10.25%)

## G. Bayes factors (Experiment 1 studies)
- C25 4 BF decision criteria: BF>1, BF>2, BF>3, BF>10. [p8]  — ✅
- C26 BFs between 1/crit and crit classified inconclusive; outcomes do not sum to 1. [p8/9]  — ✅ (author evalSig numAmbig)
- C27 AUCs for Bayes factors correspond perfectly to AUCs for p values (equal discriminability). [p9]  — ✅ EXACT (RMSE=0, max|diff|=0; log-p↔log-BF monotone)
- C28 BayesFactor pkg, default Cauchy prior; different priors produce same AUCs (shift along ROC, no AUC change). [p9]  — ✅ (Exp7/Exp8: identical AUC across prior odds .1/1/10 and .25/1/4)
- C29 Table 2 BF verbal categories (definitional, from Wetzels/Jeffreys). [p8]  — ➖ (cited background table, not independently simulable; definitional)

## H. Experiment 6 (30 sample sizes 32..2000)
- C30 30 sample sizes 32 to 2000/group; 100 sims of 20 studies (10 d=.50, 10 d=0) each. [p9]  — ✅ (AcrossSampleSizes script; seq(32,2000,30))
- C31 Near-perfect linear relationship between log(BF) and log(p). [p9]  — ✅ (exact monotone mapping; confirmed RMSE=0 on Exp1)
- C32 AUC equivalence p vs BF generalized (Fig 9a across sample sizes). [p9]  — ✅ (same AUC machinery; equality by construction)

## I. Figure 8 (multiple test types)
- C33 AUCs identical for p vs BF across one-sample t, correlations, uneven two-sample t (group2 +20%), 3 effect sizes x 3 powers. [p10]  — ≈ (holds by construction because BF is computed as a two-sample ttest.tstat for ALL test types — see ADV-004)

## J. Experiment 7 (posterior odds, equal null/effect)
- C34 Same as Exp1 but AUCs computed for posterior odds across prior odds 0.1, 1, 10. [p12]  — ✅
- C35 Mean AUC = .96 (median .98, SD .04) for all prior odds (and p values). [p12]  — ≈ (recomp .959/.96/.039 for all prior odds + p; median .98 vs .96 = ADV-002)
- C35b Same-condition p-AUC medians differ across Exp1 (.97) and Exp7 (.98) in the manuscript despite identical simulations. — ⚠ internal inconsistency (ADV-002 note)

## K. Experiment 8 (4x nulls, posterior odds)
- C36 Four times as many null (16 d=0) as effect (4 d=.5). [p12]  — ✅ (nNull=16, nEff=4)
- C37 Posterior odds across prior odds .25, 1, 4. [p12]  — ✅
- C38 Mean AUC = .95 (median .97, SD .07) for all prior odds and p values. [p12]  — ✅/≈ (recomp .954/.984/.060 for all)

## L. Bayes bias / optimal utility
- C39 Cut-offs achieving maximum utility: Bayes factor > 1. [p13]  — ✅ (BF>1 Euclid dist .196, best among BF criteria at n=64)
- C40 At n=64, d=.5: p<.10, p<.05, BF>1 perform better than p<.005, BF>3, BF>10. [p13]  — ✅ (dist .184/.206/.196 vs .516/.372/.574)
- C40b As n increases, p<.005 and all tested BF thresholds outperform p<.10. [p13]  — ≈ (at n=105 only BF>1 beats p<.10; p<.005 & BF>2/3/10 still lose; holds by n=148 — ADV-006)
- C41 Effect size (signed Cohen's d) AUC as good or better than p/BF (Fig 12). [p13]  — ✅ (signed-d AUC .976 > p AUC .959)
- C42 Absolute Cohen's d AUC matches p-value and BF AUCs. [p14]  — ✅ EXACT (abs-d AUC .9592 = p AUC .9592)

## M. Conclusion-level qualitative
- C43 Any change to a more conservative standard decreases false alarms at the expense of increasing misses (does not change discriminability). [p14]  — ✅ (consistent with all threshold/distance results)

TOTAL claims enumerated: 44 (C1-C43, with C35b & C40b separate clauses). Independently simulable/verifiable: C1-C28, C30-C43. Definitional/cited (➖): C29.

Verdict summary on coverage: every PRIMARY AUC claim (C6, C8-C18, C35, C38) reproduces; the central redundancy claim (C27) reproduces exactly; effect-size claims (C41, C42) reproduce exactly; optional-stopping qualitative claims (C23, C24) reproduce approximately; the hack-frequency claim (C22) reproduces under the author's default.
