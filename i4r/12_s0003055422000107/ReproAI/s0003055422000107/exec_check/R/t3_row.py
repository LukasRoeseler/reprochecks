import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
with pdfplumber.open(pdfpath) as pdf:
    pg = pdf.pages[12]
    chars = pg.chars
    # scan row bands of 24pt each between top 520 and 610, dump chars per band in x>=40
    for (y0,y1) in [(520,545),(545,572),(572,600),(600,625)]:
        sel=[c for c in chars if c['top']>=y0 and c['bottom']<=y1 and c['x0']>=40 and c['x1']<=560 and c['text'].strip()]
        sel.sort(key=lambda c:(round(c['top']),c['x0']))
        print("### band",y0,y1)
        line="".join(c['text'] for c in sel)
        print(repr(line))
