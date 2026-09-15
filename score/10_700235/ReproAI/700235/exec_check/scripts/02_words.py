import pdfplumber, io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
pdf = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\paper.pdf"
pages = [int(a) for a in sys.argv[1:]]
with pdfplumber.open(pdf) as pdfdoc:
    for i in pages:
        page = pdfdoc.pages[i]
        words = page.extract_words(use_text_flow=False, keep_blank_chars=False)
        # group by top
        rows = {}
        for w in words:
            key = round(w["top"]/4)
            rows.setdefault(key, []).append(w)
        print("="*40, "PDF PAGE", i, "npages", len(pdfdoc.pages), "="*40)
        for key in sorted(rows):
            ws = sorted(rows[key], key=lambda w: w["x0"])
            line = " | ".join(w["text"] for w in ws)
            print("%6d [x%5.0f] %s" % (int(key), ws[0]["x0"], line))
