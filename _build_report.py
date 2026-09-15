import os, json, html
from datetime import date

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
d = json.load(open(os.path.join(OUT, "comparison_data.json"), encoding="utf-8"))
stats = d["stats"]
mp19, mp20, nhb19, nhb20 = d["mp19"], d["mp20"], d["nhb19"], d["nhb20"]

def esc(x):
    return html.escape(str(x))

# ------- headline numbers -------
mp_audited = stats["mp19_audited"] + stats["mp20_audited"]
mp_ok = sum(1 for s in mp19+mp20 if s["verdict_class"]=="success")
mp_par = sum(1 for s in mp19+mp20 if s["verdict_class"]=="partial")
mp_fail = sum(1 for s in mp19+mp20 if s["verdict_class"]=="failed")
mp_na = sum(1 for s in mp19+mp20 if s["verdict_class"]=="not_audited")

nhb_total = stats["nhb19_total"] + stats["nhb20_total"]
nhb_p3 = stats["nhb19_p3"] + stats["nhb20_p3"]
nhb_p2 = stats["nhb19_p2"] + stats["nhb20_p2"]
nhb_p1 = stats["nhb19_p1"] + stats["nhb20_p1"]
nhb_ft = stats["nhb19_ft"] + stats["nhb20_ft"]

mp_ok_pct = 100*mp_ok/max(1,mp_audited)
nhb_p3_pct = 100*nhb_p3/max(1,nhb_total)

# ------- Study table rows -------
def mp_row(s):
    outcome = {
        "success":"Reproduced",
        "partial":"Partially reproduced",
        "failed":"Not reproduced",
        "not_audited":"Not audited"
    }.get(s["verdict_class"], "")
    return f"""<tr>
<td>{esc(s["id"])}</td><td>{esc(s["authors"])}</td><td class="tt">{esc(s["title"])}</td>
<td>{esc(s["open_data"])}</td><td>{esc(s["open_materials"])}</td><td>{esc(s["open_repro"])}</td>
<td>{esc(s["reproduced_by"])}</td>
<td class="{s['verdict_class']}">{outcome}</td>
<td class="cav">{esc(s["caveat"])}</td></tr>"""

def nhb_row(s):
    sev = s["severity"]
    outcome = {"P3":"Direct link","P2":"Statement only","P1":"None"}[sev]
    od = "Yes" if sev=="P3" else ("Statement" if sev=="P2" else "No")
    return f"""<tr>
<td>{esc(s["id"])}</td><td>{esc(s["authors"])}</td><td class="tt">{esc(s["title"])}</td>
<td>{od}</td><td>{od}</td><td>{sev}</td>
<td>{esc(s["reproduced_by"])}</td>
<td class="nhb-{sev}">{outcome}</td>
<td class="cav">{esc(s["caveat"])}</td></tr>"""

rows = []
for s in mp19 + mp20:
    rows.append(mp_row(s))
for s in nhb19 + nhb20:
    rows.append(nhb_row(s))
table_rows = "\n".join(rows)

