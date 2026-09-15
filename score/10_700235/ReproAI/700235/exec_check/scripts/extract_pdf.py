import pdfplumber, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
pdf = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\paper.pdf"
outp = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\ReproAI\700235\exec_check\output"
with pdfplumber.open(pdf) as pdfdoc:
    print("NPAGES", len(pdfdoc.pages))
    # find pages containing 'TABLE 3' or text of table 3/4
    for i, page in enumerate(pdfdoc.pages):
        txt = page.extract_text() or ""
        if ("TABLE 3" in txt.upper()) or ("Long-Run Estimates" in txt) or ("ELBAT" in txt) or ("setamitsEnuR-gnoL" in txt):
            print("=== TABLE MARKER PAGE", i, "===")
            with open(outp + "\\page_%03d.txt" % i, "w", encoding="utf-8") as f:
                f.write(txt)
