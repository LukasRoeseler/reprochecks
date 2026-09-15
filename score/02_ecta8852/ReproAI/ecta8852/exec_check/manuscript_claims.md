# Manuscript Claims Inventory — Goeree & Yariv (2011), Econometrica 79(3):893–921, DOI 10.3982/ecta8852

Audit date 2026-09-14. Legend: ✅ exact at reported precision · ≈ close/method-explicable ·
⚠ discrepant (cause in Findings) · ➖ not independently checkable (reason).

## Claims
| ID | Claim (page) | Manuscript | Recompute (R/Py from raw data) | Verdict |
|----|--------------|-----------|-------------------------------|---------|
| C1 | Total subjects participated (p.899) | 549 | 549 (17 sessions, each counted once; hom 189 / het 261 / part 99) | ✅ |
| C2 | Avg payoff/no-chat segment (p.899) | $9.53 | $9.34 (934 c) | ⚠ ADV-004 |
| C3 | Avg payoff/chat segment (p.899) | $13.11 | $13.43 (1343 c) | ⚠ ADV-004 |
| C4 | $5 show-up fee (p.899) | $5 | design parameter; not in data | ➖ (design, not data) |
| Table III, no-communication | | | | |
| C5 | # individual decisions hom 5/7/9 | 540/1620/675 | 540/1620/675 | ✅ |
| C6 | # group decisions hom 5/7/9 | 60/180/75 | 60/180/75 | ✅ |
| C7 | Red w/ red signal hom 5/7/9 | 91/89/90 | 90.6/89.4/89.8 | ✅ |
| C8 | Red w/ blue signal hom 5/7/9 | 7/24/39 | 7.2/24.1/39.1 | ✅ |
| C9 | Wrong jury outcomes hom 5/7/9 | 10/35/48 | 10.0/35.0/48.0 | ✅ |
| C10 | Truejar blue hom 5/7/9 | 7/5/0 | 6.9/4.9/0.0 | ✅ |
| C11 | Truejar red hom 5/7/9 | 13/60/97 | 12.9/60.2/97.3 | ✅ |
| C12 | Het red-types red/blue-sig (r5/r7/r9) | 86/88/91 & 37/44/49 | 86.0/87.9/90.6 & 36.9/44.2/48.6 | ✅ |
| C13 | Het blue-types red/blue-sig | 64/59/62 & 16/15/19 | 63.7/58.9/61.9 & 15.5/14.8/19.1 | ✅ |
| C14 | Het wrong/truejar blue/truejar red | 23/41/60 ; 24/4/0 ; 23/83/100 | 23.3/41.3/60; 23.6/3.8/0; 23.1/83.1/100 | ✅ |
| C15 | Part neutral red/blue-sig | 91/90/71 & 18/21/28 | 91.5/90.4/71.1 & 17.9/20.6/28.0 | ✅ |
| C16 | Part strong-red red/blue-sig | 81/90/68 & 57/45/50 | 80.6/90.2/68.3 & 57.1/45.3/50.0 | ✅ |
| C17 | Part wrong/truejar blue/red | 27/25/43 ; 36/3/0 ; 12/48/100 | 26.7/25/43.3 ; 35.7/3.2/0 ; 11.8/48.3/100 | ✅ |
| Table III, with-communication | | | | |
| C18 | ind. decisions hom/het/part | 540/486/675; 675/675/540; 405/540/540 | hom r7: full data 1026 vs paper 486 (only HOM_7_27); others match | ⚠ ADV-002 |
| C19 | x%/y% red-optimal cells | x%/y% | not computed (need best-response normalization) | ➖ (requires full-profile optimal-decision coding) |
| Table V (homogeneous outcomes by #red signals) | | | | |
| C20 | no-comm freq red choices | e.g. r5: 4→25%,5→56%,... 9→100% | exact (rule-by-rule & N all match) | ✅ |
| C21 | comm freq red choices | r7:4→10%,5→50%,6-8→100% (27-session basis) | exact after hom-r7 session fix | ✅ |
| Table VI (comm, % red by signal majority + 95% CI) | | | | |
| C22 | majority-red pct hom/het/part | 100/92.6/94.7; 97.6/84.2/51.7; 100/97.2/84.4 | 100/92.6/94.7; 97.6/84.2/51.7; 100/97.2/81.8 (dedup) | ✅ part r9 ≈ (dedup) |
| C23 | majority-red/blue 95% CIs | e.g. [89.3,95.9] | Wald group-level wider e.g. [82.7,100] | ⚠ ADV-003 |
| Table IV (probit marginal effects) | | | | |
| C24 | Red sample (hom no-chat) | 0.814 | MEM = 0.814 | ✅ |
| C25 | Red sample (hom chat) | 0.504 | MEM = 0.579 ; AME = 0.477 | ⚠ ADV-006 |
| C26 | other Table IV cells | various | ≈/differ | ⚠ ADV-006 |
| fn16 (p.906) | | | | |
| C27 | decision-time with vs against signal | 41.4/55.1/30.5 vs 51.3/72.2/36.7 s | 8.5/11.9/13.2 vs 11.8/14.9/16.7 ; ratios +39%/+25%/+27% | ⚠ ADV-005 (qualitative ≥20% ✅) |
| Table VII (message profiles) | | | | |
| C28 | Truthful/Lie/Nothing/Public %, avg signal & type messages | various | requires coders' manual message categorization | ➖ |
| Table VIII (chat volume vs accuracy) | | | | |
| C29 | Signals/Chatlength/%signals correct vs incorrect + Wilcoxon | W=77,57,54; p<.48,<.01,<.004 | requires message-content coding | ➖ |

## Notes
- Payoffs recomputed from col-9 sum per (session × subject), i.e. cents, /100 to dollars.
- Table VI CIs: paper narrower than Wald group-level; consistent w/ individual-level N (≈9× groups), ignoring clustering.
- PART_9_36_chat: duplicated per-subject rows in periods 1–5 → naive part r9 comm majority-red = 40% (paper 84.4%);
  after de-duplication = 81.8%. Paper's 84.4% implies cleaned data not present in the shipped raw file.
- HOM_7_36_chat shipped but paper communication hom r7 statistics use N=486 = HOM_7_27 only.
