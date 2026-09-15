suppressMessages(library(haven))
p <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/02_NyhanReifler/causal-replication.dta"
df <- read_dta(p)
Models <- list(
  M1=list(dv="swensenfav",preds=c("innuendo","denial","causal"),w="aw"),
  M3=list(dv="acceptedbribes",preds=c("innuendo","denial","causal"),w="aw"),
  M5=list(dv="resigninvest",preds=c("denial","causal"),w="aw"),
  M2=list(dv="swensenfav",preds=c("innuendo","denial","causal"),w="weight"),
  M4=list(dv="acceptedbribes",preds=c("innuendo","denial","causal"),w="weight"),
  M6=list(dv="resigninvest",preds=c("denial","causal"),w="weight")
)
for(nm in names(Models)){
  M <- Models[[nm]]
  d <- df[!is.na(df[[M$dv]]),]
  f <- as.formula(paste(M$dv,"~",paste(M$preds,collapse="+")))
  m <- lm(f, data=d, weights=d[[M$w]])
  cat(sprintf("%s n=%d\n", nm, nrow(d)))
  print(round(coef(m),4))
}