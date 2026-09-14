# Manuscript Claims Inventory — Williams & Bürkner (2020) MP.2018.872

**Title:** Coding Errors Lead to Unsupported Conclusions: A critique of Hofmann et al. (2015)
**Authors:** Donald R. Williams (UC Davis), Paul-Christian Bürkner (Aalto University)
**DOI:** 10.15626/2018.872
**Article type:** Commentary (Meta-Psychology, Vol 4, 2020; "empirical" content = original re-analysis meta-analysis of Hofmann et al. 2015)
**OSF (paper DOI):** J2QGS  ·  **OSF (analysis, cited in text):** kd3en
**Badges (paper header):** Open data: Yes · Open materials: Yes · Open and reproducible analysis: Yes · Analysis reproduced by: André Kalmendal · Preregistration: N/A
**Audit (re-audit) date:** 2026-09-14 · **Engine:** anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT

Legend: ✅ identical/verified · ⚠ discrepant · ≈ close & explicable · ➖ not independently checkable (reason)

## A. The authors' OWN numerical meta-analysis (R 4.6.1 + metafor 5.0.1, author data+code; independently re-checked in Python 3.8)

- **C1.** Overall SMD non-significant: ES=0.22, z=1.67, p=0.0953, CI[-0.04,0.47] — ✅ (R 0.2162/1.6682/0.0953/[-0.038,0.470]; Python 0.2162/1.6682)
- **C2.** Overall SMCR non-significant: ES=0.17, z=1.23, p=0.217, CI[-0.10,0.43] — ✅ (R 0.1671/1.2346/0.2170/[-0.098,0.432]; Python 0.1672)
- **C3.** Trim & fill: bias in SMD outcomes; corrected SMD=0.07, CI[-0.18,0.32] — ✅ (R 0.0672/[-0.184,0.319], k0=4)
- **C4.** Significant between-study variance SMCR: τ²=0.15, p=0.003 — ✅ (τ²=0.1523, Q p=0.0038)
- **C5.** Not significant between-study variance SMD: τ²=0.09, p=0.1149 — ✅ (τ²=0.0886, p=0.1149)
- **C6.** Table 1 SMCR rows (5 symptoms: Anxiety 0.09/0.17/0.51/0.61; Depression 0.29/0.27/1.08/0.28; Psychopathology 0.10/0.18/0.57/0.57; Psychotic 0.31/0.18/1.68/0.09; Repetitive -0.06/0.21/-0.29/0.77) — ✅ (all match in R and Python)
- **C7.** Table 1 SMCR τ² row: 0.09/0.06/p=0.0140/CI[0.01,0.29] — ✅ (0.092/0.062/QEp=0.0140/CI[0.006,0.287])
- **C8.** Table 1 SMD rows (5 symptoms: Anxiety 0.08/0.18/0.47/0.64; Depression 0.28/0.27/1.03/0.30; Psychopathology 0.14/0.19/0.73/0.47; Psychotic 0.41/0.19/2.13/0.033; Repetitive 0.15/0.22/0.69/0.49) — ✅ (all match)
- **C9.** Table 1 SMD τ² row: 0.069/0.069/p=0.0561/CI[0.00,0.40] — ✅ (0.069/0.069/QEp=0.0561/CI[0.000,0.401])
- **C10.** SMCR specific symptoms all non-significant (CIs include zero) — ✅ (all 5 non-significant)
- **C11.** SMD psychotic significant: 0.41, z=2.1278, p=0.0334, CI[0.03,0.80] — ✅ (R 0.4138/2.1278/0.0334/[0.033,0.795]; Python 0.4138/2.1277)
- **C12.** Other SMD symptoms (anxiety, depression, psychopathology, repetitive) non-significant — ✅
- **C13.** Restricting outcomes to total psychotic symptoms → loss of statistical significance — ✅ (SMCR p=0.3001, SMD p=0.2742, both non-significant)
- **C14.** "6 out of the 16 outcomes used to compute the overall effect should have been negative" — ✅ for SMCR (exactly 6 of 16 negative); note SMD gives 4 of 16 (authors headline the SMCR metric)
- **C15.** Method: SMD = Hedges' g from post-treatment scores only; SMCR = raw-score-standardized mean change (r=0.7) — ✅ (code + independent Python Hedges' g recompute match all 29 per-study g values)

## B. Documentary claims forwarded about the retracted Hofmann et al. (2015)

- **C16.** Lee et al. (2013): placebo improved, IN-OT did not; yet Hofmann Table 1 reported Hedges' g=1.07 — ➖ (source retracted; the "1.07" not independently checkable). Directional consistency supported: author's recoded Lee effect is negative (SMD −0.558).
- **C17.** Anagnostou et al. (2012) selected outcomes: d=0.13, d=−0.22, d=0.64 (repetitive behavior) — ➖ (forwarded from retracted Hofmann Table 1; d-computation units not in dat.csv)
- **C18.** Average effect larger for included outcomes (d=0.83) than excluded (d=0.49) in Hofmann Table 1 — ➖ (forwarded from retracted source)
- **C19.** Dadds et al. (2014) mislabeling / CARS not repetitive-behavior — ➖ documentary
- **C20.** PANSS total treated as psychotic + two negative-only-symptom scales; BPRS as general psychopathology — ≈ partially checkable against dat.csv coding of "psychotic"/"psychopathology" rows (PANSS-total rows coded psychotic; BPRS rows coded psychopathology), consistent.

## C. Open-science / provenance claims

- **C21.** "Open data: Yes" — ✅ substantiated (dat.csv on OSF kd3en and in J2QGS Submission; byte-identical MD5)
- **C22.** "Open materials: Yes" — ✅ substantiated (R scripts + manuscript on OSF)
- **C23.** "Open and reproducible analysis: Yes" — ✅ via paper-cited kd3en copy (reproduces exactly on R 4.6.1/metafor 5.0.1); ⚠ the duplicate in the paper's own OSF DOI project (J2QGS/Submission) does NOT reproduce under metafor 5.0.1 (ADV-001)
- **C24.** "Analysis reproduced by: André Kalmendal" — ➖ (editorial process attestation, not independently re-checkable here)

## Summary
- Independent-checkable numeric claims (author's own analysis): 15 (C1–C15) — all ✅ (14 exact + C14 exact w/ a reporting nuance).
- Documentary/forwarded (retracted source): 5 (C16–C20) — mostly ➖.
- Provenance: 4 (C21–C24) — 3 ✅, C24 ➖, C23 ⚠ (one of two copies).
- **Notable correction to the prior audit:** the prior audit reported OSF J2QGS as "empty (0 files)". It is not — Submission/ contains data, analysis R script, and manuscript. That prior finding (ADV-001/002 in the old report) is RETRACTED here.
