suppressMessages({library(readstata13); library(dplyr)})
cat("=== ULTIMATUM GAME RECOMPUTATION (corrected) ===\n")
d <- read.dta13("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/9mfws/data_and_code/ultimatum_game/data/ultimatum.dta")
d$one_shot <- (d$Total_played_rounds==1) + 0
prop <- d[d$player==0, ]
resp <- d[d$player==1, ]

# Acceptance rate computed on PROPOSER rows using paired responder decision
cat("\n--- ACCEPTANCE RATE BY PROPOSER OFFER (one-shot) ---\n")
os <- prop[prop$one_shot==1, ]
agg <- os %>% group_by(decision_first_scale) %>%
  summarise(acc=mean(decision_face_first, na.rm=TRUE), n=n())
print(as.data.frame(agg %>% filter(decision_first_scale %in% c(20,30,40,45,48,49,50,51,55,60))))

cat("\n--- ACCEPTANCE JUMP AT 50 (one-shot) ---\n")
for (o in c(48,49,50)) {
  cat("offer",o,": acc=",mean(os$decision_face_first[os$decision_first_scale==o],na.rm=TRUE),
      "  n=",sum(os$decision_first_scale==o,na.rm=TRUE),"\n")
}

cat("\n--- ACCEPTANCE JUMP AT 50 (all offers) ---\n")
for (o in c(49,50)) {
  cat("offer",o,": acc=",mean(prop$decision_face_first[prop$decision_first_scale==o],na.rm=TRUE),
      " n=",sum(prop$decision_first_scale==o,na.rm=TRUE),"\n")
}

# Responder RT with Tukey-fence trimming (one-shot)
cat("\n--- ONE-SHOT RESPONDER RT (raw and trimmed) ---\n")
osr <- resp[resp$one_shot==1,]
bs <- boxplot.stats(osr$decisiontime)
fence <- bs$stats[4] + 3*(bs$stats[4]-bs$stats[2])
cat("Tukey far-out fence:", fence, "\n")
osr_t <- osr[osr$decisiontime<=fence,]
cat("Raw   : offer49 RT=", mean(osr$decisiontime[osr$offer_face_scale==49],na.rm=TRUE),
    " offer50 RT=", mean(osr$decisiontime[osr$offer_face_scale==50],na.rm=TRUE), "\n")
cat("Trimmed: offer49 RT=", mean(osr_t$decisiontime[osr_t$offer_face_scale==49],na.rm=TRUE),
    " (n=",sum(osr_t$offer_face_scale==49,na.rm=TRUE),
    ") offer50 RT=", mean(osr_t$decisiontime[osr_t$offer_face_scale==50],na.rm=TRUE),
    " (n=",sum(osr_t$offer_face_scale==50,na.rm=TRUE),")\n")

# Overall trimmed responder RT stats
rsp_t <- resp[resp$decisiontime<=fence,]
cat("\nTrimmed all-responder RT: n=",sum(!is.na(rsp_t$decisiontime)),
    " mean=",mean(rsp_t$decisiontime,na.rm=TRUE),
    " q50=",quantile(rsp_t$decisiontime,0.5,na.rm=TRUE),
    " q75=",quantile(rsp_t$decisiontime,0.75,na.rm=TRUE),"\n")
