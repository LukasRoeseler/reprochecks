options(error = function() {
  cat("CAUGHT_ERROR:", geterrmessage(), "\n")
  traceback(3)
  q(status = 5)
})
source("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/03_Brunner_PowerHeterogeneity/ReproAI/Brunner_PowerHeterogeneity_874/exec_check/verify_study1_zcurve.R")
