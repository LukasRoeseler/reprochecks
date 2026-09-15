import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
outdir = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\ReproAI\s0003055422000107\exec_check\output"
with pdfplumber.open(pdfpath) as pdf:
    page = pdf.pages[8]
    im = page.to_image(resolution=250)
    im.save(outdir + r"\table1_page.png")
    print("saved full page")
    # Try a tighter crop is hard without knowing coords; save words with coords near 'Votechange'
    words = page.extract_words()
    # find words matching interaction-like tokens
    for w in words:
        if w['text'] in ('0.368','0.668','0.667','0.760','0.868','0.371','0.38','0.18','0.31','0.30','0.319') or 'M/F' in w['text']:
            print(w)
