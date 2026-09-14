import numpy as np
import csv, os

outdir = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)\02_Rousselet_SkewedDistributions\ReproAI\Rousselet_SkewedDistributions_1630\exec_check\output"
os.makedirs(outdir, exist_ok=True)

param = np.array([[300,20,300],[300,50,300],[350,20,250],[350,50,250],
                  [400,20,200],[400,50,200],[450,20,150],[450,50,150],
                  [500,20,100],[500,50,100],[550,20,50],[550,50,50]])
tab1_median = [509,512,524,528,540,544,555,562,572,579,588,594]
tab1_skew   = [92,88,76,72,60,55,45,38,29,21,12,6]
tab2_paper = [[41,26,19,18,8,8,6,4,3,1],[39,27,21,16,10,7,5,5,3,2],
              [35,23,16,12,8,7,5,4,3,1],[35,24,16,14,8,6,5,4,3,2],
              [28,18,15,9,6,6,4,3,2,1],[26,18,12,9,7,5,4,3,2,1],
              [21,14,10,9,5,4,3,2,2,1],[18,11,8,7,5,3,3,1,1,1],
              [13,10,6,5,3,2,2,1,1,0],[9,6,4,4,2,2,1,1,1,0],
              [5,4,3,2,1,1,1,1,0,0],[2,2,1,0,1,0,0,0,0,0]]
nvec = [4,6,8,10,15,20,25,35,50,100]
rng = np.random.default_rng(20260914)  # independent generator

def exgauss(mu, sigma, tau, size):
    return rng.normal(mu, sigma, size) + rng.exponential(tau, size)

# Table 1: population medians/skewness from 1M draws (independent rng)
pop_m, pop_md = [], []
for (mu,s,t) in param:
    x = exgauss(mu,s,t,1_000_000)
    pop_m.append(np.mean(x)); pop_md.append(np.median(x))
pop_m = np.array(pop_m); pop_md = np.array(pop_md)
t1_rep_median = np.round(pop_md).astype(int)
t1_rep_skew   = np.round(pop_m - pop_md).astype(int)
med_match = int(np.sum(t1_rep_median == tab1_median))
skew_match = int(np.sum(t1_rep_skew == tab1_skew))

# Table 2: median mean bias, 10,000 sims x 10 sizes, independent rng
nsim = 10000
bias = np.zeros((12,10))
maxn = max(nvec)
# draw full 100-col samples per distribution, downsample first n cols (mirror author logic w/ independent rng)
for P,(mu,s,t) in enumerate(param):
    full = exgauss(mu,s,t,(nsim,maxn))
    for j,n in enumerate(nvec):
        meds = np.median(full[:, :n], axis=1)
        bias[P,j] = np.mean(meds) - pop_md[P]
t2_rep = np.round(bias).astype(int)
dev = t2_rep - np.array(tab2_paper)
exact = int(np.sum(dev==0)); within2 = int(np.sum(np.abs(dev)<=2))

with open(os.path.join(outdir,"python_table1_2_repl.csv"),"w",newline="") as f:
    w=csv.writer(f); w.writerow(["skew_mod","median_rep","median_paper","skew_rep","skew_paper"])
    for i in range(12):
        w.writerow([round(pop_m[i]-pop_md[i]), t1_rep_median[i], tab1_median[i], t1_rep_skew[i], tab1_skew[i]])

print("PYTHON independent recompute")
print("Table1 median matches:", med_match, "/12 ; skewness matches:", skew_match, "/12")
print("Table2 exact:", exact, "/120 ; within +-2:", within2, "/120 ; max abs dev:", int(np.max(np.abs(dev))))
print("skew rows table1:", list(t1_rep_skew))
print("table2 rep round values row sk92:", list(t2_rep[0]), "paper:", tab2_paper[0])
