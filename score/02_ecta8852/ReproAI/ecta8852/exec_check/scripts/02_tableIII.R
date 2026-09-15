## Script 02: Table III — strategic voting across treatments (raw recompute)
options(warn=-1)
d <- read.csv("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/02_ecta8852/ReproAI/ecta8852/exec_check/output/master_behavior.csv",
              stringsAsFactors=FALSE)
d$base <- paste(d$pref,d$rule,d$nsubj,d$rev,sep="_")

dec <- function(sam, act) as.numeric(act==1)

res <- list()
for (pf in c("hom","het","part")) {
  for (rl in c(5,7,9)) {
    for (cm in c(0,1)) {
      sub <- d[d$pref==pf & d$rule==rl & d$comm==cm, ]
      if (nrow(sub)==0) next
      # individual decisions
      nind <- nrow(sub)
      # group decisions
      ngroups <- nrow(unique(sub[,c("period","group","base")]))
      # red votes with red signal / blue
      rr <- sub[sub$sample==1,]; rb <- sub[sub$sample==2,]
      red_red  <- if(nrow(rr)) mean(rr$action==1)*100 else NA
      red_blue <- if(nrow(rb)) mean(rb$action==1)*100 else NA
      # group outcomes
      g <- unique(sub[,c("period","group","base","groupdec","jar")])
      wrong <- mean(g$groupdec != g$jar)*100
      tb <- g[g$jar==2,]; tr <- g[g$jar==1,]
      truejarblue <- if(nrow(tb)) mean(tb$groupdec==1)*100 else NA   # chose red when jar blue
      truejarred  <- if(nrow(tr)) mean(tr$groupdec==2)*100 else NA   # chose blue when jar red
      res[[length(res)+1]] <- data.frame(pref=pf, rule=rl, comm=cm,
        nind=nind, ngroups=ngroups,
        red_red_red=red_red, red_votes_w_blue_sig=red_blue,
        wrong_jury_outcomes=wrong, truejar_blue=truejarblue, truejar_red=truejarred)
    }
  }
}
T3 <- do.call(rbind, res)
cat("=== TABLE III recompute (individual-decision basis for red/blue rows; group-decision basis for outcomes) ===\n")
print(T3, row.names=FALSE)
write.csv(T3, "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/02_ecta8852/ReproAI/ecta8852/exec_check/output/tableIII_recompute.csv", row.names=FALSE)
