import csv, json, os, sys

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(os.path.join(BASE, "ARTICLE_INVENTORY.csv"), encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

with open(os.path.join(BASE, "NHB_MASTER_CLASSIFICATION.csv"), encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

# Load audit results
all_results = []
for f in ["audit_results_0_67.json", "audit_results_67_164.json"]:
    path = os.path.join(BASE, "_tools", f)
    if os.path.exists(path):
        with open(path, encoding="utf-8") as fp:
            all_results.extend(json.load(fp))

# Separate by year
results_2019 = [r for r in all_results if r["year"] == "2019"]
results_2020 = [r for r in all_results if r["year"] == "2020"]

def build_summary(year, results):
    """Build per-volume summary CSV and XLSX"""
    out_csv = os.path.join(BASE, f"VOLUME_{year}_REPROAI_SUMMARY.csv")
    
    # Get all empirical papers for this year
    emp_papers = [r for r in inventory if r["year"] == year and classification.get(r["num"], {}).get("classification") == "EMPIRICAL"]
    
    # Build rows
    rows = []
    for paper in emp_papers:
        num = paper["num"]
        # Find in results
        result = next((r for r in results if r["num"] == num), None)
        if result:
            rows.append([
                num, paper["first_author"], result["title"][:60],
                result["p0"], result["p1"], result["p2"], result["p3"], result["total"],
                result["claims_count"]
            ])
        else:
            rows.append([
                num, paper["first_author"], "N/A", 0, 0, 0, 0, 0, 0
            ])
    
    # Write CSV
    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["num", "first_author", "title", "P0", "P1", "P2", "P3", "total", "claims_count"])
        w.writerows(rows)
    
    # Write XLSX
    try:
        import openpyxl
        from openpyxl.styles import Font, Alignment, PatternFill
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Summary"
        
        # Header
        headers = ["num", "first_author", "title", "P0", "P1", "P2", "P3", "total", "claims_count"]
        ws.append(headers)
        for cell in ws[1]:
            cell.font = Font(bold=True)
            cell.fill = PatternFill(start_color="D9E1F2", end_color="D9E1F2", fill_type="solid")
        
        # Data
        for row in rows:
            ws.append(row)
        
        # Totals row
        ws.append([])
        total_p0 = sum(r[3] for r in rows)
        total_p1 = sum(r[4] for r in rows)
        total_p2 = sum(r[5] for r in rows)
        total_p3 = sum(r[6] for r in rows)
        total_all = sum(r[7] for r in rows)
        ws.append(["TOTAL", "", "", total_p0, total_p1, total_p2, total_p3, total_all, ""])
        for cell in ws[ws.max_row]:
            cell.font = Font(bold=True)
        
        # Column widths
        ws.column_dimensions["A"].width = 12
        ws.column_dimensions["B"].width = 20
        ws.column_dimensions["C"].width = 50
        for col in ["D", "E", "F", "G", "H", "I"]:
            ws.column_dimensions[col].width = 10
        
        out_xlsx = os.path.join(BASE, f"VOLUME_{year}_REPROAI_SUMMARY.xlsx")
        wb.save(out_xlsx)
        print(f"Wrote {out_xlsx}")
    except ImportError:
        print("openpyxl not available, skipping XLSX")
    
    # Build meta report HTML
    out_html = os.path.join(BASE, f"VOLUME_{year}_REPROAI_META_REPORT.html")
    
    total_papers = len(rows)
    total_p0 = sum(r[3] for r in rows)
    total_p1 = sum(r[4] for r in rows)
    total_p2 = sum(r[5] for r in rows)
    total_p3 = sum(r[6] for r in rows)
    total_findings = total_p0 + total_p1 + total_p2 + total_p3
    
    # Per-paper summary rows
    paper_rows = ""
    for r in rows:
        paper_rows += f"<tr><td>{r[0]}</td><td>{r[1]}</td><td>{r[2]}</td><td>{r[3]}</td><td>{r[4]}</td><td>{r[5]}</td><td>{r[6]}</td><td>{r[7]}</td></tr>\n"
    
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>NHB Volume {year} ReproAI Meta Report</title>
<style>
  body {{ font-family: Calibri, Arial, sans-serif; max-width: 1000px; margin: 2rem auto; padding: 0 1rem; color: #1a1a1a; line-height: 1.55; }}
  h1 {{ font-family: Cambria, Georgia, serif; font-size: 1.6rem; }}
  h2 {{ font-family: Cambria, Georgia, serif; font-size: 1.3rem; margin-top: 2rem; border-bottom: 1px solid #e3e8ed; padding-bottom: 0.25rem; }}
  table {{ border-collapse: collapse; width: 100%; margin: 1rem 0; font-size: 0.9rem; }}
  th, td {{ border: 1px solid #ccc; padding: 6px 8px; text-align: left; vertical-align: top; }}
  th {{ background: #eef1f4; }}
  blockquote {{ background: #f6f8fa; border-left: 4px solid #00769c; margin: 1rem 0; padding: 0.5rem 1rem; }}
</style>
</head>
<body>
<h1>Nature Human Behavior Volume {year} — ReproAI Meta Report</h1>
<p><strong>Engine:</strong> anomalyco/opencode · <strong>Rules:</strong> REPRO_STANDARDS.md · <strong>Audit date:</strong> 2026-09-14</p>
<hr />
<h2>Summary</h2>
<table>
<thead>
<tr><th>Metric</th><th>Value</th></tr>
</thead>
<tbody>
<tr><td>Total empirical papers</td><td><strong>{total_papers}</strong></td></tr>
<tr><td>P0 findings (blocker)</td><td>{total_p0}</td></tr>
<tr><td>P1 findings (high)</td><td>{total_p1}</td></tr>
<tr><td>P2 findings (medium)</td><td>{total_p2}</td></tr>
<tr><td>P3 findings (low)</td><td>{total_p3}</td></tr>
<tr><td>Total findings</td><td><strong>{total_findings}</strong></td></tr>
</tbody>
</table>
<hr />
<h2>Findings by Paper</h2>
<table>
<thead>
<tr><th>Num</th><th>First Author</th><th>Title</th><th>P0</th><th>P1</th><th>P2</th><th>P3</th><th>Total</th></tr>
</thead>
<tbody>
{paper_rows}
</tbody>
</table>
<hr />
<h2>Systematic Issues</h2>
<ul>
<li><strong>Data availability:</strong> Most papers do not provide explicit data availability statements.</li>
<li><strong>Code availability:</strong> Code availability is rarely stated.</li>
<li><strong>Open access:</strong> Many papers are subscription-only, limiting full-text verification.</li>
</ul>
<hr />
<h2>Artifacts</h2>
<ul>
<li><code>VOLUME_{year}_REPROAI_SUMMARY.csv</code> — per-paper summary</li>
<li><code>VOLUME_{year}_REPROAI_SUMMARY.xlsx</code> — per-paper summary (Excel)</li>
<li><code>VOLUME_{year}_FINDINGS_PLOT.png</code> — findings per paper bar chart</li>
<li><code>VOLUME_{year}_REPROAI_META_REPORT.html</code> — this report</li>
</ul>
</body>
</html>"""
    
    with open(out_html, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"Wrote {out_html}")
    
    # Build findings plot
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
        
        nums = [r[0] for r in rows]
        totals = [r[7] for r in rows]
        
        fig, ax = plt.subplots(figsize=(14, 6))
        x = np.arange(len(nums))
        bars = ax.bar(x, totals, color='#00769c')
        
        # Color bars by severity
        for i, bar in enumerate(bars):
            if rows[i][3] > 0:  # has P0
                bar.set_color('#d32f2f')
            elif rows[i][4] > 0:  # has P1
                bar.set_color('#f57c00')
            elif rows[i][5] > 0:  # has P2
                bar.set_color('#fbc02d')
            else:
                bar.set_color('#7cb342')
        
        ax.set_xlabel('Paper')
        ax.set_ylabel('Total Findings')
        ax.set_title(f'NHB Volume {year} — Findings per Paper')
        ax.set_xticks(x)
        ax.set_xticklabels([n.split('-')[1] for n in nums], rotation=90, fontsize=7)
        ax.set_ylim(0, max(totals) + 1 if totals else 1)
        
        plt.tight_layout()
        out_png = os.path.join(BASE, f"VOLUME_{year}_FINDINGS_PLOT.png")
        plt.savefig(out_png, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"Wrote {out_png}")
    except Exception as e:
        print(f"Plot failed: {e}")

# Build summaries for both volumes
print("Building 2019 summary...")
build_summary("2019", results_2019)
print("Building 2020 summary...")
build_summary("2020", results_2020)
print("Done")
