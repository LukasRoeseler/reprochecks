dir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/17_Aung_voice/models"
r <- load(file.path(dir,"m1.rda"))
cat("loaded objects:", r, "\n")
cat("class m1:", class(m1), "\n")
cat("formula:", deparse(m1$formula), "\n")
print(fixef(m1, probs=c(0.055,0.945)))
