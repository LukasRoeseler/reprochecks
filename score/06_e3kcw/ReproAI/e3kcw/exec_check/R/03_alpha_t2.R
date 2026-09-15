suppressMessages({library(dplyr); library(psych); library(jsonlite)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/06_e3kcw/ReproAI/e3kcw"
d <- readRDS(file.path(base,"exec_check/output/01_explore/data_raw.rds"))
out <- file.path(base,"exec_check/output/03_alpha_t2")
dir.create(out, showWarnings=FALSE, recursive=TRUE)
con <- file(file.path(out,"console.log"), open="wt")
sink(con); sink(con, type="message")
cat("==== START 03_alpha_t2.R ====\n")

# ---- Cronbach's alpha for scales with item-level data ----
alpha_r <- function(items){
  a <- psych::alpha(as.data.frame(items), check.keys=TRUE)
  c(raw=a$total$raw_alpha, std=a$total$std.alpha)
}
cat("== Cronbach's alpha (items available) ==\n")
w <- alpha_r(d[,c("worry1","worry2","worry3")]); cat(sprintf("worry (3 items): raw=%.3f std=%.3f  [manuscript alpha=.81]\n", w[1], w[2]))
l <- alpha_r(d[,c("lonely1","lonely2","lonely3")]); cat(sprintf("lonely (3 items): raw=%.3f std=%.3f [manuscript alpha=.78]\n", l[1], l[2]))
hp <- alpha_r(d[,c("healthbeh1","healthbeh2","healthbeh3")]); cat(sprintf("healthy beh (3): raw=%.3f std=%.3f [manuscript alpha=.65]\n", hp[1], hp[2]))
hu <- alpha_r(d[,c("healthbeh4","healthbeh5","healthbeh6")]); cat(sprintf("unhealthy beh(3): raw=%.3f std=%.3f [manuscript alpha=.48]\n", hu[1], hu[2]))

# worry descriptives (standardized then averaged)
wz <- cbind(scale(d$worry1), scale(d$worry2), scale(d$worry3))
wr <- rowMeans(wz, na.rm=TRUE)
cat(sprintf("\nworry avg: mean=%.4f sd=%.4f [manuscript M=-.0003 SD=.85]\n", mean(wr), sd(wr)))

# ---- sex composition ----
cat(sprintf("\nsex: 1=%d (%.1f%%), 2=%d (%.1f%%) [manuscript claims 73%% female; PDF footnote 1=male 2=female]\n",
    sum(d$sex==1), 100*mean(d$sex==1), sum(d$sex==2), 100*mean(d$sex==2)))

# ---- mindfulness descriptives (raw total -> avg) ----
cat(sprintf("mindful: sum mean=%.4f sd=%.4f -> avg=%.4f sd=%.4f [manuscript M=2.50 SD=.47]\n",
    mean(d$mindful), sd(d$mindful), mean(d$mindful)/12, sd(d$mindful)/12))

# ---- age summary (manuscript M=21.36 SD=4.49) ----
cat(sprintf("age: mean=%.4f sd=%.4f n(noNA)=%d [manuscript M=21.36 SD=4.49]\n",
    mean(d$age,na.rm=TRUE), sd(d$age,na.rm=TRUE), sum(!is.na(d$age))))

# ---- Table 2 simple slopes from fully-standardized model (log quarantine, drop age NA) ----
dd <- d[!is.na(d$age),]
dff <- function(v) v - mean(v)
flow_c <- dff(dd$flow/5); mind_c <- dff(dd$mindful/12); q_c <- dff(log10(dd$quarantine))
fxq <- flow_c*q_c; mxq <- mind_c*q_c
df <- data.frame(flow_c,mind_c,q_c,fxq,mxq,sex=dd$sex,age=dd$age,edu=dd$edu,
                 ifsibling=dd$ifsibling,income=dd$income,opt=dd$opt,iu=dd$iu,swls=dd$swls)
for (j in 1:5) df[[j]] <- scale(df[[j]])[,1]
for (j in 6:13) df[[j]] <- as.numeric(scale(df[[j]]))
outcomes <- c(worry="worry_avg",negemo="negemo_avg",posemo="posemo_avg",depress="depress_avg",
              anx="anx_avg",lonely="lonely_avg",healthy="healthy_avg",unhealthy="unhealthy_avg")
d$worry_avg <- rowMeans(cbind(scale(d$worry1),scale(d$worry2),scale(d$worry3)),na.rm=TRUE)
d$lonely_avg <- (d$lonely1+d$lonely2+d$lonely3)/3
d$healthy_avg <- (d$healthbeh1+d$healthbeh2+d$healthbeh3)/3
d$unhealthy_avg <- (d$healthbeh4+d$healthbeh5+d$healthbeh6)/3
d$posemo_avg <- d$posemo/6; d$negemo_avg <- d$negemo/6; d$depress_avg <- d$depress/6; d$anx_avg <- d$anx/6

t2_pdf <- list(minus=list(worry=.14,negemo=.11,posemo=NA,depress=.16,anx=.12,lonely=.18,healthy=NA,unhealthy=.12),
               plus=list(worry=.06,negemo=.007,posemo=NA,depress=.02,anx=.01,lonely=.07,healthy=NA,unhealthy=.05))
cat("\n== Table 2 simple slopes recomputation (at -1SD / +1SD flow) ==\n")
dd$worry_avg <- rowMeans(cbind(scale(dd$worry1),scale(dd$worry2),scale(dd$worry3)),na.rm=TRUE)
dd$lonely_avg <- (dd$lonely1+dd$lonely2+dd$lonely3)/3
dd$healthy_avg <- (dd$healthbeh1+dd$healthbeh2+dd$healthbeh3)/3
dd$unhealthy_avg <- (dd$healthbeh4+dd$healthbeh5+dd$healthbeh6)/3
dd$posemo_avg <- dd$posemo/6; dd$negemo_avg <- dd$negemo/6; dd$depress_avg <- dd$depress/6; dd$anx_avg <- dd$anx/6
for (nm in c("worry","negemo","depress","anx","lonely","unhealthy")){
  y <- scale(dd[[outcomes[[nm]]]])[,1]
  m <- lm(y ~ flow_c+mind_c+q_c+fxq+mxq+sex+age+edu+ifsibling+income+opt+iu+swls, data=df)
  bq <- coef(m)["q_c"]; bfxq <- coef(m)["fxq"]
  minus <- bq - bfxq; plus <- bq + bfxq
  cat(sprintf("%-12s -1SD=%.3f (pdf %.2f)  +1SD=%.3f (pdf %.2f)\n", nm, minus, t2_pdf$minus[[nm]], plus, t2_pdf$plus[[nm]]))
}
sink(type="message"); sink(); close(con)
cat("done\n")
