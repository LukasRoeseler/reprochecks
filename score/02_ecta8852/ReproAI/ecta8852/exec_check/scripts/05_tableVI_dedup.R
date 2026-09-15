## Script 05 (FIXED): Table VI recompute with per-subject dedup keyed on comm-inclusive id
options(warn=-1)
suppressMessages(library(dplyr))
d <- read.csv("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/02_ecta8852/ReproAI/ecta8852/exec_check/output/master_behavior.csv",
              stringsAsFactors=FALSE)
d$id <- paste(d$pref,d$rule,d$nsubj,d$rev,d$comm,sep="_")

cat("Dup check (comm=1): raw rows vs distinct (period,group,subj,id):\n")
chk <- d %>% filter(comm==1) %>% group_by(pref,rule,id) %>%
  summarise(raw=n(), dedup=n_distinct(paste(period,group,subj)), .groups="drop")
print(as.data.frame(chk))

# dedup per comm-inclusive id (removes PART r9 chat duplicate records in periods 1-5)
d <- d[!duplicated(d[,c("period","group","subj","id")]),]
# apply paper comm session set for hom r7 (HOM_7_27 only)
d <- d[!(d$pref=="hom" & d$rule==7 & d$comm==1 & d$nsubj==36),]

cat("\n=== TABLE VI recompute (comm, deduped): % red by signal majority + 95% CI ===\n")
for (pf in c("hom","het","part")) {
  sub <- d[d$pref==pf & d$comm==1,]
  g <- sub %>% group_by(rule, id, period, group) %>%
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
