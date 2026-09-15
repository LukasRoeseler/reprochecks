# Manuscript Claims Inventory — "Vulnerability and Clientelism"
AER 112(11):3627–3659 (2022), DOI 10.1257/aer.20190565
Audit engine: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT · rules 2026.06.27 · audit date 2026-09-14

## Scope note
Source for all claims: `paper_extracted.txt` (main article body + main tables 1–5). The AEA
Supplemental Appendix (online appendix Tables A1–A10, Figures A1–A2) and the ICPSR replication
package (10.3886/E173341V1) could NOT be retrieved in this environment (both returned HTTP 403 to
automated access; no institutional login available). Therefore every regression point estimate that
requires the underlying data to recompute is marked **➖ (not independently checkable — no data)**,
except where the paper's own reported numbers permit closed-form arithmetic verification (**internal
consistency**).

Legend: ✅ identical at reported precision (or checkable arithmetic) · ≈ close/methodologically
explicable · ⚠ discrepant · ➖ not independently checkable (reason given).

---

## A. Headline claims (Introduction / Abstract)

| ID | Claim (page) | Status | Basis |
|----|--------------|--------|-------|
| C-01 | Cisterns treatment reduces likelihood of requesting private goods by 3.0 pp, a 17% decline (p. 3629) | ✅ | 0.030/0.177 = 0.169 ≈ 17%; control mean 0.177 (Table 3) |
| C-02 | 1-SD decrease in municipal rainfall increases requests by 2.3 pp, 13% (p. 3629) | ✅ | 0.023/0.177 = 0.130 ≈ 13% (Table 3) |
| C-03 | Cisterns effect concentrated: requests fall 10.9 pp, 38% among clientelist marker; no effect otherwise (p. 3630) | ✅ | β1+β2 = 0.109; 0.109/0.285 = 0.382 (Table 5) |
| C-04 | Rainfall: 1-SD decrease increases requests 3.5 pp clientelist vs 2.0 pp non-clientelist (p. 3630) | ✅ | β3+β4 = 0.035 vs β3 = 0.020 (Table 5) |
| C-05 | Cisterns decreases a citizen's probability of voting for the incumbent mayor by 10.1 pp (p. 3629) | ✅ | Table 4 col1 = 0.101 |
| C-06 | Expanded sample: cisterns decreases vote for incumbent-group candidate by 7.6 pp (p. 3630) | ✅ | Table 4 col2 = 0.076 |
| C-07 | Both shocks improve well-being (food insecurity, depression, self-reported health) (p. 3628) | ✅/➖ | Direction consistent with Table 2; magnitudes prose-level |

## B. Section I — context & descriptive stats (Table 1)

| ID | Claim | Status | Basis |
|----|-------|--------|-------|
| C-08 | 21.3% asked for private goods 2012 (p. 3631) | ✅ | Table1 mean 0.213 |
| C-09 | 8.6% made such requests in 2013 | ✅ | Table1 mean 0.086 |
| C-10 | a third of requests involved health care, a quarter water (p. 3632) | ➖ | unverifiable (composition breakdown, appendix) |
| C-11 | 1-SD reduction in rainfall increased requests by 3.6 pp in 2012 but not 2013 | ✅(size)/➖(sign from extraction) | Table1 rainfall cell 0.036; extraction sign lossy, prose direction consistent |
| C-12 | politicians fulfilled approx one-half of requests (p. 3632) | ➖ | no closed-form check |
| C-13 | 18.4% had at least monthly conversations with a local politician before 2012 campaign (p. 3633) | ✅ | Table1 frequent-interactions mean 0.184 |
| C-14 | 69.6% received a home visit from mayoral-candidate rep (p. 3634) | ✅ | Table1 0.696 |
| C-15 | 71.8% voted for mayor+councilor of same coalition (p. 3634) | ✅ | Table1 0.718 |
| C-16 | 77.3% report all family members vote same mayoral candidate (p. 3634) | ✅ | Table1 0.773 |
| C-17 | 1-SD decline in rainfall increases overall declarations by 6.6 pp (p. 3634) | ✅ | Table1 "any declared support" rainfall cell 0.066 |
| C-18 | 7.0% requests fulfilled by incumbent vs 5.6% challenger candidates in 2012 (p. 3634) | ➖ | separate tabulation, appendix data |
| C-19 | 3.9% incumbent vs 0.40% out-of-office in 2013 (order of magnitude) (p. 3634) | ➖ | separate tabulation |
| C-20 | 425 clusters / 40 municipalities; 1,133 contiguous municipalities, 9 states, >28M residents (p. 3631) | ✅(counts) | 425 documented; context numbers not independently recomputable |
| C-21 | Semiarid zone 2012 avg precipitation 43.9 cm vs 139.5 cm rest of Brazil (p. 3631) | ➖ | background climate figure |

