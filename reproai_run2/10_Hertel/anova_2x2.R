library(haven)
library(ez)
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/10_Hertel"
df <- read_sav(file.path(d, "Ashley_labels.sav"))
df$Group <- as.factor(df$Group); df$CB <- as.factor(df$CB); df$SNO <- as.factor(df$SNO)

# 2x2 within: cond(base,supp) x ctype(H,NH). 4 cells: FAHbase,FAHsupp,FANHbase,FANHsupp
long <- data.frame(
  SNO=rep(df$SNO,4),
  Group=rep(df$Group,4), CB=rep(df$CB,4),
  cond=factor(rep(c("base","base","supp","supp"), each=nrow(df)), levels=c("base","supp")),
  ctype=factor(rep(c("H","NH","H","NH"), each=nrow(df))),
  val=c(df$FAHbaseC, df$FANHbaseC, df$FAHsuppC, df$FANHsuppC)
)
res <- ezANOVA(data=long, dv=val, wid=SNO, between=.(Group,CB), within=.(cond,ctype), type=3, detailed=TRUE)
print(res$ANOVA)
