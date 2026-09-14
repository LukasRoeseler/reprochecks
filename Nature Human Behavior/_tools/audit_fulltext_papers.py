import os, csv, json, re
from datetime import date

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"
AUDIT_DATE = date.today().isoformat()

with open(f"{BASE}\\NHB_MASTER_CLASSIFICATION.csv", encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

def extract_claims(text, title, num):
    """Extract claims from full text"""
    claims = []
    
    # Sample size
    n_match = re.search(r'sample size of (\d+)', text, re.IGNORECASE)
    if n_match:
        claims.append({
            'id': 'C1',
            'claim': f"Sample size n={n_match.group(1)}",
            'location': 'Full text',
            'type': 'sample_size',
            'value': n_match.group(1)
        })
    
    # Effect sizes
    d_matches = re.findall(r'(?:Cohens|Cohens|Cohens) d\s*=\s*([-\d.]+)', text, re.IGNORECASE)
    for i, d in enumerate(d_matches[:3]):
        claims.append({
            'id': f'C{len(claims)+1}',
            'claim': f"d={d}",
            'location': 'Full text',
            'type': 'effect_size',
            'value': d
        })
    
    # R² values
    r2_matches = re.findall(r'R²\s*=\s*([-\d.]+)', text, re.IGNORECASE)
    for i, r2 in enumerate(r2_matches[:3]):
        claims.append({
            'id': f'C{len(claims)+1}',
            'claim': f"R²={r2}",
            'location': 'Full text',
            'type': 'variance_explained',
            'value': r2
        })
    
    # p-values
    p_matches = re.findall(r'p\s*[=<]\s*([-\d.]+)', text, re.IGNORECASE)
    for i, p in enumerate(p_matches[:3]):
        claims.append({
            'id': f'C{len(claims)+1}',
            'claim': f"p={p}",
            'location': 'Full text',
            'type': 'p_value',
            'value': p
        })
    
    return claims

def extract_data_code_availability(text):
    """Extract data/code availability from full text"""
    result = {
        'data_availability': '',
        'code_availability': '',
        'osf_links': [],
        'github_links': [],
        'zenodo_links': [],
        'figshare_links': []
    }
    
    # Data availability
    da_match = re.search(r'Data availability\s*(.*?)(?:Code availability|References|$)', text, re.DOTALL | re.IGNORECASE)
    if da_match:
        result['data_availability'] = da_match.group(1).strip()[:500]
    
    # Code availability
    ca_match = re.search(r'Code availability\s*(.*?)(?:References|Acknowledgements|$)', text, re.DOTALL | re.IGNORECASE)
    if ca_match:
        result['code_availability'] = ca_match.group(1).strip()[:500]
    
    # Extract links
    for link in re.findall(r'https?://[^\s<>"\')]+', text):
        if 'osf.io' in link:
            result['osf_links'].append(link)
        elif 'github.com' in link:
            result['github_links'].append(link)
        elif 'zenodo.org' in link:
            result['zenodo_links'].append(link)
        elif 'figshare.com' in link:
            result['figshare_links'].append(link)
    
    # Deduplicate
    for key in ['osf_links', 'github_links', 'zenodo_links', 'figshare_links']:
        result[key] = list(dict.fromkeys(result[key]))
    
    return result

def audit_paper(num, year, dir_name, pdf_path):
    """Perform full ReproAI audit on a paper"""
    paper_dir = os.path.dirname(pdf_path)
    repro_dir = os.path.join(paper_dir, 'ReproAI')
    os.makedirs(os.path.join(repro_dir, 'extracted'), exist_ok=True)
    os.makedirs(os.path.join(repro_dir, 'reproai_reports'), exist_ok=True)
    
    # Read full text
    with open(os.path.join(paper_dir, 'fulltext_extracted.txt'), encoding='utf-8') as f:
        full_text = f.read()
    
    # Load metadata
    meta_path = os.path.join(paper_dir, 'metadata.json')
    with open(meta_path, encoding='utf-8') as f:
        meta = json.load(f)
    
    title = meta.get('title', '')
    first_author = meta.get('first_author', dir_name.split('_')[1])
    
    # Extract claims
    claims = extract_claims(full_text, title, num)
    
    # Extract data/code availability
    avail = extract_data_code_availability(full_text)
    
    # Determine severity
    all_links = avail['osf_links'] + avail['github_links'] + avail['zenodo_links'] + avail['figshare_links']
    if all_links:
        severity = 'P3'
        status = 'ok'
        message = f'Data/code available: {" ".join(all_links[:2])}'
    elif avail['data_availability']:
        severity = 'P2'
        status = 'warn'
        message = f'Data availability stated, no direct link'
    else:
        severity = 'P1'
        status = 'critical'
        message = 'No data availability statement found'
    
    # Write manuscript_claims.md
    claims_path = os.path.join(repro_dir, 'extracted', 'manuscript_claims.md')
    with open(claims_path, 'w', encoding='utf-8') as f:
        f.write(f"# Manuscript Claims Inventory\n\n")
        f.write(f"Paper: {num} {first_author}\n")
        f.write(f"Title: {title}\n")
        f.write(f"DOI: {meta.get('doi', '')}\n")
        f.write(f"Audit date: {AUDIT_DATE}\n")
        f.write(f"Audit type: FULL TEXT\n\n")
        f.write(f"## Claims\n\n")
        for c in claims:
            f.write(f"- **{c['id']}**: {c['claim']} (Location: {c['location']}, Type: {c['type']})\n")
        f.write(f"\n## Total claims: {len(claims)}\n")
    
    # Write architecture_report.json
    arch = {
        'paper': num,
        'title': title,
        'first_author': first_author,
        'doi': meta.get('doi', ''),
        'audit_date': AUDIT_DATE,
        'audit_type': 'FULL_TEXT',
        'engine': 'anomalyco/opencode',
        'rules': 'REPRO_STANDARDS.md',
        'claims': claims,
        'data_code_availability': {
            'data_availability': avail['data_availability'],
            'code_availability': avail['code_availability'],
            'links': {
                'osf': avail['osf_links'],
                'github': avail['github_links'],
                'zenodo': avail['zenodo_links'],
                'figshare': avail['figshare_links']
            },
            'has_direct_link': bool(all_links),
            'severity': severity,
            'status': status
        }
    }
    with open(os.path.join(repro_dir, 'reproai_reports', 'architecture_report.json'), 'w', encoding='utf-8') as f:
        json.dump(arch, f, indent=2, ensure_ascii=False)
    
    # Write risk_register.json
    risk = {
        'paper': num,
        'audit_date': AUDIT_DATE,
        'findings': [
            {
                'finding_id': 'F-001',
                'finding_type': 'DATA_CODE_AVAILABILITY',
                'severity': severity,
                'status': status,
                'message': message,
                'evidence': {
                    'data_availability': avail['data_availability'][:200],
                    'code_availability': avail['code_availability'][:200],
                    'links': all_links
                }
            }
        ]
    }
    with open(os.path.join(repro_dir, 'reproai_reports', 'risk_register.json'), 'w', encoding='utf-8') as f:
        json.dump(risk, f, indent=2, ensure_ascii=False)
    
    # Write advisory_plan.json
    advisory = {
        'paper': num,
        'audit_date': AUDIT_DATE,
        'recommendations': [
            {
                'id': 'R-001',
                'title': 'Data/code availability',
                'priority': 'high' if severity in ['P1', 'P2'] else 'low',
                'status': status,
                'notes': message
            }
        ]
    }
    with open(os.path.join(repro_dir, 'reproai_reports', 'advisory_plan.json'), 'w', encoding='utf-8') as f:
        json.dump(advisory, f, indent=2, ensure_ascii=False)
    
    # Write REPROAI_REPORT.html
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>ReproAI Report - {num} {first_author}</title>
<style>
body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 2em; max-width: 900px; }}
h1 {{ color: #1a1a2e; }}
table {{ border-collapse: collapse; width: 100%; }}
th, td {{ border: 1px solid #ddd; padding: 0.5em; }}
th {{ background: #1a1a2e; color: white; }}
.severity-P1 {{ color: #e74c3c; font-weight: bold; }}
.severity-P2 {{ color: #f39c12; font-weight: bold; }}
.severity-P3 {{ color: #27ae60; }}
</style>
</head>
<body>
<h1>ReproAI Report</h1>
<p><strong>Paper:</strong> {num} {first_author}</p>
<p><strong>Title:</strong> {title}</p>
<p><strong>DOI:</strong> {meta.get('doi', '')}</p>
<p><strong>Audit date:</strong> {AUDIT_DATE}</p>
<p><strong>Audit type:</strong> FULL TEXT</p>

<h2>Claims</h2>
<table>
<tr><th>ID</th><th>Claim</th><th>Type</th></tr>
"""
    for c in claims:
        html += f"<tr><td>{c['id']}</td><td>{c['claim']}</td><td>{c['type']}</td></tr>\n"
    html += "</table>\n"
    
    html += f"""
<h2>Data/Code Availability</h2>
<p><strong>Severity:</strong> <span class="severity-{severity}">{severity}</span></p>
<p><strong>Status:</strong> {status}</p>
<p><strong>Message:</strong> {message}</p>
"""
    if avail['data_availability']:
        html += f"<h3>Data Availability</h3><p>{avail['data_availability']}</p>\n"
    if avail['code_availability']:
        html += f"<h3>Code Availability</h3><p>{avail['code_availability']}</p>\n"
    if all_links:
        html += "<h3>Links</h3><ul>\n"
        for link in all_links:
            html += f"<li><a href='{link}'>{link}</a></li>\n"
        html += "</ul>\n"
    
    html += """
<p><em>Generated by ReproAI - anomalyco/opencode</em></p>
</body>
</html>"""
    
    with open(os.path.join(repro_dir, 'REPROAI_REPORT.html'), 'w', encoding='utf-8') as f:
        f.write(html)
    
    return {
        'num': num,
        'first_author': first_author,
        'title': title,
        'severity': severity,
        'status': status,
        'message': message,
        'claims_count': len(claims),
        'has_link': bool(all_links)
    }

# Find empirical papers with fulltext.pdf
to_audit = []
for year in ['2019', '2020']:
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    for d in os.listdir(vol_dir):
        pdf_path = os.path.join(vol_dir, d, 'fulltext.pdf')
        if os.path.exists(pdf_path):
            with open(pdf_path, 'rb') as f:
                header = f.read(5)
            if header == b'%PDF-':
                num = d.split('_')[0]
                cls = classification.get(num, {}).get('classification', 'Unknown')
                if cls == 'EMPIRICAL':
                    to_audit.append((num, year, d, pdf_path))

print(f"Auditing {len(to_audit)} empirical papers with full text...\n")

results = []
for num, year, dir_name, pdf_path in to_audit:
    print(f"  {num} ({dir_name})...", end=' ')
    try:
        result = audit_paper(num, year, dir_name, pdf_path)
        results.append(result)
        print(f"OK [{result['severity']}]")
    except Exception as e:
        print(f"ERROR: {str(e)[:50]}")

# Write summary
print(f"\n=== AUDIT SUMMARY ===")
print(f"Total audited: {len(results)}")
print(f"P1 (Critical): {sum(1 for r in results if r['severity'] == 'P1')}")
print(f"P2 (Moderate): {sum(1 for r in results if r['severity'] == 'P2')}")
print(f"P3 (Minor): {sum(1 for r in results if r['severity'] == 'P3')}")
print(f"With direct links: {sum(1 for r in results if r['has_link'])}")
