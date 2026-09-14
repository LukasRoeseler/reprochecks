import csv, os, subprocess, sys, re, time

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"
INVENTORY = os.path.join(BASE, "ARTICLE_INVENTORY.csv")

with open(INVENTORY, encoding="utf-8") as f:
    rows = list(csv.DictReader(f))

start = int(sys.argv[1]) if len(sys.argv) > 1 else 0
end = int(sys.argv[2]) if len(sys.argv) > 2 else len(rows)

def clean_html(text):
    text = re.sub(r'<script[^>]*>.*?</script>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<style[^>]*>.*?</style>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<svg[^>]*>.*?</svg>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<nav[^>]*>.*?</nav>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<header[^>]*>.*?</header>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<footer[^>]*>.*?</footer>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<aside[^>]*>.*?</aside>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<form[^>]*>.*?</form>', ' ', text, flags=re.DOTALL)
    text = re.sub(r'<table[^>]*>.*?</table>', ' [TABLE] ', text, flags=re.DOTALL)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'&amp;', '&', text)
    text = re.sub(r'&lt;', '<', text)
    text = re.sub(r'&gt;', '>', text)
    text = re.sub(r'&quot;', '"', text)
    text = re.sub(r'&#39;', "'", text)
    text = re.sub(r'&nbsp;', ' ', text)
    text = re.sub(r'&mdash;', '—', text)
    text = re.sub(r'&ndash;', '–', text)
    text = re.sub(r'&ldquo;', '"', text)
    text = re.sub(r'&rdquo;', '"', text)
    text = re.sub(r'&hellip;', '…', text)
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\n\s*\n+', '\n\n', text)
    return text.strip()

def extract_article(html):
    # Find the main article content
    # Try to find the <main> element
    main_match = re.search(r'<main[^>]*class="[^"]*c-article-main-column[^"]*"[^>]*>(.*?)</main>', html, re.DOTALL)
    if main_match:
        content = main_match.group(1)
    else:
        # Try article tag
        art_match = re.search(r'<article[^>]*>(.*?)</article>', html, re.DOTALL)
        if art_match:
            content = art_match.group(1)
        else:
            content = html
    
    # Remove header
    content = re.sub(r'<div[^>]*class="[^"]*c-article-header[^"]*"[^>]*>.*?</div>', ' ', content, flags=re.DOTALL)
    
    # Extract sections
    sections = []
    
    # Title
    title_match = re.search(r'<h1[^>]*class="[^"]*c-article-title[^"]*"[^>]*>(.*?)</h1>', content, re.DOTALL)
    if title_match:
        title = clean_html(title_match.group(1))
        sections.append(f"# {title}\n")
    
    # Abstract
    abs_match = re.search(r'<div[^>]*class="[^"]*c-article-editorial-summary[^"]*"[^>]*>(.*?)</div>\s*</div>', content, re.DOTALL)
    if not abs_match:
        abs_match = re.search(r'<h2[^>]*>Abstract</h2>(.*?)(?=<h2|</article>)', content, re.DOTALL)
    if abs_match:
        abs_text = clean_html(abs_match.group(1))
        if abs_text.strip():
            sections.append(f"## Abstract\n{abs_text}\n")
    
    # Find all sections with data-title
    for sec_match in re.finditer(r'<section[^>]*data-title="([^"]*)"[^>]*>(.*?)</section>', content, re.DOTALL):
        sec_title = sec_match.group(1)
        sec_content = sec_match.group(2)
        # Remove nested section headers
        sec_text = clean_html(sec_content)
        if sec_text.strip() and len(sec_text.strip()) > 50:
            sections.append(f"## {sec_title}\n{sec_text}\n")
    
    # If no sections found, try h2-based extraction
    if len(sections) <= 1:
        h2_parts = re.split(r'<h2[^>]*class="[^"]*c-article-section__title[^"]*"[^>]*>(.*?)</h2>', content)
        if len(h2_parts) > 1:
            for i in range(1, len(h2_parts), 2):
                sec_title = clean_html(h2_parts[i])
                sec_content = h2_parts[i+1] if i+1 < len(h2_parts) else ''
                sec_text = clean_html(sec_content)
                if sec_text.strip() and len(sec_text.strip()) > 50:
                    sections.append(f"## {sec_title}\n{sec_text}\n")
    
    result = '\n'.join(sections)
    return result

done = 0
failed = 0

for i in range(start, end):
    row = rows[i]
    num = row["num"]
    year = row["year"]
    first = row["first_author"]
    article_id = row["article_id"]
    url = row["url"]

    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    slug = f"{num}_{first}".replace(" ", "")
    paper_dir = os.path.join(vol_dir, slug)
    os.makedirs(paper_dir, exist_ok=True)

    html_path = os.path.join(paper_dir, "paper.html")
    txt_path = os.path.join(paper_dir, "paper_extracted.txt")

    if os.path.exists(txt_path) and os.path.getsize(txt_path) > 1000:
        print(f"[{num}] Text exists, skipping")
        done += 1
        continue

    print(f"[{num}] Fetching {url}")
    try:
        result = subprocess.run(
            ["curl.exe", "-L", "-s", "--max-time", "120",
             "-H", "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
             "-H", "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
             "-H", "Accept-Language: en-US,en;q=0.9",
             url],
            timeout=130,
            capture_output=True
        )
        html = result.stdout.decode('utf-8', errors='replace')
        
        if len(html) < 5000:
            print(f"[{num}] FAILED (HTML too small: {len(html)})")
            failed += 1
            continue
        
        with open(html_path, "w", encoding="utf-8") as f:
            f.write(html)
        
        text = extract_article(html)
        
        if len(text) < 500:
            print(f"[{num}] Extraction yielded too little text: {len(text)}")
            failed += 1
            continue
        
        with open(txt_path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"[{num}] OK ({len(html)} HTML, {len(text)} text chars)")
        done += 1
    except Exception as e:
        print(f"[{num}] ERROR: {e}")
        failed += 1
        continue
    
    time.sleep(1)

print(f"\nDone: {done}, Failed: {failed}")
