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
# runnable set = direct P3 link OR data available in paper/supplement (downloadable); mirrors the report reclassification
def _is_barrier(s):
    c=(s.get("caveat") or "").lower()
    if s.get("severity")=="P1": return True
    if any(k in c for k in ('supplement','included in this','included in the','source data','data files necessary','data for','available within the article','are provided in the')):
        return False
    return True
nhb_direct = sum(1 for s in nhb_ft if not _is_barrier(s))

MP_C = "#F2B30F"
NHB_C = "#0b2344"
OK="#2e7d32"; PAR="#f9a825"; BAD="#c62828"; TECH="#ef6c00"


# ---- unit-chart helper: one rectangle per study, stacked per category, WITH x/y axes ----
import matplotlib.patches as mpatches
def unit_chart(ax, cats, vals, colors, square=0.7, per_col_max=14, gap=0.12):
    # each category = a column of one rectangle per study, counted on the y-axis
    for k, n in enumerate(vals):
        n = int(n)
        for i in range(n):
            r = i % per_col_max            # row within column
            col = i // per_col_max         # wrap into extra columns
            xx = k + 0.05 + col*(1.02)
            yy = r*(square+gap)
            rect = mpatches.Rectangle((xx, yy), square, square, facecolor=colors[k],
                                      edgecolor="white", linewidth=0.6, alpha=0.92)
            ax.add_patch(rect)
    maxrows = max((int(v)//per_col_max + (1 if int(v)%per_col_max else 0))*1 for v in vals) if vals else 1
    ax.set_xlim(-0.3, len(cats)+0.3)
    ax.set_ylim(0, maxrows*per_col_max*(square+gap))
    ax.set_xticks(range(len(cats))); ax.set_xticklabels(cats, fontsize=9)
    ax.set_yticks(np.arange(0, maxrows*per_col_max+1))
    ax.set_ylim(0, int(ax.get_ylim()[1])+1)
    ax.set_ylabel("Number of studies", fontsize=10)
    ax.spines[['top','right']].set_visible(False)
    ax.grid(axis="y", alpha=0.3)


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

# ============================================================ Figure 2: open data (unit chart, one rectangle per study)
mp_od = sum(1 for s in mp_aud if str(s.get("open_data","")).lower() in ("yes","y"))
mp_od_na = len(mp_aud)-mp_od
fig, axes = plt.subplots(1,2, figsize=(14,5), gridspec_kw={"width_ratios":[1,1]})
# meta-psychology
ax=axes[0]
cats=["Open\ndata","Data\nN/A"]
vals=[mp_od, mp_od_na]
cols=[OK,"#b0bec5"]
unit_chart(ax, cats, vals, cols)
ax.set_title(f"Meta-Psychology open data (n={len(mp_aud)})\nOpen data present: {mp_od} ({round(100*mp_od/len(mp_aud))}%)", fontsize=12, fontweight="bold")
# nhb
ax=axes[1]
cats=["Direct\nlink","Statement\nonly","No\navail."]
vals=[nhb_p3, nhb_p2, nhb_p1]
cols=[OK,PAR,BAD]
unit_chart(ax, cats, vals, cols)
ax.set_title(f"Nature Human Behavior data availability (n={len(nhb_ft)})\nDirect: {nhb_p3} ({nhb_p3pct}%) · Stmt: {nhb_p2} ({nhb_p2pct}%) · None: {nhb_p1}", fontsize=12, fontweight="bold")
# single shared legend
handles=[mpatches.Patch(facecolor=OK, label=f"Open data / direct link ({mp_od}+{nhb_p3})"),
         mpatches.Patch(facecolor=PAR, label=f"Statement only ({nhb_p2})"),
         mpatches.Patch(facecolor=BAD, label=f"No availability ({nhb_p1})"),
         mpatches.Patch(facecolor="#b0bec5", label=f"Data N/A (simulation) ({mp_od_na})")]
fig.suptitle("Open data availability by journal — each small square is one audited study", fontsize=13, fontweight="bold")
fig.legend(handles=handles, loc="lower center", ncol=4, frameon=False, fontsize=10)
fig.tight_layout(rect=[0.02,0.10,1,0.90]); fig.savefig(os.path.join(OUT,"fig2_open_data.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

# ============================================================ Figure 3: outcomes (unit chart, one rectangle per study)
fig, axes = plt.subplots(1,2, figsize=(14,5.2), gridspec_kw={"width_ratios":[1,1]})
ax=axes[0]
cats=["Reproduced","Partially","Not\nreproduced","Technical"]
mp_vals=[mp_ok, mp_par, mp_bad, mp_tech]
cols=[OK,PAR,BAD,TECH]
unit_chart(ax, cats, mp_vals, cols)
ax.set_title(f"Meta-Psychology outcomes (n={len(mp_aud)})\nReproduced: {mp_ok} · Partial: {mp_par} · Not reprod.: {mp_bad} · Technical: {mp_tech}", fontsize=12, fontweight="bold")
# NHB: only include studies where the numerical check could run (direct data/code link, n = nhb_direct)
ax=axes[1]
cats=["Check\ncould run"]
vals=[nhb_direct]
cols=[OK]
unit_chart(ax, cats, vals, cols, per_col_max=18)
ax.set_title(f"Nature Human Behavior (audit runnable only, n={nhb_direct})\nOf {len(nhb_ft)} audited: {nhb_direct} had usable data/code ({nhb_p3} direct link + {nhb_direct-nhb_p3} in paper/supplement);\n{nhb_p2-(nhb_direct-nhb_p3)} statement-only and {nhb_p1} none could not be re-run", fontsize=11, fontweight="bold")
# single shared legend
handles=[mpatches.Patch(facecolor=OK, label="Reproduced / check could run"),
         mpatches.Patch(facecolor=PAR, label="Partially reproduced"),
         mpatches.Patch(facecolor=BAD, label="Not reproduced"),
         mpatches.Patch(facecolor=TECH, label="Technical failure")]
fig.suptitle("Reproducibility outcomes — each small square is one audited study where the audit could be run", fontsize=13, fontweight="bold")
fig.legend(handles=handles, loc="lower center", ncol=4, frameon=False, fontsize=10)
fig.tight_layout(rect=[0.02,0.10,1,0.90]); fig.savefig(os.path.join(OUT,"fig3_outcomes.png"), dpi=150, bbox_inches="tight"); plt.close(fig)

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
    # force integer-only y ticks (no fractional 'Number of studies' values)
    ymax = ax.get_ylim()[1]
    yticks = np.arange(0, ymax+1).astype(int)
    if yticks[-1] < ymax:
        yticks = np.append(yticks, int(np.ceil(ymax)))
    ax.set_yticks(yticks)
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
axes[1].set_title("Meta-Psychology: citations by reproducibility outcome", fontsize=12, fontweight="bold")
# NHB: citations for the studies where the audit could run (usable data/code only)
nhb_runnable_set = [s for s in nhb_ft if not _is_barrier(s)]
box_with_jitter(axes[2], [ [s["cites"] for s in nhb_runnable_set] ],
                ["NHB (audit runnable)"], { "NHB (audit runnable)":OK }, ylog=True)
axes[2].set_title(f"NHB: citations (audit runnable, n={len(nhb_runnable_set)})", fontsize=12, fontweight="bold")
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
