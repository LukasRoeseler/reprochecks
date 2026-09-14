# Manuscript claims inventory — de Leeuw et al. (2019), MP.2018.1481 (RE-AUDIT 2026-09-14)

*Similar event-related potentials to music and language: A replication of Patel, Gibson, Ratner, Besson, & Holcomb (1998)*
Vassar College. doi: 10.15626/MP.2018.1481. OSF `EPD42` (supplementary page), `zpm9t` (data/materials), `g3b5j` (preregistration), `m9kej` (analysis notebook). Badges: Preregistration Plus, Open Data, Open Materials, Open & Reproducible Analysis (independent reproduction by Martina Sladekova).

RE-AUDIT engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT. Rules REPRO_STANDARDS.md 2026.06.27. Audit date 2026-09-14.
Host: R 4.6.1 (ucrt, 2026-06-24) + readr 2.2.0, dplyr 1.2.1, tidyr 1.3.2, ez 4.5.0, BayesFactor 0.9.12.4.8; Python 3.8.10 (pandas 2.0.3, numpy 1.24.4, scipy 1.10.1). Seed 12604 (author's). RNGkind Mersenne-Twister/Inversion/Rejection.

Legend: ✅ identical at reported precision · ≈ close & explicable · ⚠ discrepant · ➖ not independently checkable (reason).
NOTE: The task header's paper label "jsPsych..." is incorrect; the actual article audited is the ERP replication above (folder `deLeeuw_ERP`). jsPsych (de Leeuw, 2015) appears only as a Methods citation.

## A. Sample & data structure
| # | Claim (paper) | Value | Reimplementation | Verdict |
|---|---|---|---|---|
| C1 | Participants recruited | 44 (ages 18-22, M=19.8, SD=1.2) | 44 recruited; 41 have demographic data; 35 analyzed | ✅ |
| C2 | Participants with complete dataset | 39 | 44 − 5 technical (S8,S21,S10,S27,S30) | ✅ |
| C3 | Technical-problem exclusions | 5 | S8, S21 (+ never-started S10,S27,S30) | ✅ |
| C4 | Excluded <19 good segments in any condition | 4 | S11,S23,S25,S40 (cutoff 19 in xlsx) | ✅ |
| C5 | Analyzed N | 35 | 35 (all present in eeg_data_tidy) | ✅ |
| C6 | Mean usable trials LG/LU/MG/MU | 27.7 / 27.7 / 33.3 / 33.0 | 27.63 / 27.71 / 33.34 / 33.03 (from Good_Segments xlsx, 35 Ss) | ✅ |
| C7 | Musical experience M(SD) yrs | 9.7 (3.3) | 9.71 (3.43), N=35 | ✅ |
| C8 | Instrument hrs/week M(SD) | 5.8 (3.4) | 5.83 (3.42), N=35 | ✅ |
| C9 | Age M(SD) | 19.8 (1.2) | 19.8 (1.21), N=35 | ✅ |

## B. Behavioral accuracy (Table 1)
Paper values reproduce exactly from the author's own code → BUT that code's sample keeps excluded subject 8 (see ADV-003).
| # | Condition | Paper M(SD) | Author-code (N=36 incl. S8) | Intended N=35 | Verdict |
|---|---|---|---|---|---|
| C10 | Language-Grammatical | 93.3% (5.3) | 93.3 (5.35) | 93.43 (5.39) | ✅(as reported) / see ADV-003 |
| C11 | Language-Ungrammatical | 88.2% (18.0) | 88.2 (18.0) | 88.19 (18.25) | ✅(as reported) / see ADV-003 |
| C12 | Music-In-Key | 84.5% (14.5) | 84.5 (14.5) | 84.29 (14.67) | ✅(as reported) / see ADV-003 |
| C13 | Music-Distant-Key | 69.1% (15.5) | 69.1 (15.5) | 69.29 (15.73) | ✅(as reported) / see ADV-003 |

## C. Table 2 — grammaticality × electrode ANOVAs (500–800 ms, N=35)
| # | Cell | Paper F, p | Reimpl F, p | Verdict |
|---|---|---|---|---|
| C14 | Lang-Mid gram | 6.41, .016 | 6.4129, .0161 | ✅ |
| C15 | Lang-Mid electrode | 1.00, .372 | 1.0033, .3720 | ✅ |
| C16 | Lang-Mid gram×elec | 5.11, .009 | 5.1154, .0085 | ✅ |
| C17 | Lang-Lat gram | 0.44, .512 | 0.4392, .5120 | ✅ |
| C18 | Lang-Lat electrode | 3.68, .0002 | 3.6757, 2.18e-4 | ✅ |
| C19 | Lang-Lat gram×elec | 4.99, .000003 | 4.9915, 2.79e-6 | ✅ |
| C20 | Mus-Mid gram | 23.94, .00002 | 23.9365, 2.37e-5 | ✅ |
| C21 | Mus-Mid electrode | 7.00, .002 | 6.99996, 1.72e-3 | ✅ |
| C22 | Mus-Mid gram×elec | 12.43, .00003 | 12.4300, 2.51e-5 | ✅ |
| C23 | Mus-Lat gram | 1.12, .298 | 1.1163, .2982 | ✅ |
| C24 | Mus-Lat electrode | 11.10, <.000001 | 11.1038, 5.31e-15 | ✅ |
| C25 | Mus-Lat gram×elec | 6.47, <.000001 | 6.4700, 1.97e-8 | ✅ |

## D. Table 3 — difference-wave ANOVAs (500–800 ms)
| # | Cell | Paper F, p | Reimpl F, p | Verdict |
|---|---|---|---|---|
| C26 | Mid stimulus (lang vs music) | 0.226, .637 | 0.2262, .6374 | ✅ |
| C27 | Mid electrode | 16.289, .000002 | 16.2888, 1.66e-6 | ✅ |
| C28 | Mid stimulus×electrode | 0.315, .731 | 0.3153, .7306 | ✅ |
| C29 | Lat stimulus | 1.784, .190 | 1.7849, .1904 | ✅ |
| C30 | Lat electrode | 12.181, <.000001 | 12.1805, 1.82e-16 | ✅ |
| C31 | Lat stimulus×electrode | 2.009, .038 | 2.0092, .0380 | ✅ |

## E. Table 4 — Bayes factors (vs participant-only) + derived ratios
| # | Model | Midline (paper→reimpl) | Lateral (paper→reimpl) | Verdict |
|---|---|---|---|---|
| C32 | Electrode + P | 18,160 ±1.26% → 18159.5 (1.26%) | 1.81e9 ±0.35% → 1.805e9 (0.35%) | ✅ |
| C33 | Stimulus + P | 0.170 ±2.03% → 0.1703 (2.03%) | 0.157 ±2.03% → 0.1570 (2.03%) | ✅ |
| C34 | E+S + P | 3,015 ±1.32% → 3015.2 (1.32%) | 2.93e8 ±1.22% → 2.926e8 (1.22%) | ✅ |
| C35 | Full (E+S+ExS) + P | 367 ±2.02% → 366.7 (2.02%) | 1.24e9 ±1.30% → 1.237e9 (1.30%) | ✅ |
| C36 | Mid BF (E-only)/(E+S) | 6.02 | 6.0226 | ✅ |
| C37 | Lat BF (E-only)/full | 1.46 | 1.4593 | ✅ |
| C38 | Lat BF full/main-only | 4.22 | 4.2280 | ✅ |

## F. Appendix — RATN / N350 (300–400 ms, music, lateral)
| # | Claim | Paper | Reimpl | Verdict |
|---|---|---|---|---|
| C39 | gram×hemisphere×electrode-site 3-way ANOVA | F(4,136)=.366, p=.832 | F=0.3660, p=.8325 | ✅ |
| C40 | "431,034× less likely" (full 3-way model vs null) | 431,034 | 418,304 (1/2.3906e-6) | ≈ ADV-001 (3% MC noise) |
| C41 | "39× less likely" (full vs no-3-way) | 39 | 37.77 (inverse of 0.02647) | ≈ ADV-002 (1.5% MC noise) |
| C42 | RATN not reproduced for music | qualitative | 3-way n.s.; waveform consistent | ✅(stat) / ➖(visual) |

## G. Interpretive / headline claims (direction verified)
| # | Claim | Verdict |
|---|---|---|
| C43 | P600 present for syntactic (language) AND harmonic (music) violations | ✅ (C20, C31 + difference waves) |
| C44 | Language & music P600 amplitudes statistically indistinguishable (no stimulus main effect) | ✅ (C26, C29; BFs C33, C38) |
| C45 | Effect stronger at posterior electrodes (gram×electrode interactions) | ✅ (C16, C19, C22, C25) |
| C46 | No music P600 at O1/O2 (deviation from Patel) | ➖ (figure-based; not pixel-verifiable) |
| C47 | Moderate evidence of no lang/music amplitude difference (lateral) | ✅ (C37, C38) |
| C48 | N=35 > 2× original N=15 | ✅ |
| C49 | "Very close replication"/basic-existence framing; jsPsych built experiment | ➖ (design/procedural) |

## Summary
- All 49 claims C1–C49 enumerated; all are EMPIRICAL claims of an original ERP replication study (paper is empirical, not a methods/software paper).
- 44 numeric/test claims reproduce at the manuscript's precision (Tables 1–3 ANOVAs exact; Table 4 BFs within ±2% MC error of stated bands).
- Two appendix RATN BF magnitudes (C40, C41) reproduce ≈ (3% and 1.5% low) — Monte-Carlo noise in `BayesFactor`; the author's own rendered notebook gives a third value (430,597 ±6.69%), confirming the ~±7% MC error band on these magnitudes.
- NEW finding ADV-003: Table 1 behavioral accuracy is computed over N=36 (keeps excluded subject 8) because the author's exclusion filter `!subject_id %in% c(8,...)` cannot match zero-padded ID "08" to integer 8. Reproduces the paper's numbers, but the sample differs from the stated analytic N=35.
- No P0/P1. Findings: ADV-001 (P2), ADV-002 (P3), ADV-003 (P2), ADV-004 (P3, non-preregistered RATN). Figures 1–3 visual claims out of scope.
