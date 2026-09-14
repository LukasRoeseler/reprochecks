# ReproAI cell-by-cell comparison: Hunter et al. (2020) MP.2019.1992
# Compares the independent R reimplementation (hunter_reimpl.R, 5000 sims/cond,
# seed 20260914) against the manuscript Tables 3-8 transcribed from paper_extracted.txt.
# Classification thresholds:
#   EXACT  if |diff| <= 0.005   (matches 3-decimal rounded value / rounding noise)
#   CLOSE  if |diff| <= 0.020   (within Monte-Carlo sampling error for 5000 sims)
#   MISMATCH otherwise (> 0.020)
import csv, os

OUT = os.path.join("output")
def rd(x, d=3):
    return round(float(x), d)

RES = {"exact":0, "close":0, "mismatch":0, "mismatch_rows":[]}

def chk(label, man, reim):
    if man is None or reim is None:
        return
    d = abs(man - float(reim))
    if d <= 0.005:
        RES["exact"] += 1
    elif d <= 0.020:
        RES["close"] += 1
    else:
        RES["mismatch"] += 1
        RES["mismatch_rows"].append((label, man, round(float(reim),3), round(d,3)))

def load(fn):
    rows = list(csv.DictReader(open(os.path.join(OUT, fn), newline='')))
    return rows

# ---------- Tables 3 & 4 : FWER ----------
MS_T3 = {  # (n,mu) -> list per method order matching reimpl cols
}
# methods in reimpl col order: Bonf_R0,Holm_R0,NoC_R0,Bonf_R1,Holm_R1,NoC_R1,Meta_R1,Bonf_R2,Holm_R2,NoC_R2,Meta_R2
t3man = {
 (25,"null"):    [.041,.041,.202, .001,.001,.013,.208, .000,.000,.001,.200],
 (25,"partial"): [.023,.026,.120, .000,.000,.007,.120, .000,.000,.000,.117],
 (100,"null"):   [.038,.038,.205, .000,.000,.013,.209, .000,.000,.001,.206],
 (100,"partial"):[.022,.032,.125, .000,.000,.007,.121, .000,.000,.000,.122],
}
t4man = {
 (25,"null"):    [.039,.039,.442, .000,.000,.046,.440, .000,.000,.002,.447],
 (25,"partial"): [.028,.028,.380, .000,.000,.036,.363, .000,.000,.002,.371],
 (100,"null"):   [.043,.043,.440, .000,.000,.050,.438, .000,.000,.004,.440],
 (100,"partial"):[.028,.032,.374, .000,.000,.031,.362, .000,.000,.002,.364],
}
cols = ["Bonf_R0","Holm_R0","NoC_R0","Bonf_R1","Holm_R1","NoC_R1","Meta_R1","Bonf_R2","Holm_R2","NoC_R2","Meta_R2"]
for fn, manmap in (("table3_fwer_4groups_reimpl.csv", t3man), ("table4_fwer_7groups_reimpl.csv", t4man)):
    for row in load(fn):
        key = (int(row["n"]), row["mu"])
        if key not in manmap: continue
        for i,c in enumerate(cols):
            chk("%s %s %s" % (fn.split("_")[0], key, c), manmap[key][i], row[c])

