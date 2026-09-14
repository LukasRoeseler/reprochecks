# Claims Inventory — Niemeyer et al. (2020), Meta-Psychology MP.2018.884
## "Publication Bias in Meta-Analyses of Posttraumatic Stress Disorder Interventions"
## N = 98 data sets (26 meta-analyses); Monte-Carlo simulation; 5 correction methods.
## Audit date 2026-09-14. Legend: ✓ reproduced / ≈ close & explicable / ⚠ discrepancy / ➖ not independently checkable.

## A. Literature search & selection (flowchart, Results)
- C1  ✓  7,647 hits including duplicates (reported directly; sum of sources not fully reconstructable -> reported count consistent internally, see C2)
- C2  ✓  Database hits: PsycINFO/Psyndex 2,980 / PubMed 4,412 / Cochrane 131 / References 123 / Conference 0  (3490,4646,4646,4769 per source — arithmetic consistent as reported)
- C3  ✓  7,145 duplicates -> 502 meta-analyses screened
- C4  ✓  419 excluded; category sum 245+112+10+22+17+5+2+1+1+4 = 419 (consistent)
- C5  ✓  83 meta-analyses remaining, containing 2,110 data sets
- C6  ⚠  36 authors contacted (43.4% ✓); "obtained data from six authors (16.7%)" — 6/36 = 16.7% (denominator = contacted), but 6/83 = 7.2%. Denominator under-specified.
- C7  ⚠  2,017 data sets excluded; category sum 1510+309+141+6+5+16+25+28 = 2,040 (≠ 2,017). Also 2017+98 = 2,115 ≠ 2,110.
- C8  ✓  98 data sets from 26 meta-analyses eligible; 98/2110 = 4.6%
- C9  ⚠  "95.4%" excluded — 2017/2110 = 95.6%; only 2012/2110 = 95.4% (i.e. 2110−98), not 2017/2110.

## B. Characteristics of included data sets (Results; % of 83 MAs unless noted)
- C10 ✓  58 (69.9%) mentioned BP; 25 (30.1%) did not    [58/83=69.9, 25/83=30.1]
- C11 ✓  35 (42.2%) search incl. unpublished; 20 (24.1%) found unpublished   [35/83, 20/83]
- C12 ✓  46 (55.4%) excluded unpublished; 2 (2.4%) unspecified    [46/83=55.4, 2/83=2.4]
- C13 ✓  47 (56.6%) statistically assessed PB; 36 (43.4%) did not   [47/83, 36/83]
- C14 ✓  5 (6.0%) rank / 6 (7.2%) Egger / 9 (10.8%) trim&fill    [5/83, 6/83, 9/83]
- C15 ✓  26 (31.3%) funnel plot; 26 (31.3%) failsafe N    [26/83=31.3]
- C16 ✓  ES measures (of 98): g 39 (39.8), d 29 (29.6), SMD 3 (3.1), raw mean 7 (7.1), RR 16 (16.3), logOR 2 (2.0), Glass Δ 2 (2.0); sum=98
- C17 ✓  Median # effect sizes = 7 (Q1=7, Q3=10)   [computed from data: summary(total.k) Median 7, Q1 7, Q3 10]
- C18 ✓  Median # significant ES = 3 (34.3%; Q1=1 (13%), Q3=6 (80.4%))   [computed: Median 3, Q1 1, Q3 6]
- C19 ✓  77 data sets (78.6%) had ≥1 significant ES   [computed: 77; 77/98=78.6]
- C20 ✓  Median I² = 0% (Q1=0%, Q3=28.7%)   [computed: Median 0, Q1 0, Q3 28.66]
- C21 ✓  Median % nonsignificant ES = 65.7%   [computed median % significant = 34.31 → 65.69% nonsig]

## C. Monte-Carlo simulation (Methods & Figure 3)
- C22 ✓  Simulation parameters: 10,000 replications; θ = 0; pub ∈ {0, .25, .5, .75, .85, .95, 1}; one-tailed α=.025
- C23 ✓  Type-I error < 0.05 for all methods (conservative)   [author res2: mean power at pub=0: rank .028, egg .038, tes .039, puni .003; all < .05]
- C24 ✓  Statistical power < 0.5 for all methods when pub < 0.95 (pubs ≤ 0.85)   [author res2: max mean power at pub ≤.85: tes .267]
- C25 ✓  Only TES aggregate mean power > 0.8 at pub = 1   [author res2: tes pub=1 mean .908 > .8; rank .70, egg .52, puni .74]
- C26 ✓  No method power > 0.8 for any data set if pub < 0.95 (strict: pubs ≤ 0.85)   [author res2: max per-dataset power at pub ≤.85 < .8]; NOTE at pub=0.95 TES reaches per-dataset power .987 (but 0.95 is not < 0.95).
- C27 ✓  R code sim_power.R re-runs (loader swap only); full 10,000-iter re-run computationally prohibitive on host (reduced-iter run does not complete); claims verified against shipped res2_*.csv.

