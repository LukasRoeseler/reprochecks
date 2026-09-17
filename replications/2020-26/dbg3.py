import numpy as np
import scipy.io as sio
import os

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))
m = sio.loadmat(os.path.join(DATA,"data","spose_similarity.mat"), squeeze_me=True, struct_as_record=False)
spose_sim = m["spose_sim"]
n = e.shape[0]
sim = e @ e.T
esim = np.exp(sim)

def direct(i,j):
    s = 0.0
    for k in range(n):
        if k==i or k==j: continue
        s += esim[i,j]/(esim[i,j]+esim[i,k]+esim[j,k])
    return s/(n-2)

pairs = [(0,1),(5,10),(100,200),(500,501),(1853,1852)]
for i,j in pairs:
    d = direct(i,j)
    print(f"({i},{j}) direct={d:.6f} spose_sim={spose_sim[i,j]:.6f} diff={d-spose_sim[i,j]:+.6f}")

# Check my vectorized formula partial: verify the per-k sum matches direct for one pair
i,j = 0,1
M = np.sum(1.0/(esim[i,j]+esim[i,:]+esim[j,:]))
sub_i = esim[i,j]/(2*esim[i,j]+esim[i,i])
sub_j = esim[i,j]/(2*esim[i,j]+esim[j,j])
calc = esim[i,j]*(M-sub_i-sub_j)/(n-2)
print("vectorized-formula value for (0,1):", calc, "direct:", direct(0,1))
