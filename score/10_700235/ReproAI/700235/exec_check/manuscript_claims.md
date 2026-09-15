# Claim Inventory — Usmani (2018), "Democracy and the Class Struggle"
DOI 10.1086/700235 · American Journal of Sociology 124(3):664–704 · audited 2026-09-14

Legend: ✅ verified (internal, where possible) · ≈ close/methodologically explicable · ⚠ discrepant ·
➖ not independently checkable (no replication package/data/code was shipped or linked in the article).

## A. Sample/coverage & Table 1 (no raw data → external recompute impossible)
| ID | Claim | Manuscript | Recompute/Extract | Verdict |
|----|-------|-----------|------------------|---------|
| C1  | Novel dataset "almost 200 countries", 1754–2012 | 179 countries (Table 1) | 179 in Table 1 | ≈ (abstract says "almost 200"; tabled =179) |
| C2  | Disruptive capacity N country-years / with Polity2 | 8,668 / 7,610 | — | ➖ no data |
| C3  | Manufacturing share N | 6,203 / 4,947 | — | ➖ |
| C4  | Strikes per capita N | 5,282 / 4,378 | — | ➖ |
| C5  | Strike frequency N | 5,030 / 4,343 | — | ➖ |
| C6  | Strike freq/worker N | 4,486 / 4,012 | — | ➖ |
| C7  | Strike vol/cap N | 4,444 / 3,709 | — | ➖ |
| C8  | Strike volume N | 4,283 / 3,684 | — | ➖ |
| C9  | Strike vol/worker N | 3,833 / 3,450 | — | ➖ |
| C10 | Labor rights index N | 3,425 / 2,848 | — | ➖ |
| C11 | Potential labor power N | 2,874 / 2,746 | — | ➖ |
| C12 | Union members/cap N | 2,629 / 2,448 | — | ➖ |
| C13 | Union membership N | 2,581 / 2,426 | — | ➖ |
| C14 | Union density N | 2,506 / 2,387 | — | ➖ |
| C15 | Strikes/cap "only 60% of the coverage of disruptive capacity" | 60% | 4,378/7,610 = 57.5% | ≈ (rounding overstatement; minor) |
| C16 | Union-data availability bias "42 points higher (0–100)" | 42 | Table 1 ΔAvg column = 142 | ⚠ (finding ADV-002) |

## B. Table 2 descriptive statistics (preferred samples) — no data
| ID | Variable | Avg / SD / within-SD | Verdict |
|----|----------|---------------------|---------|
| C17 | Polity2 score | 67.32 / 34.66 / 19.71 | ➖ (within<overall ✓ internal) |
| C18 | Electoral democracy | 52.35 / 29.17 / 15.85 | ➖ (within<overall ✓) |
| C19 | GDP per capita (log) | 8.13 / .93 / .44 | ➖ (within<overall ✓) |
| C20 | Growth rate | 1.96 / 5.17 / 4.69 | ➖ (within<overall ✓) |
| C21 | Disruptive capacity | 19.90 / 8.37 / 3.35 | ➖ (within<overall ✓) |
| C22 | Educational attainment | 6.13 / 2.97 / 1.63 | ➖ (within<overall ✓) |
| C23 | Urbanity | 229.47 / 142.19 / 69.26 | ➖ (within<overall ✓) |
| C24 | Landlord power | 27.37 / 19.72 / 10.20 | ➖ (within<overall ✓) |
| C25 | Income inequality | 36.71 / 9.95 / 3.00 | ➖ (within<overall ✓) |
| C26 | within-SD < overall SD all 9 rows | holds | holds 9/9 | ✅ (internal) |

## C. Figure 1 validation (mobilization indicators) — no data
| ID | Claim | Manuscript | Verdict |
|----|-------|-----------|---------|
| C27 | DC → union 0.91 SD (α=.10); strike freq 0.24 SD (α=.01); strike vol 0.08 SD (α=.05) | as stated | ➖ no data/figure embedded data |
| C28 | r(disruptive capacity, GDP pc) = 0.62 | 0.62 | ➖ |

