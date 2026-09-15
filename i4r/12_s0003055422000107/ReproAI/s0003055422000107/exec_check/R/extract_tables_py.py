import pdfplumber
pdfpath = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\paper.pdf"
out = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\12_s0003055422000107\ReproAI\s0003055422000107\exec_check\output\paper_tables_extracted.txt"
with pdfplumber.open(pdfpath) as pdf:
    lines_all = []
    for i, page in enumerate(pdf.pages):
        t = page.extract_text() or ""
        txt = t.replace("\n", " | ")
        lines_all.append(f"=== PAGE {i+1} (pdf index) ===\n{txt}\n")
    with open(out, "w", encoding="utf-8") as f:
        f.writelines(lines_all)
print("done, pages:", len(pdf.pages))
