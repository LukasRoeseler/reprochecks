import os, csv
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Nature Human Behavior"

with open(f"{BASE}\\NHB_DOWNLOAD_STATUS.csv", encoding="utf-8") as f:
    results = list(csv.DictReader(f))

with open(f"{BASE}\\NHB_MASTER_CLASSIFICATION.csv", encoding="utf-8") as f:
    classification = {r["num"]: r for r in csv.DictReader(f)}

# Determine ACTUAL download status: check if a valid fulltext.pdf exists
def check_real_pdf(num):
    for year in ['2019', '2020']:
        vol_dir = os.path.join(BASE, f"Volume {year} ({year})")
        if not os.path.exists(vol_dir):
            continue
        for d in os.listdir(vol_dir):
            if d.startswith(num + '_'):
                pdf_path = os.path.join(vol_dir, d, 'fulltext.pdf')
                if os.path.exists(pdf_path):
                    with open(pdf_path, 'rb') as f:
                        header = f.read(5)
                    return header == b'%PDF-'
    return False

for r in results:
    r['actually_downloaded'] = 'Yes' if check_real_pdf(r['num']) else 'No'

# Write updated CSV
with open(f"{BASE}\\NHB_DOWNLOAD_STATUS.csv", 'w', encoding='utf-8', newline='') as f:
    fields = ['num', 'doi', 'doi_url', 'first_author', 'is_open_access', 'full_text_available', 'method', 'download_url', 'actually_downloaded']
    writer = csv.DictWriter(f, fieldnames=[k for k in fields if k != 'landing_url'])
    writer.writeheader()
    for r in results:
        writer.writerow({k: r.get(k, '') for k in fields if k != 'landing_url'})

# Build XLSX
wb = Workbook()
ws = wb.active
ws.title = "Download Status"

headers = ['Num', 'DOI', 'DOI URL', 'First Author', 'Classification', 'Unpaywall OA', 'Reported Available', 'Method', 'Actually Downloaded (valid PDF)', 'Download URL']
ws.append(headers)

for cell in ws[1]:
    cell.font = Font(bold=True, color="FFFFFF")
    cell.fill = PatternFill(start_color="1a1a2e", end_color="1a1a2e", fill_type="solid")

for r in results:
    cls = classification.get(r['num'], {}).get('classification', 'Unknown')
    ws.append([
        r['num'], r['doi'], r['doi_url'], r['first_author'], cls,
        'Yes' if r['is_open_access'] == 'True' else 'No',
        'Yes' if r['full_text_available'] == 'True' else 'No',
        r['method'], r['actually_downloaded'], r['download_url']
    ])

for col in ws.columns:
    max_length = 0
    col_letter = col[0].column_letter
    for cell in col:
        if cell.value:
            max_length = max(max_length, len(str(cell.value)))
    ws.column_dimensions[col_letter].width = min(max_length + 2, 70)

ws.freeze_panes = "A2"

# Summary sheet
ws2 = wb.create_sheet("Summary")
ws2.append(["Metric", "Count"])
for cell in ws2[1]:
    cell.font = Font(bold=True)

total = len(results)
oa = sum(1 for r in results if r['is_open_access'] == 'True')
reported = sum(1 for r in results if r['full_text_available'] == 'True')
actual = sum(1 for r in results if r['actually_downloaded'] == 'Yes')

ws2.append(["Total articles", total])
ws2.append(["Unpaywall Open Access", oa])
ws2.append(["Reported full-text available (unpaywall)", reported])
ws2.append(["Actually downloaded valid PDF", actual])
ws2.append(["Failed / not a PDF", reported - actual])

ws2.append([])
ws2.append(["SUCCESSFULLY DOWNLOADED (valid PDF)", "DOI URL", "Download URL"])
for cell in ws2[ws2.max_row]:
    cell.font = Font(bold=True)
for r in results:
    if r['actually_downloaded'] == 'Yes':
        ws2.append([f"{r['num']} {r['first_author']}", r['doi_url'], r['download_url']])

ws2.append([])
ws2.append(["ATTEMPTED BUT FAILED / NOT A PDF", "DOI URL", "Reason"])
for cell in ws2[ws2.max_row]:
    cell.font = Font(bold=True)
for r in results:
    if r['full_text_available'] == 'True' and r['actually_downloaded'] == 'No':
        ws2.append([f"{r['num']} {r['first_author']}", r['doi_url'], r['method']])

output_path = f"{BASE}\\NHB_DOWNLOAD_STATUS.xlsx"
wb.save(output_path)

print(f"Reconciled: {total} papers")
print(f"  OA (unpaywall): {oa}")
print(f"  Reported available: {reported}")
print(f"  Actually downloaded valid PDF: {actual}")
print(f"  Failed/not-a-PDF: {reported - actual}")
print(f"Saved: {output_path}")
