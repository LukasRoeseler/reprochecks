suppressMessages({library(dplyr); library(metafor); library(effectsize); library(correlation)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
st <- read.csv(file.path(base,"repo_data/Studies.csv"), stringsAsFactors=FALSE, check.names=FALSE)
names(st) <- make.names(names(st), unique=TRUE)
st$study_n <- st$Study.N
d <- st %>% filter(Effect.Size.ID == "47569_001")
cat("n rows:", nrow(d), " N sum:", sum(d$Study.N, na.rm=TRUE), "\n")
print(data.frame(author=d$Study.Author, year=d$Study.Year, metric=d$Metric, est=d$Estimate, n=d$Study.N, lo=d$Lower.CI, up=d$Upper.CI))

## replicate conversion
tt <- function(s){ s<-tolower(trimws(s)); dplyr::case_when( s %in% c("correlation","pearson's r","correlation coefficient","corrected correlation","attenuated correlation (uncorrected correlation)","weighted mean correlation coefficient","r = uncorrected sample-weighted mean effect size")~"r", TRUE~s)}
d$cm <- tt(d$Metric)
d <- d %>% mutate(study_n=ifelse(is.na(study_n), round(mean(study_n,na.rm=TRUE)), study_n))
d$r_estimate <- ifelse(d$cm=="r", d$Estimate, NA)
print(data.frame(author=d$Study.Author, r=d$r_estimate, n=d$study_n))
cat("any r NA:", sum(is.na(d$r_estimate)), " any r outside [-1,1]:", sum(!is.na(d$r_estimate) & (d$r_estimate< -1 | d$r_estimate>1)), "\n")
res <- tryCatch(rma(data=d, measure="COR", ri=r_estimate, ni=study_n), error=function(e) paste("ERR:", conditionMessage(e)))
print(res)
