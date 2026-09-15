import os, json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
d = json.load(open(os.path.join(OUT,"studies_consolidated.json"), encoding="utf-8"))

def cnt(pred):
    return sum(1 for s in d if pred(s))

# Figure 4: full-text (PDF/materials) audit coverage by journal
fig, ax = plt.subplots(figsize=(8,5))
journals = ["Meta-Psychology","Nature Human Behavior"]
total = [cnt(lambda s: s["journal"]=="Meta-Psychology"), cnt(lambda s: s["journal"]=="Nature Human Behavior")]
ft = [cnt(lambda s: s["journal"]=="Meta-Psychology" and s["full_text_audited"]),
      cnt(lambda s: s["journal"]=="Nature Human Behavior" and s["full_text_audited"])]
x=np.arange(2); w=0.38
ax.bar(x-w/2, total, w, label="Studies in audit corpus", color="#999")
ax.bar(x+w/2, ft, w, label="Audited with full text/materials", color="#2c6fbb")
ax.set_xticks(x); ax.set_xticklabels(journals)
ax.set_ylabel("Number of studies")
ax.set_title("Full-text vs metadata-level ReproAI audits by journal")
for i in range(2):
    ax.annotate(total[i],(x[i]-w/2,total[i]+1),ha="center",fontsize=10)
    ax.annotate(f"{ft[i]} ({100*ft[i]/max(1,total[i]):.0f}%)",(x[i]+w/2,ft[i]+1),ha="center",fontsize=10)
ax.legend(); ax.grid(axis="y",alpha=0.3)
p=os.path.join(OUT,"fig4_fulltext_coverage.png")
fig.savefig(p,dpi=150,bbox_inches="tight"); plt.close(fig)
print("wrote",p)

# Figure 5: severity distribution across both journals (comparable on availability/openness)
# NHB severity only meaningful; MP outcome
# Better: overall finding severity for NHB, outcome for MP -> combine as stacked
pass
