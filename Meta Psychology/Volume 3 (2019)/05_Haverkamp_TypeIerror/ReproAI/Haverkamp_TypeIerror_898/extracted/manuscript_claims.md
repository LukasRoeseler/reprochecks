# Manuscript claim inventory — Haverkamp & Beauducel (2019), MP.2018.898
## RE-AUDIT 2026-09-14 — regenerated fresh (replaces the 2026-09-10 audit inventory)

Paper: "Differences of Type I error rates for ANOVA and Multilevel-Linear-Models using
SAS and SPSS for repeated measures designs." *Meta-Psychology*, 3, article MP.2018.898,
doi:10.15626/MP.2018.898. OSF project `em62j`. Badges: Open Materials (verified);
Open & reproducible analysis (reproduced by Jack Davis). Not preregistered.

Legend: ✅ identical / reproduced at reported precision · ≈ close & methodologically
explicable · ⚠ discrepant / not exactly reproducible (cause given) · ➖ not independently
checkable (concrete reason).

---

## Design claims (p.5–6, "Material and methods")

| ID | Claim | Manuscript source | Verification | Verdict |
|----|-------|-------------------|--------------|---------|
| C1 | 144 conditions = sphericity[2] × methods[9] × n[4] × m[2] | p.6 | 9 methods (rANOVA S/SPSS, rANOVA-HF S/SPSS, MLM-CS S/SPSS, MLM-UN S/SPSS, MLM-KR SAS); 2×9×4×2=144 | ✅ arithmetic |
| C2 | 5,000 samples per condition | p.5/7 | help-block partitioning in population_9/12.sps (`by helpXX` in SAS, split in SPSS); not re-runnable at full S in open tooling | ⚠ stated & scripted, not fully executed |
| C3 | m = 9 and 12 occasions; n = 15/20/25/30 | p.5/6 | population_*.sps + analysis scripts confirm | ✅ |
| C4 | Population: no within/between effect; corr .50 (holds); corr .50 even / .80 odd (violation, Eq. 4) | p.6, Eqs 1–4 | population_9/12.sps: x_t = √(1−.5)z+√.5 c1 (holds); c1..c6 (odd) corr .8, even-t x's corr .5 | ✅ matches scripts |
| C5 | α=.05; Bradley (1978) robust range [.025,.075]; >.075 liberal, <.025 conservative | p.7 | used as stated | ✅ |
| C6 | Table 1 Google Scholar hits: SPSS 2070 / SAS 1790 / Stata 984 / R 512 (9 Sept 2018) | p.3 | search date- & engine-dependent; query string given but not re-run | ➖ |
| C7 | Table 2 smallest sample sizes of prior MLM simulation studies | p.4 | cited external values from prior papers; not independently recomputable | ➖ |

## Results claims (Figs 1–4 prose)

| ID | Claim | Manuscript | Reimplementation (R 4.6.1) | Cross-lang (Py 3.8) | Verdict |
|----|-------|-----------|---------------------------|---------------------|---------|
| C8 | rANOVA ≈5% when sphericity holds (both packages, all m/n) | p.7/8 | S=2000: holds 4.30–5.95% | 4.15–5.90% | ✅ |
| C9 | rANOVA inflated (>5%) under sphericity violation | p.8 | violation 6.8–8.3% | 6.5–9.0% | ✅ |
| C10 | rANOVA-HF ≈5% under sphericity holds | p.7/8 | 3.90–5.60% | 3.75–5.65% | ✅ |
| C11 | rANOVA-HF corrects violation back to ≈5% | p.8 | 4.80–6.55% | 4.60–6.70% | ≈ mostly nominal |
| C12 | MLM-UN progressive *liberal* bias for small n, stronger in SPSS than SAS | p.7–9, Fig 1–3 | m9/n15 = 0.33–0.35; m12/n15 = 0.68 | m9/n15 = 0.39 | ✅ magnitude; ⚠ SPSS>SAS split not verifiable in R/Py (one algorithm) |
| C13 | MLM-UN bias increases from m=9 to m=12 (different ordinate) | p.8 | m9/n15 ≈ .35 → m12/n15 ≈ .68 | consistent | ✅ |
| C14 | MLM-CS ≈5% when sphericity holds (both packages) | p.7–9 | holds 3.7–5.7% | 4.7–7.0% | ✅ / ≈ |
| C15 | MLM-CS conservative bias under violation (m=9, SAS); SPSS near liberal edge | p.9/12 | violation 1.7–4.0% (conservative) | 0.3–4.0% (conservative) | ⚠ SAS-side reproduced; SPSS-side split not representable in R/Py |

