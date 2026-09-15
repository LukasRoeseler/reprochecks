## ReproAI audit — Forster & Neugebauer 2024
## Step 05: Consolidate manuscript-vs-reimplementation comparison table (CSV) + diagnostic figure
suppressMessages({ library(haven); library(dplyr); library(sandwich); library(lmtest); library(ggplot2) })

OUT <- "../output"
dataDir <- "../data/pkg/replication_package_incl_data/00_data"
fe <- read_dta(file.path(dataDir, "validation_fe.dta"))
fs_raw <- read_dta(file.path(dataDir, "validation_fs.dta"))
fs <- fs_raw

comp <- function(qty, manuscript, reimpl, verdict) {
  data.frame(Quantity=qty, Manuscript=manuscript, Reimplementation=reimpl, Verdict=verdict, stringsAsFactors=FALSE)
}
rows <- list(
  comp("FE applications (N)", "3,002", "3002", "OK"),
  comp("FS respondents", "480", "480 distinct IDs", "OK"),
  comp("Response rate", "16%", "480/3002 = 0.1599", "OK"),
  comp("FS vignette ratings", "3,840 (8x480)", "3840 rows; 8 per respondent", "OK"),
  comp("FE mean invitation prob (SD)", "0.54 (0.50)", "0.5410 (0.4984)", "OK"),
  comp("FS mean invitation prob (SD)", "0.59 (0.49)", "0.5932 (0.4913)", "OK"),
  comp("FE occupational field N", "655/398/1261/688", "655/398/1261/688", "OK"),
  comp("FE occupational field prop", "0.22/0.13/0.42/0.23", "0.218/0.133/0.420/0.229", "OK"),
  comp("FS occupational field N", "512/560/1944/824", "512/560/1944/824", "OK"),
  comp("FS occupational field prop", "0.13/0.15/0.50/0.22", "0.133/0.146/0.506/0.215", "ROUNDING"),
  comp("FS hiring resp. N (alone/joint/colleagues)", "632/2984/224", "632/2984/224", "OK"),
  comp("SDB scale mean (SD)", "0 (1)", "~0 (1)", "OK"),
  comp("Survey-att tilltudes scale mean (SD)", "0 (1)", "~0 (1)", "OK"),
  comp("Avg processing time per vignette (SD)", "30.78 (11.63)", "30.7848 (11.6254)", "OK"),
  comp("FE ethnic effect (migration=1)", "-0.07 (***)", "-0.0703", "OK"),
  comp("FS ethnic effect (migration=1)", "-0.001 (ns)", "-0.0012", "OK"),
  comp("Ethnicity disparity (interaction)", "b=0.070, SE=0.023", "b=0.0697, SE=0.0226", "OK"),
  comp("FE education dropout effect", "+2.8 pp (ns)", "+0.0278", "OK"),
  comp("FS education 3vs2 effect", "-0.05 (5pp)", "-0.0502", "OK"),
  comp("Education disparity (interaction)", "b=-0.080, SE=0.026", "b=-0.0801, SE=0.0259", "OK"),
  comp("FS intermediate-HS disadvantage (1vs2)", "12.2 pp", "-0.1216", "OK"),
  comp("SDB cut-offs (p33/p66)", "-0.29 / 0.53", "-0.289 / 0.528", "OK"),
  comp("SDB group N", "1600/1272/968", "1600/1272/968", "OK"),
  comp("Response-time cut-offs (p33/p66)", "24.50 / 33.25", "24.5 / 33.25", "OK"),
  comp("Response-time group N", "1280/1264/1296", "1280/1264/1296", "OK"),
  comp("Survey-attitudes cut-offs (p33/p66)", "-0.26 / 0.42", "-0.264 / 0.418", "OK"),
  comp("Survey-attitudes group N", "1720/936/1184", "1720/936/1184", "OK"),
  comp("% found profiles realistic", "61%", "0.6104 (type 3/4)", "OK")
)
cmp <- do.call(rbind, rows)
write.csv(cmp, file.path(OUT, "comparison_manuscript_reimpl.csv"), row.names=FALSE)

## Diagnostic figure: FE vs FS migration & education coefficients with CIs
fs$fs_applicant_education <- factor(fs$fs_applicant_education)
fs$fs_achievement <- factor(fs$fs_achievement); fs$fs_ses <- factor(fs$fs_ses)
fs$occupational_field <- factor(fs$occupational_field)
fs$fs_applicant_female <- factor(fs$fs_applicant_female)
fs$fs_applicant_migration <- factor(fs$fs_applicant_migration)
fs$wave <- factor(fs$wave)

mfe <- lm(callback_strict ~ factor(fe_applicant_dropout)+factor(fe_applicant_female)+
            factor(fe_applicant_migration)+factor(occupational_field)+factor(wave), data=fe)
mfs <- lm(invitation_dich ~ relevel(fs_applicant_education,ref="2")+fs_applicant_female+
            relevel(fs_achievement,ref="2")+relevel(fs_ses,ref="2")+relevel(occupational_field,ref="1")+
            fs_applicant_migration+wave, data=fs)
Vfe <- vcovHC(mfe, type="HC1"); Vfs <- vcovCL(mfs, cluster=fs$ID, type="HC1")
b_fe_m <- coef(mfe)["factor(fe_applicant_migration)1"]; se_fe_m <- sqrt(Vfe["factor(fe_applicant_migration)1","factor(fe_applicant_migration)1"])
b_fs_m <- coef(mfs)["fs_applicant_migration1"]; se_fs_m <- sqrt(Vfs["fs_applicant_migration1","fs_applicant_migration1"])
b_fe_e <- coef(mfe)["factor(fe_applicant_dropout)1"]; se_fe_e <- sqrt(Vfe["factor(fe_applicant_dropout)1","factor(fe_applicant_dropout)1"])
b_fs_e <- coef(mfs)["relevel(fs_applicant_education, ref = \"2\")3"]; se_fs_e <- sqrt(Vfs["relevel(fs_applicant_education, ref = \"2\")3","relevel(fs_applicant_education, ref = \"2\")3"])

d <- data.frame(
  study=c("FE","FS","FE","FS"),
  dim=factor(c("Ethnic background","Ethnic background","Education (dropout)","Education (dropout)"), levels=c("Ethnic background","Education (dropout)")),
  b=c(b_fe_m,b_fs_m,b_fe_e,b_fs_e),
  se=c(se_fe_m,se_fs_m,se_fe_e,se_fs_e))
d$lo <- d$b-1.96*d$se; d$hi <- d$b+1.96*d$se
p <- ggplot(d, aes(x=study, y=b, color=study)) +
  geom_point(size=3) + geom_errorbar(aes(ymin=lo, ymax=hi), width=0.12) +
  geom_hline(yintercept=0, linetype="dashed") + facet_wrap(~dim) +
  labs(x=NULL, y="Coefficient (LPM)", title="Reimplementation: FE vs FS effects") +
  theme_minimal()
ggsave(file.path(OUT, "figure_fevsfs_reimpl.png"), p, width=7, height=3.5)
cat("Wrote comparison CSV and figure\n")
cat("==== DONE ====\n")
