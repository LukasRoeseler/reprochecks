import os, csv
import pdfplumber

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(f"{BASE}\\NHB_MASTER_CLASSIFICATION.csv", encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

# Find empirical papers with fulltext.pdf
fulltext_empirical = []
for year in ['2019', '2020']:
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    for d in os.listdir(vol_dir):
        pdf_path = os.path.join(vol_dir, d, 'fulltext.pdf')
        if os.path.exists(pdf_path):
            num = d.split('_')[0]
            cls = classification.get(num, {}).get('classification', 'Unknown')
            if cls == 'EMPIRICAL':
                fulltext_empirical.append({
                    'num': num,
                    'year': year,
                    'dir': d,
                    'path': pdf_path
                })

print(f"Empirical papers with fulltext.pdf: {len(fulltext_empirical)}")

# Extract text using pdfplumber
for p in fulltext_empirical:
    try:
        with pdfplumber.open(p['path']) as pdf:
            text_parts = []
            for page in pdf.pages:
                text = page.extract_text()
                if text:
                    text_parts.append(text)
            
            full_text = '\n'.join(text_parts)
            
            # Save extracted text
            txt_path = os.path.join(os.path.dirname(p['path']), 'fulltext_extracted.txt')
            with open(txt_path, 'w', encoding='utf-8') as f:
                f.write(full_text)
            
            p['text_length'] = len(full_text)
            p['has_text'] = len(full_text) > 1000
            print(f"  {p['num']} - {p['text_length']} chars - {'OK' if p['has_text'] else 'EMPTY'}")
            
    except Exception as e:
        p['text_length'] = 0
        p['has_text'] = False
        print(f"  {p['num']} - ERROR: {str(e)[:50]}")

# Save results
with open(f"{BASE}\\FULLTEXT_AVAILABLE.csv", 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['num', 'year', 'dir', 'text_length', 'has_text'])
    writer.writeheader()
    for p in fulltext_empirical:
        writer.writerow(p)

available = sum(1 for p in fulltext_empirical if p['has_text'])
print(f"\nTotal with extractable text: {available}")
