suppressPackageStartupMessages({
  library(readr); library(dplyr); library(lme4); library(ordinal)
})
out <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/10_714931/ReproAI/714931/exec_check/output"
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/10_714931/ReproAI/714931"
d <- read.delim(file.path(base,"extracted","Cordova_Kras_dataset.txt"), sep="\t", na.strings="")
names(d)[names(d)=="Loggdp_2012"] <- "Loggdp"
names(d)[names(d)=="Logpopsize"] <- "Logpop"

res <- list()
res$N <- nrow(d)
res$n_muni <- length(unique(d$cidade))
res$n_wps_muni <- length(unique(d$cidade[d$deam==1]))
res$pct_interviews_wps <- round(100*sum(d$deam==1)/nrow(d),1)
res$n_female <- sum(d$female==1); res$n_male <- sum(d$female==0)
# descriptives: strongly agree (value 5) by gender
res$men_agree_dv1 <- round(100*sum(d$b4dr==5 & d$female==0, na.rm=TRUE)/sum(d$female==0 & !is.na(d$b4dr)),1)
res$women_agree_dv1 <- round(100*sum(d$b4dr==5 & d$female==1, na.rm=TRUE)/sum(d$female==1 & !is.na(d$b4dr)),1)
res$men_agree_byst <- round(100*sum(d$b11ar==5 & d$female==0, na.rm=TRUE)/sum(d$female==0 & !is.na(d$b11ar)),1)
res$women_agree_byst <- round(100*sum(d$b11ar==5 & d$female==1, na.rm=TRUE)/sum(d$female==1 & !is.na(d$b11ar)),1)
res$knowvictim_pct <- round(100*sum(d$knowvictim==1, na.rm=TRUE)/sum(!is.na(d$knowvictim)),1)
res$b9a_yes <- sum(d$b9a==1, na.rm=TRUE); res$b9a_no <- sum(d$b9a==0, na.rm=TRUE)
res$b9a_pct <- round(100*res$b9a_yes/(res$b9a_yes+res$b9a_no),1)

cat("=== DESCRIPTIVES ===\n")
for (nm in names(res)) cat(sprintf("%-24s %s\n", nm, paste(res[[nm]],collapse=",")))

# --- Model setup: factor codings matching Stata i.b0./i.b1. ---
d$edlevel_f <- factor(d$edlevel, levels=0:3)                      # base 0
d$p2a_f     <- factor(d$p2a, levels=1:3)                          # base 1
d$marital_f <- factor(d$marital_status, levels=1:6)               # base 1
d$color_f   <- factor(d$color, levels=1:5)                        # base 1
ctl <- glmerControl(optCtrl=list(maxfun=200000))

fit_binary <- function(form_txt){
  f <- as.formula(paste(form_txt, " + (1|cidade)"))
  suppressWarnings(glmer(f, data=d, family=binomial, control=ctl))
}
d$b4dr_f <- ordered(d$b4dr, levels=1:5)
d$b11ar_f <- ordered(d$b11ar, levels=1:5)
fit_ordered <- function(form_txt){
  f <- as.formula(paste(form_txt, " + (1|cidade)"))
  suppressWarnings(clmm(f, data=d, control=clmm.control(maxIter=4000, maxLineIter=12000)))
}

cat("\n=== TABLE A3: melogit b9a deam (Figure 6) ===\n")
m <- fit_binary("b9a ~ deam + vaw_law + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f")
s <- summary(m)
print(coef(s)[c("(Intercept)","deam"),])
cat("N used:", nobs(m), "\n")

cat("\n=== TABLE 1 Model 2: meologit b4dr deam##female (Figure 1) ===\n")
m2.o <- fit_ordered("b4dr_f ~ deam*female + vaw_law*female + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f")
cat("N used:", m2.o$n, "\n")
b2 <- m2.o$coefficients
cat("deam:", b2["deam"], "\n"); cat("female:", b2["female"], "\n"); cat("deam:female:", b2["deam:female"], "\n")

cat("\n=== TABLE 1 Model 4: meologit b4dr num_years##female (Figure 2) ===\n")
m4.o <- fit_ordered("b4dr_f ~ num_years*female + vaw_law*female + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f")
cat("N used:", m4.o$n, "\n")
b4 <- m4.o$coefficients
cat("num_years:", b4["num_years"], "\n"); cat("female:", b4["female"], "\n"); cat("num_years:female:", b4["num_years:female"], "\n")

cat("\n=== TABLE 1 Model 6: meologit b11ar deam##female (Figure 3) ===\n")
m6.o <- fit_ordered("b11ar_f ~ deam*female + vaw_law*female + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f")
cat("N used:", m6.o$n, "\n")
b6 <- m6.o$coefficients
cat("deam:", b6["deam"], "\n"); cat("female:", b6["female"], "\n"); cat("deam:female:", b6["deam:female"], "\n")

cat("\n=== TABLE 1 Model 8: meologit b11ar num_years##female (Figure 4) ===\n")
m8.o <- fit_ordered("b11ar_f ~ num_years*female + vaw_law*female + civilpolice + femiciderate + Loggdp + Logpop + b4gr + q91cr + q91er + c1r + q89er + edlevel_f + classe + q53r + p2a_f + marital_f + children + color_f")
cat("N used:", m8.o$n, "\n")
b8 <- m8.o$coefficients
cat("num_years:", b8["num_years"], "\n"); cat("female:", b8["female"], "\n"); cat("num_years:female:", b8["num_years:female"], "\n")

vs <- list(M2=list(deam=b2["deam"],female=b2["female"],interaction=b2["deam:female"]),
           M4=list(ny=b4["num_years"],female=b4["female"],interaction=b4["num_years:female"]),
           M6=list(deam=b6["deam"],female=b6["female"],interaction=b6["deam:female"]),
           M8=list(ny=b8["num_years"],female=b8["female"],interaction=b8["num_years:female"]))
capture.output(print(vs), file=file.path(out,"key_coefficients.txt"))
cat("\nSaved key coefficients to output.\n")

