suppressMessages({library(dplyr); library(jsonlite)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/06_e3kcw/ReproAI/e3kcw"
d <- readRDS(file.path(base,"exec_check/output/01_explore/data_raw.rds"))
out <- file.path(base,"exec_check/output/02b_match")
dir.create(out, showWarnings=FALSE, recursive=TRUE)
con <- file(file.path(out,"console.log"), open="wt")
sink(con); sink(con, type="message")
cat("==== START 02b_match.R ====\n")
d$flow_avg <- d$flow/5; d$mindful_avg <- d$mindful/12
d$depress_avg <- d$depress/6; d$anx_avg <- d$anx/6; d$posemo_avg <- d$posemo/6; d$negemo_avg <- d$negemo/6
d$healthy_avg <- (d$healthbeh1+d$healthbeh2+d$healthbeh3)/3
d$unhealthy_avg <- (d$healthbeh4+d$healthbeh5+d$healthbeh6)/3
d$lonely_avg <- (d$lonely1+d$lonely2+d$lonely3)/3
wz <- cbind(scale(d$worry1), scale(d$worry2), scale(d$worry3)); d$worry_avg <- rowMeans(wz,na.rm=TRUE)
d$q_log <- log10(d$quarantine)
outcomes <- c(worry="worry_avg",negemo="negemo_avg",posemo="posemo_avg",depress="depress_avg",
              anx="anx_avg",lonely="lonely_avg",healthy="healthy_avg",unhealthy="unhealthy_avg")
oo <- c("worry","negemo","posemo","depress","anx","lonely","healthy","unhealthy")
pdfval <- list(quar=c(.10,.06,-.02,.09,.07,.12,.04,.08), flow=c(.001,.004,.17,-.04,-.004,-.15,.19,-.12),
               mind=c(-.04,-.09,.19,-.06,-.05,.06,.06,.05), fxq=c(-.04,-.05,-.004,-.06,-.06,-.05,-.01,-.05),
               mxq=c(.02,.01,-.02,.01,.03,.01,.005,.04))

run <- function(age_handle, qvar, standardize){
  dd <- d
  if (age_handle=="drop")   dd <- dd[!is.na(dd$age),]
  if (age_handle=="impute") dd$age[is.na(dd$age)] <- mean(dd$age, na.rm=TRUE)
  flow_c <- dd$flow_avg - mean(dd$flow_avg, na.rm=TRUE)
  mind_c <- dd$mindful_avg - mean(dd$mindful_avg, na.rm=TRUE)
  qv <- dd[[qvar]]; q_c <- qv - mean(qv, na.rm=TRUE)
  fxq <- flow_c*q_c; mxq <- mind_c*q_c
  df <- data.frame(flow_c,mind_c,q_c,fxq,mxq,sex=dd$sex,age=dd$age,edu=dd$edu,
                   ifsibling=dd$ifsibling,income=dd$income,opt=dd$opt,iu=dd$iu,swls=dd$swls)
  if (standardize){
    for (j in 1:5) df[[j]] <- scale(df[[j]])[,1]
  }
  co <- sapply(names(outcomes), function(nm){
    y <- dd[[outcomes[[nm]]]]
    if (standardize) y <- scale(y)[,1]
    m <- lm(y ~ flow_c+mind_c+q_c+fxq+mxq+sex+age+edu+ifsibling+income+opt+iu+swls, data=df)
    coef(m)[c("flow_c","mind_c","q_c","fxq","mxq")]
  })
  list(flow=co["flow_c",], mind=co["mind_c",], quar=co["q_c",], fxq=co["fxq",], mxq=co["mxq",])
}

combo <- list(
  A_drop_log_std = run("drop","q_log",TRUE),
  B_imp_log_std  = run("impute","q_log",TRUE),
  C_drop_raw_std = run("drop","quarantine",TRUE),
  D_imp_raw_std  = run("impute","quarantine",TRUE))
for (cname in names(combo)){
  rows <- combo[[cname]]
  dif <- unlist(lapply(names(rows), function(r) rows[[r]][oo]-pdfval[[r]]))
  cat(sprintf("\n%-16s meanAbs=%.5f sumAbs=%.4f maxAbs=%.4f\n", cname,
      mean(abs(dif)), sum(abs(dif)), max(abs(dif))))
}
cat("\n=== Best: A_drop_log_std (vs PDF) ===\n")
lr <- c("quar","flow","mind","fxq","mxq")
for (r in lr){
  cat(sprintf("%-5s MINE %s\n     PDF %s\n", r,
      paste(sprintf("%.3f",combo$A_drop_log_std[[r]][oo]),collapse=" "),
      paste(sprintf("%.3f",pdfval[[r]]),collapse=" ")))
}
saveRDS(combo, file.path(out,"combo.rds"))
sink(type="message"); sink(); close(con)
cat("done\n")
