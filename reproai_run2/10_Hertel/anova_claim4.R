library(haven)
library(ez)
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/10_Hertel"
df <- read_sav(file.path(d, "Ashley_labels.sav"))
df$Group <- as.factor(df$Group)
df$SNO <- as.factor(df$SNO)
cat("Missing in FA cols:\n")
print(sapply(df[c("FAbaseC","FAsuppC","FAnewC")], function(x) sum(is.na(x))))

# Complete cases across base+supp
sub <- df[complete.cases(df[c("FAbaseC","FAsuppC")]),]
cat("N with both base+supp:", nrow(sub), "\n")

# Build long format with factor Type (baseline, suppress) and run mixed ANOVA
long <- data.frame(
  SNO = sub$SNO,
  Group = sub$Group,
  Type = factor(rep(c("base","supp"), each=nrow(sub))),
  FA = c(sub$FAbaseC, sub$FAsuppC)
)
res <- ezANOVA(data=long, dv=FA, wid=SNO, between=Group, within=Type, type=3, detailed=TRUE)
print(res)

# mean by group x type
print(tapply(long$FA, list(long$Group, long$Type), mean))
cat("sd:\n")
print(tapply(long$FA, list(long$Group, long$Type), sd))
print(table(long$Group))
