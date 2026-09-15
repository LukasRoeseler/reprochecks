import csv, sys, io

def load(path):
    rows=[]
    with open(path, newline='', encoding='utf-8-sig') as f:
        r=csv.DictReader(f)
        for line in r:
            rows.append(line)
    return rows

def truth(x):
    return str(x).strip().lower() in ('true','1','yes')

def compute_rule_scores(data, conds):
    # per-participant scores at test
    # group by condition, uniqueid
    from collections import defaultdict
    groups=defaultdict(list)
    for line in data:
        if not truth(line.get('test')):
            continue
        if truth(line.get('exclude')):
            continue
        cond=line['condition']
        if conds is not None and cond not in conds:
            continue
        uid=line['uniqueid']
        groups[(cond,uid)].append(line)
    testrule=[]
    for (cond,uid), trials in groups.items():
        n=len(trials)
        d2=d1a=d1b=0
        for t in trials:
            resp=int(t['response'])
            dim2=int(t['dim2']); dim3=int(t['dim3'])
            twodim = ((not dim3) and (not dim2) and (not resp)) or ((dim3 or dim2) and resp)
            one1 = (dim2 and resp) or ((not dim2) and (not resp))
            one2 = (dim3 and resp) or ((not dim3) and (not resp))
            d2 += twodim; d1a+=one1; d1b+=one2
        twodimscore=d2/n
        onedimscore=max(d1a/n, d1b/n)
        testrule.append((cond,ondecidimclose:=None,))
        testrule[-1]= (cond, onedimscore, twodimscore)
    from collections import defaultdict
    agg=defaultdict(lambda:[0.0,0.0,0])
    for cond,o1,o2 in testrule:
        agg[cond][0]+=o1; agg[cond][1]+=o2; agg[cond][2]+=1
    out={}
    for cond,(s1,s2,n) in agg.items():
        out[cond]=(round(s1/n,4), round(s2/n,4), n)
    return out

def main():
    print("=== EXPERIMENT 1 (test phase) ===")
    d1=load('data/data_exp1.csv')
    r=compute_rule_scores(d1, {'contingent','full_info'})
    for c in sorted(r): print(str(c), '1D=',r[c][0], '2D=',r[c][1], 'n=',r[c][2])
    print("=== EXPERIMENT 2 (test phase) ===")
    d2=load('data/data_exp2.csv')
    r=compute_rule_scores(d2, {'contingent','full_info'})
    for c in sorted(r): print(str(c), '1D=',r[c][0], '2D=',r[c][1], 'n=',r[c][2])

main()
