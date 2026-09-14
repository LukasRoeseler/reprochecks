import os, glob, pdfplumber, sys
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)"
for d in sorted(os.listdir(base)):
    pdf = os.path.join(base, d, "paper.pdf")
    if not os.path.isfile(pdf): 
        continue
    out = os.path.join(base, d, "paper_extracted.txt")
    try:
        with pdfplumber.open(pdf) as p:
            n = len(p.pages)
            text = "\n".join((pg.extract_text() or "") for pg in p.pages)
        with open(out, "w", encoding="utf-8") as f:
            f.write(text)
        print("{0}  pages={1}  chars={2}".format(d, n, len(text)))
    except Exception as e:
        print("{0}  ERROR {1}".format(d, e))
