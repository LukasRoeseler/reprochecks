# Claim Inventory — Kuper & Bott (2019), MP.2018.878
**"Has the evidence for moral licensing been inflated by publication bias?"**
Meta-Psychology 3, 1–22. OSF: https://osf.io/h2rx7 (data + code), codebook.xlsx, `reviewer,analysis_JH.R`.
Audit date 2026-09-10. Engine: anomalyco/opencode — DeepSeek-V4-Flash (in-session Qwen3.8-27B).

## 0. Architecture (what was archived)
| Item | Present in OSF archive? | Notes |
|---|---|---|
| Manuscript (docx + pdf) | ✅ | `878-Manuscript in docx or tex-2218-1-4-20180430.docx` |
| Raw data `dat_new_s.txt` (Simbrunner, **k=102**) | ✅ | corrected Simbrunner & Schlegelmilch (2017) dataset |
| Raw data `dat_new_b.txt` (Blanken, k=90) | ✅ | |
| Raw data `dat_old_s.txt` (k=106) / `dat_old_b.txt` (k=91) | ✅ | uncorrected |
| codebook.xlsx | ✅ | variable definitions |
| R code `reviewer,analysis_JH.R` | ✅ | **runs on raw k=102 only** |
| Modified **k=76 dataset** (post Table 1/2 exclusions & aggregations) | ❌ | **NOT shipped** |
| Code applying Table 1/2 exclusions/aggregations | ❌ | **NOT shipped** |
| Appendix 3-PSM-averaging simulation code (Fig. A1) | ❌ | **NOT shipped** |
| Power-analysis code (n=766) | ❌ | **NOT shipped** |
| Funnel plots (Fig. 1, 2) source data | ❌ | only the raw k=102 is available |

**Badge status (manuscript p.14):** "Open Data and Open Materials badge … verified that the analysis reproduced the results presented in the article." — This verification was performed by R. Carlsson on the **k=102 shipped analysis**, not on the manuscript's **k=76 headline** analysis.

## 1. Claims inventory

### Headline results (Table 3 + Results text, pp. 8–10)

| ID | Claim (manuscript) | Reported value | My reproduction | Severity | Verdict |
|---|---|---|---|---|---|
| C01 | Naïve RE meta-analysis, entire dataset (k=76): d, CI, Z | d=.27, [0.19;0.35], Z=6.57, p<.001 | **k=75**: d=.267, [0.182;0.352], Z=6.18 (reconstructed from raw data per Table 1/2) | P1 | ⚠ not exactly reproducible; k off by 1, Z off by .39 |
| C02 | Heterogeneity: I², Q | I²=.26, Q(75)=175.77, p<.001 | Reconstruction: **I²=61.8%, Q(74)=184.3**. **I²=.26 is internally inconsistent with Q(75)=175.77 (⇒ I²≈57%)** | P1 | ❌ internally contradictory + not reproducible |
| C03 | k = 76 effect sizes | 76 | **75** (reconstruction) | P2 | ⚠ off by 1 |
| C04 | PET-PEESE slope (entire dataset) | b=1.36, t(74)=2.73, p=.008 | Reconstruction: b≈1.20 (k=102: b=1.47, p=.003) | ≈ | ≈ directionally reproduced |
| C05 | PET-PEESE intercept = corrected d (entire) | d=−.05, [−.26;0.16], t(74)=−0.46, p=.64 | Reconstruction (k=75): **−.027** (k=102: −.10) | P2 | ≈ close (−.027 vs −.05) |
| C06 | 3-PSM corrected d (entire) | d=.18, [0.06;0.29], Z=3.11, p=.002 | Reconstruction (k=75): **d=.154, [0.039;0.269]** | P2 | ≈ close but not exact |
| C07 | 3-PSM fit improvement (entire) | χ²(1)=3.42, p=.065 | Reconstruction: X²(1)=4.48, p=.034 | P2 | ⚠ differs (ns vs sig) |
| C08 | NOA subgroup naïve d (k=40) | d=.38, [0.27;0.48], Z=7.01 | Reconstruction (k=40): **d=.368, [0.261;0.476], Z=6.74** | ≈ | ✅ close |
| C09 | NOA PET-PEESE d / slope | d=−.13, [−.37;0.12], p=.29; b=2.12, p<.001 | Reconstruction: d=−.104, b=1.97 (p=.001) | ≈ | ✅ close |
| C10 | NOA 3-PSM d | d=.31, [0.15;0.47], Z=3.76, p<.001 | Reconstruction: d=.268 | ≈ | ✅ close |
| C11 | EUR subgroup naïve d (k=30) | d=.21, [0.09;0.32], Z=3.45 | Reconstruction (k=29): **d=.210, [0.069;0.350], Z=2.93** | P2 | ⚠ k off by 1, Z off |
| C12 | EUR PET-PEESE / 3-PSM | d=.10 p=.59 / d=.11 p=.12 | Reconstruction: d=.121 / d=.081 | ≈ | ✅ close |
| C13 | SEA subgroup naïve d (k=1) | d=−.37, [−.75;0.004], Z=−1.94, p=.052 | Reconstruction (k=1): **d=−.260, [−.632;0.112], Z=−1.37, p=.18** | P2 | ⚠ differs (single-study, unstable) |
| C14 | Moderator: culture NA vs SEA (uncorrected) | β=.71, Z=2.34, p=.019 | k=102 shipped: NOA coef=0.73 (Z=5.27) | ≈ | ✅ direction reproduced |
| C15 | Moderator: NA vs EUR | β=.17, Z=2.17, p=.030 | k=102: EUR coef=0.57 (Z=4.09) | ≈ | ✅ direction reproduced |
| C16 | Moderator: type of comparison (uncorrected) | β=−.42, Z=−3.72, p<.001 | k=102: comparison coef=−.144 (Z=−1.69, p=.09) | P2 | ⚠ not reproduced (uncorrected d>3 outliers) |
| C17 | Moderator: comparison (corrected dataset) | β=−.19, Z=−1.97, p=.049 | — | P2 | ⚠ |
| C18 | Meta-regression (comparison + culture + se): se effect | β=1.20, Z=2.00, p=.045 | k=102: se coef=1.256 (Z=2.42, p=.015) | ≈ | ✅ close |
| C19 | Meta-regression: NA vs SEA, NA vs EUR | β=.66 p=.024 / β=.15 p=.048 | k=102: NOA=0.675 (Z=5.0) / EUR=0.509 (Z=3.77) | ≈ | ✅ direction reproduced |
| C20 | 3-PSM + moderators: world region effects | β=.63 p=.021 (NA vs SEA) / β=.15 p=.033 (NA vs EUR) | — | P2 | ⚠ |
| C21 | 3-PSM + moderators: comparison ns | β=−.14, Z=−1.49, p=.14 | — | P2 | ⚠ |
| C22 | 3-PSM + moderators: se effect | β=1.20, Z=2.00, p=.045 | — | P2 | ⚠ |
| C23 | 3-PSM + moderators fit improvement | χ²(1)=2.77, p=.096 | — | P2 | ⚠ |
| C24 | Funnel plots (Fig. 1, 2) asymmetry | visual | not independently verifiable (no k=76 data shipped) | P2 | ➖ not verifiable |

