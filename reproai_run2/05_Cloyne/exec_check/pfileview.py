import time, urllib.parse, os
from playwright.sync_api import sync_playwright

BASE = "https://www.openicpsr.org"
outdir = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check\icpsr"
os.makedirs(outdir, exist_ok=True)
fn = "data.xlsx"
path = "/openicpsr/112651/fcr:versions/V1/20111351_data/" + fn

def log(m): print(m, flush=True)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    ctx = browser.new_context(accept_downloads=True, user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    page = ctx.new_page()
    page.goto(BASE + "/openicpsr/project/112651/version/V1/view?path=" + urllib.parse.quote(path, safe="/") + "&type=file", wait_until="domcontentloaded", timeout=60000)
    for i in range(30):
        t = page.title()
        if "moment" not in t.lower() and "bot" not in t.lower() and t.strip():
            break
        time.sleep(2)
    page.wait_for_timeout(3000)
    log("FILE VIEW TITLE: " + page.title())
    log("URL: " + page.url)
    # find any download links/buttons
    try:
        els = page.eval_on_selector_all("a,button,input[type=submit]", "els => els.filter(e=>e.tagName!=='A' || (e.href&&/download|getFile/i.test(e.href)) ).map(e=>({tag:e.tagName, href:e.href||null, text:(e.innerText||e.value||'').trim().slice(0,50)}))")
        for e in els:
            if e.get("href") or e.get("text"):
                log("CTRL: %s" % (e,))
    except Exception as ex:
        log("selerr "+repr(ex)[:120])
    browser.close()
