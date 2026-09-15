import pdfplumber, warnings, sys
warnings.filterwarnings("ignore")
args = sys.argv[1:]
for i in range(0, len(args), 2):
    path, out = args[i], args[i+1]
    try:
        pdf = pdfplumber.open(path)
        txt = "\n\n=====PAGE=====\n\n".join((p.extract_text() or "") for p in pdf.pages)
        with open(out, "w", encoding="utf-8") as f:
            f.write(txt)
        print("OK", out, len(pdf.pages), len(txt))
    except Exception as e:
        print("ERR", path, repr(e))
