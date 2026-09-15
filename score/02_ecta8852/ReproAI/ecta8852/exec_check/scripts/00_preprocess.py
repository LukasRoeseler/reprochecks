import os, re, glob, csv

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\02_ecta8852\ReproAI\ecta8852\extracted\Data\BehaviorOutcomes"
OUT = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\02_ecta8852\ReproAI\ecta8852\exec_check\output\master_behavior.csv"

def parse_label(fn):
    m = re.match(r'^(HOM|HET|PART)_(\d)_(\d+)_(chat|nochat)(_rev)?\.txt$', fn, re.I)
    pref_map = {'HOM':'hom','HET':'het','PART':'part'}
    return {
        'pref': pref_map[m.group(1).upper()],
        'rule': int(m.group(2)),
        'nsubj': int(m.group(3)),
        'comm': 1 if m.group(4)=='chat' else 0,
        'rev': 1 if m.group(5) else 0,
    }

files = sorted(glob.glob(os.path.join(BASE, '*.txt')))
rows = []
seen = {}
for fp in files:
    fn = os.path.basename(fp)
    tag = parse_label(fn)
    with open(fp) as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line: continue
            parts = line.split()
            if len(parts) != 10:
                raise ValueError(f"{fn}:{lineno}: expected 10 cols, got {len(parts)}: {line}")
            parts = [int(x) for x in parts]
            rows.append([tag['pref'], tag['rule'], tag['comm'], tag['rev'], tag['nsubj'], fn] + parts)

with open(OUT, 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['pref','rule','comm','rev','nsubj','file','period','subj','group','type','sample','action','groupdec','jar','payoff','time'])
    w.writerows(rows)

print("rows(total individual decisions):", len(rows))
from collections import defaultdict
subj = set()
for r in rows:
    subj.add((r[4], r[0], r[1], r[2], r[3], r[5]))  # nsubj less useful; count by file+subj
subj_by_file = defaultdict(set)
for r in rows:
    subj_by_file[r[5]].add(r[7])
tot = 0
for k in sorted(subj_by_file):
    print(k, len(subj_by_file[k]))
    tot += len(subj_by_file[k])
print("TOTAL distinct subjects:", tot)
