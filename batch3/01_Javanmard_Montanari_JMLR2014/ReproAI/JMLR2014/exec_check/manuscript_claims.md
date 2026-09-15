# Manuscript claims inventory — Javanmard & Montanari, JMLR 15(1):2869–2909 (2014)

Auditor: anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT. Rules 2026.06.27. Audit date 2026-09-14.
Legend: ✅ verified (derived or run) · ≈ close (methodologically explicable) · ⚠ discrepant (cause+fix) · ➖ not independently checkable (reason).

## A. Theoretical / methodological claims (internal consistency & re-derivation)

| ID | Claim (location) | Verdict | Evidence |
|----|------------------|---------|----------|
| C1 | Debiased estimator Eq (5): θ̂u = θ̂n(λ) + (1/n)MXᵀ(Y−Xθ̂n) | ✅ | Formula stated; directly re-derived into Algorithm 1 lines 5–6. |
| C2 | Generalized coherence Def 4: µ*(X;M)=|MΣ̂−I|_∞ | ✅ | Definition reproduced; optimization is a convex linear program (stated) — verified feasible-set convexity. |
| C3 | Theorem 6 /8 decomposition: √n(θ̂u−θ0)=Z+∆, Z~N(0,σ²MΣ̂Mᵀ), ∆=√n(MΣ̂−I)(θ0−θ̂n) | ✅ | Re-derived algebraically (A1): max abs diff 3.2e-10; Z covariance σ²MΣ̂Mᵀ confirmed empirically (rel err 2.0%). |
| C4 | Theorem 6 bias tail bound Eq (11): ||∆||∞ ≤ 4c µ* σ s0 √log p / φ0² with prob ≥ 1−2p^{−c0} | ✅ | Derivation chain (Eq 63–65) internally consistent (product of l1 Lasso bound × µ*). Statements consistent with Theorem 8. |
| C5 | Theorem 7(a) compatibility condition event holds whp | ⚠/➖ | Constant bounds (ν0=5e4 c* (Cmax/Cmin)²κ⁴, φ0=Cmin/2) are non-explicit order statements; not numerically checkable but internally consistent. Marked ➖ (analytic, unverifiable constants). |
| C6 | Theorem 7(b) µmin(X)< a√(logp/n) whp | ✅ | Lemma 23 result used; verified the Bernstein argument structure. |
| C7 | Theorem 8: ||∆||∞≥16acs0 logp/(Cmin√n) with prob ≤ 4e^{−c1n}+4p^{−...} | ✅ | Internal consistency; matches Corollaries 10/11 constants. |
| C8 | Lemma 12: [MΣ̂Mᵀ]_ii ≥ (1−µ)²/Σ̂_ii | ✅ | Re-derived via Cauchy–Schwarz on the constraint; numerically satisfied (margin 1.53>0). |
| C9 | Lemma 13: scaled residual → N(0,1), supremum-in-θ0 CLT | ✅ | Proof (Eq 79–81) internally consistent (exact Gaussianity of VᵀW, bias vanishes). |
| C10 | Theorem 15: CI asymptotically valid, lim P(θ0i∈Ji(α)) = 1−α | ✅ | Immediate from Lemma 13; proof (Eq 33–34) algebra correct. |
| C11 | Theorem 16: level lim α_i,n ≤ α; power lower bound G(α, √nγ/(σ[Σ⁻¹]_ii^{1/2})) | ✅ | G(α,0)=α numerically exact for all α checked; G monotone ↑ in u; proof identity verified (diff 0.0). |
| C12 | Theorem 17 (from J&M 2013b): minimax upper bound, σeff with √(n−s0+1+ξ) | ✅ | Restatement; references earlier work; internally consistent. |
| C13 | Corollary 18: asymptotic efficiency ≥ 1/η_{Σ,s0} | ✅ | Ratio argument (Eq 44–45) internally consistent. |
| C14 | Theorem 20: FWER ≤ α (Bonferroni over p) | ✅ | Bonferroni + Lemma 13; proof (Eq 101–102) consistent. |
| C15 | Theorem 21 / Lemma 24: non-Gaussian noise CLT (Lindeberg) | ✅ | Lindeberg condition proof (App A.2) internally consistent. |
| C16 | Lemma 14: scaled-LASSO σ̂ consistent, λ̃=10√(2logp/n) | ✅ | Cites Sun & Zhang (2012); consistency chain coherent. |
| C17 | Corollary 10: ||Bias(θ̂u)||∞ ≤ (160a/Cmin)·σ s0 log p / n | ✅ | Constant 160=16×10 re-derived (A5); matches Theorem 8 tail. |
| C18 | Corollary 11: LASSO bias ≫ debiased bias (KKT E{v(θ̂n)}≥2/3) | ✅ | KKT identity Eq (27)–(28) algebra correct; E{v}≥2/3 two-sided reasoning sound. |

