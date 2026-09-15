suppressMessages(library(lme4))
suppressMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
csvfile <- args[1]
label    <- args[2]

df <- fread(csvfile)
cat("LABEL:", label, " N rows:", nrow(df), "\n")
cat("CTC / impressions given\n")
df[, success := clicks]
df[, failure := impressions - clicks]

# random intercept, fixed slopes
m1 <- glmer(cbind(success, failure) ~ positive + negative + length + complexity + platform_age + (1 | clickability_test_id),
            data = df, family = binomial, nAGQ = 0, control = glmerControl(optCtrl = list(maxfun = 1e5)))
cat("\n[Random intercept / fixed slopes] ", label, "\n")
print(summary(m1)$coefficients)

# random intercept + random slopes for positive & negative
m2 <- try(glmer(cbind(success, failure) ~ positive + negative + length + complexity + platform_age + (1 + positive + negative | clickability_test_id),
            data = df, family = binomial, nAGQ = 0, control = glmerControl(optCtrl = list(maxfun = 1e5))), silent = TRUE)
if (inherits(m2, "try-error")) {
  cat("\n[Random slopes model failed]\n")
} else {
  cat("\n[Random intercept + random slopes] ", label, "\n")
  print(summary(m2)$coefficients)
}

cat("\nDONE\n")