## D. Polity-IV context
| ID | Claim | Manuscript | Verdict |
|----|-------|-----------|---------|
| C29 | 2014: 4 lowest (SA, Bahrain, N.Korea, Bhutan), 35 highest | 4 / 35 | ➖ (no PolityIV file shipped) |
| C30 | 201 sovereign states, some as early as 1800 | 201 | ➖ |

## E. Model/sample (Table 3 model info; col order 6,5,4,3,2,1)
| ID | Claim | Manuscript | Recompute | Verdict |
|----|-------|-----------|-----------|---------|
| C31 | DC "as many as 104 countries 1821–2013"; landlord "145 countries 1859–2008" | col1 104/1821-2013; col2 145/1859-2008 | matches | ✅ (internal) |
| C32 | Preferred models fewer countries/less time | col6 = 64 / 4,437 / 1871–2003 (fewest) | matches | ✅ (internal) |

## F. Table 3 Long-Run Estimates, Polity2 (semistandardized, dynamic FE panel) — no raw data
| ID | Claim | Manuscript | Verdict |
|----|-------|-----------|---------|
| C33 | DC col1 bivariate | 2.978** [1.01,5.08] | ➖ (est↔CI mid ≈ internal) |
| C34 | DC col3 social-forces | 2.624** [.68,4.68] | ➖ |
| C35 | DC col6 preferred | 4.168** [1.35,6.94] | ➖ |
| C36 | Landlord negative & ** in cols 2,3,6 | −5.8/−5.5/−4.9 approx, ** | ⚠ direction ✓ (sign negatives unambiguous); exact magnitudes ➖ (mirrored-PDF transcription) |
| C37 | GDP pc never statistically significant | col3/4/6 ns | ✅ (internal: CIs include 0, no stars) |
| C38 | Education ns in Polity2 model | ns | ✅ (internal) |
| C39 | Income inequality all positive (not negative) | col4 +0.516, col6 +2.061 | ✅ (internal, matches prose "positive") |
| C40 | Regional avg predict democratization (col6) | 5.471** [1.18,9.69] | ➖ |

## G. Table 4 Long-Run Estimates, Electoral Democracy — no raw data
| ID | Claim | Manuscript | Verdict |
|----|-------|-----------|---------|
| C41 | DC col6 preferred | 2.812** [.69,5.08] | ➖ |
| C42 | Landlord col6 negative ** | ≈ −6.0** | ⚠ direction ✓; magnitude ➖ |
| C43 | Education sig only in ED model (col4) | 11.938* [.67,25.13] | ✅ (internal, matches prose "significant at α=.05 in ED") |
| C44 | Income inequality positive & ~significant | col4 +1.377† | ✅ (internal) |

## H. Counterfactual political-significance exercises (no data)
| ID | Claim | Manuscript | Internal check | Verdict |
|----|-------|-----------|----------------|---------|
| C45 | Brazil gains ~46 democracy-years ≈ 83% of observed ≈ twice as democratic | 46 / 83% | 46/0.83≈55 yrs; 55+46≈2×55 | ≈ (internally consistent) |
| C46 | Decomposition 63% landlords / 37% nonelites | 63/37 | sums to 100 | ✅ (internal) |
| C47 | Avg developing country gain 29 (Polity2)/19 (ED) democracy-years ≈ 54% (52%) | 29 / 54% | 29/0.54≈54 yrs | ≈ |
| C48 | Gap 49 (Polity2) / 35 (ED) fewer years | 49 / 35 | consistent | ≈ |
| C49 | ~57% (Polity2)/54% (ED) of the gap explained ("slightly more than half") | 57%/54% | 49/0.57≈86, 35/0.54≈65 | ≈ (internally consistent; Fig.4 caption "~50–60%") |
| C50 | Fig.4 caption "roughly 50%–60% of the gap closed" | 50–60% | consistent w/ 57/54 | ✅ (internal) |

Summary counts (excluding sub-rows inside multi-claim rows): **50 claims**.
No claim requiring raw data could be independently reproduced because the article ships no replication
package and provides no OSF/Dataverse/GitHub/Zenodo/data-availability link anywhere in its full text.