# ---------- Tables 5 & 6 : power (PP, AP) ----------
# reimpl col order: NoRepl_Bonf_PP,AP NoRepl_Holm NoRepl_NoC  OneRep_Bonf OneRep_Holm
#   OneRep_NoC OneRep_Meta TwoRep_Bonf TwoRep_Holm TwoRep_NoC TwoRep_Meta
pcols = ["Bonf","Holm","NoC","Meta"]
colmap5 = {}
lab = {4:"5",7:"6"}
t5man = {
 ("25","partial"): {
   ("NoRev","Bonf"):(.103,.016), ("NoRev","Holm"):(.110,.025), ("NoRev","NoC"):(.288,.092),
   ("OneR","Bonf"):(.010,.000), ("OneR","Holm"):(.011,.001), ("OneR","NoC"):(.080,.008), ("OneR","Meta"):(.491,.241),
   ("TwoR","Bonf"):(.001,.000), ("TwoR","Holm"):(.001,.000), ("TwoR","NoC"):(.024,.000), ("TwoR","Meta"):(.671,.433)},
 ("25","nonnull"): {
   ("NoRev","Bonf"):(.380,.000), ("NoRev","Holm"):(.419,.000), ("NoRev","NoC"):(.567,.002),
   ("OneR","Bonf"):(.239,.000), ("OneR","Holm"):(.266,.000), ("OneR","NoC"):(.410,.000), ("OneR","Meta"):(.737,.042),
   ("TwoR","Bonf"):(.180,.000), ("TwoR","Holm"):(.201,.000), ("TwoR","NoC"):(.332,.000), ("TwoR","Meta"):(.838,.215)},
 ("100","partial"): {
   ("NoRev","Bonf"):(.566,.307), ("NoRev","Holm"):(.596,.370), ("NoRev","NoC"):(.802,.610),
   ("OneR","Bonf"):(.319,.096), ("OneR","Holm"):(.354,.139), ("OneR","NoC"):(.647,.374), ("OneR","Meta"):(.979,.948),
   ("TwoR","Bonf"):(.180,.032), ("TwoR","Holm"):(.211,.053), ("TwoR","NoC"):(.524,.233), ("TwoR","Meta"):(.998,.995)},
 ("100","nonnull"): {
   ("NoRev","Bonf"):(.782,.089), ("NoRev","Holm"):(.885,.450), ("NoRev","NoC"):(.903,.470),
   ("OneR","Bonf"):(.658,.009), ("OneR","Holm"):(.795,.203), ("OneR","NoC"):(.825,.224), ("OneR","Meta"):(.990,.941),
   ("TwoR","Bonf"):(.590,.001), ("TwoR","Holm"):(.727,.090), ("TwoR","NoC"):(.762,.104), ("TwoR","Meta"):(.999,.996)},
}
t6man = {
 ("25","partial"): {
   ("NoRev","Bonf"):(.048,.001), ("NoRev","Holm"):(.050,.002), ("NoRev","NoC"):(.287,.039),
   ("OneR","Bonf"):(.002,.000), ("OneR","Holm"):(.002,.000), ("OneR","NoC"):(.080,.001), ("OneR","Meta"):(.501,.147),
   ("TwoR","Bonf"):(.000,.000), ("TwoR","Holm"):(.000,.000), ("TwoR","NoC"):(.022,.000), ("TwoR","Meta"):(.682,.312)},
 ("25","nonnull"): {
   ("NoRev","Bonf"):(.545,.000), ("NoRev","Holm"):(.594,.000), ("NoRev","NoC"):(.742,.000),
   ("OneR","Bonf"):(.450,.000), ("OneR","Holm"):(.494,.000), ("OneR","NoC"):(.642,.000), ("OneR","Meta"):(.907,.000),
   ("TwoR","Bonf"):(.407,.000), ("TwoR","Holm"):(.448,.000), ("TwoR","NoC"):(.592,.000), ("TwoR","Meta"):(.890,.031)},
 ("100","partial"): {
   ("NoRev","Bonf"):(.405,.083), ("NoRev","Holm"):(.420,.100), ("NoRev","NoC"):(.810,.487),
   ("OneR","Bonf"):(.160,.005), ("OneR","Holm"):(.172,.008), ("OneR","NoC"):(.645,.227), ("OneR","Meta"):(.977,.903),
   ("TwoR","Bonf"):(.064,.000), ("TwoR","Holm"):(.071,.001), ("TwoR","NoC"):(.515,.106), ("TwoR","Meta"):(.998,.990)},
 ("100","nonnull"): {
   ("NoRev","Bonf"):(.829,.000), ("NoRev","Holm"):(.913,.150), ("NoRev","NoC"):(.944,.202),
   ("OneR","Bonf"):(.758,.000), ("OneR","Holm"):(.851,.021), ("OneR","NoC"):(.898,.042), ("OneR","Meta"):(.994,.874),
   ("TwoR","Bonf"):(.729,.000), ("TwoR","Holm"):(.809,.002), ("TwoR","NoC"):(.862,.007), ("TwoR","Meta"):(.999,.990)},
}
# build col accessors per reimpl row
revmap = {"NoRev":"NoRepl","OneR":"OneRep","TwoR":"TwoRep"}
for fn, manmap in (("table5_power_4groups_reimpl.csv", t5man), ("table6_power_7groups_reimpl.csv", t6man)):
    for row in load(fn):
        key = (row["n"], row["mu"])
        if key not in manmap: continue
        for rev, rem in [("NoRev","NoRepl"),("OneR","OneRep"),("TwoR","TwoRep")]:
            for meth in pcols:
                m = manmap[key].get((rev,meth))
                if m is None: continue
                ppcol = rem + "_" + meth + "_PP"
                apcol = rem + "_" + meth + "_AP"
                chk("T%s %s %s %s PP" % (lab[int(row["J"])], key, rev, meth), m[0], row[ppcol])
                chk("T%s %s %s %s AP" % (lab[int(row["J"])], key, rev, meth), m[1], row[apcol])

