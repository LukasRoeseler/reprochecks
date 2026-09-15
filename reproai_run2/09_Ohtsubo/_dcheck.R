suppressMessages({library(readxl); library(dplyr); library(rstatix)})
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/09_Ohtsubo/dl_httpsosfiodownloadp9whq.bin"
data <- read_excel(d, sheet = "Sheet3", skip = 1)
data$r4rec <- 8 - as.numeric(data$r4)
data$intimacy_scale <- (data$r1 + data$r4rec + data$r6 + data$r7)/4
cat("constructed==Intimacy (any FALSE):", any(data$intimacy_scale != data$Intimacy), "\n")
for (ex in c(22,25)){
  dd <- data[-ex, ]
  t <- t.test(Intimacy ~ cnd, data=dd, var.equal=TRUE, alternative="two.sided")
  cd <- cohens_d(dd, Intimacy ~ cnd, var.equal=TRUE)
  cat(sprintf("excl %d: t=%.3f df=%.0f p=%.9f  cohens_d=%s\n", ex, t$statistic, t$parameter, t$p.value, cd$effsize))
}
