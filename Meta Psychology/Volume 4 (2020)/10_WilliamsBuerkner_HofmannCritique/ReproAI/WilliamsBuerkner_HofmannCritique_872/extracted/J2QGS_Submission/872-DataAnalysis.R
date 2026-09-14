require(metafor)

# load data
adata <- read.csv("dat.csv")
# assumed correlation, which was the same as the primary study
adata$ri <- 0.7 # assume 0.7

# compute both SMD and SMCR effect sizes
adata <- escalc(measure="SMD", m1i=oxyMean_pre, sd1i=oxySd_pre, 
                n1i=oxyN, m2i=plaMean_pre, sd2i=plaSd_pre, 
                n2i=plaN, data=adata, var.names = c("SMD_pre", "vSMD_pre"))

adata <- escalc(measure="SMD", m1i=oxyMean_post, sd1i=oxySd_post, 
                n1i=oxyN, m2i=plaMean_post, sd2i=plaSd_post, 
                n2i=plaN, data=adata, var.names = c("SMD_post", "vSMD_post"))



adata <- escalc(measure="SMCR", m1i=oxyMean_post, m2i=oxyMean_pre,
                sd1i=oxySd_pre, ni=oxyN, ri = ri,
                data=adata, var.names = c("oxySMCR", "voxySMCR"))

adata <- escalc(measure="SMCR", m1i=plaMean_post, m2i=plaMean_pre,
                sd1i=plaSd_pre, ni=plaN, ri = ri,
                data=adata, var.names = c("plaSMCR", "vplaSMCR"))

adata$SMCR <- adata$oxySMCR - adata$plaSMCR
adata$SMCR <- adata$SMCR
adata$vSMCR <- adata$voxySMCR + adata$vplaSMCR

# enter in averbeck data by hand in excel and save (effect = - 0.51, v = 0.19)
#write.csv(adata, "d_for_aver.csv")
#adata <- read.csv("d_for_aver.csv")
# there was not pre and post data for averbeck, so we assumed the same effect size
# for both SMD and SMCR. This is not optimal, of course, but sensitivity analysis 
# showed it did not influence the overal conclusion.
adata[1,20] <- - 0.51
adata[1,26] <- -0.51
adata[1,21] <- 0.19
adata[1,27] <- 0.19

# main analysis
## SMCR
m.smcr <- rma(SMCR * - 1, vi = vSMCR,  subset = (overall== 1), data = adata, slab = name)
# trim and fill
trimfill(m.smcr)

## SMD
m.smd <- rma(SMD_post * -1, vi = vSMD_post,   subset = (overall == 1), data = adata, slab = name)
# trim and fill
trimfill(m.smd)

# moderator for symptom types
m.smcr.mod <- rma(SMCR * -1, vi = vSMCR, mods = ~ disorder - 1, data = adata, slab = name)
m.smcr.mod

m.smd.mod <- rma(SMD_post * -1, vi = vSMD_post, mods = ~ disorder - 1, data = adata, slab = name)
m.smd.mod

# only total psychotic
m.smcr.mod <- rma(SMCR * -1, vi = vSMCR,subset = (psycho_tot== 1) , data = adata, slab = name)
m.smcr.mod

m.smd.mod <- rma(SMD_post * -1, vi = vSMD_post, subset = (psycho_tot== 1), data = adata, slab = name)
m.smd.mod


