import requests, urllib.parse, sys

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
}

base = "https://www.openicpsr.org"
path = "/openicpsr/112651/fcr:versions/V1/20111351_data/data.xlsx"
url = base + "/openicpsr/project/112651/version/V1/download?path=" + urllib.parse.quote(path, safe="/:&=") + "&type=file"
print("URL:", url)
s = requests.Session()
try:
    r = s.get(url, headers=headers, timeout=120, allow_redirects=True)
    print("status", r.status_code, "len", len(r.content), "ctype", r.headers.get("Content-Type"))
    if r.status_code == 200 and len(r.content) > 5000 and not r.content[:5].startswith(b"<!do") and not r.content[:5].startswith(b"<ht"):
        open(r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check\data.xlsx", "wb").write(r.content)
        print("SAVED data.xlsx")
    else:
        print("Not a file; first bytes:", r.content[:200])
except Exception as e:
    print("ERR", e)
