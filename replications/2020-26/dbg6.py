import numpy as np, scipy.io as sio, os
DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))
catmat = sio.loadmat(os.path.join(DATA,"data","category_mat_manual.mat"), squeeze_me=True)["category_mat_manual"].astype(int)
catmat[catmat.sum(axis=1)>1,:]=0
rmind = ~np.any(catmat, axis=1)
# Note: also remove cats 9,10 BEFORE rmind in driver; but for debugging use a subset
spose_small = e[~rmind,:]
catmat = catmat[~rmind,:]
# build with 18 cats
ncat=catmat.shape[1]
cat_sums=np.zeros((ncat,spose_small.shape[1])); cat_cnts=np.zeros(ncat)
for c in range(1,ncat+1):
    rows=np.where(catmat[:,c-1]==1)[0]
    cat_sums[c-1]=spose_small[rows].sum(axis=0); cat_cnts[c-1]=len(rows)
print("cat_cnts:", cat_cnts)
i_obj=0
lab=int(np.sum(catmat[i_obj]*np.arange(1,ncat+1)))
print("obj0 label:", lab)
sums=cat_sums.copy(); cnts=cat_cnts.copy()
if lab>0: sums[lab-1]-=spose_small[i_obj]; cnts[lab-1]-=1
centroids=sums/np.maximum(cnts,1)[:,None]
print("centroids shape:", centroids.shape, "any nan:", np.isnan(centroids).any())
print("centroid[0][:5]:", centroids[0][:5])
print("X[0][:5]:", spose_small[0][:5])
dist=np.linalg.norm(centroids-spose_small[i_obj],axis=1)
print("dist:", dist)
print("argmin:", np.argmin(dist))
# Check ordering alignment: words
words = sio.loadmat(os.path.join(DATA,"variables","words.mat"), squeeze_me=True)["words"]
# catmat rows correspond to words? check object 0 label should be animal (aardvark)
# In original 27 cat matrix, which column is animal? category order from typicality categories27
