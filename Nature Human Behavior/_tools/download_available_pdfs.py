import urllib.request, csv, os, time

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(f"{BASE}\\NHB_DOWNLOAD_STATUS.csv", encoding="utf-8") as f:
    results = list(csv.DictReader(f))

downloaded = 0
failed = 0

for r in results:
    if r['full_text_available'] != 'True':
        continue
    
    num = r['num']
    year = num[:4]
    first_author = r['first_author']
    url = r['download_url']
    
    # Find paper directory
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    # Find the directory matching this num
    target_dir = None
    for d in os.listdir(vol_dir):
        if d.startswith(num + '_'):
            target_dir = os.path.join(vol_dir, d)
            break
    
    if not target_dir:
        print(f"  SKIP {num}: directory not found")
        continue
    
    pdf_path = os.path.join(target_dir, 'fulltext.pdf')
    
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        response = urllib.request.urlopen(req, timeout=30)
        with open(pdf_path, 'wb') as f:
            f.write(response.read())
        downloaded += 1
        print(f"  DOWNLOADED {num} ({first_author}) -> {pdf_path}")
    except Exception as e:
        failed += 1
        print(f"  FAILED {num} ({first_author}): {str(e)[:50]}")
    
    time.sleep(1)

print(f"\nDownloaded: {downloaded}, Failed: {failed}")