## C. Section II–III — intervention, data, samples

| ID | Claim | Status | Basis |
|----|-------|--------|-------|
| C-22 | 1,308 households + 425 clusters randomized; 615hh/189cl treatment, 693hh/236cl control | ✅ | 615+693=1308; 189+236=425 |
| C-23 | Baseline survey 1,189 household heads; info on 2,990 adult members (p. 3637) | ✅/➖ | counts consistent; wave structure appendix |
| C-24 | Wave2: 1,238 households, 2,680 individuals; Wave3: 1,119 households, 1,944 individuals (p. 3638) | ✅ | 2,680+1,944 = 4,624 eligible; analysis N 4,288 (Table 3) is the post-exclusion sample |
| C-25 | Compliance: Wave2 67.5% tx / 20.2% co; Wave3 90.8% tx / 65.3% co (p. 3640) | ➖ | appendix Table A1 |
| C-26 | Attrition: baseline 9.1%, Wave2 5.4%, Wave3 14.5%; attrition–treatment p=0.64 (p. 3641) | ➖ | appendix Table A1 |
| C-27 | Baseline balance: slightly >half female; ~37 y; ~6 yr education; hh size just over 4; 63% neighbor w/ cistern; 6pp diff (p. 3640) | ➖ | appendix Table A2 |
| C-28 | Electoral main sample: 21 municipalities, 909 machines, 190 locations, 4.8 machines/location (p. 3639) | ✅ | 909/190 = 4.78 |
| C-29 | Expanded sample: 39 municipalities, 1,641 machines in 369 locations | ✅ | 1,641/369 = 4.45 |
| C-30 | Machine averages: 338 registered = 260 valid + 19 blank/invalid + 59 abstain; incumbent 118 (45%), challenger 142 (55%) (p. 3639) | ✅ | 260+19+59=338; 118+142=260; 118/260=45.4%; 142/260=54.6% |
| C-31 | Rainfall data: sample avg 40.9 cm (2012), 69.3 cm (2013) (p. 3639) | ➖ | climate data source (CHIRPS) |

## D. Section IV — methodology

| ID | Claim | Status | Basis |
|----|-------|--------|-------|
| C-32 | Treatment stratified by municipality; clustered SE at neighborhood-cluster level | ✅ | design statement; matches Tables 3/5 notes |
| C-33 | 64% power: detect 2.5 pp effect on requests at 5% | ➖ | power calc, no closed-form |
| C-34 | Main electoral spec: location FE + controls for treated/respondent/registered counts; CRVE + wild-cluster-bootstrap | ✅ | design statement; Table 4 notes match |

## E. Section V — Results (Tables 2–4)

