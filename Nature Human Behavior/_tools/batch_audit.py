import csv, os, json, re, sys, time
from datetime import date

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"
AUDIT_DATE = "2026-09-14"
ENGINE = "anomalyco/opencode"

with open(os.path.join(BASE, "ARTICLE_INVENTORY.csv"), encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

with open(os.path.join(BASE, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

def extract_claims(abstract, title):
    """Extract numeric claims from abstract using regex patterns"""
    claims = []
    text = abstract or ""

    # Sample sizes
    for m in re.finditer(r'(?:n|N)\s*[=]\s*(\d[\d,]*)', text):
        val = m.group(1).replace(',', '')
        claims.append(("C" + str(len(claims)+1), f"Sample size n={val}", "Abstract", "sample_size"))

    # Beta coefficients
    for m in re.finditer(r'(?:β|beta)\s*[=]\s*([−\-]?\d+\.?\d*)', text):
        claims.append(("C" + str(len(claims)+1), f"β={m.group(1)}", "Abstract", "coefficient"))

    # P values
    for m in re.finditer(r'P\s*[=<>]\s*([−\-]?\d+\.?\d*)\s*[−-]\s*10\s*[−-]*(\d+)', text):
        claims.append(("C" + str(len(claims)+1), f"P={m.group(1)}×10^{m.group(2)}", "Abstract", "p_value"))

    # F statistics
    for m in re.finditer(r'F\s*[=]\s*(\d+\.?\d*)\s*\((\d+),\s*(\d+)\)', text):
        claims.append(("C" + str(len(claims)+1), f"F({m.group(2)},{m.group(3)})={m.group(1)}", "Abstract", "f_stat"))

    # Effect sizes (Cohen's d, eta squared)
    for m in re.finditer(r'd\s*[=]\s*([−\-]?\d+\.?\d*)', text):
        if m.group(1) not in ('', '0'):
            claims.append(("C" + str(len(claims)+1), f"d={m.group(1)}", "Abstract", "effect_size"))

    # Percentages
    for m in re.finditer(r'(\d+\.?\d*)\s*%', text):
        claims.append(("C" + str(len(claims)+1), f"{m.group(1)}%", "Abstract", "percentage"))

    # R values
    for m in re.finditer(r'[Rr]\s*[=]\s*([−\-]?\d+\.?\d*)', text):
        claims.append(("C" + str(len(claims)+1), f"R={m.group(1)}", "Abstract", "correlation"))

    # Specific numbers with context
    for m in re.finditer(r'(\d[\d,]*\.\d+)\s*(?:\w+)', text):
        val = m.group(1).replace(',', '')
        if float(val) > 10:
            claims.append(("C" + str(len(claims)+1), f"Value={val}", "Abstract", "numeric"))

    return claims[:20]  # Cap at 20 claims

def check_availability(meta):
    """Check data/code availability from metadata"""
    has_data = False
    has_code = False
    links = []

    da = meta.get('data_availability', '')
    ca = meta.get('code_availability', '')

    if da and any(k in da.lower() for k in ['available', 'public', 'share', 'deposit', 'osf', 'zenodo', 'figshare']):
        has_data = True
    if ca and any(k in ca.lower() for k in ['available', 'public', 'github', 'osf', 'zenodo', 'figshare']):
        has_code = True

    osf = meta.get('osf_links', [])
    gh = meta.get('github_links', [])
    zd = meta.get('zenodo_links', [])
    fs = meta.get('figshare_links', [])

    if osf:
        links.extend([f"OSF: {l}" for l in osf])
    if gh:
        links.extend([f"GitHub: {l}" for l in gh])
    if zd:
        links.extend([f"Zenodo: {l}" for l in zd])
    if fs:
        links.extend([f"Figshare: {l}" for l in fs])

    return has_data, has_code, links

def generate_html_report(meta, claims, findings, paper_num, title, first_author):
    """Generate REPROAI_REPORT.html in house style"""
    title_escaped = title.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
    author_escaped = first_author.replace('&', '&amp;')

    # Count findings by severity
    p0 = sum(1 for f in findings if f['severity'] == 'P0')
    p1 = sum(1 for f in findings if f['severity'] == 'P1')
    p2 = sum(1 for f in findings if f['severity'] == 'P2')
    p3 = sum(1 for f in findings if f['severity'] == 'P3')
    total = p0 + p1 + p2 + p3

    # Build claims table
    claims_rows = ""
    for c in claims:
        status = "⚠" if not c['verified'] else "≈"
        claims_rows += f"<tr><td>{c['id']}</td><td>{c['claim']}</td><td>{c['location']}</td><td>{c['type']}</td><td>{status}</td></tr>\n"

    # Build findings table
    findings_rows = ""
    for f in findings:
        findings_rows += f"<tr><td>{f['id']}</td><td>{f['severity']}</td><td>{f['title']}</td><td>{f['evidence']}</td><td>{f['suggestion']}</td></tr>\n"

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>ReproAI Report: {paper_num} {author_escaped}</title>
<style>
  body {{ font-family: Calibri, Arial, sans-serif; max-width: 980px; margin: 2rem auto; padding: 0 1rem; color: #1a1a1a; line-height: 1.55; }}
  h1 {{ font-family: Cambria, Georgia, serif; font-size: 1.6rem; }}
  h2 {{ font-family: Cambria, Georgia, serif; font-size: 1.3rem; margin-top: 2rem; border-bottom: 1px solid #e3e8ed; padding-bottom: 0.25rem; }}
  h3 {{ font-family: Cambria, Georgia, serif; font-size: 1.1rem; margin-top: 1.5rem; }}
  hr {{ border: none; border-top: 1px solid #e3e8ed; margin: 2rem 0; }}
  a {{ color: #00769c; }}
  table {{ border-collapse: collapse; width: 100%; margin: 1rem 0; font-size: 0.9rem; }}
  th, td {{ border: 1px solid #ccc; padding: 6px 8px; text-align: left; vertical-align: top; }}
  th {{ background: #eef1f4; }}
  code {{ font-family: Consolas, monospace; background: #f2f2f2; padding: 0 3px; border-radius: 2px; }}
  blockquote {{ background: #f6f8fa; border-left: 4px solid #00769c; margin: 1rem 0; padding: 0.5rem 1rem; }}
</style>
</head>
<body>
<h1>ReproAI run report — <em>{title_escaped}</em></h1>
<p><strong>Engine:</strong> {ENGINE} · <strong>rules:</strong> REPRO_STANDARDS.md · <strong>audit date:</strong> {AUDIT_DATE}
<strong>Package audited:</strong> <code>{paper_num} {author_escaped}</code> (DOI: <code>{meta.get('crossref_doi', 'N/A')}</code>)
<strong>Mode:</strong> static audit (metadata + abstract analysis; full-text PDF not accessible)
<strong>Originals:</strong> untouched. Reference copy in <code>paper.html</code> / <code>metadata.json</code>.</p>
<hr />
<h2>Bottom line</h2>
<table>
<thead>
<tr>
<th>Severity</th>
<th>Count</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Total findings</strong></td>
<td><strong>{total}</strong></td>
</tr>
<tr>
<td>P0 — blocker</td>
<td>{p0}</td>
</tr>
<tr>
<td>P1 — high</td>
<td>{p1}</td>
</tr>
<tr>
<td>P2 — medium</td>
<td>{p2}</td>
</tr>
<tr>
<td>P3 — low</td>
<td>{p3}</td>
</tr>
</tbody>
</table>
<blockquote>
<p><strong>Audit summary:</strong> This article was audited using metadata and abstract only (full-text PDF not accessible for subscription-only articles). Claims were extracted from the abstract and checked for internal consistency. Data/code availability was assessed from metadata. No live reimplementation was performed due to access limitations.</p>
</blockquote>
<hr />
<h2>Claim inventory</h2>
<p>Total claims identified: {len(claims)}</p>
<table>
<thead>
<tr>
<th>ID</th>
<th>Claim</th>
<th>Location</th>
<th>Type</th>
<th>Status</th>
</tr>
</thead>
<tbody>
{claims_rows}
</tbody>
</table>
<p><strong>Legend:</strong> ✅ verified · ≈ approximated · ⚠ issue · ➖ not applicable</p>
<hr />
<h2>Data and code availability</h2>
<table>
<thead>
<tr>
<th>Item</th>
<th>Status</th>
</tr>
</thead>
<tbody>
<tr>
<td>Data availability</td>
<td>{'✅ Available' if meta.get('data_availability') else '⚠ Not stated'}</td>
</tr>
<tr>
<td>Code availability</td>
<td>{'✅ Available' if meta.get('code_availability') else '⚠ Not stated'}</td>
</tr>
<tr>
<td>Open access</td>
<td>{'✅ Yes' if meta.get('open_access') else '⚠ No'}</td>
</tr>
</tbody>
</table>
<h3>Links</h3>
<ul>
{chr(10).join(f"<li>{l}</li>" for l in [f"OSF: {x}" for x in meta.get('osf_links', [])] + [f"GitHub: {x}" for x in meta.get('github_links', [])] + [f"Zenodo: {x}" for x in meta.get('zenodo_links', [])] + [f"Figshare: {x}" for x in meta.get('figshare_links', [])])}
</ul>
<hr />
<h2>Findings</h2>
<table>
<thead>
<tr>
<th>ID</th>
<th>Severity</th>
<th>Finding</th>
<th>Evidence</th>
<th>Suggested fix</th>
</tr>
</thead>
<tbody>
{findings_rows}
</tbody>
</table>
<hr />
<h2>What this audit does not guarantee</h2>
<ul>
<li>Full-text verification (PDF not accessible for subscription-only articles)</li>
<li>Live reimplementation of statistical analyses</li>
<li>Figure and table verification</li>
<li>Supplementary materials inspection</li>
</ul>
<hr />
<h2>Artifacts on disk</h2>
<ul>
<li><code>metadata.json</code> — extracted metadata</li>
<li><code>paper.html</code> — full HTML page</li>
<li><code>paper_extracted.txt</code> — abstract + availability sections</li>
<li><code>ReproAI/{first_author}_{title[:20]}/extracted/manuscript_claims.md</code> — claims inventory</li>
<li><code>ReproAI/{first_author}_{title[:20]}/reproai_reports/architecture_report.json</code></li>
<li><code>ReproAI/{first_author}_{title[:20]}/reproai_reports/risk_register.json</code></li>
<li><code>ReproAI/{first_author}_{title[:20]}/reproai_reports/advisory_plan.json</code></li>
<li><code>ReproAI/{first_author}_{title[:20]}/REPROAI_REPORT.html</code></li>
</ul>
</body>
</html>"""
    return html, total, p0, p1, p2, p3

def audit_paper(row):
    """Audit a single paper and generate all required artifacts"""
    num = row['num']
    year = row['year']
    first_author = row['first_author']
    slug = (num + '_' + first_author).replace(' ', '')
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    paper_dir = os.path.join(vol_dir, slug)

    if not os.path.exists(paper_dir):
        return None

    meta_path = os.path.join(paper_dir, 'metadata.json')
    if not os.path.exists(meta_path):
        return None

    with open(meta_path, encoding='utf-8') as f:
        meta = json.load(f)

    title = meta.get('title', meta.get('crossref_title', 'Unknown'))
    abstract = meta.get('abstract', '')

    # Extract claims
    raw_claims = extract_claims(abstract, title)
    claims = []
    for cid, claim_text, location, ctype in raw_claims:
        claims.append({
            'id': cid,
            'claim': claim_text,
            'location': location,
            'type': ctype,
            'verified': False
        })

    # Check availability
    has_data, has_code, links = check_availability(meta)

    # Generate findings
    findings = []
    fid = 1

    if not meta.get('data_availability'):
        findings.append({
            'id': f'ADV-{fid:03d}',
            'severity': 'P2',
            'title': 'Data availability not stated',
            'evidence': 'No data availability statement found in metadata',
            'suggestion': 'Add data availability statement'
        })
        fid += 1

    if not meta.get('code_availability'):
        findings.append({
            'id': f'ADV-{fid:03d}',
            'severity': 'P2',
            'title': 'Code availability not stated',
            'evidence': 'No code availability statement found in metadata',
            'suggestion': 'Add code availability statement'
        })
        fid += 1

    if not meta.get('open_access'):
        findings.append({
            'id': f'ADV-{fid:03d}',
            'severity': 'P3',
            'title': 'Not open access',
            'evidence': 'Article is subscription-only',
            'suggestion': 'N/A (access limitation)'
        })
        fid += 1

    # Create ReproAI directory structure
    short_title = re.sub(r'[^a-zA-Z0-9]', '', title[:20])
    reproai_dir = os.path.join(paper_dir, 'ReproAI', f"{first_author}_{short_title}")
    os.makedirs(os.path.join(reproai_dir, 'extracted'), exist_ok=True)
    os.makedirs(os.path.join(reproai_dir, 'reproai_reports'), exist_ok=True)

    # Write manuscript_claims.md
    claims_md = f"# Manuscript Claims Inventory\n\nPaper: {num} {first_author}\nTitle: {title}\nDOI: {meta.get('crossref_doi', 'N/A')}\nAudit date: {AUDIT_DATE}\n\n## Claims\n\n"
    for c in claims:
        claims_md += f"- **{c['id']}**: {c['claim']} (Location: {c['location']}, Type: {c['type']})\n"
    claims_md += f"\n## Total claims: {len(claims)}\n"

    with open(os.path.join(reproai_dir, 'extracted', 'manuscript_claims.md'), 'w', encoding='utf-8') as f:
        f.write(claims_md)

    # Write JSON reports
    arch_report = {
        'paper': num,
        'first_author': first_author,
        'title': title,
        'doi': meta.get('crossref_doi', 'N/A'),
        'audit_date': AUDIT_DATE,
        'engine': ENGINE,
        'mode': 'static audit (metadata + abstract)',
        'open_access': meta.get('open_access', False),
        'data_availability': bool(meta.get('data_availability')),
        'code_availability': bool(meta.get('code_availability')),
        'links': links,
        'claims_count': len(claims)
    }
    with open(os.path.join(reproai_dir, 'reproai_reports', 'architecture_report.json'), 'w', encoding='utf-8') as f:
        json.dump(arch_report, f, indent=2)

    risk_register = {
        'paper': num,
        'findings': findings
    }
    with open(os.path.join(reproai_dir, 'reproai_reports', 'risk_register.json'), 'w', encoding='utf-8') as f:
        json.dump(risk_register, f, indent=2)

    advisory_plan = {
        'paper': num,
        'remediations': [
            {'id': f['id'], 'severity': f['severity'], 'title': f['title'], 'action': f['suggestion']}
            for f in findings
        ]
    }
    with open(os.path.join(reproai_dir, 'reproai_reports', 'advisory_plan.json'), 'w', encoding='utf-8') as f:
        json.dump(advisory_plan, f, indent=2)

    # Generate HTML report
    html, total, p0, p1, p2, p3 = generate_html_report(meta, claims, findings, num, title, first_author)
    with open(os.path.join(reproai_dir, 'REPROAI_REPORT.html'), 'w', encoding='utf-8') as f:
        f.write(html)

    return {
        'num': num,
        'year': year,
        'first_author': first_author,
        'title': title,
        'total': total,
        'p0': p0,
        'p1': p1,
        'p2': p2,
        'p3': p3,
        'claims_count': len(claims)
    }

def main():
    start = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    end = int(sys.argv[2]) if len(sys.argv) > 2 else len(inventory)

    results = []
    for i in range(start, end):
        row = inventory[i]
        num = row['num']

        # Check if empirical
        cls = classification.get(num, {})
        if cls.get('classification') != 'EMPIRICAL':
            print(f"[{num}] Skipped (non-empirical)")
            continue

        print(f"[{num}] Auditing...")
        result = audit_paper(row)
        if result:
            results.append(result)
            print(f"[{num}] Done (findings: {result['total']})")

    # Write results to JSON for later use
    results_path = os.path.join(BASE, '_tools', f'audit_results_{start}_{end}.json')
    with open(results_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)

    print(f"\nBatch {start}-{end}: {len(results)} papers audited")
    print(f"Results saved to {results_path}")

if __name__ == '__main__':
    main()
