# NHB ReproAI Audit Progress

**Engine:** anomalyco/opencode
**Rules:** REPRO_STANDARDS.md
**Audit date:** 2026-09-14

## Status: COMPLETE

### Phase 1: Metadata Fetching
- [x] All 164 articles fetched (2019: 67, 2020: 97)
- [x] metadata.json, paper.html, paper_extracted.txt created for all papers

### Phase 2: Classification
- [x] NHB_MASTER_CLASSIFICATION.csv created
- [x] 150 EMPIRICAL papers identified
- [x] 14 NON-EMPIRICAL papers (theory/model, reviews, meta-analyses)

NON-EMPIRICAL list:
- 2019-01: Comparing meta-analyses (meta-analysis)
- 2019-08: Social influence models (simulation)
- 2019-56: Potential game approach (theoretical)
- 2019-65: Scoping review
- 2020-14: Systematic review and meta-analysis
- 2020-15: COVID-19 intervention modelling
- 2020-32: Evolution of productive organizations (theory)
- 2020-35: Unified account of numerosity (mathematical derivation)
- 2020-47: Agent-based model of SARS-CoV-2
- 2020-58: Stochastic SEIR model
- 2020-59: Social network-based distancing
- 2020-60: Global supply-chain effects
- 2020-64: Social goods dilemmas (evolutionary dynamics)
- 2020-75: Systematic review and meta-analysis

### Phase 3: Audit
- [x] All 150 empirical papers audited
- [x] Per-paper artifacts created:
  - extracted/manuscript_claims.md
  - reproai_reports/architecture_report.json
  - reproai_reports/risk_register.json
  - reproai_reports/advisory_plan.json
  - REPROAI_REPORT.html

### Phase 4: Volume Artifacts
- [x] VOLUME_2019_REPROAI_SUMMARY.csv
- [x] VOLUME_2019_REPROAI_SUMMARY.xlsx
- [x] VOLUME_2019_REPROAI_META_REPORT.html
- [x] VOLUME_2019_FINDINGS_PLOT.png
- [x] VOLUME_2020_REPROAI_SUMMARY.csv
- [x] VOLUME_2020_REPROAI_SUMMARY.xlsx
- [x] VOLUME_2020_REPROAI_META_REPORT.html
- [x] VOLUME_2020_FINDINGS_PLOT.png

### Findings Summary (Updated 2026-09-14)

**Method:** Data/code availability extracted from HTML article pages (Data Availability and Code Availability sections).

**2019 (63 empirical papers):**
- P1 (Critical - no info): 1
- P2 (Moderate - text only, no link): 28
- P3 (Minor - has direct link): 34
- Total: 63 findings

**2020 (87 empirical papers):**
- P1 (Critical - no info): 0
- P2 (Moderate - text only, no link): 38
- P3 (Minor - has direct link): 49
- Total: 87 findings

**Combined (150 empirical papers):**
- P1: 1, P2: 66, P3: 83
- 55% of papers have direct data/code links (OSF, GitHub, Zenodo, Figshare)
- 44% have availability text but no direct link
- 1% have no availability information

### Notes
- All papers audited using metadata + HTML content (static audit)
- Data/code availability extracted from HTML article pages
- Full-text PDF verification not performed (subscription-only articles)
- No live reimplementation performed
- Claims extracted from abstracts using regex patterns
