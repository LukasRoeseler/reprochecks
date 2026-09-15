import pdfplumber, io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
pdf = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\paper.pdf"
def norm(s):
    return (s or "").replace(" ","").replace("\n","")
with pdfplumber.open(pdf) as pdfdoc:
    for i, page in enumerate(pdfdoc.pages):
        txt = norm(page.extract_text())
        hi = txt.upper()
        tags=[]
        for t in ["TABLE1","TABLE2","TABLE3","TABLE4","INDICATORSOFNONELITECAPACITY","DESCRIPTIVESTATISTICS","LONG-RUNESTIMATES","LONG-RUNESTIMATE,POLITY2","LONG-RUNESTIMATES,ELECTORALDEMOCRACY","FIG.1","FIG.2"]:
            if t in hi:
                tags.append(t)
        if tags:
            print(i, tags)
