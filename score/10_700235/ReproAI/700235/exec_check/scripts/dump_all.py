import pdfplumber, io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
pdf = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\paper.pdf"
outp = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\ReproAI\700235\exec_check\output"
with pdfplumber.open(pdf) as pdfdoc:
    for i, page in enumerate(pdfdoc.pages):
        txt = page.extract_text() or ""
        with open(outp + "\\all_%03d.txt" % i, "w", encoding="utf-8") as f:
            f.write(txt)
print("done", len(pdfdoc.pages))
