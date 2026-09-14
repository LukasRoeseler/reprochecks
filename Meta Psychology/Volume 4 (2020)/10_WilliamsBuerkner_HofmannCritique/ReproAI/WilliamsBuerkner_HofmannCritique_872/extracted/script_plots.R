require(metafor)
m.smcr <- rma(SMCR * -1, vi = vSMCR,  subset = (overall== 1), data = adata, slab = name)
m.smd <- rma(SMD_post * -1, vi = vSMD_post,   subset = (overall == 1), data = adata, slab = name)

# forets plots
# SMCR
dcex <- 2
par(mar = c(2, 4, .5, 2) + 0.1)
forest(m.smcr, xlab = "Psychiatric Symptoms", 
       cex.lab = 1.25, cex.axis = .75, digits = 2)
text(-5.5, 17.5, "Authors (Year)")
text(4.25, 17.5, "SMCR")
text(5.75, 17.5, "[95%-CI]")

# SMD
forest(m.smd, xlab = "Psychiatric Symptoms", 
       cex.lab = 1.25, cex.axis = .75, digits = 2)
text(-4.85, 17.5, "Authors (Year)")
text(4.5, 17.5, "SMD")
text(5.75, 17.5, "[95%-CI]")

# trim and fill as done in Hofmann et al (2015)
# SMCR
t.smcr <- trimfill(m.smcr, estimator = "L0")
par( mar = c(5, 5, 5, 5))
funnel(t.smcr, xlab = "SMCR: Psychiatric Symptoms", 
       cex.lab = 1.25, cex.axis = 1, digits = 2, ylab = "", back = "grey90")


# SMD
t.smd <- trimfill(m.smd)
forest(m.smd)
funnel(t.smd, xlab = "SMD: Psychiatric Symptoms",
       cex.lab = 1.25, cex.axis = 1, digits = 2, back = "grey90")