### Method / data handling (Tables 1 & 2, pp. 6–8)

| ID | Claim | Severity | Verdict |
|---|---|---|---|
| C25 | k=102 → k=76 via Table 1 (exclusions) + Table 2 (aggregations) | P1 | ⚠ rules described but **code + resulting k=76 dataset not shipped**; my faithful reconstruction gives k=75 |
| C26 | Table 1: excluded Effron(2014) 1–2, Kouchaki(2011) 1–4, Jordan(2011) 1, Mazar&Zhong(2010) study 3 dup, Monin&Miller(2001) study 3 dup | P2 | ✅ rules documented & applied in reconstruction |
| C27 | Table 2: aggregated 8×Blanken(2012) pairs, 2×Bradley-Geist(2010), 2×Meijers(2014), 2×Simbrunner(2016) multi-outcome | P2 | ✅ applied (yields k=75) |
| C28 | "100% of effect sizes and 100% of sample sizes identical" between corrected datasets | P3 | ✅ consistent with shipped `dat_new_*.txt` |

### Power analysis (p. 13)

| ID | Claim | My verification | Severity | Verdict |
|---|---|---|---|---|
| C29 | n=766 total for 80% power, d=0.18, one-tailed | Independent: 2×(z.95+z.80)²/0.18² = 2×381.6 → **N=764** (≈766 with continuity) | P3 | ✅ VERIFIED |

### Appendix (pp. 18–21)

| ID | Claim | My verification | Severity | Verdict |
|---|---|---|---|---|
| C30 | 3-PSM averaging simulation (Fig. A1): overestimation bias when averaging dependent ES; bias > d=.10 in extreme case | **Simulation code not shipped** → not independently verifiable | P2 | ➖ not verifiable |
| C31 | Selection-threshold exploration (Fig. 3): 3-PSM d≈0 for one-tailed p=.05–.15, fit improvement p<.001, Bonferroni n=981 | **Code not shipped** → not independently verifiable | P2 | ➖ not verifiable |

### Abstract / conclusions (pp. 1, 13, 14)

| ID | Claim | Consistency | Severity | Verdict |
|---|---|---|---|---|
| C32 | "PET-PEESE d=−0.05, p=.64 and 3-PSM d=0.18, p=.002" | matches C05, C06 (approx) | P3 | ✅ |
| C33 | "evidence for and size of moral licensing inflated by publication bias" | consistent with C04–C07 | P3 | ✅ |
| C34 | "culture moderates the moral licensing effect" | consistent with C08–C12, C14–C15 | P3 | ✅ |
| C35 | "should be adequately powered and ideally pre-registered" | C29 verified; no pre-registration (Preregistration: No) | P3 | ✅ |

## 2. Severity rollup (consolidated into 6 findings, ADV-001…ADV-006)
- **P0:** 0
- **P1:** 2  → **ADV-001** (C01, C25: headline k=76 analysis not reproducible from archive) and **ADV-002** (C02: I²/Q internal contradiction)
- **P2:** 2  → **ADV-003** (C24, C30, C31: appendix & exploratory analyses not verifiable) and **ADV-004** (C03, C05–C07, C11, C13: k off by 1; precise 3-PSM/PET/SEA values not exact)
- **P3:** 2  → **ADV-005** (C16, C17: uncorrected comparison moderator) and **ADV-006** (C24: funnel plots not regenerable)

Reproduced/verified (✅/≈, no finding): C08–C10, C14–C15, C18–C19 (culture subgroups + moderators), C26–C28 (Table 1/2 rules, data identity), C29 (power n=766 verified), C32–C35 (abstract/conclusions consistent).

**Headline verdict:** The **main effect (d≈.27) and culture subgroups (NOA≈.37, EUR≈.21) are approximately reproducible** from the shipped raw data when the manuscript's Table 1/2 rules are applied manually. However, the **exact headline k=76 analysis, the I²=0.26 statistic, the 3-PSM/PET-PEESE precise values, and the appendix simulations are NOT reproducible** from the archived materials — the modified k=76 dataset, the exclusion/aggregation code, and the appendix simulation code were never shipped. The I²=0.26 reported in the manuscript is **internally inconsistent** with its own Q(75)=175.77 (which implies I²≈57%).
