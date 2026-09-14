import json, os, csv, re

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(os.path.join(BASE, "ARTICLE_INVENTORY.csv"), encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

with open(os.path.join(BASE, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

def update_paper_report(paper_dir, meta, num, first_author):
    """Update the reproai_reports with actual availability findings"""
    da_text = meta.get('data_availability_full', '')
    ca_text = meta.get('code_availability_full', '')
    osf_links = meta.get('osf_links', [])
    gh_links = meta.get('github_links', [])
    zenodo_links = meta.get('zenodo_links', [])
    figshare_links = meta.get('figshare_links', [])
    
    all_links = osf_links + gh_links + zenodo_links + figshare_links
    has_link = bool(all_links)
    
    # Determine severity
    if has_link:
        severity = 'P3'  # Minor - data/code available with link
        status = 'ok'
        message = f'Data/code available at: {" ".join(all_links[:3])}'
    elif da_text:
        severity = 'P2'  # Moderate - text exists but no direct link
        status = 'warn'
        message = f'Data availability stated but no direct link provided: {da_text[:100]}...'
    else:
        severity = 'P1'  # High - no availability info
        status = 'critical'
        message = 'No data availability statement found'
    
    # Update architecture report
    arch_path = os.path.join(paper_dir, 'ReproAI', first_author, 'reproai_reports', 'architecture_report.json')
    if os.path.exists(arch_path):
        with open(arch_path, encoding='utf-8') as f:
            arch = json.load(f)
        
        # Add/update availability section
        arch['data_code_availability'] = {
            'data_availability_text': da_text,
            'code_availability_text': ca_text,
            'links': {
                'osf': osf_links,
                'github': gh_links,
                'zenodo': zenodo_links,
                'figshare': figshare_links
            },
            'has_direct_link': has_link,
            'severity': severity,
            'status': status
        }
        
        with open(arch_path, 'w', encoding='utf-8') as f:
            json.dump(arch, f, indent=2, ensure_ascii=False)
    
    # Update risk register
    risk_path = os.path.join(paper_dir, 'ReproAI', first_author, 'reproai_reports', 'risk_register.json')
    if os.path.exists(risk_path):
        with open(risk_path, encoding='utf-8') as f:
            risk = json.load(f)
        
        # Update the data availability finding
        for finding in risk.get('findings', []):
            if finding.get('finding_id') == 'F-001' or 'data availability' in finding.get('title', '').lower():
                finding['severity'] = severity
                finding['status'] = status
                finding['message'] = message
                finding['evidence'] = {
                    'data_availability': da_text,
                    'code_availability': ca_text,
                    'links': all_links
                }
        
        with open(risk_path, 'w', encoding='utf-8') as f:
            json.dump(risk, f, indent=2, ensure_ascii=False)
    
    # Update advisory plan
    advisory_path = os.path.join(paper_dir, 'ReproAI', first_author, 'reproai_reports', 'advisory_plan.json')
    if os.path.exists(advisory_path):
        with open(advisory_path, encoding='utf-8') as f:
            advisory = json.load(f)
        
        # Update the data availability recommendation
        for rec in advisory.get('recommendations', []):
            if 'data availability' in rec.get('title', '').lower():
                rec['status'] = status
                rec['notes'] = message
        
        with open(advisory_path, 'w', encoding='utf-8') as f:
            json.dump(advisory, f, indent=2, ensure_ascii=False)

updated = 0
for row in inventory:
    num = row['num']
    year = row['year']
    first_author = row['first_author']
    cls = classification.get(num)
    if not cls or cls.get('classification') != 'EMPIRICAL':
        continue
    
    slug = (num + '_' + first_author).replace(' ', '')
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    paper_dir = os.path.join(vol_dir, slug)
    
    meta_path = os.path.join(paper_dir, 'metadata.json')
    if not os.path.exists(meta_path):
        continue
    
    with open(meta_path, encoding='utf-8') as f:
        meta = json.load(f)
    
    update_paper_report(paper_dir, meta, num, first_author)
    updated += 1

print(f"Updated {updated} paper reports with actual availability findings")
