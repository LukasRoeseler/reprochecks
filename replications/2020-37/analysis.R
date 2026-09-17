suppressMessages(library(haven))
dir <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/y2mdw/Data"
f <- list.files(dir, pattern="\\.sav$", full.names=TRUE)
d <- as.data.frame(read_sav(f))

cat("==============================================\n")
cat("REPRODUCTION ANALYSIS - Gotz et al 2020 (NHB)\n")
cat("Paper: Physical topography is associated with human personality\n")
cat("DOI: 10.1038/s41562-020-0930-x  (Nat Hum Behav 4:1135-1144)\n")
cat("==============================================\n\n")

cat("DATASET\n")
cat("  Rows (ZIP codes):", nrow(d), "\n")
cat("  Columns:", ncol(d), "\n")
cat("  ZIPCode range:", min(d$ZIPCode), "-", max(d$ZIPCode), "\n")
cat("  Unique ZIP codes:", length(unique(d$ZIPCode)), "\n\n")

# Define indices
ind20 <- d[, c("Mountainousness_sd_elevation_20mile",
               "Mountainousness_mssd_elevation_20mile",
               "Mountainousness_mean_elevation_20mile")]
ind50 <- d[, c("Mountainousness_sd_elevation_50mile",
               "Mountainousness_mssd_elevation_50mile",
               "Mountainousness_mean_elevation_50mile")]
names(ind20) <- c("SD20","MSSD20","MEAN20")
names(ind50) <- c("SD50","MSSD50","MEAN50")

cat("--- REPORTED inter-index correlations (paper Methods, 20-mile default) ---\n")
cat("  mountainousness/MSSD r = .89\n")
cat("  mountainousness/elevation r = .66\n")
cat("  mountainousness-MSSD/elevation r = .61\n\n")

cat("--- RECOMPUTED (20-mile), pairwise complete ---\n")
c20 <- cor(ind20, use="pairwise.complete.obs")
cat(sprintf("  SD vs MSSD   r = %.4f\n", c20[1,2]))
cat(sprintf("  SD vs MEAN   r = %.4f\n", c20[1,3]))
cat(sprintf("  MSSD vs MEAN r = %.4f\n", c20[2,3]))
cat("  N complete for each pair:\n")
cat(sprintf("    SD/MSSD n=%d, SD/MEAN n=%d, MSSD/MEAN n=%d\n",
    sum(complete.cases(ind20[,c(1,2)])), sum(complete.cases(ind20[,c(1,3)])), sum(complete.cases(ind20[,c(2,3)]))))

cat("\n--- RECOMPUTED (50-mile), pairwise complete ---\n")
c50 <- cor(ind50, use="pairwise.complete.obs")
cat(sprintf("  SD vs MSSD   r = %.4f\n", c50[1,2]))
cat(sprintf("  SD vs MEAN   r = %.4f\n", c50[1,3]))
cat(sprintf("  MSSD vs MEAN r = %.4f\n", c50[2,3]))

cat("\n--- EXTREME ZIP CODES (verifying paper claims) ---\n")
sd20 <- d$Mountainousness_sd_elevation_20mile
cat("Most mountainous (max SD, 20mi):", d$ZIPCode[which.max(sd20)], "value", max(sd20,na.rm=TRUE),
    "| paper says 93526 Independence, CA\n")
cat("Least mountainous (min SD, 20mi):", d$ZIPCode[which.min(sd20)], "value", min(sd20,na.rm=TRUE),
    "| paper says 27915 Avon, NC\n")
mssd20 <- d$Mountainousness_mssd_elevation_20mile
cat("Max MSSD (20mi):", d$ZIPCode[which.max(mssd20)], "value", max(mssd20,na.rm=TRUE),
    "| paper says 98267 Marblemount, WA\n")
cat("Min MSSD (20mi):", d$ZIPCode[which.min(mssd20)], "value", min(mssd20,na.rm=TRUE),
    "| paper says 27915 Avon, NC\n")
me20 <- d$Mountainousness_mean_elevation_20mile
cat("Max mean elev (20mi):", d$ZIPCode[which.max(me20)], "value", max(me20,na.rm=TRUE),
    "| paper says 81433 Silverton, CO\n")
cat("Min mean elev (20mi):", d$ZIPCode[which.min(me20)], "value", min(me20,na.rm=TRUE),
    "| paper says 92281 Westmorland, CA\n")

cat("\n--- N used in analysis ---\n")
cat("  Paper: N individuals = 3,387,014; ZIP codes = 37,227\n")
cat("  This file: ZIP rows =", nrow(d), " (includes ZIPs w/o personality data)\n")

cat("\n--- MISSINGNESS ---\n")
print(colSums(is.na(d)))

cat("\n--- KEY LIMITATION ---\n")
cat("  Archive contains ONLY mountainousness indices (ZIP-level).\n")
cat("  Personality outcomes (Gosling-Potter, N=3.4M) are PROPRIETARY and NOT archived.\n")
cat("  Therefore multilevel models / beta coefficients CANNOT be recomputed.\n")

cat("\n--- DESCRIPTIVE STATS (paper-reported indices) ---\n")
print(summary(ind20))
