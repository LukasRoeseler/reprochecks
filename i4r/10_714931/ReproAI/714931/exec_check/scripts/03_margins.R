suppressPackageStartupMessages({
  library(readr); library(dplyr); library(lme4); library(ordinal)
})
out <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/10_714931/ReproAI/714931/exec_check/output"
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/10_714931/ReproAI/714931"
d <- read.delim(file.path(base,"extracted","Cordova_Kras_dataset.txt"), sep="\t", na.strings="")
names(d)[names(d)=="Loggdp_2012"] <- "Loggdp"; names(d)[names(d)=="Logpopsize"] <- "Logpop"
d$edlevel_f <- factor(d$edlevel, levels=0:3); d$p2a_f <- factor(d$p2a, levels=1:3)
d$marital_f <- factor(d$marital_status, levels=1:6); d$color_f <- factor(d$color, levels=1:5)
d$b4dr_f <- ordered(d$b4dr, levels=1:5)
d$b11ar_f <- ordered(d$b11ar, levels=1:5)

spec <- "deam*female + vaw_law*female + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f"
keepVars <- c("b4dr","b11ar","deam","num_years","vaw_law","civilpolice","femiciderate","Loggdp","Logpop","b4gr","q91cr","q91er","c1r","q89er","edlevel_f","classe","q53r","p2a_f","marital_f","children","color_f","female")
d0 <- d[complete.cases(d[,keepVars]),]

fit_ord <- function(dv){
  f <- as.formula(paste0(dv," ~ ", spec, " + (1|cidade)"))
  suppressWarnings(clmm(f, data=d, control=clmm.control(maxIter=6000, maxLineIter=20000)))
}
# fixed-only P(Y=5) averaging over sample, with field set to value & female held
p5 <- function(mod, field, value, fem){
  nd <- d0; nd[[field]] <- value; nd$female <- fem
  X <- model.matrix(as.formula(paste("~", spec)), data=nd)
  beta <- rep(0, ncol(X)); names(beta) <- colnames(X)
  b <- mod$beta
  for (nm in names(b)) if (nm %in% colnames(X)) beta[nm] <- b[nm]
  eta <- as.numeric(X %*% beta)
  a4 <- as.numeric(mod$alpha[length(mod$alpha)])
  p5 <- 1 - plogis(a4 - eta)
  mean(p5)
}

m_b9a <- glmer(b9a ~ deam + vaw_law + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f + (1|cidade),
               data=d, family=binomial, control=glmerControl(optCtrl=list(maxfun=200000)))
d0b <- d[complete.cases(d[,c("b9a","deam","vaw_law","civilpolice","femiciderate","Loggdp","Logpop","b4gr","q91cr","q91er","c1r","q89er","edlevel_f","classe","q53r","p2a_f","marital_f","children","color_f")]),]
cb <- function(v){ nd<-d0b; nd$deam<-v; mean(predict(m_b9a, newdata=nd, type="response", re.form=NA)) }
f6n <- 100*cb(0); f6y <- 100*cb(1)
cat(sprintf("FIG6 b9a: noWPS=%.2f WPS=%.2f diff=%.2f (manu 24.7/13.6/11.1)\n", f6n, f6y, f6n-f6y))

cat("Fitting M2 (b4dr deam##female) ...\n"); m2 <- fit_ord("b4dr_f")
cat("Fitting M4 (b4dr num_years##female) ...\n"); m4 <- fit_ord("b4dr_f"); 
cat("FIG1 (b4dr):\n")
cat(sprintf("  men  no=%.2f WPS=%.2f | women no=%.2f WPS=%.2f  (manu men 63.8/80.6, women 82.5)\n",
  100*p5(m2,"deam",0,0),100*p5(m2,"deam",1,0),100*p5(m2,"deam",0,1),100*p5(m2,"deam",1,1)))

cat("Fitting M6 (b11ar deam##female) ...\n"); m6 <- fit_ord("b11ar_f")
cat("FIG3 (b11ar):\n")
cat(sprintf("  men  no=%.2f WPS=%.2f | women no=%.2f WPS=%.2f  (manu men 56.0/81.7, diff 25.7)\n",
  100*p5(m6,"deam",0,0),100*p5(m6,"deam",1,0),100*p5(m6,"deam",0,1),100*p5(m6,"deam",1,1)))

df <- data.frame(quantity=c("Fig6 noWPS","Fig6 WPS","Fig6 diff","Fig1 men no","Fig1 men WPS","Fig1 women no","Fig1 women WPS","Fig3 men no","Fig3 men WPS","Fig3 women no","Fig3 women WPS"),
  value=c(f6n,f6y,f6n-f6y,100*p5(m2,"deam",0,0),100*p5(m2,"deam",1,0),100*p5(m2,"deam",0,1),100*p5(m2,"deam",1,1),100*p5(m6,"deam",0,0),100*p5(m6,"deam",1,0),100*p5(m6,"deam",0,1),100*p5(m6,"deam",1,1)))
write.csv(df, file.path(out,"predicted_probabilities.csv"), row.names=FALSE)
cat("Saved.\n")
