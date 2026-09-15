# Independent Python recompute (cross-language check of headline numbers)
import warnings; warnings.filterwarnings('ignore')
import pandas as pd, numpy as np
from scipy import stats

p = r'C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\SCORE ReproAI Checks\06_e3kcw\ReproAI\e3kcw\exec_check\source\Primary_sample_data.xlsx'
d = pd.read_excel(p, sheet_name='data', header=0)
print('N =', len(d))

# 1. quarantine distribution
q = d['quarantine'].value_counts().reindex([1,2,3,4])
print('quarantine counts', q.tolist(), 'pct', (q/len(d)*100).round(1).tolist())

# 2. flow descriptives (sum -> avg of 5)
print('flow avg M=%.4f SD=%.4f' % (d.flow.mean()/5, d.flow.std()/5))

# 3. flow-mindful correlation
print('flow-mindful r=%.4f' % np.corrcoef(d.flow, d.mindful)[0,1])

# 4. sex composition
print('sex1=%d(%.1f%%) sex2=%d(%.1f%%)' % ((d.sex==1).sum(), 100*(d.sex==1).mean(), (d.sex==2).sum(), 100*(d.sex==2).mean()))

# 5. Cronbach alpha (lonely) cross-check
def alpha(df):
    k = df.shape[1]
    items = df.values
    return k/(k-1)*(1 - items.var(axis=0,ddof=1).sum()/items.sum(axis=1).var(ddof=1))
print('lonely alpha=%.3f' % alpha(d[['lonely1','lonely2','lonely3']]))
print('worry alpha=%.3f' % alpha(d[['worry1','worry2','worry3']]))

# 6. One regression cross-check: lonely ~ flow+mind+q+interactions+covariates (stdall, drop age NA)
dk = d.dropna(subset=['age']).copy()
def z(s): return (s-s.mean())/s.std(ddof=1)
flow = dk.flow; mind = dk.mindful; qlog = np.log10(dk.quarantine)
fk = z(flow); mk = z(mind); qk = z(qlog)
X = pd.DataFrame({'f':fk,'m':mk,'q':qk,'fxq':fk*qk,'mxq':mk*qk,
    'sex':z(dk.sex),'age':z(dk.age),'edu':z(dk.edu),'sib':z(dk.ifsibling),
    'inc':z(dk.income),'opt':z(dk.opt),'iu':z(dk.iu),'swls':z(dk.swls)}) 
X.insert(0,'int',1.0)
y = z((dk.lonely1+dk.lonely2+dk.lonely3)/3)
beta = np.linalg.lstsq(X.values, y.values, rcond=None)[0]
names=['int','f','m','q','fxq','mxq','sex','age','edu','sib','inc','opt','iu','swls']
print('lonely std betas:', dict(zip(names, np.round(beta,4))))
# R gave: flow=-.157 mind=.059 quar=.114 fxq=-.055 mxq=.011
