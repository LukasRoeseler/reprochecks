suppressMessages({library(dplyr); library(jsonlite)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/06_e3kcw/ReproAI/e3kcw"
d <- readRDS(file.path(base,"exec_check/output/01_explore/data_raw.rds"))
outd <- file.path(base,"exec_check/output/02c_grid")
dir.create(outd, showWarnings=FALSE, recursive=TRUE)
con <- file(file.path(outd,"console.log"), open="wt")
sink(con); sink(con, type="message")
cat("==== START 02c_grid.R ====\n")
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

run <- function(age_handle, qvar, std_conv, inter_var){
  dd <- d
  if (age_handle=="drop") dd <- dd[!is.na(dd$age),]
  if (age_handle=="impute") dd$age[is.na(dd$age)] <- mean(dd$age, na.rm=TRUE)
  base_flow <- dd$flow_avg; base_mind <- dd$mindful_avg; base_q <- dd[[qvar]]
  if (std_conv=="all"){
    flow_s <- scale(base_flow)[,1]; mind_s <- scale(base_mind)[,1]; q_s <- scale(base_q)[,1]
    if (inter_var=="prod_std"){ fxq<-flow_s*q_s; mxq<-mind_s*q_s }
    else { fxq<-(flow_s*q_s - mean(flow_s*q_s))/sd(flow_s*q_s); mxq <- (mind_s*q_s-mean(mind_s*q_s))/sd(mind_s*q_s) }
    df <- data.frame(flow_s,mind_s,q_s,fxq,mxq)
    df$sex <- as.numeric(scale(dd$sex)); df$age <- as.numeric(scale(dd$age)); df$edu <- as.numeric(scale(dd$edu))
    df$ifsibling <- as.numeric(scale(dd$ifsibling)); df$income <- as.numeric(scale(dd$income))
    df$opt <- as.numeric(scale(dd$opt)); df$iu <- as.numeric(scale(dd$iu)); df$swls <- as.numeric(scale(dd$swls))
    co <- sapply(names(outcomes), function(nm){
      y <- scale(dd[[outcomes[[nm]]]])[,1]
      m <- lm(y ~ flow_s+mind_s+q_s+fxq+mxq+sex+age+edu+ifsibling+income+opt+iu+swls, data=df)
      coef(m)[c("flow_s","mind_s","q_s","fxq","mxq")]
    })
  } else {
    flow_c <- base_flow - mean(base_flow); mind_c <- base_mind - mean(base_mind)
    q_c <- base_q - mean(base_q); fxq <- flow_c*q_c; mxq <- mind_c*q_c
    df <- data.frame(flow_c,mind_c,q_c,fxq,mxq, sex=dd$sex,age=dd$age,edu=dd$edu,
                     ifsibling=dd$ifsibling,income=dd$income,opt=dd$opt,iu=dd$iu,swls=dd$swls)
    for (j in 1:5) df[[j]] <- scale(df[[j]])[,1]
    co <- sapply(names(outcomes), function(nm){
      y <- scale(dd[[outcomes[[nm]]]])[,1]
      m <- lm(y ~ flow_c+mind_c+q_c+fxq+mxq+sex+age+edu+ifsibling+income+opt+iu+swls, data=df)
      coef(m)[c("flow_c","mind_c","q_c","fxq","mxq")]
    })
  }
  list(flow=co[1,], mind=co[2,], quar=co[3,], fxq=co[4,], mxq=co[5,])
}

tests <- list(
  T1_drop_log_stdall_prodstd = run("drop","q_log","all","prod_std"),
  T2_drop_log_focal          = run("drop","q_log","focal",NA),
  T3_imp_log_stdall_prodstd  = run("impute","q_log","all","prod_std"),
  T4_drop_raw_stdall_prodstd = run("drop","quarantine","all","prod_std"),
  T5_drop_log_stdall_restand = run("drop","q_log","all","restd"),
  T6_imp_log_focal           = run("impute","q_log","focal",NA)
)
for (t in names(tests)){
  rows <- tests[[t]]; dif <- unlist(lapply(names(rows),function(r) rows[[r]][oo]-pdfval[[r]]))
  cat(sprintf("%-24s meanAbs=%.5f maxAbs=%.4f\n", t, mean(abs(dif)), max(abs(dif))))
}
cat("\n=== T1 detail (stdall, log, drop, prod_std) ===\n")
for (r in c("quar","flow","mind","fxq","mxq")){
  cat(sprintf("\n%-5s MINE %s\n     PDF %s", r,
      paste(sprintf("%.3f",tests$T1_drop_log_stdall_prodstd[[r]][oo]),collapse=" "),
      paste(sprintf("%.3f",pdfval[[r]]),collapse=" ")))
}
cat("\n\n=== T2 detail (focal std, covariates raw, drop) ===\n")
for (r in c("quar","flow","mind","fxq","mxq")){
  cat(sprintf("\n%-5s MINE %s\n     PDF %s", r,
      paste(sprintf("%.3f",tests$T2_drop_log_focal[[r]][oo]),collapse=" "),
      paste(sprintf("%.3f",pdfval[[r]]),collapse=" ")))
}
sink(type="message"); sink(); close(con)
cat("done\n")