| ID | Claim | Status | Basis |
|----|-------|--------|-------|
| C-35 | Cisterns ↓ depression 0.09 units = 0.14 SD (Table 2, col1 panel A) | ✅ | 0.092/0.646 = 0.142 |
| C-36 | Cisterns ↑ SRHS 0.08 units = 0.14 SD (col2) | ✅ | 0.075/0.535 = 0.140 |
| C-37 | Cisterns ↑ child food security 0.08, imprecise (col3) | ✅(size)/➖(sig) | 0.084 |
| C-38 | Cisterns overall vulnerability index 0.13 SD, sig 1% (col4) | ✅/➖ | coefficient 0.126; KLK standardization makes 0.13 SD interpretation internally plausible (index = mean of control-standardized components) |
| C-39 | Rain ↓ depression 0.05 = ~0.07 SD (col1 panel B) | ✅ | 0.046/0.646 = 0.071 |
| C-40 | Rain ↓ SRHS 0.04 = "about 0.08 SD" (col2) | ⚠(rounding) | 0.039/0.535 = 0.073 ≈ 0.07, not 0.08 → ADV-003 |
| C-41 | Rain worsens child food security 0.05 = ~0.05 SD (col3) | ✅ | 0.046/0.990 = 0.046 |
| C-42 | Rain overall index 0.06 SD reduction, sig 1% (col4) | ✅/➖ | 0.064; significance needs data |
| C-43 | Rain ↓ household expenditure R$24.74 ≈ 7% of avg expenditure (col5) | ✅ | 24.736; /370.877 = 6.7% ≈ 7%; 13.33+11.54 = 24.87 ≈ total |
| C-44 | Table 3: cisterns −3.0pp pool (col1); rain −2.3pp (col2); both together stable (col3); interaction small/insignificant (col4) | ✅(sizes)/➖(joint sig) | note Table 3 col3/col4 cells not cleanly readable from lossy extraction |
| C-45 | Year-specific: cisterns ≈3pp both years; homogeneity p=0.91 (col5) | ✅ | 0.029/0.031; prose p=0.910 |
| C-46 | Rain 2012 (−0.042) >> 2013 (−0.004); homogeneity p=0.011 (col6) | ✅(prose) | prose "0.042 vs 0.004"; H0 p shown 0.011 |
| C-47 | Non-water requests robust, mechanically smaller (col7) | ➖ | exact cells unreadable from extraction |
| C-48 | Public-good requests rare: 2.7% of control (col8); no substitution | ✅(mean) | Table3 col8 control mean 0.027 |
| C-49 | Table 4 col1: 1 treated ⇒ 0.101 fewer incumbent votes, bootstrap p=0.041 (prose "p=0.04") | ✅ | table values match prose |
| C-50 | Table 4 col2: 0.076 (expanded); col3 challenger +0.098 (prose "0.10"/"p=0.09"); col4/5 turnout & blank-null ≈0 | ✅(prose↔table) | see internal consistency |

## F. Section VI — mechanism (Table 5)

| ID | Claim | Status | Basis |
|----|-------|--------|-------|
| C-51 | Cisterns effect concentrated among clientelist-marker: −10.9pp, 1% sig (col1) | ✅ | β1+β2 = 0.109; 0.109/0.285 = 38% |
| C-52 | Rain: +3.5pp clientelist vs +2.0pp without (cols 1–2) | ✅ | β3+β4 = 0.035 vs β3 = 0.020 |
| C-53 | Fulfilled requests: cisterns ↓6.2pp, rain ↑2.7pp among clientelist (col5) | ✅ | cells 0.062 / 0.027 match prose |
| C-54 | Electoral heterogeneity: treated×marker −0.27 (10% sig) vs −0.05 ns without (p. 3652) | ➖ | online appendix Table A8, not in main text tables |
| C-55 | Proxy definition: marker = conversed ≥monthly with local politician before campaign | ✅ | consistent with Table 1 frequent-interactions measure |

## G. Section VII — alternative explanations (online appendix only)

| ID | Claim | Status | Basis |
|----|-------|--------|-------|
| C-56 | No differential politician visits/handouts by treatment (Table A9 panel A) | ➖ | appendix |
| C-57 | Rainfall: no campaign-visit effect; offer/accept handouts increase in drought (panel B) | ➖ | appendix |
| C-58 | No credit-claiming / PT / alignment effects (Table A8 cols 3–6) | ➖ | appendix |
| C-59 | No effect on beliefs about incumbent competence/honesty (Table A9 cols 5–7) | ➖ | appendix |
| C-60 | Little effect on preferences (risk, altruism, reciprocity, time, public-good) | ➖ | appendix Table A10 |

---

## Summary
Total claims listed: 60.
- ✅ or ✅/≈ verifiable from article's own numbers (internal consistency): **~30**
- ⚠ (minor rounding label): **1** (C-40 → ADV-003)
- ➖ (not independently checkable — data/appendix unavailable): **~29**

Headline regression EFFECT SIZES (C-01…C-06, C-35…C-53 point estimates) are arithmetically
traceable against the paper's own reported coefficients/means (internal consistency), but none were
**independently re-estimated from the replication data** because the data/code could not be obtained
in this environment → all such rows carry the ➖-reproducibility caveat in the numerical tables of the
report.
