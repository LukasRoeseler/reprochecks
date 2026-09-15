## ReproAI audit — Forster & Neugebauer 2024
## Step 03: Re-implement main models (H1/H2/H3) in R from shipped .dta
## Goal: reproduce headline coefficients, SEs, group Ns, cut-points, descriptives.
suppressMessages({ library(haven); library(dplyr); library(sandwich); library(lmtest) })

OUT <- "../output"
dataDir <- "../data/pkg/replication_package_incl_data/00_data"
fe <- read_dta(file.path(dataDir, "validation_fe.dta"))
fs <- read_dta(file.path(dataDir, "validation_fs.dta"))
fs_raw <- fs
fe_raw <- fe

## ---- numeric helper: compute coefficients + SE (HC1 robust for FE, cluster for FS) ----
coef_row <- function(model, term, se_type, cluster=NULL, g=NULL) {
  cf <- coef(model)
  if (se_type == "HC1") {
    V <- vcovHC(model, type="HC1")
  } else if (se_type == "cluster") {
    V <- vcovCL(model, cluster = cluster, type="HC1")
  } else {
    V <- vcov(model)
  }
  b <- cf[term]; se <- sqrt(V[term, term])
  c(estimate=unname(b), se=unname(se))
}

## ============================================================================
## DESCRIPTIVES (Table 2)
## ============================================================================
cat("\n================ DESCRIPTIVES ================\n")
# FE
cat("FE N:", nrow(fe), "\n")
cat("FE mean callback_strict:", mean(fe$callback_strict), " SD:", sd(fe$callback_strict), "\n")
cat("FE occupational_field table:\n"); print(table(fe$occupational_field))
cat("FE occupational_field proportions:\n"); print(round(prop.table(table(fe$occupational_field)),3))
# FS
cat("\nFS N:", nrow(fs), "\n")
cat("FS mean invitation_dich:", mean(fs$invitation_dich), " SD:", sd(fs$invitation_dich), "\n")
cat("FS occupational_field table:\n"); print(table(fs$occupational_field))
cat("FS occupational_field proportions:\n"); print(round(prop.table(table(fs$occupational_field)),3))
cat("FS recruiter_responsible table:\n"); print(table(fs$recruiter_responsible))
cat("FS recruiter_responsible proportions:\n"); print(round(prop.table(table(fs$recruiter_responsible)),3))
cat("FS time_use mean:", mean(fs$time_use, na.rm=TRUE), " SD:", sd(fs$time_use, na.rm=TRUE), "\n")
cat("FS socdesire_std mean:", mean(fs$socdesire_std, na.rm=TRUE), " SD:", sd(fs$socdesire_std, na.rm=TRUE), "\n")
cat("FS survatt_std mean:", mean(fs$survatt_std, na.rm=TRUE), " SD:", sd(fs$survatt_std, na.rm=TRUE), "\n")

## ============================================================================
## H1 MODELS
## ============================================================================
cat("\n================ H1 MODELS ================\n")

## FE ethnicity model (matches supplement Table S7 'main_fe')
fe_eth <- lm(callback_strict ~ factor(fe_applicant_dropout) + factor(fe_applicant_female)
             + factor(fe_applicant_migration) + factor(occupational_field) + factor(wave), data=fe)
r <- coef_row(fe_eth, "factor(fe_applicant_migration)1", "HC1")
cat("FE ethnic effect b(SE):", r["estimate"], "/", r["se"], "\n")

## FS ethnicity model (matches 'main_fs'); DV invitation_dich, cluster(ID)
fs$fs_applicant_education <- factor(fs$fs_applicant_education)
fs$fs_achievement <- factor(fs$fs_achievement)
fs$fs_ses <- factor(fs$fs_ses)
fs$occupational_field <- factor(fs$occupational_field)
fs$fs_applicant_female <- factor(fs$fs_applicant_female)
fs$fs_applicant_migration <- factor(fs$fs_applicant_migration)
fs$wave <- factor(fs$wave)

fs_eth <- lm(invitation_dich ~ relevel(fs_applicant_education, ref="2")
             + fs_applicant_female + relevel(fs_achievement, ref="2")
             + relevel(fs_ses, ref="2") + relevel(occupational_field, ref="1")
             + fs_applicant_migration + wave, data=fs)
r <- coef_row(fs_eth, "fs_applicant_migration1", "cluster", cluster=fs$ID, g=length(unique(fs$ID)))
cat("FS ethnic effect b(SE):", r["estimate"], "/", r["se"], "\n")

## FE education model (dropout 3 vs 2)  'main_fe_dropout'
fe_ed <- lm(callback_strict ~ factor(fe_applicant_dropout) + factor(fe_applicant_female)
            + factor(fe_applicant_migration) + factor(occupational_field), data=fe)
r <- coef_row(fe_ed, "factor(fe_applicant_dropout)1", "HC1")
cat("FE dropout(1) coef b(SE):", r["estimate"], "/", r["se"], "\n")

## FS education model 'main_fs_dropout'; base Abitur=2, report 3 vs 2
fs_ed <- lm(invitation_dich ~ relevel(fs_applicant_education, ref="2")
            + fs_applicant_female + relevel(fs_achievement, ref="2")
            + relevel(fs_ses, ref="2") + relevel(occupational_field, ref="1")
            + fs_applicant_migration + wave, data=fs)
