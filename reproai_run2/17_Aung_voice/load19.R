dir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/17_Aung_voice/models"
load(file.path(dir, "m19.rda"))
cat("M19 class:", class(m19), "\n")
cat("formula:", deparse(m19$formula), "\n")
print(fixef(m19, probs=c(0.055,0.945)))
