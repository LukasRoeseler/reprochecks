import urllib.request, json, csv, time, os, re

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"
EMAIL = "lroesele@ivv5net.de"

with open(f"{BASE}\\ARTICLE_INVENTORY.csv", encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

results = []
for i, row in enumerate(inventory):
    doi = row['doi']
    num = row['num']
    first_author = row['first_author']
    
    if not doi:
        continue
    
    # Try Unpaywall first
    oa_pdf = ''
    oa_landing = ''
    is_oa = False
    method = ''
    
    try:
        url = f"https://api.unpaywall.org/v2/{doi}?email={EMAIL}"
        req = urllib.request.Request(url)
        response = urllib.request.urlopen(req, timeout=15)
        data = json.loads(response.read())
        
        is_oa = data.get('is_oa', False)
        loc = data.get('best_oa_location') or {}
        oa_pdf = loc.get('url_for_pdf', '')
        oa_landing = loc.get('url_for_landing_page', '')
        
        if is_oa and oa_pdf:
            method = 'unpaywall'
    except Exception as e:
        method = f'unpaywall_error: {str(e)[:30]}'
    
    # If not OA via Unpaywall, try direct PDF URL
    full_text_available = False
    download_url = ''
    
    if is_oa and oa_pdf:
        full_text_available = True
        download_url = oa_pdf
    else:
        # Try direct Nature PDF URL
        try:
            pdf_url = f"https://www.nature.com/articles/{doi.replace('10.1038/', '')}.pdf"
            req = urllib.request.Request(pdf_url, method='HEAD')
            response = urllib.request.urlopen(req, timeout=10)
            if response.status == 200:
                content_type = response.headers.get('Content-Type', '')
                if 'pdf' in content_type:
                    full_text_available = True
                    download_url = pdf_url
                    method = 'direct_nature'
        except:
            pass
    
    # Clean DOI (remove trailing slash, ensure format)
    clean_doi = doi.strip().rstrip('/')
    
    results.append({
        'num': num,
        'doi': clean_doi,
        'doi_url': f'https://doi.org/{clean_doi}',
        'first_author': first_author,
        'is_open_access': is_oa,
        'full_text_available': full_text_available,
        'method': method,
        'download_url': download_url,
        'landing_url': oa_landing
    })
    
    time.sleep(1.1)

# Write CSV
with open(f"{BASE}\\NHB_DOWNLOAD_STATUS.csv", 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['num', 'doi', 'doi_url', 'first_author', 'is_open_access', 'full_text_available', 'method', 'download_url', 'landing_url'])
    writer.writeheader()
    for r in results:
        writer.writerow(r)

# Summary
total = len(results)
oa = sum(1 for r in results if r['is_open_access'])
available = sum(1 for r in results if r['full_text_available'])
print(f"Total: {total}")
print(f"Open Access: {oa}")
print(f"Full text available: {available}")
print(f"Not available: {total - available}")

# List available papers
print("\n=== FULL TEXT AVAILABLE ===")
for r in results:
    if r['full_text_available']:
        print(f"  {r['num']} - {r['first_author']} - {r['doi_url']}")
        print(f"    Method: {r['method']}")
        print(f"    URL: {r['download_url']}")
