import numpy as np, scipy.io as sio, os
DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
e = np.loadtxt(os.path.join(DATA,"data","spose_embedding_49d_sorted.txt"))
words = sio.loadmat(os.path.join(DATA,"variables","words.mat"), squeeze_me=True)["words"]
words48 = sio.loadmat(os.path.join(DATA,"variables","words48.mat"), squeeze_me=True)["words48"]

# correct wordposition48 ordered by words48
wp48 = np.array([int(np.flatnonzero(words==w)[0]) for w in words48])
print("wp48 (words48 order):", wp48[:10], "...")
# my old (words order)
seen=set(); wp_old=[]
for i,w in enumerate(words):
    if w in words48 and w not in seen:
        seen.add(w); wp_old.append(i)
print("wp_old differs:", not np.array_equal(wp48, np.array(wp_old)))

# Verify embedding alignment: row i corresponds to words[i]?
# Test: object 'pizza' (words48[0]). Its embedding row should be at index where words=='pizza'
pz = int(np.flatnonzero(words=='pizza')[0])
print("pizza word index:", pz)
# check embedding dot product pizza vs itself large
dp = e @ e.T
print("dp[pz,pz]:", dp[pz,pz])
# check that wp48 rows are distinct
print("wp48 distinct:", len(set(wp48)))

# Behavior prediction distribution
t = np.loadtxt(os.path.join(DATA,"data","data1854_batch5_test10.txt")).astype(int)+1
print("test rows:", t.shape)
a=t[:,0]-1; b=t[:,1]-1; c=t[:,2]-1
sim = np.stack([dp[a,b], dp[a,c], dp[b,c]],axis=1)
pred = np.argmax(sim,axis=1)
print("pred pair distribution (0,1,2):", np.bincount(pred,minlength=3)/len(pred))
# Are there ties?
mval=sim.max(axis=1)
ntie = (sim==mval[:,None]).sum(axis=1)>1
print("n ties:", ntie.sum())
