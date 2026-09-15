import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
with pdfplumber.open(pdfpath) as pdf:
    for pi in range(9,14):
        pg = pdf.pages[pi]
        words = pg.extract_words()
        hit = [w for w in words if w['text'] in ('2.962','1.520','1.496','ChristianDem','Green/New','Votechange','SocialDem','Cabinetparty')]
        if hit:
            print("page", pi)
            for w in hit: print("  ", round(w['top'],1), repr(w['text']))
