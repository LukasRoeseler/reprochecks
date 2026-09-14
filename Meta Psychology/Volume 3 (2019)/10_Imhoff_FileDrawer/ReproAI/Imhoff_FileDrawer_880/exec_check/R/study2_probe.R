options(contrasts=c("contr.sum","contr.poly"))
suppressMessages({library(car)})
DATA <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/10_Imhoff_FileDrawer/ReproAI/Imhoff_FileDrawer_880/extracted/osf_ja3yx_raw"
rd <- function(p) read.csv2(file.path(DATA, p), sep=";", dec=",", stringsAsFactors=FALSE, check.names=FALSE)
s2 <- rd("Study 2- Bogus Pipeline x Perpetrator Group/2_Data/dfg_as_study2_OSF.csv")
s2$bp<-factor(s2$bp); s2$prime<-factor(s2$prime)
r <- resid(lm(prejudice_post ~ prejudice_pre, data=s2))
chg <- s2$prejudice_post - s2$prejudice_pre
cands <- list(
  "scale(resid)"          = as.numeric(scale(r)),
  "resid/sd(resid)"       = r/sd(r),
  "resid/mse(resid)"      = r/sqrt(sum(r^2)/ (length(r)-1)),
  "raw resid"             = r,
  "change score"          = chg,
  "raw post"              = s2$prejudice_post,
  "resid/sd over n"       = r/sqrt(sum(r^2)/length(r))
)
for(nm in names(cands)){
  d <- s2; d$dv <- cands[[nm]]
  a <- car::Anova(aov(dv ~ bp*prime, data=d), type=3)
  Fp <- a["prime","F value"]; pp <- a["prime","Pr(>F)"]
  Fb <- a["bp","F value"]; Fi <- a["bp:prime","F value"]
  cat(sprintf("%-22s prime F=%8.3f p=%.5f | bp F=%7.3f | inter F=%7.3f\n", nm, Fp, pp, Fb, Fi))
}
cat("\nManuscript Study2: bogus main F(1,92)=0.05 p=.830, victim main F(1,92)=15.74 p<.001, eta2p=.17, interaction F(1,92)=0.01 p=.919\n")
# partial eta2 for F=18.53: 
a <- car::Anova(aov(as.numeric(scale(r)) ~ bp*prime, data=s2), type=3)
SSp<-a["factor(prime)","Sum Sq"]; SSe<-a["Residuals","Sum Sq"]
cat("prime partial eta2 under scale(resid):", SSp/(SSp+SSe), "\n")
