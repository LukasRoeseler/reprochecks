import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

papers = [
    ("01 Niemeyer", 0, 0, 0, 0, 0),
    ("02 Rousselet", 0, 0, 1, 2, 3),
    ("03 Brunner", 0, 0, 3, 2, 5),
    ("04 Hunter", 0, 0, 3, 1, 4),
    ("05 Lakens", 0, 0, 0, 1, 1),
    ("10 Williams", 0, 0, 2, 0, 2),
    ("11 Francis", 0, 0, 3, 0, 3),
]

labels = [p[0] for p in papers]
p0 = [p[1] for p in papers]
p1 = [p[2] for p in papers]
p2 = [p[3] for p in papers]
p3 = [p[4] for p in papers]
total = [p[5] for p in papers]

x = np.arange(len(labels))
w = 0.5

fig, ax = plt.subplots(figsize=(10, 5))
b0 = ax.bar(x, p0, w, label='P0', color='#dc3545')
b1 = ax.bar(x, p1, w, bottom=p0, label='P1', color='#fd7e14')
b2 = ax.bar(x, p2, w, bottom=np.array(p0)+np.array(p1), label='P2', color='#ffc107')
b3 = ax.bar(x, p3, w, bottom=np.array(p0)+np.array(p1)+np.array(p2), label='P3', color='#6c757d')

ax.set_xlabel('Paper')
ax.set_ylabel('Findings')
ax.set_title('ReproAI Findings by Paper - Meta-Psychology Volume 4 (2020)')
ax.set_xticks(x)
ax.set_xticklabels(labels, rotation=15, ha='right')
ax.legend()

for i, t in enumerate(total):
    ax.text(i, t + 0.1, str(t), ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig(r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 4 (2020)\VOLUME4_FINDINGS_PLOT.png", dpi=150)
print("Plot saved")