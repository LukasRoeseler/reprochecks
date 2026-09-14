import csv, numpy as np
base = r'C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)\01_Niemeyer_PtsdPublicationBias\ReproAI\Niemeyer_PtsdPublicationBias_884\exec_check\data'
res = {}
for name in ['res2_rank','res2_egg','res2_tes','res2_puni']:
    with open(base + '\\' + name + '.csv', encoding='utf-8') as fh:
        rows = list(csv.reader(fh, delimiter=';'))
    out = {}
    for r in rows:
        if len(r) > 0 and r[0].startswith('mu = 0'):
            vals = [float(c.strip().replace(',', '.')) for c in r[1:] if c.strip() != '']
            out[r[0].strip()] = np.array(vals)
    res[name] = out
    print('===', name)
    for p, v in out.items():
        prop = float((v > 0.8).mean())
        mean = float(v.mean())
        print('  %s: n=%d prop(ds power>0.8)=%.4f  mean_power=%.4f' % (p, len(v), prop, mean))

print()
print('C42: any dataset with power>0.8 for pub<0.95 (first 6 conds)')
for name in ['res2_rank','res2_egg','res2_tes','res2_puni']:
    out = res[name]
    keys = [k for k in out if not k.endswith('pub = 1')]
    any_gt = any(bool((out[k] > 0.8).any()) for k in keys)
    mx = max(float(out[k].max()) for k in keys)
    print('  %s: any ds power>0.8 at pub<0.95=%s, max power pub<0.95=%.4f' % (name, any_gt, mx))

print()
print('C41: prop of datasets with power>0.8 at pub=1')
for name in ['res2_rank','res2_egg','res2_tes','res2_puni']:
    print('  %s pub=1 prop(ds>0.8)=%.4f' % (name, float((res[name]['mu = 0; pub = 1'] > 0.8).mean())))

# C39: Type-I error rate < 0.05 -> overall power at pub=0 should be ~<=0.05 (mean_power at pub=0)
print()
print('C39: Type-I error proxy = mean power at pub=0')
for name in ['res2_rank','res2_egg','res2_tes','res2_puni']:
    print('  %s mean_power(pub=0)=%.4f' % (name, float(res[name]['mu = 0; pub = 0'].mean())))
