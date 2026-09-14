import os, re, json, csv
import pdfplumber
from datetime import date

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"
AUDIT_DATE = date.today().isoformat()

PAPERS = ["2019-02_Kristal", "2019-03_Gagnepain", "2019-04_VandeVliert", "2019-05_Earle", "2019-06_Oh", "2019-09_Bellmund"]

with open(f"{BASE}\\NHB_MASTER_CLASSIFICATION.csv", encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

def extract_text(pdf_path):
    parts = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            t = page.extract_text()
            if t:
                parts.append(t)
    return "\n".join(parts)

def extract_claims(text):
    claims = []
    def add(cid, claim, loc, typ, val):
        claims.append({'id': cid, 'claim': claim, 'location': loc, 'type': typ, 'value': val})
        return f'C{len(claims)+1}'
    
    # Sample size
    for m in re.finditer(r'sample size (?:of |was |were )?n\s*[=:]\s*([\d,]+)', text, re.IGNORECASE):
        add(f'C{len(claims)+1}', f"Sample size n={m.group(1)}", 'Full text', 'sample_size', m.group(1))
        break
    for m in re.finditer(r'N\s*=\s*([\d,]+)', text):
        add(f'C{len(claims)+1}', f"N={m.group(1)}", 'Full text', 'sample_size', m.group(1))
        if len([c for c in claims if c['type']=='sample_size']) >= 3:
            break
    
    # Effect sizes (d, beta, r, R2, b)
    patterns = [
        (r'd\s*=\s*([-\d.]+)', 'd', 'effect_size'),
        (r'beta\s*=\s*([-\d.]+)', 'beta', 'effect_size'),
        (r'B\s*=\s*([-\d.]+)', 'B', 'effect_size'),
        (r'R[²2]\s*=\s*([-\d.]+)', 'R2', 'variance_explained'),
        (r'r\s*=\s*([-\d.]+)', 'r', 'correlation'),
    ]
    for pat, label, typ in patterns:
        for m in re.finditer(pat, text, re.IGNORECASE):
            add(f'C{len(claims)+1}', f"{label}={m.group(1)}", 'Full text', typ, m.group(1))
            if len([c for c in claims if c['type']==typ]) >= 3:
                break
    
    # p-values
    for m in re.finditer(r'p\s*[<=\s]+\s*([0-9.]+)', text, re.IGNORECASE):
        add(f'C{len(claims)+1}', f"p={m.group(1)}", 'Full text', 'p_value', m.group(1))
        if len([c for c in claims if c['type']=='p_value']) >= 3:
            break
    
    return claims

def extract_availability(text):
    av = {'data_availability': '', 'code_availability': '', 'osf': [], 'github': [], 'zenodo': [], 'figshare': [], 'other': []}
    da = re.search(r'Data availability[:\s]*(.*?)(?=Code availability|References|Acknowledgements|Author contribution|$)', text, re.DOTALL | re.IGNORECASE)
    if da:
        av['data_availability'] = re.sub(r'\s+', ' ', da.group(1)).strip()[:800]
    ca = re.search(r'Code availability[:\s]*(.*?)(?=Data availability|References|Acknowledgements|Author contribution|$)', text, re.DOTALL | re.IGNORECASE)
    if ca:
        av['code_availability'] = re.sub(r'\s+', ' ', ca.group(1)).strip()[:800]
    for link in re.findall(r'https?://[^\s<>"\')]+', text):
        link = link.rstrip('.,);:')
        if 'osf.io' in link: av['osf'].append(link)
        elif 'github.com' in link: av['github'].append(link)
        elif 'zenodo.org' in link: av['zenodo'].append(link)
        elif 'figshare.com' in link: av['figshare'].append(link)
        elif any(k in link.lower() for k in ['data', 'download', 'repository', 'dryad', 'dataverse', 'osf']): av['other'].append(link)
    for k in av:
        if isinstance(av[k], list):
            av[k] = list(dict.fromkeys(av[k]))
    return av

def audit_paper(paper_dir_name):
    paper_dir = os.path.join(BASE, "Volume 2019 (2019)", paper_dir_name)
    num = paper_dir_name.split("_")[0]
    pdf_path = os.path.join(paper_dir, "paper.pdf")
    
    # Verify real PDF
    with open(pdf_path, 'rb') as f:
        if f.read(5) != b'%PDF-':
            raise RuntimeError("paper.pdf is not a valid PDF")
    
    with open(os.path.join(paper_dir, "metadata.json"), encoding="utf-8") as f:
        meta = json.load(f)
    title = meta.get('title', '')
    doi = meta.get('crossref_doi') or meta.get('doi', '')
    first_author = meta.get('crossref_authors', [meta.get('first_author', paper_dir_name.split("_")[1])])
    if isinstance(first_author, list):
        first_author = first_author[0].split()[-1] if first_author else paper_dir_name.split("_")[1]
    
    # Extract text
    full_text = extract_text(pdf_path)
    with open(os.path.join(paper_dir, "paper_extracted.txt"), "w", encoding="utf-8") as f:
        f.write(full_text)
    
    claims = extract_claims(full_text)
    av = extract_availability(full_text)
    all_links = av['osf'] + av['github'] + av['zenodo'] + av['figshare'] + av['other']
    
    if all_links:
        severity, status = 'P3', 'ok'
        message = f"Data/code availability available with links: {' '.join(all_links[:2])}"
    elif av['data_availability'] or av['code_availability']:
        severity, status = 'P2', 'warn'
        message = "Availability stated but no direct links found"
    else:
        severity, status = 'P1', 'critical'
        message = "No data/code availability statement found"
    
    # Find ReproAI folder (subdirectory containing REPROAI_REPORT.html)
    repro_dir = None
    for root, dirs, files in os.walk(paper_dir):
        if 'REPROAI_REPORT.html' in files:
            repro_dir = root
            break
    if not repro_dir:
        repro_dir = os.path.join(paper_dir, "ReproAI")
    os.makedirs(os.path.join(repro_dir, "extracted"), exist_ok=True)
    os.makedirs(os.path.join(repro_dir, "reproai_reports"), exist_ok=True)
    
    # manuscript_claims.md
    with open(os.path.join(repro_dir, "extracted", "manuscript_claims.md"), "w", encoding="utf-8") as f:
        f.write(f"# Manuscript Claims Inventory\n\n")
        f.write(f"Paper: {num} {first_author}\nTitle: {title}\nDOI: {doi}\nAudit date: {AUDIT_DATE}\nAudit type: FULL TEXT\n\n## Claims\n\n")
        for c in claims:
            f.write(f"- **{c['id']}**: {c['claim']} (Location: {c['location']}, Type: {c['type']})\n")
        f.write(f"\n## Total claims: {len(claims)}\n")
    
    # architecture_report.json
    arch = {
        'paper': num, 'title': title, 'first_author': first_author, 'doi': doi,
        'audit_date': AUDIT_DATE, 'audit_type': 'FULL_TEXT', 'engine': 'anomalyco/opencode',
        'rules': 'REPRO_STANDARDS.md', 'claims': claims, 'text_length': len(full_text),
        'data_code_availability': {
            'data_availability': av['data_availability'], 'code_availability': av['code_availability'],
            'links': {'osf': av['osf'], 'github': av['github'], 'zenodo': av['zenodo'], 'figshare': av['figshare'], 'other': av['other']},
            'has_direct_link': bool(all_links), 'severity': severity, 'status': status
        }
    }
    with open(os.path.join(repro_dir, "reproai_reports", "architecture_report.json"), "w", encoding="utf-8") as f:
        json.dump(arch, f, indent=2, ensure_ascii=False)
    
    # risk_register.json
    risk = {'paper': num, 'audit_date': AUDIT_DATE, 'findings': [{
        'finding_id': 'F-001', 'finding_type': 'DATA_CODE_AVAILABILITY', 'severity': severity, 'status': status,
        'message': message, 'evidence': {'data_availability': av['data_availability'][:300], 'code_availability': av['code_availability'][:300], 'links': all_links}
    }]}
    with open(os.path.join(repro_dir, "reproai_reports", "risk_register.json"), "w", encoding="utf-8") as f:
        json.dump(risk, f, indent=2, ensure_ascii=False)
    
    # advisory_plan.json
    advisory = {'paper': num, 'audit_date': AUDIT_DATE, 'recommendations': [{
        'id': 'R-001', 'title': 'Data/code availability', 'priority': 'high' if severity in ['P1','P2'] else 'low',
        'status': status, 'notes': message
    }]}
    with open(os.path.join(repro_dir, "reproai_reports", "advisory_plan.json"), "w", encoding="utf-8") as f:
        json.dump(advisory, f, indent=2, ensure_ascii=False)
    
    # REPROAI_REPORT.html
    html = f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8">
<title>ReproAI Report - {num} {first_author}</title>
<style>body{{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;margin:2em;max-width:900px}}h1{{color:#1a1a2e}}table{{border-collapse:collapse;width:100%}}th,td{{border:1px solid #ddd;padding:.5em}}th{{background:#1a1a2e;color:white}}.severity-P1{{color:#e74c3c;font-weight:bold}}.severity-P2{{color:#f39c12;font-weight:bold}}.severity-P3{{color:#27ae60}}a{{word-break:break-all}}</style>
</head><body>
<h1>ReproAI Report</h1>
<p><strong>Paper:</strong> {num} {first_author}</p>
<p><strong>Title:</strong> {title}</p>
<p><strong>DOI:</strong> {doi}</p>
<p><strong>Audit date:</strong> {AUDIT_DATE} | <strong>Type:</strong> FULL TEXT | <strong>Text length:</strong> {len(full_text)} chars</p>
<h2>Claims</h2>
<table><tr><th>ID</th><th>Claim</th><th>Type</th></tr>
"""
    for c in claims:
        html += f"<tr><td>{c['id']}</td><td>{c['claim']}</td><td>{c['type']}</td></tr>\n"
    html += "</table>"
    html += f"<h2>Data/Code Availability</h2><p><strong>Severity:</strong> <span class='severity-{severity}'>{severity}</span> | <strong>Status:</strong> {status}</p><p><strong>Message:</strong> {message}</p>"
    if av['data_availability']:
        html += f"<h3>Data Availability</h3><p>{av['data_availability']}</p>"
    if av['code_availability']:
        html += f"<h3>Code Availability</h3><p>{av['code_availability']}</p>"
    if all_links:
        html += "<h3>Links</h3><ul>" + "".join(f"<li><a href='{l}'>{l}</a></li>" for l in all_links[:10]) + "</ul>"
    html += "<p><em>Generated by ReproAI - anomalyco/opencode</em></p></body></html>"
    with open(os.path.join(repro_dir, "REPROAI_REPORT.html"), "w", encoding="utf-8") as f:
        f.write(html)
    
    return {'num': num, 'first_author': first_author, 'title': title, 'severity': severity, 'status': status,
            'message': message, 'claims_count': len(claims), 'has_link': bool(all_links),
            'text_length': len(full_text), 'osf': av['osf'], 'github': av['github'], 'zenodo': av['zenodo'], 'figshare': av['figshare'], 'other': av['other']}

results = []
for p in PAPERS:
    print(f"\n=== {p} ===")
    try:
        r = audit_paper(p)
        results.append(r)
        print(f"  claims={r['claims_count']}, text={r['text_length']} chars, severity={r['severity']} [{r['status']}]")
        print(f"  message: {r['message']}")
        if r['has_link']:
            print(f"  links: OSF={r['osf']} GH={r['github']} Zenodo={r['zenodo']} Figshare={r['figshare']} Other={r['other']}")
    except Exception as e:
        print(f"  ERROR: {str(e)[:100]}")

print("\n\n=== FULL-TEXT AUDIT SUMMARY (6 papers) ===")
for r in results:
    print(f"  {r['num']} {r['first_author']}: {r['severity']} [{r['status']}] - {r['claims_count']} claims, {r['text_length']} chars")
