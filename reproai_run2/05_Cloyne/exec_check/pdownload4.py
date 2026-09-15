import time, urllib.parse, os, sys
from playwright.sync_api import sync_playwright

BASE = "https://www.openicpsr.org"
FILES = ["data.xlsx","Table2.m","Figures3to9.m","Figure1and2.m","Figure10.m","table1.wf1","ReadMe.pdf"]
outdir = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check\icpsr"
os.makedirs(outdir, exist_ok=True)

def log(m):
    print(m, flush=True)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    ctx = browser.new_context(user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    page = ctx.new_page()
    page.goto(BASE + "/openicpsr/project/112651/version/V1/view", wait_until="domcontentloaded", timeout=60000)
    for i in range(25):
        t = page.title()
        if "moment" not in t.lower() and "bot" not in t.lower() and t.strip():
            break
        time.sleep(2)
    page.wait_for_timeout(2000)
    log("SESSION TITLE: " + page.title())

    for fn in FILES:
        path = "/openicpsr/112651/fcr:versions/V1/20111351_data/" + fn
        url = BASE + "/openicpsr/project/112651/version/V1/download?path=" + urllib.parse.quote(path, safe="/") + "&type=file"
        target = os.path.join(outdir, fn)
        try:
            resp = page.goto(url, wait_until="load", timeout=45000)
            body = resp.body()
            head = body[:8]
            log("%s status=%s len=%d head=%s" % (fn, resp.status, len(body), head))
            if resp.status == 200 and not head in (b"<!DOCTYP", b"<html", b"<!doctyp") and len(body) > 100:
                open(target, "wb").write(body)
                log("   SAVED " + fn)
            else:
                log("   NOT FILE (first 90): " + repr(body[:90]))
        except Exception as e:
            log(fn + " ERR " + repr(e)[:150])
        # back to a stable CF-cleared page
        try:
            page.goto(BASE + "/openicpsr/project/112651/version/V1/view", timeout=30000)
        except Exception:
            pass
        time.sleep(2)
    browser.close()
