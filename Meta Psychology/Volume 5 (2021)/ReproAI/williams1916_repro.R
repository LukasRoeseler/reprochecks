# Williams (2021) levels of measurement worked example
# Pet owners: Hakim (very satisfied), Jeff (moderately satisfied)
# Non-owners: Sarah (moderately dissatisfied), Ming (very dissatisfied)

# Coding rule one: Very dissatisfied=1, mod dissatisfied=2, mod satisfied=3, very satisfied=4
r1_pet <- c(4, 3)      # Hakim, Jeff
r1_nopet <- c(2, 1)    # Sarah, Ming
t1 <- t.test(r1_pet, r1_nopet, var.equal=TRUE)
cat("Rule 1 t-test: t=", unname(t1$statistic), " df=", unname(t1$parameter), " p=", unname(t1$p.value), "\n")
cat("Rule 1 means: pet=", mean(r1_pet), " nopet=", mean(r1_nopet), " diff=", mean(r1_pet)-mean(r1_nopet), "\n")

# Coding rule two: Very dissatisfied=0, mod dissatisfied=1, mod satisfied=1000, very satisfied=1002
r2_pet <- c(1002, 1000)   # Hakim, Jeff
r2_nopet <- c(1, 0)       # Sarah, Ming
t2 <- t.test(r2_pet, r2_nopet, var.equal=TRUE)
cat("Rule 2 t-test: t=", unname(t2$statistic), " df=", unname(t2$parameter), " p=", unname(t2$p.value), "\n")
cat("Rule 2 means: pet=", mean(r2_pet), " nopet=", mean(r2_nopet), " diff=", mean(r2_pet)-mean(r2_nopet), "\n")

# Mann-Whitney U test - invariant across coding rules
w1 <- wilcox.test(r1_pet, r1_nopet)
w2 <- wilcox.test(r2_pet, r2_nopet)
cat("Mann-Whitney U (rule 1): W=", unname(w1$statistic), " p=", unname(w1$p.value), "\n")
cat("Mann-Whitney U (rule 2): W=", unname(w2$statistic), " p=", unname(w2$p.value), "\n")
