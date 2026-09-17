import numpy as np
import scipy.io as sio
import os

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))
m = sio.loadmat(os.path.join(DATA,"data","spose_similarity.mat"), squeeze_me=True, struct_as_record=False)
spose_sim = m["spose_sim"]

sim = e @ e.T
print("dot range:", sim.min(), sim.max())
esim = np.exp(sim)
print("exp has inf:", np.isinf(esim).any(), "nan:", np.isnan(esim).any())
print("esim max:", esim.max())

# Where does spose_sim have value 1 outside diagonal?
n=1854
off = ~np.eye(n, dtype=bool)
print("num off-diag ==1:", np.sum((spose_sim==1)&off))
print("spose_sim diag range:", np.diag(spose_sim).min(), np.diag(spose_sim).max())
# spose_sim off-diag min:
print("spose_sim offdiag min/max:", spose_sim[off].min(), spose_sim[off].max())
