suppressMessages({library(readxl); library(dplyr); library(jsonlite)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/SCORE ReproAI Checks/06_e3kcw/ReproAI/e3kcw"
src <- file.path(base, "exec_check/source/Primary_sample_data.xlsx")
out <- file.path(base, "exec_check/output/01_explore")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
con <- file(file.path(out, "console.log"), open = "wt")
sink(con); sink(con, type = "message")
cat("==== START 01_explore.R (status: RUN) ====\n")
d <- read_excel(src, sheet = "data")
cat("N =", nrow(d), " ncol =", ncol(d), "\n\n")
cat("== Summary of all numeric columns ==\n")
d <- as.data.frame(d)
numcols <- c("sex","age","edu","region","ifsibling","income","depress","anx","posemo","negemo",
             "worry1","worry2","worry3","quarantine","mindful","flow","lonely1","lonely2","lonely3",
             "healthbeh1","healthbeh2","healthbeh3","healthbeh4","healthbeh5","healthbeh6",
             "opt","iu","swls","sleep","daysbeforemar","wave")
for (cc in numcols) {
  v <- d[[cc]]
  if (is.numeric(v) || is.integer(v)) {
    cat(sprintf("%-14s n=%d min=%.4f max=%.4f mean=%.4f sd=%.4f NA=%d\n", cc,
        length(v), min(v,na.rm=TRUE), max(v,na.rm=TRUE), mean(v,na.rm=TRUE), sd(v,na.rm=TRUE), sum(is.na(v))))
  } else {
    cat(sprintf("%-14s NON-NUMERIC n=%d NA=%d\n", cc, length(v), sum(is.na(v))))
  }
}
cat("\n== quarantine frequency ==\n")
print(table(d$quarantine, useNA="ifany"))
cat("\n== sex freq ==\n"); print(table(d$sex, useNA="ifany"))
cat("\n== wave freq ==\n"); print(table(d$wave, useNA="ifany"))
cat("\n== sample means/SDs (manuscript targets) ==\n")
targets <- list(
  flow_M=c(4.37), flow_SD=c(1.13), mindful_M=2.50, mindful_SD=.47,
  worry_M=-.0003, worry_SD=.85, posemo_M=3.69, posemo_SD=.79,
  negemo_M=1.93, negemo_SD=.63, depress_M=.57, depress_SD=.61,
  anx_M=.59, anx_SD=.67, lonely_M=1.37, lonely_SD=.50,
  healthy_M=4.09, healthy_SD=1.45, unhealthy_M=1.77, unhealthy_SD=.92,
  opt_M=3.80, opt_SD=.66, iu_M=2.22, iu_SD=.66, swls_M=3.98, swls_SD=1.14
)
cat("\n|--- derived scale descriptives (raw, full N) ---|\n")
cat(sprintf("flow          mean=%.4f sd=%.4f\n", mean(d$flow,na.rm=T), sd(d$flow,na.rm=T)))
cat(sprintf("mindful       mean=%.4f sd=%.4f\n", mean(d$mindful,na.rm=T), sd(d$mindful,na.rm=T)))
healthy <- d$healthbeh1+d$healthbeh2+d$healthbeh3
unhealthy <- d$healthbeh4+d$healthbeh5+d$healthbeh6
cat(sprintf("healthy(sum)  mean=%.4f sd=%.4f\n", mean(healthy,na.rm=T), sd(healthy,na.rm=T)))
cat(sprintf("unhealthy(sum) mean=%.4f sd=%.4f\n", mean(unhealthy,na.rm=T), sd(unhealthy,na.rm=T)))
cat(sprintf("lonely(avg3)  mean=%.4f sd=%.4f\n", mean(rowMeans(d[,c('lonely1','lonely2','lonely3')],na.rm=T),na.rm=T),
    apply(d[,c('lonely1','lonely2','lonely3')],1,function(r) sd(r,na.rm=T)) |> mean(na.rm=T)))
cat("\n== flow x mindful correlation ==\n")
cat("r =", cor(d$flow, d$mindful, use="complete.obs"), "\n")
saveRDS(d, file.path(out, "data_raw.rds"))
sink(type="message"); sink()
close(con)
cat("done\n")
