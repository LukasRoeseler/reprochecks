import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
with pdfplumber.open(pdfpath) as pdf:
    # find page containing "TABLE 3"
    for pi,p in enumerate(pdf.pages):
        t = p.extract_text() or ""
        if "TABLE 3" in t.upper() or "Determinants of Women" in t and "Party Family" in t:
            print("Table3 page idx:", pi)
            pg = p
            break
    words = pg.extract_words()
    # print words near interaction region (look for 'Votechange' and M/F)
    for w in words:
        txt = w['text']
        if 'M/F' in txt or 'Votechange' in txt or txt in ('ChristianDem','Conservative','Green/NewLeft','Liberal','SocialDem'):
            print(round(w['top'],1), round(w['x0'],1), repr(txt))
