sink("Study4a4b_out.txt", split=TRUE)
cat("===== STUDY 4a/4b (SPENT experiments) =====\n\n")
setwd("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/work/7cg2h")
library(psych); library(effsize)

cat("############ STUDY 4a ############\n")
study4a <- read.csv("Study_4a.csv")
cat("Study4a n rows:", nrow(study4a), " n col:", ncol(study4a), "\n")
cols_7pt <- c(30,38,45,49,29,32,34,35,41,44,47,51,59,60,62)
cols_5pt <- c(74,81,84,73,82,80,85)
study4a[cols_7pt] <- apply(study4a[cols_7pt], MARGIN=2, function(x) x <- 8 - x)
study4a[cols_5pt] <- apply(study4a[cols_5pt], MARGIN=2, function(x) x <- 6 - x)
col.gbpdisp <- c(16,17,18,19); col.gbpsit <- c(20,21,22,23,24,25,26)
study4a$gbpdisp <- rowMeans(study4a[,col.gbpdisp], na.rm=TRUE)
study4a$gbpsit <- rowMeans(study4a[,col.gbpsit], na.rm=TRUE)
col.nndisp <- c(30,31,37,38,39,42,45,46,48,49,50,52,53,54,56,57,58)
col.nnsit <- c(29,32,33,34,35,36,41,43,44,47,51)
study4a$nndisp <- rowMeans(study4a[,col.nndisp], na.rm=TRUE)
study4a$nnsit <- rowMeans(study4a[,col.nnsit], na.rm=TRUE)
col.seis <- c(59,60,62,63,64); study4a$seis <- rowMeans(study4a[,col.seis], na.rm=TRUE)
col.redist <- c(68,69,70,71); study4a$redist <- rowMeans(study4a[,col.redist], na.rm=TRUE)
col.EC <- c(72,74,77,81,84,86,88); study4a$EC <- rowMeans(study4a[,col.EC], na.rm=TRUE)
col.PT <- c(73,76,79,82,87,90,92); study4a$PT <- rowMeans(study4a[,col.PT], na.rm=TRUE)
col.PD <- c(75,78,80,83,85,89,91); study4a$PD <- rowMeans(study4a[,col.PD], na.rm=TRUE)
col.emp <- c(72,74,77,81,84,86,88,73,76,79,82,87,90,92,75,78,80,83,85,89,91)
study4a$emp.tot <- rowMeans(study4a[,col.emp], na.rm=TRUE)

cat("\ncheck column positions of composites:\n")
tv <- c("gbpdisp","gbpsit","nndisp","nnsit","seis","redist","EC","PT","PD","emp.tot")
for(v in tv) cat(v,"->",which(names(study4a)==v),"\n")

cat("\n--- t-tests condition (1=Monopoly, 2=SPENT) on composites ---\n")
compcols <- c("gbpdisp","gbpsit","nndisp","nnsit","seis","redist","EC","PT","PD","emp.tot")
for(v in compcols){
  cat("\n### ", v, "\n")
  print(t.test(study4a[[v]] ~ study4a$condition, var.equal=TRUE))
  cat("cohen.d:", effsize::cohen.d(study4a[[v]]~study4a$condition)$estimate, "\n")
}

cat("\n### MEDIATION (nnsit as mediator of condition -> seis), lavaan ###\n")
cols = c('seis','condition','nndisp','nnsit')
study4a[cols] <- sapply(study4a[cols], function(x) scale(x, scale=TRUE, center=TRUE))
model <- ' seis ~ c*condition
nndisp ~ a1*condition
nnsit ~ a2*condition
seis ~ b1*nndisp
seis ~ b2*nnsit
a1b1 := a1*b1
a2b2 := a2*b2
total := c + (a1*b1) + (a2*b2) '
suppressMessages(library(lavaan))
fit <- sem(model, data=study4a)
print(summary(fit, standardized=TRUE))

cat("\n############ STUDY 4b ############\n")
study4b <- read.csv("Study_4b.csv")
cat("Study4b n rows:", nrow(study4b), " n col:", ncol(study4b), "\n")
cols_7pt <- c(18,26,33,37,17,20,22,23,29,32,35,39,47,48,49)
study4b[cols_7pt] <- apply(study4b[cols_7pt], MARGIN=2, function(x) x <- 8 - x)
col.ind.att <- c(18,19,25,26,27,30,33,34,36,37,38,40,41,42,44,45,46)
col.sys.att <- c(17,20,21,22,23,24,29,31,32,35,39)
study4b$disp <- rowMeans(study4b[,col.ind.att], na.rm=TRUE)
study4b$sit <- rowMeans(study4b[,col.sys.att], na.rm=TRUE)
col.seis <- c(47,48,49,50,51); study4b$seis <- rowMeans(study4b[,col.seis], na.rm=TRUE)
col.redist <- c(117,118,119,120); study4b$redist <- rowMeans(study4b[,col.redist], na.rm=TRUE)
cat("\ncomposite col positions: disp->",which(names(study4b)=="disp")," sit->",which(names(study4b)=="sit"),
    " seis->",which(names(study4b)=="seis")," redist->",which(names(study4b)=="redist"),"\n")

cat("\n--- Confirmatory t-tests (1=SPENT, 2=No-game control) ---\n")
cat("\nH1.1 sit (alt greater):\n"); print(t.test(study4b$sit~study4b$cond, alternative='g', var.equal=TRUE))
cat("\nH1.4 redist (alt greater):\n"); print(t.test(study4b$redist~study4b$cond, alternative='g', var.equal=TRUE))
cat("\nH1.2 disp (alt less):\n"); print(t.test(study4b$disp~study4b$cond, alternative='l', var.equal=TRUE))
cat("\nH1.3 seis (alt less):\n"); print(t.test(study4b$seis~study4b$cond, alternative='l', var.equal=TRUE))
cat("\n--- cohen d (disp, sit, seis, redist) ---\n")
for(v in c("disp","sit","seis","redist")){
  cat(v,"cohen.d:", effsize::cohen.d(study4b[[v]]~study4b$cond)$estimate, "\n")
}
sink()
cat("DONE\n")
