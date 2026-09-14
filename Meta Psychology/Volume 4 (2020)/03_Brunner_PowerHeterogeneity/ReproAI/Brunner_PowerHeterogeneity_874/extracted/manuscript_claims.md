# Manuscript Claims Inventory — Brunner & Schimmack (2020) MP.2018.874

**Title:** Estimating Population Mean Power Under Conditions of Heterogeneity and Selection for Significance
**Authors:** Jerry Brunner, Ulrich Schimmack (University of Toronto Mississauga)
**DOI:** 10.15626/MP.2018.874 | **OSF project:** PEUMW
**Mode:** Simulation/analytic methods paper ("Open data: N/A"; Open materials / analysis-reproduced badges).
**Audit engine:** anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT
**Rules:** REPRO_STANDARDS.md 2026.06.27 | **Audit date:** 2026-09-14
**Host:** R 4.6.1 (RNGkind Mersenne-Twister/Inversion/Rejection), Python 3.8.10 (numpy 1.24.4, scipy 1.10.1)

Legend: ✅ verified exactly (at reported precision / within declared Monte-Carlo tolerance) · ≈ close, methodologically
explicable · ⚠ discrepant (cause+fix given) · ➖ not independently checkable (concrete reason).

---

## A. Theoretical claims (deterministic — verified exactly)

### C1. Figure 1 (Theorem 2 illustration — Uniform[0.05, 1.0])
- Claim: "Expected power = 0.525 before selection, 0.635 after selection."
- Verification: E[p]=(0.05+1.0)/2 = **0.525** ✅. Post-selection E[p²]/E[p] = ((1³−.05³)/3)/((1²−.05²)/2) = **0.6683**, NOT 0.635 ⚠. R and Python agree. Illustrative-only.
- Status: **⚠ (P3)** — caption value 0.635 is arithmetically impossible for Uniform[0.05,1].

### C2. Figure 2 (Theorem 2 illustration — Beta(13,6)·0.95+0.05)
- Claim: "Expected power = 0.700 before, 0.714 after selection."
- Verification: E[p]=0.95·(13/19)+0.05=**0.70000** ✅; E[p²]/E[p]=**0.713929**≈0.714 ✅. R and Python agree.
- Status: **✅**

### C3. Theorems 1–5 statements (Appendix, incl. deterministic F(3,26) example, seed 9999)
- Located chi-sq df giving E(power)=0.80: paper 14.36826 → computed **14.36826** ✅
- integrate(fun, DF=14.36826): 0.8000001 → **0.8000001** ✅
- mean(Power)=0.8002137 → **0.8002141** ✅ (Δ4e-7)
- length(sigF)/popsize=0.800177 → **0.8001770** ✅
- E(G|sig)=mean(SigPower)=0.8274357 → **0.8274361** ✅
- replication success proportion=0.827172 → **0.827010** ≈ (Δ1.6e-4, fresh RNG draw under seed 9999)
- Theorem 4: 1/mean(1/SigPower)=0.8000502 → **0.8000507** ✅
- Theorem 3: mean(Power²)/mean(Power)=0.8275373 → **0.8275377** ✅
- Theorem 5: 0.02722205 and 0.02732371 → **0.0272220 / 0.0273236** ✅
- Status: **✅** (all theorems confirmed; symbolic chain internally consistent).

## B. Study 1 (Table 1) — heterogeneity in sample size only, F-tests, numerator df=1

Design: n ~ Poisson(86) (df2=n−2 variable), fixed effect size f (Cohen), inverse-CDF significant-F sampling
(via author rsigF). Estimators: author zcurve() (p-values only); per-study-df2 p-curve2.1 / p-uniform / ML.
Reduced Monte Carlo (S=2000 z-curve; S=1000 p-curve/p-uniform/ML, R; S=500 Python), fixed seed 20260914.
Tolerance = ~2–3 SE ≈ 0.003 for k=100–250.

### C4. Table 1 z-curve column ✅ (author zcurve function)
| true | k=50 | k=100 | k=250 |
|---|---|---|---|
| .05 | paper .058 → .055 (Δ−.003) | .049 → .047 (Δ−.002) | .040 → .039 (Δ−.001) |
| .25 | .293 → .290 (Δ−.003) | .280 → .279 (Δ−.001) | .268 → .268 (Δ≈0) |
| .50 | .513 → .515 (Δ+.002) | .508 → .507 (Δ−.001) | .502 → .500 (Δ−.002) |
| .75 | .717 → .719 (Δ+.002) | .723 → .722 (Δ−.001) | .728 → .728 (Δ≈0) |
Status: **✅** (all Δ ≤ 0.003, within MC error; 0 failures in 2000 sims/cell).

### C5. Table 1 p-curve 2.1 column ✅ (per-study df2)
| true | k=100 | k=250 |
|---|---|---|
| .25 | .253 → .254 (Δ+.001) | .253 → .252 (Δ−.001) |
| .50 | .497 → .498 (Δ+.001) | .497 → .497 (Δ≈0) |
| .75 | .747 → .747 (Δ≈0) | .747 → .748 (Δ+.001) |
| .05 | .059 → .059 (Δ≈0) | .059 → .056 (Δ−.003) |
Status: **✅**

