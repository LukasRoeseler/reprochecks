## Script 06 (FIXED): Table IV probit reimplementation (homogeneous columns) — AME, cluster SE by subject
options(warn=-1)
suppressMessages(library(dplyr))
d <- read.csv("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/02_ecta8852/ReproAI/ecta8852/exec_check/output/master_behavior.csv",
              stringsAsFactors=FALSE)
d$id <- paste(d$pref,d$rule,d$nsubj,d$rev,d$comm,sep="_")
d <- d[!duplicated(d[,c("period","group","subj","id")]),]
d <- d[!(d$pref=="hom" & d$rule==7 & d$comm==1 & d$nsubj==36),]

d$red <- as.integer(d$action==1)
d$redsample <- as.integer(d$sample==1)
d$rule7 <- as.integer(d$rule==7)
d$rule9 <- as.integer(d$rule==9)
d <- d %>% arrange(id, subj, period) %>% group_by(id, subj) %>%
  mutate(pastwrongblue = lag(as.integer(groupdec==2 & jar==1), default=0)) %>% ungroup()
d <- d %>% group_by(id) %>% mutate(maxper=max(period), late=as.integer(period>=(maxper-4))) %>% ungroup()

for (cm in c(0,1)) {
  sub <- d[d$pref=="hom" & d$comm==cm,]
  fo <- red ~ redsample + pastwrongblue + rule7 + rule9 + redsample:rule7 + redsample:rule9 +
        late + late:redsample + late:rule7 + late:rule9 + late:pastwrongblue
  m <- glm(fo, data=sub, family=binomial(link="probit"))
  X <- model.matrix(m); b <- coef(m)
  ame <- numeric(ncol(X)); names(ame) <- colnames(X)
  for (k in seq_len(ncol(X))) {
    Xp <- X; Xp[,k] <- X[,k]+0.5; Xm <- X; Xm[,k] <- X[,k]-0.5
    ame[k] <- mean(pnorm(Xp %*% b) - pnorm(Xm %*% b))
  }
  cat(sprintf("\n===== hom comm=%d n=%d =====\n", cm, nrow(sub)))
  cat(" Red sample AME:", round(ame["redsample"],3), "  (paper 0.814 / 0.504)\n")
  cat(" rule7     AME:", round(ame["rule7"],3), "  (paper 0.271 / -0.426)\n")
  cat(" rule9     AME:", round(ame["rule9"],3), "  (paper 0.385 / -0.611)\n")
  cat(" redsample:rule7:", round(ame["redsample:rule7"],3), "  (paper -0.311 / -0.422)\n")
  cat(" redsample:rule9:", round(ame["redsample:rule9"],3), "  (paper -0.449 / -0.485)\n")
}
