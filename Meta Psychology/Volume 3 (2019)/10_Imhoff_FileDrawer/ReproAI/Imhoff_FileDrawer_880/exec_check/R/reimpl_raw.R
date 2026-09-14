### ReproAI independent RAW-LEVEL reimplementation (R 4.6.1)
### Imhoff & Messer (2019) Meta-Psychology MP.2018.880 "Second. antisemitism: file drawer report"
### Audit date 2026-09-14
### Recomputes the primary statistics from the shipped raw OSF datasets (linked project ja3yx),
### following the exact analysis specs in the authors' .sps syntax (SPSS) reimplemented in R.
suppressMessages({library(metafor); library(car)})

DATA <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/10_Imhoff_FileDrawer/ReproAI/Imhoff_FileDrawer_880/extracted/osf_ja3yx_raw"
OUT  <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/10_Imhoff_FileDrawer/ReproAI/Imhoff_FileDrawer_880/exec_check/output"
dir.create(OUT, showWarnings=FALSE, recursive=TRUE)

rd <- function(p) read.csv2(file.path(DATA, p), sep=";", dec=",", stringsAsFactors=FALSE, check.names=FALSE)

report <- list()

cat("============================================================\n")
cat("PART 1: STUDY 1 (Bogus pipeline x ongoing suffering)\n")
cat("============================================================\n")
s1 <- rd("Study 1- Bogus Pipeline x Ongoing Suffering/2_Data/dfg_as_study1_OSF.csv")
cat("rows:", nrow(s1), "\n")
# cell sizes
print(table(s1$group, s1$bp))
# stability
r.stab <- cor(s1$pre_ma, s1$post_ma, use="pairwise.complete.obs")
cat(sprintf("stability r=%0.3f  (manuscript r(83)=.89)\n", r.stab))
# residual regression
fit1 <- lm(post_ma ~ pre_ma, data=s1)
zres <- as.numeric(scale(resid(fit1)))
s1$zres <- zres
aov1 <- car::Anova(aov(zres ~ factor(bp)*factor(group), data=s1), type=3)
print(aov1)
# t-test implicit guilt by group (SPSS T-TEST GROUPS=group(1 2))
tt.guilt <- t.test(ipanat_guilt ~ factor(group, levels=c(1,2)), data=s1, var.equal=TRUE)
cat(sprintf("implicit guilt t=%0.3f df=%0.0f p=%0.3f | means %.2f vs %.2f (manuscript t=0.93 p=.354)\n",
    tt.guilt$statistic, tt.guilt$parameter, tt.guilt$p.value,
    tt.guilt$estimate[1], tt.guilt$estimate[2]))
# correlation under bp=1
s1b <- subset(s1, bp==1)
rcor <- cor.test(s1b$ipanat_guilt, s1b$post_ma)
cat(sprintf("cor ipanat_guilt~post_ma under bp=1: r=%0.3f n=%d p=%0.3f (manuscript r(44)=.12 p=.451)\n",
    rcor$estimate, sum(complete.cases(s1b[,c("ipanat_guilt","post_ma")])), rcor$p.value))

cat("\n============================================================\n")
cat("PART 2: STUDY 2 (Perpetrator group x bogus pipeline)\n")
cat("============================================================\n")
s2 <- rd("Study 2- Bogus Pipeline x Perpetrator Group/2_Data/dfg_as_study2_OSF.csv")
cat("rows:", nrow(s2), "\n")
print(table(s2$prime, s2$bp))
# stability split by prime
for(pv in 1:2){
  d <- subset(s2, prime==pv)
  r2 <- cor(d$prejudice_post, d$prejudice_pre, use="pairwise.complete.obs")
  n2 <- sum(complete.cases(d[,c("prejudice_post","prejudice_pre")]))
  cat(sprintf("prime=%d stability r=%0.3f n=%d  (manuscript jewish r(44)=.57 , chinese r(52)=.72)\n", pv, r2, n2))
}
# residual
fit2 <- lm(prejudice_post ~ prejudice_pre, data=s2)
s2$zres <- as.numeric(scale(resid(fit2)))
aov2 <- car::Anova(aov(zres ~ factor(bp)*factor(prime), data=s2), type=3)
print(aov2)

