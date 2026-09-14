import os, re, json, csv

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

# Load classification
with open(f"{BASE}\\NHB_MASTER_CLASSIFICATION.csv", encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

# Find all papers with fulltext.pdf
fulltext_papers = []
for year in ['2019', '2020']:
    vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
    for d in os.listdir(vol_dir):
        pdf_path = os.path.join(vol_dir, d, 'fulltext.pdf')
        if os.path.exists(pdf_path):
            # Extract num from directory name
            num = d.split('_')[0]
            cls = classification.get(num, {}).get('classification', 'Unknown')
            fulltext_papers.append({
                'num': num,
                'year': year,
                'dir': d,
                'path': pdf_path,
                'classification': cls,
                'size': os.path.getsize(pdf_path)
            })

print(f"Papers with fulltext.pdf: {len(fulltext_papers)}")
print(f"  Empirical: {sum(1 for p in fulltext_papers if p['classification'] == 'EMPIRICAL')}")
print(f"  Non-empirical: {sum(1 for p in fulltext_papers if p['classification'] != 'EMPIRICAL')}")

# Extract text from PDFs (simple extraction)
def extract_pdf_text(pdf_path):
    """Simple PDF text extraction using basic regex"""
    try:
        with open(pdf_path, 'rb') as f:
            content = f.read()
        
        # Check if it's actually a PDF
        if not content.startswith(b'%PDF'):
            return ''
        
        # Try to extract text between BT and ET markers
        text_parts = []
        # Find all text objects
        matches = re.findall(rb'\((.*?)\)\s*Tj', content)
        for match in matches:
            try:
                text_parts.append(match.decode('latin-1'))
            except:
                pass
        
        if text_parts:
            return ' '.join(text_parts)
        
        # Try another pattern
        matches = re.findall(rb'\[(.*?)\]\s*TJ', content)
        for match in matches:
            try:
                # Extract strings from array
                strings = re.findall(rb'\((.*?)\)', match)
                for s in strings:
                    text_parts.append(s.decode('latin-1'))
            except:
                pass
        
        return ' '.join(text_parts)
    except Exception as e:
        return f'Error: {str(e)}'

# Extract text for empirical papers
empirical_with_text = []
for p in fulltext_papers:
    if p['classification'] != 'EMPIRICAL':
        continue
    
    text = extract_pdf_text(p['path'])
    p['text_length'] = len(text)
    p['has_text'] = len(text) > 1000
    
    # Save extracted text
    txt_path = os.path.join(os.path.dirname(p['path']), 'fulltext_extracted.txt')
    with open(txt_path, 'w', encoding='utf-8') as f:
        f.write(text)
    
    if p['has_text']:
        empirical_with_text.append(p)

print(f"\nEmpirical papers with extractable text: {len(empirical_with_text)}")
for p in empirical_with_text:
    print(f"  {p['num']} - {p['dir']} - {p['text_length']} chars")
