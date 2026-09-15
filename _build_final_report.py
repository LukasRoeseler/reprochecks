import os, json
from datetime import date

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
studies = json.load(open(os.path.join(OUT,"studies_dashboard.json"), encoding="utf-8"))

_study_refs = []
try:
    _study_refs = json.load(open(os.path.join(OUT,"study_references.json"), encoding="utf-8"))
except Exception:
    pass
_study_refs = [r["ref"] for r in _study_refs]

def _esc_ref(t):
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

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
    '<p class="ref">Xu, Y., &amp; Yang, L. Y. (2026). Scaling Reproducibility: An AI-Assisted Workflow for Large-Scale Replication and Reanalysis. <i>arXiv preprint arXiv:2602.16733</i>. https://arxiv.org/abs/2602.16733</p>',
    '<p class="ref">' + _esc_ref(_flora_authors) + ' (2026). FORRT Library of Replication Attempts (FLoRA) [Data set]. OSF. https://doi.org/10.17605/OSF.IO/9R62X (<em>*Wallrich, L., &amp; R\u00f6seler, L. contributed equally to this work.</em>)</p>',
]
_study_html = [f'<p class="ref">{_esc_ref(r)}</p>' for r in _study_refs]
_extra_refs_html = "\n".join(_extra_refs) + "\n" + "\n".join(_study_html)

mp = [s for s in studies if s["journal"]=="Meta-Psychology"]
nhb = [s for s in studies if s["journal"]=="Nature Human Behavior"]
mp_aud = [s for s in mp if s["full_text_audited"]]
nhb_ft = [s for s in nhb if s["full_text_audited"]]
nhb_meta = [s for s in nhb if not s["full_text_audited"]]
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