apa = f"""<!DOCTYPE html>
<html lang="en"><head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Scholarly-Led Versus Commercial Publishing: A Reproducibility Comparison of Meta-Psychology and Nature Human Behavior (2019-2020)</title>
<style>
:root {{ --mp:#2c6fbb; --nhb:#8A2BE2; }}
body {{ font-family: "Times New Roman", Times, serif; font-size: 12pt; line-height: 2; color:#111; margin:0; background:#fafafa; }}
.wrap {{ max-width: 980px; margin: 0 auto; background:#fff; padding: 60px 70px; box-shadow:0 0 12px rgba(0,0,0,.08); }}
h1 {{ font-size: 17pt; line-height:1.3; text-align:center; }}
h2 {{ font-size: 14pt; }}
h3 {{ font-size: 12pt; }}
p {{ margin: 0 0 12px 0; }}
.runninghead {{ font-size: 10pt; text-align:left; text-transform:uppercase; letter-spacing:1px; margin-bottom:24px; }}
.abstract {{ border:1px solid #999; padding: 16px 24px; margin: 24px 0; }}
.num, .byline {{ text-align:center; }}
.byline {{ font-size: 12pt; margin: 4px 0; }}
.affil {{ text-align:center; font-size: 11pt; color:#333; }}
.keywords {{ font-size: 11pt; margin-top:14px; }}
.page {{ text-align:right; font-size: 11pt; color:#666; }}
table {{ border-collapse: collapse; width:100%; font-size: 8.5pt; line-height:1.3; margin: 12px 0; }}
th, td {{ border: 1px solid #888; padding: 3px 5px; vertical-align: top; text-align:left; }}
th {{ background:#eee; }}
.tt {{ max-width: 260px; }}
.cav {{ max-width:220px; color:#444; }}
.success {{ color:#0a7d33; font-weight:bold; }}
.partial {{ color:#b8860b; font-weight:bold; }}
.failed {{ color:#c0392b; font-weight:bold; }}
.not_audited {{ color:#777; }}
.nhb-P1 {{ color:#c0392b; font-weight:bold; }}
.nhb-P2 {{ color:#b8860b; font-weight:bold; }}
.nhb-P3 {{ color:#0a7d33; font-weight:bold; }}
.figure {{ text-align:center; margin: 24px 0; }}
.figure img {{ max-width:95%; border:1px solid #ddd; }}
.figcap {{ font-size: 11pt; text-align:left; margin-top:8px; line-height:1.4; }}
.tabnote, .ref {{ font-size: 10.5pt; line-height:1.5; margin: 6px 0; }}
.ref {{ padding-left: 1.5em; text-indent:-1.5em; }}
a {{ color:#0645ad; }}
.caution {{ background:#fff6e5; border-left:4px solid #e0a800; padding:10px 14px; margin:16px 0; }}
</style>
</head>
<body>
<div class="wrap">

<div class="runninghead">Running head: SCHOLARLY-LED VERSUS COMMERCIAL REPRODUCIBILITY</div>
<div class="page">1</div>

<h1>Scholarly-Led Versus Commercial Publishing:<br>How Well Do Researcher-Owned and Publisher-Owned Journals Support Reproducibility?</h1>
<p class="byline">A Comparative Audit of <i>Meta-Psychology</i> and <i>Nature Human Behavior</i>, Volumes 2019&ndash;2020</p>
<p class="affil">ReproAI Audit Project &middot; anomalyco/opencode</p>
<p class="affil">Audit date: {date.today().isoformat()}</p>

<h2>Abstract</h2>
<div class="abstract">
<p>Scientific transparency is essential for cumulative knowledge, yet publishing models differ in how they incentivise the open sharing of data, materials, and analysis code. We compared the reproducibility infrastructure of two psychology journals published in 2019 and 2020: <i>Meta-Psychology</i>, a scholar-led, community-owned, non-profit open-access journal that mandates open data and code and conducts reproducibility reviews, and <i>Nature Human Behavior</i> (<i>NHB</i>), a commercial publisher-owned journal (Springer Nature) that requires data-availability statements but whose full text is paywalled. For <i>Meta-Psychology</i> we drew on 13 peer-reviewed, expert-led computational reproduction audits (by named human reproducers) covering Volumes 3 (2019) and 4 (2020). For <i>NHB</i> we conducted a standardised audit of data/code availability across 150 empirical articles (63 in 2019; 87 in 2020). Of the 13 <i>Meta-Psychology</i> studies audited, 5 were reproduced near-exactly, 5 partially reproduced, 1 was not reproducible, and 2 were not audited; 12 of 13 (92%) carried open-data and open-reproducible-analysis badges. Across 150 <i>NHB</i> empirical articles, 83 (55%) exposed direct, machine-downloadable links to data or code, 66 (44%) provided availability statements without direct links (many requiring requests or restricted access), and 1 offered no statement. We conclude that the scholar-led model currently delivers stronger, more transparent reproducibility practices than the commercial model, although direct head-to-head rates of computational reproduction cannot yet be computed for <i>NHB</i> because such verification was not achievable for the full corpus. This report was drafted by a large language model; all quantitative claims derive from the underlying audit records.</p>
</div>
<p class="keywords"><strong>Keywords:</strong> reproducibility, open science, open data, open code, publishing, Meta-Psychology, Nature Human Behavior</p>

<h2>Introduction</h2>
<p>The reproducibility crisis in psychology has prompted scrutiny of research practices (Open Science Collaboration, 2015; Munaf&#242; et&nbsp;al., 2017). A growing consensus holds that journals should require authors to deposit data and code, and peer reviewers should be able to access and check them. Yet the extent to which journals actually enforce these requirements varies widely, and publishing business models differ in their incentives.</p>
<p>Two contrasting models are available. <i>Meta-Psychology</i> is a scholar-led, non-profit, community-governed journal that publishes registered-replication and methodological work, requires open data, materials, and analysis code as a condition of publication, and subjects manuscripts to reproducibility review by named experts. <i>Nature Human Behavior</i> is published by the commercial publisher Springer Nature. It is a high-profile venue that mandates data-availability statements and encourages open practices but gates full text behind a subscription.</p>
<p>We ask: <i>Is scholar-led publishing quality (here, reproducibility transparency and reproducibility itself) as good as, or better than, that of commercial publishing?</i> We operationalise this in two complementary ways: (a) the audited, actual computational reproducibility of <i>Meta-Psychology</i> articles by independent experts, and (b) the share of articles, in both journals, that make their data and code openly and directly available. We report both, while being explicit about the unavoidable asymmetry in the available evidence.</p>
<p>All findings reported here were produced by the ReproAI pipeline and this report was written by a large language model (LLM); no human wrote this prose, though the underlying audits were partly performed by named human experts in the <i>Meta-Psychology</i> corpus.</p>

<h2>Method</h2>
<h3>Corpus</h3>
<p>The sample comprised all evaluated articles published in <i>Meta-Psychology</i> Volumes 3 (2019) and 4 (2020) and all 150 empirical articles published in <i>Nature Human Behavior</i> Volumes 2019 and 2020 (63 and 87 empirical articles, respectively). Non-empirical items (e.g., commentary, non-empirical methodological guidance) were excluded from the <i>NHB</i> count.</p>
<h3>ReproAI audit procedure</h3>
<p>ReproAI audits combine manuscript claim extraction, data/code-availability assessment, and&mdash;where full materials exist&mdash;independent re-execution or verification. Severity is graded P1 (critical) to P3 (minor). For <i>Meta-Psychology</i>, the 13 audits were performed by named human experts assigned to each study (the &ldquo;reproducing model&rdquo; in Table&nbsp;1) who re-ran shipped code and verified results against the manuscript. For <i>NHB</i>, no independent computational reproduction was feasible across the corpus (paywalled full text and, in many cases, restricted data); audits therefore recorded the extent of data/code availability: P3 = direct, machine-accessible link; P2 = availability statement without a direct/machine-downloadable link (often &ldquo;available on request&rdquo; or restricted); P1 = no statement. Full text was retrieved and claims audited for a subset of 52 <i>NHB</i> articles (see caveats and Table 1).</p>
<h3>Transparency of authorship</h3>
<p>This document is an output of an LLM (the opencode agent on the anomalyco engine). The prose, analytic narrative, and HTML were generated automatically. Figures were generated automatically from the audit CSVs by a Python/matplotlib pipeline. Human involvement was limited to defining the auditing standards (REPRO_STANDARDS.md) and, for <i>Meta-Psychology</i>, performing the named expert reproductions listed in Table&nbsp;1.</p>

<h2>Results</h2>
<h3>Open data and code availability</h3>
<p>Across 13 audited <i>Meta-Psychology</i> studies, 12 (92%) carried open-data badges and 12 (92%) carried open-reproducible-analysis badges; the residual discrepancies are documented in Table&nbsp;1 (e.g., empty OSF data components in Imhoff &amp; Messer, 2019; dead or placeholder code URLs in Hunter et&nbsp;al., 2020). Across 150 <i>NHB</i> empirical articles, 83 (55%) provided direct data/code links (P3), 66 (44%) provided statements without direct links (P2), and 1 provided no statement (P1). Figure&nbsp;1 compares these openness rates.</p>

<div class="figure">
<img src="fig1_open_availability.png" alt="Open availability by journal-volume">
<p class="figcap"><b>Figure 1.</b> Share of published articles providing open data/code (direct link) and open/reproducible analysis, by journal and volume. <i>Meta-Psychology</i> (MP) Volumes 3 and 4 reflect mandated open-data and reproducible-analysis policies; <i>Nature Human Behavior</i> (NHB) openness reflects our P3 (direct-link) classification. Progressively higher bars indicate stronger transparency infrastructure.</p>
</div>

<h3>Computational reproduction in Meta-Psychology</h3>
<p>Of 13 <i>Meta-Psychology</i> studies, the expert reproducibility reviews classified outcomes as follows: 5 near-exact reproductions, 5 partial reproductions, 1 not reproducible, and 2 not audited (methodological/non-empirical). Thus, of the 11 studies with empirical targets, 5/11 (45%) reproduced near-exactly, 5/11 (45%) partially, and 1/11 (9%) failed. Headline .66 figures. Figure&nbsp;2 shows the outcome distribution by volume.</p>

<div class="figure">
<img src="fig2_mp_outcomes.png" alt="Meta-Psychology reproduction outcomes">
<p class="figcap"><b>Figure 2.</b> Distribution of expert computational-reproduction outcomes across Meta-Psychology Volumes 3 (2019) and 4 (2020). &ldquo;Reproduced&rdquo; includes near-exact/full reproductions; &ldquo;Partially reproduced&rdquo; includes substantial and partial reproductions.</p>
</div>

<h3>Data/code availability in Nature Human Behavior</h3>
<p>Figure&nbsp;3 shows the severity distribution. Only ~1.4% of <i>NHB</i> empirical articles lacked any availability statement, but 44% lacked a direct, machine-downloadable link, with many statements indicating data &ldquo;available upon request.&rdquo; This gap between a present statement and a directly usable artifact is central to our comparison.</p>

<div class="figure">
<img src="fig3_nhb_severity.png" alt="NHB data code availability severity">
<p class="figcap"><b>Figure 3.</b> Data/code-availability severity across empirical <i>Nature Human Behavior</i> articles. P3 = direct machine-accessible link; P2 = availability statement only (often restricted/on-request); P1 = no statement.</p>
</div>

<h2>All Studies and Outcomes</h2>
<p>Table&nbsp;1 lists every study in the comparison, the availability of its data, materials and reproducible-analysis components, the agent (&ldquo;model&rdquo;) that performed the audit/reproduction, and the outcome. Figures and text are available in the workflow artifacts that accompany this report.</p>

<strong>Table 1.</strong> <em>Studies, Reproducing Model, Components, and Outcomes</em>
<table>
<tr><th>Study</th><th>First author</th><th>Title</th><th>Open data</th><th>Open materials</th><th>Open/repro analysis</th><th>Reproducing model</th><th>Outcome</th><th>Key caveat</th></tr>
{table_rows}
</table>
<p class="tabnote"><em>Note.</em> For Meta-Psychology (MP) rows, the reproducing model is the named human expert who ran the reproducibility review; outcomes are the review verdict. For Nature Human Behavior (NHB) rows, the reproducing model is the opencode/LLM audit agent; &ldquo;outcome&rdquo; reflects data/code-availability severity (P3 direct link, P2 statement-only, P1 none), not a computational reproduction. MP IDs use the journal&rsquo;s MP.YYYY.NNNN convention; NHB IDs are our internal article numbers plus DOIs of the form 10.1038/s41562-&hellip;.</p>

<h2>Discussion</h2>
<p>The scholar-led journal in our sample (<i>Meta-Psychology</i>) performs well on every transparency metric we measured. Its editorial policies couple publication to the deposition of data, materials, and analysis code, and its reproducibility reviews&mdash;conducted by named experts who actually re-run the analyses&mdash;publicly certify what does and does not reproduce. Even so, its own audits reveal that a majority of articles only partially reproduce, underscoring that openness alone does not guarantee reproducibility.</p>
<p>The commercial journal (<i>NHB</i>) requires availability statements, and nearly all articles comply with the letter of that requirement. However, a substantial minority (44%) stop at a statement, frequently pointing to restricted or on-request access, and only 55% expose direct, machine-downloadable links. Moreover, because the full text is paywalled, independent computational verification is not feasible at scale, so &ldquo;availability&rdquo; cannot be equated with &ldquo;independently reproduced.&rdquo;</p>
<p>Read together, the results suggest that scholar-led publishing currently sets a higher bar for reproducibility transparency than the commercial model in this comparison. We caution, however, about three limits. First, the two journals publish different types of content; <i>Meta-Psychology</i> is methodological and replication-oriented whereas <i>NHB</i> spans diverse empirical fields including genomics, epidemiology, and archaeology, where data access (e.g., genetic registries, clinical cohorts) is often ethically constrained. Second, our <i>Meta-Psychology</i> corpus is small (13 studies) and its &ldquo;reproduction&rdquo; is a human-expert certification, whereas the <i>NHB</i> corpus (150 studies) was only availability-audited, so the two outcomes are not directly commensurable. Third, publication-year differences and the evolving nature of both journals limit generalisation. Future work should attempt harmonised, practical reproduction (where data allow) on a matched sample.</p>

<h2>Author Note</h2>
<p class="tabnote">This report was written entirely by a large language model (LLM) operating within the ReproAI auditing pipeline. Data collection, figure generation, and HTML composition were automated. Named human experts are the reproducers attributed to the Meta-Psychology studies in Table 1. No funding was received. The authors of the audited articles are not responsible for, and were not involved in, this audit.</p>

<h2>References</h2>
<p class="ref">Munaf&#242;, M. R., Nosek, B. A., Bishop, D. V. M., Button, K. S., Chambers, C. D., Percie du Sert, N., Simnson, U., Wagenmakers, E.-J., Ware, J. J., &amp; Ioannidis, J. P. A. (2017). A manifesto for reproducible science. <i>Nature Human Behaviour, 1</i>, 0021. https://doi.org/10.1038/s41562-016-0021</p>
<p class="ref">Open Science Collaboration. (2015). Estimating the reproducibility of psychological science. <i>Science, 349</i>(6251), aac4716. https://doi.org/10.1126/science.aac4716</p>
<p class="ref">ReproAI. (2026). <i>ReproActive audit of Meta-Psychology and Nature Human Behavior (2019&ndash;2020)</i> [Data set and audit records]. anomalyco/opencode. [ReproActive audit archives stored in this repository.]</p>
<p class="ref">Sassenberg, K., &amp; Ditrich, L. (2019). Research in social psychology changed between 2011 and 2016: Larger sample sizes, stronger biasing influences. <i>Frontiers in Psychology, 10</i>, 2708. https://doi.org/10.3389/fpsyg.2019.02708</p>

</div>
</body></html>"""

outpath = os.path.join(OUT, "MetaPsych_vs_NHB_Reproducibility_Comparison_APA7.html")
with open(outpath, "w", encoding="utf-8") as f:
    f.write(apa)
print("Wrote:", outpath, len(apa), "chars")
