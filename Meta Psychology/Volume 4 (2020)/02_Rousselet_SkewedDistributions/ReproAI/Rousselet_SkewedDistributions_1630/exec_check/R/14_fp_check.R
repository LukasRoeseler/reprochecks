datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"
e <- new.env(); load(file.path(datadir, "sim_gp_fp2.RData"), envir=e)
npseq <- get("npseq",envir=e); ntseq1 <- get("ntseq1",envir=e); ntseq2 <- get("ntseq2",envir=e)
res <- get("res.md.m.sig",envir=e)  # means-of-medians, uneq n
cat("npseq (participants):", npseq, "\n")
cat("ntseq1 (trials cond1):", ntseq1, "\n")
cat("ntseq2 (trials cond2):", ntseq2, "\n")
cat("dims res.md.m.sig [sim, ?, ?, ?]:", dim(res), "\n")
# paper: unequal n, cond1 trials vary (ntseq1?), cond2 const; 200 participants; n=10/20 very skewed -> FP>50%
fp <- apply(res, c(2,3,4), mean)
# find max FP value anywhere and its location
idx <- which(fp==max(fp), arr.ind=TRUE)
cat("max FP (means-of-medians, uneq):", round(max(fp),3), "at", paste(idx[1,],collapse=","), "\n")
# map: dim2 = skew or trials? dim3 = trials or skew? dim4 = participants
# Let's test 200 participants (npseq last = 200)
cat("npseq:", npseq, "\n")
# Check FP at trials=10 (ntseq1[?]) and skew most skewed for 200 participants
