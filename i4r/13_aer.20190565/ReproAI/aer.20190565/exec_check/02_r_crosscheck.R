# ReproAI independent recompute (R) of headline arithmetic — "Vulnerability and Clientelism"
# AER 112(11):3627-3659 (2022), DOI 10.1257/aer.20190565
# Second-language cross-check of the internal-consistency arithmetic done in Python,
# using only the article's own reported numbers. No replication data is available in
# this environment, so this verifies closed-form relationships, NOT the regressions.
options(warn=-1)
cat("==== START (R cross-check) ====\n")
res <- list()

add <- function(id, desc, maybe, recomp, tol) {
  d <- abs(maybe - recomp)
  v <- ifelse(d <= tol, "OK", "MISMATCH")
  res[[length(res)+1]] <<- data.frame(id=id, desc=desc, manuscript=maybe,
                                      recomputed=recomp, diff=d, verdict=v)
  if (v == "MISMATCH") cat(sprintf("[%s] MISMATCH %s: %.5f vs %.5f\n", id, desc, maybe, recomp))
}

# Table 1 binary SD checks
t1 <- list(c("R1a","Request 2012",0.213,0.409), c("R1b","Request 2013",0.086,0.280),
           c("R1c","Req+recv 2012",0.124,0.330), c("R1d","Req+recv 2013",0.039,0.193),
           c("R1e","Frequent interaction",0.184,0.387), c("R1f","Visit",0.696,0.460),
           c("R1g","Same coalition",0.718,0.450), c("R1h","All same cand",0.773,0.419),
           c("R1i","Any declared",0.485,0.500), c("R1j","Body",0.185,0.388),
           c("R1k","House",0.387,0.487), c("R1l","Rally",0.218,0.413))
for (r in t1) add(r[1], paste0("T1 SD(",r[2],")"), as.numeric(r[4]), sqrt(as.numeric(r[3])*(1-as.numeric(r[3]))), 0.011)

# % of control-mean claims
add("R2","Cisterns 3.0pp as % of ctrl mean", 0.17, 0.030/0.177, 0.005)
add("R3","Rain 2.3pp as % of ctrl mean", 0.13, 0.023/0.177, 0.005)
add("R4","Cisterns clientelist 10.9pp /0.285", 0.38, 0.109/0.285, 0.01)

# SD conversions Table 2
add("R5","Cisterns CES-D 0.14 sd", 0.14, 0.092/0.646, 0.015)
add("R6","Cisterns SRHS 0.14 sd", 0.14, 0.075/0.535, 0.015)
add("R7","Rain CES-D 0.07 sd", 0.07, 0.046/0.646, 0.015)
add("R8","Rain SRHS 0.08 sd (note)", 0.08, 0.039/0.535, 0.015)
add("R9","Rain childfood 0.05 sd", 0.05, 0.046/0.990, 0.015)

# Electoral bookkeeping
add("R10","votes 260+19+59", 338, 260+19+59, 0.5)
add("R11","incumbent 118/260", 0.45, 118/260, 0.005)
add("R12","challenger 142/260", 0.55, 142/260, 0.005)
add("R13","machines/location main 909/190", 4.8, 909/190, 0.05)
add("R14","machines/location expanded 1641/369", 4.45, 1641/369, 0.05)

# Sample arithmetic
add("R15","hh 615+693", 1308, 615+693, 5)
add("R16","clusters 189+236", 425, 189+236, 5)

df <- do.call(rbind, res)
ok <- sum(df$verdict=="OK"); mis <- sum(df$verdict=="MISMATCH")
cat(sprintf("res=%d ok=%d mismatch=%d\n", nrow(df), ok, mis))
write.csv(df, "exec_check/output/r_crosscheck.csv", row.names=FALSE)
cat("==== END (status: OK if mismatch==0) ====\n")
