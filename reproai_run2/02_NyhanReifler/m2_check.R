library(survey)
d <- read.csv("d.csv", stringsAsFactors=FALSE)
svyd <- svydesign(id=~1, weights=~weight, data=d)
m2 <- svyglm(swensenfav ~ innuendo+denial+causal, design=svyd)
s <- summary(m2)$coefficients
cat("MODEL2 svy swensenfav full:\n")
print(round(s,4))
m1 <- svyglm(swensenfav ~ innuendo+denial+causal, design=svyd)
cat("\nMODEL2 denial p-value (t):", 2*(1-pt(abs(s['denial','t value']), df=summary(m2)$df.residual[1])), "\n")
