library(haven)
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/10_Hertel"
df <- read_sav(file.path(d, "Ashley_labels.sav"))
lab <- c("nonrum"=1,"rum"=2)
# group x cond means (average over cue type = FAbaseC/FAsuppC)
cat("Group|Base%|Supp%|SuppEffect(base-supp)\n")
for (g in 1:2){
  s <- df[df$Group==g,]
  b <- mean(s$FAbaseC); su <- mean(s$FAsuppC)
  cat(g, b, su, b-su, "n=", nrow(s), "\n")
}
# direction positive = base>supp (SIF). 
cat("Group1 (nonrum) n=", sum(df$Group==1), " Group2 (rum) n=", sum(df$Group==2), " total n=", nrow(df),"\n")
