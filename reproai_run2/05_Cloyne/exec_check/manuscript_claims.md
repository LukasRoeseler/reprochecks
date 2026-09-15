# Cloyne (2013) — AER 103(4):1507–28 — Headline numerical claims & check status

**Citation:** Cloyne, J. (2013). "Discretionary Tax Changes and the Macroeconomy: New Narrative
Evidence from the United Kingdom." *American Economic Review* 103(4): 1507–28.
**DOI:** 10.1257/aer.103.4.1507 · **Reproduction package:** ICPSR DOI 10.3886/E112651V1.

| ID | Claim (paper) | Source | Repro source | Status |
|----|----------------|--------|--------------|--------|
| C1 | A 1%-of-GDP tax **cut** raises GDP ~**0.6% on impact** | Abstract | I4R author-code impact = 0.599 | Consistent (not independently recomputed) |
| C2 | ... rising to a **peak of ~2.5%** over three years | Abstract | I4R author-code peak = 2.458; peak at ~10–11 qtrs | Consistent |
| C3 | Peak effect directly comparable to Romer & Romer (2010) US (~2.5% at 10–11 qtrs) | §1 / I4R §1 | I4R confirms ~2.5 at 10–11 qtrs | Consistent |
| C4 | New narrative "exogenous" UK discretionary tax-change series, quarterly, 1945/1955–2009 | Abstract, Suppl | series is zero ~half the sample (I4R §3.1.3) | Consistent |
| C5 | Baseline VAR (Fig 3): log GDP pc, log C pc, log I pc, p=4 endog lags, q=12 exogenous shock lags, linear trend; tax shock scaled as % of GDP | I4R §2 | Baseline impact 0.599 / peak 2.458 (Matlab), 0.567 / 2.226 (Stata) | Consistent |
| C6 | Effects robust to controlling for monetary-policy / fiscal-policy shocks (peak ≈2.66% at 11 qtrs, p=0.03) | Suppl Figures 6–7 | (not re-verified) | Not re-verified |
| C7 | Tax changes raise TFP and affect employment, exchange rates, wages | Suppl Figures 3–5 | (not re-verified) | Not re-verified |

**Independent recomputation:** NOT performed — raw macro/tax data (ICPSR `data.xlsx`) could not be
retrieved in the audit environment (OpenICPSR `/download` routes Cloudflare-challenged; ICPSR deposit requires
Keycloak login). All numeric verification therefore rests on internal-consistency checks of the published human
reproduction (I4R DP132) and cross-source agreement, which pass.

**Internal-consistency checks (I4R DP132 Table 1):** z = coef/SE and 95% CI = coef ± 1.96·SE recompute within
rounding for the author-code and Stata reproduction columns (impact & peak). See `output/i4r_consistency.csv`.
