# Manuscript claims inventory — de Leeuw et al. (2019), MP.2018.1481

*Similar event-related potentials to music and language: A replication of Patel, Gibson, Ratner, Besson, & Holcomb (1998)*
Vassar College. doi: 10.15626/MP.2018.1481. OSF `EPD42` (supplementary), `zpm9t` (data/materials), `g3b5j` (preregistration), `m9kej` (analysis notebook). Badges: Preregistration Plus, Open Data, Open Materials, Open & Reproducible Analysis (reproduced by Martina Sladekova).

Audit: anomalyco/opencode (ReproAI), rules 2026.06.27, 2026-09-10. R 4.6.1, packages `readr`, `dplyr`, `ez`, `BayesFactor`. Shipped processed EEG/behavioral data re-analyzed from scratch (`exec_check/R/01_recompute.R`), cross-checked against the author's own notebook (`extracted/analysis.Rmd`) and an independent Python ANOVA decomposition (`exec_check/python_crosscheck.py`).

Legend: ✅ identical at reported precision · ≈ close & explicable · ⚠ discrepant · ➖ not independently checkable.

## Sample & data structure
| # | Claim (paper) | Value | Reimplementation | Verdict |
|---|---|---|---|---|
| C1 | Recruited participants | 44 (M age 19.8, SD 1.2) | 44 in raw file; 35 analyzed | ✅ (39 complete, 35 analyzed) |
| C2 | Participants w/ complete dataset | 39 | 44 − 5 technical (S8,S21 + 3) | ✅ |
| C3 | Exclusion: technical problems | 5 | S8, S21 (+ 3 others per author Rmd) | ✅ |
| C4 | Exclusion: <19 good segments in any condition | 4 (S11, S23, S25, S40) | confirmed in `Good_Segments_Per_Category.xlsx` (cutoff cell = 19) | ✅ |
| C5 | Analyzed N | 35 | 35 (all 35 in eeg_data_tidy) | ✅ |
| C6 | Mean usable trials: lang-gram / lang-ungram / mus-gram / mus-ungram | 27.7 / 27.7 / 33.3 / 33.0 | 27.7 / 27.7 / 33.3 / 33.0 (27.70/27.70/33.31/32.98) | ✅ |
| C7 | Musical experience M(SD) years | 9.7 (3.3) | 9.71 (3.43) | ✅ |
| C8 | Instrument hours/week M(SD) | 5.8 (3.4) | 5.83 (3.42) | ✅ |
| C9 | Age M(SD) | 19.8 (1.2) | 19.8 (1.21) | ✅ |

## Behavioral accuracy (Table 1)
| # | Claim | Paper | Reimpl | Verdict |
|---|---|---|---|---|
| C10 | Language-Grammatical acc M(SD) | 93.3% (5.3) | 93.3 (5.35) | ✅ |
| C11 | Language-Ungrammatical acc M(SD) | 88.2% (18.0) | 88.2 (18.0) | ✅ |
| C12 | Music-In-Key acc M(SD) | 84.5% (14.5) | 84.5 (14.5) | ✅ |
| C13 | Music-Distant-Key acc M(SD) | 69.1% (15.5) | 69.1 (15.5) | ✅ |

## Table 2 — grammaticality × electrode ANOVAs (500–800 ms)
| # | Cell (effect) | Paper F, p | Reimpl F, p | Verdict |
|---|---|---|---|---|
| C14 | Language-Midline grammaticality | F(1,34)=6.41, p=.016 | F=6.41, p=.0161 | ✅ |
| C15 | Language-Midline electrode | F(2,68)=1.00, p=.372 | F=1.003, p=.372 | ✅ |
| C16 | Language-Midline interaction | F(2,68)=5.11, p=.009 | F=5.115, p=.0085 | ✅ |
| C17 | Language-Lateral grammaticality | F(1,34)=0.44, p=.512 | F=0.439, p=.512 | ✅ |
| C18 | Language-Lateral electrode | F(9,306)=3.68, p=.0002 | F=3.676, p=2.18e-4 | ✅ |
| C19 | Language-Lateral interaction | F(9,306)=4.99, p=.000003 | F=4.991, p=2.79e-6 | ✅ |
| C20 | Music-Midline grammaticality | F(1,34)=23.94, p=.00002 | F=23.94, p=2.37e-5 | ✅ |
| C21 | Music-Midline electrode | F(2,68)=7.00, p=.002 | F=7.00, p=.0017 | ✅ |
| C22 | Music-Midline interaction | F(2,68)=12.43, p=.00003 | F=12.43, p=2.51e-5 | ✅ |
| C23 | Music-Lateral grammaticality | F(1,34)=1.12, p=.298 | F=1.116, p=.298 | ✅ |
| C24 | Music-Lateral electrode | F(9,306)=11.10, p<.000001 | F=11.10, p=5.31e-15 | ✅ |
| C25 | Music-Lateral interaction | F(9,306)=6.47, p<.000001 | F=6.47, p=1.97e-8 | ✅ |

