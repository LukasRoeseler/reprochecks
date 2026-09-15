suppressMessages({
  library(dplyr); library(tidyr); library(metafor)
  library(effectsize); library(correlation)
})

## Independent reimplementation of the umbrella-review reanalysis pipeline.
## Reads the shared study-level data (Studies.csv), converts each study estimate
## to a Pearson r using the metric mappings documented in the paper's methods,
## and pools via a random-effects meta-analysis (metafor::rma, measure="COR",
## DerSimonian-Laird) per effect-size ID -- mirroring the authors' run_metaanalysis.
## This is an INDEPENDENT reimplementation (not sourcing the author's R/*.R files).

csv <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check/repo_data/Studies.csv"
st <- read.csv(csv, stringsAsFactors = FALSE, check.names = FALSE, na.strings = c("-999","","#N/A"))
names(st) <- make.names(names(st), unique = TRUE)

# Rename to snake_case used by the analysis
st <- st %>%
  rename(
    effect_size_id = Effect.Size.ID,
    within_id = Within.Effect.ID,
    study_author = Study.Author,
    study_year = Study.Year,
    study_n = Study.N,
    estimate = Estimate,
    metric = Metric,
    lower_ci = Lower.CI,
    upper_ci = Upper.CI,
    standard_error = Standard.Error,
    standard_deviation = Standard.Deviation
  )

## ---- metric translation (mirrors translate_tests.R) ----
translate_tests <- function(stat) {
  s <- tolower(trimws(stat))
  dplyr::case_when(
    s %in% c("beta","beta coefficient","standardised regression coefficient") ~ "b",
    s %in% c("adjusted smd","average effect size","cohen d","cohen's d",
             "effect size (type unclear)","g","g+","hedge's g","hedges g",
             "hedges' d","hedge's d","hedges' g","median effect size",
             "pooled mean effect size","smd","standard mean difference",
             "standardised difference in the means","standardized mean difference",
             "standarised mean difference","std mean difference","std. mean difference",
             "standardised mean difference") ~ "d",
    s %in% c("mean","mean difference","pooled mean difference",
             "pre-post difference mean","unstandardized mean difference",
             "weighted mean","weighted mean difference") ~ "md",
    s %in% c("attenuated correlation (uncorrected correlation)",
             "corrected correlation","correlation","correlation coefficient",
             "pearson's r","weighted mean correlation coefficient",
             "r = uncorrected sample-weighted mean effect size") ~ "r",
    s %in% c("fisher z","fisher's z","z fischer","z fisher","fisher’s z",
             "fisher's z") ~ "z",
    s %in% c("log odds ratio") ~ "lor",
    s %in% c("odd ratio","odds ratio","odds ratio iv",
             "pooled fixed effect -odd ratio","pooled odds ratio") ~ "or",
    s %in% c("rate ratio","relative risk","risk ratio") ~ "rr",
    s %in% c("mean tau-u","tau-u") ~ NA_character_,
    TRUE ~ s
  )
}

st$converted_metric <- translate_tests(st$metric)

## ---- impute missing N by mean within effect (mirrors clean_studies.R) ----
st <- st %>%
  group_by(effect_size_id) %>%
  mutate(study_n = ifelse(is.na(study_n), round(mean(study_n, na.rm=TRUE)), study_n)) %>%
  ungroup()

## ---- conversion to r (mirrors convert_studies.R) ----
d_to_r <- function(d) { a <- sqrt(d^2 + 4); (d / a) }
z_to_r <- function(z) { tanh(z) }

st <- st %>%
  filter(converted_metric %in% c("b","d","r","z","md")) %>%
  mutate(
    r_estimate = case_when(
      converted_metric == "r" ~ estimate,
      converted_metric == "b" ~ estimate,
      converted_metric == "d" ~ sapply(estimate, function(x) d_to_r(x)),
      converted_metric == "z" ~ sapply(estimate, z_to_r),
      converted_metric == "md" & !is.na(estimate) & !is.na(standard_deviation) ~
        sapply(estimate/standard_deviation, d_to_r),
      TRUE ~ NA_real_
    )
  ) %>%
  filter(!is.na(r_estimate), !is.na(study_n))

ids <- sort(unique(st$effect_size_id))
out <- list()
for (id in ids) {
  d <- st %>% filter(effect_size_id == id)
  res <- tryCatch(
    rma(data = d, measure = "COR", ri = r_estimate, ni = study_n),
    error = function(e) NULL
  )
  if (is.null(res)) { out[[id]] <- data.frame(effect_size_id=id, ok=FALSE); next }
  ci95 <- predict(res, level = 95)
  ci999 <- predict(res, level = 99.9)
  out[[id]] <- data.frame(
    effect_size_id = id,
    ok = TRUE,
    k = res$k,
    pooled_r = as.numeric(ci95$pred),
    cilb95 = as.numeric(ci95$ci.lb),
    ciub95 = as.numeric(ci95$ci.ub),
    cilb999 = as.numeric(ci999$ci.lb),
    ciub999 = as.numeric(ci999$ci.ub),
    i2 = as.numeric(res$I2),
    tau2 = as.numeric(res$tau2),
    n_pooled = sum(d$study_n)
  )
}
rez <- bind_rows(out)
write.csv(rez, "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check/output/reanalysis_metaanalysis.csv", row.names = FALSE)
cat("Effects with study-level data:", nrow(rez), " success:", sum(rez$ok), " failed:", sum(!rez$ok), "\n")
print(rez[rez$ok & rez$n_pooled >= 1000, c("effect_size_id","k","pooled_r","cilb95","ciub95","n_pooled","i2")], digits = 4)
