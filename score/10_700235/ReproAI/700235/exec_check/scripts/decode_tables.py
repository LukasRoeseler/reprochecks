import io, sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
base = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\10_700235\ReproAI\700235\exec_check\output"
for pg in [21, 22]:
    print("="*30, "DECODED PAGE", pg, "="*30)
    with open(base + "\\page_%03d.txt" % pg, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            if not line.strip():
                print()
                continue
            print(line[::-1])
