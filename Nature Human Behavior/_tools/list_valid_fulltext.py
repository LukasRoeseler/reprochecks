import os, csv

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(f"{BASE}\\NHB_MASTER_CLASSIFICATION.csv", encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

# Find all papers with valid fulltext.pdf
valid_papers = []
for year in ['2019', '2020']:
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    for d in os.listdir(vol_dir):
        pdf_path = os.path.join(vol_dir, d, 'fulltext.pdf')
        if os.path.exists(pdf_path):
            # Verify it's a real PDF
            with open(pdf_path, 'rb') as f:
                header = f.read(5)
            if header == b'%PDF-':
                num = d.split('_')[0]
                cls = classification.get(num, {}).get('classification', 'Unknown')
                valid_papers.append({
                    'num': num,
                    'year': year,
                    'dir': d,
                    'path': pdf_path,
                    'classification': cls
                })

print(f"Valid fulltext.pdf files: {len(valid_papers)}")
print(f"  Empirical: {sum(1 for p in valid_papers if p['classification'] == 'EMPIRICAL')}")
print(f"  Non-empirical: {sum(1 for p in valid_papers if p['classification'] != 'EMPIRICAL')}")

print("\n=== PAPERS WITH FULL TEXT ===")
for p in valid_papers:
    status = "AUDIT" if p['classification'] == 'EMPIRICAL' else "SKIP"
    print(f"  {p['num']} - {p['dir']} - {p['classification']} [{status}]")
