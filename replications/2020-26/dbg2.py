import numpy as np
import scipy.io as sio
import os, collections

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
var_dir = os.path.join(DATA,"variables")
data_dir = os.path.join(DATA,"data")

m = sio.loadmat(os.path.join(var_dir,"sortind.mat"), squeeze_me=True, struct_as_record=False)
sortind = m["sortind"]
print("sortind dtype:", sortind.dtype, "shape", sortind.shape)
print("sortind[:20]:", sortind[:20])
print("is permutation (sorted==1..1854):", np.array_equal(np.sort(sortind), np.arange(1,1855)))
print("sortind[0:3]:", sortind[0:3], "sortind[-3:]:", sortind[-3:])

words = sio.loadmat(os.path.join(var_dir,"words.mat"), squeeze_me=True)["words"]
words48 = sio.loadmat(os.path.join(var_dir,"words48.mat"), squeeze_me=True)["words48"]
print("words48:", list(words48))
# intersect(words48, words, 'stable')
w48 = set()
idx48 = []
for i,w in enumerate(words):
    if w in words48 and w not in w48:
        w48.add(w); idx48.append(i)
print("wordposition48 (stable, in words order):", idx48)
print("len wordposition48:", len(idx48))
print("expected 48", len(words48))

# noise ceiling
nc = np.loadtxt(os.path.join(data_dir,"triplets_noiseceiling.csv"))
print("noise ceiling shape:", nc.shape)
print("col5 unique:", np.unique(nc[:,4])[:10], "n unique:", len(np.unique(nc[:,4])))
# unique triplets by first 3 cols
trip = nc[:,0:3].astype(int)
keys = [tuple(np.sort(t)) for t in trip]
u = set(keys)
print("n unique triplets:", len(u))
print("n rows per triplet sample:", collections.Counter(keys).most_common(3))
