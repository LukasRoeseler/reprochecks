import requests, os

f = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\reprochecks\reproai_run2\16_Horowitz"
files = {
 'README.txt': 'https://files.us.osf.io/v1/resources/6ye5m/providers/osfstorage/5f74ffca39d7e30084eb675f',
 'horowitz_final_report.pdf': 'https://files.us.osf.io/v1/resources/6ye5m/providers/osfstorage/5f9a841687b7df03bd3b1fba',
 'horowitz_regression.html': 'https://files.us.osf.io/v1/resources/6ye5m/providers/osfstorage/5f92225f7c2a7100dbe528c3',
 'summary_table.html': 'https://files.us.osf.io/v1/resources/6ye5m/providers/osfstorage/5f74f2771cfe690081cf53cd',
 'summary_table_no_METAREA.html': 'https://files.us.osf.io/v1/resources/6ye5m/providers/osfstorage/5f74f275e64e7e0087aa9734',
 'variable_documentation.html': 'https://files.us.osf.io/v1/resources/6ye5m/providers/osfstorage/5f74f276e64e7e008eaa7a27',
 'DataDictionary.xlsx': 'https://files.us.osf.io/v1/resources/6ye5m/providers/osfstorage/5f74f277e64e7e008faa812e',
 '38y3_repro_audit_template.Rmd': 'https://files.us.osf.io/v1/resources/32h4p/providers/osfstorage/63fe1ee0f014b907feeb408f',
 '38y3_audit1.csv': 'https://files.us.osf.io/v1/resources/32h4p/providers/osfstorage/69cc0497eefb5279eb744fed',
 '38y3_repro2.csv': 'https://files.us.osf.io/v1/resources/32h4p/providers/osfstorage/69cc0498f632ae4ffbdebf7f',
 '38y3_repro_audit_template.html': 'https://files.us.osf.io/v1/resources/32h4p/providers/osfstorage/63fe1edfbbc5e5083cf8038d',
 'POWER_Horowitz.zip': 'https://files.us.osf.io/v1/resources/gxfwh/providers/osfstorage/5f92e99d87b7df003d3b0970',
}
for n, u in files.items():
    try:
        r = requests.get(u, timeout=60)
        if r.status_code == 200:
            open(os.path.join(f, n), 'wb').write(r.content)
            print('OK', n, len(r.content))
        else:
            print('FAIL', n, r.status_code)
    except Exception as e:
        print('ERR', n, e)
