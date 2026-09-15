library(haven)
library(ez)
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/10_Hertel"
df <- read_sav(file.path(d, "Ashley_labels.sav"))
df$Group <- as.factor(df$Group)
df$CB <- as.factor(df$CB)
df$SNO <- as.factor(df$SNO)
cat("CB table:\n"); print(table(df$CB))
cat("Group x CB:\n"); print(table(df$Group, df$CB))

long <- data.frame(
  SNO = df$SNO, Group=df$Group, CB=df$CB,
  Type = factor(rep(c("base","supp"), each=nrow(df))),
  FA = c(df$FAbaseC, df$FAsuppC)
)
res <- ezANOVA(data=long, dv=FA, wid=SNO, between=.(Group,CB), within=Type, type=3, detailed=TRUE)
print(res)
