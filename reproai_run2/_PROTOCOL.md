# ReproAI Audit Protocol (Batch run2)

You are performing a **ReproAI numerical-reproducibility audit** of one published study.
Goal: independently verify whether the paper's **headline numerical claims** can be re-produced
(re-run) from the shared data/code, or from data obtainable via the FLoRA reproduction project.

## Tools available
- Environment: Windows PowerShell 5.1, on `C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode`.
- Python 3.8: `C:\Users\lroesele.IVV5NET\AppData\Local\Programs\Python\Python38\python.exe`
- R 4.6.1: `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`
- You have web access (webfetch) and filesystem + bash.

## Steps
1. **Obtain the study** (full text if possible; at least abstract + Method + Results). Use the
   DOI (https://doi.org/<doi>), OpenAlex, Unpaywall, or the OSF reproduction project which usually
   contains the paper/report + data.
2. **Fetch the reproduction data.** The FLoRA reproduction lives on OSF at `<osf>`.
   - List files via OSF API v2: `https://api.osf.io/v2/nodes/<osf_id>/files/osfstorage/` (recursively walk folders; each item has `attributes` `name`/`kind`, and a `links.download` you can fetch).
   - The reproduction may be a *component*; if the top node has few files, look at
     `https://api.osf.io/v2/nodes/<osf_id>/children/` for component nodes holding data, or files
     in other providers.
   - Download data + code into your audit folder. If a node 404s, fall back to scraping the
     osf.io project page (https://osf.io/<id>/) for file links.
3. **Extract headline numerical claims** (the specific statistics/tables/figures the paper is
   known for).
4. **Independently re-compute** those claims from the data (re-run provided scripts, or write your
   own in Python/R). **Never fabricate numbers** — only record numbers you actually computed. If a
   dependency is missing, install/pin as needed or impute data if it is openly downloadable;
   otherwise record the limitation.
5. **Grade** the AI-led verdict on the ReproAI scale:
   - `FULL` = independently reproduced all/most headline numbers exactly
   - `CONSISTENT` = reproduced with minor/expected deviations, conclusions hold
   - `PARTIAL` = reproduced only subset / substantive deviations
   - `NODATA` = could not obtain data/code to independently re-run
   - `FAIL` = reproduced and contradicted a headline claim
6. **Severity findings** count per category P0 (critical) / P1 (major) / P2 (minor) / P3 (cosmetic),
   e.g. `P0-0 P1-0 P2-1 P3-2`.
7. **Write artifacts** into your designated audit folder:
   - `REPROAI_REPORT.html` (house style, self-contained: header, data-sourcing, claim inventory,
     verification table, findings, verdict).
   - `_audit_summary.json` containing `{"grade":...,"sev":"P0-x P1-x...","data_status":"obtained|partial|none","key_findings":[...],"headline_verified":bool,"notes":"..."}`.

## Honesty rule
This is a real reproduction attempt. Report exactly what you could verify. If data are not
reachable, say `NODATA` with the reason — do NOT invent results. Note whether your verdict matches
the human FLoRA code (`flora` value in the registry).
