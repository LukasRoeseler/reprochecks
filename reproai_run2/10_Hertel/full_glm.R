library(haven)
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/10_Hertel"
df <- read_sav(file.path(d, "Ashley_labels.sav"))
df$Group <- as.factor(df$Group); df$CB <- as.factor(df$CB); df$SNO <- as.factor(df$SNO)
cat("N:", nrow(df), "\n")

# Full 6-cell within design: type(2:homograph H, nonhomograph NH) x cond(3:base,supp,new)
# DVs per cell
full <- data.frame(
  SNO=df$SNO, Group=df$Group, CB=df$CB,
  Hbase=df$FAHbaseC, Hsupp=df$FAHsuppC, Hnew=df$FAHnewC,
  NHbase=df$FANHbaseC, NHsupp=df$FANHsuppC, NHnew=df$FANHnewC
)
# Wide -> within factors via idata
withinf <- expand.grid(cond=c("base","supp","new"), type=c("H","NH"))
# ordering must match columns Hbase,Hsupp,Hnew,NHbase,NHsupp,NHnew => type changes slowest
# column order: Hbase(type=H,cond=base), Hsupp(H,supp), Hnew(H,new), NHbase(NH,base), NHsupp, NHnew
# so type varies slowest, cond fastest: withinf rows = (cond,type): base,H; supp,H; new,H; base,NH; supp,NH; new,NH
obs <- cbind(full$Hbase, full$Hsupp, full$Hnew, full$NHbase, full$NHsupp, full$NHnew)
mf <- expand.grid(cond=c("base","supp","new"), type=c("H","NH"))
design <- cbind(full[,c("Group","CB")], as.data.frame(obs))
mlm <- lm(obs ~ Group*CB, data=design)  # between factors on the 6-column DV
library(car)
id <- data.frame(cond=factor(mf$cond), type=factor(mf$type))
res <- Anova(mlm, idata=id, idesign=~cond*type, type=3)
print(summary(res, multivariate=FALSE))
