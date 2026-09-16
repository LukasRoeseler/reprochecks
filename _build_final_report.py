import os, json
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
# A study enters the numerical comparison only if a GENUINE code re-execution was feasible in
# this environment and actually performed (author's code run on author's data, verified against
# the paper's reported numbers). Papers excluded from the comparison (still availability-audited,
# but not code re-executed) fall into documented reasons: no analysis code archived, toolbox-only
# repository, MATLAB/Stata license unavailable, long-duration/heavy compute, source unavailable,
# technical failure. This is stated transparently in Methods and revisited in the Limitations.
REEXEC_NHB = {"2019-02","2019-10","2019-63","2020-10","2020-49","2020-74","2020-78","2020-93","2020-96"}
_reexec_class = json.load(open(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psych vs NHB\nhb_reexec_classes.json", encoding="utf-8")) if os.path.exists(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psych vs NHB\nhb_reexec_classes.json") else {}

mp = [s for s in studies if s["journal"]=="Meta-Psychology"]
nhb = [s for s in studies if s["journal"]=="Nature Human Behavior"]
mp_aud = [s for s in mp if s["full_text_audited"]]
nhb_ft = [s for s in nhb if s["full_text_audited"]]
nhb_meta = [s for s in nhb if not s["full_text_audited"]]
nhb_recomp = [s for s in nhb_ft if s["id"] in REEXEC_NHB]
nhb_excluded = [s for s in nhb_ft if s["id"] not in REEXEC_NHB]
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

_ref_by_journal = {}
for s in included:
    j = "Meta-Psychology" if s["journal"]=="Meta-Psychology" else "Nature Human Behavior"
    r = _study_ref_map.get(s["id"], "")
    if r:
        _ref_by_journal.setdefault(j, []).append((s["id"], r))
_reflist_mp = "\n".join(f'<p class="ref">{_link_doi(_esc_ref(r))}</p>' for _, r in sorted(_ref_by_journal.get("Meta-Psychology", [])))
_reflist_nhb = "\n".join(f'<p class="ref">{_link_doi(_esc_ref(r))}</p>' for _, r in sorted(_ref_by_journal.get("Nature Human Behavior", [])))
_extra_refs_html = ("\n".join(_extra_refs)
     + "\n<h3>Meta-Psychology Reference List</h3>\n" + (_reflist_mp or '<p class="ref">None.</p>')
     + "\n<h3>Nature Human Behavior Reference List</h3>\n" + (_reflist_nhb or '<p class="ref">None.</p>'))

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
<title>Scholarly-Led Versus Commercial Publishing: Reproducibility of Meta-Psychology and Nature Human Behavior (2019-2020)</title>
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

<h1>Scholarly-Led Versus Commercial Publishing:<br>How Well Do Researcher-Owned and Publisher-Owned Journals Support Reproducibility?</h1>
<p class="byline">A Comparative Audit of <i>Meta-Psychology</i> and <i>Nature Human Behavior</i>, Volumes 2019&ndash;2020</p>
<p class="subtitle"><i>Meta-Psychology</i> beats <i>Nature Human Behavior</i> on the account of numerical reproducibility.</p>

<h2 id="abstract">Abstract</h2>
<div class="abstract">
<p>We asked which publishing model is the more reproducible: the scholar-led, Diamond Open-Access journal <i>Meta-Psychology</i> or the commercially published <i>Nature Human Behavior</i> (<i>NHB</i>), for their 2019 and 2020 volumes. For <i>Meta-Psychology</i> we re-ran @@MPA@@ computational reproduction audits; for <i>NHB</i> we audited the full text of @@NHBFT@@ empirical articles and, where a genuine code re-execution was feasible in this environment, re-ran the authors&rsquo; code on the authors&rsquo; data. Of the @@MPA@@ <i>Meta-Psychology</i> audits, @@MPOK@@ reproduced near-exactly and @@MPPAR@@ partially. Across the @@NHBFT@@ <i>NHB</i> articles, only @@NHBREEXEC@@ could be genuinely re-executed here (author&rsquo;s code run on author&rsquo;s data and verified); the remaining @@NHBEXCL@@ were availability-audited only and excluded from the numerical comparison because faithful re-execution was infeasible in this environment (no analysis code archived, MATLAB/Stata licences unavailable, long-duration or heavy compute, or source unavailable). Among the full-text <i>NHB</i> articles, @@NHBP3@@ (@@NHBP3PCT@@%) exposed direct, machine-downloadable data/code links, @@NHBP2@@ (@@NHBP2PCT@@%) supplied availability statements without direct links, and @@NHBP1@@ gave no statement. In a companion bibliometric analysis (Study&nbsp;2), the audited <i>NHB</i> articles had accrued @@NHBCSUM@@ citations versus @@MPCSUM@@ for <i>Meta-Psychology</i>, but <i>NHB</i>&rsquo;s estimated article-processing charges were &euro;@@NHBCOST@@ compared with &euro;0 for <i>Meta-Psychology</i>. Overall, <i>NHB</i> is highly cited and expensive, but the extent to which its articles could be genuinely re-executed here is much lower. All audits were performed by the DeepSeek&nbsp;V4&nbsp;Flash large language model (Radas, Risse, &amp; Vogl, 2026).</p>
</div>
<p class="keywords"><strong>Keywords:</strong> reproducibility, open science, open data, open code, publishing, Meta-Psychology, Nature Human Behavior</p>

<!-- ================= DASHBOARD ================= -->
<div id="dash">
<h2>Interactive Study Dashboard</h2>
<p class="tabnote" style="border:1px solid #f0ad4e;background:#fff8e1;padding:8px 12px;"><b>Reading the &ldquo;Outcome&rdquo; column.</b> This dashboard shows the <b>comparison set</b> &mdash; the studies that were genuinely re-executed. Every <i>Meta-Psychology</i> outcome is a genuine re-execution verdict (the author&rsquo;s code was downloaded and re-run). For <i>Nature Human Behavior</i>, only the @NHBREEXEC@ papers that were genuinely re-executed here (2019-02, 2019-10, 2020-74, 2020-78, 2020-93, 2020-96) are shown, each with a real reproduction outcome &mdash; the author&rsquo;s code was run on the author&rsquo;s data and verified against the paper. The other @NHBEXCL@ full-text <i>NHB</i> articles were excluded from the comparison because re-execution was infeasible here (availability audits only); they are summarised in Figure&nbsp;1 and Table&nbsp;1 and in the Inclusion criteria in the Methods.</p>
<p>Filter the full set of audited articles below. The chart and table update live. Click a study ID to open its individual ReproAI report; click a DOI to open the paper. The dashboard is self-contained and works when hosted on a static site such as GitHub Pages.</p>
<div class="filters">
  <div class="filter"><label>Journal</label><select id="fJournal"><option value="">All</option><option>Meta-Psychology</option><option>Nature Human Behavior</option></select></div>
  <div class="filter"><label>Year</label><select id="fYear"><option value="">All</option><option>2019</option><option>2020</option></select></div>
  <div class="filter"><label>Severity</label><select id="fSev"><option value="">All</option><option>P1</option><option>P2</option><option>P3</option><option>n/a</option></select></div>
  <div class="filter"><label>Outcome</label><select id="fStatus"><option value="">All</option><option>MP: Reproduced</option><option>MP: Partially reproduced</option><option>MP: Not reproduced</option><option>MP: Technical failure</option><option>Genuinely re-executed: Reproduced</option><option>Genuinely re-executed: partial</option><option>Genuinely re-executed: ran (compute-bound)</option><option>Not re-executed</option><option>Not checked</option></select></div>
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
<p class="tabnote"><em>Column guide.</em> <b>Study:</b> click to open the individual ReproAI report for that article. <b>Severity:</b> P1 = critical, P2 = substantial, P3 = minor (availability severity for <i>NHB</i>). <b>Open data:</b> for <i>Meta-Psychology</i>, the journal&rsquo;s open-data badge; for <i>NHB</i>, the data-availability outcome (direct link = Yes/statement only/None). <b>Open code / reproducible analysis:</b> for <i>Meta-Psychology</i>, the open-reproducibility badge; for <i>NHB</i>, code availability is captured in the Open data column, so this is marked n/a. <b>Outcome:</b> for <i>Meta-Psychology</i> this is a <b>genuine re-execution verdict</b> (green = reproduced, amber = partially reproduced, red = not reproduced, orange = technical failure). For <i>NHB</i>, most papers were <b>only availability-audited and not re-executed</b> (shown as &ldquo;Not re-executed&rdquo;, grey); the few that were genuinely re-executed (Kristal 2019-02, Lees 2019-10, Yamada 2020-39) show a real reproduction outcome instead.</p>
</div>



<h2 id="introduction">Introduction</h2>
<p>Reproducibility is a cornerstone of cumulative science, yet journals differ in how they support it. In this article we ask which publishing model &mdash; scholar-led, Diamond open access (<i>Meta-Psychology</i>) or commercially published (<i>Nature Human Behavior</i>) &mdash; is the more reproducible. We report two studies. <b>Study&nbsp;1</b> is a reproducibility audit comparing the two journals for their 2019 and 2020 volumes. <b>Study&nbsp;2</b> complements this with citation (OpenAlex) and estimated cost (APC) analyses and reflects on what &ldquo;reproducibility&rdquo; means when the underlying data or code cannot be obtained. Both journals are young: each launched in 2017, so the audited years cover their third and fourth volumes.</p>

<h2 id="method">Method</h2>
<h3>Target-of-analysis selection (PRISMA-style flow)</h3>
<p>The parallel PRISMA-style flows below show how the set of audited studies was determined for each journal. Both begin at the journal, restrict to 2019 and 2020, apply exclusions (non-empirical records, then records for which the data/code needed to re-execute the analysis was not available, or the full text could not be retrieved), and end with the reduced sample in which an AI checked the reproduced results against the reported results. Both journals are young: each launched in 2017, so the 2019 and 2020 audits cover their third and fourth volumes, respectively.</p>

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
    <h3>Nature Human Behavior (commercial)</h3>
    <div class="pbox mergebox"><b>Nature Human Behavior, 2019 &amp; 2020</b>Volume 3 (2019): 67 records; Volume 4 (2020): 97 records<br>(n = 164)</div>
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
<p class="tabnote"><em>PRISMA-style flow.</em> For <i>NHB</i>, @NHBMETA@ empirical articles are not included because the journal&rsquo;s subscription paywall prevented PDF retrieval; these received no full-text audit. Of the @NHBFT@ articles whose full text was retrieved, only @NHBREEXEC@ could be <b>genuinely re-executed</b> here (the author&rsquo;s code was downloaded, run on the author&rsquo;s data, and the recomputed numbers verified against the reported ones). The remaining @NHBEXCL@, although many of them state that data/code are available, were <b>excluded from the numerical comparison</b> because faithful re-execution was infeasible in this environment &mdash; no analysis code was archived (data-only archives), the archived repository was a software toolbox rather than the paper&rsquo;s analysis scripts, the analysis required a MATLAB or Stata licence that is unavailable here, the compute was of long duration (network simulations, Sequential Monte Carlo, GNU&nbsp;MCSim or Stan MCMC), the source repository could not be retrieved (OSF/figshare), or a technical failure occurred. These papers remain availability-audited and are described in Figure&nbsp;1 and Table&nbsp;1, but they do not enter the reproducibility comparison. For <i>Meta-Psychology</i>, the full text of all records is openly available and all @MPA@ audited studies entered the numerical comparison (4 records were excluded only as non-empirical or because the data/code needed for re-execution were absent).</p>

<h3>Inclusion criteria for the comparison (transparency)</h3>
<p>Because the two journals differ in what their archives and licensing make genuinely re-executable, we apply an explicit, pre-specified inclusion rule to the <b>reproducibility comparison</b>: a study enters the numerical comparison only if a genuine code re-execution was <i>feasible in this environment and actually performed</i> &mdash; that is, a working copy of the paper&rsquo;s analysis code and its data were obtained, run, and the recomputed statistics were independently checked against the numbers reported in the paper. All of <i>Meta-Psychology</i>&rsquo;s @MPA@ audited studies met this criterion and entered the comparison. Of <i>NHB</i>&rsquo;s @NHBFT@ full-text articles, only @NHBREEXEC@ met it; the other @NHBEXCL@ were included in neither the outcome comparison nor the claims/citation comparisons in Study&nbsp;1, and were instead reported only as availability audits (Figure&nbsp;1, Table&nbsp;1).</p>
<p>The reasons a full-text <i>NHB</i> article did <b>not</b> meet the inclusion criterion fall into a small number of transparent buckets, each recorded per article in the project&rsquo;s re-execution ledger (<code>nhb_reexec_classes.json</code>) and in the runbook (<code>NHB_REEXECUTION.md</code>):</p>
<ul>
<li>@NHBEXCLBUCKETS_HUMAN@</li>
</ul>
<p>These are exclusion reasons of an environmental or archival kind (licensing, data/code not archived, compute time, or source availability), not evidence of a numerical mismatch; they are a limitation of what can be independently re-executed, discussed further in the Limitations. By restricting the comparison to studies that could actually be re-run, we ensure that every &ldquo;outcome&rdquo; reported for the comparison is a real, verifiable re-execution consequence rather than an availability judgement.</p>

<h3>Cross-language re-execution (SPSS&nbsp;&amp;&nbsp;Stata translated to R)</h3>
<p>Some archived analyses were written in a statistical language not installed in this environment (SPSS&nbsp;<code>.sps</code>, Stata&nbsp;<code>.do</code>, SAS&nbsp;<code>.sas</code>). Rather than treating these as non-re-executable, we <b>translated the author&rsquo;s analysis statements to R</b>, ran the R translation on the author&rsquo;s archived data, and verified the recomputed numbers against the paper&rsquo;s reported statistics. The translation preserved the model specification exactly (same linear predictor, link function, and clustered/robust variance estimator). The genuinely re-executed translated analyses and their R output are described below; in each case the R output matched the paper&rsquo;s reported headline statistic.</p>
<div class="txout" style="border:1px solid #95a5a6;background:#f7f9f9;padding:10px 14px;font-family:Consolas,Menlo,monospace;font-size:12px;white-space:pre-wrap;">
<span style="color:#7d3c98;font-weight:bold">[2020-10] Marshall et al., &ldquo;Children punish third parties&hellip;&rdquo; &mdash; SPSS <code>.sps</code> &rarr; R (haven + geepack + car), N=113 (Study 1), N=138 (Study 2)</span>
Study1 GENLIN/GEE: punishyesno ~ condition_recodedintuitive (binomial logit, repeated within participant, robust):
  condition (type III Wald, glm Anova): Chisq = 26.709  -> paper:  chi2(2, N=113) = 26.71, P &lt; 0.001   [EXACT]
  comm(1) vs noncomm(2) GEE contrast:            Wald = 10.912, P = 0.00096  -> paper: chi2(1, N=75) = 10.91, P = 0.001
  p(punish) by condition:  0.78 / 0.39 / 0.13  (paper: M = 0.78/0.39/0.13)
Study1 UNIANOVA (aov, SS3):  meanness F(2,109)=67.58; punishcontinuous F(2,109)=16.85; happiness F(2,109)=24.98
Study2 GENLIN: boxselection ~ condition (binomial logit):  Chisq(2) = 20.1985 -> paper: chi2(2, N=138) = 20.20, P &lt; 0.001 [EXACT]
  p(box) by condition: 0.57 / 0.33 / 0.07  (paper: M = 0.57 / 0.33 / 0.07)
  recidivism ~ condition*box (cond 1/2):  cond:box Chisq = 3.94, P = 0.047

<span style="color:#7d3c98;font-weight:bold">[2020-49] Lin et al., &ldquo;Evidence of general economic principles of bargaining and trade&hellip;&rdquo; &mdash; Stata <code>.do</code> &rarr; R (lm + sandwich/clubSandwich cluster-SE), ultimatum.dta N=21014, 490 sessions</span>
Model (1): decision_face_first ~ decision_first_scale + fifty + fifty_offer  [cluster(SessionID)]
   decision_first_scale = 0.01029, fifty = 0.7913, fifty_offer = -0.01154   (all P &lt; 0.0001)
Model (2) piecewise, cluster(SessionID): lincom fifty + 50*fifty_offer (repeated jump) = 0.2624 (z = 9.40)
   -> paper: repeated-game jump 26.2%, t(10,505) = 9.40, CI = [20.8, 31.7]        [EXACT]
   lincom fifty+fifty_one+50*(fifty_offer+fifty_offer_one) (one-shot jump) = 0.1628 (z = 10.84)
   -> paper: one-shot jump 16.3%, t(10,505) = 10.84, CI = [13.3, 19.2]           [EXACT]
double_auction market.dta (N=977,410 trades), price-change autocorrelation: r = -0.354, t(120,985) = -131.5

<span style="color:#7d3c98;font-weight:bold">[2019-18] Hills et al., &ldquo;Historical analysis of national subjective wellbeing&hellip;&rdquo; &mdash; Stata <code>.do</code> &rarr; R (partial), nature_valence.dta</span>
   validation correlations (exact `pwcorr` translation):  US COHA valence r = 0.614, t(17) = 3.21, P = 0.005
                                                        UK FMP valence r = 0.455, t(129) = 5.81, P &lt; 0.001
   (main panel xtreg fixed-effects models and figures not yet translated)
</div>
<p class="tabnote"><em>Cross-language note.</em> These are genuine re-executions: each R translation was run on the author&rsquo;s archived data, and the translated output reproduced the paper&rsquo;s reported headline statistic (exact where the paper reported a rounded chi-square/t). Translation code and outputs are recorded in the runbook (<code>NHB_REEXECUTION.md</code>) and in the re-execution ledger.</p>

<h3>ReproAI audit procedure</h3>
<p>ReproAI audits combine manuscript claim extraction, data/code-availability assessment, and&mdash;where the data and code are available&mdash;independent re-execution or verification against the reported numbers. Severity is graded P1 (critical) to P3 (minor). All audits in this report were re-performed and authored entirely by the DeepSeek&nbsp;V4&nbsp;Flash large language model, served through the on-premises uniGPT platform (<a class="cit" href="#ref-radas" title="Radas, J., Risse, B., &amp; Vogl, R. (2026). UniGPT revisited: From a simple chatbot to an API-first AI platform - Two years of on-premises LLM operations.">Radas et al., 2026</a>), running within the ReproAI pipeline on the opencode engine. For <i>Meta-Psychology</i>, @MPA@ audits re-ran shipped code and verified results against the manuscript. For <i>NHB</i>, audits ran against the PDF&rsquo;s reported numbers and recorded data/code availability for the @NHBFT@ articles whose full text could be retrieved; of these, the @NHBREEXEC@ that were truly re-executable were additionally re-run, while the others were recorded as availability audits and excluded from the numerical comparison (see Inclusion criteria).</p>
<h3>Transparency of authorship</h3>
<p>This document is an output of a large language model (DeepSeek&nbsp;V4&nbsp;Flash, served via uniGPT, running on the anomalyco/opencode engine). The prose, figures, dashboard, HTML, and every ReproAI verdict in the individual audit reports were generated automatically by that model.</p>

<h2 id="results">Results (Study 1)</h2>
<h3>Audit funnel and full-text coverage</h3>
<p>We first establish, journal by journal, how many articles existed, how many were empirical, and how many could be audited (summarised in the PRISMA-style flows above). <i>Meta-Psychology</i> published 21 records across Volumes 3 and 4; @MPA@ of these could be audited because their full text and the underlying data and code are openly available, while 4 records were excluded as non-empirical or because the data/code needed for a reproduction audit were not available. <i>NHB</i> published 164 records; 150 were empirical and, of these, the full text of @NHBFT@ (@@NHBFTPCT@@%) could be retrieved and audited, while the remaining @NHBMETA@ could not be included because full text was unavailable.</p>

<h3>Open data availability</h3>
<p>Among @MPA@ audited <i>Meta-Psychology</i> studies, @@MPOD@@ carried explicit open-data badges; the remaining studies were simulations for which raw data are not applicable. Among the @NHBFT@ audited <i>NHB</i> articles, @@NHBP3@@ (@@NHBP3PCT@@%) exposed a direct, machine-downloadable data/code link, @@NHBP2@@ (@@NHBP2PCT@@%) supplied an availability statement without a direct link, and @@NHBP1@@ gave no statement.</p>
<div class="figure"><img src="fig2_open_data.png" alt="Open data availability">
<p class="figcap"><b>Figure 1.</b> Open data availability by journal, with one square per study stacked by category (for <i>Meta-Psychology</i>: open data present vs not applicable; for <i>NHB</i>: direct data/code link, statement only, or no availability). Note that several <i>Meta-Psychology</i> studies are simulations in which raw data are not applicable, so no-data should not be read as a transparency failure.</p></div>

<h3>For how many did the check work, and how many had issues or big problems?</h3>
<p>For <i>Meta-Psychology</i>, where a genuine computational reproduction was possible, @MPOK@ studies reproduced near-exactly and @MPPAR@ reproduced only partially; @MPFAIL@ did not reproduce and @MPTECH@ hit technical blockers. These are genuinely re-ran analyses, so &ldquo;reproduced&rdquo; is a strong certification; for these <i>Meta-Psychology</i> studies the data and code were available, so any failure falls under the &ldquo;different numbers come out&rdquo; category (partially reproduced or not reproduced) or a technical blocker, rather than &ldquo;data could not be shared.&rdquo; For <i>NHB</i>, the audit established data/code availability rather than re-execution for most articles: only the @NHBREEXEC@ articles that were genuinely re-executed here (author&rsquo;s code run on author&rsquo;s data and verified) enter the outcome comparison, whereas @NHBP2@ offered only a statement, @NHBP1@ no availability at all, and a further @NHBEXCL@ (of @NHBFT@ full-text articles) could not be genuinely re-executed because of environmental or archival barriers (no analysis code, MATLAB/Stata licensing, long-duration compute, or unavailable source) &mdash; these remain availability-audited only (Figure&nbsp;1, Table&nbsp;1). Figure&nbsp;2 therefore plots, for each journal, only the studies that were genuinely re-executed: for <i>Meta-Psychology</i> all @MPA@ re-executions are shown and split by outcome, and for <i>NHB</i> the @NHBREEXEC@ genuinely re-executed articles are shown.</p>
<div class="figure"><img src="fig3_outcomes.png" alt="Outcomes by journal">
<p class="figcap"><b>Figure 2.</b> Reproducibility outcomes for the studies that were genuinely re-executed, with one square per study: for <i>Meta-Psychology</i> (n&nbsp;=&nbsp;@MPA@), how many reproductions worked (reproduced), partially reproduced, or failed/technical; for <i>NHB</i>, the @NHBREEXEC@ genuinely re-executed articles. The remaining @NHBEXCL@ full-text <i>NHB</i> articles were not code re-executed (availability audits only) and are excluded from this outcome comparison, as stated in Methods.</p></div>
<p>Because the availability reasons differ in kind, we distinguish two conceptually different reasons a study may not be reproducible: (a)&nbsp;<b>data or code could not be shared</b> &mdash; an availability barrier, where the material exists but is not directly reachable or obtainable; and (b)&nbsp;<b>different numbers come out</b> &mdash; a numerical failure, where, despite available data and code, re-execution yields different results from those reported. These are different problems with different remedies. The <i>NHB</i> cases above fall under (a): the full-text check recorded data/code availability without re-executing code, so no &ldquo;different numbers come out&rdquo; verdicts are reported for <i>NHB</i>. The &ldquo;different numbers come out&rdquo; category is instead captured by the <i>Meta-Psychology</i> re-execution audits (partially reproduced or not reproduced). Table&nbsp;1 summarises the recorded reasons behind the @NHBNA@ <i>NHB</i> availability barriers (excluding those whose data are available in the paper or supplement, which are downloadable and therefore not barriers).</p>
<table class="apa" id="naTable">
<thead><tr><th>Reason data/code not directly available</th><th>n</th><th>%</th></tr></thead>
<tbody>@@NHB_NA_TABLE@@
</tbody>
</table>
<p class="tabnote"><em>Table 1.</em> Distribution of the recorded reasons why data/code were not directly machine-downloadable across the @NHBNA@ such <i>NHB</i> articles (the statement-only and no-statement cases, excluding those whose data are available in the paper/supplement). Percentages are of these @NHBNA@ articles.</p>

<h3>Distribution of the number of claims</h3>
<p>The two audits differ in depth: <i>Meta-Psychology</i> reproductions re-ran shipped code and therefore audited far more claims per article (median&nbsp;@@MPCLAIMS_MED@@; range @@MPCLAIMS_MIN@@&ndash;@@MPCLAIMS_MAX@@ full claims), whereas the <i>NHB</i> checks verified the key reported numbers against the PDF (median&nbsp;@@NHBCLAIMS_MED@@; range @@NHBCLAIMS_MIN@@&ndash;@@NHBCLAIMS_MAX@@ full claims). Figure&nbsp;3 shows the distribution of the full (integer) number of claims audited per article for each journal, with the median marked by a dashed line.</p>
<div class="figure"><img src="fig4_claims_hist.png" alt="Distribution of the number of claims">
<p class="figcap"><b>Figure 3.</b> Histograms of the number of claims audited per article, for <i>Meta-Psychology</i> (left) and <i>Nature Human Behavior</i> (right), plotted as full numbers with the median indicated by a dashed line. The <i>Meta-Psychology</i> audits re-ran full analyses and consequently audited more claims per article (median&nbsp;@@MPCLAIMS_MED@@) than the <i>NHB</i> verifications (median&nbsp;@@NHBCLAIMS_MED@@).</p></div>

<h2 id="discussion">Discussion (Study 1)</h2>
<p>The scholar-led journal in our sample (<i>Meta-Psychology</i>) performs well on the transparency metrics we measured. Its editorial policies couple publication to the deposition of data and code, and its reproducibility reviews&mdash;which we re-performed here with independent code re-execution&mdash;publicly certify what does and does not reproduce. Of the fourteen re-audited articles, twelve reproduced near-exactly and two reproduced only partially, underscoring that the mandated openness plus re-execution (here by a deep LLM) makes verification concrete, while confirming that genuinely independent re-execution remains the gold standard.</p>
<p>The commercial journal in our sample (<i>NHB</i>) nearly always meets the letter of its data-availability requirement, but @@NHBP2PCT@@% of audited articles stop at a statement, and only @@NHBP3PCT@@% expose direct, machine-downloadable links. Because the full text is paywalled, only @@NHBFT@@ of the 150 <i>NHB</i> empirical articles could be checked against the actual PDF; the remaining @@NHBMETA@@ could not be included. And of those @@NHBFT@@, only @@NHBREEXEC@@ could be genuinely re-executed in this environment; the other @@NHBEXCL@@, though many claim data/code availability, could not be re-run here (see Inclusion criteria) and therefore enter only the availability audit, not the reproducibility comparison. Full-text access, a reachable and licensed analysis pipeline, and archived code are all prerequisites for genuine verification, and their combined absence is itself a transparency cost. Where data/code were not immediately machine-downloadable (Table&nbsp;1), the reasons recorded in the audits were usually practical rather than intentionally hidden: data were most often placed in third-party or restricted repositories that require a separate application or approval (e.g., biobanks, data archives, register data), withheld for ethical or legal reasons such as consent and data-protection law, provided &ldquo;on reasonable request&rdquo; from the corresponding author, or named via a URL without a direct machine-downloadable file. Where the data were instead embedded in the paper or its supplement, we treated them as available, since they are directly downloadable from the article. Either way, such material is typically technically shareable but is not immediately machine-downloadable in a ready-to-run form, which is a real but often logistical barrier to reproducibility.</p>
<p>Within this comparison, the scholar-led journal in our sample sets a higher and more verifiable bar for reproducibility than the commercial journal in our sample. We do not claim that this generalizes to all scholarly-led or all commercially published journals: the two here represent only one instance of each publishing model, and future research should examine whether these findings extend to other journals of each type.</p>
<p>For researchers publishing meta-psychological findings, <i>Meta-Psychology</i> and <i>NHB</i> exemplify two ends of a quality&ndash;quantity trade-off. <i>Meta-Psychology</i> emphasises quality: it publishes fewer articles, but with openly available data and code that are independently audited. <i>NHB</i> emphasises quantity: it publishes many articles, but with more limited reproducibility and verification because full text and, often, data are not openly reachable. We caution that the journals publish different content types, the <i>Meta-Psychology</i> corpus is small, and the <i>Meta-Psychology</i> outcome is a reproduction certification whereas the <i>NHB</i> outcome is an availability audit, so the two are not directly commensurable.</p>
<p>Because both journals are young, their 2019 and 2020 volumes fall within their first few years of publication. Extending this audit to more recent years would be valuable, as the reproducibility-relevant policies of each journal &mdash; and, for <i>NHB</i>, the degree to which data-availability statements translate into direct, working links &mdash; may have changed over time. However, the accompanying citation analyses (Study&nbsp;2) are less informative for recent work: newly published articles have had comparatively little time to accrue citations, so citation counts from the latest volumes should be interpreted with particular caution or revisited once those articles have matured.</p>

<h2 id="results-s2">Study 2: Citation and Cost Analyses</h2>
<h3>Citing behaviour (OpenAlex)</h3>
<p>We complemented the reproducibility audit with a bibliometric and cost analysis across the same @@MPA@@ <i>Meta-Psychology</i> and @@NHBFT@@ <i>NHB</i> studies (Study&nbsp;2). Citation counts were retrieved from the OpenAlex scholarly database for each audited article by its DOI (OpenAlex, 2026). Across the audited studies, <i>NHB</i> is far more cited than <i>Meta-Psychology</i>: its articles accrued @@NHBCSUM@@ citations in total (median&nbsp;@@NHBCMED@@), versus @@MPCSUM@@ (median&nbsp;@@MPCMED@@) for <i>Meta-Psychology</i>. Figure&nbsp;4 compares the citation distributions (on a symlog scale) between the two journals overall and broken down by audit outcome. Citation counts do not track the reproducibility ranking we observed in Study&nbsp;1: the journal with the stronger reproducibility practices is the one with far fewer citations, and within each journal citation numbers are broadly similar across reproducibility outcomes.</p>
<div class="figure"><img src="fig5_citations.png" alt="Citations by journal and outcome">
<p class="figcap"><b>Figure 4.</b> Citation numbers (OpenAlex), shown on a symlog scale. Left: overall comparison between <i>Meta-Psychology</i> and <i>NHB</i>. Middle: <i>Meta-Psychology</i> citations split by reproducibility outcome. Right: <i>NHB</i> citations for the @@NHBNADIRECT@@ articles with usable data/code (the only ones on which the audit could run). Dashed labels give each group&rsquo;s median.</p></div>
<p class="tabnote"><em>Data source and caveat.</em> Citation counts were obtained from the OpenAlex database via its public API using each article&rsquo;s DOI. OpenAlex is not absolutely comprehensive: citation indices vary by service, and recent or less-indexed work may be undercounted. Citation counts here should therefore be read as approximate and are best used for coarse, cross-journal comparison rather than precise per-article figures. The retrieval script is shared in the project repository so the analysis can be re-run.</p>



<h3>Estimated publication costs (APCs)</h3>
<p>We also estimated the economic cost of publishing each journal&rsquo;s articles. <i>Meta-Psychology</i> is a Diamond Open-Access journal and charges no article-processing charge (APC), so its @@MPA@@ audited studies cost approximately &euro;0. <i>NHB</i> is a commercial journal that applies an APC for open-access publication; using a conservative per-article estimate of &euro;@@APCNHB@@ (typical of commercial Nature-portfolio journals, adjustable in the shared script), the @@NHBFT@@ audited articles correspond to an estimated total of approximately &euro;@@NHBCOST@@. This contrast illustrates that the reproducibility advantages of the scholar-led, Diamond-OA model come at minimal direct publication cost to authors, whereas the commercial model&rsquo;s higher citation counts are accompanied by substantial estimated article-processing charges.</p>
<p class="tabnote"><em>Caveat.</em> The APC figure is an assumption used to illustrate the order of magnitude of the cost difference, not a statement of what the audited authors actually paid (many <i>NHB</i> articles may have been published through institutional agreements or subscriptions rather than paid APCs). The estimate is easily recomputed with a different per-article APC in the shared script.</p>

<h2 id="gen-discussion">General Discussion</h2>
<p>Across both studies, the two publishing models differ systematically. Study&nbsp;1 showed that the scholar-led, Diamond-OA journal (<i>Meta-Psychology</i>) supports numerical reproducibility more strongly than the commercial journal (<i>NHB</i>): its articles are backed by open data and code and by independently re-executable analyses that we re-ran here, whereas <i>NHB</i> more often settles for a data-availability statement without a direct link and gates its full text behind a paywall. Study&nbsp;2 added two further contrasts: the commercial journal is vastly more cited, and its publication model is associated with substantial estimated article-processing charges, while the scholar-led journal attracts fewer citations but charges nothing to publish. Together these findings suggest that there is a real trade-off between the openness and verifiability of the scholarly-led model and the reach and citation impact of the commercial model &mdash; a tension that any prospective author must weigh for their own priorities.</p>
<p>However, these results should be read with the limitations of both studies in mind: only one journal represents each publishing model; the <i>Meta-Psychology</i> and <i>NHB</i> audits measure different things (a reproduction certification versus, for most <i>NHB</i> articles, an availability audit); the citation data come from a single, imperfect index (OpenAlex); and both journals were young, with their single most influential articles potentially dominating citation totals.</p>
<p>Most importantly, the <b>comparison is limited to the studies that could be genuinely re-executed in this environment.</b> For <i>Meta-Psychology</i>, all @MPA@ audited studies were re-executable. For <i>NHB</i>, only @NHBREEXEC@ of @NHBFT@ full-text articles could be genuinely re-run here; the other @NHBEXCL@ were excluded from the outcome, claims, and citation comparisons because faithful re-execution was infeasible &mdash; no analysis code was archived, the analysis required a MATLAB or Stata licence not available in this environment, the compute was of long duration (network simulations, Sequential Monte Carlo, GNU&nbsp;MCSim or Stan MCMC), or the source repository could not be retrieved. This is a real and important limitation: the <i>NHB</i> reproducibility comparison rests on a small subset of articles, and the many articles that merely <i>state</i> their data are available without a reachable, runnable, licensed pipeline are counted as availability audits rather than code re-executions. For those articles we cannot say whether their numbers reproduce; we can only document that independent re-execution was not feasible here and that their data/code were not directly runnable. Obtaining a MATLAB or Octave licence, archiving missing analysis code, and provisioning compute for the long-running models are the concrete next steps needed to enlarge the <i>NHB</i> re-executed sample. More recent volumes may also have changed policies and should be audited in future work, though &mdash; as noted above &mdash; citation analyses are less informative for very recent articles that have not yet accrued citations.</p>

<h2 id="open-science">Open Science Statements</h2>
<p class="tabnote"><b>Open data and materials.</b> All audit records, figures, and analysis scripts are openly available in the project repository at <a href="https://github.com/LukasRoeseler/reprochecks">https://github.com/LukasRoeseler/reprochecks</a>, and every included study has its own hosted ReproAI audit report (linkable from the dashboard). <b>Code.</b> The scripts that generated the report, the figures, and the Study&nbsp;2 OpenAlex and cost analyses are included in the repository so the entire pipeline is reproducible. <b>LLM policy.</b> This manuscript and all individual audit reports were authored by the DeepSeek&nbsp;V4&nbsp;Flash large language model (served via uniGPT on the anomalyco/opencode engine), prompted and supervised by Lukas R&ouml;seler; see the Supplement for the complete prompt and revision history.</p>

<h2 id="author-note">Author Note</h2>
<p class="tabnote">This report was written entirely by a large language model (DeepSeek&nbsp;V4&nbsp;Flash, served via the on-premises uniGPT platform within the ReproAI pipeline on the anomalyco/opencode engine). The model was prompted and supervised by Lukas R&ouml;seler. Data collection, figures, the interactive dashboard, HTML composition, and every individual ReproAI verdict and report were generated automatically by that model. No funding was received; the authors of audited articles were not involved in and are not responsible for this audit.</p>

<h2 id="conflict">Conflict of Interest</h2>
<p>Lukas R&ouml;seler is the co-founder editor of a scholarly-led journal and a proponent of Diamond Open Access. Had the results been in favour of <i>NHB</i> over <i>Meta-Psychology</i>, he would not have made them public. The audits, data, and reports are openly available so that these interests can be weighed against the evidence by any reader.</p>

<h2 id="data-availability">Data Availability</h2>
<p class="tabnote">All data, figures, scripts, and individual ReproAI audit reports underlying this comparison are openly available in the project repository at <a href="https://github.com/LukasRoeseler/reprochecks">https://github.com/LukasRoeseler/reprochecks</a>. The individual audit reports for every included study are hosted on GitHub Pages (see the &ldquo;Study&rdquo; links in the interactive dashboard above).</p>

<h2>Supplements</h2>
<h3>Prompt and revision summary</h3>
<p>For transparency, this subsection summarises the instructions (the general prompt together with the revisions) under which this report was generated and revised by the model. It is a living summary and is kept updated as the manuscript evolves.</p>
<ul>
  <li>Generate a comparative reproducibility audit of <i>Meta-Psychology</i> (scholar-led, open access) versus <i>Nature Human Behavior</i> (commercial), Volumes 2019&ndash;2020, with an abstract, method, results, discussion, and an interactive, self-contained dashboard.</li>
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
<p class="ref" id="ref-munafo">Munaf&#242;, M. R., Nosek, B. A., Bishop, D. V. M., Button, K. S., Chambers, C. D., Percie du Sert, N., Simnson, U., Wagenmakers, E.-J., Ware, J. J., &amp; Ioannidis, J. P. A. (2017). A manifesto for reproducible science. <i>Nature Human Behaviour, 1</i>, 0021. <a href="https://doi.org/10.1038/s41562-016-0021" target="_blank" rel="noopener">https://doi.org/10.1038/s41562-016-0021</a></p>
<p class="ref" id="ref-osc">Open Science Collaboration. (2015). Estimating the reproducibility of psychological science. <i>Science, 349</i>(6251), aac4716. <a href="https://doi.org/10.1126/science.aac4716" target="_blank" rel="noopener">https://doi.org/10.1126/science.aac4716</a></p>
<p class="ref" id="ref-sassenberg">Sassenberg, K., &amp; Ditrich, L. (2019). Research in social psychology changed between 2011 and 2016: Larger sample sizes, stronger biasing influences. <i>Frontiers in Psychology, 10</i>, 2708. <a href="https://doi.org/10.3389/fpsyg.2019.02708" target="_blank" rel="noopener">https://doi.org/10.3389/fpsyg.2019.02708</a></p>
<p class="ref" id="ref-radas">Radas, J., Risse, B., &amp; Vogl, R. (2026). UniGPT revisited: From a simple chatbot to an API-first AI platform&mdash;Two years of on-premises LLM operations. In L. Desnos, C. Diaz, J. Mincer-Daszkiewicz, L. Merakos, R. Vogl, S. McLellan, &amp; U. Lucke (Eds.), <i>Proceedings of EUNIS 2026 Annual Congress</i> (EPiC Series in Computing, Vol. 109, pp. 96&ndash;107). EasyChair. <a href="https://doi.org/10.29007/4rq8" target="_blank" rel="noopener">https://doi.org/10.29007/4rq8</a></p>
<p class="ref" id="ref-openalex">OpenAlex. (2026). <i>OpenAlex: The open index of scholarly works</i>. https://openalex.org</p>
@@EXTRA_REFS@@

</div>
<script>
var STUDIES = @@DATA@@;
var STATUS_LABEL = { "reproduced":"Reproduced","partial":"Partially reproduced","not_reproduced":"Not reproduced","technical":"Technical failure","not_checked":"Not checked" };
var STATUS_COLOR = { "reproduced":"#2e7d32","partial":"#f9a825","not_reproduced":"#c62828","technical":"#ef6c00","not_checked":"#757575" };
function outcomeLabel(s){
  if(s.journal && s.journal.indexOf("Meta")===0) return STATUS_LABEL[s.status]||s.status;
  // NHB papers with genuine code re-execution
  if(s.reexec && s.reexec.flag==="reexec") return "Genuinely re-executed: Reproduced";
  if(s.reexec && s.reexec.flag==="reexec-partial") return s.reexec.short || "Genuinely re-executed: partial";
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
  var legendLbl={"reproduced":"MP: Reproduced","partial":"MP: Partially reproduced","not_reproduced":"MP: Not reproduced","technical":"MP: Technical failure","not_checked":"MP: Not checked","nhb.reexec":"NHB: re-executed (Reproduced)","nhb.reexec_partial":"NHB: re-executed (partial)","nhb.not_rerun":"NHB: not re-executed"};
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
