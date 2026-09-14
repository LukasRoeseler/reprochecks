### Recompute Studies 1 & 2 ANOVAs with sum-to-zero contrasts (match SPSS Type III)
options(contrasts=c("contr.sum","contr.poly"))
suppressMessages({library(car)})
DATA <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/10_Imhoff_FileDrawer/ReproAI/Imhoff_FileDrawer_880/extracted/osf_ja3yx_raw"
rd <- function(p) read.csv2(file.path(DATA, p), sep=";", dec=",", stringsAsFactors=FALSE, check.names=FALSE)

cat("---- STUDY 1 (manuscript: bp F 0.05? no-> Study1 reports Fs<1 for mains, interaction F(1,79)=0.28 p=.602) ----\n")
s1 <- rd("Study 1- Bogus Pipeline x Ongoing Suffering/2_Data/dfg_as_study1_OSF.csv")
fit1 <- lm(post_ma ~ pre_ma, data=s1)
s1$zres <- as.numeric(scale(resid(fit1)))
s1$bp  <- factor(s1$bp);  s1$group <- factor(s1$group)
print(car::Anova(aov(zres ~ bp*group, data=s1), type=3))

cat("\n---- STUDY 2 (manuscript: bogus main F(1,92)=0.05 p=.830; victim main F(1,92)=15.74 p<.001; interaction F=0.01 p=.919) ----\n")
s2 <- rd("Study 2- Bogus Pipeline x Perpetrator Group/2_Data/dfg_as_study2_OSF.csv")
fit2 <- lm(prejudice_post ~ prejudice_pre, data=s2)
s2$zres <- as.numeric(scale(resid(fit2)))
s2$bp  <- factor(s2$bp);  s2$prime <- factor(s2$prime)
print(car::Anova(aov(zres ~ bp*prime, data=s2), type=3))

cat("\n---- also check residual score def (SPSS ZRESID = resid/RMSE). Compute via resid/sd and resid/mse ----\n")
cat("Study2 correlation between scale(resid) and resid/sd:", cor(as.numeric(scale(resid(fit2))), resid(fit2)/sd(resid(fit2))), "\n")
cat("Study2: does victim main become 15.74 under any residual scale? F is scale-invariant, so no.\n")
cat("Reported eta2p=.17 for victim main: check partial eta2 from our SS.\n")
a2 <- aov(zres ~ bp*prime, data=s2)
sm <- summary(a2)[[1]]
print(sm)
cat("residual df in aov (for 2x2 on n=96):", sm["Residuals","Df"], "\n")
