import numpy as np
import h5py
import pandas as pd

WORK = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\work\g9zkf'
NG = 51
NS = 8
NU = 36297

f = h5py.File(WORK + r'\code_extract\gamedatapreprocessed.mat', 'r')
stdscores = np.array(f['opt/stdscores']).ravel()
normfactor = np.array(f['opt/normfactor'])
stdt = normfactor[:, 0]
Dset = f['#refs#']
D_uid = np.array(Dset['Nb']).ravel().astype(int)
D_game = np.array(Dset['Mb']).ravel().astype(int)
D_inds = np.array(Dset['Pb']).astype(int)
D_score_raw = np.array(Dset['zb']).ravel().astype(np.float64)
T_uid = np.array(Dset['Oc']).ravel().astype(int)
T_game = np.array(Dset['Nc']).ravel().astype(int)
T_inds = np.array(Dset['Qc']).astype(int)
T_score_raw = np.array(Dset['Ac']).ravel().astype(np.float64)
f.close()

X = np.load(WORK + r'\X.npy')
XT = np.load(WORK + r'\XTEST.npy')

def r4(a, b):
    m = ~np.isnan(a) & ~np.isnan(b)
    r = np.corrcoef(a[m], b[m])[0, 1]
    return r ** 4

def abserr_nrmse(XHAT):
    def one(xh, uid, game, inds, score_raw):
        col = (inds[0] - 1) * NG + (inds[1] - 1)
        xhat_norm = xh[uid - 1, col]
        xhat_raw = xhat_norm * stdt[game - 1]
        err = score_raw - xhat_raw
        gid = game - 1
        n = np.bincount(gid, minlength=NG)
        absum = np.bincount(gid, weights=np.abs(err), minlength=NG)
        sqsum = np.bincount(gid, weights=err ** 2, minlength=NG)
        mae = absum / np.maximum(n, 1)
        rmse = np.sqrt(sqsum / np.maximum(n, 1))
        return np.nanmean(mae / stdscores), np.nanmean(rmse / stdscores)
    ab_tr, nr_tr = one(XHAT, D_uid, D_game, D_inds, D_score_raw)
    ab_te, nr_te = one(XHAT, T_uid, T_game, T_inds, T_score_raw)
    return ab_tr, nr_tr, ab_te, nr_te

# archived paper values
f = h5py.File(WORK + r'\code_extract\pcasol6.mat', 'r')
ap = f['allpreds']
ab_arch = np.array(ap['abserror_train']).ravel()
ab_arch_te = np.array(ap['abserror_test']).ravel()
nr_arch = np.array(ap['nrmse_train']).ravel()
nr_arch_te = np.array(ap['nrmse_test']).ravel()
exp_arch_tr = np.array(ap['explained_train'])[0]
exp_arch_te = np.array(ap['explained_test'])[0]
f.close()

print('%-3s | %-9s %-9s | %-9s %-9s | %-9s %-9s | %-9s %-9s' % (
    'k', 'ab_tr', 'ab_te', 'nrm_tr', 'nrm_te', 'exp_tr', 'exp_te', 'ARCH_ab_te', 'ARCH_exp_te'))
rows = []
for k in range(1, 13):
    d = np.load(WORK + r'\out_k%02d.npz' % k)
    A, S, Mu = d['A'], d['S'], d['Mu']
    XHAT = (Mu[:, None] + A @ S).T
    ab_tr, nr_tr, ab_te, nr_te = abserr_nrmse(XHAT)
    et, es = r4(X, XHAT), r4(XT, XHAT)
    rows.append((k, ab_tr, ab_te, nr_tr, nr_te, et, es))
    print('%-3d | %-9.5f %-9.5f | %-9.5f %-9.5f | %-9.5f %-9.5f | %-9.5f %-9.5f' % (
        k, ab_tr, ab_te, nr_tr, nr_te, et, es, ab_arch_te[k - 1], exp_arch_te[k - 1]))

# baseline (mean learning curve)
meanX = np.nanmean(X, axis=0)
XHAT_base = np.tile(meanX, (NU, 1))
ab_tr, nr_tr, ab_te, nr_te = abserr_nrmse(XHAT_base)
print('base | %-9.5f %-9.5f | %-9.5f %-9.5f | (arch ab_te %.5f)' % (
    ab_tr, ab_te, nr_tr, nr_te, ab_arch_te[12]))

# ---- k=6 loadings vs Figure3.xlsx ----
d = np.load(WORK + r'\out_k06.npz')
A6 = d['A']  # (408, 6) : col = (slice-1)*NG + game
fig3 = pd.read_excel(WORK + r'\code_extract\exceldata\Figure3.xlsx')
print('\nFigure3.xlsx columns:', list(fig3.columns)[:5], '...')
# Figure3 'Coefficients_1..48' = 6 factors x 8 stages, row order = task order (game index in reindexed order?)
# Compare my A (per reindexed game, 8 slices) to Figure3 (per task name, 48 coeffs)
# Figure3 rows are tasks. We need to know the game ordering. Use gamenames in reindexed order.
gnames = np.array(f['opt/gamenames']).ravel() if False else None
# load gamenames
f2 = h5py.File(WORK + r'\code_extract\gamedatapreprocessed.mat', 'r')
gamenames = [x.decode() for x in f2['opt/gamenames'][0]]
print('gamenames (reindexed order):', gamenames[:6])
print('Figure3 task rows (first 5):', fig3['Tasks'].tolist()[:5])
# A6 reshaped: for factor f (0..5), stage s (0..7), game g: A6[s*NG+g, f]
# Figure3 'Coefficients_{f*8+s+1}'
# For each Figure3 task, find its game index, then compare
print('\nCompare my A6 (factor1, all 8 stages) to Figure3 Coefficients_1..8 for first tasks:')
for i, tname in enumerate(fig3['Tasks'].tolist()[:6]):
    # find game index in gamenames
    if tname in gamenames:
        g = gamenames.index(tname)
        mine = [A6[s * NG + g, 0] for s in range(8)]
        arch = [fig3.loc[i, 'Coefficients_%d' % (s + 1)] for s in range(8)]
        print('  %-22s g=%d mine=%s' % (tname, g, np.round(mine, 3)))
        print('  %-22s     arch=%s' % ('', np.round(arch, 3)))
    else:
        print('  task not in gamenames:', tname)
