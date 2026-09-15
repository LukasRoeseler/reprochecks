import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
with pdfplumber.open(pdfpath) as pdf:
    pg = pdf.pages[12]
    words = pg.extract_words()
    # table region likely top half; print first 90 words sorted by top then x0
    tab = [w for w in words if w['top'] < 620]
    tab.sort(key=lambda w:(round(w['top']),w['x0']))
    for w in tab[:120]:
        print(round(w['top'],1), round(w['x0'],1), repr(w['text']))
