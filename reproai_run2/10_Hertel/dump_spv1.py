import os
d = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\10_Hertel\spv_extract"
for name in ["00000000011_lightNotesData.bin","00000000012_lightTableData.bin","00000000013_lightTableData.bin",
             "00000000014_lightTableData.bin","00000000015_lightTableData.bin","00000000016_lightTableData.bin",
             "00000000017_lightTableData.bin","00000000018_lightTableData.bin"]:
    fp=os.path.join(d,name)
    raw=open(fp,"rb").read()
    txt=raw.decode("utf-8",errors="replace")
    import re
    txt=re.sub(r"[^\x20-\x7e]","",txt)
    print("="*30, name)
    print(txt)
