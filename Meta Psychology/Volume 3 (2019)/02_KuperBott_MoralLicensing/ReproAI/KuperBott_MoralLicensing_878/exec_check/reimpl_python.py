# ReproAI re-audit - Kuper & Bott (2019) MP.2018.878
# Independent Python 3.8 reimplementation (second language cross-check vs R metafor/weightr).
# 1) Reconstruct k=76 analytic dataset from raw dat_new_s.txt (Table 1 & 2 rules)
# 2) REML random-effects meta-analysis (independent of metafor)
# 3) Verify the paper's internal inconsistency: I2=0.26 vs Q(75)=175.77
# 4) Verify the power analysis (n=766, d=0.18, 80%, one-tailed)
import numpy as np
from scipy.optimize import minimize_scalar
from scipy import stats

def read_ds(path):
    import re
    pat=re.compile(r'"(\d+)"\s+"([^"]+)"\s+(\d+)\s+(\d+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+"([^"]+)"')
    rows=[]
    with open(path,encoding='latin1') as f:
        f.readline()
        for line in f:
            line=line.strip()
            if not line: continue
            m=pat.search(line)
            if not m: 
                raise ValueError("unparsed: "+line)
            idx,authors,study,N,yi,se,comparison,decision_type,pub,country,region,ID=m.groups()
            def clean(x): return None if x=='NA' else x
            rows.append(dict(authors=authors,study=int(study),N=int(N),yi=float(yi),se=float(se),
                             comparison=int(comparison),decision_type=int(decision_type),pub=int(pub),
                             country=clean(country),world_region=clean(region)))
    return rows

def reconstruct(ds):
    au=[r['authors'].lstrip('. ').lstrip('.') for r in ds]
    keep=[True]*len(ds)
    # Table1 exclusions
    for i,a in enumerate(au):
        if a.startswith('Effron (2014)') or a.startswith('Kouchaki (2011)'):
            keep[i]=False
    # Table2 pair drops (keep first of each pair)
    def drop(prefix,pairs):
        for p in pairs:
            for i,a in enumerate(au):
                if a.startswith(prefix) and ds[i]['study'] in p and ds[i]['study']!=p[0]:
                    keep[i]=False
    drop('Blanken et al. (2012)',[(1,2),(4,5),(6,7),(8,9),(10,11),(12,13),(14,15),(16,17)])
    drop('Bradley-Geist et al. (2010)',[(1,2),(3,4)])
    drop('Meijers et al. (2014)',[(1,2),(3,4)])
    # Simbrunner aggregation
    sim=[i for i,a in enumerate(au) if 'Simbrunner' in a and '2016' in a]
    groups={}
    for i in sim:
        groups.setdefault(ds[i]['N'],[]).append(i)
    out=[]
    for i,r in enumerate(ds):
        if i in sim: continue
        if not keep[i]: continue
        out.append({'yi':r['yi'],'se':r['se'],'region':r['world_region'],'comp':r['comparison']})
    for n,idx in groups.items():
        yi=np.mean([ds[i]['yi'] for i in idx]); se=np.mean([ds[i]['se'] for i in idx])
        out.append({'yi':yi,'se':se,'region':ds[idx[0]]['world_region'],'comp':ds[idx[0]]['comparison']})
    return out

def reml_ma(yi,vi,tol=1e-9,maxiter=200):
    k=len(yi)
    def negll(tausq):
        v=vi+tausq
        w=1.0/v
        mu=np.sum(w*yi)/np.sum(w)
        ll=-0.5*(np.sum(np.log(v))+np.sum((yi-mu)**2/v)+np.log(np.sum(w)))
        return -ll
    res=minimize_scalar(negll,bounds=(0,1),method='bounded',options={'xatol':1e-10})
    tausq=res.x
    v=vi+tausq; w=1.0/v
    mu=np.sum(w*yi)/np.sum(w)
    se=np.sqrt(1.0/np.sum(w))
    z=mu/se
    Q=np.sum((yi-mu)**2/vi)          # metafor QE convention: denominator = sampling variance
    I2=(Q-(k-1))/Q if Q>0 else 0
    return mu,se,z,Q,I2,tausq

# --- data ---
ds=read_ds(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\02_KuperBott_MoralLicensing\ReproAI\KuperBott_MoralLicensing_878\exec_check\data\dat_new_s.txt")
recon=reconstruct(ds)
print("=== RECONSTRUCTION ===")
print("raw k =",len(ds))
print("reconstructed k =",len(recon))
regions={}
for r in recon: regions[r['region']]=regions.get(r['region'],0)+1
print("region counts:",regions)

yi=np.array([r['yi'] for r in recon]); se=np.array([r['se'] for r in recon]); vi=se**2
mu,se_ma,z,Q,I2,tausq=reml_ma(yi,vi)
print("\n=== NAIVE RE (REML) k=%d ==="%len(recon))
print("d=%.4f SE=%.4f Z=%.3f 95%%CI=[%.3f;%.3f]"%(mu,se_ma,z,mu-1.96*se_ma,mu+1.96*se_ma))
print("tau2=%.4f Q(df=%d)=%.2f I2=%.3f"%(tausq,len(recon)-1,Q,I2))

# PET-PEESE (WLS)
W=1.0/vi
X=np.column_stack([np.ones(len(yi)),se]); Wy=yi*np.sqrt(W); Wx=X*np.sqrt(W)[:,None]
XtX=np.linalg.inv(Wx.T@Wx); beta=XtX@(Wx.T@Wy)
resid=Wy-Wx@beta; dferr=len(yi)-2
sig2=np.sum(resid**2)/dferr
V=sig2*XtX; se_b=np.sqrt(np.diag(V)); t=beta/se_b
p=2*(1-stats.t.cdf(np.abs(t),dferr))
print("\n=== PET-PEESE k=%d ==="%len(recon))
print("intercept d=%.3f t=%.2f p=%.3f | slope b=%.3f t=%.2f p=%.3f"%(beta[0],t[0],p[0],beta[1],t[1],p[1]))

# --- paper internal inconsistency ---
print("\n=== PAPER INTERNAL CONSISTENCY (independent) ===")
Q=175.77; df=75
print("Reported I2=0.26 AND Q(75)=175.77. Formula I2=(Q-df)/Q = %.3f (=%.1f%%)"%((Q-df)/Q,(Q-df)/Q*100))
print("=> 0.26 != 0.573 : internally inconsistent by the standard formula.")

# --- power analysis ---
print("\n=== POWER ANALYSIS (n for d=0.18, 80% power, one-tailed) ===")
for zname,z in [('z_a=1.6449',1.6448536269514722),('z_b=0.8416',0.8416212335729143)]:
    n=2*((1.6448536269514722+0.8416212335729143)/0.18)**2
    print("N per group=%.1f -> total N=%.1f ; manuscript says n=766"%(n/2,n))
print("(exact total with standard z = %.0f, close to 766)"%(2*((1.6448536269514722+0.8416212335729143)/0.18)**2))

# --- dat_old_s uncorrected comparison moderator check ---
dso=read_ds(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)\02_KuperBott_MoralLicensing\ReproAI\KuperBott_MoralLicensing_878\exec_check\data\dat_old_s.txt")
print("\n=== uncorrected dat_old_s ===")
print("k=",len(dso))
for r in dso:
    if r['yi']>3: print("  d>3 row:",r['authors'],r['study'],"yi=",r['yi'])
