# ReproAI — Manuscript Claims Inventory
**Paper:** Adida, Combes, Lo & Verink (2016), "The Spousal Bump: Do Cross-Ethnic
Marriages Increase Political Support in Multiethnic Democracies?", *Comparative
Political Studies* 49(5): 635–661. DOI 10.1177/0010414015621080.
**Auditor:** DeepSeek V4 Flash via uniGPT (anomalyco/opencode ReconAI engine).
**Audit date:** 2026-09-14. **Rules:** 2026.06.27. **Mode:** static + internal-consistency.

## Legend
- ✅ consistent/arithmetically verified (internal consistency at reported precision)
- ≈ close / methodologically explainable
- ⚠ discrepant
- ➖ not independently checkable (no raw data/replication package obtainable) — reason given

## Benin survey experiment (Cotonou, Aug 2012; N_total_analyzed = 158 + 189 = 347)
| ID | Claim (page/text) | Verdict | Note |
|----|-------------------|---------|------|
| C1 | Control: 71% non-coethnics vs 19% Chantal coethnics vote for Yayi; >50pp gap, sig beyond 99% (pp. 645) | ✅ (internal) | 71.43−19.35 = 52.08pp; step-significant claim not recomputable beyond published p ➖ for headline p |
| C2 | T1 coethnics: Control 19.35 (n=62); Wife 13.33 (n=45); Fon 41.18 (n=51) | ✅ | counts (12,6,21) reconstruct pcts to <0.06pp; n sum 158 |
| C3 | T1 non-coethnics: Control 71.43 (n=56); Wife 57.58 (n=66); Fon 55.22 (n=67) | ✅ | counts (40,38,37); n sum 189 |
| C4 | T1 coethnics diffs: W−C −6.02 p=.41; F−C +21.82 p=.01; F−W +27.84 p=.00 | ✅ | recomputed diffs & approx two-proport z p match; headline p not now recomputable on raw ➖ |
| C5 | T1 non-coethnics diffs: −13.85 p=.11; −16.20 p=.06; −2.35 p=.79 | ✅ | as above |
| C6 | T2 coethnics: Fon wife b=0.22** (0.08) → 0.21** (0.08); R² .07/.13; Obs 158 | ➖ | OLS on raw respondent data not available |
| C7 | T2 non-coethnics: −0.16 (0.09) → −0.19* (0.09); R² .02/.10; Obs 189 | ➖ | as above |
| C8 | "Fon ... increase their support by more than 20 percentage points" after Fon-wife cue (p. 646) | ✅ | matches F−C +21.82pp |
| C9 | cosmopolitan ruled out: cue effect positive ONLY for Fon; non-coethnics see NS decrease | ✅ (direction) | consistent with T1 signs (DR1) |
| C10 | Instrumental: ~1/3 say Yayi favors Southerners; only 9% of those Fon; Fon 9.8%→13.7%; p=.513 | ➖ | denominators not published; p not recomputable |
| C11 | Manipulation: 100% coethnics / 98% non-coethnics identify Chantal's ethnicity; cue NS | ➖ | no raw counts (SI-5) |
| C12 | Context: Benin ~10M; 2006 run-off ~75% | ➖ | external background, not audited pipeline |

## Afrobarometer cross-national analysis (Rounds 3 & 4)
| ID | Claim | Verdict | Note |
|----|-------|---------|------|
| C13 | leader cross-ethnic marriage in >half of countries, ~half of country-rounds | ✅ (internal) | 8/14, 12/25 |
| C14 | T3 country unit: pop cross-ethnic rate 0.128/0.240; ELF .791/.741; PREG .433/.405; pop 19,052/32,659; Polity 3.5/5.4; N 6/8 | ✅ (internal) | consistent with prose 24%/13%; underlying DHS/EPR data ➖ |
| C15 | T3 country-round unit: leader grp .317/.509; spouse grp .317/.582; N 11/9 & 13/12 | ✅ (internal) | "larger by 8pp" ≈ 7.3pp in-cross-column (ADV-002) |
| C16 | 8 of 14 AB countries, 12 of 25 tenures cross-ethnic | ✅ | arithmetic holds |
| C17 | spouse coethnicity ~23% of AB respondents, slightly higher than leader coethnicity | ➖ | SI-3; AB data not obtained |
| C18 | T4 Vote: 0.03* / 0.04** (0.01) | ➖ | AB raw data not obtained; cannot recompute regression |
| C19 | T4 Job performance: −0.13** / −0.05 (0.02/0.03) | ➖ | as above |
| C20 | T4 Ethnic political power: 0.01 / 0.02 (0.03) | ➖ | as above |
| C21 | T4 Ethnic unfair: −0.00 / −0.03 (0.03) | ➖ | as above |
| C22 | "spouse coethnics are 4.3 percentage points more likely ... most restrictive model" | ≈ | T4 Vote+SES b=0.04**; 4.3pp implies b≈0.043; rounded display consistent, not independently verifiable |
| C23 | Full-sample support 53% / 60% / 65% (non/spouse/leader coethnics) | ➖ | SI-3/note 29; no raw data |
| C24 | note 17: AB Fon 29% support Yayi; spouse-coethnics 47% overall, 37% when opponent coethnic, 51% when not | ➖ | no raw data |
| C25 | balance achieved (SI-4); logit & bootstrapped robustness results hold | ➖ | robustness outputs "available on request" only |

**Summary:** 25 claims enumerated; 25 verification events generated + 50 internal-consistency
operations across ~8 tables/directional statements. Headline Benin experiment (C6–C7) and all
Afrobarometer regression results (C18–C21) are `➖` because no raw data or replication package is
obtainable (see risk register ADV-001).
