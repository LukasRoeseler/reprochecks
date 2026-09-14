suppressMessages(require(metafor))
options(width=250)
# J2QGS Submission variant of author script
adata <- read.csv("dat.csv")
adata$ri <- 0.7
adata <- escalc(measure="SMD", m1i=oxyMean_pre, sd1i=oxySd_pre, n1i=oxyN,
                m2i=plaMean_pre, sd2i=plaSd_pre, n2i=plaN, data=adata,
                var.names = c("SMD_pre", "vSMD_pre"))
adata <- escalc(measure="SMD", m1i=oxyMean_post, sd1i=oxySd_post, n1i=oxyN,
                m2i=plaMean_post, sd2i=plaSd_post, n2i=plaN, data=adata,
                var.names = c("SMD_post", "vSMD_post"))
adata <- escalc(measure="SMCR", m1i=oxyMean_post, m2i=oxyMean_pre, sd1i=oxySd_pre,
                ni=oxyN, ri = ri, data=adata, var.names = c("oxySMCR", "voxySMCR"))
adata <- escalc(measure="SMCR", m1i=plaMean_post, m2i=plaMean_pre, sd1i=plaSd_pre,
                ni=plaN, ri = ri, data=adata, var.names = c("plaSMCR", "vplaSMCR"))
adata$SMCR <- adata$oxySMCR - adata$plaSMCR
adata$vSMCR <- adata$voxySMCR + adata$vplaSMCR
# J2QGS hard-coding
adata[1,20] <- -0.51
adata[1,26] <- -0.51
adata[1,21] <- 0.19
adata[1,27] <- 0.19
cat("Row1 after J2QGS hard-coding:\n")
print(data.frame(SMD_post=adata$SMD_post[1], vSMD_post=adata$vSMD_post[1],
                 SMCR=adata$SMCR[1], vSMCR=adata$vSMCR[1]))
cat("\nOverall SMD (J2QGS script):\n")
print(summary(rma(SMD_post * -1, vi=vSMD_post, subset=(overall==1), data=adata)))
cat("\nOverall SMCR (J2QGS script):\n")
print(summary(rma(SMCR * -1, vi=vSMCR, subset=(overall==1), data=adata)))
cat("\n--- kd3en script Row1 (for contrast) ---\n")
