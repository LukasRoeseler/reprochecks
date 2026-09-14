import urllib.request, json, csv, time

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"
EMAIL = "lroesele@ivv5net.de"

with open(f"{BASE}\\ARTICLE_INVENTORY.csv", encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

results = []
for i, row in enumerate(inventory):
    doi = row['doi']
    if not doi:
        continue
    
    try:
        url = f"https://api.unpaywall.org/v2/{doi}?email={EMAIL}"
        req = urllib.request.Request(url)
        response = urllib.request.urlopen(req, timeout=15)
        data = json.loads(response.read())
        
        is_oa = data.get('is_oa', False)
        loc = data.get('best_oa_location') or {}
        pdf_url = loc.get('url_for_pdf', '')
        landing_url = loc.get('url_for_landing_page', '')
        oa_status = data.get('oa_status', '')
        
        results.append({
            'num': row['num'],
            'doi': doi,
            'first_author': row['first_author'],
            'title': row.get('title', row['first_author'])[:60],
            'is_oa': is_oa,
            'oa_status': oa_status,
            'pdf_url': pdf_url,
            'landing_url': landing_url
        })
        
        # Rate limit: 1 request per second
        if i < len(inventory) - 1:
            time.sleep(1.1)
            
    except Exception as e:
        results.append({
            'num': row['num'],
            'doi': doi,
            'first_author': row['first_author'],
            'title': row.get('title', row['first_author'])[:60],
            'is_oa': 'error',
            'oa_status': str(e)[:50],
            'pdf_url': '',
            'landing_url': ''
        })
        time.sleep(2)

# Write output
with open(f"{BASE}\\NHB_DOI_STATUS.csv", 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['num', 'doi', 'first_author', 'title', 'is_oa', 'oa_status', 'pdf_url', 'landing_url'])
    writer.writeheader()
    for r in results:
        writer.writerow(r)

# Summary
oa_count = sum(1 for r in results if r['is_oa'] == True)
not_oa = sum(1 for r in results if r['is_oa'] == False)
errors = sum(1 for r in results if r['is_oa'] == 'error')

print(f"Total: {len(results)}")
print(f"Open Access: {oa_count}")
print(f"Not Open Access: {not_oa}")
print(f"Errors: {errors}")

# List OA papers
print("\nOpen Access papers:")
for r in results:
    if r['is_oa'] == True:
        print(f"  {r['num']} - {r['first_author']} - {r['title'][:40]}")
        print(f"    PDF: {r['pdf_url']}")