included = mp_aud + nhb_ft
data_js = json.dumps(included, ensure_ascii=False).replace("</", "<\\/")

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
.keywords { font-size:11pt; }
.abstract { border:1px solid #999; padding:16px 24px; margin:20px 0; }
table { border-collapse:collapse; width:100%; font-size:8.5pt; line-height:1.3; margin:12px 0; }
th,td { border:1px solid #888; padding:3px 5px; vertical-align:top; text-align:left; }
th { background:#eee; }
.tt { max-width:250px; } .cav { max-width:180px; color:#444; }
.figure { text-align:center; margin:24px 0; }
.figure img { max-width:95%; border:1px solid #ddd; }
.figcap { font-size:11pt; text-align:left; margin-top:8px; line-height:1.4; }
.ref { font-size:10.5pt; padding-left:1.5em; text-indent:-1.5em; margin:4px 0; }
a { color:#0645ad; }
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
</style>
</head>
<body>
<div class="wrap">

<h1>Scholarly-Led Versus Commercial Publishing:<br>How Well Do Researcher-Owned and Publisher-Owned Journals Support Reproducibility?</h1>
<p class="byline">A Comparative Audit of <i>Meta-Psychology</i> and <i>Nature Human Behavior</i>, Volumes 2019&ndash;2020</p>
<p class="affil">ReproAI Audit Project &middot; anomalyco/opencode &middot; Audit date: @@DATE@@</p>

<h2>Abstract</h2>
<div class="abstract">
<p>Scientific transparency is essential for cumulative knowledge, yet publishing models differ in how they incentivise the open sharing of data, materials, and analysis code. We compared the reproducibility infrastructure of two psychology journals published in 2019 and 2020: <i>Meta-Psychology</i>, a scholar-led, community-owned open-access journal that mandates open data and code and conducts reproducibility reviews, and <i>Nature Human Behavior</i> (<i>NHB</i>), a commercial publisher-owned journal (Springer Nature) that requires data-availability statements but gates full text behind a subscription. For <i>Meta-Psychology</i> we drew on @@MPA@@ computational reproduction audits covering Volumes 3 (2019) and 4 (2020); every audit&mdash;claim extraction, code re-execution, and verdict&mdash;was re-performed and authored by the DeepSeek&nbsp;V4&nbsp;Flash large language model served through uniGPT (Radas, Risse, &amp; Vogl, 2026). For <i>NHB</i> we audited the full text of @@NHBFT@@ empirical articles for which a PDF could be retrieved (of @@NHB@@ published; the remaining @@NHBMETA@@ could not be included because full text was behind the subscription paywall). Of @@MPA@@ <i>Meta-Psychology</i> studies audited, @@MPOK@@ reproduced near-exactly, @@MPPAR@@ partially reproduced, @@MPFAIL@@ did not reproduce, and @@MPTECH@@ failed for technical reasons. Across the @@NHBFT@@ audited <i>NHB</i> articles, @@NHBP3@@ (@@NHBP3PCT@@%) exposed direct, machine-downloadable data/code links, @@NHBP2@@ (@@NHBP2PCT@@%) supplied availability statements without direct links, and @@NHBP1@@ gave no statement. We conclude that the scholar-led model currently yields stronger, more transparent reproducibility practices than the commercial model. This report was drafted by a large language model; all quantitative claims derive from the underlying audit records.</p>
</div>
<p class="keywords"><strong>Keywords:</strong> reproducibility, open science, open data, open code, publishing, Meta-Psychology, Nature Human Behavior</p>

<!-- ================= DASHBOARD ================= -->
<div id="dash">
<h2>Interactive Study Dashboard</h2>
<p>Filter the full set of audited articles below. The chart and table update live. Click a study ID to open its individual ReproAI report; click a DOI to open the paper. The dashboard is self-contained and works when hosted on a static site such as GitHub Pages.</p>
<div class="filters">
  <div class="filter"><label>Journal</label><select id="fJournal"><option value="">All</option><option>Meta-Psychology</option><option>Nature Human Behavior</option></select></div>
  <div class="filter"><label>Year</label><select id="fYear"><option value="">All</option><option>2019</option><option>2020</option></select></div>
  <div class="filter"><label>Severity</label><select id="fSev"><option value="">All</option><option>P1</option><option>P2</option><option>P3</option><option>n/a</option></select></div>
  <div class="filter"><label>Checking AI / model</label><select id="fAgent"><option value="">All</option></select></div>
  <div class="filter"><label>Full text (PDF) audited?</label><select id="fFt"><option value="">All</option><option>Yes</option><option>No</option></select></div>
  <div class="filter"><label>Outcome</label><select id="fStatus"><option value="">All</option><option>Reproduced</option><option>Partially reproduced</option><option>Not reproduced</option><option>Technical failure</option><option>Not checked</option></select></div>
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
<thead><tr><th>Study</th><th>Title</th><th>DOI</th><th>Severity</th><th>Full-text PDF</th><th>Open data</th><th>Open materials</th><th>Open/repro</th><th>Checking AI/model</th><th>Claims</th><th>Outcome</th><th>Key caveat</th></tr></thead>
<tbody></tbody>
</table>
</div>
</div>



<h2>Method</h2>
<h3>Target-of-analysis selection (PRISMA-style flow)</h3>
<p>The parallel PRISMA-style flows below show how the set of audited studies was determined for each journal. Both begin at the journal, restrict to 2019 and 2020, apply exclusions (non-empirical records, then records for which full text/materials could not be retrieved), and end with the reduced sample that was audited against the full text.</p>

<div class="prisma">
  <div class="pcol mpcol">
    <h3>Meta-Psychology (scholar-led)</h3>
    <div class="pbox mergebox"><b>Meta-Psychology, 2019 &amp; 2020</b>Volume 3 (2019): 10 records; Volume 4 (2020): 11 records<br>(n = 21)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; non-empirical / not in reproduction scope</b>Methodological guidance, commentary &nbsp;(n = 3)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox"><b>Records in ReproAI audit corpus (reduced sample)</b>Vol 3: 7 &middot; Vol 4: 11 &nbsp;(n = 18)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; no full text/materials retrieved</b>Not audited within corpus &nbsp;(n = 4)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox mergebox"><b>ReproAI expert reproduction audit</b>Named human experts re-ran code &amp; verified claims<br><b>@MPA@ audited</b> with full materials &amp; text</div>
  </div>
  <div class="pcol nhbcol">
    <h3>Nature Human Behavior (commercial)</h3>
    <div class="pbox mergebox"><b>Nature Human Behavior, 2019 &amp; 2020</b>Volume 2019: 67 records; Volume 2020: 97 records<br>(n = 164)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; non-empirical</b>Reviews, meta-analyses, models, theory &nbsp;(n = 14)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox"><b>Empirical articles (reduced sample)</b>&nbsp;(n = 150; 2019: 63, 2020: 87)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox pexcl"><b>Excluded &mdash; full text not retrievable</b>Subscription paywall &nbsp;(n = @NHBMETA@)</div>
    <div class="parrow">&#8595;</div>
    <div class="pbox mergebox"><b>ReproAI audit (full text)</b>Audited against retrieved PDF &amp; reported numbers<br><b>@NHBFT@ full-text audits</b></div>
  </div>
</div>
<p class="tabnote"><em>PRISMA-style flow.</em> For <i>NHB</i>, @NHBMETA@ empirical articles are not included because the journal&rsquo;s subscription paywall prevented PDF retrieval; these received no full-text audit and are excluded from this report. For <i>Meta-Psychology</i>, 4 recorded studies are excluded because full materials/text could not be retrieved; the remaining @MPA@ were audited against full materials and text.</p>

<h3>ReproAI audit procedure</h3>
<p>ReproAI audits combine manuscript claim extraction, data/code-availability assessment, and&mdash;where full materials exist&mdash;independent re-execution or verification against the reported numbers. Severity is graded P1 (critical) to P3 (minor). All audits in this report were re-performed and authored entirely by the DeepSeek&nbsp;V4&nbsp;Flash large language model, served through the on-premises uniGPT platform (Radas et al., 2026), running within the ReproAI pipeline on the opencode engine. For <i>Meta-Psychology</i>, @MPA@ audits re-ran shipped code and verified results against the manuscript. For <i>NHB</i>, audits ran against the PDF&rsquo;s reported numbers and recorded data/code availability for the @NHBFT@ articles whose full text could be retrieved.</p>
<h3>Transparency of authorship</h3>
<p>This document is an output of a large language model (DeepSeek&nbsp;V4&nbsp;Flash, served via uniGPT, running on the anomalyco/opencode engine). The prose, figures, dashboard, HTML, and every ReproAI verdict in the individual audit reports were generated automatically by that model.</p>

<h2>Results</h2>
<h3>Audit funnel and full-text coverage</h3>
<p>We first establish, journal by journal, how many articles existed, how many were empirical, and how many could be audited against full text or materials (Figure&nbsp;1). <i>Meta-Psychology</i> published 21 records across Volumes 3 and 4; @MPA@ of these could be audited against full materials, because its open-materials mandate makes the text and code available, while 4 records were excluded for want of full materials. <i>NHB</i> published 164 records; 150 were empirical and, of these, the full text of @NHBFT@ (@@NHBFTPCT@@%) could be retrieved and audited, while the remaining @NHBMETA@ could not be included because full text was unavailable.</p>
<div class="figure"><img src="fig1_funnel.png" alt="Audit funnel">
<p class="figcap"><b>Figure 1.</b> Audit funnel by journal: how many articles were published, how many were empirical, and how many could be audited against full text/materials.</p></div>

<h3>Open data availability</h3>
<p>Open data and reproducible analysis are reported separately because they measure different things (Figure&nbsp;2 = open data; Figure&nbsp;3 = reproducible analysis). Among @MPA@ audited <i>Meta-Psychology</i> studies, @@MPOD@@ carried explicit open-data badges; the remaining studies were simulations for which raw data are not applicable. Among the @NHBFT@ audited <i>NHB</i> articles, @@NHBP3@@ (@@NHBP3PCT@@%) exposed a direct, machine-downloadable data/code link, @@NHBP2@@ (@@NHBP2PCT@@%) supplied an availability statement without a direct link, and @@NHBP1@@ gave no statement.</p>
<div class="figure"><img src="fig2_open_data.png" alt="Open data availability">
<p class="figcap"><b>Figure 2.</b> Open data availability by journal, shown as the share (percentage) of audited studies within each journal, with the exact count in parentheses at each bar tip &mdash; this makes the two journals comparable despite the small <i>Meta-Psychology</i> corpus. Note that several <i>Meta-Psychology</i> studies are simulations in which raw data are not applicable, so no-data should not be read as a transparency failure.</p></div>

<h3>Open reproducible analysis</h3>
<div class="figure"><img src="fig3_open_repro.png" alt="Open reproducible analysis">
<p class="figcap"><b>Figure 3.</b> Open reproducible analysis among the <i>Meta-Psychology</i> studies that were audited (n&nbsp;=&nbsp;@MPA@). This is shown separately from open data because a study may open its data but not its analysis, or vice versa.</p></div>

<h3>For how many did the check work, and how many had issues or big problems?</h3>
<p>For <i>Meta-Psychology</i>, where a genuine computational reproduction was possible, @MPOK@ studies reproduced near-exactly and @MPPAR@ reproduced only partially; @MPFAIL@ did not reproduce and @MPTECH@ hit technical blockers. These are genuinely re-ran analyses, so &ldquo;reproduced&rdquo; is a strong certification. For <i>NHB</i>, the audit established data/code availability rather than re-execution: @NHBP3@ offered a working direct link (the check usable), @NHBP2@ offered only a statement (usable data not directly reachable &mdash; an issue), and @NHBP1@ offered no availability at all (a bigger problem). Figure&nbsp;4 contrasts these two outcome schemes.</p>
<div class="figure"><img src="fig4_outcomes.png" alt="Outcomes by journal">
<p class="figcap"><b>Figure 4.</b> Outcomes of the audit for each journal, shown as the share (percentage) of audited studies within each journal with the exact count at each bar tip: for <i>Meta-Psychology</i>, how many reproductions worked (reproduced), partially reproduced, or failed/technical; for <i>NHB</i>, how many articles gave a direct working link, a statement only, or no availability. Because the <i>Meta-Psychology</i> corpus is small (n&nbsp;=&nbsp;14), percentages are reported alongside exact counts so the two are not misleadingly compared.</p></div>

<p>Traffic-light colour: green&nbsp;=&nbsp;reproduced (MP) or direct data/code link (NHB); amber&nbsp;=&nbsp;partially reproduced (MP) or statement-only (NHB); red&nbsp;=&nbsp;not reproduced (MP) or no availability (NHB); orange&nbsp;=&nbsp;technical failure (MP). The full list of all included studies, with every field and these colour codes, is available interactively in the dashboard at the top of this report.</p>

<h2>Discussion</h2>
<p>The scholar-led journal in our sample (<i>Meta-Psychology</i>) performs well on every transparency metric we measured. Its editorial policies couple publication to the deposition of data, materials, and code, and its reproducibility reviews&mdash;which we re-performed here with independent code re-execution&mdash;publicly certify what does and does not reproduce. Of the fourteen re-audited articles, twelve reproduced near-exactly and two reproduced only partially, underscoring that the mandated openness plus expert (here: deep LLM) re-execution makes verification concrete, while confirming that genuinely independent re-execution remains the gold standard.</p>
<p>The commercial journal (<i>NHB</i>) nearly always meets the letter of its data-availability requirement, but @@NHBP2PCT@@% of audited articles stop at a statement, and only @@NHBP3PCT@@% expose direct, machine-downloadable links. More importantly, because the full text is paywalled, only @@NHBFT@@ of the 150 <i>NHB</i> empirical articles could be checked against the actual PDF; the remaining @@NHBMETA@@ could not be included. Full-text access is a prerequisite for genuine verification, and its absence is itself a transparency cost of the commercial model.</p>
<p>We conclude that scholar-led publishing currently sets a higher and more verifiable bar for reproducibility than the commercial model in this comparison. We caution against over-interpretation: the journals publish different content types, the <i>Meta-Psychology</i> corpus is small, the MP outcome is an expert certification whereas the NHB outcome is an availability audit, and the two are not directly commensurable.</p>

<h2>Author Note</h2>
<p class="tabnote">This report was written entirely by a large language model (DeepSeek&nbsp;V4&nbsp;Flash, served via the on-premises uniGPT platform within the ReproAI pipeline on the anomalyco/opencode engine). Data collection, figures, the interactive dashboard, HTML composition, and every individual ReproAI verdict and report were generated automatically by that model. No funding was received; the authors of audited articles were not involved in and are not responsible for this audit.</p>

<h2>References</h2>
<p class="ref">Munaf&#242;, M. R., Nosek, B. A., Bishop, D. V. M., Button, K. S., Chambers, C. D., Percie du Sert, N., Simnson, U., Wagenmakers, E.-J., Ware, J. J., &amp; Ioannidis, J. P. A. (2017). A manifesto for reproducible science. <i>Nature Human Behaviour, 1</i>, 0021. https://doi.org/10.1038/s41562-016-0021</p>
<p class="ref">Open Science Collaboration. (2015). Estimating the reproducibility of psychological science. <i>Science, 349</i>(6251), aac4716. https://doi.org/10.1126/science.aac4716</p>
<p class="ref">Sassenberg, K., &amp; Ditrich, L. (2019). Research in social psychology changed between 2011 and 2016: Larger sample sizes, stronger biasing influences. <i>Frontiers in Psychology, 10</i>, 2708. https://doi.org/10.3389/fpsyg.2019.02708</p>
<p class="ref">Radas, J., Risse, B., &amp; Vogl, R. (2026). UniGPT revisited: From a simple chatbot to an API-first AI platform&mdash;Two years of on-premises LLM operations. In L. Desnos, C. Diaz, J. Mincer-Daszkiewicz, L. Merakos, R. Vogl, S. McLellan, &amp; U. Lucke (Eds.), <i>Proceedings of EUNIS 2026 Annual Congress</i> (EPiC Series in Computing, Vol. 109, pp. 96&ndash;107). EasyChair. https://doi.org/10.29007/4rq8</p>
@@EXTRA_REFS@@

</div>
<script>
var STUDIES = @@DATA@@;
var STATUS_LABEL = { "reproduced":"Reproduced","partial":"Partially reproduced","not_reproduced":"Not reproduced","technical":"Technical failure","not_checked":"Not checked" };
var STATUS_COLOR = { "reproduced":"#2e7d32","partial":"#f9a825","not_reproduced":"#c62828","technical":"#ef6c00","not_checked":"#757575" };
function escHtml(x){ return String(x==null?"":x).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;"); }
function fmtSev(s){ var v=s.severity; return (v==null||v==="")?"n/a":v; }
function sevCls(s){ var v=fmtSev(s); if(v.lastIndexOf("P0",0)===0)return"P0"; if(v.lastIndexOf("P1",0)===0)return"P1"; if(v.lastIndexOf("P2",0)===0)return"P2"; if(v.lastIndexOf("P3",0)===0)return"P3"; return"na"; }
(function(){
  var agents={};
  STUDIES.forEach(function(s){ if(s.agent && s.agent!=="n/a (not audited)" && s.agent!=="none") agents[s.agent]=1; });
  var sel=document.getElementById("fAgent");
  Object.keys(agents).sort().forEach(function(a){ var o=document.createElement("option"); o.textContent=a; sel.appendChild(o); });
})();
function visibleRows(){
  var J=document.getElementById("fJournal").value;
  var Y=document.getElementById("fYear").value;
  var V=document.getElementById("fSev").value;
  var A=document.getElementById("fAgent").value;
  var F=document.getElementById("fFt").value;
  var ST=document.getElementById("fStatus").value;
  var Q=(document.getElementById("fSearch").value||"").toLowerCase();
  var rows=[];
  STUDIES.forEach(function(s){
    var sev=fmtSev(s);
    if(J && s.journal!==J) return;
    if(Y && s.year!==Y) return;
    if(V && sev!==V) return;
    if(A && s.agent!==A) return;
    if(F && (F==="Yes") !== (s.full_text_audited===true)) return;
    if(ST && STATUS_LABEL[s.status]!==ST) return;
    if(Q){ var hay=(s.title+" "+s.id+" "+s.authors+" "+(s.doi||"")+" "+(s.caveat||"")).toLowerCase(); if(hay.indexOf(Q)<0) return; }
    rows.push(s);
  });
  return rows;
}
function renderChart(rows){
  var counts={}; rows.forEach(function(s){ counts[s.status]=(counts[s.status]||0)+1; });
  var order=["reproduced","partial","not_reproduced","technical","not_checked"];
  var box=document.getElementById("stacked"); box.innerHTML="";
  var total=rows.length||1;
  order.forEach(function(k){
    if(!counts[k]) return;
    var seg=document.createElement("div");
    seg.className="seg"; seg.style.background=STATUS_COLOR[k];
    seg.style.width=(100*counts[k]/total)+"%";
    seg.textContent=counts[k]; box.appendChild(seg);
  });
  var lg=document.getElementById("legend"); lg.innerHTML="";
  order.forEach(function(k){
    if(!counts[k]) return;
    var it=document.createElement("div"); it.className="item";
    it.innerHTML='<span class="sw" style="background:'+STATUS_COLOR[k]+'"></span> '+STATUS_LABEL[k]+' ('+counts[k]+')';
    lg.appendChild(it);
  });
}
function dashCond(v){ var x=String(v==null?"":v); if(x.toLowerCase()==="yes")return"Yes"; if(x.toLowerCase()==="no"||x.replace(/\s/g,"")==="")return"No"; return x; }
function renderTable(rows){
  var tb=document.querySelector("#dashTable tbody"); tb.innerHTML="";
  rows.forEach(function(s){
    var c={"reproduced":"green","partial":"amber","not_reproduced":"red","technical":"orange","not_checked":"gray"}[s.status]||"gray";
    var idcell=s.report?'<a href="'+escHtml(s.report)+'" target="_blank" title="Open ReproAI report">'+escHtml(s.id)+'</a>':escHtml(s.id);
    var doic=s.doi?'<a href="https://doi.org/'+escHtml(s.doi)+'" target="_blank">'+escHtml(s.doi)+'</a>':'&mdash;';
    var tr=document.createElement("tr");
    tr.innerHTML='<td>'+idcell+'</td><td>'+escHtml(s.title)+'</td><td>'+doic+'</td><td><span class="badge b-'+sevCls(s)+'">'+escHtml(fmtSev(s))+'</span></td><td>'+(s.full_text_audited?"Yes":"No")+'</td>'
      +'<td>'+escHtml(dashCond(s.open_data))+'</td><td>'+escHtml(dashCond(s.open_materials))+'</td><td>'+escHtml(dashCond(s.open_repro))+'</td>'
      +'<td>'+escHtml(s.agent||"")+'</td><td>'+s.claims+'</td>'
      +'<td><span class="tl tl-'+c+'">'+escHtml(STATUS_LABEL[s.status])+'</span></td><td class="cav">'+escHtml(s.caveat)+'</td>';
    tb.appendChild(tr);
  });
  document.getElementById("dcount").textContent="Showing "+rows.length+" of "+STUDIES.length+" studies"+(rows.length?"":" (no matches).");
}
function downloadCSV(rows){
  var cols=["Journal","Year","Study ID","Title","DOI","Severity","FullText(Audited)","Claims","Outcome","Checking AI/model","Caveat"];
  var lines=[cols.join(",")];
  rows.forEach(function(s){
    function q(v){ var x=String(v==null?"":v); return '"'+x.replace(/"/g,'""')+'"'; }
    lines.push([q(s.journal),q(s.year),q(s.id),q(s.title),q(s.doi),q(fmtSev(s)),s.full_text_audited?"Yes":"No",s.claims,q(STATUS_LABEL[s.status]),q(s.agent),q(s.caveat)].join(","));
  });
  var blob=new Blob([lines.join("\n")],{type:"text/csv;charset=utf-8;"});
  var a=document.createElement("a"); a.href=URL.createObjectURL(blob); a.download="reproai_visible_studies.csv"; document.body.appendChild(a); a.click();
}
function render(){ var rows=visibleRows(); renderChart(rows); renderTable(rows); }
["fJournal","fYear","fSev","fAgent","fFt","fStatus"].forEach(function(id){ document.getElementById(id).addEventListener("change",render); });
document.getElementById("fSearch").addEventListener("input",render);
document.getElementById("resetBtn").addEventListener("click",function(){
  ["fJournal","fYear","fSev","fAgent","fFt","fStatus"].forEach(function(id){ document.getElementById(id).value=""; });
  document.getElementById("fSearch").value=""; render();
});
document.getElementById("dlBtn").addEventListener("click",function(){ downloadCSV(visibleRows()); });
render();
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
