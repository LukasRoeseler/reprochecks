import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
with pdfplumber.open(pdfpath) as pdf:
    page = pdf.pages[8]
    chars = page.chars
    # interaction row near y top ~296 (word level). Extract chars in band
    for (label, y0, y1, x0, x1) in [("row1",86,116,40,300),("row2",286,320,40,300)]:
        sel = [c for c in chars if c['top']>=y0 and c['bottom']<=y1 and c['x0']>=x0 and c['x1']<=x1 and c['text'].strip()]
        sel.sort(key=lambda c:(round(c['top']),c['x0']))
        print("###", label)
        line=""
        for c in sel:
            line += c['text']
        print(repr(line))
