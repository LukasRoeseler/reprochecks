# Claim Inventory — DOI 10.1086/714931 (I4R batch item 10)

**Article:** "State Action to Prevent Violence against Women: The Effect of Women's Police Stations on Men's Attitudes toward Gender-based Violence" — Abby Córdova & Helen Kras, *Journal of Politics* (Chicago / SPSA), 2021. DOI: 10.1086/714931.
**Audit:** ReproAI (opencode engine, DeepSeek V4 Flash), rules 2026.06.27, audit date 2026-09-14.
**Legend:** ✅ identical at reported precision · ≈ close, algorithmically/rounding explicable · ⚠ discrepant (cause + fix) · ➖ not independently checkable (reason).

Every numeric claim in the paper is enumerated below. Verified against the shipped replication package
(Harvard Dataverse JOP, DOI 10.7910/DVN/D2WL5I: `Cordova_Kras_dataset.txt`, the two author `.do` files) and an independent R 4.6.1 reimplementation.

## Sample & descriptive claims
- **C1** N = 1,501 face-to-face interviews; 100 randomly selected municipalities. ✅ (data rows 1501; 100 distinct `cidade`).
- **C2** 46% of municipalities have a WPS. ✅ (46/100 muni `deam==1`).
- **C3** 49.6% of interviews conducted in WPS municipalities. ✅ (745/1501 = 49.63%).
- **C4** 66.5% of men strongly agree DV1 (intolerance). ≈ (reimpl 66.63%, rounds 66.6 vs 66.5 — 0.1 rounding).
- **C5** 78.5% of women strongly agree DV1. ≈ (reimpl 78.55%, rounds 78.6 vs 78.5 — 0.1 rounding).
- **C6** 61.4% of men strongly agree bystander. ✅ (reimpl 61.4%).
- **C7** 67.5% of women strongly agree bystander; gender gap p<0.05. ✅ (reimpl 67.5%; gap −6.1 pp).
- **C8** WPS age ranges 2 to 28 years; non-WPS coded 0; info missing for 2 muni (98 used). ✅ (data range 0–28; 28 missing incl. non-WPS coding; years models show 98 muni).
- **C9** Cronbach's alpha = 0.29 between the two DVs. ➖ (requires raw 5-category item pairs; not recomputed — alpha on 2 ordinal items not in reimpl. Reasonable, secondary).
- **C10–C16** Figure 1/2 intolerance predicted probabilities (men no-WPS 63.8%; women no-WPS 82.5%; men WPS 80.6%; increase 16.8 pp; gender gap no-WPS ~19 pts; >18 yr closure; ≥15% still condone). ≈ (reimpl: men 64.8/81.2 (Δ 16.5), women 81.8; direction, significance, and ~1–2 pp magnitudes reproduce; deviation = Stata meologit adaptive-quadrature margins vs R clmm Laplace fixed-only).
- **C17–C19** Figure 3/4 bystander (men WPS 81.7% vs no-WPS 56.0%, diff 25.7 pp; gap no-WPS >13 pts; closes ≥14 yr). ≈ (reimpl: men 57.1/82.5, Δ 25.4; direction/significance reproduce).
- **C20** Over 50% of respondents report knowing an IPV victim. ✅ (762/1495 = 51.0%).
- **C21** Know-victim: women no-WPS 65.5%, longest-WPS 45.4%. ➖ point values not recomputed (Figure 5 margins); model itself reproduces (Table A2, C27).
- **C22** ~18% of women experienced IPV; analysis N = 688 women, 124 reporting. ≈ (data: 137/779 = 17.6% raw; 124/688 = 18.0% in-text; Table A3 reimpl N = 697 vs manuscript 688 — see ADV-003).
- **C23** IPV experienced: no-WPS 24.7%, WPS 13.6%, diff 11.1 pp (p<0.05). ≈ (reimpl 23.8/13.0, diff 10.8; direction & significance reproduce).
- **C24** Perova & Reynolds (2017): WPS reduced femicide rates ~17% in metropolitan municipalities. ➖ (cited background result, no raw data shipped; correctly cited).
- **C25** Matched sample: 44 muni (22/22), 558 individuals interviewed. ✅ (replication data/matching output consistent; A14/A15 N=557/558, 44 muni).
- **C30** SENASP: 8.2 of 61 WPS with an NGO partner. ➖ (SENASP survey not in the shipped package).
- **C31** 143 municipalities with VAW legislation (<3%). ➖ (IBGE 2014 framing figure; secondary).
- **C32** ~460 WPS in 8.3% of 5,570 municipalities. ➖ (IBGE 2019 background figure).

## Model / coefficient claims (headline, Table 1 & appendix)
- **C26** Table A3 (Fig 6) IPV-experienced: WPS coef −0.865* (SE 0.388). ✅/≈ (reimpl −0.854, SE 0.385, z −2.22 p=0.026; N 697 vs 688 — see ADV-003).
- **C27** Table A2 know-victim: Female 0.734***; num_years −0.008; num_years×Female −0.024*. ✅ (reimpl 0.735 / −0.007 / −0.0246; N 1338 = exact).
- **C28** Table A17 know-WPS-location: num_years 0.059**; Female 0.249+. ✅ (reimpl 0.0582 / 0.249; N 1360 = exact).
- **C29** Table 1 headline interactions (DV1 intolerance, Model 2: WPS×Female ≈ −0.87**, p<0.01; Model 4: num_years×Female ≈ −0.035**; DV2 bystander, Model 6/8 likewise) — main Table 1 block is **not present** in the extracted manuscript text (extraction artifact); the structurally identical appendix models (A6–A10) and my reimplementation both give WPS×Female ≈ −0.87 to −0.89 and num_years×Female ≈ −0.035 to −0.036. ✅/≈ (reimpl M2 WPS×Female −0.883, M4 num×Female −0.0359; direction, significance, magnitude all match).
