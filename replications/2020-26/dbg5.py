import numpy as np, scipy.io as sio, os
DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))
typ = sio.loadmat(os.path.join(DATA,"data","typicality_data27.mat"), squeeze_me=True, struct_as_record=False)
categories27 = typ["categories27"]
catmat = sio.loadmat(os.path.join(DATA,"data","category_mat_manual.mat"), squeeze_me=True)["category_mat_manual"].astype(int)
categories = list(categories27)
for r in sorted([2,5,7,8,11,14,25], reverse=True):
    del categories[r-1]; catmat = np.delete(catmat, r-1, axis=1)
catmat[catmat.sum(axis=1)>1,:]=0
for r in sorted([9,10], reverse=True):
    del categories[r-1]; catmat = np.delete(catmat, r-1, axis=1)
rmind = ~np.any(catmat, axis=1)
spose_small = e[~rmind,:]
catmat = catmat[~rmind,:]
catlabels = np.sum(catmat*np.tile(np.arange(1,len(categories)+1),(catmat.shape[0],1)),axis=1)
print("n cats", len(categories), "n obj", len(catlabels))
print("catlabels unique count:", len(set(catlabels)), "min/max:", catlabels.min(), catlabels.max())
print("cat label distribution:", np.bincount(catlabels))
# check: for a sample object, is its label correct? print a few objects' spose and label
# compare to category names
print("categories:", categories)
# Check a specific known object: e.g. 'aardvark' (word index 0) -> animal cat? 
words = sio.loadmat(os.path.join(DATA,"variables","words.mat"), squeeze_me=True)["words"]
print("words[:10]:", words[:10])
# test LOO centroid quickly for a subset
ncat=len(categories)
cat_sums=np.zeros((ncat,spose_small.shape[1])); cat_cnts=np.zeros(ncat)
for c in range(1,ncat+1):
    rows=np.where(np.any(catmat==c,axis=1))[0]
    cat_sums[c-1]=spose_small[rows].sum(axis=0); cat_cnts[c-1]=len(rows)
def loo(X,labels,ncat,cat_sums,cat_cnts):
    pred=np.zeros(len(labels),dtype=int)
    for i_obj in range(len(labels)):
        lab=labels[i_obj]; sums=cat_sums.copy(); cnts=cat_cnts.copy()
        if lab>0: sums[lab-1]-=X[i_obj]; cnts[lab-1]-=1
        centroids=sums/np.maximum(cnts,1)[:,None]
        dist=np.linalg.norm(centroids-X[i_obj],axis=1)
        pred[i_obj]=int(np.argmin(dist))+1
    return pred
pred=loo(spose_small,catlabels,ncat,cat_sums,cat_cnts)
print("accuracy spose:", 100*np.mean(pred==catlabels))
print("pred distribution:", np.bincount(pred))