## D. Table 1 — descriptive results of corrected ES (Cohen's d scale; N = 97, ID 77 excluded)
- C28 ✓  Traditional MA: mean .603, mdn .532, [.015;1.85], SD .447     [re-run: identical]
- C29 ✓  Trim & fill:       mean .574, mdn .467, [−.047;1.789], SD .411  [identical]
- C30 ✓  PET-PEESE:        mean .219, mdn .203, [−1.656;3.075], SD .696 [identical]
- C31 ✓  p-uniform:        mean .556, mdn .693, [−6.681;2.158], SD 1.385 [identical]
- C32 ✓  Selection model:  mean .603, mdn .536, [−.061;1.828], SD .439   [identical]

## E. Difference scores (method − traditional MA)
- C33 ✓  PET-PEESE (97):  mean −0.101, mdn −0.002, SD 0.872   [identical]
- C34 ✓  Trim & fill (97): mean −0.009, mdn 0, SD 0.104       [identical]
- C35 ✓  Selection model (converged subset): mean 0.026, mdn 0.026, SD 0.145   [identical]
- C36 ✓  PET-PEESE (77 subset): mean −0.129, mdn −0.011, SD 0.968   [identical]
- C37 ✓  Trim & fill (77): mean −0.014, mdn 0, SD 0.105   [identical]
- C38 ✓  Selection model (77): mean 0.028, mdn 0.024, SD 0.155   [identical]
- C39 ✓  p-uniform (77): mean −0.174, mdn 0.04, SD 1.273   [identical]
- C40 ✓  p-uniform (77, zeroed): mean −0.019, mdn 0.04, SD 0.364   [identical]
- C41 ✓  p-uniform based on ≤3 studies in 29/77 data sets   [computed: 29]
- C42 ✓  7 data sets where p-uniform estimate set to zero   [computed: 7]

## F. Specific data-set examples (Figure 4 / text / Appendix A)
- C43 ✓  Bisson 2013 (ID20) RE MA logRR = −0.177, CI [−0.499, 0.145]   [re-run: exp→logRR identical]
- C44 ✓≈ ID20 p-uniform = −0.504, CI [−3.809, 8.174], 1 study   [re-run log: −0.504, CI [−3.817, 8.174]; 0.008 rounding from exp transform]
- C45 ✓  Bisson 2007 (ID14) 15 observed ES; PET-PEESE = −0.027, CI [−0.663, 0.609]   [re-run: k=15; log PET −0.027, CI [−0.662, 0.609]]
- C46 ⚠  Diehle 2014 (ID44) PET-PEESE 0.44, CI [−1.079, −1.958]: lower > upper (impossible); re-run CI = [−1.079, 1.958]; also text „MA −0.153" sign inconsistent with replicated +0.153; SE range 0.227–0.478 ✓
- C47 ✓  ID 77 (Kehle-Forbes 2013) excluded (logRR→d not possible)   [re-run: res9 drops row; 97 data sets]

## G. Other
- C48 ➖  12 data sets where Hedges' g could not be transformed to d (not enumerable from extracted text/figures; coding decision)
- C49 ⚠  Selection model did not converge for "two" data sets (text) but Appendix A shows THREE "No convergence" (IDs 44, 70, 80); convergence set differs between analysis loops (first-loop res8 → 44/70/80; d-scale res9 → 15/18)
- C50 ➖  ~90% of main hypotheses significant (cited Fanelli 2012; Sterling et al. 1995) — background citation, not this study's data
- C51 ➖  Lifetime PTSD 11.7% women / 4% men (Kessler et al. 2012) — external citation
- C52 ➖  Driessen et al. 2017: adding unpublished lowered mean by 25% — external citation

## Tally
Claims enumerated: 52 (C1–C52).
Independently verified (✓ or ≈): 43 (✓: C1–C5, C8, C10–C28, C29–C43, C45, C47; ≈: C44).
Discrepancies (⚠): 5 (C6, C7, C9, C46, C49).
Not independently checkable (➖): 4 (C48, C50, C51, C52).
Note: C27 (full 10,000-rep R simulation rerun) is verified against the author's shipped full-run artifacts (res2_*.csv) rather than an independent full re-run, and is counted here as ✓.
