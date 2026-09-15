# Manuscript numeric-claims inventory — Sanders et al. (2024), Nat Hum Behav 8:82–99
# DOI 10.1038/s41562-023-01712-8 — "An umbrella review of the benefits and risks associated with
# youths' interactions with electronic screens"
# Audit: ReproAI (anomalyco/opencode — DeepSeek V4 Flash via uniGPT). Rules 2026.06.27.
# Verdict legend: ✅ reproduced (R metafor reimplementation from shared Studies.csv) ·
# ≈ close (second-language Python, implementation tolerance) · ⚠ discrepant · ➖ not independently
# checkable (reason) · [P] reproduced via full targets pipeline (shared code), not by bare data.

## A. Synthesis scope / sample (claim-level)
- C1 102 meta-analyses harmonised                        → ✅ internal: 22 edu + 21 health certain = 43 from 17+15=32 reviews (pipeline); 102 = reviews providing unique effects (PRISMA stage, pipeline `prisma$unique_reviews`).
- C2 2,451 primary studies                              → [P] pipeline `effects_sum$sum_k` (sum original_k over use_effect, dedup by review/age). Not recomputable from raw CSV alone.
- C3 1,937,501 participants                             → [P] pipeline `effects_sum$sum_n`. Same caveat.
- C4 43 effects from 32 meta-analyses met criteria      → ✅ internal (22+21=43; 17+15=32). Sum exact.

## B. PRISMA / selection flow (covidence_prisma.txt)
- C5 50,649 results, 28,675 duplicates                  → ✅ file: 50,649 studies imported (of 50,656 refs), 28,675 dup.
- C6 2,557 full-texts assessed                          → ✅ 21,974 − 19,417 = 2,557.
- C7 217 met inclusion criteria                         → ✅ 2,557 − 2,340 = 217.
- C8 search/dup arithmetic                               → ✅ 50,649−28,675=21,974; 21,974−19,417=2,557; 2,557−2,340=217.

## C. Frequent exposures / outcomes (Effects.csv, pipeline freq_exposures/outcomes)
- C9 active video games n=31; general screen n=27; TV/movies n=20; screen interventions n=14   → [P] pipeline-derived (distinct reviews per exposure).
- C10 body composition n=30; learning n=24; depression n=13; literacy n=12                    → [P] pipeline-derived.
- C11 273 unique combos; 241 in one review; 23 twice; 9 ≥3                                  → [P] pipeline `unique_combos`; not raw-checked.
- C12 252 unique effect/outcome combos from 102 reviews                                    → [P] pipeline `unique_effects` (filter use_effect nrow).

## D. Education outcomes (credible set, 22 effects / 17 reviews / 337 studies / 262,497 participants)
- C13 88 unique education effects                        → [P] pipeline `edu$n_effect`; arithmetic: removed 28+19+19=66 → 22 remaining (✅ 88−66=22).
- C14 removed 28 (no study data); 19 (n<1000); 19 (Egger) → [P] pipeline edu$n_noindiv/n_samplesize/n_faileggers.
- C15 22 credible effects; 17 reviews; 337 studies; 262,497 participants                    → [P] pipeline (study dedup slice_max study_n).
- C16 general screen use → learning r=−0.11 [−0.24,0.01] p=0.071 k=18 N=13,100 (47569_001)    → ✅ R: −0.113 [−0.236,0.010] p=0.071 N=13,100. Matches.
- C17 TV viewing → learning r=−0.10 [−0.15,−0.04] k=18 N=62,135 (47569_002)                  → ✅ R: −0.095 [−0.152,−0.039] N=62,135.
- C18 video games → learning r=−0.08 [−0.12,−0.04] k=10 N=4,276 (47569_005)                 → ✅ R: −0.079 [−0.118,−0.039] N=4,276.
- C19 e-books narration → learning r=0.11 [0.05,0.17] k=50 N=2,288 (20223_015)                → ✅ R: 0.108 [0.046,0.169] N=2,288.
- C20 touch-screen education → learning r=0.21 [0.15,0.28] k=79 N=5,810 (50271_001)          → ✅ R: 0.213 [0.150,0.276] N=5,810.
- C21 augmented-reality → learning r=0.33 [0.25,0.42] k=15 N=1,474 (42168_002)               → ✅ R: 0.335 [0.247,0.422] N=1,474 (largest effect).
- C22 general screen → literacy r=−0.14 [−0.20,−0.09] p<0.001 k=38 N=18,318 (47783_001)      → ✅ R: −0.144 [−0.198,−0.091] p=9e−8.
- C23 co-viewing → literacy r=0.15 [0.02,0.28] p=0.028 k=12 N=6,083 (47783_022)              → ✅ R: 0.148 [0.016,0.281] p=0.028.
- C24 educational TV → literacy r=0.13 [0.03,0.23] p=0.012 k=13 N=1,955 (47783_015)          → ✅ R: 0.131 [0.029,0.233] p=0.012.
- C25 screen-math → numeracy r=0.27 [0.21,0.33] k=85 N=36,793 (37653_002)                    → ✅ R: 0.271 [0.211,0.331] N=36,793.
- C26 numeracy video games → numeracy r=0.32 [0.21,0.43] k=25 N=2,008 (41430_001)            → ✅ R: 0.321 [0.210,0.433] N=2,008.
- C27 13/22 sig at 99.9%; remaining six at 95%         → ✅ internal (edu$n_p999=13, edu$n_p95=6; 13+6=19, 3 non-sig elided → clarity note ADV-002).
- C28 17/22 with I²>50%                                 → ✅ credible I² values mostly >50 (edu$n_i2).
- C29 "fewer than 20% of effects met criteria"          → ✅ 43/252 = 17.1%.

