import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
with pdfplumber.open(pdfpath) as pdf:
    page = pdf.pages[8]
    chars = page.chars
    sel = [c for c in chars if c['top']>=286 and c['bottom']<=320 and c['x0']>=40 and c['x1']<=560 and c['text'].strip()]
    sel.sort(key=lambda c:(round(c['top']),c['x0']))
    line=""
    for c in sel: line+=c['text']
    print(repr(line))
    # Table 3 is on subsequent page; find its interaction row
    page3 = pdf.pages[9]
    words = page3.extract_words()
    for w in words:
        if w['text'] in ('0.87','0.86','0.76','0.66','1.23','1.50','1.57','0.53') or 'M/Fratio' in w['text']:
            print("T3", w)
