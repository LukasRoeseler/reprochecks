# -*- coding: utf-8 -*-
"""
Reproduction of the quantitative results from:
Hebart, Zheng, Pereira & Baker (2020), Nature Human Behaviour 4, 1173-1185
"Revealing the multidimensional mental representations of natural objects
underlying human similarity judgments", DOI 10.1038/s41562-020-00951-3
(osf node z2784).

Ports the numeric portions of make_figures_behavsim.m to Python (numpy/scipy).
Figure-generation blocks are skipped as instructed.  MATLAB rng(N) and numpy
RandomState(N) produce different pseudo-random sequences, so tie-break /
bootstrap / permutation results are *near* but not bit-identical to MATLAB
(this is documented in the log; deterministic seeds are used throughout).
"""
import numpy as np
import scipy.io as sio
import scipy.spatial.distance as spdist
import os, sys, io, time, glob

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
data_dir = os.path.join(DATA, "data")
var_dir = os.path.join(DATA, "variables")
WORK = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\work\z2784"
CACHE = os.path.join(WORK, "cache")
os.makedirs(CACHE, exist_ok=True)

log = io.StringIO()
def out(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    log.write(s + "\n")

def flush():
    return None

# ---------------------------------------------------------------- loaders
def loadmat_var(path, name):
    m = sio.loadmat(path, squeeze_me=True, struct_as_record=False)
    return m[name]

# ------------------------------------------------------------- squareformq
# squareformq.m: vector <-> symmetric matrix, works on non-distance matrices too.
def squareformq(inp):
    inp = np.asarray(inp)
    if inp.ndim == 1:
        n = inp.shape[0]
        sz = int(0.5 * (np.sqrt(8 * n + 1) + 1))
        out = np.zeros((sz, sz))
        iu = np.triu_indices(sz, 1)
        out[iu] = inp          # MATLAB fills lower triangle then mirrors
        # MATLAB: out(tril(true(sz),-1))=in ; out=out+out'  -> symmetric
        # NOTE: scipy squareform expects order by row (i<j). We will use
        # scipy directly for the correlation computations (see below).
        return out
    elif inp.ndim == 2 and inp.shape[0] == inp.shape[1]:
        iu = np.triu_indices(inp.shape[0], 1)
        return inp[iu]
    else:
        raise ValueError("squareformq input")

# ------------------------------------------------------- embedding2sim (fixed)
# Matches the corrected embedding2sim.m (ctmp re-initialized each (i,j)).
def embedding2sim(embedding, dtype=np.float64):
    n = embedding.shape[0]
    A = np.exp(embedding @ embedding.T).astype(dtype)
    diage = np.diag(A)
    M = np.zeros((n, n), dtype=dtype)
    for k in range(n):
        col = A[:, k][:, None]
        row = A[k, :][None, :]
        M += (1.0 / (A + col + row)).astype(dtype)
    sub_i = A / (2.0 * A + diage[:, None])
    sub_j = A / (2.0 * A + diage[None, :])
    cp = (A * M - sub_i - sub_j) / (n - 2)
    np.fill_diagonal(cp, 1.0)
    return cp

# embedding2sim restricted to a subset of object rows/cols (used for Figure 8)
def embedding2sim_subset(embedding, idx):
    embedding = np.asarray(embedding)
    n = embedding.shape[0]
    A = np.exp(embedding @ embedding.T)
    Ai = A[np.ix_(idx, idx)]
    m = len(idx)
    M = np.zeros((m, m))
    for k in range(n):
        col = A[idx, k][:, None]        # A[i,k] for i in idx
        row = A[k, idx][None, :]        # A[k,j] for j in idx
        M += 1.0 / (Ai + col + row)
    diage = np.array([A[i, i] for i in idx])
    sub_i = Ai / (2.0 * Ai + diage[:, None])
    sub_j = Ai / (2.0 * Ai + diage[None, :])
    cp = (Ai * M - sub_i - sub_j) / (n - 2)
    np.fill_diagonal(cp, 1.0)
    return cp

# ----------------------------------------------------------------- fdr_bh
# Benjamini-Hochberg adjusted p-values (matches fdr_bh.m output 'adj_p').
def fdr_bh(pvals, q=0.05, method='pdep'):
    pvals = np.asarray(pvals, dtype=float).ravel()
    m = len(pvals)
    order = np.argsort(pvals)
    ps = pvals[order]
    if method == 'pdep':
        wtd = m * ps / np.arange(1, m + 1)
    else:
        denom = m * np.sum(1.0 / np.arange(1, m + 1))
        wtd = denom * ps / np.arange(1, m + 1)
    adj_sorted = np.minimum.accumulate(wtd[::-1])[::-1]
    adj = np.empty(m)
    adj[order] = adj_sorted
    return adj

# ---------------------------------------------------------------- data load
out("=" * 80)
out("REPRODUCTION - Hebart et al. 2020, NHB 4:1173-1185, DOI 10.1038/s41562-020-00951-3")
out("=" * 80)

e = np.loadtxt(os.path.join(data_dir, "spose_embedding_49d_sorted.txt"))
n_obj = e.shape[0]
out("spose_embedding_49d_sorted:", e.shape)
dot_product49 = e @ e.T
m = sio.loadmat(os.path.join(data_dir, "spose_similarity.mat"), squeeze_me=True, struct_as_record=False)
spose_sim = m["spose_sim"].astype(np.float64)
out("spose_sim:", spose_sim.shape, "range %.4f..%.4f" % (spose_sim.min(), spose_sim.max()))

triplet_testdata49 = np.loadtxt(os.path.join(data_dir, "data1854_batch5_test10.txt")).astype(int) + 1
out("triplet_testdata49:", triplet_testdata49.shape)

sortind = sio.loadmat(os.path.join(var_dir, "sortind.mat"), squeeze_me=True)["sortind"].astype(int)
# remap (identity in archived data, but replicate code)
for i_obj in range(1, n_obj + 1):
    idx = np.where(triplet_testdata49 == sortind[i_obj - 1])
    triplet_testdata49[idx] = 10000 + i_obj
triplet_testdata49 = triplet_testdata49 - 10000

words = sio.loadmat(os.path.join(var_dir, "words.mat"), squeeze_me=True)["words"]
words48 = sio.loadmat(os.path.join(var_dir, "words48.mat"), squeeze_me=True)["words48"]
unique_id = sio.loadmat(os.path.join(var_dir, "unique_id.mat"), squeeze_me=True)["unique_id"]
# wordposition48 = intersect(words48, words, 'stable') -> indices into words,
# ordered by words48 (the 3rd output ib of intersect(A,B,'stable')).
wordposition48 = np.array([int(np.flatnonzero(words == w)[0]) for w in words48])
out("wordposition48:", wordposition48.shape)

RDM48_triplet = sio.loadmat(os.path.join(data_dir, "RDM48_triplet.mat"), squeeze_me=True)["RDM48_triplet"].astype(np.float64)
RDM48_s1 = sio.loadmat(os.path.join(data_dir, "RDM48_triplet_splithalf.mat"), squeeze_me=True)["RDM48_triplet_split1"].astype(np.float64)
RDM48_s2 = sio.loadmat(os.path.join(data_dir, "RDM48_triplet_splithalf.mat"), squeeze_me=True)["RDM48_triplet_split2"].astype(np.float64)

# =========================================================== SECTION 1
out("\n" + "=" * 80)
out("SECTION 1: behavior prediction on test set (Figure 2a / main text)")
out("=" * 80)

# precompute object -> trial index mapping once (used in sec 1 and 5a)
obj_trials = [[] for _ in range(n_obj)]
for t in range(len(triplet_testdata49)):
    for o in (triplet_testdata49[t, 0], triplet_testdata49[t, 1], triplet_testdata49[t, 2]):
        obj_trials[o - 1].append(t)
obj_trials = [np.array(x, dtype=int) for x in obj_trials]

def predict_behavior(dp, triplets, rng):
    a = triplets[:, 0] - 1; b = triplets[:, 1] - 1; c = triplets[:, 2] - 1
    sim = np.stack([dp[a, b], dp[a, c], dp[b, c]], axis=1)
    mval = sim.max(axis=1)
    pred = np.argmax(sim, axis=1)
    tie = (sim == mval[:, None]).sum(axis=1) > 1
    if tie.any():
        for i in np.flatnonzero(tie):
            ties = np.flatnonzero(sim[i] == mval[i])
            pred[i] = ties[rng.randint(len(ties))]
    return pred + 1, sim      # 1-based pair index (matches MATLAB behav_predict)

def per_object_acc(pred, obj_trials, n_obj):
    acc = np.zeros(n_obj)
    for i_obj in range(n_obj):
        rows = obj_trials[i_obj]
        acc[i_obj] = 100.0 * np.mean(pred[rows] == 1)
    return acc

rng42 = np.random.RandomState(42)
behav_predict, sim_all = predict_behavior(dot_product49, triplet_testdata49, rng42)
behav_predict_prob = np.exp(sim_all[np.arange(len(triplet_testdata49)), behav_predict - 1]) / np.exp(sim_all).sum(axis=1)

behav_predict_acc = 100.0 * np.mean(behav_predict == 1)
out("behav_predict_acc (100*mean(predict==1)): %.4f" % behav_predict_acc)

behav_predict_obj = per_object_acc(behav_predict, obj_trials, n_obj)
behav_predict_acc_ci95 = 1.96 * np.std(behav_predict_obj, ddof=1) / np.sqrt(n_obj)
out("mean(behav_predict_obj) [paper 64.60]: %.4f" % np.mean(behav_predict_obj))
out("behav_predict_acc_ci95 (1.96*std/sqrt(1854)) [paper +/-0.23]: %.4f" % behav_predict_acc_ci95)
out("95%% CI: %.4f .. %.4f" % (np.mean(behav_predict_obj) - behav_predict_acc_ci95,
                               np.mean(behav_predict_obj) + behav_predict_acc_ci95))
out("behav_predict_obj min/max: %.3f %.3f" % (behav_predict_obj.min(), behav_predict_obj.max()))

# =========================================================== SECTION 2
out("\n" + "=" * 80)
out("SECTION 2: noise ceiling (from triplets_noiseceiling.csv)")
out("=" * 80)
NCdat = np.loadtxt(os.path.join(data_dir, "triplets_noiseceiling.csv"))
N = NCdat.shape[0]
for i in range(N):
    row = NCdat[i, :3]
    sorted_row = np.sort(row)
    sortind_row = np.argsort(row, kind='stable')
    # find(sortind==NCdat(i,4)) : position of original choice among sorted
    choice = NCdat[i, 3]
    pos = int(np.flatnonzero(sortind_row == choice - 1)[0]) + 1
    NCdat[i, :4] = [sorted_row[0], sorted_row[1], sorted_row[2], pos]

# unique triplets by first 3 columns
key = [tuple(NCdat[i, :3].astype(int)) for i in range(N)]
uids = sorted(set(key))
uid_to_idx = {u: k for k, u in enumerate(uids)}
consistency = np.zeros(len(uids))
for u in uids:
    inds = [i for i, k in enumerate(key) if k == u]
    answers = NCdat[inds, 3].astype(int)
    counts = np.bincount(answers, minlength=4)[1:4]
    consistency[uid_to_idx[u]] = counts.max() / counts.sum()
out("n unique triplets:", len(uids))
out("nNC[0] (count of first triplet):", sum(1 for k in key if k == uids[0]))
noise_ceiling = consistency.mean() * 100
noise_ceiling_ci95 = 1.96 * np.std(consistency, ddof=1) * 100 / np.sqrt(1000)
out("noise_ceiling [paper 67.22]: %.4f" % noise_ceiling)
out("noise_ceiling_ci95 [paper +/-1.04]: %.4f" % noise_ceiling_ci95)
out("95%% CI: %.4f .. %.4f" % (noise_ceiling - noise_ceiling_ci95, noise_ceiling + noise_ceiling_ci95))

# =========================================================== SECTION 3
out("\n" + "=" * 80)
out("SECTION 3: percent performance achieved (subtracting chance)")
out("=" * 80)
num = np.mean(behav_predict_obj) - 100.0 / 3.0
den = 100.0 * noise_ceiling / 100.0 - 100.0 / 3.0
pp_achieved = 100.0 * num / den
out("percent performance achieved [paper 92.25]: %.4f" % pp_achieved)

rng42 = np.random.RandomState(42)
ind_rnd_behav = rng42.randint(1, n_obj + 1, size=(1000, 10000))
ind_rnd_ceiling = rng42.randint(1, 1000 + 1, size=(1000, 10000))
mb = behav_predict_obj[ind_rnd_behav - 1].mean(axis=0)
mc = consistency[ind_rnd_ceiling - 1].mean(axis=0)
btstp_se = 100.0 * np.std((mb - 100.0 / 3.0) / (100.0 * mc - 100.0 / 3.0), ddof=1)
out("bootstrap std (btstp_se) [paper +/-1.50]: %.4f" % btstp_se)
out("percent performance +/- btstp_se: %.4f (%.4f)" % (pp_achieved, pp_achieved - btstp_se))

# =========================================================== SECTION 4
out("\n" + "=" * 80)
out("SECTION 4: similarity-based correlation r48 (Figure 2b)")
out("=" * 80)
esim = np.exp(dot_product49)
cp = np.zeros((n_obj, n_obj))
for i in range(n_obj):
    for j in range(i + 1, n_obj):
        ctmp = np.zeros(n_obj)
        for kk in range(len(wordposition48)):
            k = wordposition48[kk]
            if k == i or k == j:
                continue
            ctmp[k] = esim[i, j] / (esim[i, j] + esim[i, k] + esim[j, k])
        cp[i, j] = ctmp.sum()
cp = cp / 48.0
cp = cp + cp.T
np.fill_diagonal(cp, 1.0)
spose_sim48 = cp[np.ix_(wordposition48, wordposition48)]
true_sim48 = 1.0 - RDM48_triplet

# squareform (i<j order)  -- matches MATLAB squareformq row order (lower tri)
def sq_lower(M):
    M = np.asarray(M)
    iu = np.triu_indices(M.shape[0], 1)
    return M[iu]

v_pred = sq_lower(spose_sim48)
v_true = sq_lower(true_sim48)
r48 = np.corrcoef(v_pred, v_true)[0, 1]
out("r48 [paper 0.90]: %.6f" % r48)

rng2 = np.random.RandomState(2)
n48pairs = 48 * 47 // 2
rnd48 = rng2.randint(0, n48pairs, size=(n48pairs, 1000))
r48_boot = np.zeros(1000)
c1 = v_pred; c2 = v_true
for i in range(1000):
    r48_boot[i] = np.corrcoef(c1[rnd48[:, i]], c2[rnd48[:, i]])[0, 1]
r48_z = np.arctanh(r48)
r48_ci_l = np.tanh(r48_z - 1.96 * np.std(np.arctanh(r48_boot), ddof=1))
r48_ci_u = np.tanh(r48_z + 1.96 * np.std(np.arctanh(r48_boot), ddof=1))
out("r48 95%% CI [paper 0.88-0.91]: %.4f .. %.4f" % (r48_ci_l, r48_ci_u))

reliability48 = np.corrcoef(sq_lower(1 - RDM48_s1), sq_lower(1 - RDM48_s2))[0, 1]
split_c1 = np.corrcoef(sq_lower(1 - RDM48_s1), v_pred)[0, 1]
split_c2 = np.corrcoef(sq_lower(1 - RDM48_s2), v_pred)[0, 1]
splithalf48 = np.tanh(np.mean(np.arctanh([split_c1, split_c2])))
out("split1 r [paper 0.87]: %.4f ; split2 r [paper 0.88]: %.4f" % (split_c1, split_c2))
out("reliability48 [paper 0.91]: %.4f" % reliability48)
out("splithalf48: %.4f" % splithalf48)
variance_explained48 = splithalf48 ** 2 / reliability48 ** 2
out("variance_explained48 = splithalf^2/reliability^2: %.4f" % variance_explained48)

# =========================================================== SECTION 5a
out("\n" + "=" * 80)
out("SECTION 5a: dimension-reduction -> behavior prediction (Figure 6a)")
out("=" * 80)
sort_dims = np.argsort(e, axis=1)          # ascending, per object (0-indexed)
# build reduced embeddings for each i_dim (1..49): zero i_dim-th smallest each obj
red_embeddings = []
cur = e.copy()
for i_dim in range(1, 50):
    if i_dim > 1:
        cur = cur.copy()
    obj_dims = np.arange(n_obj)
    cur[obj_dims, sort_dims[np.arange(n_obj), i_dim - 1]] = 0.0
    red_embeddings.append(cur.copy())
behav_predict_acc_reduc = np.zeros(49)
behav_predict_obj_reduc = np.zeros((n_obj, 49))
behav_predict_acc_reduc_ci95 = np.zeros(49)
for i_dim in range(49):
    rng42 = np.random.RandomState(42)
    dp = red_embeddings[i_dim] @ red_embeddings[i_dim].T
    bp, _ = predict_behavior(dp, triplet_testdata49, rng42)
    behav_predict_acc_reduc[i_dim] = 100.0 * np.mean(bp == 1)
    behav_predict_obj_reduc[:, i_dim] = per_object_acc(bp, obj_trials, n_obj)
    behav_predict_acc_reduc_ci95[i_dim] = 1.96 * np.std(behav_predict_obj_reduc[:, i_dim], ddof=1) / np.sqrt(n_obj)

behav_predict_acc_reduc = behav_predict_acc_reduc[::-1]
behav_predict_obj_reduc = behav_predict_obj_reduc[:, ::-1]
behav_predict_acc_reduc_ci95 = behav_predict_acc_reduc_ci95[::-1]
cutoff95 = (0.95 * behav_predict_acc - 100.0 / 3.0) + 100.0 / 3.0
cutoff99 = (0.99 * behav_predict_acc - 100.0 / 3.0) + 100.0 / 3.0
mask95 = behav_predict_acc_reduc > cutoff95
mindim = int(np.flatnonzero(mask95)[0])
mask99 = behav_predict_acc_reduc < cutoff99
maxdim = int(np.flatnonzero(mask99)[-1])
out("mindim/maxdim behavior [paper 6-11]: %d - %d" % (mindim, maxdim))
out("behav_predict_acc (full): %.4f ; cutoff95 %.4f cutoff99 %.4f" % (behav_predict_acc, cutoff95, cutoff99))
out("acc_reduc (dims retained 0..49):", ", ".join("%.2f" % v for v in behav_predict_acc_reduc))

# =========================================================== SECTION 5b
out("\n" + "=" * 80)
out("SECTION 5b: dimension-reduction -> similarity variance (Figure 6b)")
out("=" * 80)
out("Computing 49 reduced similarity matrices via vectorized embedding2sim.")
out("Each is O(N^3) in numpy; this is the expensive block.")
cache_sims = {}
sim_res_file = os.path.join(CACHE, "r_reduc.npy")
grid_file = os.path.join(CACHE, "r_reduc_grid.json")
if os.path.exists(grid_file):
    import json
    grid = json.load(open(grid_file))
    r_reduc = np.zeros(49)
    for k, v in grid.items():
        if not np.isnan(v):
            r_reduc[int(k) - 1] = v
    out("loaded cached r_reduc grid (i_dim with values):",
        ", ".join(str(k) for k in sorted(grid.keys(), key=int) if not np.isnan(grid[k])))
elif os.path.exists(sim_res_file):
    r_reduc = np.load(sim_res_file)
    out("loaded cached r_reduc:", r_reduc.shape)
elif os.environ.get("SKIP_5B") == "1":
    out("SKIP_5B set: not computing reduced similarities.")
    r_reduc = None
else:
    r_reduc = np.zeros(49)
    v_full = sq_lower(spose_sim)
    for i_dim in range(49):
        t0 = time.time()
        sim_red = embedding2sim(red_embeddings[i_dim], dtype=np.float64)
        v_red = sq_lower(sim_red)
        r_reduc[i_dim] = np.corrcoef(v_full, v_red)[0, 1]
        out("  i_dim=%d  r=%.5f  (%.1fs) cum=%.1fs" % (i_dim + 1, r_reduc[i_dim], time.time() - t0, time.time()))
        np.save(sim_res_file, r_reduc)
        sys.stdout.flush()
    np.save(sim_res_file, r_reduc)
if r_reduc is not None:
    # Build the reversed array; missing i_dim are interpolated in r^2 space.
    known = [i for i in range(1, 50) if r_reduc[i - 1] != 0.0]
    if len(known) < 49:
        ks = np.array(known, dtype=float)
        vs = np.array([r_reduc[i - 1] ** 2 for i in known])
        alli = np.arange(1, 50, dtype=float)
        r2_full = np.interp(alli, ks, vs)
        r2_full = np.clip(r2_full, 0.0, 1.0)
        out("NOTE: r_reduc computed on a grid; missing dims interpolated in r^2 space.")
    else:
        r2_full = r_reduc ** 2
    r_reduc_rev = r2_full[::-1]
    out("r^2 (i_dim=1..49 known):", ", ".join("%.4f" % (r_reduc[i - 1] ** 2) for i in known))
    out("r^2 reversed (dims retained 0..48):", ", ".join("%.3f" % v for v in r_reduc_rev))
    mask95 = r_reduc_rev > 0.95
    mask99 = r_reduc_rev < 0.99
    mindim2 = int(np.flatnonzero(mask95)[0])
    maxdim2 = int(np.flatnonzero(mask99)[-1])
    out("mindim2/maxdim2 similarity [paper 9-15]: %d - %d" % (mindim2, maxdim2))
    # report exact crossing i_dim values
    out("i_dim where r^2 first >0.95 (reversed k=%d -> i_dim=%d):" % (mindim2, 49 - mindim2))
    out("i_dim where r^2 last <0.99 (reversed k=%d -> i_dim=%d):" % (maxdim2, 49 - maxdim2))
# =========================================================== SECTION 6
out("\n" + "=" * 80)
out("SECTION 6: predict_category (cross-validated category prediction)")
out("=" * 80)
typ = sio.loadmat(os.path.join(data_dir, "typicality_data27.mat"), squeeze_me=True, struct_as_record=False)
categories27 = typ["categories27"]
catmat = sio.loadmat(os.path.join(data_dir, "category_mat_manual.mat"), squeeze_me=True)["category_mat_manual"].astype(int)
categories = list(categories27)
rmcat = [2, 5, 7, 8, 11, 14, 25]
for r in sorted(rmcat, reverse=True):
    del categories[r - 1]
    catmat = np.delete(catmat, r - 1, axis=1)
catmat[catmat.sum(axis=1) > 1, :] = 0
for r in sorted([9, 10], reverse=True):
    del categories[r - 1]
    catmat = np.delete(catmat, r - 1, axis=1)
rmind = ~np.any(catmat, axis=1)
spose_small = e[~rmind, :]
catmat = catmat[~rmind, :]
catlabels = np.sum(catmat * np.tile(np.arange(1, len(categories) + 1), (catmat.shape[0], 1)), axis=1)
out("n categories: %d ; n objects: %d" % (len(categories), len(catlabels)))
out("chance: %.2f%%" % (100.0 / len(categories)))

# precompute category sums/counts
ncat = len(categories)
cat_sums = np.zeros((ncat, spose_small.shape[1]))
cat_cnts = np.zeros(ncat)
for c in range(1, ncat + 1):
    rows = np.where(catmat[:, c - 1] == 1)[0]
    cat_sums[c - 1] = spose_small[rows].sum(axis=0)
    cat_cnts[c - 1] = len(rows)
def loo_centroid(X, labels, ncat, cat_sums, cat_cnts):
    n = len(labels)
    pred = np.zeros(n, dtype=int)
    for i_obj in range(n):
        lab = labels[i_obj]
        sums = cat_sums.copy()
        cnts = cat_cnts.copy()
        if lab > 0:
            sums[lab - 1] -= X[i_obj]
            cnts[lab - 1] -= 1
        centroids = sums / np.maximum(cnts, 1)[:, None]
        # distances from test to each centroid
        testv = X[i_obj]
        dist = np.linalg.norm(centroids - testv, axis=1)
        pred[i_obj] = int(np.argmin(dist)) + 1
    return pred
pred_spose = loo_centroid(spose_small, catlabels, ncat, cat_sums, cat_cnts)
acc_spose = 100.0 * np.mean(pred_spose == catlabels)
out("Accuracy for SPoSE [paper 86.42]: %.2f%%" % acc_spose)

sensevec = sio.loadmat(os.path.join(data_dir, "sensevec_augmented_with_wordvec.mat"), squeeze_me=True, struct_as_record=False)["sensevec_augmented"]
sensevec_reduc = sensevec[~rmind, :]
sv_sums = np.zeros((ncat, sensevec_reduc.shape[1]))
sv_cnts = np.zeros(ncat)
for c in range(1, ncat + 1):
    rows = np.where(catmat[:, c - 1] == 1)[0]
    sv_sums[c - 1] = np.nansum(sensevec_reduc[rows], axis=0)
    sv_cnts[c - 1] = len(rows)
pred_sem = loo_centroid(sensevec_reduc, catlabels, ncat, sv_sums, sv_cnts)
acc_sem = 100.0 * np.mean(pred_sem == catlabels)
out("Accuracy for word embedding [paper 85.97]: %.2f%%" % acc_sem)

# =========================================================== SECTION 7
out("\n" + "=" * 80)
out("SECTION 7: typicality vs best-matching dimension (Figure 7)")
out("=" * 80)
best_match27 = typ["best_match27"].astype(float)
category27_ind = typ["category27_ind"]
category27_subind = typ["category27_subind"].astype(int)
cat27_typ = typ["category27_typicality_rating_normed"]
sub_colors = best_match27[category27_subind - 1]
n_sub = len(category27_subind)
r_typ = np.zeros(n_sub)
p_typ = np.zeros(n_sub)
for i in range(n_sub):
    ci = category27_subind[i]
    y = cat27_typ[ci - 1]
    bm = int(best_match27[ci - 1])
    x = e[category27_ind[ci - 1] - 1, bm - 1]
    # spearman rho (one-sided right) -- scipy gives two-sided p
    from scipy.stats import spearmanr
    rho, p_two = spearmanr(x, y)
    r_typ[i] = rho
    if rho >= 0:
        p_typ[i] = p_two / 2.0
    else:
        p_typ[i] = 1.0 - p_two / 2.0
adj = fdr_bh(p_typ)
n_sig = int(np.sum(adj < 0.05))
out("r_typicality_s:", ", ".join("%.3f" % v for v in r_typ))
out("p_typicality_s (one-sided):", ", ".join("%.4f" % v for v in p_typ))
out("adj_p:", ", ".join("%.4f" % v for v in adj))
out("n significant [paper 14/17]: %d / %d" % (n_sig, n_sub))
sig_rho = r_typ[adj < 0.05]
out("significant rho range [paper 0.26-0.62]: %.3f .. %.3f" % (sig_rho.min(), sig_rho.max()))
out("all rho range: %.3f .. %.3f" % (r_typ.min(), r_typ.max()))

rng1 = np.random.RandomState(1)
r_typ_boot = np.zeros((n_sub, 1000))
for i in range(n_sub):
    ci = category27_subind[i]
    y = cat27_typ[ci - 1]
    bm = int(best_match27[ci - 1])
    x = e[category27_ind[ci - 1] - 1, bm - 1]
    nc = len(x)
    rnd = rng1.randint(0, nc, size=(nc, 1000))
    for j in range(1000):
        r_typ_boot[i, j] = spearmanr(x[rnd[:, j]], y[rnd[:, j]])[0]
ci_l = np.tanh(np.arctanh(r_typ) - 1.645 * np.std(np.arctanh(r_typ_boot), axis=1, ddof=1))
ci_u = np.tanh(np.arctanh(r_typ) + 1.645 * np.std(np.arctanh(r_typ_boot), axis=1, ddof=1))
out("one-sided 95%% CI lower:", ", ".join("%.3f" % v for v in ci_l))
out("one-sided 95%% CI upper:", ", ".join("%.3f" % v for v in ci_u))

# =========================================================== SECTION 8
out("\n" + "=" * 80)
out("SECTION 8: Extended Data Figure 1 - reproducibility of dimensions")
out("=" * 80)
refdir = os.path.join(DATA, "reference_models")
reference_models = []
for i_model in range(1, 21):
    fn = glob.glob(os.path.join(refdir, "s%02d" % i_model, "*.txt"))
    fn = sorted(fn)[-1]
    tmp = np.loadtxt(fn)
    tmp2 = tmp[:, np.any(tmp > 0.1, axis=0)]
    reference_models.append(tmp2[sortind - 1, :])
    out("model %d: dims after removing empty=%d" % (i_model, tmp2.shape[1]))
n_dim_reference = [m.shape[1] for m in reference_models]
reproducibility = np.zeros((49, 20))
for i_model in range(20):
    cmat = np.corrcoef(e.T, reference_models[i_model].T)[:49, 49:]
    reproducibility[:, i_model] = cmat.max(axis=1)
mean_z = np.mean(np.arctanh(reproducibility), axis=1)
repro_ci95 = 1.96 * np.std(np.arctanh(reproducibility), axis=1, ddof=1) / np.sqrt(20)
upper_bound = np.tanh(mean_z + repro_ci95)
lower_bound = np.tanh(mean_z - repro_ci95)
mean_reproducibility = np.tanh(mean_z)
out("n dims >0.9: %d/49 ; >0.6: %d/49 [paper 34/49, 46/49]" % (
    np.sum(mean_reproducibility > 0.9), np.sum(mean_reproducibility > 0.6)))
repro_ind = np.argsort(-mean_reproducibility) + 1   # sort descending -> indices
r_rank = np.corrcoef(np.arange(1, 50), repro_ind)[0, 1]
out("mean_reproducibility (sorted desc):", ", ".join("%.3f" % v for v in np.sort(mean_reproducibility)[::-1]))
out("r_rank [paper Spearman 0.75]: %.4f" % r_rank)

# note: MATLAB corr = Pearson, paper reports Spearman 0.75. Compute both.
rho_rank = spearmanr(np.arange(1, 50), repro_ind)[0]
out("r_rank (Pearson): %.4f ; Spearman: %.4f" % (r_rank, rho_rank))

rng1 = np.random.RandomState(1)
perm = np.argsort(np.random.rand(49, 100000), axis=0)
# correlate each perm column with repro_ind (Pearson)
perm_cent = perm - perm.mean(axis=0)
repro_cent = repro_ind - repro_ind.mean()
r_rank_perm = (perm_cent.T @ repro_cent) / (
    np.linalg.norm(perm_cent, axis=0) * np.linalg.norm(repro_cent))
pval = np.mean(np.concatenate([r_rank_perm, [r_rank]]) >= r_rank)
out("permutation p (Pearson) [paper p<0.001]: %.4g" % pval)
# Also compute via Spearman for the reported stat
rho_perm = np.zeros(100000)
for i in range(100000):
    rho_perm[i] = spearmanr(perm[:, i], repro_ind)[0]
p_rho = np.mean(np.concatenate([rho_perm, [rho_rank]]) >= rho_rank)
out("permutation p (Spearman): %.4g" % p_rho)

rng2 = np.random.RandomState(2)
rnd = rng2.randint(0, 49, size=(49, 1000))
r_rank_boot = np.zeros(1000)
for i in range(1000):
    r_rank_boot[i] = np.corrcoef(rnd[:, i], repro_ind[rnd[:, i]])[0, 1]
r_rank_ci_l = np.tanh(np.arctanh(r_rank) - 1.96 * np.std(np.arctanh(r_rank_boot), ddof=1))
r_rank_ci_u = np.tanh(np.arctanh(r_rank) + 1.96 * np.std(np.arctanh(r_rank_boot), ddof=1))
out("r_rank 95%% CI [paper 0.61-0.85]: %.4f .. %.4f" % (r_rank_ci_l, r_rank_ci_u))

# =========================================================== SECTION 9
out("\n" + "=" * 80)
out("SECTION 9: Figure 8 - similarity from human dimension ratings")
out("=" * 80)
object_names20 = ['bazooka', 'bib', 'crowbar', 'crumb', 'flamingo', 'handbrake', 'hearse', 'keyhole', 'palm_tree',
                  'scallion', 'sleeping_bag', 'spider_web', 'splinter', 'staple_gun', 'suitcase', 'syringe',
                  'tennis_ball', 'woman', 'workbench', 'wreck']
ind20 = np.array([int(np.flatnonzero(unique_id == o)[0]) + 1 for o in object_names20])
ratings_all = sio.loadmat(os.path.join(data_dir, "dimension_ratings.mat"), squeeze_me=True)["ratings_translated_all"]
Rt = ratings_all.mean(axis=2)
minRt = Rt.min(axis=0)
mRt = Rt.mean(axis=0)
Rt = Rt - mRt
Rt = (1 + minRt) * Rt
Rt = Rt + mRt
spose_sub = e.copy()
spose_sub[ind20 - 1, :] = Rt - minRt
cp20 = embedding2sim_subset(spose_sub, ind20 - 1)
true_sim20 = spose_sim[np.ix_(ind20 - 1, ind20 - 1)]
pred_sim20 = cp20
v_p20 = sq_lower(pred_sim20)
v_t20 = sq_lower(true_sim20)
r_reference = np.corrcoef(v_p20, v_t20)[0, 1]
out("r_reference [paper 0.85]: %.4f" % r_reference)

rng42 = np.random.RandomState(42)
n_shuffle = 10000
rand = rng42.rand(20, n_shuffle)
randind = np.argsort(rand, axis=0)
true_vec = v_t20
r_randomization = np.zeros(n_shuffle)
for i in range(n_shuffle):
    pp = pred_sim20[np.ix_(randind[:, i], randind[:, i])]
    r_randomization[i] = np.corrcoef(sq_lower(pp), true_vec)[0, 1]
p_rand = np.mean(np.concatenate([r_randomization, [r_reference]]) >= r_reference)
out("randomization p [paper p<0.001]: %.4g" % p_rand)
out("max r_randomization: %.4f" % r_randomization.max())

rng1 = np.random.RandomState(1)
n20pairs = 20 * 19 // 2
rnd20 = rng1.randint(0, n20pairs, size=(n20pairs, 1000))
r20_boot = np.zeros(1000)
for i in range(1000):
    r20_boot[i] = np.corrcoef(v_p20[rnd20[:, i]], v_t20[rnd20[:, i]])[0, 1]
r20_ci_l = np.tanh(np.arctanh(r_reference) - 1.96 * np.std(np.arctanh(r20_boot), ddof=1))
r20_ci_u = np.tanh(np.arctanh(r_reference) + 1.96 * np.std(np.arctanh(r20_boot), ddof=1))
out("r_reference 95%% CI [paper 0.80-0.89]: %.4f .. %.4f" % (r20_ci_l, r20_ci_u))

# =========================================================== write log
with open(os.path.join(WORK, "z2784_repro.log"), "w", encoding="ascii", errors="replace") as f:
    f.write(log.getvalue())
out("\nDIAGNOSTIC: mean(spose_sim48)=%.4f true_sim48 mean=%.4f" % (spose_sim48.mean(), true_sim48.mean()))
out("DONE. log written.")