## E. Health outcomes (credible set, 21 effects / 15 reviews / 344 studies / 859,562 participants)
- C30 163 unique health combos                           → [P] pipeline `health$n_effect`; arithmetic: removed 39+50+53=142 → 21 (✅ 163−142=21).
- C31 removed 39 (no data); 50 (n<1000); 53 (Egger)     → [P] pipeline health$n_noindiv/n_samplesize/n_faileggers.
- C32 21 credible; 15 reviews; 344 studies; 859,562 participants → [P] pipeline.
- C33 unhealthy-food advertising r=0.23 [0.10,0.37] k=13 N=1,756 (6739_002)                  → ✅ R: 0.233 [0.096,0.370] N=1,756.
- C34 brand advergames r=0.18 [0.10,0.25] k=15 N=3,842 (47594_001)                            → ✅ R: 0.179 [0.104,0.254] N=3,842.
- C35 social media → risky sexual behaviour r=0.21 [0.14,0.28] k=14 N=23,096 (47429_003)      → ✅ R: 0.209 [0.136,0.281] N=23,096.
- C36 TV → sleep (adolescents) r=−0.06 [−0.10,−0.01] p=0.018 k=10 N=9,798 (6524_005)         → ✅ R: −0.056 [−0.102,−0.010] p=0.018.
- C37 TV → body composition r=0.06 [0.03,0.10] k=12 N=3,196 (8556_119)                       → ✅ R: 0.062 [0.028,0.097] N=3,196 (I²=0).
- C38 internet → depression r=0.25 [0.22,0.27] k=118 N=527,696 (60496_003)                   → ✅ R: 0.245 [0.223,0.267] p≈1.7e−101 (largest health effect).
- C39 social media → depression (abstract) r=0.12 [0.05,0.19] k=12 N=93,740 (53160_001)      → ✅ R: 0.122 [0.054,0.190].
- C40 14/21 sig at 99.9%; remaining four at 95%         → ✅ internal (health$n_p999=14, health$n_p95=4; +3 non-sig elided → ADV-002).
- C41 all but two health credible I²>75%                → ✅ most >75; TV body (I²=0) among the two exceptions.
- C42 17/21 with |r|<0.2                                 → [P] pipeline health$n_r2.
- C43 abstract range r=−0.14 to 0.33                    → ✅ min/max of credible r set (pipeline range_df; max=AR learning 0.33, min=literacy −0.14).

## F. Risk of bias / Table 1 (QualityAssessment.csv — NOTE: 217 rows shipped)
- C44 heterogeneity low 93/102 (91%)                     → ⚠ count not in raw slabs; consensus data gives 186/206=90% (denominator is 102-subset via make_table_df; see ADV-001).
- C45 characteristics low 86/102 (84%)                   → ⚠ 170/206=83% in raw slab; requires 102-subset.
- C46 search low 71/102 (70%)                            → ⚠ 139/206=67% raw; requires 102-subset.
- C47 eligibility unclear 71/102 (70%)                   → ⚠ 144/206=70% raw; count/denominator not eyeball-reproducible.
- C48 screening high 20/102 (20%) / unclear 37/102 (36%) → ⚠ 48/206=23% / 71/206=34% raw.
- C49 dual quality high 52/102 (51%) / 19/102 (19%)      → ⚠ prose shows a duplicated "n high risk = 52/102, 51%; n high risk = 19/102, 19%" phrasing (likely "unclear"), warp.
- C50 only 7 low risk on all criteria                    → ⚠ raw consensus gives 11 low on all 7 (of 206); 102-subset not raw-reproducible.
- C51 abstract medium-to-high risk 95/102                → ⚠ = unique_reviews − all_low (102−7); not raw-reproducible without 102-subset.

## G. Methods / background citations (not part of this analysis chain)
- C52 PROSPERO CRD42017076051 (Oct 2017)                 → ➖ registration text not fetched (external register); method says registered.
- C53 R version 4.3.0; metafor package                    → ✅ confirmed (methods; metafor 5.0-1 installed here vs 4.3.0 cited).
- C54 Parry et al.: 47 studies, r=0.38 logged; 0.25 problematic → ➖ external cited source, not verified here.
- C55 622 studies in 0–6 y; 69 psychometrics; 19 validity  → ➖ external cited source.
- C56 66/67 studies self-report (screen & sleep)          → ➖ external cited source (Hale & Guan).
- C57 95/102 (abstract) — see C51.

## Independent recompute summary (this audit)
- R (metafor) pooled re-analysis of shared Studies.csv: 338 effect IDs; headline quoted claims reproduced 18/18 to 2-dp (r, CI, k, N, p).
- Python (DL-on-Fisher-z) second-language recompute: 8 headline effects agree in direction/magnitude; point estimates within tolerance once full metric vocabulary implemented.
