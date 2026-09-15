suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"

## Re-run meta to add p-value + 99.9 significance classification
library(metafor); library(effectsize)
st0 <- read.csv(file.path(base,"repo_data/Studies.csv"), stringsAsFactors=FALSE, check.names=FALSE, na.strings=c("-999","","#N/A"))
names(st0) <- make.names(names(st0), unique=TRUE)
st <- st0 %>% rename(effect_size_id=Effect.Size.ID, study_author=Study.Author, study_year=Study.Year,
  study_n=Study.N, estimate=Estimate, metric=Metric, lower_ci=Lower.CI, upper_ci=Upper.CI,
  standard_error=Standard.Error, standard_deviation=Standard.Deviation)
translate_tests <- function(stat){ s<-tolower(trimws(stat)); dplyr::case_when(
  s %in% c("beta","beta coefficient","standardised regression coefficient")~"b",
  s %in% c("adjusted smd","average effect size","cohen d","cohen's d","effect size (type unclear)","g","g+","hedge's g","hedges g","hedges' d","hedge's d","hedges' g","median effect size","pooled mean effect size","smd","standard mean difference","standardised difference in the means","standardized mean difference","standarised mean difference","std mean difference","std. mean difference","standardised mean difference")~"d",
  s %in% c("mean","mean difference","pooled mean difference","pre-post difference mean","unstandardized mean difference","weighted mean","weighted mean difference")~"md",
  s %in% c("attenuated correlation (uncorrected correlation)","corrected correlation","correlation","correlation coefficient","pearson's r","weighted mean correlation coefficient","r = uncorrected sample-weighted mean effect size")~"r",
  s %in% c("fisher z","fisher's z","z fischer","z fisher","fisher’s z","fisher's z")~"z",
  s %in% c("log odds ratio")~"lor",
  s %in% c("odd ratio","odds ratio","odds ratio iv","pooled fixed effect -odd ratio","pooled odds ratio")~"or",
  s %in% c("rate ratio","relative risk","risk ratio")~"rr",
  s %in% c("mean tau-u","tau-u")~NA_character_, TRUE~s)}
d_to_r<-function(d){a<-sqrt(d^2+4); d/a}; z_to_r<-function(z)tanh(z)
st <- st %>% mutate(cm=translate_tests(metric)) %>% group_by(effect_size_id) %>%
  mutate(study_n=ifelse(is.na(study_n),round(mean(study_n,na.rm=TRUE)),study_n)) %>% ungroup() %>%
  filter(cm %in% c("b","d","r","z","md")) %>%
  mutate(r_est=case_when(cm=="r"~estimate, cm=="b"~estimate, cm=="d"~sapply(estimate,d_to_r),
    cm=="z"~sapply(estimate,z_to_r), cm=="md" & !is.na(estimate) & !is.na(standard_deviation)~sapply(estimate/standard_deviation,d_to_r), TRUE~NA_real_)) %>%
  filter(!is.na(r_est), !is.na(study_n))
res <- list()
for(id in unique(st$effect_size_id)){
  d <- st[st$effect_size_id==id,]
  fit <- tryCatch(rma(data=d, measure="COR", ri=r_est, ni=study_n), error=function(e)NULL)
  if(is.null(fit)){next}
  lp <- predict(fit, level=95); l99<-predict(fit, level=99.9)
  res[[id]] <- data.frame(effect_size_id=id, k=fit$k, r=as.numeric(lp$pred), cilb=as.numeric(lp$ci.lb), ciub=as.numeric(lp$ci.ub),
    p=as.numeric(fit$pval), i2=as.numeric(fit$I2), n=sum(d$study_n),
    sig999 = sign(as.numeric(l99$ci.lb))==sign(as.numeric(l99$ci.ub)))
}
rez <- bind_rows(res); write.csv(rez, file.path(base,"output/reanalysis_full.csv"), row.names=FALSE)

## Merge with Effects metadata
eff <- read.csv(file.path(base,"repo_data/Effects.csv"), stringsAsFactors=FALSE, check.names=FALSE)
names(eff) <- make.names(names(eff), unique=TRUE)
eff <- eff %>% rename(effect_size_id=Effect.Size.ID, exposure=Plain.Language...Exposure, outcome=Outcome.Plain.Language.Descriptor, cat=Outcome.Level.1)
M <- merge(rez, eff[, c("effect_size_id","cat","outcome","exposure")], by="effect_size_id", all.x=TRUE)
write.csv(M, file.path(base,"output/reanalysis_full_joined.csv"), row.names=FALSE)

## ---- Quoted-claim verification table ----
paper <- data.frame(
  claim=c("lit_general","coview","edutv_lit","num_math","num_vid","ar_learn","touch_learn","ebook_learn","tv_learn","vid_learn","gen_learn","adv_food","advergame","sm_sex","tv_sleep","tv_body","inet_dep","sm_dep"),
  id=c("47783_001","47783_022","47783_015","37653_002","41430_001","42168_002","50271_001","20223_015","47569_002","47569_005","47569_001","6739_002","47594_001","47429_003","6524_005","8556_119","60496_003","53160_001"),
  r_p=c(-0.14,0.15,0.13,0.27,0.32,0.33,0.21,0.11,-0.10,-0.08,-0.11,0.23,0.18,0.21,-0.06,0.06,0.25,0.12),
  cilb_p=c(-0.20,0.02,0.03,0.21,0.21,0.25,0.15,0.05,-0.15,-0.12,-0.24,0.10,0.10,0.14,-0.10,0.03,0.22,0.05),
  ciub_p=c(-0.09,0.28,0.23,0.33,0.43,0.42,0.28,0.17,-0.04,-0.04,0.01,0.37,0.25,0.28,-0.01,0.10,0.27,0.19),
  k_p=c(38,12,13,85,25,15,79,50,18,10,18,13,15,14,10,12,118,12),
  n_p=c(18318,6083,1955,36793,2008,1474,5810,2288,62135,4276,13100,1756,3842,23096,9798,3196,527696,93740))
V <- merge(paper, M, by.x="id", by.y="effect_size_id", all.x=TRUE)
V$r_ok <- abs(V$r - V$r_p) < 0.011
V$cilb_ok <- abs(V$cilb - V$cilb_p) < 0.011
V$ciub_ok <- abs(V$ciub - V$ciub_p) < 0.011
V$k_ok  <- V$k == V$k_p
V$n_ok  <- V$n == V$n_p
V$match <- V$r_ok & V$cilb_ok & V$ciub_ok & V$k_ok & V$n_ok
cat("QUOTED-CLAIM VERIFICATION: matches =", sum(V$match), "of", nrow(V), "\n\n")
res_out <- data.frame(claim=V$claim, id=V$id, r_paper=V$r_p, r_reimpl=round(V$r,3),
  cilb_p=V$cilb_p, cilb_re=round(V$cilb,3), ciub_p=V$ciub_p, ciub_re=round(V$ciub,3),
  k_p=V$k_p, k_re=V$k, n_p=V$n_p, n_re=V$n, I2=round(V$i2,1), p_re=signif(V$p,3), MATCH=V$match)
write.csv(res_out, file.path(base,"output/quoted_verification.csv"), row.names=FALSE)
print(res_out)
## 99.9% education/health counts
edu <- M[M$cat=="education",]; hea <- M[M$cat %in% c("health","health behaviour","physical health","psychology"),]
cat("\nEducation effects with n>=1000 meeting 99.9% sig (crude):", sum(edu$n>=1000 & edu$sig999), "\n")
