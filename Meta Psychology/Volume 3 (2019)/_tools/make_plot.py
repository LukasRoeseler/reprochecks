import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

ROOT = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI\Meta Psychology\Volume 3 (2019)"

# (label, P0, P1, P2, P3)
data = [
    ("01 Witt\nSignalDetection",   0, 0, 1, 4),
    ("02 Kuper&Bott\nMoralLicensing",0, 2, 2, 2),
    ("04 Brand\nPosteriorPassing",  0, 0, 1, 3),
    ("05 Haverkamp\nTypeIerror",    0, 2, 2, 2),
    ("07 Witt\nGraphConstruction",  0, 0, 2, 4),
    ("09 deLeeuw\nERP",             0, 0, 1, 3),
    ("10 Imhoff\nFileDrawer",       0, 1, 2, 3),
]

labels = [d[0] for d in data]
p0 = [d[1] for d in data]
p1 = [d[2] for d in data]
p2 = [d[3] for d in data]
p3 = [d[4] for d in data]

x = np.arange(len(labels))
w = 0.2

fig, ax = plt.subplots(figsize=(10.5, 5.6))
b0 = ax.bar(x - 1.5*w, p0, w, label="P0 — blocker", color="#c0392b")
b1 = ax.bar(x - 0.5*w, p1, w, label="P1 — high",     color="#e67e22")
b2 = ax.bar(x + 0.5*w, p2, w, label="P2 — medium",   color="#f1c40f")
b3 = ax.bar(x + 1.5*w, p3, w, label="P3 — low",      color="#27ae60")

# value labels on bars (only for non-zero)
for bars in (b0, b1, b2, b3):
    for b in bars:
        h = b.get_height()
        if h > 0:
            ax.annotate(f"{int(h)}", (b.get_x() + b.get_width()/2, h),
                        ha="center", va="bottom", fontsize=8, xytext=(0,1),
                        textcoords="offset points")

# totals line
totals = [a+b+c+d for a,b,c,d in zip(p0,p1,p2,p3)]
ax.plot(x, totals, color="#2c3e50", marker="o", ms=4, lw=1.4, label="Total", zorder=5)
for xi, t in zip(x, totals):
    ax.annotate(f"{t}", (xi, t), ha="center", va="bottom", fontsize=8,
                xytext=(0, 6), textcoords="offset points", color="#2c3e50")

ax.set_ylabel("Findings (count)")
ax.set_xlabel("Paper (MP.2018.###)")
ax.set_xticks(x)
ax.set_xticklabels(labels, fontsize=9)
ax.set_ylim(0, max(totals) + 1.5)
ax.yaxis.grid(True, linestyle=":", alpha=0.5)
ax.set_axisbelow(True)
for s in ("top", "right"):
    ax.spines[s].set_visible(False)
ax.legend(loc="upper left", ncol=5, fontsize=9, frameon=False)
ax.set_title("ReproAI findings by paper and severity — Meta-Psychology Vol 3 (2019)",
             fontsize=11, pad=10)
fig.tight_layout()
out = ROOT + r"\VOLUME3_FINDINGS_BY_PAPER.png"
fig.savefig(out, dpi=150)
print("Wrote", out)
