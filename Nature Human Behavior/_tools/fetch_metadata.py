import csv, os, subprocess, sys, json, time, re

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"
INVENTORY = os.path.join(BASE, "ARTICLE_INVENTORY.csv")

with open(INVENTORY, encoding="utf-8") as f:
    rows = list(csv.DictReader(f))

start = int(sys.argv[1]) if len(sys.argv) > 1 else 0
end = int(sys.argv[2]) if len(sys.argv) > 2 else len(rows)

def fetch_url(url, timeout=130):
    result = subprocess.run(
        ["curl.exe", "-L", "-s", "--max-time", str(timeout),
         "-H", "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
         "-H", "Accept: application/json,text/html,*/*;q=0.8",
         "-H", "Accept-Language: en-US,en;q=0.9",
         url],
        timeout=timeout+10,
        capture_output=True
    )
    return result.stdout.decode('utf-8', errors='replace')

def clean_html(text):
    text = re.sub(r'<script[^>]*>.*?</script>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<style[^>]*>.*?</style>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<svg[^>]*>.*?</svg>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'&amp;', '&', text)
    text = re.sub(r'&lt;', '<', text)
    text = re.sub(r'&gt;', '>', text)
    text = re.sub(r'&quot;', '"', text)
    text = re.sub(r'&#39;', "'", text)
    text = re.sub(r'&nbsp;', ' ', text)
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\n\s*\n+', '\n\n', text)
    return text.strip()

def extract_abstract_and_metadata(html):
    """Extract abstract and key metadata from NHB article page"""
    meta = {}
    
    # Title
    title_match = re.search(r'<h1[^>]*class="[^"]*c-article-title[^"]*"[^>]*>(.*?)</h1>', html, re.DOTALL)
    if title_match:
        meta['title'] = clean_html(title_match.group(1))
    
    # Authors
    authors = re.findall(r'<span[^>]*class="[^"]*c-article-author-list__item[^"]*"[^>]*>(.*?)</span>', html, re.DOTALL)
    if authors:
        meta['authors'] = [clean_html(a) for a in authors]
    
    # Abstract
    abs_match = re.search(r'<div[^>]*class="[^"]*c-article-editorial-summary__content[^"]*"[^>]*>(.*?)</div>', html, re.DOTALL)
    if not abs_match:
        abs_match = re.search(r'<h2[^>]*id="Abs1-content"[^>]*>.*?</h2>\s*(.*?)(?=<h2|</div>\s*</div>\s*</div>)', html, re.DOTALL)
    if not abs_match:
        abs_match = re.search(r'Abstract</h2>(.*?)(?=<h2|<section)', html, re.DOTALL)
    if abs_match:
        meta['abstract'] = clean_html(abs_match.group(1))
    
    # Data availability
    da_match = re.search(r'<h2[^>]*data-title="Data availability"[^>]*>(.*?)(?=<h2|</section>)', html, re.DOTALL)
    if da_match:
        meta['data_availability'] = clean_html(da_match.group(1))
    
    # Code availability
    ca_match = re.search(r'<h2[^>]*data-title="Code availability"[^>]*>(.*?)(?=<h2|</section>)', html, re.DOTALL)
    if ca_match:
        meta['code_availability'] = clean_html(ca_match.group(1))
    
    # Supplementary information links
    supp_links = re.findall(r'href="(https://media\.springernature\.com/original/springer-static/esm/[^"]+)"', html)
    meta['supplementary_links'] = supp_links
    
    # OSF links
    osf_links = re.findall(r'https://osf\.io/[a-zA-Z0-9]+', html)
    meta['osf_links'] = list(set(osf_links))
    
    # GitHub links
    gh_links = re.findall(r'https://github\.com/[^<\s"]+', html)
    meta['github_links'] = list(set(gh_links))
    
    # Zenodo links
    zd_links = re.findall(r'https://zenodo\.org/[^<\s"]+', html)
    meta['zenodo_links'] = list(set(zd_links))
    
    # Figureshare links
    fs_links = re.findall(r'https://figshare\.com/[^<\s"]+', html)
    meta['figshare_links'] = list(set(fs_links))
    
    # Is it open access?
    if 'open-access' in html.lower() or 'open access' in html.lower():
        meta['open_access'] = True
    else:
        meta['open_access'] = False
    
    return meta

def fetch_crossref(doi):
    """Fetch metadata from Crossref API"""
    url = f"https://api.crossref.org/works/{doi}"
    try:
        html = fetch_url(url)
        data = json.loads(html)
        return data.get('message', {})
    except:
        return {}

done = 0
failed = 0

for i in range(start, end):
    row = rows[i]
    num = row["num"]
    year = row["year"]
    first = row["first_author"]
    article_id = row["article_id"]
    doi = row["doi"]
    url = row["url"]

    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    slug = f"{num}_{first}".replace(" ", "")
    paper_dir = os.path.join(vol_dir, slug)
    os.makedirs(paper_dir, exist_ok=True)

    html_path = os.path.join(paper_dir, "paper.html")
    meta_path = os.path.join(paper_dir, "metadata.json")
    txt_path = os.path.join(paper_dir, "paper_extracted.txt")

    if os.path.exists(meta_path) and os.path.getsize(meta_path) > 100:
        print(f"[{num}] Metadata exists, skipping")
        done += 1
        continue

    print(f"[{num}] Fetching {url}")
    try:
        html = fetch_url(url)
        
        if len(html) < 5000:
            print(f"[{num}] FAILED (HTML too small: {len(html)})")
            failed += 1
            continue
        
        with open(html_path, "w", encoding="utf-8") as f:
            f.write(html)
        
        meta = extract_abstract_and_metadata(html)
        
        # Fetch Crossref for full metadata
        cr = fetch_crossref(doi)
        if cr:
            meta['crossref_title'] = cr.get('title', [''])[0] if cr.get('title') else ''
            meta['crossref_authors'] = [
                f"{a.get('given','')} {a.get('family','')}" 
                for a in cr.get('author', [])
            ]
            meta['crossref_doi'] = cr.get('DOI', '')
            meta['crossref_publisher'] = cr.get('publisher', '')
            meta['crossref_volume'] = cr.get('volume', '')
            meta['crossref_pages'] = cr.get('page', '')
            meta['crossref_issued'] = cr.get('issued', {}).get('date-parts', [[None]])[0]
            meta['crossref_type'] = cr.get('type', '')
            
            # Data/code availability from Crossref
            if cr.get('data-available'):
                meta['crossref_data_available'] = True
            if cr.get('code-available'):
                meta['crossref_code_available'] = True
        
        with open(meta_path, "w", encoding="utf-8") as f:
            json.dump(meta, f, indent=2, ensure_ascii=False)
        
        # Also write abstract text
        if meta.get('abstract'):
            with open(txt_path, "w", encoding="utf-8") as f:
                f.write(f"# {meta.get('title', 'Unknown Title')}\n\n")
                if meta.get('authors'):
                    f.write(f"Authors: {', '.join(meta['authors'])}\n\n")
                f.write(f"## Abstract\n{meta['abstract']}\n\n")
                if meta.get('data_availability'):
                    f.write(f"## Data Availability\n{meta['data_availability']}\n\n")
                if meta.get('code_availability'):
                    f.write(f"## Code Availability\n{meta['code_availability']}\n\n")
                if meta.get('osf_links'):
                    f.write(f"## OSF Links\n{chr(10).join(meta['osf_links'])}\n\n")
                if meta.get('github_links'):
                    f.write(f"## GitHub Links\n{chr(10).join(meta['github_links'])}\n\n")
                if meta.get('supplementary_links'):
                    f.write(f"## Supplementary Information\n{chr(10).join(meta['supplementary_links'])}\n\n")
        
        print(f"[{num}] OK (OA={meta.get('open_access', False)}, OSF={len(meta.get('osf_links',[]))}, GH={len(meta.get('github_links',[]))})")
        done += 1
    except Exception as e:
        print(f"[{num}] ERROR: {e}")
        failed += 1
        continue
    
    time.sleep(1)

print(f"\nDone: {done}, Failed: {failed}")
