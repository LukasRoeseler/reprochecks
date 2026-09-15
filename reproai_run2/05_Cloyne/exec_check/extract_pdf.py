import sys
from pdfminer.high_level import extract_text

src = sys.argv[1]
dst = sys.argv[2]
txt = extract_text(src)
with open(dst, "w", encoding="utf-8") as f:
    f.write(txt)
print("PAGES_CHARS", len(txt))
