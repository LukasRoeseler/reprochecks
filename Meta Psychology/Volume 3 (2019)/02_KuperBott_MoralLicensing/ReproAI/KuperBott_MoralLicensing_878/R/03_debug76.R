# Debug + correct k=76 construction
options(width=220)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/02_KuperBott_MoralLicensing/ReproAI/KuperBott_MoralLicensing_878/R")
suppressMessages({library(metafor); library(weightr)})
dat <- read.table("dat_new_s.txt", sep=" ", header=TRUE, fileEncoding="latin1")
dat$yi <- as.numeric(as.character(dat$yi)); dat$se <- as.numeric(as.character(dat$se)); dat$vi <- dat$se^2
dat$au <- gsub("^[. ]+","",dat$authors)
cat("nrow dat_new_s =", nrow(dat), "\n")
cat("Simbrunner rows by N:\n"); print(table(dat$N[dat$au=="(Simbrunner and Schlegelmilch (2016)"]))
cat("All Simbrunner N values:", dat$N[dat$au=="(Simbrunner and Schlegelmilch (2016)"], "\n")

keep_first <- function(au, st) {
  keep <- rep(TRUE, length(au))
  for (p in list(c(1,2),c(4,5),c(6,7),c(8,9),c(10,11),c(12,13),c(14,15),c(16,17)))
    keep[au=="Blanken et al. (2012)" & st %in% p & st != p[1]] <- FALSE
  for (p in list(c(1,2),c(3,4)))
    keep[au=="Bradley-Geist et al. (2010)" & st %in% p & st != p[1]] <- FALSE
  for (p in list(c(1,2),c(3,4)))
    keep[au=="Meijers et al. (2014)" & st %in% p & st != p[1]] <- FALSE
  keep
}
dat$keep <- keep_first(dat$au, dat$study)
dat$keep[ dat$au=="Effron (2014)" ] <- FALSE
dat$keep[ dat$au=="Kouchaki (2011)" ] <- FALSE
cat("\nafter pair+exclusion filter (before Simbrunner handling) =", sum(dat$keep), "\n")

d <- dat[dat$keep,]
sim <- d[d$au=="(Simbrunner and Schlegelmilch (2016)",]
other <- d[d$au!="(Simbrunner and Schlegelmilch (2016)",]
cat("other rows =", nrow(other), "; simbrunner rows =", nrow(sim), "\n")
sim52  <- sim[sim$N==52,]
sim57  <- sim[sim$N==57,]
sim111 <- sim[sim$N==111,]
mk <- function(sub, tag) data.frame(authors=tag, study=1, N=mean(sub$N), yi=mean(sub$yi),
     se=mean(sub$se), comparison=sub$comparison[1], decision_type=sub$decision_type[1],
     pub=sub$pub[1], country=sub$country[1], world_region=sub$world_region[1],
     ID=sub$ID[1], vi=mean(sub$se)^2, au=tag, keep=TRUE)
fin <- rbind(other, sim52, mk(sim57,"Simbrunner agg n57"), mk(sim111,"Simbrunner agg n111"))
fin$yi<-as.numeric(fin$yi); fin$se<-as.numeric(fin$se); fin$vi<-as.numeric(fin$se)^2
cat("\nFINAL k =", nrow(fin), "\n")
cat("region counts: NOA=",sum(fin$world_region=="NOA",na.rm=TRUE)," EUR=",sum(fin$world_region=="EUR",na.rm=TRUE),
    " SEA=",sum(fin$world_region=="SEA",na.rm=TRUE)," NA=",sum(is.na(fin$world_region)),"\n")

mod1 <- rma(yi=yi,vi=vi,dat=fin)
cat("\nNAIVE rma k=",mod1$k," d=",round(mod1$b,4)," SE=",round(mod1$se,4)," Z=",round(mod1$zval,3),
    " p=",signif(mod1$pval,4)," CI[",round(mod1$ci.lb,3),";",round(mod1$ci.ub,3),"]\n")
cat("tau2=",round(mod1$tau2,4)," I2=",round(mod1$I2,2)," QE=",round(mod1$QE,2)," QEp=",signif(mod1$QEp,4),"\n")
pp_lm<-lm(fin$yi~fin$se,weights=1/fin$vi); pps<-summary(pp_lm); pdf_<-pps$df[2]; ci<-confint(pp_lm)[1,]
cat("PET-PEESE int=",round(coef(pp_lm)[1],3)," t(",pdf_,")=",round(pps$coefficients[1,3],2),
    " p=",round(pps$coefficients[1,4],3)," CI[",round(ci[1],3),";",round(ci[2],3),"]\n")
cat("   slope=",round(coef(pp_lm)[2],3)," t=",round(pps$coefficients[2,3],2)," p=",round(pps$coefficients[2,4],3),"\n")
saveRDS(fin,"output/fin76.rds")
cat("SAVED\n")
