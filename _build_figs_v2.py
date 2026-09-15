import os, json, statistics
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
nhb_p3pct = round(100*nhb_p3/len(nhb_ft)); nhb_p2pct = round(100*nhb_p2/len(nhb_ft))

MP_C = "#F2B30F"
NHB_C = "#0b2344"
OK="#2e7d32"; PAR="#f9a825"; BAD="#c62828"; TECH="#ef6c00"


# ============================================================ Figure 1: funnel
fig, axes = plt.subplots(1,2, figsize=(12,5.2))
for ax,(name,c_fun,stages) in zip(axes,
    [("Meta-Psychology",MP_C,[("All published records",MP_TOTAL),("Empirical",MP_EMP),("Full audit possible",MP_AUD)]),
     ("Nature Human Behavior",NHB_C,[("All published records",NHB_TOTAL),("Empirical",NHB_EMP),("Full-text audit",NHB_AUD)])]):
    labels=[s[0] for s in stages]; vals=[s[1] for s in stages]
    y=np.arange(len(stages))
    ax.barh(y, vals, color=c_fun, height=0.5, alpha=0.9)
    for yi,val in zip(y,vals):
        ax.text(val+ (0.02*max(vals,default=1)), yi, f"{val}", va="center", fontsize=11, fontweight="bold")
    ax.set_yticks(y); ax.set_yticklabels(labels, fontsize=10)
    ax.invert_yaxis(); ax.set_xlim(0, max(vals)*1.18)
    ax.set_title(name, fontsize=13, fontweight="bold")
    ax.spines[['top','right']].set_visible(False); ax.xaxis.set_visible(False)
