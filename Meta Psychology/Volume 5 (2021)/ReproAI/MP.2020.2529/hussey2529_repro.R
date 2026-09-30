# Hussey (2021) p-hacking satire simulation - appendix code
# p_ointless <- runif(1, 0, 0.0499); p <- 0.049; compare publishability

simulation <- function() {
  p_ointless <- runif(1, 0, 0.0499)
  if (p_ointless < 0.05) { publishable_p_ointless = TRUE } else { publishable_p_ointless = FALSE }
  p <- 0.049
  if (p < 0.05) { publishable_p = TRUE } else { publishable_p = FALSE }
  return(publishable_p_ointless == publishable_p)
}

res <- replicate(10000, simulation())
cat("N =", length(res), "\n")
cat("Mean congruence =", mean(res), "\n")
cat("Percent congruent =", mean(res) * 100, "%\n")
cat("Number of TRUE =", sum(res), "\n")

# verify p_ointless always < 0.05 and p=0.049 < 0.05
cat("p_ointless range: min=", min(replicate(1000, runif(1,0,0.0499))), " max=", max(replicate(1000, runif(1,0,0.0499))), "\n")
cat("p=0.049 < 0.05? ", 0.049 < 0.05, "\n")
