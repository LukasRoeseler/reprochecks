import pdfplumber, io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
pdf = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\paper.pdf"
with pdfplumber.open(pdf) as pdfdoc:
    print("NPAGES", len(pdfdoc.pages))
    for i, page in enumerate(pdfdoc.pages):
        txt = (page.extract_text() or "").upper()
        tags = []
        for t in ["TABLE 1", "TABLE 2", "TABLE 3", "TABLE 4", "FIG. 1", "FIG. 2", "FIG. 3", "FIG. 4"]:
            if t in txt.replace(" ",""):
                tags.append(t)
        if tags:
            print(i, page.width, page.height, tags)
