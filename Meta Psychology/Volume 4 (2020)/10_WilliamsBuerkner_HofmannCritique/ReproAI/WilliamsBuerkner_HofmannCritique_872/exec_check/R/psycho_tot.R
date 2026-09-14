suppressMessages(require(metafor))
a <- read.csv('dat.csv')
a$ri <- 0.7
a <- escalc(measure='SMD', m1i=oxyMean_post, sd1i=oxySd_post, n1i=oxyN,
            m2i=plaMean_post, sd2i=plaSd_post, n2i=plaN, data=a,
            var.names=c('SMD_post','vSMD_post'))
a <- escalc(measure='SMCR', m1i=oxyMean_post, m2i=oxyMean_pre, sd1i=oxySd_pre,
            ni=oxyN, ri=ri, data=a, var.names=c('oxySMCR','voxySMCR'))
a <- escalc(measure='SMCR', m1i=plaMean_post, m2i=plaMean_pre, sd1i=plaSd_pre,
            ni=plaN, ri=ri, data=a, var.names=c('plaSMCR','vplaSMCR'))
a$SMCR <- a$oxySMCR - a$plaSMCR
a$vSMCR <- a$voxySMCR + a$vplaSMCR
m1 <- rma(SMCR*-1, vi=vSMCR, subset=(psycho_tot==1), data=a)
m2 <- rma(SMD_post*-1, vi=vSMD_post, subset=(psycho_tot==1), data=a)
out <- data.frame(kind=c('SMCR','SMD'),
                  ES=round(c(m1$b[1], m2$b[1]),4),
                  SE=round(c(m1$se[1], m2$se[1]),4),
                  z=round(c(m1$zval[1], m2$zval[1]),4),
                  p=round(c(m1$pval[1], m2$pval[1]),4))
write.csv(out, 'output/psycho_tot_repro.csv', row.names=FALSE)
cat("SMCR pt:", out[1,2], "z=", out[1,4], "p=", out[1,5], "\n")
cat("SMD  pt:", out[2,2], "z=", out[2,4], "p=", out[2,5], "\n")
