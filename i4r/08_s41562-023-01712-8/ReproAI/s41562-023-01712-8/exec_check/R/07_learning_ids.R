suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
m <- read.csv(file.path(base,"output/reanalysis_joined.csv"), stringsAsFactors=FALSE)
m$n_pooled<-as.numeric(m$n_pooled); m$k<-as.numeric(m$k)
ids <- c("47569_001","47569_002","47569_005","61429_001")
for (id in ids){
 x <- m[m$effect_size_id==id,]
 if(nrow(x)) cat(id, "|", x$outcome[1], "|", x$exposure[1], "| k=",x$k[1], "| r=",round(x$pooled_r[1],3),
   paste0("[",round(x$cilb95[1],3),", ",round(x$ciub95[1],3),"]"), "| N=",x$n_pooled[1], "| I2=",round(x$i2[1],1),"\n")
}
