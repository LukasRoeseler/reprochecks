## ReproAI audit — Forster & Neugebauer 2024
## Step 04: Supplementary checks
## - FS respondent count (480) & response rate
## - H2/H3 subgroup ethnic-migration coefficients (directional claim: insignificant, ~0)
## - 61% "realistic applicants" robustness proportion
suppressMessages({ library(haven); library(dplyr); library(sandwich); library(lmtest) })

dataDir <- "../data/pkg/replication_package_incl_data/00_data"
fe <- read_dta(file.path(dataDir, "validation_fe.dta"))
fs_raw <- read_dta(file.path(dataDir, "validation_fs.dta"))
fs <- fs_raw

cat("FE applications N:", nrow(fe), "\n")
cat("FS vignette ratings N:", nrow(fs), "\n")
cat("FS distinct respondents (ID):", length(unique(fs$ID)), "\n")
cat("FS vignettes per respondent: expect 8 ->", nrow(fs)/length(unique(fs$ID)), "\n")
cat("Implied response rate 480/3002:", 480/3002, "\n")

## factor coding for FS models
fs$fs_applicant_education <- factor(fs$fs_applicant_education)
fs$fs_achievement <- factor(fs$fs_achievement)
fs$fs_ses <- factor(fs$fs_ses)
fs$occupational_field <- factor(fs$occupational_field)
fs$fs_applicant_female <- factor(fs$fs_applicant_female)
fs$fs_applicant_migration <- factor(fs$fs_applicant_migration)
fs$wave <- factor(fs$wave)

eth <- function(d) {
  m <- lm(invitation_dich ~ relevel(fs_applicant_education,ref="2") + fs_applicant_female
          + relevel(fs_achievement,ref="2") + relevel(fs_ses,ref="2")
          + relevel(occupational_field,ref="1") + fs_applicant_migration + wave, data=d)
  V <- vcovCL(m, cluster=d$ID, type="HC1")
  cf <- coef(m); se <- sqrt(V["fs_applicant_migration1","fs_applicant_migration1"])
  c(b=unname(cf["fs_applicant_migration1"]), se=unname(se))
}

## H2: SDB groups
fs2 <- fs[!is.na(fs$socdesire_std), ]
cat("\nH2 SDB subgroups (ethnic migration coef, clustered SE):\n")
lev <- ifelse(fs2$socdesire_std <= quantile(fs2$socdesire_std,0.33,type=6),1,
         ifelse(fs2$socdesire_std <= quantile(fs2$socdesire_std,0.66,type=6),2,3))
for (x in 1:3) { r <- eth(fs2[lev==x,]); cat(sprintf("  SDB group %d: b=%.4f se=%.4f N=%d\n", x, r["b"], r["se"], sum(lev==x))) }

## H3: time_use groups
fs3 <- fs[!is.na(fs$time_use), ]
cat("\nH3 time_use subgroups:\n")
lev <- ifelse(fs3$time_use <= quantile(fs3$time_use,0.33,type=6),1,
         ifelse(fs3$time_use <= quantile(fs3$time_use,0.66,type=6),2,3))
for (x in 1:3) { r <- eth(fs3[lev==x,]); cat(sprintf("  time_use group %d: b=%.4f se=%.4f N=%d\n", x, r["b"], r["se"], sum(lev==x))) }

## H3: survatt groups (restandardize)
fs4 <- fs[!is.na(fs$survatt_std), ]
m2 <- mean(fs4$survatt_std); s2 <- sd(fs4$survatt_std)*sqrt((nrow(fs4)-1)/nrow(fs4))
fs4$sv <- (fs4$survatt_std - m2)/s2
cat("\nH3 survatt subgroups:\n")
lev <- ifelse(fs4$sv <= quantile(fs4$sv,0.33,type=6),1,
         ifelse(fs4$sv <= quantile(fs4$sv,0.66,type=6),2,3))
for (x in 1:3) { r <- eth(fs4[lev==x,]); cat(sprintf("  survatt group %d: b=%.4f se=%.4f N=%d\n", x, r["b"], r["se"], sum(lev==x))) }

## 61% realistic applicants: type_applicants==3 | 4
cat("\ntype_applicants table:\n"); print(table(fs$type_applicants))
cat("Proportion type_applicants in (3,4):", mean(fs$type_applicants %in% c(3,4)), "\n")

## 120-sec exclusion window (footnote 5): time_use max
cat("\ntime_use >=120 count:", sum(fs$time_use>=120, na.rm=TRUE), " (none if response time kept <120)\n")
cat("time_use min/max:", range(fs$time_use, na.rm=TRUE), "\n")

cat("\n==== DONE ====\n")
