import numpy as np, time, os
DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))

def embedding2sim(embedding, dtype=np.float32):
    n = embedding.shape[0]
    A = np.exp(embedding @ embedding.T).astype(dtype)
    diage = np.diag(A)
    M = np.zeros((n, n), dtype=dtype)
    for k in range(n):
        col = A[:, k][:, None]; row = A[k, :][None, :]
        M += (1.0 / (A + col + row)).astype(dtype)
    sub_i = A / (2.0 * A + diage[:, None])
    sub_j = A / (2.0 * A + diage[None, :])
    cp = A * (M - sub_i - sub_j) / (n - 2)
    np.fill_diagonal(cp, 1.0)
    return cp

for dt in (np.float32, np.float64):
    t0=time.time(); cp=embedding2sim(e, dtype=dt); dtv=time.time()-t0
    print(dt.__name__, "time %.1fs" % dtv, "cp range %.4f..%.4f" % (cp.min(), cp.max()))
