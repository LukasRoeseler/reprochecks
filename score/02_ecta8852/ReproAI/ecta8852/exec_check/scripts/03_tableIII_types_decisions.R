## Script 03: Table III type-level splits + decision-time claims (fn 16)
options(warn=-1)
suppressMessages(library(dplyr))
d <- read.csv("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/02_ecta8852/ReproAI/ecta8852/exec_check/output/master_behavior.csv",
              stringsAsFactors=FALSE)

type_row <- function(df, lab) {
  if(nrow(df)==0) return(NULL)
  rr <- df[df$sample==1,]; rb <- df[df$sample==2,]
  data.frame(type=lab, n=nrow(df),
    red_red = if(nrow(rr)) round(mean(rr$action==1)*100,1) else NA,
    red_blue= if(nrow(rb)) round(mean(rb$action==1)*100,1) else NA)
}

cat("=== Heterogeneous: red-type(1)/blue-type(2) splits, no-comm ===\n")
for (rl in c(5,7,9)) {
  sub <- d[d$pref=="het" & d$rule==rl & d$comm==0,]
  cat("rule", rl, "\n")
  a <- type_row(sub[sub$type==1,],"red_type")
  b <- type_row(sub[sub$type==2,],"blue_type")
  print(rbind(a,b))
}
cat("\n=== Partisan: neutral(0)/strong-red(3) splits, no-comm ===\n")
for (rl in c(5,7,9)) {
  sub <- d[d$pref=="part" & d$rule==rl & d$comm==0,]
  cat("rule", rl, "\n")
  a <- type_row(sub[sub$type==0,],"neutral")
  b <- type_row(sub[sub$type==3,],"strong_red")
  print(rbind(a,b))
}

cat("\n=== Decision times: voting with vs against signal (fn16) ===\n")
for (pf in c("hom","het","part")) {
  sub <- d[d$pref==pf & d$comm==0,]
  with_sig  <- sub[sub$action==sub$sample,]
  agnst_sig <- sub[sub$action!=sub$sample,]
  cat(sprintf("%s: with-signal %.1fs (n=%d) ; against-signal %.1fs (n=%d)\n",
      pf, mean(with_sig$time), nrow(with_sig), mean(agnst_sig$time), nrow(agnst_sig)))
}
