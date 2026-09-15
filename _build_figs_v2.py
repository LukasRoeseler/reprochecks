import os, json, io
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

BASE = r"C:\Users\lroesele.IVV5NET\Claude_Code\ReproAI"
OUT = os.path.join(BASE, "Meta Psych vs NHB")
d = json.load(open(os.path.join(OUT, "studies_dashboard.json"), encoding="utf-8"))

mp = [s for s in d if s["journal"] == "Meta-Psychology"]
nhb = [s for s in d if s["journal"] == "Nature Human Behavior"]
mp_aud = [s for s in mp if s["full_text_audited"]]
nhb_ft = [s for s in nhb if s["full_text_audited"]]
nhb_meta = [s for s in nhb if not s["full_text_audited"]]

MP_TOTAL = 21; MP_EMP = len(mp); MP_AUD = len(mp_aud)
NHB_TOTAL = 164; NHB_EMP = len(nhb); NHB_AUD = len(nhb_ft)

mp_ok = sum(1 for s in mp_aud if s["outcome"]=="Reproduced")
mp_par = sum(1 for s in mp_aud if s["outcome"]=="Partially reproduced")
mp_bad = sum(1 for s in mp_aud if s["outcome"] in ("Not reproduced",))
mp_tech = sum(1 for s in mp_aud if s["status"]=="technical")
mp_na = sum(1 for s in mp_aud if s["outcome"]=="Not audited")

nhb_p3 = sum(1 for s in nhb_ft if s["severity"]=="P3")
nhb_p2 = sum(1 for s in nhb_ft if s["severity"]=="P2")
nhb_p1 = sum(1 for s in nhb_ft if s["severity"]=="P1")

MP_BLUE="#2c6fbb"; NHB_PUR="#8A2BE2"; 
OK="#2e7d32"; PAR="#f9a825"; BAD="#c62828"; TECH="#ef6c00"; GRAY="#9e9e9e"

# ---------------------------------------------------------------- Figure 1: funnel
fig, axes = plt.subplots(1,2, figsize=(12,5.2))
for ax,(name,c_fun,stages,mc) in zip(axes,
    [("Meta-Psychology",MP_BLUE,[("All published records",MP_TOTAL),("Empirical",MP_EMP),("Full audit possible",MP_AUD)],'o'),
     ("Nature Human Behavior",NHB_PUR,[("All published records",NHB_TOTAL),("Empirical",NHB_EMP),("Full-text audit",NHB_AUD)],'o')]):
    labels=[s[0] for s in stages]; vals=[s[1] for s in stages]
    y=np.arange(len(stages))
    ax.barh(y, vals, color=c_fun, height=0.5, alpha=0.85)
    for yi,val in zip(y,vals):
        ax.text(val+ (0.02*max(vals,default=1)), yi, f"{val}", va="center", fontsize=11, fontweight="bold")
    ax.set_yticks(y); ax.set_yticklabels(labels, fontsize=10)
    ax.invert_yaxis(); ax.set_xlim(0, max(vals)*1.18)
    ax.set_title(name, fontsize=13, fontweight="bold")
    ax.spines[['top','right']].set_visible(False)
    ax.xaxis.set_visible(False)