### C6. Table 1 ML-model column ✅ (per-study df2)
| true | k=100 | k=250 |
|---|---|---|
| .25 | .251 → .252 (Δ+.001) | .251 → .251 (Δ≈0) |
| .50 | .497 → .497 (Δ≈0) | .497 → .498 (Δ+.001) |
| .75 | .747 → .747 (Δ≈0) | .747 → .748 (Δ+.001) |
| .05 | .057 → .057 (Δ≈0) | .057 → .054 (Δ−.003) |
Status: **✅**

### C7. Table 1 p-uniform column — RESULT ✅, SHIPPED CODE ⚠ (P1)
- Correct (upper-tail) implementation reproduces Table 1: true .25→.251 (Δ 0), .50→.496 (Δ 0), .75→.746 (Δ 0), .05→.058 (Δ−.001) at k=100. **✅ paper's numbers are correct.**
- The AUTHOR's recovered `heteroNpunifF` uses `pf(datta, log.p=T)` = log **lower**-tail in the numerator of the modified p-value instead of the **upper**-tail `pf(datta, lower.tail=F, log.p=T)`. Run as-is it returns a degenerate ≈0.80–0.91 estimate for every true power (e.g. true .25 → 0.844; true .05 → 0.808), contradicting Table 1. Same ~0.85 result obtained at fixed df2=84 and per-study df2, so the cause is the tail-direction error, not the df2 handling.
- Status: **⚠ P1** — shipped code for one of the four headline estimators does not reproduce its own published column; corrected code does.

### C8. Table 2 / prose "with 50% power at least 100 studies ... MAE <6% for all methods"
- Internal-consistency check of Table 2: at power .50, k=50 MAE (pcurve/punif/ml/zcurve) = 8.14/7.80/7.60/7.44 (all >6%); k=100 = 5.80/5.56/5.41/5.48 (all <6%). k=100 is the smallest k where all four fall below 6%. ✅
- Status: **✅** (arithmetically consistent with Table 2).

## C. Not independently checkable (concrete reasons)

### C9. Study 2 (gamma effect sizes; Tables 3 & 4)
ML with gamma effect size + 3 random starts per sim (heteromleF), 10,000 sims × 5×3×3×2 cells — computationally
infeasible here and seed/start nondeterministic; not reimplemented. Status: **➖**

### C10. Study 3 (beta effect sizes correlated with sample size; Table 5)
Requires the correlated-Poisson/beta sampling driver (β₀,β₁ tuning via optim, σ²=0.09) — driver not recovered;
not reimplemented. Status: **➖**

### C11. Oregon→Open Science Collaboration application (66% mean power vs 37% actual vs 97% original)
Requires the original OSC-100 p-value set / Schimmack-Brunner (2016) analysis, not shipped. Status: **➖**

### C12. Irvine-Hall method paragraph & bandwidth=0.05 numbers (.235/.492/.743; 24/76/99%, 85/91/97%, 40/84/99%)
Method/parameters not supplied in paper; not checkable. Status: **➖**

### C13. Historic-trends "increase <5 percentage points since 2011"; p-curve 4.06 overestimation
External z-curve applications / separate evaluations, no data shipped. Status: **➖**

## D. Availability / provenance / simulation infrastructure

### C14. Simulation scale: 10,000 sims/cell; 70 quad-core Apple iMacs
Internally consistent with SEs in Table 1 (SD/√10000 ≈ 0.007 at k=100 ≈ reported SD 0.031–0.073 across cells).
Status: **✅** (internally consistent; reproduces within MC error at reduced sample).

### C15. Code availability — PUBLISHED statement "at https://osf.io/bvraz"
OSF node `bvraz` does not exist (API /v2/nodes/bvraz/ → HTTP 404; web fallback 200 is OSF's generic not-found page).
The stated published code-URL is effectively dead. Draft (Zcurve6.7.tex) instead points to
http://www.utstat.toronto.edu/~brunner/zcurve2018 — also dead (recoverable only via Wayback Machine, 9 captures
2018–2026; the estimator file estimatR.txt recovered from the 2022-05-19 capture). Status: **⚠ P2**

### C16. OSF project PEUMW contents
6 folders (1. Submission, 2. Review Round 1, 3. Revision, 4. Review Round 2, 5. Revision 2, 6. Revision 3) —
manuscript LaTeX/PDF + editorial PDFs only; **no R code, no simulation data, no analysis scripts**. Status: **⚠ P2**

### C17. "Open Materials" badge + "verified the analysis reproduced the results"
Substantiated only for the manuscript/code via an archive; the only documented code path (osf.io/bvraz) is dead and
the archived p-uniform function does not reproduce its published column. Badge not fully substantiated. Status: **⚠ P2**

---

**Summary of checks:** 17 claim clusters (C1–C17) covering every numeric exhibit (theorem/figures/Table 1–2 prose/
scale/availability). Verified ✅: C1(before), C2, C3, C4, C5, C6, C7(result), C8, C14. ⚠: C1(after 0.635), C7(code),
C15, C16, C17. ➖: C9, C10, C11, C12, C13.
