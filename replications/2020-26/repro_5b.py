# Section 5b: dimension-reduction -> similarity variance (Figure 6b)
# Computes r_reduc = corr(squareform(spose_sim), squareform(spose_sim_reduc{i_dim}))
# for selected i_dim values using the (exact) vectorized embedding2sim (float32).
# O(N^3) per dimension; we compute a coarse grid then refine around the crossings.
import numpy as np, scipy.io as sio, os, time, sys, json

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
WORK = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\work\z2784"
CACHE = os.path.join(WORK, "cache")
os.makedirs(CACHE, exist_ok=True)

def embedding2sim(embedding, dtype=np.float32):
    n = embedding.shape[0]
    A = np.exp(embedding @ embedding.T).astype(dtype)
    diage = np.diag(A)
    M = np.zeros((n, n), dtype=dtype)
    for k in range(n):
        col = A[:, k][:, None]; row = A[k, :][None, :]
        M += (1.0 / (A + col + row)).astype(dtype)
    sub_i = A / (2.0 * A + diage[:, None]); sub_j = A / (2.0 * A + diage[None, :])
    cp = (A * M - sub_i - sub_j) / (n - 2)
    np.fill_diagonal(cp, 1.0)
    return cp

e = np.loadtxt(os.path.join(DATA, "data", "spose_embedding_49d_sorted.txt"))
n_obj = e.shape[0]
spose_sim = sio.loadmat(os.path.join(DATA, "data", "spose_similarity.mat"), squeeze_me=True)["spose_sim"]

def sq(M):
    iu = np.triu_indices(M.shape[0], 1); return M[iu]
v_full = sq(spose_sim)

sort_dims = np.argsort(e, axis=1)
# reduced embeddings: cumulative zeroing of weakest dims
reds = []
cur = e.copy()
for i_dim in range(1, 50):
    if i_dim > 1:
        cur = cur.copy()
    cur[np.arange(n_obj), sort_dims[np.arange(n_obj), i_dim - 1]] = 0.0
    reds.append(cur.copy())

cache_file = os.path.join(CACHE, "r_reduc_grid.json")
res = {}
if os.path.exists(cache_file):
    res = json.load(open(cache_file))
    print("loaded cache:", sorted(res.keys()), flush=True)

idims = [int(x) for x in sys.argv[1:]] if len(sys.argv) > 1 else [1, 10, 20, 30, 35, 40, 45, 49]
for i_dim in idims:
    if str(i_dim) in res:
        print("i_dim=%d cached r=%.5f" % (i_dim, res[str(i_dim)]), flush=True)
        continue
    t0 = time.time()
    sim_red = embedding2sim(reds[i_dim - 1])
    r = float(np.corrcoef(v_full, sq(sim_red))[0, 1])
    res[str(i_dim)] = r
    json.dump(res, open(cache_file, "w"))
    print("i_dim=%d r=%.5f r2=%.5f (%.1fs)" % (i_dim, r, r * r, time.time() - t0), flush=True)
print("ALL DONE")
print(json.dumps(res, indent=0))
