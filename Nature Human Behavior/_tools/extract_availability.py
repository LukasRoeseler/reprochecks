import csv, json, os, re, sys

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(os.path.join(BASE, "ARTICLE_INVENTORY.csv"), encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

with open(os.path.join(BASE, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

def extract_availability_from_html(html):
    """Extract data/code availability text and links from HTML"""
    result = {
        'data_availability_text': '',
        'code_availability_text': '',
        'all_links': [],
        'osf_links': [],
        'github_links': [],
        'zenodo_links': [],
        'figshare_links': [],
        'other_links': []
    }
    
    # Try to find Data Availability section
    da_match = re.search(r'Data availability</h2>(.*?)(?=<h2|</article>|$)', html, re.DOTALL)
    if da_match:
        text = re.sub(r'<[^>]+>', ' ', da_match.group(1))
        text = re.sub(r'\s+', ' ', text).strip()
        result['data_availability_text'] = text[:1000]
    
    # Try to find Code Availability section
    ca_match = re.search(r'Code availability</h2>(.*?)(?=<h2|</article>|$)', html, re.DOTALL)
    if ca_match:
        text = re.sub(r'<[^>]+>', ' ', ca_match.group(1))
        text = re.sub(r'\s+', ' ', text).strip()
        result['code_availability_text'] = text[:1000]
    
    # Extract all links
    all_links = re.findall(r'href="(https?://[^"]+)"', html)
    for link in all_links:
        if 'osf.io' in link:
            result['osf_links'].append(link)
        elif 'github.com' in link:
            result['github_links'].append(link)
        elif 'zenodo.org' in link:
            result['zenodo_links'].append(link)
        elif 'figshare.com' in link:
            result['figshare_links'].append(link)
        elif any(k in link.lower() for k in ['data', 'code', 'supplement', 'repository']):
            result['other_links'].append(link)
    
    # Remove duplicates
    for key in ['osf_links', 'github_links', 'zenodo_links', 'figshare_links', 'other_links']:
        result[key] = list(dict.fromkeys(result[key]))
    
    return result

results = []
for row in inventory:
    num = row['num']
    year = row['year']
    first_author = row['first_author']
    slug = (num + '_' + first_author).replace(' ', '')
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    paper_dir = os.path.join(vol_dir, slug)
    
    html_path = os.path.join(paper_dir, 'paper.html')
    if not os.path.exists(html_path):
        continue
    
    with open(html_path, encoding='utf-8') as f:
        html = f.read()
    
    avail = extract_availability_from_html(html)
    
    # Check if open access (full text available)
    is_oa = 'open-access' in html.lower() or 'Open access' in html
    
    # Load existing metadata
    meta_path = os.path.join(paper_dir, 'metadata.json')
    meta = {}
    if os.path.exists(meta_path):
        with open(meta_path, encoding='utf-8') as f:
            meta = json.load(f)
    
    # Update metadata with new availability info
    if avail['data_availability_text']:
        meta['data_availability_full'] = avail['data_availability_text']
    if avail['code_availability_text']:
        meta['code_availability_full'] = avail['code_availability_text']
    if avail['osf_links']:
        meta['osf_links'] = list(set(meta.get('osf_links', []) + avail['osf_links']))
    if avail['github_links']:
        meta['github_links'] = list(set(meta.get('github_links', []) + avail['github_links']))
    if avail['zenodo_links']:
        meta['zenodo_links'] = list(set(meta.get('zenodo_links', []) + avail['zenodo_links']))
    if avail['figshare_links']:
        meta['figshare_links'] = list(set(meta.get('figshare_links', []) + avail['figshare_links']))
    if avail['other_links']:
        meta['other_links'] = avail['other_links']
    meta['is_open_access_html'] = is_oa
    
    with open(meta_path, 'w', encoding='utf-8') as f:
        json.dump(meta, f, indent=2, ensure_ascii=False)
    
    results.append({
        'num': num,
        'is_oa': is_oa,
        'has_da_text': bool(avail['data_availability_text']),
        'has_ca_text': bool(avail['code_availability_text']),
        'osf_count': len(avail['osf_links']),
        'gh_count': len(avail['github_links']),
        'zenodo_count': len(avail['zenodo_links']),
        'figshare_count': len(avail['figshare_links']),
        'other_count': len(avail['other_links'])
    })

# Summary
oa_count = sum(1 for r in results if r['is_oa'])
da_count = sum(1 for r in results if r['has_da_text'])
ca_count = sum(1 for r in results if r['has_ca_text'])
osf_count = sum(r['osf_count'] > 0 for r in results)
gh_count = sum(r['gh_count'] > 0 for r in results)

print(f"Total papers: {len(results)}")
print(f"Open access (HTML): {oa_count}")
print(f"Has Data Availability text: {da_count}")
print(f"Has Code Availability text: {ca_count}")
print(f"Has OSF links: {osf_count}")
print(f"Has GitHub links: {gh_count}")

# List OA papers
print("\nOpen access papers:")
for r in results:
    if r['is_oa']:
        print(f"  {r['num']}")
