import json, os, csv

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(os.path.join(BASE, "ARTICLE_INVENTORY.csv"), encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

with open(os.path.join(BASE, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

stats = {
    'total_empirical': 0,
    'has_da_link': 0,
    'has_da_text_no_link': 0,
    'has_ca_link': 0,
    'has_ca_text_no_link': 0,
    'has_any_link': 0,
    'no_availability_info': 0,
}

updated_papers = []

for row in inventory:
    num = row['num']
    year = row['year']
    first_author = row['first_author']
    cls = classification.get(num)
    if not cls or cls.get('classification') != 'EMPIRICAL':
        continue
    
    stats['total_empirical'] += 1
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
    
    # Determine availability status
    has_da_link = bool(osf_links or gh_links or zenodo_links or figshare_links)
    has_da_text = bool(da_text) and has_da_link
    has_ca_link = bool(osf_links or gh_links or zenodo_links or figshare_links)
    has_ca_text = bool(ca_text) and has_ca_link
    
    all_links = osf_links + gh_links + zenodo_links + figshare_links
    has_any_link = bool(all_links)
    
    if has_da_link:
        stats['has_da_link'] += 1
    elif has_da_text:
        stats['has_da_text_no_link'] += 1
    
    if has_ca_link:
        stats['has_ca_link'] += 1
    elif bool(ca_text):
        stats['has_ca_text_no_link'] += 1
    
    if has_any_link:
        stats['has_any_link'] += 1
    else:
        stats['no_availability_info'] += 1
    
    # Build a comprehensive availability summary
    availability_summary = {
        'data_availability': da_text,
        'code_availability': ca_text,
        'links': {
            'osf': osf_links,
            'github': gh_links,
            'zenodo': zenodo_links,
            'figshare': figshare_links
        },
        'has_data_link': has_da_link,
        'has_code_link': has_ca_link,
        'has_any_link': has_any_link
    }
    
    updated_papers.append({
        'num': num,
        'first_author': first_author,
        'has_data_link': has_da_link,
        'has_code_link': has_ca_link,
        'has_any_link': has_any_link,
        'links': ' '.join(all_links),
        'da_text': da_text[:200],
        'ca_text': ca_text[:200]
    })

# Write updated summary
summary_path = os.path.join(BASE, "NHB_AVAILABILITY_AUDIT.csv")
with open(summary_path, 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['num', 'first_author', 'has_data_link', 'has_code_link', 'has_any_link', 'links', 'da_text', 'ca_text'])
    writer.writeheader()
    for p in updated_papers:
        writer.writerow(p)

print("=== AVAILABILITY AUDIT SUMMARY ===")
print(f"Total empirical papers: {stats['total_empirical']}")
print(f"Has Data Availability link: {stats['has_da_link']}")
print(f"Has DA text but no link: {stats['has_da_text_no_link']}")
print(f"Has Code Availability link: {stats['has_ca_link']}")
print(f"Has CA text but no link: {stats['has_ca_text_no_link']}")
print(f"Has any link (OSF/GitHub/Zenodo/Figshare): {stats['has_any_link']}")
print(f"No availability info: {stats['no_availability_info']}")
print(f"\nOutput: {summary_path}")
