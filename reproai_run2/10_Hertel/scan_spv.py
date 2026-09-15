import os, glob
d = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\10_Hertel\spv_extract"
hits = {}
for fp in glob.glob(os.path.join(d, "*.bin")) + glob.glob(os.path.join(d, "*.xml")):
    base = os.path.basename(fp)
    try:
        raw = open(fp, "rb").read()
    except Exception:
        continue
    for enc in ("utf-16-le", "utf-8", "latin-1"):
        try:
            txt = raw.decode(enc, errors="replace")
        except Exception:
            continue
        if ("746" in txt) or ("6.20" in txt) or ("GLM" in txt.upper()) or ("Suppress" in txt) or ("FAsupp" in txt):
            hits.setdefault(base, []).append(enc)
for k, v in sorted(hits.items()):
    print(k, sorted(set(v)))
