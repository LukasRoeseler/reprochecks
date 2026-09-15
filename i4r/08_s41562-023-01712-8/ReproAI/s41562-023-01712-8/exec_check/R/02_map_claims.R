suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
m <- read.csv(file.path(base,"output/reanalysis_joined.csv"), stringsAsFactors=FALSE)
cred <- m[!is.na(m$n_pooled) & m$n_pooled >= 1000, ]
sel <- cred[, c("effect_size_id","cat","outcome","exposure","k","pooled_r",
                "cilb95","ciub95","n_pooled","i2","Value","Statistical.Test")]
sel$pooled_r <- round(sel$pooled_r,3); sel$cilb95 <- round(sel$cilb95,3)
sel$ciub95 <- round(sel$ciub95,3); sel$i2 <- round(sel$i2,1); sel$k <- as.integer(sel$k)
write.csv(sel, file.path(base,"output/credible_candidates.csv"), row.names=FALSE)
cat("wrote", nrow(sel), "rows\n")