fig.suptitle("Audit funnel: how many articles existed, were empirical, and could be audited", fontsize=14, fontweight="bold")
fig.tight_layout(rect=[0,0,1,0.95])
fig.savefig(os.path.join(OUT,"fig1_funnel.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ============================================================ Figure 2: open data (percentage)
mp_od = sum(1 for s in mp_aud if str(s.get("open_data","")).lower() in ("yes","y"))
mp_od_na = len(mp_aud)-mp_od
def pct_txt(count, denom):
    return f"{count}\n({round(100*count/denom)}%)"
fig, ax = plt.subplots(figsize=(9.5,5))
cats=["Open data present","Data N/A (simulation)","Statement only","No availability"]
mp_vals=[mp_od, mp_od_na, 0, 0]
nhb_vals=[nhb_p3, 0, nhb_p2, nhb_p1]
x=np.arange(len(cats)); w=0.38
b1=ax.bar(x-w/2, [100*v/len(mp_aud) for v in mp_vals], w, label="Meta-Psychology (audited, n=%d)"%len(mp_aud), color=MP_C)
b2=ax.bar(x+w/2, [100*v/len(nhb_ft) for v in nhb_vals], w, label="NHB (full-text audited, n=%d)"%len(nhb_ft), color=NHB_C)
for i,(v1,v2) in enumerate(zip(mp_vals,nhb_vals)):
    if v1>0: ax.annotate(pct_txt(v1,len(mp_aud)), (i-w/2, 100*v1/len(mp_aud)+1.5), ha="center", fontsize=9, fontweight="bold", color="#8a6d00")
    if v2>0: ax.annotate(pct_txt(v2,len(nhb_ft)), (i+w/2, 100*v2/len(nhb_ft)+1.5), ha="center", fontsize=9, fontweight="bold", color=NHB_C)
ax.set_xticks(x); ax.set_xticklabels(cats, fontsize=10)
ax.set_ylabel("Percentage of audited studies (%)"); ax.set_ylim(0,100)
ax.set_title("Open data availability by journal (share of audited studies)", fontsize=13, fontweight="bold")
ax.legend(); ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)
fig.tight_layout(); fig.savefig(os.path.join(OUT,"fig2_open_data.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ============================================================ Figure 3: outcomes (percentage)
fig, axes = plt.subplots(1,2, figsize=(12.5,5))
ax=axes[0]
cats=["Reproduced","Partially","Not\nreproduced","Technical"]
mp_vals=[mp_ok, mp_par+mp_na, mp_bad, mp_tech]
cols=[OK,PAR,BAD,TECH]
vals_p=[100*v/len(mp_aud) for v in mp_vals]
b=ax.bar(cats, vals_p, color=cols, alpha=0.9)
for i,v,raw in zip(range(len(cats)),vals_p,mp_vals):
    if raw>0: ax.annotate(pct_txt(raw,len(mp_aud)), (i, v+1.2), ha="center", fontsize=10, fontweight="bold")
ax.set_title("Meta-Psychology outcomes (n=%d)"%len(mp_aud), fontsize=12, fontweight="bold")
ax.set_ylim(0,105); ax.set_ylabel("Percentage of audited studies (%)"); ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)
ax=axes[1]
cats=["Direct\nlink","Statement\nonly","No\navailability"]
nhb_vals=[nhb_p3, nhb_p2, nhb_p1]
cols=[OK,PAR,BAD]
vals_p=[100*v/len(nhb_ft) for v in nhb_vals]
b=ax.bar(cats, vals_p, color=cols, alpha=0.9)
for i,v,raw in zip(range(len(cats)),vals_p,nhb_vals):
    if raw>0: ax.annotate(pct_txt(raw,len(nhb_ft)), (i, v+1.2), ha="center", fontsize=10, fontweight="bold")
ax.set_title("Nature Human Behavior availability outcome (n=%d)"%len(nhb_ft), fontsize=12, fontweight="bold")
ax.set_ylim(0,105); ax.set_ylabel("Percentage of articles (%)"); ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)
fig.suptitle("For how many did the check work, and how many had issues or big problems? (share of audited studies)", fontsize=13, fontweight="bold")
fig.tight_layout(rect=[0,0,1,0.95]); fig.savefig(os.path.join(OUT,"fig3_outcomes.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ============================================================ Figure 4: claims histograms (integers + medians)
fig, axes = plt.subplots(1,2, figsize=(12.5,5))
panels = [
    (axes[0], [s["claims"] for s in mp_aud], "Meta-Psychology", MP_C, np.arange(14, 68, 4)),
    (axes[1], [s["claims"] for s in nhb_ft], "Nature Human Behavior", NHB_C, np.arange(0, 19)),
]
for ax, vals, name, color, bins in panels:
    ax.hist(vals, bins=bins, color=color, edgecolor="white", alpha=0.9)
    med = statistics.median(vals)
    ax.axvline(med, color="#222", linestyle="--", linewidth=1.4)
    ax.set_title(f"{name} (n={len(vals)})\nmedian = {med:g} claims", fontsize=13, fontweight="bold")
    ax.set_ylim(0, None)
    # force integer x ticks
    ticks = [t for t in ax.get_xticks() if float(t).is_integer()]
    ax.set_xticks(ticks)
    ax.set_xlabel("Number of claims audited per article (full numbers)"); ax.set_ylabel("Number of studies")
    ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)
fig.suptitle("Distribution of the number of claims audited per article (dashed line = median)", fontsize=14, fontweight="bold")
fig.tight_layout(rect=[0,0,1,0.95]); fig.savefig(os.path.join(OUT,"fig4_claims_hist.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ============================================================ Study 2: OpenAlex citations
oa = json.load(open(os.path.join(OUT, "openalex_cache.json"), encoding="utf-8"))
for s in (mp_aud + nhb_ft):
    s["cites"] = oa.get(s["doi"], {}).get("cited_by_count") or 0
all_ = mp_aud + nhb_ft

def box_with_jitter(ax, groups, labels, color_map, ylog=False):
    positions = list(range(len(groups)))
    bp = ax.boxplot(list(groups), positions=positions, widths=0.5, patch_artist=True,
                    showfliers=False, medianprops=dict(color="#111"))
    for patch, lab in zip(bp["boxes"], labels):
        patch.set_facecolor(color_map.get(lab, "#999"))
        patch.set_alpha(0.55)
    for pos, grp in zip(positions, groups):
        xs = np.random.default_rng(pos).uniform(pos-0.18, pos+0.18, size=len(grp))
        ax.scatter(xs, grp, s=22, color=color_map.get(labels[pos], "#333"), alpha=0.7, edgecolor="white", linewidth=0.4)
        if grp:
            ax.annotate(f"med={statistics.median(grp):g}", (pos, np.percentile(grp,100)),
                        ha="center", va="bottom", fontsize=9, fontweight="bold")
    ax.set_xticks(positions); ax.set_xticklabels(labels, fontsize=9)
    if ylog:
        ax.set_yscale("symlog")
    ax.grid(axis="y", alpha=0.3); ax.spines[['top','right']].set_visible(False)

fig, axes = plt.subplots(1,3, figsize=(15,5))
# Overall: MP vs NHB
box_with_jitter(axes[0],
    [[s["cites"] for s in mp_aud], [s["cites"] for s in nhb_ft]],
    ["Meta-Psychology", "NHB"], { "Meta-Psychology": MP_C, "NHB": NHB_C }, ylog=True)
axes[0].set_title("Overall: citations by journal", fontsize=12, fontweight="bold")
axes[0].set_ylabel("Citations (OpenAlex) - symlog scale")
# MP by outcome
mp_group=[]; mp_lab=[]
for lab in ["Reproduced","Partially reproduced"]:
    g=[s["cites"] for s in mp_aud if s["outcome"]==lab]
    mp_group.append(g); mp_lab.append(lab)
box_with_jitter(axes[1], mp_group, mp_lab, {"Reproduced":OK,"Partially reproduced":PAR}, ylog=True)
axes[1].set_title("Meta-Psychology: citations by outcome", fontsize=12, fontweight="bold")
# NHB by outcome
nhb_group=[]; nhb_lab=[]
for lab in ["Direct data/code link","Statement only","No availability"]:
    g=[s["cites"] for s in nhb_ft if s["outcome"]==lab]
    nhb_group.append(g); nhb_lab.append(lab)
box_with_jitter(axes[2], nhb_group, nhb_lab, {"Direct data/code link":OK,"Statement only":PAR,"No availability":BAD}, ylog=True)
axes[2].set_title("NHB: citations by data availability", fontsize=12, fontweight="bold")
fig.suptitle("Is reproducibility linked to citation numbers? (Study 2)", fontsize=14, fontweight="bold")
fig.tight_layout(rect=[0,0,1,0.93]); fig.savefig(os.path.join(OUT,"fig5_citations.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ============================================================ Study 2: estimated APC costs (reported in text only)
APC_NHB = 9000.0
nhb_cost = len(nhb_ft)*APC_NHB

# remove obsolete fig3_open_repro
obsolete = os.path.join(OUT, "fig3_open_repro.png")
if os.path.exists(obsolete): os.remove(obsolete)
if os.path.exists(os.path.join(OUT,"fig4_outcomes.png")): os.remove(os.path.join(OUT,"fig4_outcomes.png"))
if os.path.exists(os.path.join(OUT,"fig5_claims_hist.png")): os.remove(os.path.join(OUT,"fig5_claims_hist.png"))

json.dump(dict(mp_total=MP_TOTAL,mp_emp=MP_EMP,mp_aud=MP_AUD,mp_ok=mp_ok,mp_par=mp_par,
               nhb_total=NHB_TOTAL,nhb_emp=NHB_EMP,nhb_aud=NHB_AUD,nhb_meta=len(nhb_meta),
               nhb_p3=nhb_p3,nhb_p2=nhb_p2,nhb_p1=nhb_p1,apc_nhb=APC_NHB,nhb_cost=nhb_cost,
               mp_cites=sum(s["cites"] for s in mp_aud), nhb_cites=sum(s["cites"] for s in nhb_ft)),
          open(os.path.join(OUT,"funnel_stats.json"),"w"), ensure_ascii=False, indent=2)
print("figures written; NHB estimated total APC EUR", nhb_cost)
