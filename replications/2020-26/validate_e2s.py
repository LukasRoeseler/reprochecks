import numpy as np, time, os, scipy.io as sio
DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))
spose_sim = sio.loadmat(os.path.join(DATA,"data","spose_similarity.mat"), squeeze_me=True)["spose_sim"]

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

t0=time.time(); cp = embedding2sim(e); print("time %.1fs" % (time.time()-t0))
print("cp range %.6f .. %.6f" % (cp.min(), cp.max()))
def sq(M):
    iu=np.triu_indices(M.shape[0],1); return M[iu]
vc=sq(cp); vs=sq(spose_sim)
print("corr(sq(cp), sq(spose_sim)) = %.6f" % np.corrcoef(vc,vs)[0,1])
print("mean abs diff:", np.abs(cp-spose_sim)[~np.eye(len(cp),dtype=bool)].mean())
print("max abs diff:", np.abs(cp-spose_sim)[~np.eye(len(cp),dtype=bool)].max())
