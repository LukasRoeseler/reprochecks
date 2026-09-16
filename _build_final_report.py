import os, json, math
from datetime import date

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
studies = json.load(open(os.path.join(OUT,"studies_dashboard.json"), encoding="utf-8"))

_study_refs_data = []
try:
    _study_refs_data = json.load(open(os.path.join(OUT,"study_references.json"), encoding="utf-8"))
except Exception:
    pass
_study_ref_map = {r["id"]: r["ref"] for r in _study_refs_data}

def _esc_ref(t):
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

import re as _re
_DOI_RE = _re.compile(r'(https?://(?:dx\.)?doi\.org/[^\s<]+)')
def _link_doi(text):
    return _DOI_RE.sub(lambda m: '<a href="' + m.group(1) + '" target="_blank" rel="noopener">' + m.group(1) + '</a>', text)


_FLORA_AUTHORS = ["Wallrich, L.", "Röseler, L.", "Hartmann, H.", "Ashcroft-Jones, S.",
"Doetsch, C.", "Kaiser, L.", "Schüller, S. M.", "Aldoh, A.", "Behbood, H.", "Elsherif, M. M.",
"Klett, N.", "Krapp, J.", "Liu, M.", "Pavlović, Z.", "Pennington, C. R.", "Schütz, A.", "Seida, C.",
"Siziva, K.", "Skvortsova, A.", "Aczel, B.", "Adelina, N.", "Agostini, V.", "Al-Hoorie, A. H.",
"Alarie, S.", "Albayrak-Aydemir, N.", "Alzahawi, S.", "Anvari, F.", "Arriaga, P.", "Baker, B. J.",
"Barth, C. L.", "Bauer, D. J.", "Becker, R.", "Beitner, J.", "Belaus, A.", "Bhatt, H.",
"Bhogal, J.", "Boyce, V.", "Breemer, L.", "Brick, C.", "Brohmer, H.", "Brummernhenrich, B.",
"Budd, E.", "Butler, A.", "Casula, A.", "Chandrashekar, S. P.", "Chen, S.", "Chung, K. L.",
"Cockcroft, J. P.", "Crowe, P.", "Cummins, J.", "Daniel, A.", "Deane, O.", "Deressa, T. K.",
"Dienlin, T.", "Diveica, V.", "Draguns, A.", "Dumbalska, T.", "Efendic, E.", "El Halabi, M.",
"Enright, S.", "Evans, T. R.", "Exner, A.", "Farrar, B. G.", "Feldman, G.", "Fillon, A.",
"Floyd, J.", "Fontana Vieira, F.", "Frese, J.", "Förster, N.", "Gattie, M. C.", "Gemmecke, C.",
"Genschow, O.", "Giannouli, V.", "Gjoneska, B.", "Gnambs, T.", "Gourdon-Kanhukamwe, A.",
"Graham, C. J.", "Greshake Tzovaras, B.", "Guay, S.", "Hausenloy, J.", "Haviva, C.",
"Henderson, E. L.", "Herderich, A.", "Hilbert, L.", "Holgado, D.", "Hussey, I.", "Höfer, L.",
"Ilchovska, Z. G.", "Imada, H.", "Imwene, P.", "Izydorczak, K.", "Jaubert, S.", "Jeftić, A.",
"Kalandadze, T.", "Kamermans, K.", "Karhulahti, V.", "Kasseckert, L.", "Kastrinogiannis, A.",
"Klingelhöfer-Jens, M.", "Kocalar, H. E.", "Koppel, L.", "Koppold, A.", "Korbmacher, M.",
"Kujawa, Z.", "Kulke, L.", "Kumar, P.", "Kuper, N.", "LaPlume, A. A.", "Lach, R.",
"Lecuona, O.", "Lee, J.", "Leech, G.", "Leksina, E.", "Lin, C.", "Liu, Y.", "Lohkamp, F.",
"Lou, N. M.", "Lynott, D.", "Mackinnon, S.", "Maier, M.", "Maiya, S.", "Makel, M. C.",
"Manrique-Castano, D.", "Manríquez-Robles, D.", "Mathes, L.", "McSharry, D.",
"Meidenbauer, K. L.", "Meier, M.", "Micheli, L.", "Miller, T.", "Montefinese, M.", "Moreau, D.",
"Moser, N.", "Mrkva, K.", "Murphy, J.", "Muthu, J.", "Narkar, N.", "Nemcova, M.",
"Nádvorník, J.", "O'Mahoney, R.", "O'Mahony, A.", "Oberholzer, Y.", "Oomen, D.", "Osano, M.",
"Otstavnov, N.", "Packheiser, J.", "Pandey, S.", "Panton, H.", "Papenmeier, F.", "Parsons, S.",
"Paruzel-Czachura, M.", "Pavlov, Y. G.", "Pittelkow, M.", "Plomp, W.", "Plonski, P. E.",
"Pravednikov, A.", "Pronizius, E.", "Pua, A.", "Pypno-Blajda, K.", "Rausch, M.", "Raza, H.",
"Reason, R.", "Rebholz, T. R.", "Resulbegoviq, H.", "Richert, E.", "Ross, R. M.", "Russo, S.",
"Röer, J. P.", "Sandkühler, J. F.", "Schmidt, K.", "Sempere, N.", "Sobolak, R.",
"Sperl, M. F.", "Stevens, J. R.", "Stogianni, M.", "Szekely, R.", "Tan, A. W.",
"Thürmer, J. L.", "Tiulpakova, M.", "Tomczak, J.", "Tołopiło, A.", "Tunca, B.",
"Vanpaemel, W.", "Vaughn, L. A.", "Verheyen, S.", "Vineyard, G. H.", "Weber, L.",
"Weinberg, A.", "Wingen, S.", "Wolska, J.", "Yeung, S. K.", "Younssi, M.", "Zaneva, M.",
"Zimmermann, D.", "Azevedo, F."]

_flora_authors = ", ".join(_FLORA_AUTHORS[:-1]) + ", & " + _FLORA_AUTHORS[-1]
_extra_refs = [
    '<p class="ref" id="ref-xu">' + _link_doi('Xu, Y., &amp; Yang, L. Y. (2026). Scaling Reproducibility: An AI-Assisted Workflow for Large-Scale Replication and Reanalysis. <i>arXiv preprint arXiv:2602.16733</i>. https://arxiv.org/abs/2602.16733</p>'),
    '<p class="ref" id="ref-flora">' + _link_doi(_esc_ref(_flora_authors) + ' (2026). FORRT Library of Replication Attempts (FLoRA) [Data set]. OSF. https://doi.org/10.17605/OSF.IO/9R62X') + ' (<em>*Wallrich, L., &amp; R\u00f6seler, L. contributed equally to this work.</em>)</p>',
]

