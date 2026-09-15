## ReproAI audit — Goeree & Yariv (2011) ECTA8852
## Script 01: load master behavior data, session/sample inventory, payoffs
## Reimplementation language: R 4.6.1
options(warn=-1)
suppressMessages(library(dplyr))

d <- read.csv("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/02_ecta8852/ReproAI/ecta8852/exec_check/output/master_behavior.csv",
              stringsAsFactors=FALSE)

## ---- 1. Session inventory ----
# a session = base label (pref, rule, nsubj, order) independent of chat/nochat
d$base <- paste(d$pref, d$rule, d$nsubj, d$rev, sep="_")
sess <- d %>% group_by(base, pref, rule, nsubj, rev) %>%
  summarise(has_chat = any(comm==1), has_nochat = any(comm==0), .groups="drop")
cat("=== Session/subject inventory ===\n")
print(sess %>% select(pref,rule,nsubj,rev,has_chat,has_nochat) %>% as.data.frame())
cat("\nDistinct sessions:", nrow(sess), "\n")
cat("SUM of session Ns (subjects, each session counted once):",
    sum(sess$nsubj), "\n")

cat("\nBy preference:\n")
print(sess %>% group_by(pref) %>% summarise(subjects=sum(nsubj), sessions=n()))

## ---- 2. Period counts per session (chat / nochat segments) ----
cat("\nPeriods per comm segment (max period observed per base x comm):\n")
per <- d %>% group_by(base, comm) %>% summarise(nper=max(period), ndec=n(), .groups="drop")
print(as.data.frame(per))

## ---- 3. Payoffs  ----
# payoff per subject per treatment segment (cents); then average across subjects
pay <- d %>% group_by(comm, subj, base) %>% summarise(earn=sum(payoff), .groups="drop")
pay_avg <- pay %>% group_by(comm) %>% summarise(mean_cents=mean(earn), sd=sd(earn), n=n())
cat("\n=== Average payoff per subject per segment (cents) ===\n")
print(pay_avg)
cat("\nIn dollars: ", sprintf("%.2f", pay_avg$mean_cents/100), "\n")
cat("Paper: no-chat $9.53, chat $13.11\n")
