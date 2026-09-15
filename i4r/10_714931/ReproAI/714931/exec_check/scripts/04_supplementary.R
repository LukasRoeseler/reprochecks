suppressPackageStartupMessages({library(readr);library(dplyr);library(lme4)})
out <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/10_714931/ReproAI/714931/exec_check/output"
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/10_714931/ReproAI/714931"
d <- read.delim(file.path(base,"extracted","Cordova_Kras_dataset.txt"), sep="\t", na.strings="")
names(d)[names(d)=="Loggdp_2012"] <- "Loggdp"; names(d)[names(d)=="Logpopsize"] <- "Logpop"
d$edlevel_f <- factor(d$edlevel, levels=0:3); d$p2a_f <- factor(d$p2a, levels=1:3)
d$marital_f <- factor(d$marital_status, levels=1:6); d$color_f <- factor(d$color, levels=1:5)
cat("num_years range (non-NA):", range(d$num_years, na.rm=TRUE), "\n")
cat("num_years NA count:", sum(is.na(d$num_years)), "\n")

ctl <- glmerControl(optCtrl=list(maxfun=200000))

# Table A2: knowvictim ~ num_years##female ...
m <- glmer(knowvictim ~ num_years*female + vaw_law*female + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f + (1|cidade), data=d, family=binomial, control=ctl)
s <- summary(m)$coefficients
cat("\nTable A2 key coef (manu: num_years -0.008, female 0.734***, num:female -0.024*):\n")
print(s[c("num_years","female","num_years:female"),c(1,2,4)])
cat("N:", nobs(m), " (manu 1338)\n")

# Table A17: knowdeam1 ~ num_years + female + ...
m2 <- glmer(knowdeam1 ~ num_years + female + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f + (1|cidade), data=d, family=binomial, control=ctl)
s2 <- summary(m2)$coefficients
cat("\nTable A17 key coef (manu: num_years 0.059**, female 0.249+):\n")
print(s2[c("num_years","female"),c(1,2,4)])
cat("N:", nobs(m2), " (manu 1360)\n")

# VIF for main interactions (OLS, cl integrity check) - Table A11
vif_reg <- function(form, df){
  X <- model.matrix(form, data=df)
  y <- df$b4dr
  Xc <- X; yc <- y
  Xc[,1] <- 1
  # VIF via cor of regressors
  num <- diag(solve(cor(Xc)))
  dat <- data.frame(var=colnames(Xc), vif=num)
  dat[order(-dat$vif),][1:12,]
}
cat("\nSample VIF (main WPS model, diagnostic only) top 12:\n")
print(vif_reg(~ deam*female + vaw_law*female + femiciderate + Loggdp + Logpop + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f, d))