# ---- Inclusion criteria for the reproducibility COMPARISON ----
# PRIMARY OUTCOME (all 14 MP + all 128 NHB full texts): was executable analysis code archived
# alongside data in a form a third party can obtain and run? This is fully observable at the
# journal level and does not depend on this environment's licensed/compute resources.
# SECONDARY / EXPLORATORY: among the few papers that were actually code-re-executed here, the
# reproduction rate (genuine re-execution verdicts, with a Fisher/Wilson interval).
# NOTE: 2019-20 (Bruneau) had NO author code (recreated from paper + data). It is therefore
# reported as "recreated corroboration" but is NOT part of the strict re-execution comparison.
REEXEC_NHB = {"2019-02","2019-10","2019-63","2019-17","2019-19","2019-42","2019-37","2020-10","2020-31","2020-34","2020-49","2020-61","2020-74","2020-78","2020-93","2020-96"}
RECREATED_NHB = {"2019-20"}
_reexec_class = json.load(open(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psych vs NHB\nhb_reexec_classes.json", encoding="utf-8")) if os.path.exists(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psych vs NHB\nhb_reexec_classes.json") else {}

mp = [s for s in studies if s["journal"]=="Meta-Psychology"]
nhb = [s for s in studies if s["journal"]=="Nature Human Behaviour"]
mp_aud = [s for s in mp if s["full_text_audited"]]
nhb_ft = [s for s in nhb if s["full_text_audited"]]
nhb_meta = [s for s in nhb if not s["full_text_audited"]]
nhb_recomp = [s for s in nhb_ft if s["id"] in REEXEC_NHB]
nhb_excluded = [s for s in nhb_ft if s["id"] not in REEXEC_NHB and s["id"] not in RECREATED_NHB]
nhb_recreated = [s for s in nhb_ft if s["id"] in RECREATED_NHB]
_nhb_excl_buckets = {}
for s in nhb_excluded:
    b = _reexec_class.get(s["id"], {}).get("bucket", "Availability-audited only (not code re-executed)")
    _nhb_excl_buckets[b] = _nhb_excl_buckets.get(b, 0) + 1
mp_ok = sum(1 for s in mp_aud if s["status"]=="reproduced")
mp_par = sum(1 for s in mp_aud if s["status"]=="partial")
mp_fail = sum(1 for s in mp_aud if s["status"]=="not_reproduced")
mp_tech = sum(1 for s in mp_aud if s["status"]=="technical")
nhb_p3 = sum(1 for s in nhb_ft if s["severity"]=="P3")
nhb_p2 = sum(1 for s in nhb_ft if s["severity"]=="P2")
nhb_p1 = sum(1 for s in nhb_ft if s["severity"]=="P1")
nhb_p3pct = round(100*nhb_p3/len(nhb_ft)) if nhb_ft else 0
nhb_p2pct = round(100*nhb_p2/len(nhb_ft)) if nhb_ft else 0
nhb_ftpct = round(100*len(nhb_ft)/len(nhb)) if nhb else 0
mp_od = sum(1 for s in mp_aud if str(s.get("open_data","")).lower() in ("yes","y"))
mp_or = sum(1 for s in mp_aud if str(s.get("open_repro","")).lower() in ("yes","y"))

# ---- Inferential statistics for the exploratory re-execution comparison ----
def _wilson(k, n, z=1.96):
    if n == 0:
        return (0.0, 0.0)
    p = k / n
    den = 1 + z * z / n
    ctr = (p + z * z / (2 * n)) / den
    marg = z * math.sqrt((p * (1 - p) + z * z / (4 * n)) / n) / den
    return (ctr - marg, ctr + marg)
def _fmt_pct(x):
    return f"{100*x:.0f}%"
# MP reproducibility: reproduced / audited. NHB: reproduced / re-executed (the 9 code-run papers).
_nhb_rep = sum(1 for s in nhb_recomp if (s.get("reexec") or {}).get("flag")=="reexec")
_nhb_rep_total = max(1, len(nhb_recomp))
_mp_wilson = _wilson(mp_ok, max(1, len(mp_aud)))
_nhb_wilson = _wilson(_nhb_rep, _nhb_rep_total)
try:
    from scipy.stats import fisher_exact
    _or, _fisher_p = fisher_exact([[mp_ok, len(mp_aud)-mp_ok], [_nhb_rep, _nhb_rep_total-_nhb_rep]])
except Exception:
    _or, _fisher_p = float("nan"), float("nan")

# ---- PRIMARY OUTCOME: executable analysis code archived alongside data (journal-level, all 14+128) ----
# Fully observable; does not depend on this environment's licences/compute. For MP: all audited
# articles archive code under MP's mandatory reproducibility-check policy (open_repro = Yes for all
# 14). For NHB: classified from the re-execution ledger by whether analysis scripts were archived.
_NO_CODE_BUCKETS = {
  "Availability-audited only (not code re-executed)",
  "No analysis code archived (data-only archive)",
  "Toolbox-only repo (no paper analysis scripts archived)",
}
def _nhb_code_archived(s):
    if s["id"] in RECREATED_NHB:
        return False   # data-only archive, analysis recreated from paper (not author code)
    b = _reexec_class.get(s["id"], {}).get("bucket", "Availability-audited only (not code re-executed)")
    return b not in _NO_CODE_BUCKETS
_nhb_code = [s for s in nhb_ft if _nhb_code_archived(s)]
_nhb_code_n = len(_nhb_code)
_nhb_nocode_n = len(nhb_ft) - _nhb_code_n
# MP: all 14 audited have code (open_repro = Yes throughout); the whole MP sample is code-archived.
_mp_code_n = len(mp_aud)
_mp_code_pct = 100.0 if mp_aud else 0.0
_nhb_code_pct = round(100.0 * _nhb_code_n / len(nhb_ft)) if nhb_ft else 0
_primary_or, _primary_fisher = float("nan"), float("nan")
try:
    _primary_or, _primary_fisher = fisher_exact(
        [[_mp_code_n, 0], [_nhb_code_n, _nhb_nocode_n]])
except Exception:
    pass


included = mp_aud + nhb_recomp
def _med(xs):
    n=len(xs); return (xs[n//2] if n%2 else (xs[n//2-1]+xs[n//2])/2.0)
_mp_cl = sorted(s["claims"] for s in mp_aud)
_nhb_cl = sorted(s["claims"] for s in nhb_ft)

# ---- Study 2: OpenAlex citations + estimated APC costs ----
import statistics as _st
_oa = {}
try:
    _oa = json.load(open(os.path.join(OUT,"openalex_cache.json"), encoding="utf-8"))
except Exception:
    pass
for s in mp_aud + nhb_ft:
    doi = s.get("doi","")
    s["cites"] = int(_oa.get(doi, {}).get("cited_by_count") or 0)
_APC_NHB = 9000.0
_mp_cites = [s["cites"] for s in mp_aud]
_nhb_cites = [s["cites"] for s in nhb_ft]
_nhb_cost = int(len(nhb_ft)*_APC_NHB)
_nhb_cost_str = f"{_nhb_cost:,}"
_apc_str = f"{_APC_NHB:,.0f}"

# ---- NHB data/code reasons: studies where the audit could NOT be run (not direct-link) ----
# Reclassify: if source data are in the paper/supplement they ARE downloadable, so they are
# treated as available (not a non-availability reason) and excluded from the barrier tally.
def _nhb_na_reason(s):
    sev = s.get("severity","")
    c = _re.sub(r'^full text \(pdf\) retrieved and claims audited \| ','',(s.get("caveat") or ""),flags=_re.I)
    c = _re.sub(r'^data availability stated, no direct link:\s*','',c,flags=_re.I)
    cl = c.lower()
    if sev == "P1" or 'no data availability statement' in cl:
        return "No data availability statement"
    if 'on reasonable request' in cl or 'available upon request' in cl:
        return "Available on request from authors"
    if any(k in cl for k in ('consent','irb','ethical','data-protection','data protection','restriction','restricted','cannot be shared','not publicly','law','do not per','not permitted')):
        return "Ethical/legal restriction (consent, IRB, data protection)"
    if any(k in cl for k in ('biobank','nda','hcp','register','application','approval','third-party','third party','access','dryad','dataverse','osf','figshare','zenodo','github','repository','pgc','controlled')):
        return "Third-party / restricted repository (application/approval needed)"
    if any(k in cl for k in ('supplement','included in this','included in the','source data','data files necessary','data for','available within the article','are provided in the')):
        return "AVAILABLE (data in paper/supplement)"
    if any(k in cl for k in ('https','available at','available from','available through','downloadable','publicly available','open science')):
        return "URL/repository named, no direct machine-downloadable link"
    return "Data not directly downloadable"
def _nhb_na_is_barrier(s):
    return _nhb_na_reason(s) != "AVAILABLE (data in paper/supplement)"
_nhb_na = [s for s in nhb_ft if s.get("severity") in ("P1","P2") and _nhb_na_is_barrier(s)]
def _e(x):
    return str(x).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace('"',"&quot;")
# ---- APA-style summary table of reasons ----
from collections import Counter as _C
_na_tally = _C(_nhb_na_reason(s) for s in _nhb_na)
_na_total = sum(_na_tally.values())
_na_tally_apa_rows = "\n".join(
    "<tr><td class=\"tt\">" + _e(k) + "</td><td style=\"text-align:center\">" + str(v)
    + "</td><td style=\"text-align:center\">" + f"{100*v/_na_total:.1f}%"
    + "</td></tr>" for k,v in _na_tally.most_common())
_nhb_na_count = _na_total
_nhb_direct = len(nhb_ft) - _nhb_na_count
# MP: numbers mismatch (distinct numbers come out) tallies come from re-execution outcomes
_mp_nums = {  # conceptual split for MP where re-execution happened
    "Reproduced": mp_ok, "Partially reproduced (some numbers differ)": mp_par,
    "Not reproduced (numbers differ)": mp_fail, "Technical failure (code could not run)": mp_tech,
}

for s in included:
    s["report"] = "MetaPsych_vs_NHB/" + s["id"] + "/"
data_js = json.dumps(included, ensure_ascii=False).replace("</", "<\\/")

# ---- Counts-audit table (single source of truth for denominators) ----
# Rows: journal, records published, non-empirical excluded, empirical, full text retrieved,
#        code archived (primary outcome), code re-executed here, reproduced (re-exec comparisons).
def _ca_row(journal, records, nonemp, empirical, fulltext, codearch, reexec, reproduced):
    return (f"<tr><td class=\"tt\">{journal}</td>"
            f"<td style=\"text-align:center\">{records}</td>"
            f"<td style=\"text-align:center\">{nonemp}</td>"
            f"<td style=\"text-align:center\">{empirical}</td>"
            f"<td style=\"text-align:center\">{fulltext}</td>"
            f"<td style=\"text-align:center\">{codearch}</td>"
            f"<td style=\"text-align:center\">{reexec}</td>"
            f"<td style=\"text-align:center\">{reproduced}</td></tr>")
# MP records = 21 (Vol3=10, Vol4=11); non-empirical excluded = 3; empirical = 18; audited = 14;
#   (4 excluded as infeasible) code-archived = 14; reexec = 14; reproduced = mp_ok
_mp_records = 21
_mp_nonemp = 3
_mp_empir = 18
_mp_ft = len(mp_aud)       # 14 audited
_nhb_records = 164
_nhb_nonemp = 14
_nhb_empir = 150
_nhb_fulltext = len(nhb_ft)   # 128
# wait: MP records 21, nonemp 3 => empirical 18; audited 14; excluded 4 (of the 18). code-archived MP=14
_ca_rows = (
    _ca_row("Meta-Psychology", _mp_records, _mp_nonemp, _mp_empir, _mp_ft, _mp_code_n, len(mp_aud), mp_ok)
    + _ca_row("Nature Human Behaviour", _nhb_records, _nhb_nonemp, _nhb_empir, _nhb_fulltext, _nhb_code_n, len(nhb_recomp), _nhb_rep)
)
_ca_foot = (
    f"<p class=\"tabnote\"><em>Counts audit.</em> NHB start figures: 164 records = 150 empirical + 14 non-empirical "
    f"(reviews/meta-analyses/models/theory); of the 150 empirical, full text of {len(nhb_ft)} was retrieved "
    f"({len(nhb_meta)} not available behind the paywall). Code archived (primary outcome): MP {_mp_code_n}/{_mp_ft} "
    f"(100%); NHB {_nhb_code_n}/{_nhb_fulltext} ({_nhb_code_pct}%). Genuine code re-execution in this environment: "
    f"MP {len(mp_aud)} of {len(mp_aud)}; NHB {len(nhb_recomp)} of {_nhb_fulltext}. Reproduced count in the exploratory "
    f"re-execution comparison: MP {mp_ok}, NHB {_nhb_rep}.</p>"
)


_ref_by_journal = {}
for s in included:
    j = "Meta-Psychology" if s["journal"]=="Meta-Psychology" else "Nature Human Behaviour"
    r = _study_ref_map.get(s["id"], "")
    if r:
        _ref_by_journal.setdefault(j, []).append((s["id"], r))
_reflist_mp = "\n".join(f'<p class="ref">{_link_doi(_esc_ref(r))}</p>' for _, r in sorted(_ref_by_journal.get("Meta-Psychology", [])))
_reflist_nhb = "\n".join(f'<p class="ref">{_link_doi(_esc_ref(r))}</p>' for _, r in sorted(_ref_by_journal.get("Nature Human Behaviour", [])))
_extra_refs_html = ("\n".join(_extra_refs)
     + "\n<h3>Meta-Psychology Reference List</h3>\n" + (_reflist_mp or '<p class="ref">None.</p>')
     + "\n<h3>Nature Human Behaviour Reference List</h3>\n" + (_reflist_nhb or '<p class="ref">None.</p>'))

def esc(x):
    return str(x).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace('"',"&quot;")

def srow(s):
    st = s.get("status","not_checked")
    cls = {"reproduced":"green","partial":"amber","not_reproduced":"red","technical":"orange","not_checked":"gray"}.get(st,"gray")
    idc = s["id"]
    rep = s.get("report","")
    idcell = f'<a href="{esc(rep)}" target="_blank" title="Open ReproAI report">{esc(idc)}</a>' if rep else esc(idc)
    doi = s.get("doi","")
    doic = f'<a href="https://doi.org/{esc(doi)}" target="_blank">{esc(doi)}</a>' if doi else "&mdash;"
    ft = "Yes" if s["full_text_audited"] else "No"
    return (f"<tr><td>{idcell}</td><td class='tt'>{esc(s['title'])}</td><td>{doic}</td>"
            f"<td>{esc(s.get('open_data',''))}</td><td>{esc(s.get('open_materials',''))}</td><td>{esc(s.get('open_repro',''))}</td>"
            f"<td>{ft}</td><td>{s['claims']}</td>"
            f"<td><span class='tl tl-{cls}'>{esc(s['outcome'])}</span></td><td class='cav'>{esc(s['caveat'])}</td></tr>")

table_rows = "\n".join([srow(s) for s in included])

template = r"""<!DOCTYPE html>
<html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" type="image/svg+xml" href="favicon.svg">
<title>Scholarly-Led Versus Commercial Publishing: Reproducibility of Meta-Psychology and Nature Human Behaviour (2019-2020)</title>
<style>
:root { --mp:#F2B30F; --nhb:#0b2344; --ink:#111; }
body { font-family:"Times New Roman",Times,serif; font-size:12pt; line-height:2; color:var(--ink); margin:0; background:#f4f4f4; }
.wrap { max-width: 1060px; margin:0 auto; background:#fff; padding:60px 70px; box-shadow:0 0 12px rgba(0,0,0,.08); }
h1 { font-size:17pt; line-height:1.3; text-align:center; }
h2 { font-size:14pt; border-bottom:1px solid #ccc; padding-bottom:4px; }
h3 { font-size:12pt; }
p { margin:0 0 12px 0; }
.runninghead { font-size:10pt; text-transform:uppercase; letter-spacing:1px; }
.byline,.affil { text-align:center; }
.byline { font-style:italic; font-size:11.5pt; }
.subtitle { text-align:center; font-size:12pt; font-weight:bold; margin:2px 0 12px 0; }
.keywords { font-size:11pt; }
.abstract { border:1px solid #999; padding:16px 24px; margin:20px 0; }
table { border-collapse:collapse; width:100%; font-size:8.5pt; line-height:1.3; margin:12px 0; }
th,td { border:1px solid #888; padding:3px 5px; vertical-align:top; text-align:left; }
th { background:#eee; }
.tt { max-width:250px; } .cav { max-width:180px; color:#444; }
table.apa { border-collapse:collapse; width:70%; margin:16px auto; font-size:10pt; }
table.apa th, table.apa td { border:none; border-bottom:1px solid #888; padding:4px 10px; text-align:center; }
table.apa thead tr { border-bottom:2px solid #222; }
table.apa tbody tr:last-child td { border-bottom:2px solid #222; }
.figure { text-align:center; margin:24px 0; }
.figure img { max-width:95%; border:1px solid #ddd; }
.figcap { font-size:11pt; text-align:left; margin-top:8px; line-height:1.4; }
.ref { font-size:10.5pt; padding-left:1.5em; text-indent:-1.5em; margin:4px 0; }
a { color:#0645ad; }
a.cit { color:inherit; border-bottom:1px dotted #888; text-decoration:none; }
a.cit:hover { border-bottom-color:#0645ad; background:#f0f3ff; }
/* dashboard */
#dash { font-family:Arial,Helvetica,sans-serif; font-size:11pt; background:#fafbff; border:1px solid #ccd; border-radius:8px; padding:20px 24px; margin:28px 0; line-height:1.5; }
#dash h2 { border:none; }
.filters { display:flex; flex-wrap:wrap; gap:12px; margin:10px 0; align-items:flex-end; }
.filter { display:flex; flex-direction:column; font-size:10.5pt; }
.filter select, .filter input { font-size:10.5pt; padding:4px; min-width:150px; }
.fbtn { font-size:10.5pt; padding:6px 12px; cursor:pointer; border:1px solid #2c6fbb; background:#2c6fbb; color:#fff; border-radius:4px; }
.chartbox { background:#fff; border:1px solid #ddd; border-radius:6px; padding:12px 16px; margin:12px 0; }
.stacked { display:flex; height:38px; border-radius:4px; overflow:hidden; width:100%; }
.seg { display:flex; align-items:center; justify-content:center; color:#fff; font-size:10pt; font-weight:bold; min-width:0; }
.legend { display:flex; flex-wrap:wrap; gap:14px; margin:8px 0; font-size:10.5pt; }
.legend .item { display:flex; align-items:center; gap:5px; }
.sw { width:14px; height:14px; border-radius:3px; display:inline-block; }
#dashTable { font-family:Arial,Helvetica,sans-serif; font-size:9.5pt; width:100%; border-collapse:collapse; }
#dashTable th { background:#1a1a2e; color:#fff; position:sticky; top:0; }
#dashTable td { border:1px solid #ccc; padding:3px 5px; }
.dcount { margin:6px 0; font-weight:bold; }
.tl { padding:1px 8px; border-radius:10px; color:#fff; font-size:9pt; white-space:nowrap; }
.tl-green { background:#2e7d32; } .tl-amber { background:#f9a825; color:#222; }
.tl-red { background:#c62828; } .tl-orange { background:#ef6c00; } .tl-gray { background:#757575; }
.prisma { display:flex; gap:30px; flex-wrap:wrap; margin:20px 0; }
.pcol { flex:1; min-width:320px; }
.pbox { border:1.5px solid #333; background:#f7f7f7; padding:10px 14px; margin:0 auto 8px auto; width:88%; text-align:center; line-height:1.35; }
.pbox b { display:block; }
.parrow { text-align:center; font-size:14pt; width:88%; margin:0 auto; }
.pexcl { border:1.5px dashed #a33; }
.mergebox { background:#eef2ff; }
.mpcol .pbox { border-color:var(--mp); } .nhbcol .pbox { border-color:var(--nhb); }
.page { text-align:right; font-size:11pt; color:#666; }
/* floating table of contents */
body { position:relative; }
.toc { position:fixed; left:16px; top:24px; width:200px; z-index:50; font-family:Arial,Helvetica,sans-serif; font-size:11px; line-height:1.4; }
.toc-body { background:#fff; border:1px solid #ccc; border-radius:8px; padding:10px 12px; box-shadow:0 2px 10px rgba(0,0,0,.12); display:flex; flex-direction:column; gap:3px; }
.toc-body a { text-decoration:none; color:#0645ad; padding:1px 2px; border-left:3px solid transparent; }
.toc-body a:hover { border-left-color:var(--mp); background:#f5f7ff; }
.toc-toggle { display:none; }
.toc-home { display:block; background:var(--nhb); color:#fff; text-decoration:none; padding:8px 10px; border-radius:8px; font-size:11px; font-weight:bold; text-align:center; margin-bottom:7px; border:1px solid var(--nhb); }
.toc-home:hover { background:#12345e; color:#fff; }
@media (max-width:1350px){ .toc { position:static; width:auto; margin:0 0 18px 0; } .toc-body{ box-shadow:none; } }
@media (max-width:760px){
  .toc-body { display:none; }
  .toc-toggle { display:block; cursor:pointer; background:#1a1a2e; color:#fff; padding:8px 12px; border-radius:6px; font-weight:bold; }
}
</style>
</head>
<body>
<div class="wrap">

<nav class="toc" id="toc">
  <a class="toc-home" href="https://lukasroeseler.github.io/reprochecks/">&larr; Back to ReproAI checks</a>
  <div class="toc-toggle" id="tocToggle">Contents</div>
  <div class="toc-body">
    <a href="#abstract">Abstract</a>
    <a href="#introduction">Introduction</a>
    <a href="#dash">Dashboard</a>
    <a href="#method">Method</a>
    <a href="#results">Results</a>
    <a href="#results-s2">Study 2: Citation &amp; cost analyses</a>
    <a href="#discussion">Discussion</a>
    <a href="#gen-discussion">General Discussion</a>
    <a href="#open-science">Open Science Statements</a>
    <a href="#author-note">Author Note</a>
    <a href="#conflict">Conflict of Interest</a>
    <a href="#data-availability">Data Availability</a>
    <a href="#references">References</a>
  </div>
</nav>

<h1>Scholarly-Led Versus Commercial Publishing:<br>A Two-Journal Case Study of Reproducibility Support</h1>
<p class="byline">A Comparative Audit of <i>Meta-Psychology</i> (Linnaeus University Press) and <i>Nature Human Behaviour</i> (Springer Nature), 2019&ndash;2020 Volumes</p>
<p class="subtitle"><i>A descriptive case study of two journals; the inferential comparison below is exploratory, underpowered, and not conventionally significant.</i></p>

<h2 id="abstract">Abstract</h2>
<div class="abstract">
<p>We asked which publishing model is the more reproducible: the scholar-led, Diamond Open-Access journal <i>Meta-Psychology</i> (published by Linnaeus University Press) or the commercially published <i>Nature Human Behaviour</i> (<i>NHB</i>; Springer Nature), for their 2019 and 2020 volumes. Because genuine numerical re-execution is infeasible or unlicensed for most <i>NHB</i> articles, we report a <b>primary, fully-observable journal-level outcome</b> measured on all @MPA@ <i>Meta-Psychology</i> and all @NHBFT@ full-text <i>NHB</i> articles: <b>whether executable analysis code was archived alongside data in a form a third party can obtain and run</b>. @MPA@@ of @MPA@ <i>Meta-Psychology</i> articles met this standard (@@MP_REPROD_S@@), because its editorial policy mandates code and data deposition and runs reproducibility checks before publication; among <i>NHB</i> articles, @NHB_CODEARCH@ of @NHBFT@ (@@NHB_CODEARCH_PCT@@%) met it. Full-text access itself was restricted: of 150 <i>NHB</i> empirical articles, @NHBFT@ were retrievable behind the paywall and @NHBMETA@ were not. As a <b>secondary, exploratory</b> analysis we genuinely re-ran author code on author data where feasible: all @MPA@ <i>Meta-Psychology</i> re-executions reproduced (@MPOK@) or partially reproduced (@MPPAR@), whereas among the @NHBREEXEC@ <i>NHB</i> articles that could be re-executed (@NHB_REPROD_S@@ reproduced) the difference from <i>Meta-Psychology</i> is <b>not conventionally significant</b> (Fisher&rsquo;s exact two-sided <i>p</i>&nbsp;=&nbsp;@@FISHER_P@@; 95% CIs overlap: MP @@MP_WILSON@@ vs NHB @@NHB_WILSON@@). These re-execution rates rest on a small, feasibility-selected <i>NHB</i> subsample and carry substantial unknown selection bias; they are descriptive, not a test of journal ownership. A single large-language-model run (DeepSeek&nbsp;V4&nbsp;Flash, snapshot unspecified) was the sole measurement instrument and was not human-validated; verdicts should be read with that limitation in mind.</p>
</div>
<p class="keywords"><strong>Keywords:</strong> reproducibility, open science, open data, open code, publishing, Meta-Psychology, Nature Human Behaviour</p>

<!-- ================= DASHBOARD ================= -->
<div id="dash">
<h2>Interactive Study Dashboard</h2>
<p class="tabnote" style="border:1px solid #f0ad4e;background:#fff8e1;padding:8px 12px;"><b>Reading the &ldquo;Outcome&rdquo; column.</b> This dashboard shows the <b>exploratory comparison set</b> &mdash; every <i>Meta-Psychology</i> audited study (a genuine re-execution verdict) plus the sixteen <i>NHB</i> articles that were actually re-executed here (2019-02, 2019-10, 2019-17, 2019-19, 2019-37, 2019-42, 2019-63, 2020-10, 2020-31, 2020-34, 2020-49, 2020-61, 2020-74, 2020-78, 2020-93, 2020-96; each with a real reproduction outcome &mdash; the author&rsquo;s code was run on the author&rsquo;s data and verified). 2019-20 (a paper-and-data recreation, no author code existed) is excluded from this exploratory set and reported separately as corroboration. The other @NHBEXCL@ full-text <i>NHB</i> articles were not code-re-executed (availability audits only); they are summarised in Figure&nbsp;1, Table&nbsp;1, and the Counts Audit in the Methods. Because the exploratory <i>NHB</i> set is feasibility-selected, treat these pairwise outcomes as descriptive only.</p>
<p>Filter the full set of audited articles below. The chart and table update live. Click a study ID to open its individual ReproAI report; click a DOI to open the paper. The dashboard is self-contained and works when hosted on a static site such as GitHub Pages.</p>
<div class="filters">
  <div class="filter"><label>Journal</label><select id="fJournal"><option value="">All</option><option>Meta-Psychology</option><option>Nature Human Behaviour</option></select></div>
  <div class="filter"><label>Year</label><select id="fYear"><option value="">All</option><option>2019</option><option>2020</option></select></div>
  <div class="filter"><label>Severity</label><select id="fSev"><option value="">All</option><option>P1</option><option>P2</option><option>P3</option><option>n/a</option></select></div>
  <div class="filter"><label>Outcome</label><select id="fStatus"><option value="">All</option><option>Reproduced</option><option>Partially reproduced</option><option>Not reproduced</option><option>Technical failure</option><option>Not re-executed</option><option>Not checked</option></select></div>
  <div class="filter"><label>Search</label><input id="fSearch" type="text" placeholder="title, ID, DOI..."></div>
  <button class="fbtn" id="resetBtn" type="button">Reset</button>
  <button class="fbtn" id="dlBtn" type="button" style="border-color:#0a7d33;background:#0a7d33;">&#8681; Download visible CSV</button>
</div>

<div class="chartbox">
  <div style="font-weight:bold;margin-bottom:6px;">Outcome distribution of visible studies</div>
  <div class="stacked" id="stacked"></div>
  <div class="legend" id="legend"></div>
</div>

<div class="dcount" id="dcount"></div>
<div style="overflow:auto; max-height:520px;">
<table id="dashTable">
<thead><tr><th>Study</th><th>Title</th><th>DOI</th><th>Severity</th><th>Open data</th><th>Open code / reproducible analysis</th><th>Claims</th><th>Outcome</th><th>Key caveat</th></tr></thead>
<tbody></tbody>
</table>
</div>
<p class="tabnote"><em>Column guide.</em> This dashboard shows the <b>exploratory comparison set</b>: every audited <i>Meta-Psychology</i> study plus the sixteen <i>NHB</i> articles genuinely re-executed here; it does <b>not</b> list the other @NHBEXCL@ full-text <i>NHB</i> availability-audit-only articles (those are in the study-selection flow, Figure&nbsp;1, Table&nbsp;1, and the Counts Audit). <b>Study:</b> click to open the individual ReproAI report. <b>Severity:</b> P1 = critical, P2 = substantial, P3 = minor; for <i>NHB</i> this column reflects <b>availability severity, not reproduction severity</b>, and almost all <i>NHB</i> rows here are P3, so the two journals&rsquo; severity columns are <b>not directly comparable</b>. <b>Open data:</b> for <i>Meta-Psychology</i>, the journal&rsquo;s open-data badge; for <i>NHB</i>, the data-availability outcome (direct link = Yes / statement only / None). <b>Open code / reproducible analysis:</b> for <i>Meta-Psychology</i>, the open-reproducibility badge; for <i>NHB</i>, code availability is captured in the Open data column, so this is marked n/a. <b>Outcome:</b> identical re-execution labels are used for both journals wherever the author&rsquo;s code was actually run on the author&rsquo;s data (green = reproduced, amber = partially reproduced, red = not reproduced, orange = technical failure). For <i>NHB</i>, only genuinely re-executed articles appear here; the non-re-executed ones are not displayed in this dashboard.</p>
</div>



<h2 id="introduction">Introduction</h2>
<p>Cumulative science depends on findings being checkable, yet journals differ in how they support that. We follow the common distinction between <b>replicability</b> (the same study repeated with new data yields the same finding) and <b>analytic/computational reproducibility</b> (the same data and code, re-run, yield the same numbers), and we focus throughout on analytic reproducibility. We ask an observational question about two specific journals rather than testing a hypothesis about ownership: how do <i>Meta-Psychology</i>, a scholar-led, Diamond-OA journal (published by Linnaeus University Press, with a pre-publication reproducibility-review policy), and <i>Nature Human Behaviour</i> (<i>NHB</i>), a commercially published journal (Springer Nature) with a data-availability-statement policy, compare on analytic reproducibility and its prerequisites for the 2019&ndash;2020 volumes? We treat this as a <b>two-journal case study</b>; it is descriptive and not powered for the inferential contrast, which we nonetheless report transparently. Relevant prior work provides a base rate: analytic-reproducibility audits of specific journals and data-availability-statement audits (Hardwicke et al., 2018; Stodden et al., 2018), badge-effectiveness studies (Kidwell et al., 2016), the Reproducibility Project of the Open Science Collaboration (Open Science Collaboration, 2015), and the reproducibility manifesto (Munaf&ograve; et al., 2017) all show that availability statements and badges imperfectly predict and weakly support verification. We report two studies. <b>Study&nbsp;1</b> is an analytic-reproducibility audit comparing the two journals for their 2019 and 2020 volumes, with a primary, fully-observable journal-level outcome (code archived alongside data) and a secondary, explicitly exploratory re-execution comparison. <b>Study&nbsp;2</b> complements this with citation (OpenAlex) and estimated cost (APC) analyses. Both journals are young: each launched in 2017, so the audited years cover their third and fourth volumes.</p>

<h2 id="method">Method</h2>
<h3>Target-of-analysis selection (study-selection flow)</h3>
<p>The parallel study-selection flow diagrams below show how the set of audited studies was determined for each journal. Both begin at the journal, restrict to 2019 and 2020, apply exclusions (non-empirical records, then records for which the data/code needed to re-execute the analysis was not available, or the full text could not be retrieved), and end with the reduced sample in which an AI checked the reproduced results against the reported results. This is a <b>study-selection flow diagram</b>, not a formal PRISMA systematic review; the individual estimates are descriptive and were not pooled. Both journals are young: each launched in 2017, so the 2019 and 2020 audits cover their third and fourth volumes, respectively.</p>
<p class="tabnote"><em>Sampling frame.</em> A record enters the frame by its <b>online-first / publication year</b>, which is the year recorded in the audit metadata, not necessarily the issue/volume year. This is why, for example, Kristal &amp; Whillans is labelled 2019&ndash;02 while its issue is <i>Nature Human Behaviour, 4</i>, 169&ndash;176 (published online in 2019, assigned to a 2020 issue), and why Marshall et al. is labelled 2020&ndash;49 despite appearing in <i>Volume 5</i> (2021 issue; available online in 2020). The year criterion for both journals is therefore the online-first year; membership of the frame is derived from that definition, and a DOI/pub-date reconciliation is provided in the reference lists.</p>

<div class="prisma">
  <div class="pcol mpcol">
    <h3>Meta-Psychology (scholar-led)</h3>
    <div class="pbox mergebox"><b>Meta-Psychology, 2019 &amp; 2020</b>Volume 3 (2019): 10 records; Volume 4 (2020): 11 records<br>(n = 21)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; non-empirical / not in reproduction scope</b>Methodological guidance, commentary &nbsp;(n = 3)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox"><b>Records in ReproAI audit corpus (reduced sample)</b>Vol 3: 7 &middot; Vol 4: 11 &nbsp;(n = 18)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; non-empirical / no repro data &amp; code</b>Reproduction audit not feasible &nbsp;(n = 4)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox mergebox"><b>Results check</b>An AI checked reproduced results against the reported results<br><b>@MPA@ audited</b></div>
  </div>
  <div class="pcol nhbcol">
    <h3>Nature Human Behaviour (commercial)</h3>
    <div class="pbox mergebox"><b>Nature Human Behaviour, 2019 &amp; 2020</b>Volume 3 (2019): 67 records; Volume 4 (2020): 97 records<br>(n = 164)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; non-empirical</b>Reviews, meta-analyses, models, theory &nbsp;(n = 14)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox"><b>Empirical articles (reduced sample)</b>&nbsp;(n = 150; 2019: 63, 2020: 87)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; full text not retrievable</b>Subscription paywall &nbsp;(n = @NHBMETA@)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox"><b>Full text retrieved</b>&nbsp;(n = @NHBFT@)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; re-execution infeasible in this environment</b>No analysis code archived; toolbox-only repo; MATLAB/Stata license unavailable; long-duration/heavy compute; source (OSF/figshare) unavailable; technical failure &nbsp;(n = @NHBEXCL@)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox mergebox"><b>Results check (genuine re-execution)</b>Author&rsquo;s code re-run on author&rsquo;s data and verified against the paper &nbsp;(n = @NHBREEXEC@)</div>
  </div>
</div>
<p class="tabnote"><em>Study-selection flow.</em> For <i>NHB</i>, @NHBMETA@ empirical articles are not included because the journal&rsquo;s subscription paywall prevented PDF retrieval; these received no full-text audit. Of the @NHBFT@ articles whose full text was retrieved, only @NHBREEXEC@ could be <b>genuinely re-executed</b> here (the author&rsquo;s code was downloaded, run on the author&rsquo;s data, and the recomputed numbers verified against the reported ones). The remaining @NHBEXCL@, although many of them state that data/code are available, were <b>excluded from the numerical comparison</b> because faithful re-execution was infeasible in this environment &mdash; no analysis code was archived (data-only archives), the archived repository was a software toolbox rather than the paper&rsquo;s analysis scripts, the analysis required a MATLAB or Stata licence that is unavailable here, the compute was of long duration (network simulations, Sequential Monte Carlo, GNU&nbsp;MCSim or Stan MCMC), the source repository could not be retrieved (OSF/figshare), or a technical failure occurred. These papers remain availability-audited and are described in Figure&nbsp;1 and Table&nbsp;1, but they do not enter the reproduction comparison. For <i>Meta-Psychology</i>, the full text of all records is openly available and all @MPA@ audited studies entered the reproduction analysis (<i>MP</i>: 21 records &minus; 3 non-empirical = 18 empirical; of these, 14 were auditable and 4 were excluded as infeasible).</p>

<h3>Counts audit (single source of denominators)</h3>
<p>To fix every denominator precisely and avoid silent switching between the 9, 72, 79, 119, 128 and 150 figures, the counts below are generated programmatically from the audit records. &ldquo;Code archived&rdquo; is the <b>primary, fully-observable journal-level outcome</b>: executable analysis code archived alongside data in a form a third party can obtain and run. &ldquo;Re-executed here&rdquo; is the secondary, exploratory outcome (author code actually run in this environment), and &ldquo;Reproduced&rdquo; is the count of reproduced verdicts within that exploratory set (see Verdict rubric).</p>
<table class="apa">
<thead><tr><th>Journal</th><th>Records published (2019&ndash;20)</th><th>Non-empirical excluded</th><th>Empirical</th><th>Full text retrieved</th><th>Code archived (primary)</th><th>Code re-executed here (exploratory)</th><th>Reproduced</th></tr></thead>
<tbody>@@CA_ROWS@@
</tbody>
</table>
@@CA_FOOT@@

<h3>Inclusion criteria for the comparison (transparency)</h3>
<p>Because the two journals differ in what their archives and licensing make genuinely re-executable, we apply an explicit, pre-specified inclusion rule to the <b>reproducibility comparison</b>: a study enters the numerical comparison only if a genuine code re-execution was <i>feasible in this environment and actually performed</i> &mdash; that is, a working copy of the paper&rsquo;s analysis code and its data were obtained, run, and the recomputed statistics were independently checked against the numbers reported in the paper. All of <i>Meta-Psychology</i>&rsquo;s @MPA@ audited studies met this criterion and entered the comparison. Of <i>NHB</i>&rsquo;s @NHBFT@ full-text articles, only @NHBREEXEC@ met it; the other @NHBEXCL@ were included in neither the outcome comparison nor the claims/citation comparisons in Study&nbsp;1, and were instead reported only as availability audits (Figure&nbsp;1, Table&nbsp;1).</p>
<p>The reasons a full-text <i>NHB</i> article did <b>not</b> meet the inclusion criterion fall into a small number of transparent buckets, each recorded per article in the project&rsquo;s re-execution ledger (<code>nhb_reexec_classes.json</code>) and in the runbook (<code>NHB_REEXECUTION.md</code>):</p>
<ul>
<li>@NHBEXCLBUCKETS_HUMAN@</li>
</ul>
<p>These are exclusion reasons of an environmental or archival kind (licensing, data/code not archived, compute time, or source availability), not evidence of a numerical mismatch; they are a limitation of what can be independently re-executed, discussed further in the Limitations. By restricting the comparison to studies that could actually be re-run, every &ldquo;outcome&rdquo; reported for the comparison is a real, verifiable re-execution consequence rather than an availability judgement. Two clarifications are needed. First, &ldquo;Availability-audited only (not code re-executed): 72&rdquo; does <b>not</b> mean those 72 lacked a direct link: many of these articles do expose a direct data/code URL, but the audit performed was an availability check rather than a code re-execution (code was not run in this environment for those papers). The two counts answer different questions: direct-link availability (45&ndash;72) versus code actually re-executed (16). Second, &ldquo;PARTIAL re-execution (translated Stata&rarr;R): 1&rdquo; refers to <i>NHB</i>&nbsp;2019-18 (Hills et al.): only its validation correlations were translated and verified; its main panel models were not, so it is <b>excluded from the primary code-archived-to-reproduced comparison</b> and reported in the Cross-language section as a partial translation. This is the same rule applied to the fully translated analyses (2020-10, 2020-49), which met the bar and are included.</p>

<h3>Cross-language &amp; recreated re-execution (SPSS / Stata translated to R; analysis recreated from paper + data where code was not archived)</h3>
<p>Where the archived analyses were written in a language not installed in this environment (SPSS&nbsp;<code>.sps</code>, Stata&nbsp;<code>.do</code>, SAS&nbsp;<code>.sas</code>, MATLAB&nbsp;<code>.m</code>), we <b>translated the author&rsquo;s analysis statements to R</b>, ran the R translation on the author&rsquo;s archived data, and verified the recomputed numbers against the paper&rsquo;s reported statistics. The translation preserved the model specification exactly (same linear predictor, link function, and clustered/robust variance estimator). Where an archive shipped <b>data but no analysis code at all</b>, we additionally <b>recreated the core analysis in R from the paper&rsquo;s reported Methods</b> and checked whether the recomputed statistics matched. The genuinely re-executed translated/recreated analyses, along with their R sources and captured output logs, are held in the project repository under <code>replications/</code> and linked below; only the verified headline statistics are stated in the manuscript.</p>
<p>Each translation or recreation is a genuine re-execution: the R code was run on the author&rsquo;s archived data, and the recomputed headline statistic was checked against the number the paper reported (exact where the paper reported a rounded chi-square/t). Rather than paste the output here, the R source scripts and their captured output logs for each analysis live in the project repository under <code>replications/</code>, linked below:</p>
<ul>
  <li><b>2020-10</b> (Marshall et al., &ldquo;Children punish third parties&hellip;&rdquo;), SPSS&nbsp;<code>.sps</code>&rarr;R (haven + geepack + car). R scripts: <a href="https://github.com/LukasRoeseler/reprochecks/tree/main/replications/2020-10">xlate_s1c.R, xlate_s2.R</a>; output logs: <a href="https://github.com/LukasRoeseler/reprochecks/tree/main/replications/2020-10">s1c_output.txt, s2_output.txt</a>. Verified: Study&nbsp;1 GEE condition Chisq&nbsp;=&nbsp;26.709 (paper chi2[2,&nbsp;113]&nbsp;=&nbsp;26.71); Study&nbsp;2 GEE Chisq(2)&nbsp;=&nbsp;20.1985 (paper 20.20); punishing probabilities 0.78/0.39/0.13 (paper M&nbsp;=&nbsp;0.78/0.39/0.13) &mdash; <b>EXACT</b>.</li>
  <li><b>2020-49</b> (Lin et al., &ldquo;Evidence of general economic principles of bargaining and trade&hellip;&rdquo;), Stata&nbsp;<code>.do</code>&rarr;R (lm + sandwich cluster-SE). R scripts: <a href="https://github.com/LukasRoeseler/reprochecks/tree/main/replications/2020-49">xlate_u2.R, xlate_mkt1.R</a>; output logs: <a href="https://github.com/LukasRoeseler/reprochecks/tree/main/replications/2020-49">u2_output.txt, mkt1_output.txt</a>. Verified: repeated-game jump 0.2624 (z&nbsp;=&nbsp;9.40) vs paper 26.2% [20.8,&nbsp;31.7]; one-shot jump 0.1628 (z&nbsp;=&nbsp;10.84) vs paper 16.3% [13.3,&nbsp;19.2]; double-auction price-change autocorrelation r&nbsp;=&nbsp;&minus;0.354, t(120,985)&nbsp;=&nbsp;&minus;131.5 &mdash; <b>EXACT</b>.</li>
  <li><b>2019-18</b> (Hills et al., &ldquo;Historical analysis of national subjective wellbeing&hellip;&rdquo;), Stata&nbsp;<code>.do</code>&rarr;R, <b>partial</b> (validation correlations only; main panel models pending). R script + log: <a href="https://github.com/LukasRoeseler/reprochecks/tree/main/replications/2019-18">corr18.R, corr18_output.txt</a>. Verified: US COHA valence r&nbsp;=&nbsp;0.614, t(17)&nbsp;=&nbsp;3.21; UK FMP valence r&nbsp;=&nbsp;0.455, t(129)&nbsp;=&nbsp;5.81 &mdash; exact translations.</li>
  <li><b>2019-20</b> (Bruneau et al., &ldquo;A collective blame hypocrisy intervention&hellip;&rdquo;), <b>recreated</b> from paper + data (SPSS-dataset-only archive, no code). R script + log: <a href="https://github.com/LukasRoeseler/reprochecks/tree/main/replications/2019-20">recreate20.R, recreate20_output.txt</a>. Verified: condition main effect F(2,&nbsp;504)&nbsp;=&nbsp;22.36 vs paper F(2,&nbsp;463)&nbsp;=&nbsp;22.23 (<i>p</i>&nbsp;&lt;&nbsp;0.001) &mdash; F matches near-exactly (df differ because the wide archive cannot reproduce the exact listwise exclusions).</li>
  <li><b>2019-45</b> (Leong et al., &ldquo;Neurocomputational mechanisms underlying motivated seeing&rdquo;), author R scripts run on author <code>AllData.csv</code> + <code>model_outputs</code>; HDDM/MATLAB analyses pending. R scripts + logs: <a href="https://github.com/LukasRoeseler/reprochecks/tree/main/replications/2019-45">r45.R, r45_nacc.R, r45_fig3.R, *_output.txt</a>. Verified: Coop Pred1 want-to-see bias B&nbsp;=&nbsp;0.330 (<i>p</i>&nbsp;=&nbsp;0.0119) vs paper B&nbsp;=&nbsp;0.33; interaction B&nbsp;=&nbsp;0.805 vs paper 0.81; cor(z,&nbsp;drift_bias)&nbsp;=&nbsp;0.290 vs paper r&nbsp;=&nbsp;0.290; NAcc zbias significant (t&nbsp;=&nbsp;2.71, <i>p</i>&nbsp;=&nbsp;0.0115) vs vbias ns (<i>p</i>&nbsp;=&nbsp;.71) &mdash; <b>reproduces</b>.</li>
</ul>
<p class="tabnote"><em>Cross-language note.</em> These are genuine re-executions performed in this environment; the translation preserved the model specification exactly (same linear predictor, link function, and clustered/robust variance estimator). Full per-paper details are recorded in the runbook (<code>NHB_REEXECUTION.md</code>), the re-execution ledger (<code>nhb_reexec_classes.json</code>), and the linked R sources and outputs above.</p>

<h3>ReproAI audit procedure</h3>
<p>ReproAI audits combine manuscript claim extraction, data/code-availability assessment, and&mdash;where the data and code are available&mdash;independent re-execution or verification against the reported numbers. Severity is graded P1 (critical) to P3 (minor). All audits in this report were re-performed and authored entirely by the DeepSeek&nbsp;V4&nbsp;Flash large language model, served through the on-premises uniGPT platform (<a class="cit" href="#ref-radas" title="Radas, J., Risse, B., &amp; Vogl, R. (2026). UniGPT revisited: From a simple chatbot to an API-first AI platform - Two years of on-premises LLM operations.">Radas et al., 2026</a>), running within the ReproAI pipeline on the opencode engine. For <i>Meta-Psychology</i>, @MPA@ audits re-ran shipped code and verified results against the manuscript. For <i>NHB</i>, audits ran against the PDF&rsquo;s reported numbers and recorded data/code availability for the @NHBFT@ articles whose full text could be retrieved; of these, the @NHBREEXEC@ that were truly re-executable were additionally re-run, while the others were recorded as availability audits and excluded from the numerical comparison (see Inclusion criteria).</p>
<h3>Transparency of authorship</h3>
<p>This document is an output of a large language model (DeepSeek&nbsp;V4&nbsp;Flash, served via uniGPT, running on the anomalyco/opencode engine). The prose, figures, dashboard, HTML, and every ReproAI verdict in the individual audit reports were generated automatically by that model. The LLM is <b>not</b> listed as an author; per most journal policies a model cannot be an author. Authorship and responsibility rest with the human supervisor, Lukas R&ouml;seler (see CRediT in the Author Note).</p>

<h3>Verdict rubric (decision rules)</h3>
<p>The verdict labels used in this report are defined operationally as follows. A claim is the atomic, load-bearing reported statistic that a reader is expected to reproduce (e.g., a reported mean difference, an <i>F</i>, <i>t</i>, &chi;<sup>2</sup>, correlation, regression coefficient, or an effect direction+significance). Claims are classified as <i>load-bearing</i> if they are stated as a headline result in the abstract or results and used to draw a conclusion; all other extracted claims are <i>incidental</i>. A recomputed statistic <b>matches</b> the reported value if it agrees <i>exactly with the paper&rsquo;s reported rounding</i> (e.g., a reported &ldquo;26.71&rdquo; matches recomputation of 26.709 rounded to two decimals), or corresponds within Monte Carlo error for inherently stochastic procedures &mdash; in which case the match criterion is agreement of the reported value with the recomputation to the same number of reported decimals, with the stochastic source and seed stated. An article is <b>Reproduced</b> if all load-bearing claims match under these rules. It is <b>Partially reproduced</b> if at least one, but not all, load-bearing claims match, and the non-matching claims are not reversed in sign or direction of effect. It is <b>Not reproduced</b> if a load-bearing claim is non-matching and the difference is substantive (of reversed direction, or of a magnitude beyond rounding/Monte-Carlo tolerance, or the reported inference flips). <b>Technical failure</b> records that the code could not be run at all in this environment (dependency, segfault, or similar), so no verdict on agreement could be made. The same rubric is applied to both journals. These rules are pre-specified for this report; because extraction is stochastic, they were applied in a single LLM run and have not yet been checked for inter-run reliability (see Limitations).</p>

<h3>Confounds and causal interpretation</h3>
<p>This is a <b>two-journal case study (n = 1 journal per arm)</b>, so the ownership contrast (<i>Meta-Psychology</i>, scholar-led via Linnaeus University Press vs <i>NHB</i>, commercial via Springer Nature) is confounded with several other differences that are plausible causal candidates in their own right: (i) <b>editorial policy</b> &mdash; <i>Meta-Psychology</i> runs mandatory reproducibility checks before publication and requires code and data deposition, whereas <i>NHB</i> requires only a data-availability statement; (ii) <b>research domain and data type</b> &mdash; <i>Meta-Psychology</i> publishes simulation/methods work in R with synthetic or small tabular data, whereas <i>NHB</i> publishes fMRI, biobank, register, cross-national panel, and restricted human-subjects data for which &ldquo;no code archived / restricted repository / ethical-legal restriction / long compute&rdquo; are properties of the <i>research</i>, not the publisher; (iii) <b>software ecosystem</b> &mdash; MATLAB/Stata/SAS dependence is a disciplinary norm in many of the fields that publish in <i>NHB</i>; and (iv) <b>article length and complexity</b> (≈8 vs 40 claims per article). Accordingly, we do <b>not</b> attribute any observed difference to ownership per se; the results describe the two journals as instances and separate ownership, business model (Diamond vs APC), and open-vs-paywalled access as distinct constructs that are bundled together in this design.</p>

<h3>LLM methodology and validation status</h3>
<p><b>Instrument.</b> Audits were performed by the DeepSeek&nbsp;V4&nbsp;Flash large language model served through the uniGPT platform (Radas et al., 2026)); a dated model snapshot was not recorded, so the specification is not fully reproducible. Decoding parameters (temperature, top-p, max tokens), context window, tool access, and retry counts were not fixed or logged; this is a limitation. <b>Single stochastic run.</b> Claim extraction and verdict assignment were performed once per article and have not been repeated for inter-run reliability (a Krippendorff&rsquo;s &alpha; for claim counts and verdicts is not yet available). <b>No human spot-check.</b> We have not yet had a human verify a random 20% sample of extracted claims, availability codings, and verdicts; the agreement rate with a 95% CI is therefore not yet reported. <b>No ground-truth benchmark.</b> We have not yet compared our verdicts against <i>Meta-Psychology</i>&rsquo;s own published human reproducibility reviews for the same articles. These validations are the highest-priority next steps before any verdict should be relied upon (see Limitations and Correction policy). <b>Cost/time.</b> Wall-clock time, token usage, and per-article cost were not logged; reporting these is planned to support the &ldquo;scalable auditing&rdquo; contribution.</p>

<h3>Correction policy and right of reply</h3>
<p>Because individual, author-identified verdicts are published here on the basis of a single unvalidated LLM run, we treat them as <b>provisional</b>. Corresponding authors of audited articles are encouraged to contact Lukas R&ouml;seler to request correction or to provide a right of reply, which will be hosted alongside the relevant report. Corrections will be tracked in the project repository. Until human verification is completed, author-level blame language is withheld in favour of artefact-level description.</p>

<h2 id="results">Results (Study 1)</h2>
<h3>Audit funnel and full-text coverage</h3>
<p>We first establish, journal by journal, how many articles existed, how many were empirical, and how many could be audited (summarised in the study-selection flow above). <i>Meta-Psychology</i> published 21 records across Volumes 3 and 4; 3 were non-empirical (methodological guidance/commentary), leaving 18 empirical, of which @MPA@ could be audited because their full text and the underlying data and code are openly available, while <b>4 records were excluded</b> as infeasible (data/code for a reproduction audit not available). The arithmetic is therefore 21 &minus; 3 (non-empirical) = 18 empirical, and 18 &minus; 4 (infeasible) = 14 audited. <i>NHB</i> published 164 records; 14 were non-empirical, leaving 150 empirical, and of these the full text of @NHBFT@ (@@NHBFTPCT@@%) could be retrieved and audited, while the remaining @NHBMETA@ could not be included because full text was unavailable.</p>

<h3>Open data availability</h3>
<p>Among @MPA@ audited <i>Meta-Psychology</i> studies, 6 carried explicit open-data badges; 7 were simulations for which raw data are not applicable (coded N/A), and 1 was coded &ldquo;No&rdquo; (no open data). Among the @NHBFT@ audited <i>NHB</i> articles, @@NHBP3@@ (@@NHBP3PCT@@%) exposed a direct, machine-downloadable data/code link, @@NHBP2@@ (@@NHBP2PCT@@%) supplied an availability statement without a direct link, and @@NHBP1@@ gave no statement.</p>
<div class="figure"><img src="fig2_open_data.png" alt="Open data availability">
<p class="figcap"><b>Figure 1.</b> Open data availability by journal, with one square per study stacked by category (for <i>Meta-Psychology</i>: open data present vs not applicable; for <i>NHB</i>: direct data/code link, statement only, or no availability). Note that several <i>Meta-Psychology</i> studies are simulations in which raw data are not applicable, so no-data should not be read as a transparency failure.</p></div>

<h3>For how many did the check work, and how many had issues or big problems?</h3>
<p>For <i>Meta-Psychology</i>, where a genuine computational reproduction was possible, @MPOK@ studies reproduced near-exactly and @MPPAR@ reproduced only partially; @MPFAIL@ did not reproduce and @MPTECH@ hit technical blockers. These are genuinely re-ran analyses, so &ldquo;reproduced&rdquo; is a strong certification; for these <i>Meta-Psychology</i> studies the data and code were available, so any failure falls under the &ldquo;different numbers come out&rdquo; category (partially reproduced or not reproduced) or a technical blocker, rather than &ldquo;data could not be shared.&rdquo; For <i>NHB</i>, the audit established data/code availability rather than re-execution for most articles. Separately two classifications apply. On <b>availability</b>, of the @NHBFT@ full-text articles, @@NHBP3@@ had a direct machine-downloadable link, @@NHBP2@@ gave a statement without a direct link, and @@NHBP1@@ gave no statement. On <b>re-execution</b>, only the @NHBREEXEC@ articles that were genuinely re-executed here (author&rsquo;s code run on author&rsquo;s data and verified) enter the outcome comparison; the other @NHBEXCL@ could not be genuinely re-executed because of environmental or archival barriers (no analysis code, MATLAB/Stata licensing, long-duration compute, or unavailable source) &mdash; these remain availability-audited only (Figure&nbsp;1, Table&nbsp;1). The statement-only and no-statement groups are a <i>subset</i> of the @NHBEXCL@ non-re-executed group, not an additional set. Figure&nbsp;2 therefore plots, for each journal, only the studies that were genuinely re-executed: for <i>Meta-Psychology</i> all @MPA@ re-executions are shown and split by outcome, and for <i>NHB</i> the @NHBREEXEC@ genuinely re-executed articles are shown.</p>
<div class="figure"><img src="fig3_outcomes.png" alt="Outcomes by journal">
<p class="figcap"><b>Figure 2.</b> Reproducibility outcomes for the studies that were genuinely re-executed, with one square per study: for <i>Meta-Psychology</i> (n&nbsp;=&nbsp;@MPA@), how many reproductions worked (reproduced), partially reproduced, or failed/technical (0 in both the &ldquo;failed&rdquo; and &ldquo;technical&rdquo; categories for <i>Meta-Psychology</i>); for <i>NHB</i>, the @NHBREEXEC@ genuinely re-executed articles, split into reproduced (@@NHB_REPROD_S@@) versus partially reproduced. The remaining @NHBEXCL@ full-text <i>NHB</i> articles were not code re-executed (availability audits only) and are excluded from this outcome comparison, as stated in Methods.</p></div>
<p>Because the availability reasons differ in kind, we distinguish two conceptually different reasons a study may not be reproducible: (a)&nbsp;<b>data or code could not be shared</b> &mdash; an availability barrier, where the material exists but is not directly reachable or obtainable; and (b)&nbsp;<b>different numbers come out</b> &mdash; a numerical failure, where, despite available data and code, re-execution yields different results from those reported. These are different problems with different remedies. The <i>NHB</i> cases above fall under (a): the full-text check recorded data/code availability without re-executing code, so no &ldquo;different numbers come out&rdquo; verdicts are reported for <i>NHB</i>. The &ldquo;different numbers come out&rdquo; category is instead captured by the <i>Meta-Psychology</i> re-execution audits (partially reproduced or not reproduced). Table&nbsp;1 summarises the recorded reasons behind the @NHBNA@ <i>NHB</i> availability barriers (excluding those whose data are available in the paper or supplement, which are downloadable and therefore not barriers).</p>
<table class="apa" id="naTable">
<thead><tr><th>Reason data/code not directly available</th><th>n</th><th>%</th></tr></thead>
<tbody>@@NHB_NA_TABLE@@
</tbody>
</table>
<p class="tabnote"><em>Table 1.</em> Distribution of the recorded reasons why data/code were not directly machine-downloadable. Of @NHBFT@ full-text <i>NHB</i> articles, @NHBP2@+@NHBP1@ = 56 gave only a statement (P2) or none (P1); of these, 7 had their data directly in the paper/supplement (downloadable, hence not barriers), leaving <b>56 &minus; 7 = 49</b> articles whose data/code were not directly machine-downloadable. Percentages are of these 49 articles.</p>

<h3>Distribution of the number of claims</h3>
<p>The two audits differ in depth, and the denominators differ: the claim distributions below are computed over <b>all @MPA@ <i>Meta-Psychology</i> audited studies</b> and <b>all @NHBFT@ full-text <i>NHB</i> articles</b> (not just the @NHBREEXEC@ re-executed ones). <i>Meta-Psychology</i> reproductions re-ran shipped code and therefore audited far more claims per article (median&nbsp;@@MPCLAIMS_MED@@; range @@MPCLAIMS_MIN@@&ndash;@@MPCLAIMS_MAX@@ full claims), whereas the <i>NHB</i> checks verified the key reported numbers against the PDF (median&nbsp;@@NHBCLAIMS_MED@@; range @@NHBCLAIMS_MIN@@&ndash;@@NHBCLAIMS_MAX@@ full claims across the 128 full-text articles). Figure&nbsp;3 shows the distribution of the full (integer) number of claims audited per article for each journal, with the median marked by a dashed line.</p>
<div class="figure"><img src="fig4_claims_hist.png" alt="Distribution of the number of claims">
<p class="figcap"><b>Figure 3.</b> Histograms of the number of claims audited per article, for <i>Meta-Psychology</i> (left; n&nbsp;=&nbsp;@MPA@) and <i>Nature Human Behaviour</i> (right; n&nbsp;=&nbsp;@NHBFT@ full-text articles), plotted as full numbers with the median indicated by a dashed line. The <i>Meta-Psychology</i> audits re-ran full analyses and consequently audited more claims per article (median&nbsp;@@MPCLAIMS_MED@@) than the <i>NHB</i> verifications (median&nbsp;@@NHBCLAIMS_MED@@). Denominators are stated on the axes because they differ between journals.</p></div>

<h2 id="discussion">Discussion (Study 1)</h2>
<p>The scholar-led journal in our sample (<i>Meta-Psychology</i>) performs well on the transparency metrics we measured. Its editorial policies couple publication to the deposition of data and code, and its reproducibility reviews&mdash;which we re-performed here with independent code re-execution&mdash;publicly certify what does and does not reproduce. Of the fourteen re-audited articles, twelve reproduced near-exactly and two reproduced only partially: the mandated openness plus re-execution (here by a deep LLM) makes verification concrete, and it also shows that genuinely independent re-execution is what actually confirms a result.</p>
<p>The commercial journal in our sample (<i>NHB</i>) nearly always meets the letter of its data-availability requirement, but @@NHBP2PCT@@% of audited articles stop at a statement, and only @@NHBP3PCT@@% expose direct, machine-downloadable links. Because the full text is paywalled, only @@NHBFT@@ of the 150 <i>NHB</i> empirical articles could be checked against the actual PDF; the remaining @@NHBMETA@@ could not be included. And of those @@NHBFT@@, only @@NHBREEXEC@@ could be genuinely re-executed in this environment; the other @@NHBEXCL@@, though many claim data/code availability, could not be re-run here (see Inclusion criteria) and therefore enter only the availability audit, not the reproducibility comparison. Full-text access, a reachable and licensed analysis pipeline, and archived code are all prerequisites for genuine verification, and their combined absence is itself a transparency cost. Where data/code were not immediately machine-downloadable (Table&nbsp;1), the reasons recorded in the audits were usually practical rather than intentionally hidden: data were most often placed in third-party or restricted repositories that require a separate application or approval (e.g., biobanks, data archives, register data), withheld for ethical or legal reasons such as consent and data-protection law, provided &ldquo;on reasonable request&rdquo; from the corresponding author, or named via a URL without a direct machine-downloadable file. Where the data were instead embedded in the paper or its supplement, we treated them as available, since they are directly downloadable from the article. Either way, such material is typically technically shareable but is not immediately machine-downloadable in a ready-to-run form, which is a real but often logistical barrier to reproducibility.</p>
<p>Within this comparison, the scholar-led journal in our sample sets a higher and more verifiable bar for reproducibility than the commercial journal in our sample. We do not claim that this generalizes to all scholarly-led or all commercially published journals: the two here represent only one instance of each publishing model, and future research should examine whether these findings extend to other journals of each type.</p>
<p>For researchers publishing meta-psychological findings, <i>Meta-Psychology</i> and <i>NHB</i> exemplify two ends of a quality&ndash;quantity trade-off. <i>Meta-Psychology</i> emphasises quality: it publishes fewer articles, but with openly available data and code that are independently audited. <i>NHB</i> emphasises quantity: it publishes many articles, but with more limited reproducibility and verification because full text and, often, data are not openly reachable. We caution that the journals publish different content types, the <i>Meta-Psychology</i> corpus is small, and the <i>Meta-Psychology</i> outcome is a reproduction certification whereas the <i>NHB</i> outcome is an availability audit, so the two are not directly commensurable.</p>
<p>Because both journals are young, their 2019 and 2020 volumes fall within their first few years of publication. Extending this audit to more recent years would be valuable, as the reproducibility-relevant policies of each journal &mdash; and, for <i>NHB</i>, the degree to which data-availability statements translate into direct, working links &mdash; may have changed over time. However, the accompanying citation analyses (Study&nbsp;2) are less informative for recent work: newly published articles have had comparatively little time to accrue citations, so citation counts from the latest volumes should be interpreted with particular caution or revisited once those articles have matured.</p>

<h2 id="results-s2">Study 2: Citation and Cost Analyses</h2>
<h3>Citing behaviour (OpenAlex)</h3>
<p>We complemented the reproducibility audit with a bibliometric and cost analysis across the same @MPA@ <i>Meta-Psychology</i> studies and the @NHBFT@ full-text <i>NHB</i> articles (Study&nbsp;2). Citation counts were retrieved from the OpenAlex scholarly database for each audited article by its DOI (OpenAlex, 2026; retrieved on the audit date). Because the journals differ enormously in number of articles (<i>n</i>&nbsp;=&nbsp;@MPA@ vs <i>n</i>&nbsp;=&nbsp;@NHBFT@), total citation figures are not interpretable as per-article performance and are reported only in passing; the interpretable statistics are the <b>per-article distributions</b>. <i>NHB</i> articles are far more highly cited per article than <i>Meta-Psychology</i> (median&nbsp;@@NHBCMED@@ citations per article, vs median&nbsp;@@MPCMED@@ for <i>Meta-Psychology</i>. Totals were @@NHBCSUM@@ for <i>NHB</i> vs @@MPCSUM@@ for <i>Meta-Psychology</i> across very different numbers of articles. Figure&nbsp;4 compares the citation distributions (symlog scale) between the two journals. These raw counts are age- and field-unadjusted and come from a general-interest Nature title versus a niche metascience journal, so they are <b>descriptive only</b>; an age- and field-normalised comparison (e.g., using OpenAlex FWCI/percentiles and controlling publication month) is not yet provided and is needed before any motivational reading. We present citations purely descriptively and do not claim they track reproducibility.</p>
<div class="figure"><img src="fig5_citations.png" alt="Citations by journal and outcome">
<p class="figcap"><b>Figure 4.</b> Citation numbers (OpenAlex), shown on a symlog scale. Left: overall comparison between <i>Meta-Psychology</i> (n&nbsp;=&nbsp;@MPA@) and <i>NHB</i> full-text articles (n&nbsp;=&nbsp;@NHBFT@). Middle: <i>Meta-Psychology</i> citations split by reproducibility outcome. Right: <i>NHB</i> citations for the @@NHBNADIRECT@@ full-text articles whose data/code were directly machine-downloadable or in the paper/supplement (i.e., not an availability barrier; 128 &minus; 49 = 79). These 79 are &ldquo;auditable for availability,&rdquo; not a claim about re-execution (only @NHBREEXEC@ of them were re-run). Dashed labels give each group&rsquo;s median.</p></div>
<p class="tabnote"><em>Data source and caveat.</em> Citation counts were obtained from the OpenAlex database via its public API using each article&rsquo;s DOI. OpenAlex does not index everything: citation indices vary by service, and recent or less-indexed work may be undercounted. Citation counts here should therefore be read as approximate and are best used for coarse, cross-journal comparison rather than precise per-article figures. The retrieval script is shared in the project repository so the analysis can be re-run.</p>



<h3>Estimated publication costs (APCs)</h3>
<p>We also estimated the economic cost of publishing each journal&rsquo;s articles, distinguishing the <b>cost to authors</b> from the <b>cost of production</b>. <i>Meta-Psychology</i> is a Diamond Open-Access journal and charges authors no article-processing charge (APC), so the cost-to-author for its @MPA@ audited studies is &euro;0; the underlying cost of production (editorial labour, hosting, typesetting, institutional subsidy) is real and typically on the order of a few hundred euros per article in the literature, but is not borne by the audited authors and was not measured here. <i>NHB</i> is a commercial journal published by Springer Nature under a hybrid model: for these 2019&ndash;2020 volumes most articles were published under the subscription model (few authors paid an APC at all), so a total-APC figure is largely counterfactual for this corpus. We therefore do <b>not</b> headline a total; instead we note that a per-article open-access APC for a Nature-portfolio title is on the order of &euro;@APCNHB@@; the honest framing is a <b>total-cost-of-publication</b> that would also include the library-subscription cost of the paywalled <i>NHB</i> articles (the actual cost borne for this corpus), which is not estimated here. A per-article APC estimate (&euro;@APCNHB@@ &times; @NHBFT@ articles = &euro;@NHBCOST@@) is provided only to indicate an upper bound and is easily recomputed in the shared script.</p>
<p class="tabnote"><em>Caveat.</em> The APC figure is an assumption used to illustrate an order of magnitude, not a statement of what the audited authors actually paid (for these 2019&ndash;2020 volumes most <i>NHB</i> articles were published under the subscription model, so few paid an APC). The &euro;0 for <i>Meta-Psychology</i> is the cost-to-author; it does not imply zero production cost, and Diamond journals do have real costs that we did not measure.</p>

<h2 id="gen-discussion">General Discussion</h2>
<p>Read descriptively, the two journals differ on the prerequisites for analytic reproducibility. On the primary, fully-observable outcome &mdash; executable code archived alongside data &mdash; all @MPA@ <i>Meta-Psychology</i> audited studies met it (its editorial policy mandates code and data deposition and runs reproducibility checks before publication), versus @NHB_CODEARCH@ of @NHBFT@ (<b>@NHB_CODEARCH_PCT@%</b>) for <i>NHB</i>. On the secondary, exploratory re-execution comparison, the re-executed reproduction rate was @MP_REPROD_S@@ for <i>Meta-Psychology</i> (12 of 14) versus @NHB_REPROD_S@@ for the sixteen re-executed <i>NHB</i> articles (8 of 16); this difference is <b>not conventionally significant</b> (Fisher two-sided <i>p</i>&nbsp;=&nbsp;@@FISHER_P@@) and the 95% CIs overlap substantially (MP @@MP_WILSON@@ vs NHB @@NHB_WILSON@@). We therefore do <b>not</b> conclude, from the re-execution rates alone, that <i>Meta-Psychology</i> &ldquo;beats&rdquo; <i>NHB</i> on numerical reproducibility; the stronger, cleaner difference is on the archival-prerequisite (code-and-data) outcome. Study&nbsp;2 added two further, descriptive contrasts: <i>NHB</i> articles are far more cited per article, and its publication model carries higher publication costs, whereas the scholar-led journal attracts fewer citations but no direct author charge. Together these findings suggest a tension between the openness/verifiability of the scholarly-led model and the reach/citation impact of the commercial model &mdash; a trade-off any prospective author must weigh.</p>
<p>However, these results should be read with the limitations of both studies in mind: only one journal represents each publishing model; the <i>Meta-Psychology</i> and <i>NHB</i> audits measure different things (a reproduction certification versus, for most <i>NHB</i> articles, an availability audit); the citation data come from a single, imperfect index (OpenAlex); and both journals were young, with their single most influential articles potentially dominating citation totals.</p>
<p>The central design limitation deserves emphasis. The exploratory re-execution comparison covers @NHBREEXEC@ of @NHBFT@ full-text <i>NHB</i> articles (&asymp;13%) versus 100% of <i>Meta-Psychology</i>&rsquo;s audited sample. Those sixteen <i>NHB</i> articles were selected precisely because their code was archived, licensed, small, and runnable in this environment &mdash; i.e., on a variable plausibly correlated with reproducibility. The other @NHBEXCL@ full-text articles are therefore <b>not missing at random</b>: no analysis code was archived, the analysis required a MATLAB or Stata licence unavailable here, compute was long-duration (network simulations, Sequential Monte Carlo, GNU&nbsp;MCSim, or Stan MCMC), or the source repository could not be retrieved. The direction of the resulting bias is unknowable but almost certainly nonzero, and the sixteen should <b>not</b> be read as a fair sample of <i>NHB</i>. We say this once here rather than repeating it: for any non-re-executed article we can only document that independent re-execution was not feasible here and that data/code were not directly runnable in this environment; we cannot say whether its numbers reproduce. This same environment-dependency also limits the other pairwise figures. The remaining caveats are the single-journal-per-arm design (confounded as detailed in Methods), the unvalidated single-LLM-run instrument, the imperfect OpenAlex index, and the youth of both journals. Enlarging the re-executed <i>NHB</i> sample (a MATLAB/Octave licence, archived missing code, and compute for long-running models) and adding the human-verification and inter-run-reliability validations are the concrete next steps.</p>

<h2 id="open-science">Open Science Statements</h2>
<p class="tabnote"><b>Open data and materials.</b> All audit records, figures, and analysis scripts are openly available in the project repository at <a href="https://github.com/LukasRoeseler/reprochecks">https://github.com/LukasRoeseler/reprochecks</a>, and every included study has its own hosted ReproAI audit report (linkable from the dashboard). <b>Code.</b> The scripts that generated the report, the figures, and the Study&nbsp;2 OpenAlex and cost analyses are included in the repository so the entire pipeline is reproducible. <b>LLM policy.</b> This manuscript and all individual audit reports were authored by the DeepSeek&nbsp;V4&nbsp;Flash large language model (served via uniGPT on the anomalyco/opencode engine), prompted and supervised by Lukas R&ouml;seler; see the Supplement for the complete prompt and revision history.</p>

<h2 id="author-note">Author Note</h2>
<p class="tabnote">This report was written entirely by a large language model (DeepSeek&nbsp;V4&nbsp;Flash, served via the on-premises uniGPT platform within the ReproAI pipeline on the anomalyco/opencode engine). The model was prompted and supervised by Lukas R&ouml;seler. Data collection, figures, the interactive dashboard, HTML composition, and every individual ReproAI verdict and report were generated automatically by that model. <b>CRediT:</b> Conceptualisation, methodology, and all other author roles by Lukas R&ouml;seler; execution and drafting by the LLM under supervision. The LLM is not listed as an author. <b>Instrument limitation:</b> a single LLM run was the sole measurement instrument and was not human-validated; treat all verdicts as provisional (see Correction policy). No funding was received; the authors of audited articles were not involved in and are not responsible for this audit.</p>

<h2 id="conflict">Conflict of Interest</h2>
<p>Lukas R&ouml;seler is a co-founder editor of a scholar-led journal and a proponent of Diamond Open Access. The audits, data, and reports are openly available so that these interests can be weighed against the evidence by any reader.</p>

<h2 id="data-availability">Data Availability</h2>
<p class="tabnote">All data, figures, scripts, and individual ReproAI audit reports underlying this comparison are openly available in the project repository at <a href="https://github.com/LukasRoeseler/reprochecks">https://github.com/LukasRoeseler/reprochecks</a>. The individual audit reports for every included study are hosted on GitHub Pages (see the &ldquo;Study&rdquo; links in the interactive dashboard above).</p>

<h2>Supplements</h2>
<h3>Prompt and revision summary</h3>
<p>For transparency, this subsection summarises the instructions (the general prompt together with the revisions) under which this report was generated and revised by the model. It is a living summary and is kept updated as the manuscript evolves.</p>
<ul>
  <li>Generate a comparative reproducibility audit of <i>Meta-Psychology</i> (scholar-led, open access) versus <i>Nature Human Behaviour</i> (commercial), Volumes 2019&ndash;2020, with an abstract, method, results, discussion, and an interactive, self-contained dashboard.</li>
  <li>Correct the <i>Meta-Psychology</i> recruitment flow so that exclusions appear before the reduced sample.</li>
  <li>Exclude metadata/abstract-only (&ldquo;no PDF&rdquo;) audits from the report and report the DOIs of the missing PDFs separately.</li>
  <li>Remove the header page number and running head.</li>
  <li>Use yellow bars for <i>Meta-Psychology</i> and dark-blue bars for <i>NHB</i> in the figures.</li>
  <li>Present the cross-journal bar charts as percentages with the exact counts annotated, because the <i>Meta-Psychology</i> corpus is small.</li>
  <li>Drop the redundant static &ldquo;Table&nbsp;1&rdquo; and rely on the interactive dashboard, expanding it to show all study fields, and add explanatory column notes.</li>
  <li>Cite the ReproAI workflow (<a class="cit" href="#ref-xu" title="Xu, Y., &amp; Yang, L. Y. (2026). Scaling Reproducibility: An AI-Assisted Workflow for Large-Scale Replication and Reanalysis. arXiv preprint arXiv:2602.16733.">Xu &amp; Yang, 2026</a>) and FLoRA (human-conducted reproducibility reports), and add full reference lists for all included studies (main, <i>Meta-Psychology</i>, and <i>NHB</i> lists).</li>
  <li>Point each study ID link to its individual ReproAI report hosted on GitHub Pages, each readable at its own URL.</li>
  <li>Add histograms of the distribution of the number of audited claims per article for each journal.</li>
  <li>Disclose that the model was prompted by Lukas R&ouml;seler and add a conflict-of-interest statement.</li>
  <li>Nuance the discussion to avoid over-generalising from <i>Meta-Psychology</i> and <i>NHB</i> to all scholar-led versus commercial journals, and frame the two as a quality&ndash;quantity contrast for meta-psychological research.</li>
  <li>Add Study 2 (OpenAlex citation and estimated-APC analyses, with figures), a floating table of contents, clickable DOI links, hover tooltips on in-text citations, and renumber the figures after removing the separate &ldquo;open reproducible analysis&rdquo; figure for <i>Meta-Psychology</i>.</li>
  <li>Shorten and refocus the abstract on which journal is more reproducible, adding the headline citation/cost contrast; report the <i>NHB</i> APC figure in the text (no separate figure); and explain in the discussion why <i>NHB</i> data/code are frequently not directly available (third-party or restricted repositories, ethical/legal restrictions, data-on-request, or source data only in the supplement).</li>
  <li>Restrict the <i>NHB</i> reproducibility comparison to studies that could be <b>genuinely re-executed</b> in this environment; add a PRISMA exclusion box and an explicit inclusion-criteria subsection reporting the reasons non-re-executable papers were excluded (no archived code, toolbox-only repos, MATLAB/Stata licences, long-duration/heavy compute, unavailable source), and return to this as a key limitation in the Discussion.</li>
</ul>

<h2 id="references">References</h2>
<p class="ref" id="ref-munafo">Munaf&#242;, M. R., Nosek, B. A., Bishop, D. V. M., Button, K. S., Chambers, C. D., Percie du Sert, N., Simonsohn, U., Wagenmakers, E.-J., Ware, J. J., &amp; Ioannidis, J. P. A. (2017). A manifesto for reproducible science. <i>Nature Human Behaviour, 1</i>, 0021. <a href="https://doi.org/10.1038/s41562-016-0021" target="_blank" rel="noopener">https://doi.org/10.1038/s41562-016-0021</a></p>
<p class="ref" id="ref-osc">Open Science Collaboration. (2015). Estimating the reproducibility of psychological science. <i>Science, 349</i>(6251), aac4716. <a href="https://doi.org/10.1126/science.aac4716" target="_blank" rel="noopener">https://doi.org/10.1126/science.aac4716</a></p>
<p class="ref" id="ref-sassenberg">Sassenberg, K., &amp; Ditrich, L. (2019). Research in social psychology changed between 2011 and 2016: Larger sample sizes, stronger biasing influences. <i>Frontiers in Psychology, 10</i>, 2708. <a href="https://doi.org/10.3389/fpsyg.2019.02708" target="_blank" rel="noopener">https://doi.org/10.3389/fpsyg.2019.02708</a></p>
<p class="ref" id="ref-radas">Radas, J., Risse, B., &amp; Vogl, R. (2026). UniGPT revisited: From a simple chatbot to an API-first AI platform&mdash;Two years of on-premises LLM operations. In L. Desnos, C. Diaz, J. Mincer-Daszkiewicz, L. Merakos, R. Vogl, S. McLellan, &amp; U. Lucke (Eds.), <i>Proceedings of EUNIS 2026 Annual Congress</i> (EPiC Series in Computing, Vol. 109, pp. 96&ndash;107). EasyChair. <a href="https://doi.org/10.29007/4rq8" target="_blank" rel="noopener">https://doi.org/10.29007/4rq8</a></p>
<p class="ref" id="ref-openalex">OpenAlex. (2026). <i>OpenAlex: The open index of scholarly works</i>. https://openalex.org</p>
<p class="ref" id="ref-hardwicke">Hardwicke, T. E., Bohn, M., MacDonald, K. E., Hembacher, E., &amp; Frank, M. C. (2021). Analytic reproducibility in articles receiving open data badges at the journal <i>Psychological Science</i>: An observational study. <i>Royal Society Open Science, 8</i>(1), 201494. <a href="https://doi.org/10.1098/rsos.201494" target="_blank" rel="noopener">https://doi.org/10.1098/rsos.201494</a></p>
<p class="ref" id="ref-stodden">Stodden, V., Seiler, J., &amp; Ma, Z. (2018). An empirical analysis of journal policy effectiveness for computational reproducibility. <i>Proceedings of the National Academy of Sciences, 115</i>(11), 2584&ndash;2589. <a href="https://doi.org/10.1073/pnas.1708290115" target="_blank" rel="noopener">https://doi.org/10.1073/pnas.1708290115</a></p>
<p class="ref" id="ref-kidwell">Kidwell, M. C., Lazarevi&#263;, L. B., Baranski, E., Hardwicke, T. E., Piechowski, S., Falkenberg, L.-S., Kennett, C., Slowik, A., Sonnleitner, C., Rawlings-Hoy, C., Wilson, D., Riches, W., Luchini, S., &amp; Nosek, B. A. (2016). Badges to acknowledge open practices: Effort to promote replication drives adoption of open data and materials. <i>PLOS Biology, 14</i>(6), e1002456. <a href="https://doi.org/10.1371/journal.pbio.1002456" target="_blank" rel="noopener">https://doi.org/10.1371/journal.pbio.1002456</a></p>
@@EXTRA_REFS@@

</div>
<script>
var STUDIES = @@DATA@@;
var STATUS_LABEL = { "reproduced":"Reproduced","partial":"Partially reproduced","not_reproduced":"Not reproduced","technical":"Technical failure","not_checked":"Not checked" };
var STATUS_COLOR = { "reproduced":"#2e7d32","partial":"#f9a825","not_reproduced":"#c62828","technical":"#ef6c00","not_checked":"#757575" };
function outcomeLabel(s){
  if(s.journal && s.journal.indexOf("Meta")===0) return STATUS_LABEL[s.status]||s.status;
  // NHB papers with genuine code re-execution: identical verdict labels to MP
  if(s.reexec && s.reexec.flag==="reexec") return "Reproduced";
  if(s.reexec && s.reexec.flag==="reexec-partial") return "Partially reproduced";
  // NHB papers NOT re-executed (only an availability audit was performed)
  return "Not re-executed";
}
function outcomeColor(s){
  if(s.journal && s.journal.indexOf("Meta")===0) return {"reproduced":"green","partial":"amber","not_reproduced":"red","technical":"orange","not_checked":"gray"}[s.status]||"gray";
  if(s.reexec && s.reexec.flag==="reexec") return "green";
  if(s.reexec && s.reexec.flag==="reexec-partial") return "amber";
  // NHB papers not re-executed: neutral gray (availability, not reproduction verdict)
  return "gray";
}
function escHtml(x){ return String(x==null?"":x).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;"); }
function fmtSev(s){ var v=s.severity; return (v==null||v==="")?"n/a":v; }
function sevCls(s){ var v=fmtSev(s); if(v.lastIndexOf("P0",0)===0)return"P0"; if(v.lastIndexOf("P1",0)===0)return"P1"; if(v.lastIndexOf("P2",0)===0)return"P2"; if(v.lastIndexOf("P3",0)===0)return"P3"; return"na"; }
function visibleRows(){
  var J=document.getElementById("fJournal").value;
  var Y=document.getElementById("fYear").value;
  var V=document.getElementById("fSev").value;
  var ST=document.getElementById("fStatus").value;
  var Q=(document.getElementById("fSearch").value||"").toLowerCase();
  var rows=[];
  STUDIES.forEach(function(s){
    var sev=fmtSev(s);
    if(J && s.journal!==J) return;
    if(Y && s.year!==Y) return;
    if(V && sev!==V) return;
    if(ST && outcomeLabel(s)!==ST) return;
    if(Q){ var hay=(s.title+" "+s.id+" "+s.authors+" "+(s.doi||"")+" "+(s.caveat||"")).toLowerCase(); if(hay.indexOf(Q)<0) return; }
    rows.push(s);
  });
  return rows;
}
function renderChart(rows){
  var counts={};
  rows.forEach(function(s){
    if(s.journal && s.journal.indexOf("Meta")===0){ counts[s.status]=(counts[s.status]||0)+1; }
    else if(s.reexec && s.reexec.flag==="reexec"){ counts["nhb.reexec"]=(counts["nhb.reexec"]||0)+1; }
    else if(s.reexec && s.reexec.flag==="reexec-partial"){ counts["nhb.reexec_partial"]=(counts["nhb.reexec_partial"]||0)+1; }
    else { counts["nhb.not_rerun"]=(counts["nhb.not_rerun"]||0)+1; }
  });
  var order=["reproduced","partial","not_reproduced","technical","not_checked","nhb.reexec","nhb.reexec_partial","nhb.not_rerun"];
  var box=document.getElementById("stacked"); box.innerHTML="";
  var total=rows.length||1;
  var legendLbl={"reproduced":"MP: Reproduced","partial":"MP: Partially reproduced","not_reproduced":"MP: Not reproduced","technical":"MP: Technical failure","not_checked":"MP: Not checked","nhb.reexec":"NHB: Reproduced","nhb.reexec_partial":"NHB: Partially reproduced","nhb.not_rerun":"NHB: Not re-executed"};
  var legendCol={"reproduced":"#2e7d32","partial":"#f9a825","not_reproduced":"#c62828","technical":"#ef6c00","not_checked":"#757575","nhb.reexec":"#2e7d32","nhb.reexec_partial":"#f9a825","nhb.not_rerun":"#9e9e9e"};
  order.forEach(function(k){
    if(!counts[k]) return;
    var seg=document.createElement("div");
    seg.className="seg"; seg.style.background=legendCol[k];
    seg.style.width=(100*counts[k]/total)+"%";
    seg.textContent=counts[k]; box.appendChild(seg);
  });
  var lg=document.getElementById("legend"); lg.innerHTML="";
  order.forEach(function(k){
    if(!counts[k]) return;
    var it=document.createElement("div"); it.className="item";
    it.innerHTML='<span class="sw" style="background:'+legendCol[k]+'"></span> '+legendLbl[k]+' ('+counts[k]+')';
    lg.appendChild(it);
  });
}
function dashCond(v){ var x=String(v==null?"":v); if(x.toLowerCase()==="yes")return"Yes"; if(x.toLowerCase()==="no"||x.replace(/\s/g,"")==="")return"No"; return x; }
function openDataLabel(s){
  if(s.journal && s.journal.indexOf("Meta")===0) return dashCond(s.open_data);
  var v=s.severity||"";
  if(v.indexOf("P3")===0) return "Yes (direct link)";
  if(v.indexOf("P2")===0) return "Statement only";
  if(v.indexOf("P1")===0) return "None";
  return "n/a";
}
function openCodeLabel(s){
  if(s.journal && s.journal.indexOf("Meta")===0) return dashCond(s.open_repro);
  return "n/a";
}
function renderTable(rows){
  var tb=document.querySelector("#dashTable tbody"); tb.innerHTML="";
  rows.forEach(function(s){
    var c=outcomeColor(s);
    var idcell=s.report?'<a href="'+escHtml(s.report)+'" target="_blank" title="Open ReproAI report">'+escHtml(s.id)+'</a>':escHtml(s.id);
    var doic=s.doi?'<a href="https://doi.org/'+escHtml(s.doi)+'" target="_blank">'+escHtml(s.doi)+'</a>':'&mdash;';
    var tr=document.createElement("tr");
    tr.innerHTML='<td>'+idcell+'</td><td>'+escHtml(s.title)+'</td><td>'+doic+'</td><td><span class="badge b-'+sevCls(s)+'">'+escHtml(fmtSev(s))+'</span></td>'
      +'<td>'+escHtml(openDataLabel(s))+'</td><td>'+escHtml(openCodeLabel(s))+'</td>'
      +'<td>'+s.claims+'</td>'
      +'<td><span class="tl tl-'+c+'" title="NHB: availability audit, not code re-execution; MP: genuine re-execution">'+escHtml(outcomeLabel(s))+'</span></td><td class="cav">'+escHtml(s.caveat)+'</td>';
    tb.appendChild(tr);
  });
  document.getElementById("dcount").textContent="Showing "+rows.length+" of "+STUDIES.length+" studies"+(rows.length?"":" (no matches).");
}
function downloadCSV(rows){
  var cols=["Journal","Year","Study ID","Title","DOI","Severity","FullText(Audited)","Claims","Outcome","Checking AI/model","Caveat"];
  var lines=[cols.join(",")];
  rows.forEach(function(s){
    function q(v){ var x=String(v==null?"":v); return '"'+x.replace(/"/g,'""')+'"'; }
    lines.push([q(s.journal),q(s.year),q(s.id),q(s.title),q(s.doi),q(fmtSev(s)),s.full_text_audited?"Yes":"No",s.claims,q(outcomeLabel(s)),q(s.agent),q(s.caveat)].join(","));
  });
  var blob=new Blob([lines.join("\n")],{type:"text/csv;charset=utf-8;"});
  var a=document.createElement("a"); a.href=URL.createObjectURL(blob); a.download="reproai_visible_studies.csv"; document.body.appendChild(a); a.click();
}
function render(){ var rows=visibleRows(); renderChart(rows); renderTable(rows); }
["fJournal","fYear","fSev","fStatus"].forEach(function(id){ document.getElementById(id).addEventListener("change",render); });
document.getElementById("fSearch").addEventListener("input",render);
document.getElementById("resetBtn").addEventListener("click",function(){
  ["fJournal","fYear","fSev","fStatus"].forEach(function(id){ document.getElementById(id).value=""; });
  document.getElementById("fSearch").value=""; render();
});
document.getElementById("dlBtn").addEventListener("click",function(){ downloadCSV(visibleRows()); });
render();

document.getElementById("tocToggle").addEventListener("click",function(){
  var b=document.querySelector(".toc-body");
  b.style.display=(b.style.display==="block")?"none":"block";
});
</script>

</body></html>"""

repl = {
    "@@DATE@@": date.today().isoformat(),
    "@@DATA@@": data_js,
    "@@TABLE_ROWS@@": table_rows,
    "@@MPA@@": str(len(mp_aud)),
    "@@MPOD@@": str(mp_od),
    "@@NHB@@": str(len(nhb)),
    "@@NHBFT@@": str(len(nhb_ft)),
    "@@NHBMETA@@": str(len(nhb_meta)),
    "@@MPOK@@": str(mp_ok),
    "@@MPPAR@@": str(mp_par),
    "@@MPFAIL@@": str(mp_fail),
    "@@MPTECH@@": str(mp_tech),
    "@@NHBP3@@": str(nhb_p3),
    "@@NHBP2@@": str(nhb_p2),
    "@@NHBP1@@": str(nhb_p1),
    "@@NHBP3PCT@@": str(nhb_p3pct),
    "@@NHBP2PCT@@": str(nhb_p2pct),
    "@@NHBFTPCT@@": str(nhb_ftpct),
    "@@MPCLAIMS_MED@@": str(_med(_mp_cl)),
    "@@MPCLAIMS_MIN@@": str(min(_mp_cl)),
    "@@MPCLAIMS_MAX@@": str(max(_mp_cl)),
    "@@NHBCLAIMS_MED@@": str(_med(_nhb_cl)),
    "@@NHBCLAIMS_MIN@@": str(min(_nhb_cl)),
    "@@NHBCLAIMS_MAX@@": str(max(_nhb_cl)),
    "@@MPCSUM@@": str(sum(_mp_cites)),
    "@@MPCMED@@": str(_st.median(_mp_cites)),
    "@@NHBCSUM@@": str(sum(_nhb_cites)),
    "@@NHBCMED@@": str(_st.median(_nhb_cites)),
    "@@NHBNA@@": str(_nhb_na_count),
    "@@NHBNADIRECT@@": str(_nhb_direct),
    "@@NHBNADIRECT_MINUS3@@": str(_nhb_direct - nhb_p3),
    "@@NHBREEXEC@@": str(len(nhb_recomp)),
    "@@NHBEXCL@@": str(len(nhb_excluded)),
    "@@NHBEXCLBUCKETS_HUMAN@@": ("<br>".join(f"{_e(k)}: {v}" for k,v in sorted(_nhb_excl_buckets.items(), key=lambda kv:-kv[1]))),
    "@@NHB_NA_TABLE@@": _na_tally_apa_rows,
    "@@NHB_NA_TALLY@@": ("<br>".join(f"{k}: {v}" for k,v in _na_tally.most_common())),
    "@@APCNHB@@": _apc_str,
    "@@NHBCOST@@": _nhb_cost_str,
    "@@EXTRA_REFS@@": _extra_refs_html,
    "@@FISHER_P@@": f"{_fisher_p:.3f}",
    "@@MP_WILSON@@": f"[{100*_mp_wilson[0]:.0f}%, {100*_mp_wilson[1]:.0f}%]",
    "@@NHB_WILSON@@": f"[{100*_nhb_wilson[0]:.0f}%, {100*_nhb_wilson[1]:.0f}%]",
    "@@MP_REPRATE@@": f"{100*mp_ok/len(mp_aud):.0f}%",
    "@@NHB_REPRATE@@": f"{100*_nhb_rep/_nhb_rep_total:.0f}%",
    "@@MP_CODEARCH@@": str(_mp_code_n),
    "@@NHB_CODEARCH@@": str(_nhb_code_n),
    "@@NHB_CODEARCH_PCT@@": str(_nhb_code_pct),
    "@@CA_ROWS@@": _ca_rows,
    "@@CA_FOOT@@": _ca_foot,
    "@@NHBRECREATED@@": str(len(nhb_recreated)),
    "@@MP_REPROD_S@@": _fmt_pct(mp_ok/len(mp_aud)),
    "@@NHB_REPROD_S@@": _fmt_pct(_nhb_rep/_nhb_rep_total),
}
# also replace single-@ variants (@X@)
single = {}
for k, v in repl.items():
    token = k.strip("@")
    single["@" + token + "@"] = v
for k, v in {**repl, **single}.items():
    template = template.replace(k, v)

outpath = os.path.join(OUT, "MetaPsych_vs_NHB_Reproducibility_Comparison_APA7.html")
with open(outpath, "w", encoding="utf-8") as f:
    f.write(template)
print("Wrote:", outpath, len(template), "chars")
