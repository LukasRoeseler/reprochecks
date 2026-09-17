import scipy.io as sio
import numpy as np
import os

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
data_dir = os.path.join(DATA, "data")
var_dir = os.path.join(DATA, "variables")

m = sio.loadmat(os.path.join(data_dir, "typicality_data27.mat"), squeeze_me=True, struct_as_record=False)
print("categories27:", list(m["categories27"]))
print("category27_subind:", m["category27_subind"], len(m["category27_subind"]))
print("best_match27:", m["best_match27"])
print("category27_ind[0]:", m["category27_ind"][0], "len:", len(m["category27_ind"][0]))
print("category27_typicality_rating_normed[0]:", m["category27_typicality_rating_normed"][0], "len:", len(m["category27_typicality_rating_normed"][0]))

# check subind mapping
for i, si in enumerate(m["category27_subind"]):
    print(i, "cat:", m["categories27"][si-1], "ind len:", len(m["category27_ind"][si-1]), "typ len:", len(m["category27_typicality_rating_normed"][si-1]))

# text files
print("\nTest data file: first 5 rows")
d = np.loadtxt(os.path.join(data_dir,"data1854_batch5_test10.txt"))
print(d.shape); print(d[:5])
print("min/max:", d.min(), d.max())

print("\nspose_embedding_49d_sorted.txt")
e = np.loadtxt(os.path.join(data_dir,"spose_embedding_49d_sorted.txt"))
print(e.shape, e.min(), e.max())

print("\ntriplets_noiseceiling.csv first 8 lines")
with open(os.path.join(data_dir,"triplets_noiseceiling.csv")) as f:
    for i in range(8):
        print(repr(f.readline()))
