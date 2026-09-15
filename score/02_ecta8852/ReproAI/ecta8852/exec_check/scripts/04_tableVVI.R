## Script 04: Table V + Table VI with rule breakout and paper session-set for comm
options(warn=-1)
suppressMessages(library(dplyr))
d <- read.csv("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/02_ecta8852/ReproAI/ecta8852/exec_check/output/master_behavior.csv",
              stringsAsFactors=FALSE)
# Apply paper's communication session sets: hom r7 comm = HOM_7_27 only (nsubj==27)
d <- d[!(d$pref=="hom" & d$rule==7 & d$comm==1 & d$nsubj==36),]
d$base <- paste(d$pref,d$rule,d$nsubj,d$rev,sep="_")

## ---- Table V per rule ----
cat("=== TABLE V recompute (homogeneous, % red group decision by #red signals), BY RULE ===\n")
for (cm in c(0,1)) {
  cat(sprintf("\n--- communication=%d ---\n", cm))
  sub <- d[d$pref=="hom" & d$comm==cm,]
  g <- sub %>% group_by(rule, base, period, group) %>%
       summarise(redsig=sum(sample==1), gdec=mean(groupdec)==1, .groups="drop")
  tb <- g %>% group_by(rule, redsig) %>% summarise(pct=round(mean(gdec)*100), n=n(), .groups="drop")
  print(as.data.frame(tb))
}

## ---- Table VI per preference/rule ----
cat("\n=== TABLE VI recompute (communication, % red by signal majority + 95% CI) ===\n")
for (pf in c("hom","het","part")) {
  sub <- d[d$pref==pf & d$comm==1,]
  g <- sub %>% group_by(rule, base, period, group) %>%
       summarise(redsig=sum(sample==1), gdec=mean(groupdec)==1, .groups="drop")
  g$maj <- ifelse(g$redsig >= 5, "red","blue")
  tb <- g %>% group_by(rule, maj) %>%
       summarise(n=n(), pct=round(mean(gdec)*100,1),
                 se=sqrt(mean(gdec)*(1-mean(gdec))/n()),
                 ci_lo=round(max(0,(mean(gdec)-1.96*se)*100),1),
                 ci_hi=round(min(1,(mean(gdec)+1.96*se))*100,1),
                 .groups="drop") %>% arrange(maj, rule)
  cat("---", pf, "---\n")
  print(as.data.frame(tb))
}
