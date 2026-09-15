suppressMessages({library(dplyr); library(jsonlite)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/06_e3kcw/ReproAI/e3kcw"
d <- readRDS(file.path(base,"exec_check/output/01_explore/data_raw.rds"))
out <- file.path(base,"exec_check/output/02_regression")
dir.create(out, showWarnings=FALSE, recursive=TRUE)
con <- file(file.path(out,"console.log"), open="wt")
sink(con); sink(con, type="message")
cat("==== START 02_regression.R (status: RUN) ====\n")

# ---- derive scales (averages matching manuscript descriptives) ----
mk <- function(...) rowMeans(cbind(...), na.rm=TRUE)
d$flow_avg      <- d$flow/5
d$mindful_avg   <- d$mindful/12
d$depress_avg   <- d$depress/6
d$anx_avg       <- d$anx/6
d$posemo_avg    <- d$posemo/6
d$negemo_avg    <- d$negemo/6
d$healthy_avg   <- (d$healthbeh1+d$healthbeh2+d$healthbeh3)/3
d$unhealthy_avg <- (d$healthbeh4+d$healthbeh5+d$healthbeh6)/3
# worry = mean of standardized items
wz <- cbind(scale(d$worry1), scale(d$worry2), scale(d$worry3))
d$worry_avg <- rowMeans(wz, na.rm=TRUE)
# loneliness avg
d$lonely_avg <- (d$lonely1+d$lonely2+d$lonely3)/3

outcomes <- list(
  worry      = "worry_avg",
  negemo     = "negemo_avg",
  posemo     = "posemo_avg",
  depress    = "depress_avg",
  anx        = "anx_avg",
  lonely     = "lonely_avg",
  healthy    = "healthy_avg",
  unhealthy  = "unhealthy_avg"
)

# ---- helper: fit model for one specification ----
fit_spec <- function(d, qvar, region_in, standardize=FALSE) {
  res <- list()
  for (nm in names(outcomes)) {
    flow_c   <- d$flow_avg - mean(d$flow_avg, na.rm=TRUE)
    mind_c   <- d$mindful_avg - mean(d$mindful_avg, na.rm=TRUE)
    q_c      <- d[[qvar]] - mean(d[[qvar]], na.rm=TRUE)
    fxq      <- flow_c * q_c
    mxq      <- mind_c * q_c
    df <- data.frame(y=d[[outcomes[[nm]]]], flow_c, mind_c, q_c, fxq, mxq)
    df$sex <- d$sex; df$age <- d$age; df$edu <- d$edu
    df$ifsibling <- d$ifsibling; df$income <- d$income
    df$opt <- d$opt; df$iu <- d$iu; df$swls <- d$swls
    if (region_in) df$region <- d$region
    if (standardize) {
      df$y <- scale(df$y)[,1]
      for (j in 2:ncol(df)) if (is.numeric(df[[j]])) df[[j]] <- scale(df[[j]])[,1]
    }
    res[[nm]] <- lm(y ~ flow_c + mind_c + q_c + fxq + mxq + sex + age + edu + ifsibling + income + opt + iu + swls, data=df)
  }
  res
}
report_row <- function(res, term) {
  sapply(results_outcome_order, function(nm){
    co <- coefficients(res[[nm]])
    b <- co[term]; se <- summary(res[[nm]])$coefficients[term,"Std. Error"]
    z <- b/se; p <- 2*pnorm(-abs(z))
    sprintf("%.3f [%.2f,%.2f] p=%.4f", b, b-1.96*se, b+1.96*se, p)
  })
}

results_outcome_order <- c("worry","negemo","posemo","depress","anx","lonely","healthy","unhealthy")

# ---- Test variants ----
d$q_log <- log10(d$quarantine)
variants <- list(
  V1_raw_noregion = function() fit_spec(d, "quarantine", FALSE),
  V2_log_noregion = function() fit_spec(d, "q_log", FALSE),
  V3_raw_region   = function() fit_spec(d, "quarantine", TRUE),
  V4_log_region   = function() fit_spec(d, "q_log", TRUE)
)
for (v in names(variants)) {
  cat("\n######## VARIANT:", v, "########\n")
  res <- variants[[v]]()
  terms <- c("flow_c","mind_c","q_c","fxq","mxq")
  labs <- c("FLOW","MINDFUL","QUARANTINE","FLOWxQUAR","MINDxQUAR")
  for (i in seq_along(terms)) {
    cat("\n--", labs[i], "--\n")
    print(data.frame(outcome=results_outcome_order, value=report_row(res, terms[i])))
  }
}
# ---- also fit with standardized (beta) for V2 to see scale ----
cat("\n######## VARIANT V2 log, STANDARDIZED betas ########\n")
resS <- fit_spec(d, "q_log", FALSE, standardize=TRUE)
for (i in seq_along(c("flow_c","mind_c","q_c","fxq","mxq"))) {
  cat("\n--", labs[i], "--\n")
  print(data.frame(outcome=results_outcome_order, val=report_row(resS, terms[i])))
}
sink(type="message"); sink(); close(con)
cat("done\n")
