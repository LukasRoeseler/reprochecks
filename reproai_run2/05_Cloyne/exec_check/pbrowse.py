import time, re, json, sys
from playwright.sync_api import sync_playwright

BASE = "https://www.openicpsr.org"
FOLDER = "/openicpsr/112651/fcr:versions/V1/20111351_data"
view_url = BASE + "/openicpsr/project/112651/version/V1/view?path=" + FOLDER + "&type=folder"

outdir = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\05_Cloyne\exec_check"

results = {}

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    ctx = browser.new_context(user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    page = ctx.new_page()
    page.goto(view_url, wait_until="domcontentloaded", timeout=60000)
    # wait for cloudflare to clear (title changes)
    for i in range(30):
        t = page.title()
        if "moment" not in t.lower() and "bot" not in t.lower() and t.strip():
            break
        time.sleep(2)
    page.wait_for_timeout(3000)
    html = page.content()
    with open(outdir + "\\openicpsr_folder.html", "w", encoding="utf-8") as f:
        f.write(html)
    print("TITLE:", page.title())
    print("URL now:", page.url)
    # extract download links
    links = page.eval_on_selector_all("a[href*='download']", "els => els.map(e => e.href)")
    for l in links:
        print("LINK:", l)
    browser.close()

results["view_url"] = page.url if False else view_url
