library(survey)
d <- read.csv("d.csv", stringsAsFactors=FALSE)

# svy models with pweight = 'weight'; design without explicit PSU/strata (id=~1)
for (design in c("none","psuid")) {
  cat("\n================ DESIGN:", design, "===============\n")
  if (design=="none") {
    svyd <- svydesign(id=~1, weights=~weight, data=d)
  } else {
    svyd <- svydesign(id=~ccap_id, weights=~weight, data=d)
  }
  cat("\n-- MODEL2 svy: swensenfav ~ innuendo+denial+causal --\n")
  m2 <- svyglm(swensenfav ~ innuendo+denial+causal, design=svyd)
  b <- coef(m2); s <- SE(m2)
  cat(sprintf("denial coef=%.3f se=%.3f\n", b['denial'], s['denial']))
  d_causal_inn <- b['causal']-b['innuendo']
  se_causal_inn <- sqrt(s['causal']^2+s['innuendo']^2-2*vcov(m2)['causal','innuendo'])
  t <- d_causal_inn/se_causal_inn; p <- 2*(1-pt(abs(t), df=df.residual(m2)))
  cat(sprintf("causal-innuendo diff=%.3f se=%.3f p=%.4f\n", d_causal_inn, se_causal_inn, p))

  cat("\n-- MODEL4 svy: acceptedbribes ~ innuendo+denial+causal --\n")
  m4 <- svyglm(acceptedbribes ~ innuendo+denial+causal, design=svyd)
  b <- coef(m4); s <- SE(m4)
  d_cd <- b['causal']-b['denial']
  se_cd <- sqrt(s['causal']^2+s['denial']^2-2*vcov(m4)['causal','denial'])
  t <- d_cd/se_cd; p <- 2*(1-pt(abs(t), df=df.residual(m4)))
  cat(sprintf("causal-denial diff=%.3f se=%.3f p=%.4f\n", d_cd, se_cd, p))

  cat("\n-- MODEL6 svy: resigninvest ~ denial+causal --\n")
  m6 <- svyglm(resigninvest ~ denial+causal, design=svyd)
  b <- coef(m6); s <- SE(m6)
  d_cd <- b['causal']-b['denial']
  se_cd <- sqrt(s['causal']^2+s['denial']^2-2*vcov(m6)['causal','denial'])
  t <- d_cd/se_cd; p <- 2*(1-pt(abs(t), df=df.residual(m6)))
  cat(sprintf("causal-denial diff=%.3f se=%.3f p=%.4f\n", d_cd, se_cd, p))
}
