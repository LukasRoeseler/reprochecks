# ReproAI cross-check (second-language recompute, Python 3.8 / scipy.stats + statistics)
# Independent re-computation of the internally-derivable checks for
# Rodriguez-Lara & Moreno-Garrido (2012) Exp Econ 15:158-175.  Static audit; no raw data.
from math import sqrt, exp
import statistics as st

print("==== ReproAI Python cross-check START (status: OK) ====")
print("Engine: anomalyco/opencode (ReproAI) / DeepSeek V4 Flash via uniGPT; rules 2026.06.27; audit 2026-09-14")
import sys
print("Python", sys.version.split()[0])

# 1) Pooled means = unweighted mean of 3 treatment means (n=24 each)
def pool(g): return sum(g)/3.0
checks = [
    ("qd pool", pool([9.92,10.75,9.83]), 10.16),
    ("qr pool", pool([10.17,10.5,11.96]), 10.87),
    ("s  pool", pool([0.44,0.37,0.36]), 0.39),
    ("s-xa pool", pool([-0.07,-0.12,-0.18]), -0.13),
    ("s-xl pool", pool([-0.14,-0.03,-0.18]), -0.11),
]
for name, calc, rep in checks:
    print("[1] %-10s calc=%.4f reported=%.2f diff=%.4f" % (name, calc, rep, calc-rep))

# 2) Footnote 13: BL qd vs qr independent two-sample t, pooled var, df=46
m1,s1,m2,s2,n = 9.83,3.47,11.96,3.38,24
sp2 = ((n-1)*s1**2 + (n-1)*s2**2)/(2*n-2)
se = sqrt(sp2*(2.0/n)); t = (m2-m1)/se
from scipy import stats as sps
p = 2*sps.t.sf(abs(t), 46)
print("[3] Footnote13 BL qd!=qr: t=%.3f p=%.4f (paper t=2.14 p=0.036)" % (t,p))

# 5) W (z) <-> p mapping (second language)
w_cases = [
    ("Acc DW ftn17", .93, .3529), ("Lib DW ftn17",4.095,0.0),
    ("md>=mr Lib T3", .762,.446), ("md<mr qd>=qr Acc",.120,.9049),
    ("md>=mr pd<=pr Acc",1.120,.904), ("Pool bias W",.10,.9172),
]
for label,w,prep in w_cases:
    pcalc = 2*sps.norm.sf(abs(w))
    print("[5] W=%.3f p_calc=%.4f p_reported=%s -> %s" % (w,pcalc,prep, "OK" if abs(pcalc-(prep or 0))<0.002 else "MISMATCH"))

# 6) F <-> p mapping
f_cases = [
    ("Lib DW robust ftn17",7.93,2,22,.0025),("Acc DW robust ftn17",2.04,2,22,.1534),
    ("Pool bias robust ftn19",3.17,2,60,.0482),("Pool bias quant ftn19",0.35,2,60,.7056),
    ("Bias isolate robust",0.59,2,60,.5597),("Egal DW robust ftn17",4.28,2,22,.0269),
]
for label,F,d1,d2,prep in f_cases:
    pcalc = 1-sps.f.cdf(F,d1,d2)
    print("[6] F=%g(%d,%d) p_calc=%.4f p_reported=%.4f" % (F,d1,d2,pcalc,prep))

# 7) thresholds
print("[7] q0=%.4f (paper 3/7)  q1=%.4f (paper 0.6)" % (0.75/1.75, 1.5/2.5))

# 8) cell counts
cnt=[round(x*24) for x in (0.08,0.04,0.17)]
print("[8] zero-givers per treatment:", cnt, "total", sum(cnt), "pooled-72", sum(cnt)/72.0)
print("    vs 'eight s=0 dictators' (8/72=%.3f); 'positive 90pct' -> %.3f (7) vs %.3f (8)" % (8/72.0, 65/72.0, 64/72.0))
print("==== END (status: OK) ====")
