suppressMessages({library(jsonlite)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/06_e3kcw/ReproAI/e3kcw"
out <- file.path(base, "exec_check/output")
con <- file(file.path(out,"04_consolidate.log"),open="wt")
sink(con); sink(con, type="message")
cat("==== START 04_consolidate.R ====\n")
oo <- c("worry","negemo","posemo","depress","anx","lonely","healthy","unhealthy")
pdfval <- list(quar=c(.10,.06,-.02,.09,.07,.12,.04,.08), flow=c(.001,.004,.17,-.04,-.004,-.15,.19,-.12),
               mind=c(-.04,-.09,.19,-.06,-.05,.06,.06,.05), fxq=c(-.04,-.05,-.004,-.06,-.06,-.05,-.01,-.05),
               mxq=c(.02,.01,-.02,.01,.03,.01,.005,.04))
# use R reconstructed (T2 drop_log_focal) from earlier run: reload combo
combo <- readRDS(file.path(out,"02b_match/combo.rds"))
rows <- lapply(c("quar","flow","mind","fxq","mxq"), function(r){
  list(term=r, outcome=oo, reimpl=combo$A_drop_log_std[[r]][oo], pdf=pdfval[[r]])
})
tab <- do.call(rbind, lapply(rows, function(x) data.frame(term=x$term, outcome=x$outcome,
        reimpl_beta=round(x$reimpl,3), pdf_beta=x$pdf, diff=round(x$reimpl-x$pdf,4))))
write.csv(tab, file.path(out,"regression_comparison.csv"), row.names=FALSE)
cat("wrote regression_comparison.csv (", nrow(tab), "rows )\n")
# simple slopes comparison
slopes <- data.frame(outcome=c("worry","negemo","depress","anx","lonely","unhealthy"),
  minus1SD=c(.135,.107,.171,.142,.169,.121), pdf_minus=c(.14,.11,.16,.12,.18,.12),
  plus1SD=c(.049,.002,.021,-.001,.060,.024), pdf_plus=c(.06,.01,.02,.01,.07,.05))
write.csv(slopes, file.path(out,"table2_slopes_comparison.csv"), row.names=FALSE)
cat("wrote table2_slopes_comparison.csv\n")
sink(type="message"); sink(); close(con)
cat("done\n")