r <- coef_row(fs_ed, "relevel(fs_applicant_education, ref = \"2\")3", "cluster", cluster=fs$ID)
cat("FS education 3vs2 coef b(SE):", r["estimate"], "/", r["se"], "\n")
r1 <- coef_row(fs_ed, "relevel(fs_applicant_education, ref = \"2\")1", "cluster", cluster=fs$ID)
cat("FS education 1vs2 (intermediate HS) coef b(SE):", r1["estimate"], "/", r1["se"], "\n")

## ============================================================================
## H1 SIGNIFICANCE TEST (pooled FE+FS, cluster(ID))  -- TableS7_significance
## ============================================================================
cat("\n======== H1 SIGNIFICANCE TEST (pooled) ========\n")
walk_fe <- data.frame(ID=fe_raw$ID, invitation=fe_raw$callback_strict,
                      applicant_female=as.numeric(fe_raw$fe_applicant_female),
                      applicant_migration=as.numeric(fe_raw$fe_applicant_migration),
                      applicant_education=as.numeric(fe_raw$fe_applicant_dropout)+2,  # 0->2, 1->3
                      occupational_field=as.numeric(fe_raw$occupational_field), wave=as.numeric(fe_raw$wave),
                      experiment=0)
walk_fs <- data.frame(ID=fs_raw$ID, invitation=as.numeric(fs_raw$invitation_dich),
                      applicant_female=as.numeric(fs_raw$fs_applicant_female),
                      applicant_migration=as.numeric(fs_raw$fs_applicant_migration),
                      applicant_education=as.numeric(fs_raw$fs_applicant_education),
                      occupational_field=as.numeric(fs_raw$occupational_field), wave=as.numeric(fs_raw$wave),
                      experiment=1)
sign <- rbind(walk_fe, walk_fs)
sign$applicant_education <- factor(sign$applicant_education)
sign$applicant_migration <- factor(sign$applicant_migration)
sign$applicant_female <- factor(sign$applicant_female)
sign$occupational_field <- factor(sign$occupational_field)
sign$wave <- factor(sign$wave)
sign$experiment <- factor(sign$experiment)

sig_model <- lm(invitation ~ relevel(applicant_education,ref="2")*experiment
                + applicant_migration*experiment + applicant_female*experiment
                + occupational_field*experiment + wave*experiment, data=sign)
cl <- sign$ID
V <- vcovCL(sig_model, cluster=cl, type="HC1")
cf <- coef(sig_model)
print(names(cf))
# interaction of interest: migration1:experiment1
cat("Ethnicity disparity interaction b(SE):", cf["experiment1:applicant_migration1"], "/",
    sqrt(V["experiment1:applicant_migration1","experiment1:applicant_migration1"]), "\n")
cat("Education(3) disparity interaction b(SE):", cf["relevel(applicant_education, ref = \"2\")3:experiment1"], "/",
    sqrt(V["relevel(applicant_education, ref = \"2\")3:experiment1","relevel(applicant_education, ref = \"2\")3:experiment1"]), "\n")

## ============================================================================
## H2: SDB groups
## ============================================================================
cat("\n======== H2: SDB ========\n")
fs2 <- fs
fs2 <- fs2[!is.na(fs2$socdesire_std), ]
# restandardize to final sample (Stata egen std = (x-mean)/sd with sd dividing by n)
m <- mean(fs2$socdesire_std); s <- sd(fs2$socdesire_std)*sqrt((nrow(fs2)-1)/nrow(fs2))
fs2$socdesire_std2 <- (fs2$socdesire_std - m)/ (s)
cat("Restandardized socdesire mean/sd:", mean(fs2$socdesire_std2), sd(fs2$socdesire_std2), "\n")
cat("N with non-missing socdesire:", nrow(fs2), "\n")
# Stata egen pctile default 'altdef' = type=6 (linear interp, index p*(n+1))
p33 <- unname(quantile(fs2$socdesire_std2, probs=0.33, type=6))
p66 <- unname(quantile(fs2$socdesire_std2, probs=0.66, type=6))
cat("SDB cut points p33, p66 (type=6):", p33, p66, "\n")
# Stata pctile default: uses formula p*(n+1). Let's try to match -0.29, 0.53
lev <- ifelse(fs2$socdesire_std2<=p33,1,ifelse(fs2$socdesire_std2<=p66,2,3))
cat("SDB group Ns:", table(lev), "\n")

## ============================================================================
## H3: time_use groups
## ============================================================================
cat("\n======== H3: time_use ========\n")
fs3 <- fs[!is.na(fs$time_use), ]
q33 <- unname(quantile(fs3$time_use, probs=0.33, type=6))
q66 <- unname(quantile(fs3$time_use, probs=0.66, type=6))
cat("time_use cut points p33, p66 (type=1):", q33, q66, "\n")
lev <- ifelse(fs3$time_use<=q33,1,ifelse(fs3$time_use<=q66,2,3))
cat("time_use group Ns:", table(lev), "\n")

## survatt groups
cat("\n======== H3: survatt ========\n")
fs4 <- fs[!is.na(fs$survatt_std), ]
m2 <- mean(fs4$survatt_std); s2 <- sd(fs4$survatt_std)*sqrt((nrow(fs4)-1)/nrow(fs4))
fs4$survatt_std2 <- (fs4$survatt_std - m2)/s2
p33 <- unname(quantile(fs4$survatt_std2, probs=0.33, type=6))
p66 <- unname(quantile(fs4$survatt_std2, probs=0.66, type=6))
cat("survatt N:", nrow(fs4), " cut points p33,p66:", p33, p66, "\n")
lev <- ifelse(fs4$survatt_std2<=p33,1,ifelse(fs4$survatt_std2<=p66,2,3))
cat("survatt group Ns:", table(lev), "\n")

cat("\n==== DONE ====\n")