cat("\n============================================================\n")
cat("PART 3: STUDIES 3a,3b,3c (Phase2 warmth ratings, RM 2x2)\n")
cat("============================================================\n")
rm3 <- function(label, d, n_rep){
  d <- d[complete.cases(d[,c("cctr_warmth","chol_warmth","jctr_warmth","jhol_warmth")]),]
  n <- nrow(d)
  # order per GLM: cctr chol jctr jhol ; factors jewish(+ for j) holocaust(+ for hol)
  D_int <- d$cctr_warmth - d$chol_warmth - d$jctr_warmth + d$jhol_warmth   # interaction contrast
  tt <- t.test(D_int)
  F_int <- tt$statistic^2
  p_int <- tt$p.value
  # Jewish main effect contrast: jctr+jhol -(cctr+chol)
  D_jew <- (d$jctr_warmth + d$jhol_warmth) - (d$cctr_warmth + d$chol_warmth)
  ttj <- t.test(D_jew); F_jew <- ttj$statistic^2; p_jew <- ttj$p.value
  # Holocaust main effect contrast
  D_hol <- (d$chol_warmth + d$jhol_warmth) - (d$cctr_warmth + d$jctr_warmth)
  tth <- t.test(D_hol); F_hol <- tth$statistic^2; p_hol <- tth$p.value
  cat(sprintf("%s: n=%d | interaction F(1,%d)=%0.3f p=%0.3f\n", label, n, n-1, F_int, p_int))
  cat(sprintf("   jewish main F=%0.3f p=%0.3f ; holocaust main F=%0.3f p=%0.3f\n", F_jew,p_jew,F_hol,p_hol))
  # Table 1 paired t between jhol and jctr (Jewish target, holocaust vs control)
  Dtab <- d$jhol_warmth - d$jctr_warmth
  ttab <- t.test(Dtab)
  cat(sprintf("   Table1 paired jhol vs jctr: t(%d)=%0.2f p=%0.3f  means jhol=%.2f jctr=%.2f SD %.2f %.2f\n",
      n-1, ttab$statistic, ttab$p.value, mean(d$jhol_warmth), mean(d$jctr_warmth), sd(d$jhol_warmth), sd(d$jctr_warmth)))
  list(n=n, F_int=F_int, p_int=p_int)
}
s3a <- rd("Study 3a-c- Subtle Prejudice via Reverse Correlation Image Classification/Study 3a/2_Data/dfg_as_study3a_phase2_OSF.csv")
s3b <- rd("Study 3a-c- Subtle Prejudice via Reverse Correlation Image Classification/Study 3b/2_Data/dfg_as_study3b_phase2_OSF.csv")
s3c <- rd("Study 3a-c- Subtle Prejudice via Reverse Correlation Image Classification/Study 3c/2_Data/dfg_as_study3c_phase2_OSF.csv")
r3a <- rm3("Study3a", s3a, 56)
r3b <- rm3("Study3b", s3b, 43)
r3c <- rm3("Study3c", s3c, 64)

cat("\n============================================================\n")
cat("PART 4: STUDY 4a (criticism of Israel)\n")
cat("============================================================\n")
s4a <- rd("Study 4 a + b- Less egalitarian sample/Study 4a/2_Data/dfg_as_study4a_OSF.csv")
cat("rows:", nrow(s4a), " table(condition):", paste(names(table(s4a$condition)), table(s4a$condition), collapse=" "), "\n")
tt4a <- t.test(as ~ factor(condition, levels=c(1,0)), data=s4a, var.equal=TRUE)
cat(sprintf("t(%0.0f)=%0.2f p=%0.3f  means %.2f vs %.2f SD %.2f %.2f (manuscript t(98)=-0.29 p=.776)\n",
    tt4a$parameter, tt4a$statistic, tt4a$p.value, tt4a$estimate[1], tt4a$estimate[2],
    sd(s4a$as[s4a$condition==1]), sd(s4a$as[s4a$condition==0])))

