import pdfplumber, io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
pdf = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\paper.pdf"
pages = [int(a) for a in sys.argv[1:]]
with pdfplumber.open(pdf) as pdfdoc:
    for i in pages:
        page = pdfdoc.pages[i]
        words = page.extract_words()
        rows = {}
        for w in words:
            rows.setdefault(round(w["top"]/4), []).append(w)
        print("="*40, "PDF PAGE", i, "="*40)
        for key in sorted(rows):
            ws = sorted(rows[key], key=lambda w: w["x0"])
            for w in ws:
                if w["x0"] > 180:
                    print("  t%04d x%5.0f %r" % (key, w["x0"], w["text"]))
