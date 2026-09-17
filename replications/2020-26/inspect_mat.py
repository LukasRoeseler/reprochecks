import scipy.io as sio
import numpy as np
import os

DATA = r"C:\Users\lroesele.IVV5NET\AppData\Local\Temp\opencode\repro_pilot\downloads\osf\z2784"
data_dir = os.path.join(DATA, "data")
var_dir = os.path.join(DATA, "variables")

for name in ["RDM48_triplet.mat","RDM48_triplet_splithalf.mat","typicality_data27.mat",
             "dimension_ratings.mat","dimlabel_answers.mat","category_mat_manual.mat",
             "spose_similarity.mat","sensevec_augmented_with_wordvec.mat"]:
    p = os.path.join(data_dir, name)
    print("="*70)
    print("FILE:", name)
    m = sio.loadmat(p, squeeze_me=True, struct_as_record=False)
    for k,v in m.items():
        if k.startswith("__"): continue
        if isinstance(v, np.ndarray):
            print("  ", k, "ndarray", v.dtype, v.shape)
        elif hasattr(v, "_fieldnames"):
            print("  ", k, "STRUCT fields:", v._fieldnames)
        else:
            print("  ", k, type(v), repr(v)[:120])
        # inspect structure fields
        if hasattr(v, "_fieldnames"):
            for f in v._fieldnames:
                fv = getattr(v, f)
                if isinstance(fv, np.ndarray):
                    print("      .", f, "ndarray", fv.dtype, fv.shape, repr(fv.reshape(-1)[:5])[:150])
                else:
                    print("      .", f, type(fv), repr(fv)[:150])

print("="*70)
print("VARIABLES")
for name in ["sortind.mat","words.mat","words48.mat","unique_id.mat","labels.mat","labels_short.mat","im.mat"]:
    p = os.path.join(var_dir, name)
    print("="*70)
    print("FILE:", name)
    m = sio.loadmat(p, squeeze_me=True, struct_as_record=False)
    for k,v in m.items():
        if k.startswith("__"): continue
        if isinstance(v, np.ndarray):
            print("  ", k, "ndarray", v.dtype, v.shape, repr(v.reshape(-1)[:5])[:150])
        elif hasattr(v, "_fieldnames"):
            print("  ", k, "STRUCT fields:", v._fieldnames)
        else:
            print("  ", k, type(v), repr(v)[:150])
