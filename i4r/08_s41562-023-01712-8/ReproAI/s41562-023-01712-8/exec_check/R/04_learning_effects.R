suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
m <- read.csv(file.path(base,"output/reanalysis_joined.csv"), stringsAsFactors=FALSE)
m$n_pooled <- as.numeric(m$n_pooled); m$k <- as.numeric(m$k)
sel <- m[grepl("Learning: General|Learning ", m$outcome) , ]
sel <- sel[grepl("TV|Video|Screen use: General|television", sel$exposure, ignore.case=TRUE), ]
write.csv(sel[, c("effect_size_id","outcome","exposure","k","pooled_r","cilb95","ciub95","n_pooled","i2","Combined.N","Value")], file.path(base,"output/learning_effects.csv"), row.names=FALSE)
print(sel[, c("effect_size_id","outcome","exposure","k","pooled_r","cilb95","ciub95","n_pooled","i2","Combined.N","Value")])
