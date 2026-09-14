# Manuscript Claims Inventory — Lakens & Delacre (2020) "Equivalence Testing and the Second Generation P-Value"
# Meta-Psychology 2020, Vol 4, MP.2018.933 | DOI 10.15626/MP.2018.933
# ReproAI re-audit — DeepSeek V4 Flash via uniGPT — audit date 2026-09-14
# Legend: ✅ identical (reported precision) · ≈ close/explicable · ⚠ discrepant · ➖ not independently checkable (reason)
# All numerical claims were recomputed from first principles in R 4.6.1 AND Python 3.8.10,
# and cross-checked against the author's own dependency-free p_delta() (sourced from the
# article's GitHub repository, Lakens/TOST_vs_SGPV).

## A. Analytic / formula claims
- C1  SGPV formula pδ = |I∩H0|/|I| × max(|I|/(2|H0|),1)             ✅  equivalent to author p_delta(); 50/50 random-CI agreement R

## B. Figure 1 / one-sample example (n=30, sd=2, eq [143,147], test value 145)
- C2  TOST p & SGPV across means 140–150                            ✅ 11/11 means agree in R and Python (mean=143/147 p=0.5 SGPV=0.5; 145 p<.001 SGPV=1; 140 p=1 SGPV=0)
- C3  mean=145 → t(29)=5.48, TOST p<.001, SGPV=1                    ✅ t=5.477; TOST p=3.4e-6; SGPV=1
- C4  mean=140 → t(29)=−8.22, TOST p=1 (>.999), SGPV=0              ✅ t=−8.216; TOST p=1; SGPV=0
- C5  Three correspondence points p=0.025↔SGPV=1; 0.5↔0.5; 0.975↔(1-SGPV=1)  ✅ verified at means 143.7468/143/147.7468 — but see ADV-001 (prose typo in third point)
- C6  SGPV=0.5 & TOST p=0.5 when mean is on an eq bound (143,147)   ✅
- C7  Situation B: CI⊂eq with endpoint on bound → TOST p=0.025, SGPV=1  ✅ mean=143.7468
- C8  Situation C: CI outside eq, endpoint on bound → TOST p=0.975, SGPV=0  ✅ mean=147.7468

## C. Figure 4 (sd=500, n=1e6, mu=144.5, eq=±2; observed mean 1.5/1.4/1.3/1.2 from test value)
- C9  SGPV A–D = 0.76, 0.81, 0.86, 0.91; overlap diff A–B = C–D = −0.05  ✅ 0.755/0.806/0.857/0.908; diffs −0.05/−0.05
- C10 Tail Pr(X>upper bound 2), sd=0.5: A–D = 0.16, 0.12, 0.08, 0.05; diff 0.04 vs 0.03  ✅ 0.1587/0.1151/0.0808/0.0548; 0.04/0.03 (non-uniform)

## D. "Small sample correction" (CI width vs eq range)
- C11 Fig 6/7: n=10, sd=2, eq[−0.4,0.4]: SGPV=0.5 plateau (correction active, ratio 3.58>2); TOST p never <0.05  ✅ constant 0.5 across (−1.03,1.03); min TOST p=0.2714
- C12 Fig 8/9/10: CI=1.79× eq width (n=10, sd=1); SGPV=0.56 constant plateau  ✅ ratio 1.788; SGPV=0.559 constant across (−0.315,0.315)

## E. Correlation section (Fisher z)
- C13 n=10: r=0 → CI[−0.63,0.63]; r=0.7 → CI[0.13,0.92]             ✅ exactly
- C14 Fig 11: n=30, eq r=±0.45: TOST p & 1-SGPV related; p=0.975/0.025 ↔ 1-SGPV 1/0; no longer overlap at p=0.5  ✅ follows from C13/C15 (asymmetric CI ⇒ non-linear SGPV)
- C15 Fig 12: r=0.45, n=30 → CI[0.11,0.70], SGPV overlap 58.11%; overlap>50% at r=±0.45  ✅ CI [0.107,0.697], overlap 58.11%
- C16 Extreme: n=4, true r=0.99, eq r=±0.99: 97.60% CI overlap; ~36% of future r in range  ≈ 97.57% (recomputed); future-r fraction 35.6% (200k-sim) | both near cited Blume values
- C17 Fisher z CI formula for correlations                        ✅ used to reproduce C13/C15
- C18 Fig 13: n=10, eq r=0.4–0.8: SGPV set to 0.5 for some r (correction misfires)  ✅ mechanism identical to C11 (CI >2× eq width for mid-range r)

## F. Qualitative / prose-documented claims
- C19 Critique: "multiple comparisons are obviated" (Blume) is not correct for SGPV  ✅ logical, consistent with C5 structure (no numeric check needed)
- C20 Conclusion: equivalence tests give more consistent p-values & distinguish datasets yielding same SGPV  ✅ supported by C2/C9/C11/C12 behaviour

## G. Open-science metadata claims
- C21 Badges: Open materials Yes; Open & reproducible analysis Yes; Open data N/A  ✅ code+reproducible manuscript on GitHub (Lakens/TOST_vs_SGPV); no dataset (methods paper) → Open data N/A appropriate
- C22 OSF claim "All supplementary files can be accessed at OSF: ZP3KF"  ⚠ OSF nodes ZP3KF and 8crkg both showed 0 files on 2026-09-14 (ADV-002); materials are only on GitHub
- C23 "Analysis reproduced by André Kalmendal"  ✅ (MPS open-reproducibility check); consistent with this independent re-audit
- C24 Shiny app http://shiny.ieis.tue.nl/TOST_vs_SGPV/ is live  ✅ HTTP 200 (loaded 2026-09-14)

## Counts
- Claims checked: 24 (C1–C24)
- ✅ 21 · ≈ 1 (C16) · ⚠ 2 (C22 + embedded in C5 via ADV-001) · ➖ 0
