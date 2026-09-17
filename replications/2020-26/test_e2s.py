import numpy as np
import scipy.io as sio
import time, os

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))
n = e.shape[0]
m = sio.loadmat(os.path.join(DATA,"data","spose_similarity.mat"), squeeze_me=True, struct_as_record=False)
spose_sim = m["spose_sim"]
print("embedding", e.shape, "spose_sim", spose_sim.shape, "range", spose_sim.min(), spose_sim.max())

def embedding2sim_vec(embedding):
    n_objects = embedding.shape[0]
    sim = embedding @ embedding.T
    esim = np.exp(sim)
    diage = np.diag(esim)
    # A[i,j] = esim[i,j]
    A = esim
    # M[i,j] = sum_k 1/(A[i,j]+A[i,k]+A[j,k])  (full, including k=i,k=j)
    M = np.zeros((n_objects, n_objects))
    ak = A[:, :]  # A[:,k]
    for k in range(n_objects):
        # C_k[i,j] = 1/(A[i,j]+A[i,k]+A[j,k])
        col = A[:, k][:, None]   # A[i,k]
        row = A[k, :][None, :]   # A[j,k]
        M += 1.0/(A + col + row)
    # cp[i,j] = A[i,j]*(M[i,j]) ; subtract k=i and k=j contributions
    # term for k=i for pair (i,j): A[i,j]/(A[i,j]+A[i,i]+A[i,j]) = A[i,j]/(2A[i,j]+A[i,i])
    # term for k=j: A[i,j]/(2A[i,j]+A[j,j])
    # Build matrix of subtracted terms
    # For k=i (index i): sub_i[i,j] = A[i,j]/(2A[i,j]+diage[i])
    sub_i = A/(2*A + diage[:, None])   # for each (i,j), uses diage[i]
    sub_j = A/(2*A + diage[None, :])   # for each (i,j), uses diage[j]
    cp = A*(M - sub_i - sub_j)
    cp = cp/(n_objects-2)
    cp = cp + cp.T
    np.fill_diagonal(cp, 1.0)
    return cp

t0=time.time()
cp = embedding2sim_vec(e)
print("time", time.time()-t0)

# squareform vector (lower triangle)
from scipy.spatial.distance import squareform
v_cp = squareform(cp, checks=False)
v_sim = squareform(spose_sim, checks=False)
print("corr full vectors:", np.corrcoef(v_cp, v_sim)[0,1])
print("max abs diff:", np.max(np.abs(cp-spose_sim)))
n2 = cp.shape[0]
print("mean cp:", cp.mean())
