# ReproAI claim inventory — Rodriguez-Lara & Moreno-Garrido (2012), *Exp Econ* 15:158–175
# DOI 10.1007/s10683-011-9295-3 — "Self-interest and fairness: self-serving choices of justice principles"
# Audit discipline: ReproAI/REPRO_STANDARDS.md §1 (claim inventory FIRST)
# Mode: STATIC audit (no public raw-data deposit exists; ESM = instructions + appendices, no data).
# Status legend: OK(recomputed-consistent) / ~(rounding-consistent) / WARN(internal inconsistency) / NA(needs raw data)
# Each raw-data-dependent item is marked NA with a concrete reason (DATA-NA: no deposit).

## Design / sample
- C01  144 students recruited, no prior experience, Univ. Alicante, May & Nov 2008.      status=NA(DATA-NA, no roster)  page=159
- C02  72 dictator observations = 24 per treatment (DW/DB/BL); recipients separate.     status=OK(24x3=72; 144=72+72)   page=158 t1
- C03  Prices: DW pd=150/pr=200; DB 150/100; BL 150/150 (pesetas).                     status=OK(no internal conflict) page=166
- C04  1 EUR = 166.386 pesetas; show-up fee 4 EUR.                                      status=OK
- C05  Exchange/conversion: "~3000 pesetas (18 Euros)" — 18 x 166.386 = 2995 pts.       status=OK(conversion) ; amount NA(DATA-NA) page=166

## Table 1 — Earning stage
- C06  qd means: DW 9.92, DB 10.75, BL 9.83                                          status=NA(DATA-NA)
- C07  qd pooled mean 10.16                                                           status=OK(calc 10.167) 
- C08  qd SDs 2.95/2.41/3.47/2.96                                                   status=NA(DATA-NA)
- C09  qd min/max 5/16, 7/15, 3/17, pooled 3/17                                      status=NA(group); OK(pooled=min/max across cells)
- C10  qr means: DW 10.17, DB 10.5, BL 11.96                                         status=NA(DATA-NA)
- C11  qr pooled mean 10.87                                                           status=OK(calc 10.877)
- C12  qr SDs 2.39/3.13/3.38/3.06                                                   status=NA(DATA-NA)
- C13  qr min/max 6/16, 5/19, 4/18, pooled 4/19                                     status=NA(group); OK(pooled=min/max across cells)
- C14  fn13: BL qd != qr, t=2.14, p=0.036 (two-sample, df=46)                        status=OK(recomputed t=2.154, p=0.0365)

## Table 1 — Allocation stage
- C15  s means: DW 0.44, DB 0.37, BL 0.36; pooled 0.39                               status=OK(pooled 0.390); group NA(DATA-NA)
- C16  s SDs 0.20/0.17/0.21/0.19                                                    status=NA(DATA-NA)
- C17  s min/max 0/0.74, 0/0.57, 0/0.63, pooled 0/0.74                              status=OK(pooled=min/max across cells)
- C18  share offering nothing 0.08/0.04/0.17/0.10                                   status=WARN -> 7 zeros (2/1/4) vs fn19+AppB "8" (ADV-002)
- C19  share offering above 0.5: 0.29/0.17/0.25/0.24                                status=NA(DATA-NA)
- C20  (s-xa) means -0.07/-0.12/-0.18; pooled -0.13                                  status=OK(group derivable ~-0.066/-0.124/-0.189); pooled WARN(rounding drift, ADV-003)
- C21  (s-xl) means -0.14/-0.03/-0.18; pooled -0.11                                  status=OK(group derivable ~-0.138/-0.024/-0.189); pooled WARN(ADV-003)
- C22  (s-xa)/(s-xl) SDs, min/max                                                  status=NA(group); OK(pooled min/max across cells)

## §4 prose
- C23  "dictators divided around 3000 pesetas (18 Euros)"                           status=OK(conversion only); amount NA(DATA-NA) page=166
- C24  "positive transfers occur 90% of the time"                                    status=WARN -> 65/72=0.903 (7 zeros) but 8 zeros => 64/72=0.889 (ADV-002) page=166
- C25  "average distribution is around 40%"                                          status=OK(pooled s=0.39) page=166
- C26  fn14: KS=0.33, p=0.089 (DW vs DB offers)                                      status=NA(asymptotic p ~0.07-0.15, exact not computable w/o data; ADV-005) page=166
- C27  "20% DW do not fulfil accountability just-desert; ~17% DB incompatible with libertarian" status=NA(DATA-NA) page=169

