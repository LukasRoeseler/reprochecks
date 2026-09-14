import re, json
f = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\09_deLeeuw_ERP\ReproAI\deLeeuw_ERP_1481\extracted\analysis.nb.html"
t = open(f, encoding='utf-8').read()
idx = [m.start() for m in re.finditer('"columns":\[', t)]
print('count', len(idx))
# try to find each JSON object containing columns
out = []
for m in re.finditer(r'\{"columns":\[', t):
    start = m.start()
    # balanced brace parse from here
    depth = 0
    i = start
    instr = False
    while i < len(t):
        c = t[i]
        if instr:
            if c == '\\':
                i += 2
                continue
            if c == '"':
                instr = False
        else:
            if c == '"':
                instr = True
            elif c == '{':
                depth += 1
            elif c == '}':
                depth -= 1
                if depth == 0:
                    break
        i += 1
    chunk = t[start:i+1]
    try:
        d = json.loads(chunk)
        cols = [c.get('label',[None])[0] if c.get('label') else c.get('name') for c in d['columns']]
        rows = d['data']
        out.append((cols, rows))
    except Exception as e:
        out.append(('PARSE_FAIL', str(e)[:80]))
for n,(cols,rows) in enumerate(out):
    print('===== TABLE', n)
    if cols == 'PARSE_FAIL':
        print('   parse fail', rows)
        continue
    print('   cols:', cols)
    for r in rows:
        print('   ', r)