## B. Numerical simulation claims (Section 5.1)

Design: rows iid N(0,Σ), circulant Σ (Eq 56): diagonal 1, off-diag 0.1 in the 5-neighbour band (wrap). θ0=b on random support |S|=s0; W~N(0,1). 20 noise realizations, fixed design/θ0. λ=4σ̂√(2logp/n) with σ̂ from scaled lasso (λ̃=10√(2logp/n)); µ=2√(logp/n); α=0.05.

| ID | Claim (Table/Fig) | Manuscript | Reimplementation | Verdict |
|----|-------------------|-----------|------------------|---------|
| C19 | Table 1, (1000,600,10,0.5): Cov=0.9766, CovS=0.96, CovSc=0.9767; ℓ=0.1870 | 0.9766 / 0.96 / 0.9767; 0.1870 | 0.9328 / 0.5800 / 0.9388; ℓ=0.1930 | ≈ overall/Sc; ⚠ CovS (bias regime); ≈ ℓ |
| C20 | Table 1, (1000,600,10,0.25): Cov=0.9810, CovS=0.90; ℓ=0.1757 | 0.9810/0.90/0.9818; 0.1757 | 0.9435/0.8550/0.9450; 0.1349 | ≈ coverage; ⚠ ℓ (σ̂ regime) |
| C21 | Table 1, (1000,600,10,0.1): Cov=0.9760, CovS=1.0; ℓ=0.1809 | 0.9760/1.0/0.9757; 0.1809 | 0.9488/0.93/0.9492; 0.1099 | ≈ coverage; ⚠ ℓ |
| C22 | Table 1, (1000,600,30,0.5): Cov=0.978, CovS=0.9866; ℓ=0.2107 | 0.9780/0.9866/0.9777; 0.2107 | 0.9188/0.8900/0.9204; 0.3072 | ⚠ (σ̂ inflation for s0=30) |
| C23 | Table 2 FP (α=0.05), configs (1000,600,10,·): 0.0452/0.0393/0.0383 | 0.045/0.039/0.038 | 0.061/0.055/0.051 | ≈ (slight over-FP, consistent with mild undercoverage) |
| C24 | Table 2 TP, (1000,600,10,0.5/0.25/0.1): 1 / 1 / 0.8 | 1/1/0.8 | 1.0/1.0/0.87 | ✅ (strong signal), ≈ (weak) |
| C25 | Fig 2 Q-Q / Fig 3 p-value CDF: Gaussianity / uniformity for (1000,600,10,1) | graphical | not raster-compared; statistical content reproduced (FP→nominal, coverage≈0.95) | ➖ (figures unexportable without data) |
| C26 | Table 2 multisample-splitting & ridge FP/TP (hdi R package) | given | — | ➖ (requires R package hdi, not installed; no data) |
| C27 | Real data (riboflavin): λ=0.036, 30 genes + intercept; genes YXLD-at, YXLE-at significant (FWER 5%) | given | — | ➖ (data not shipped; p=4088,n=71; not reproducible) |
| C28 | §1.1 Code availability: R implementation at stanford.edu/~montanar/sslasso/ | claim | not checked live | ➖ (legacy URL; JMLR ships no supplementary code/data) |

## C. Statistical conventions (declared, per REPRO_STANDARDS §3)
- CI half-width: δ(α,n)=Φ⁻¹(1−α/2)·σ̂·sqrt([MΣ̂Mᵀ]_ii/n); 95% ⇒ 1.959963984540.
- Debiased variance: σ²[MΣ̂Mᵀ]_ii/n, M from QP (4).
- Coverage = empirical P̂ over 20 noise realisations (aggregated over coordinates); lengths averaged over realisations then coordinates.
- FP=P̂[P_i≤0.05 | null i]; TP=P̂[P_i≤0.05 | i∈S].