## Table 2 — Linear estimates (WLS robust + bootstrapped quantile)
- C28  WLS robust: s=alpha+beta xa / xl / xb  (all coefficients + SEs)               status=NA(DATA-NA; WLS/Huber-White needs raw data)
- C29  Bootstrapped quantile (median) regressions (all coefficients + SEs)            status=NA(DATA-NA; bootstrap needs raw data)
- C30  Justice-principle F-tests (robust & quantile): VALUES                         status=NA(DATA-NA)
- C31  Justice-principle F-tests: reported p <-> F(df) pairing                       status=OK(verified numerically, e.g. Lib DW 7.93(2,22)->0.0026; Acc 2.04->0.1539; etc.) fn17
- C32  Justice-principle Wilcoxon (Table 2): VALUES                                 status=NA(DATA-NA)
- C33  Justice-principle Wilcoxon: reported p <-> W(z) pairing                       status=OK(verified; pool-bias 0.10->0.9203 ~ 0.9172)
- C34  fn17: libertarian rejected in DW (F=7.93/8.03, W=4.095)                       status=OK(pairings) page=171
- C35  fn17: accountability not rejected in DW (F=2.04/1.39, W=0.93)                 status=OK(pairings) page=171
- C36  fn17: egalitarian — robust F2,22=4.28 p=0.0269 "rejected"; quant 0.61 & W=1.06 "cannot reject" status=OK(pairings consistent) page=171

## §4 pooled analysis & bias principle
- C37  "none of the three natural principles explains pooled data (p<0.0020)"         status=WARN(qnt-lib 6.79->0.0022 just above 0.0020 bound; ADV-004) page=171
- C38  bias principle pooled: F robust=3.17 p=0.0482; F quant=0.35 p=0.7056; W=0.10 p=0.9172  status=OK(3.17->0.0491; 0.35->0.7061; W 0.10->0.9203 ~) page=171
- C39  fn19: "8 s=0, one 0.01, another 0.02"                                         status=WARN(count 8 vs Table-1 7; ADV-002) page=171
- C40  fn19: isolate selfish (<5%): bias not rejected F2,60=0.59 p=0.5597           status=OK(0.59->0.5575 ~) page=171

## Table 3 — Wilcoxon signed-rank (self-serving choices)
- C41  Panel I values (all W)                                                        status=NA(DATA-NA)
- C42  Panel I subgroup Ns: md>=mr 34, md<mr 38 (34+38=72); pd>pr 21/pd<=pr 13 (=34); qd>=qr 9/qd<qr 29 (=38)  status=OK(arithmetic) page=172
- C43  Panel II Ns: Acc 22, Lib 21, Egal 29 (sum 72)                                status=OK(arithmetic) page=172
- C44  Panel I W <-> p pairings (in-text)                                           status=OK except W=1.120 p=0.904 -> ADV-001 (should be 0.2628) page=172
- C45  "34 more/equal, 38 less" contributions                                        status=OK(34+38=72) page=172

## ESM — Appendix A
- C46  instructions; 24/session; 16 paid 150, 4 paid 200, 4 paid 100 pts             status=OK(no internal conflict) ESM p1

## ESM — Appendix B (hurdle model, M-estimators)
- C47  hurdle probit+linear coefficients & marginal effects (Table A)               status=NA(DATA-NA)
- C48  hurdle: DB>DW giving p=0.026; accountability weight p=0.010; libertarian p=0.009  status=NA(DATA-NA)
- C49  hurdle: chi2_3 = 7.63, p=0.0543                                               status=OK(p=0.05431) ESM p7
- C50  M-estimators & F-tests (Table B) values                                      status=NA(DATA-NA)
- C51  M-estimator F <-> p pairings (25.97(2,22),10.43(2,20),17.89(2,22),8.55(2,19))  status=OK(verified) ESM p9
- C52  "unselfish" (give >=5%): DW=21, DB=22 -> below-5% DW 3, DB 2                    status=WARN(tension w/ Table-1 shares; ADV-002) ESM p8

## ESM — Appendix C (most-favourable-principle thresholds)
- C53  q0: DW 200 qr = 150 qd -> qr/Q = 3/7 = 0.4286                                 status=OK(derived) ESM p10
- C54  q1: DB 150 qd = 100 qr -> qr/Q = 0.6                                          status=OK(derived) ESM p10

## Counts of claims
- Total inventoried items: 54 (C01-C54).
- Raw-data-dependent only (status=NA(DATA-NA) with no derived component): 13 items.
- Items with at least one OK (~) recomputed/consistent component: 29.
- Items flagged WARN (internal inconsistency, mapped to findings): 5 (C18, C24, C37, C39, C52 -> ADV-002/004) plus the W=1.120 p-value (C44 -> ADV-001);
  pooled rounding-drift (C20/C21/C22 -> ADV-003) and KS/df2 notes (C26, C37 -> ADV-005/004) are flagged in their status lines.
- (Some items carry combined statuses, e.g. "status=NA(group); OK(pooled...)", so the per-token tallies above are not intended to sum to 54.)
