import sys, os, glob
import pdfplumber

def extract(path, outdir):
    text_pages = []
    with pdfplumber.open(path) as pdf:
        npages = len(pdf.pages)
        for i, page in enumerate(pdf.pages):
            t = page.extract_text() or ""
            text_pages.append(f"\n===== PAGE {i+1}/{npages} =====\n" + t)
    full = "\n".join(text_pages)
    base = os.path.splitext(os.path.basename(path))[0]
    out = os.path.join(outdir, base + "_extracted.txt")
    with open(out, "w", encoding="utf-8") as f:
        f.write(full)
    return out, len(text_pages)

if __name__ == "__main__":
    pdf = sys.argv[1]
    outdir = sys.argv[2]
    p, n = extract(pdf, outdir)
    print(f"Extracted {n} pages -> {p}")
