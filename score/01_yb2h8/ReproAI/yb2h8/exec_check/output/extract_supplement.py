from pdfminer.high_level import extract_text
src = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\01_yb2h8\ReproAI\yb2h8\exec_check\output\jcm-09-03350-s001_supplement.pdf"
txt = extract_text(src)
open(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\01_yb2h8\ReproAI\yb2h8\exec_check\output\supplement_extracted.txt","w",encoding="utf-8").write(txt)
print("pages? chars:", len(txt))
