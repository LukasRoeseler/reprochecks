from pdfminer.high_level import extract_text
t = extract_text(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\I4R ReproAI Checks\15_aer.20161385\paper.pdf")
open("pdfminer_full.txt","w",encoding="utf-8").write(t)
print("len", len(t))
# Find Table 3 region
i = t.find("Table 3")
print("first Table 3 at", i)
