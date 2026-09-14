suppressMessages({
  library(dplyr); library(BayesFactor); library(readr)
})
cat("==== START recompute: Bayes factors (Table 4) + RATN BF (status: running) ====\n")

base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check"
setwd(base)

load_data <- function(){ readRDS("output/_diff_data.rds") }
d <- load_data(); mid.diff <- d$mid.diff; lat.diff <- d$lat.diff
mid.diff$subject <- as.factor(mid.diff$subject)
lat.diff$subject <- as.factor(lat.diff$subject)

cat("==== TABLE 4: Bayes factors (vs participant-only) ====\n")
set.seed(12604)
bf.mid <- anovaBF(mean.amplitude ~ stimulus.condition * electrode + subject, data=mid.diff, whichRandom="subject")
cat("-- BF Midline --\n"); print(extractBF(bf.mid), digits=6)
cat("Midline BF (electrode-only)/(electrode+stimulus) =", extractBF(bf.mid)$bf[1]/extractBF(bf.mid)$bf[3], "  paper 6.02\n")

set.seed(12604)
bf.lat <- anovaBF(mean.amplitude ~ stimulus.condition * electrode + subject, data=lat.diff, whichRandom="subject")
cat("-- BF Lateral --\n"); print(extractBF(bf.lat), digits=6)
cat("Lateral BF electrode-only/full =", extractBF(bf.lat)$bf[1]/extractBF(bf.lat)$bf[4], "  paper 1.46\n")
cat("Lateral BF full/main-effects-only =", extractBF(bf.lat)$bf[4]/extractBF(bf.lat)$bf[3], "  paper 4.22\n")

cat("==== RATN Bayes factor (appendix) ====\n")
RATN <- d$RATN
RATN$subject <- as.factor(RATN$subject)
set.seed(12604)
bf.RATN <- anovaBF(mean.amplitude ~ electrode.site * grammar.condition * hemisphere + subject, data=data.frame(RATN), whichRandom="subject")
rbf <- extractBF(bf.RATN)
cat("RATN full-model BF (last):", rbf$bf[length(rbf$bf)], "\n")
cat("RATN 1/bf_full (full vs null) =", 1/rbf$bf[length(rbf$bf)], "  paper 431,034\n")
cat("RATN inverse full/no-3-way (1/(bf18/bf17)) =", 1/(rbf$bf[length(rbf$bf)]/rbf$bf[length(rbf$bf)-1]), "  paper 39\n")
cat("==== END bayes (status: OK) ====\n")