## Table 3 (m=12, sphericity holds; additional n=100 sub-simulation, p.10)

| ID | Claim | Manuscript | Reimplementation | Verdict |
|----|-------|-----------|------------------|---------|
| C16 | MLM-UN SAS: n=15 56.33%, n=30 19.56%, n=100 7.76% | Table 3 | R m12/n15 = 68% (S=50); m12/n100 = 6.7% (S=30) | ⚠ magnitude/order reproduced; exact value not bit-matching (no SAS) |
| C17 | MLM-SAT SAS ≡ MLM-UN SAS (56.33/19.56/7.76) | Table 3 | no SAS; implies Satterthwaite ≙ SAS default for this design | ➖ (SAS-only logic) |
| C18 | MLM-KR SAS: n=15 36.87%, n=30 9.86%, n=100 5.66% | Table 3 | KR not representable as distinct from CS in R lmer reimpl | ➖ |
| C19 | MLM-UN SPSS: n=15 69.42%, n=30 24.66%, n=100 8.80% | Table 3 | R m12/n15 = 68% (close to SPSS 69.42%) | ⚠ proximity only; no SPSS |

## Discussion / implications

| ID | Claim | Manuscript | Verification | Verdict |
|----|-------|-----------|--------------|---------|
| C20 | MLM-UN uncorrected liberal under every simulated condition (Bradley) | p.11–12 | all R-evaluated UN cells liberal (35%, 68%, 6.7% at n=100) | ✅ direction |
| C21 | MLM-KR for 9 occasions only drops the liberal bias for n>25; for 12 occasions not for n≤30 | p.12 | KR-as-UN not representable in R lmer reimpl | ➖ |
| C22 | MLM-CS conservative under violation specific to SAS (m=9) | p.12 | R/Py give overall-conservative MLM-CS violation (SAS side) | ⚠ partial |
| C23 | Prefer MLM-CS or rANOVA under sphericity, HF under violation | p.12 | consistent with reproduced nominal rANOVA/MLM-CS, corrected HF | ✅ supported |

---

## Reproduction status summary
- **rANOVA / rANOVA-HF (C8–C11):** REPRODUCED (R S=2000 two seeds AND Python S=2000 two seeds — cross-language agreement). Nominal under sphericity, inflated under violation, HF corrects.
- **MLM-UN (C12–C13, C16, C19, C20):** magnitude of the progressive liberal bias REPRODUCED in R (0.33/0.35 at m9/n15; 0.68 at m12/n15; 0.067 at m12/n100) and in Python (0.39 at m9/n15). The m12/n15 R value (0.68) brackets Table 3's SAS 56.33% / SPSS 69.42%. Exact per-cell Table 3 percentages and the SPSS>SAS split remain software-specific and unarchived ⇒ ⚠ (not refuted, not bit-matched).
- **MLM-CS (C14–C15):** ≈5% under holds reproduced; conservative under violation (SAS side) reproduced; SPSS-side split not representable.
- **MLM-KR (C18, C21):** not independently representable in the R lmer reimplementation (Kenward–Roger on an UN model is distinct from MLM-CS); would require SAS/SPSS or an UN-fit with ddf="Kenward-Roger".

## Findings keyed to this inventory
- ADV-001 (P2): exact Table 3 per-cell Type I error percentages and the SAS-vs-SPSS split not bit-reproducible (proprietary software, no raw data/output on OSF); magnitude confirmed.
- ADV-002 (RE-SCINDED as a previous-audit FALSE POSITIVE): no prose-vs-Table inconsistency; the p.7–8 "close to five per cent" refers to MLM-CS and rANOVA, never to MLM-UN.
- ADV-003 (P2): reproducible-analysis badge not fully supported — per-condition result tables (which the SPSS scripts write to .sav) and population .sav files were not uploaded.
- ADV-004 (P2): shipped SAS m=9 sphericity-violation MLM blocks reference C:\Pop_long_violation _12.sav (stray space + wrong suffix) — copy-paste defect that makes the exact m=9 MLM-violation input ambiguous.
- ADV-005 (P3): MLM-UN full grid computationally infeasible at S=5000 in open tooling (~14–30 s/fit at m=12).
- ADV-006 (P3): Figs 1–4 raster, per-condition numbers not tabulated; auditor model has no image input.
- ADV-007 (P3): R reimpl cannot distinguish MLM-KR(UN) from MLM-CS.
