cat("47569 ids in reanalysis output:\n")
o <- read.csv("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check/output/reanalysis_metaanalysis.csv", stringsAsFactors=FALSE)
print(o[grepl("47569", o$effect_size_id), ])
cat("\nall ids sample:\n"); print(head(o$effect_size_id, 20))
