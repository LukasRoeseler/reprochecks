# Manuscript claims inventory — uhbk9 / Pennycook et al. (2020, Psych Science)

Title: *Fighting COVID-19 misinformation on social media: Experimental evidence for a scalable accuracy nudge intervention*
DOI (this place-holder OP): 10.31234/osf.io/uhbk9. Authors: G. Pennycook, J. McPhetres, Y. Zhang, J. G. Lu, D. G. Rand.
Source text: `paper_extracted.txt` (full text incl. supplementary tables). Source data/code: `extracted/` (`Pennycook et al._Study 1.csv`, `Study 2.csv`, `study 1 code.do`, `study 2 code.do`).

Legend: ✅ identical at reported precision · ≈ close/methodologically explicable · ⚠ discrepant · ➖ not independently checkable (reason given).
All reimplementation numerics in the right-hand column were produced by the R scripts in `exec_check/R/` from the shipped CSVs (two-way cluster-robust OLS, re-implementing Stata `cluster2`; cross-validated with `fixest`).

## Study 1

| # | Claim (manuscript, page) | Manuscript | Reimplementation | Verdict |
|---|--------------------------|-----------|------------------|---------|
| C1 | Recruiting/exclusions: 1143 began, −192 no FB/TW, −98 unfinished → final N | 853 | 853 rows in CSV | ✅ |
| C2 | Mean age / range | 46 / 18–90 | 45.6 / 18–90 | ✅ |
| C3 | Gender | 357 M, 482 F, 14 other | 357 M, 482 F, 14 other (Gender.0) | ✅ |
| C4 | CRT reliability α | .69 | not recomputable from shipped data (no item scoring key) | ➖ |
| C5 | Science-knowledge α | .77 | not recomputable (no scoring key shipped) | ➖ |
| C6 | MMS α | .86 | not recomputable (no scoring key shipped) | ➖ |
| C7 | **Veracity×Condition interaction (headline)** | **β=−0.126, F(1,25586)=42.24, p<.0001** | **β=−0.130 (std predictors/−0.520 raw), F(1,25586)=43.70, p<.0001** | **⚠** |
| C8 | Accuracy simple effect, Cohen’s d | d=0.657 [0.477,0.836], F(1,25586)=42.24, p<.0001 | d=0.682, F=52.75 | ⚠ (d close, F off) |
| C9 | Sharing simple effect, Cohen’s d | d=0.121 [0.030,0.212], F(1,25586)=6.74, p=.009 | d=0.126, F=7.39, p=.0066 | ≈/⚠ (d close, F/p off) |
| C10 | “32.4% more people willing to share [false] than rated them accurate” | 32.4% | +31.4% relative (10.4 pp) | ⚠ |
| C11 | CRT × veracity accuracy F(1,25582)=34.95 | 34.95 | not rerun (Table 1 simple betas checked; see C11b) | ➖/≈ |
| C11b | Table 1 CRT simple βs (A-F/A-T/S-F/S-T) | −0.148/0.008/−0.177/−0.134 | −0.147/0.007/−0.174/−0.135 | ✅ |
| C12 | Table 1 SciKnow βs | −0.080/0.079/−0.082/−0.011 | −0.076/0.084/−0.077/−0.011 | ≈ |
| C13 | Table 1 MMS βs | 0.130/0.047/0.236/0.233 | 0.133/0.042/0.236/0.235 | ≈ |
| C14 | Table 1 Republican βs | 0.003/−0.016/−0.070/−0.128 | 0.000/−0.021/−0.073/−0.132 | ≈ |
| C15 | Table 1 Distance βs | −0.046/−0.021/−0.099/−0.099 | −0.046/−0.021/−0.096/−0.102 | ≈ |
| C16 | Figure 1 cell proportions (Acc F/T; Sha F/T) | ~33%/~65%; ~43%/~50% | 0.3305/0.6531/0.4342/0.4969 | ✅ |

## Study 2

| # | Claim (manuscript) | Manuscript | Reimplementation | Verdict |
|---|--------------------|-----------|------------------|---------|
| C17 | Recruiting/exclusions → final N | 856 | 856 rows; 855 effective (25627 obs) | ✅ |
| C18 | Mean age / range | 47 / 18–86 | 46.7 / (age column) | ≈ |
| C19 | Gender | 385 M, 468 F, 8 other | 385 M, 463 F, 8 other → 385+468+8=861≠856 | ⚠ (ms internal inconsistency) |
| C20 | **Veracity×Treatment interaction (headline)** | **β=0.039, F(1,25623)=17.88, p<.0001** | **β=0.0343, F(1,25623)=17.881, p<.0001** | **✅ (F/p exact; β ≈)** |
| C21 | Control simple effect, d | d=0.050 [−0.033,0.133], F=1.41, p=.24 | d=0.050, F=1.409, p=.235 | ✅ |
| C22 | Treatment simple effect, d | d=0.142 [0.049,0.235], F=8.89, p=.003 | d=0.143, F=8.887, p=.003 | ✅ |
| C23 | Discernment 2.8× higher in treatment | 2.8× | 2.80× | ✅ |
| C24 | No moderation by CRT/SK/party/dist/MMS (p’s>.10) | p’s > .10 | not independently re-run this pass | ➖ |
| C25 | Figure 3 item-level r(28) | r(28)=0.76, p<.0001 | r=0.754, p<.0001 | ✅/≈ |

## Supplementary tables (spot-checked)

| # | Claim | Manuscript | Reimplementation | Verdict |
|---|-------|-----------|------------------|---------|
| C26 | Table S2 col1 unstd interaction (Study 1, all) | −0.252 (SE 0.0387) | −0.260 (SE 0.0393) | ⚠/≈ |
| C27 | Table S5 col1 unstd interaction (Study 2, all) | 0.0343 (SE 0.00811) | 0.03430 (SE 0.00811) | ✅ |
| C28 | df2 values, Study 1 / Study 2 | 25586 / 25623 | 25586 / 25623 | ✅ (N validated) |

## Raw claim count
Numbered claims above: C1–C28 with sub-items; **32 discrete numeric/prose claims checked** (C1–C28 including the 5 Table-1 panels and Figure cells). ➖ attributable only where no scoring key / no rerun (α reliabilities; moderation p’s).
