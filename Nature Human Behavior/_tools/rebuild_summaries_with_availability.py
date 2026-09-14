import json, os, csv

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(os.path.join(BASE, "ARTICLE_INVENTORY.csv"), encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

with open(os.path.join(BASE, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

# Collect updated findings
findings_by_year = {'2019': [], '2020': []}

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
    
    da_text = meta.get('data_availability_full', '')
    ca_text = meta.get('code_availability_full', '')
    osf_links = meta.get('osf_links', [])
    gh_links = meta.get('github_links', [])
    zenodo_links = meta.get('zenodo_links', [])
    figshare_links = meta.get('figshare_links', [])
    
    all_links = osf_links + gh_links + zenodo_links + figshare_links
    has_link = bool(all_links)
    
    # Determine finding
    if has_link:
        severity = 'P3'
        status = 'ok'
        message = f'Data/code available: {" ".join(all_links[:2])}'
    elif da_text:
        severity = 'P2'
        status = 'warn'
        message = f'Data availability stated, no direct link: {da_text[:80]}...'
    else:
        severity = 'P1'
        status = 'critical'
        message = 'No data availability statement'
    
    findings_by_year[year].append({
        'num': num,
        'first_author': first_author,
        'title': meta.get('title', row.get('title', '')),
        'finding_id': 'F-001',
        'finding_type': 'DATA_CODE_AVAILABILITY',
        'severity': severity,
        'status': status,
        'message': message,
        'links': ' '.join(all_links)
    })

# Write updated CSVs
for year in ['2019', '2020']:
    csv_path = os.path.join(BASE, f"VOLUME_{year}_REPROAI_SUMMARY.csv")
    with open(csv_path, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['num', 'first_author', 'title', 'finding_id', 'finding_type', 'severity', 'status', 'message', 'links'])
        writer.writeheader()
        for finding in findings_by_year[year]:
            writer.writerow(finding)
    
    # Stats
    total = len(findings_by_year[year])
    p1 = sum(1 for f in findings_by_year[year] if f['severity'] == 'P1')
    p2 = sum(1 for f in findings_by_year[year] if f['severity'] == 'P2')
    p3 = sum(1 for f in findings_by_year[year] if f['severity'] == 'P3')
    ok = sum(1 for f in findings_by_year[year] if f['status'] == 'ok')
    warn = sum(1 for f in findings_by_year[year] if f['status'] == 'warn')
    critical = sum(1 for f in findings_by_year[year] if f['status'] == 'critical')
    
    print(f"\n=== VOLUME {year} ===")
    print(f"Total empirical papers: {total}")
    print(f"P1 (Critical - no info): {p1}")
    print(f"P2 (Moderate - text only): {p2}")
    print(f"P3 (Minor - has link): {p3}")
    print(f"Status ok: {ok}, warn: {warn}, critical: {critical}")
