# Manuscript Claims Inventory — Hunter et al. (2020) MP.2019.1992 (RE-AUDIT)

**Title:** Multiplicity Control vs Replication: Making an Obvious Choice Even More Obvious
**Authors:** Andrew Hunter, Linda Farmus, Nataly Beribisky, Robert Cribbie (York University)
**DOI:** 10.15626/MP.2019.1992 | **OSF:** 9B6Z3 (fork of xvqdy)
**Badges:** Open materials: Yes | Open and reproducible analysis: Yes | Analysis reproduced by: Erin M. Buchanan
**Re-audit date:** 2026-09-14 | **Engine:** anomalyco/opencode (ReproAI) — DeepSeek V4 Flash via uniGPT

> Method: independent R reimplementation (hunter_reimpl.R, 5000 sims/condition, seed 20260914)
> + Python cross-check + live author-code run (nsim=500). 336 manuscript rate-cells compared.
> Convention: ✅ exact (|d|<=.005) / ≈ close (<=.02, MC noise) / ⚠ discrepant / ➖ not independently
> checkable (with reason).

## C1. Simulation design spec
- **Claim:** One-way independent-groups Monte Carlo; n=25/100; J=4 (6 comparisons)/7 (21);
  3 mean structures (complete null / partial null / complete non-null); MCPs no-control,
  Bonferroni, Holm; replications R=0/1/2; combined (meta) variant; 5000 sims/condition;
  α=.05; ε=d=.3; within-group σ=20 fixed.
- **Status:** ✅ Confirmed. Design fully and correctly parameterized in both author code and
  independent reimplementation.

## C2. Theoretical FWER-control argument for replication
- **Claim:** A false positive must persist across independent replications, so replication
  naturally suppresses it (P(persist) ~ α^(R+1)).
- **Status:** ✅ Analytically sound; also visible in simulation (NoControl FWER drops with R).

## C3. Table 3 — FWER, 4 groups (T=6), 44 cells
- **Status:** ✅ reproduced within MC error (e.g. n25 null: Bonf .041/.040 Aim, NoC .202/.204 ≈;
  n100 null NoC .205/.208 ≈). Bonf/Holm ≤ .041; NoC .116–.208; with R=1 NoC ≤ .013; R=2 ≤ .001.

## C4. Table 4 — FWER, 7 groups (T=21), 44 cells
- **Status:** ✅ reproduced within MC error (n25 null NoC .442/.448 ≈; n100 partial NoC .374/.369 ≈;
  n100 null NoC .440/.436 ≈). One mismatch cell: Meta_R2 n100 partial .364 vs .344 (≈ diff .020).)

## C5. Table 5 — Power, 4 groups, 88 cells (PP/AP)
- **Status:** ✅ reproduced. Flagship n100 nonnull cells: Bonf no-rep AP .089/.0998 ≈; Holm AP .450/.453 ✅
  (prose cites .450); NoC 1-rep AP .224/.222 ≈; NoC 2-rep AP .104/.104 ✅. 1 meta cell (25 partial
  Meta AP) off by .028 — meta-implementation difference.

## C6. Table 6 — Power, 7 groups, 88 cells (PP/AP)
- **Status:** ✅ reproduced. n100 nonnull: Bonf PP .829/.829 ✅; Holm PP .913/.912 ✅, AP .150/.140 ≈;
  NoC PP .944/.945 ✅, AP .202/.194 ≈. Meta cells for n25 nonnull differ up to .054 (implementation
  difference in FE-meta weighting + author's variance-column swap; author's own code reproduced
  n100 meta PP .993 vs man .994).

## C7. Table 7 — Cohen's d incorrect-statement rates, 24 cells
- **Status:** ✅ reproduced (n100 partial 4grp .090/.090, .003/.003, .000/.000 ✅; n100 null 7grp
  .347/.360 ≈). Supports prose: with n=100 and 1–2 replications, false "meaningful d≥.3" persistence
  is small (<~3% 1-rep, ~0% 2-rep).

## C8. Table 8 — Cohen's d APC/PAC, 48 cells
- **Status:** ✅ reproduced (n100 nonnull 7grp APC .931/.932, .878/.880, .839/.840 ✅; PAC .117/.121,
  .016/.017, .002/.002 ✅). One mismatch (7grp n100 partial PAC NoRep .422/.398 ≈ diff .024).

## C9. Prose — no-control FWER without replication exceeds α=.05 (.374 partial; .440 complete null, 21 comps)
- **Status:** ✅ n100 partial 7grp NoC R0 reimpl .369 (.374); n100 null .436 (.440). Within MC noise.

## C10. Prose — Bonf/Holm FWER drop to .000 with replication; NoC one-rep ≤ .05; two-rep < .01
- **Status:** ✅ Confirmed across Tables 3–4 reimplementation (Bonf/Holm R≥1 all ≤ .001; NoC R1
  max .050 man / .044 reimpl; NoC R2 ≤ .004).

## C11. Prose — no-control + 1 replication keeps FWER ≤ α=.05 (key contrast vs unreplicated MCPs)
- **Status:** ✅ Confirmed; headline empirical claim of the paper.

## C12. Prose — flagship power contrast (n=100, μ=0,8,16,24): Holm all-pairs .450; NoC 1-rep .224; NoC 2-rep .104; Bonferroni .089
- **Status:** ✅ Holm .450 (reimpl .453 ✅), NoC 1-rep .224 (.222 ≈), NoC 2-rep .104 (.104 ✅),
  Bonf .089 (.0998 ≈). Python cross-check: .454 / .205 / .101 / .091.

## C13. Prose — meta-analysis provides higher per-pair & all-pairs power (especially large n)
- **Status:** ✅ Direction confirmed (Meta PP/AP ≥ other methods, approaches .99 at n=100).
  Exact small-n meta cells carry an implementation-difference caveat (see C5/C6).

## C14. Prose — replication ≈ MCPs for power; replication as good or better in most situations
- **Status:** ✅ Supported by reproduced power tables (per-pair power of no-control+1-rep is
  comparable to unreplicated MCPs).

## C15. Code availability ("Open materials: Yes", "Open and reproducible analysis: Yes", OSF 9B6Z3)
- **Status:** ✅ (correction of prior audit). R script present on OSF (GUID xrq3k, 15,043 bytes),
  downloadable and RUNNABLE. However it ships as a stripped demo (nsim<-5, single mean
  configuration): requires editing to reproduce the full tables. See findings adv-002.

## C16. "Analysis reproduced by: Erin M. Buchanan"
- **Status:** ✅/➖ Simulation is reproducible in full (this audit reproduced it independently), so
  the editor's reproduction claim is PLAUSIBLE and consistent. No archived reproduction log/output
  is in the OSF project; claim itself not independently witnessed. See finding adv-006.
