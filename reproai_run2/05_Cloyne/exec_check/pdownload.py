import time, urllib.parse
from playwright.sync_api import sync_playwright

BASE = "https://www.openicpsr.org"
FILES = ["data.xlsx","Table2.m","Figures3to9.m","Figure1and2.m","Figure10.m","table1.wf1","ReadMe.pdf","LICENSE.txt"]
outdir = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check\icpsr"

import os
os.makedirs(outdir, exist_ok=True)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    ctx = browser.new_context(user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    page = ctx.new_page()
    # establish session & pass cloudflare
    page.goto(BASE + "/openicpsr/project/112651/version/V1/view", wait_until="domcontentloaded", timeout=60000)
    for i in range(25):
        t = page.title()
        if "moment" not in t.lower() and "bot" not in t.lower() and t.strip():
            break
        time.sleep(2)
    page.wait_for_timeout(2000)
    print("SESSION TITLE:", page.title())

    for fn in FILES:
        path = "/openicpsr/112651/fcr:versions/V1/20111351_data/" + fn
        url = BASE + "/openicpsr/project/112651/version/V1/download?path=" + urllib.parse.quote(path, safe="/") + "&type=file"
        try:
            resp = ctx.request.get(url, timeout=120000)
            body = resp.body()
            ct = resp.headers.get("content-type","")
            print(fn, "status", resp.status, "len", len(body), "ct", ct)
            # save if it's a real file (zip or binary), skip HTML
            head = body[:4]
            is_html = head in (b"<!DO", b"<htm")
            if resp.status == 200 and len(body) > 200 and not is_html:
                open(os.path.join(outdir, fn), "wb").write(body)
                print("   SAVED", fn)
            else:
                print("   NOT FILE:", body[:120])
        except Exception as e:
            print(fn, "ERR", repr(e)[:200])
        time.sleep(1)
    browser.close()
