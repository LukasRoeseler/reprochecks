sink("Study2_out.txt", split=TRUE)
cat("===== STUDY 2 ANALYSIS =====\n\n")
data <- read.csv("Study2_data.csv", header=T)
cat("Total rows:", nrow(data), "\n")

data$seis1 <- 8 - data$seis1
data$seis2 <- 8 - data$seis2
data$seis3 <- 8 - data$seis3
col.seis <- c(26,27,28,29,30)
data$seis <- rowMeans(data[,col.seis], na.rm = TRUE)
col.disp <- c(13,14,15,18)
col.sit <- c(17,20,21,22,23)
data$disp <- rowMeans(data[,col.disp], na.rm = TRUE)
data$sit <- rowMeans(data[,col.sit], na.rm = TRUE)
col.redist <- c(31,32,33,34)
data$redist <- rowMeans(data[,col.redist], na.rm = TRUE)

library(psych)
cat("\n--- FULL SAMPLE PEARSON CORRELATIONS ---\n")
cat("\nH1.1 sit~seis:\n"); print(corr.test(data$sit, data$seis, use="pairwise", method="pearson"))
cat("\nH1.2 sit~redist:\n"); print(corr.test(data$sit, data$redist, use="pairwise", method="pearson"))
cat("\nH2.1 disp~seis:\n"); print(corr.test(data$disp, data$seis, use="pairwise", method="pearson"))
cat("\nH2.2 disp~redist:\n"); print(corr.test(data$disp, data$redist, use="pairwise", method="pearson"))

cat("\n--- CONTROLLING FOR IDEOLOGY ---\n")
print(summary(lm(seis~sit + ideology, data=data)))
cat("\n"); print(summary(lm(redist~sit + ideology, data=data)))
cat("\n"); print(summary(lm(seis~disp + ideology, data=data)))
cat("\n"); print(summary(lm(redist~disp + ideology, data=data)))

cat("\n--- ATTENTION CHECK (attn.check==2) SUBSET ---\n")
library(plyr)
print(count(data$ideology))
data2 <- data[ which(data$attn.check == 2), ]
cat("Passed attention n:", nrow(data2), "\n")
cat("\nH1.1 sit~seis:\n"); print(corr.test(data2$sit, data2$seis, use="pairwise", method="pearson"))
cat("\nH1.2 sit~redist:\n"); print(corr.test(data2$sit, data2$redist, use="pairwise", method="pearson"))
cat("\nH2.1 disp~seis:\n"); print(corr.test(data2$disp, data2$seis, use="pairwise", method="pearson"))
cat("\nH2.2 disp~redist:\n"); print(corr.test(data2$disp, data2$redist, use="pairwise", method="pearson"))

cat("\n--- NONPARAMETRIC (spearman) FULL SAMPLE ---\n")
cat("\nH1.1 sit~seis:\n"); print(corr.test(data$sit, data$seis, use="pairwise", method="spearman"))
cat("\nH1.2 sit~redist:\n"); print(corr.test(data$sit, data$redist, use="pairwise", method="spearman"))
cat("\nH2.1 disp~seis:\n"); print(corr.test(data$disp, data$seis, use="pairwise", method="spearman"))
cat("\nH2.2 disp~redist:\n"); print(corr.test(data$disp, data$redist, use="pairwise", method="spearman"))
sink()
cat("DONE\n")