cat("\n============================================================\n")
cat("PART 5: STUDY 4b (criticism of Israel; raw recompute w/ exclusions)\n")
cat("============================================================\n")
rb <- rd("Study 4 a + b- Less egalitarian sample/Study 4b/2_Data/rawdata/dfg_as_study4b_raw_OSF.csv")
cat("rows(raw):", nrow(rb), "\n")
# count missings on as1..as18 per subject, exclusion: missings LT 10 (=> exclusions: missings >= 10)
idx <- paste0("as",1:18)
rb$nmiss <- apply(rb[,idx], 1, function(r) sum(is.na(r)))
cat("freq nmiss(>=10): ", sum(rb$nmiss >= 10), "\n")
rb <- rb[rb$nmiss < 10, ]
# recode reversed items
for(v in c("as1","as2","as3","as7","as8","as13","as14","as15","as18")) rb[[paste0(v,"r")]] <- 8 - rb[[v]]
keep <- paste0(c("as4","as5","as6","as9","as10","as11","as12","as16","as17"),"")
rev  <- unlist(lapply(c("as1","as2","as3","as7","as8","as13","as14","as15","as18"), function(v) paste0(v,"r")))
rb$antiisr <- rowMeans(rb[, c(keep, rev)], na.rm=TRUE)
rb$ni_g <- rowMeans(rb[, c("ni2","ni4","ni6")], na.rm=TRUE)
cat("rows(analysed N):", nrow(rb), " table(condition)", paste(names(table(rb$condition)), table(rb$condition), collapse=" "), "\n")
tt4b <- t.test(antiisr ~ factor(condition, levels=c(0,1)), data=rb, var.equal=TRUE)
cat(sprintf("t(%0.0f)=%0.2f p=%0.3f means %.2f vs %.2f SD %.2f %.2f (manuscript t(194)=0.14 p=.890)\n",
    tt4b$parameter, tt4b$statistic, tt4b$p.value,
    mean(rb$antiisr[rb$condition==0]), mean(rb$antiisr[rb$condition==1]),
    sd(rb$antiisr[rb$condition==0]), sd(rb$antiisr[rb$condition==1])))

cat("\n============================================================\n")
cat("PART 6: STUDY 5 (empathy & donation)\n")
cat("============================================================\n")
s5 <- rd("Study 5- Denied empathy/2_Data/dfg_as_study5_OSF.csv")
cat("rows:", nrow(s5), " table(group)", paste(names(table(s5$group)), table(s5$group), collapse=" "), "\n")
tt5e <- t.test(empathy ~ factor(group, levels=c(0,1)), data=s5, var.equal=TRUE)
cat(sprintf("empathy t(%0.0f)=%0.2f p=%0.3f means %.2f vs %.2f SD %.2f %.2f (manuscript t(96)=-1.53 p=.129)\n",
    tt5e$parameter, tt5e$statistic, tt5e$p.value,
    mean(s5$empathy[s5$group==0]), mean(s5$empathy[s5$group==1]),
    sd(s5$empathy[s5$group==0]), sd(s5$empathy[s5$group==1])))
d5 <- subset(s5, complete.cases(DO07_01))
cat("donation N complete:", nrow(d5), "\n")
tt5d <- t.test(DO07_01 ~ factor(group, levels=c(0,1)), data=d5, var.equal=TRUE)
cat(sprintf("donation t(%0.0f)=%0.2f p=%0.3f means %.2f vs %.2f SD %.2f %.2f (manuscript t(46)=0.74 p=.466)\n",
    tt5d$parameter, tt5d$statistic, tt5d$p.value,
    mean(d5$DO07_01[d5$group==0]), mean(d5$DO07_01[d5$group==1]),
    sd(d5$DO07_01[d5$group==0]), sd(d5$DO07_01[d5$group==1])))

cat("\n============================================================\n")
cat("PART 7: Meta-analysis (metafor REML) from Table 1 g & SE — headline\n")
cat("============================================================\n")
meta <- data.frame(
  study=c("S1","S2","S3a","S3b","S3c","S4a","S4b","S5"),
  yi=c(0.13,-0.08,0.54,0.17,-0.60,-0.06,0.02,-0.31),
  sei=c(0.30,0.30,0.20,0.16,0.15,0.20,0.14,0.20))
fit <- rma(yi=yi, sei=sei, method="REML", data=meta)
cat("Reported: Q(7)=27.14, p<.001, I2=72.26%, pooled ~0\n")
cat(sprintf("metafor REML: Q=%0.2f p=%.4f I2=%0.2f%% pooled=%.3f se=%.3f p=%.3f\n",
    fit$QE, fit$QEp, fit$I2, fit$b[1,1], fit$se[1], fit$pval[1]))
v <- meta$sei^2; w <- 1/v; mu <- sum(w*meta$yi)/sum(w)
Q <- sum(w*(meta$yi-mu)^2)
cat(sprintf("Fixed-effect cross-check: Q=%0.2f df=7 p=%.4f I2=%.2f%%\n", Q, pchisq(Q,7,lower.tail=FALSE), 100*max(0,(Q-7))/Q))

cat("\n==== END (status: OK) ====\n")
