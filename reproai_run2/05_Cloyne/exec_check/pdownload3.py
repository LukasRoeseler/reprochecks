import time, urllib.parse, os
from playwright.sync_api import sync_playwright

BASE = "https://www.openicpsr.org"
FILES = ["data.xlsx","Table2.m","Figures3to9.m","Figure1and2.m","Figure10.m","table1.wf1","ReadMe.pdf"]
outdir = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check\icpsr"
os.makedirs(outdir, exist_ok=True)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    ctx = browser.new_context(accept_downloads=True, user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    page = ctx.new_page()
    page.goto(BASE + "/openicpsr/project/112651/version/V1/view", wait_until="domcontentloaded", timeout=60000)
    for i in range(25):
        t = page.title()
        if "moment" not in t.lower() and "bot" not in t.lower() and t.strip():
            break
        time.sleep(2)
    page.wait_for_timeout(1500)
    print("SESSION TITLE:", page.title())

    for fn in FILES:
        path = "/openicpsr/112651/fcr:versions/V1/20111351_data/" + fn
        url = BASE + "/openicpsr/project/112651/version/V1/download?path=" + urllib.parse.quote(path, safe="/") + "&type=file"
        target = os.path.join(outdir, fn)
        try:
            with page.expect_download(timeout=60000) as dd_info:
                page.evaluate("u => { window.location.href = u }", url)
            dl = dd_info.value
            dl.save_as(target)
            print("SAVED", fn, os.path.getsize(target), "bytes")
        except Exception as e:
            print(fn, "ERR", repr(e)[:200])
            # page may have navigated away; go back
            try: page.goto(BASE + "/openicpsr/project/112651/version/V1/view", timeout=30000)
            except: pass
            time.sleep(2)
        time.sleep(1)
    browser.close()