fig.suptitle("Audit funnel: how many articles existed, were empirical, and could be audited", fontsize=14, fontweight="bold")
fig.tight_layout(rect=[0,0,1,0.95])
fig.savefig(os.path.join(OUT,"fig1_funnel.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ---------------------------------------------------------------- Figure 2: open data only
mp_od = sum(1 for s in mp_aud if str(s.get("open_data","")).lower() in ("yes","y"))
mp_od_na = len(mp_aud)-mp_od   # N/A (simulation) is not "no data"
fig, ax = plt.subplots(figsize=(9,5))
cats=["Open data present","Data N/A (simulation)","Statement only","No availability"]
mp_vals=[mp_od, mp_od_na, 0, 0]
nhb_vals=[nhb_p3, 0, nhb_p2, nhb_p1]
x=np.arange(len(cats)); w=0.38
b1=ax.bar(x-w/2, mp_vals, w, label="Meta-Psychology (audited, n=14)", color=MP_BLUE)
b2=ax.bar(x+w/2, nhb_vals, w, label="NHB (full-text audited, n=%d)"%len(nhb_ft), color=NHB_PUR)
ax.set_xticks(x); ax.set_xticklabels(cats, fontsize=10)
ax.set_ylabel("Number of studies"); ax.set_ylim(0,130)
ax.set_title("Open data availability by journal", fontsize=13, fontweight="bold")
for bars in (b1,b2):
    for b in bars:
        if b.get_height()>0:
            ax.annotate(f"{b.get_height():.0f}", (b.get_x()+b.get_width()/2, b.get_height()+2), ha="center", fontsize=9.5, fontweight="bold")
ax.legend(); ax.grid(axis="y", alpha=0.3)
ax.spines[['top','right']].set_visible(False)
fig.tight_layout()
fig.savefig(os.path.join(OUT,"fig2_open_data.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ---------------------------------------------------------------- Figure 3: reproducible analysis (separate)
mp_rep = sum(1 for s in mp_aud if str(s.get("open_repro","")).lower() in ("yes","y"))
fig, ax = plt.subplots(figsize=(9,5))
# MP: open reproducible analysis vs NHB: P3 direct + P2 statement (nothing to re-run for NHB availability audit)
# Present MP reproducible-analysis outcome among audited
cats=["Reproducible-analysis\nopen (MP)","Partially / not\nopen (MP)"]
mp_vals=[mp_rep, len(mp_aud)-mp_rep]
ax.bar(cats, mp_vals, color=[OK,BAD], alpha=0.85)
for i,v in enumerate(mp_vals):
    ax.annotate(f"{v}", (i, v+0.15), ha="center", fontsize=11, fontweight="bold")
ax.set_ylim(0, max(mp_vals)+2)
ax.set_ylabel("Number of audited studies")
ax.set_title("Meta-Psychology: open reproducible analysis among audited studies (n=%d)"%len(mp_aud), fontsize=12, fontweight="bold")
ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)
fig.tight_layout()
fig.savefig(os.path.join(OUT,"fig3_open_repro.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ---------------------------------------------------------------- Figure 4: outcomes (worked vs issues)
fig, axes = plt.subplots(1,2, figsize=(12.5,5))
# MP outcomes
ax=axes[0]
cats=["Reproduced","Partially","Not\nreproduced","Technical"]
mp_vals=[mp_ok, mp_par+mp_na, mp_bad, mp_tech]
cols=[OK,PAR,BAD,TECH]
b=ax.bar(cats, mp_vals, color=cols, alpha=0.9)
for i,v in enumerate(mp_vals):
    if v>0: ax.annotate(f"{v}", (i, v+0.12), ha="center", fontsize=11, fontweight="bold")
ax.set_title("Meta-Psychology outcomes (n=%d)"%len(mp_aud), fontsize=12, fontweight="bold")
ax.set_ylim(0, max(mp_vals)+2); ax.set_ylabel("Studies"); ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)
# NHB availability outcome
ax=axes[1]
cats=["Worked\ndirect link","Issue\nstatement only","Big problem\nno availability"]
nhb_vals=[nhb_p3, nhb_p2, nhb_p1]
cols=[OK,PAR,BAD]
b=ax.bar(cats, nhb_vals, color=cols, alpha=0.9)
for i,v in enumerate(nhb_vals):
    if v>0: ax.annotate(f"{v}", (i, v+2), ha="center", fontsize=11, fontweight="bold")
ax.set_title("Nature Human Behavior availability outcome (n=%d)"%len(nhb_ft), fontsize=12, fontweight="bold")
ax.set_ylim(0, max(nhb_vals)+12); ax.set_ylabel("Articles"); ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)
fig.suptitle("For how many did the check work, and how many had issues or big problems?", fontsize=14, fontweight="bold")
fig.tight_layout(rect=[0,0,1,0.95])
fig.savefig(os.path.join(OUT,"fig4_outcomes.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

json.dump(dict(mp_total=MP_TOTAL,mp_emp=MP_EMP,mp_aud=MP_AUD,
               mp_ok=mp_ok,mp_par=mp_par,mp_bad=mp_bad,mp_tech=mp_tech,mp_na=mp_na,
               nhb_total=NHB_TOTAL,nhb_emp=NHB_EMP,nhb_aud=NHB_AUD,nhb_meta=NHB_EMP-NHB_AUD,
               nhb_p3=nhb_p3,nhb_p2=nhb_p2,nhb_p1=nhb_p1,
               mp_od=mp_od,mp_od_na=mp_od_na,mp_rep=mp_rep),
          open(os.path.join(OUT,"funnel_stats.json"),"w"), ensure_ascii=False, indent=2)
print("figures + funnel_stats written")
print(json.dumps(dict(mp_ok=mp_ok,mp_par=mp_par,nhb_aud=NHB_AUD,nhb_p3=nhb_p3,nhb_p2=nhb_p2,nhb_p1=nhb_p1)))