# ---------- Table 7 : Cohen's d incorrect ----------
t7man = {  # (J,n,mu) -> (NoRep,OneRep,TwoRep)
 (4,25,"null"):(.722,.372,.132), (4,25,"partial"):(.543,.221,.072),
 (4,100,"null"):(.156,.007,.000),(4,100,"partial"):(.090,.003,.000),
 (7,25,"null"):(.938,.714,.358), (7,25,"partial"):(.904,.612,.275),
 (7,100,"null"):(.347,.025,.002),(7,100,"partial"):(.293,.016,.000),
}
for row in load("table7_d_incorrect_reimpl.csv"):
    key=(int(row["J"]),int(row["n"]),row["mu"])
    if key in t7man:
        chk("T7 %s"%str(key), t7man[key][0], row["NoRep"])
        chk("T7 %s"%str(key), t7man[key][1], row["OneRep"])
        chk("T7 %s"%str(key), t7man[key][2], row["TwoRep"])

# ---------- Table 8 : APC / PAC ----------
# reimpl cols: PAC2,APC2,PAC1,APC1,PAC0,APC0  (reimpl has PAC first)
t8man = {  # (J,n,mu) -> dict: (rep,meth)-> val ; meth APC/PAC
}
t8 = {
 (4,25,"partial"): {"APC":(.651,.413,.268),"PAC":(.404,.155,.063)},
 (4,25,"nonnull"): {"APC":(.810,.681,.595),"PAC":(.173,.032,.005)},
 (4,100,"partial"):{"APC":(.758,.581,.443),"PAC":(.543,.301,.168)},
 (4,100,"nonnull"):{"APC":(.880,.788,.720),"PAC":(.368,.137,.051)},
 (7,25,"partial"): {"APC":(.647,.422,.270),"PAC":(.268,.070,.015)},
 (7,25,"nonnull"): {"APC":(.890,.816,.766),"PAC":(.016,.000,.000)},
 (7,100,"partial"):{"APC":(.765,.576,.431),"PAC":(.422,.170,.065)},
 (7,100,"nonnull"):{"APC":(.931,.878,.839),"PAC":(.117,.016,.002)},
}  # each tuple is (NoRep, OneRep, TwoRep)
for row in load("table8_d_power_reimpl.csv"):
    key=(int(row["J"]),int(row["n"]),row["mu"])
    if key not in t8: continue
    # APC0/1/2 and PAC0/1/2 (0=NoRep,1=OneRep,2=TwoRep)
    chk("T8 %s APC NoRep"%str(key), t8[key]["APC"][0], row["APC0"])
    chk("T8 %s APC OneRep"%str(key), t8[key]["APC"][1], row["APC1"])
    chk("T8 %s APC TwoRep"%str(key), t8[key]["APC"][2], row["APC2"])
    chk("T8 %s PAC NoRep"%str(key), t8[key]["PAC"][0], row["PAC0"])
    chk("T8 %s PAC OneRep"%str(key), t8[key]["PAC"][1], row["PAC1"])
    chk("T8 %s PAC TwoRep"%str(key), t8[key]["PAC"][2], row["PAC2"])

total = RES["exact"]+RES["close"]+RES["mismatch"]
print("===== CELL COMPARISON SUMMARY =====")
print("EXACT   (|diff|<=.005):", RES["exact"])
print("CLOSE   (|diff|<=.020):", RES["close"])
print("MISMATCH(> .020):", RES["mismatch"])
print("TOTAL cells compared:", total)
print()
print("===== MISMATCH CELLS (> .020) =====")
for r in RES["mismatch_rows"]:
    print("  %-60s man=%.3f reim=%.3f diff=%.3f" % r)
print("===== END (status: OK) =====")
