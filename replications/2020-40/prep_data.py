import numpy as np
import pandas as pd
import h5py

BASE = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\g9zkf'
PRE = BASE + r'\preprocessed data (CSV)'
WORK = r'C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\work\g9zkf'

NG = 51
NS = 8
NU = 36297

matp = WORK + r'\code_extract\gamedatapreprocessed.mat'
f = h5py.File(matp, 'r')
whg = np.array(f['opt/whgames']).ravel().astype(int)
reindex = {int(whg[i]): i for i in range(len(whg))}

# --- training matrix X from CSV (scores present) ---
df = pd.read_csv(PRE + r'\normalized_score_array_training.csv')
df.columns = [c.strip() for c in df.columns]
col = (df['practice bin'].values - 1) * NG + df['game_id'].map(reindex).values.astype(int)
row = df['anon_id'].values.astype(np.int64)
val = df['normalized score'].values.astype(np.float64)
X = np.full((NU, NG * NS), np.nan, dtype=np.float64)
ok = ~np.isnan(val)
X[row[ok], col[ok]] = val[ok]
print('X nonnan', np.count_nonzero(~np.isnan(X)))

# --- validation/held-out matrix XTEST from mat (CSV has no scores) ---
XST = np.array(f['opt/XSTEST'])  # (game, user, slice)
XT = np.full((NU, NG * NS), np.nan, dtype=np.float64)
for j in range(NS):
    XT[:, j * NG:(j + 1) * NG] = XST[:, :, j].T
print('XTEST nonnan', np.count_nonzero(~np.isnan(XT)))

# --- opt parameters ---
opt = {}
for name in ['ns', 'seed', 'nusers', 'ngames', 'normmethod', 'minplay', 'minusertotal',
             'nleaveout', 'maxd', 'maxgameplay']:
    opt[name] = np.array(f['opt/' + name]).ravel()
opt['slices'] = np.array(f['opt/slices']).ravel()
opt['stdscores'] = np.array(f['opt/stdscores']).ravel()
opt['normfactor'] = np.array(f['opt/normfactor'])  # (51,8)
opt['whgames'] = whg
print('stdscores shape', opt['stdscores'].shape, 'normfactor', opt['normfactor'].shape)
print('normfactor row0', opt['normfactor'][0, :])
f.close()

np.save(WORK + r'\X.npy', X)
np.save(WORK + r'\XTEST.npy', XT)
np.savez(WORK + r'\opt.npz', **opt)

# sanity: check that X matches opt.XS
f = h5py.File(matp, 'r')
XS = np.array(f['opt/XS'])
Xm = np.full((NU, NG * NS), np.nan)
for j in range(NS):
    Xm[:, j * NG:(j + 1) * NG] = XS[:, :, j].T
both = ~np.isnan(Xm) & ~np.isnan(X)
print('X vs mat agreement', both.sum(), 'maxdiff', np.nanmax(np.abs(Xm[both] - X[both])))
f.close()