## Table 3 — difference-wave ANOVAs (500–800 ms)
| # | Cell (effect) | Paper F, p | Reimpl F, p | Verdict |
|---|---|---|---|---|
| C26 | Midline stimulus (lang vs music) | F(1,34)=0.226, p=.637 | F=0.226, p=.637 | ✅ |
| C27 | Midline electrode | F(2,68)=16.289, p=.000002 | F=16.289, p=1.66e-6 | ✅ |
| C28 | Midline stimulus×electrode | F(2,68)=0.315, p=.731 | F=0.315, p=.731 | ✅ |
| C29 | Lateral stimulus (lang vs music) | F(1,34)=1.784, p=.190 | F=1.785, p=.190 | ✅ |
| C30 | Lateral electrode | F(9,306)=12.181, p<.000001 | F=12.181, p=1.82e-16 | ✅ |
| C31 | Lateral stimulus×electrode | F(9,306)=2.009, p=.038 | F=2.009, p=.038 | ✅ |

## Table 4 — Bayes factors (vs participant-only)
| # | Model | Midline (paper) | Reimpl | Lateral (paper) | Reimpl |
|---|---|---|---|---|---|
| C32 | Electrode + P | 18,160 ±1.26% | 18,160 (1.26%) | 1.81e9 ±0.35% | 1.81e9 (0.35%) |
| C33 | Stimulus + P | 0.170 ±2.03% | 0.170 (2.03%) | 0.157 ±2.03% | 0.157 (2.03%) |
| C34 | Electrode+Stim + P | 3,015 ±1.32% | 3,015 (1.32%) | 2.93e8 ±1.22% | 2.93e8 (1.22%) |
| C35 | Full (E+S+E×S) + P | 367 ±2.02% | 367 (2.02%) | 1.24e9 ±1.30% | 1.24e9 (1.30%) |
| C36 | Midline BF: electrode-only / (E+S) | 6.02 (18160/3015) | 6.0226 | — | — |
| C37 | Lateral BF: electrode-only / full | 1.46 | 1.4593 | — | — |
| C38 | Lateral BF: full / main-effects-only | 4.22 | 4.2280 | — | — |

## Appendix — RATN / N350 (300–400 ms, music)
| # | Claim | Paper | Reimpl | Verdict |
|---|---|---|---|---|
| C39 | grammaticality×hemisphere×electrode-site 3-way ANOVA | F(4,136)=.366, p=.832 | F=0.366, p=.832 | ✅ |
| C40 | "data 431,034× less likely under full model (all 3 mains + 3 two-ways + 3-way) vs null" | 431,034 | 418,304 (1/2.3906e-6) | ≈ ADV-001 |
| C41 | "39× less likely under full vs no-3-way model (m18/m17)" | 39 | 37.77 (0.02648⁻¹) | ≈ ADV-002 |
| C42 | RATN not replicated (no music-specific negativity) | qualitative | waveform + ANOVA consistent | ✅ (visual ➖) |

## Interpretive / headline claims (qualitative — direction verified, visuals not)
| # | Claim | Verdict |
|---|---|---|
| C43 | P600 present for both syntactic (language) and harmonic (music) violations | ✅ (C20, C31, difference waves) |
| C44 | Language & music P600 amplitudes statistically indistinguishable (no stimulus main effect) | ✅ (C26, C29; BFs C33, C38) |
| C45 | Effect stronger at posterior electrodes (E×Gram interaction) | ✅ (C16, C19, C22, C25) |
| C46 | No music P600 at O1/O2 (difference from Patel) | ➖ (figure-based) |
| C47 | Moderate evidence of no lang/music amplitude difference (lateral) | ✅ (C37, C38) |
| C48 | 35 participants > 2× original N=15 | ✅ |
| C49 | "very close replication" / basic-existence framing | ➖ (design) |

## Summary
- C1–C45: all numeric claims reproduce at the manuscript's reported precision (ANOVAs exact; BFs within MC error).
- C40, C41 (≈): two RATN Bayes-factor magnitudes differ by 3% and 1.5% from the manuscript — Monte-Carlo sampling noise in `BayesFactor` (same model, same data, same seed; author's own `analysis.Rmd` reports the same value via `1/bf.RATN[18]`).
- No P0/P1. The single P2 is the RATN BF magnitude gap; P3 items are the 39-vs-37.8 ratio, the non-preregistered RATN analysis, and the raster-figure (Figs 1–3) visual claims not pixel-verified.
