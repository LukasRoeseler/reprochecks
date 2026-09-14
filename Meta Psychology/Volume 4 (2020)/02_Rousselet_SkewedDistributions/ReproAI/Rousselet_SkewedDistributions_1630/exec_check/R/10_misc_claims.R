datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"
# Measurement precision (Section 5)
load(file.path(datadir, "sim_precision.RData"))
cat("== sim_precision ==\n")
cat("preseq:", preseq, "\n"); cat("ptseq:", ptseq, "\n")
cat("70% within 10ms (mean):", round(approx(y=ptseq,x=res.pre.m[2,],xout=0.70)$y), "\n")
cat("70% within 10ms (median):", round(approx(y=ptseq,x=res.pre.md[2,],xout=0.70)$y), "\n")
cat("90% within 20ms (mean):", round(approx(y=ptseq,x=res.pre.m[4,],xout=0.90)$y), "\n")
cat("90% within 20ms (median):", round(approx(y=ptseq,x=res.pre.md[4,],xout=0.90)$y), "\n")
# paper text says 59/56 and 37/38

# Group bias (Section 3, bias_diff)
load(file.path(datadir, "bias_diff_size.RData"))
cat("\n== bias_diff_size ==\n")
cat("Objects:", ls(), "\n")
# figure out structure
print(names(attributes(bc.bias.md)))
