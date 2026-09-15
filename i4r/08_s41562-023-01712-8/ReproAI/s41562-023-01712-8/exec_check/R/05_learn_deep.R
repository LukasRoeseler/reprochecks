suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
m <- read.csv(file.path(base,"output/reanalysis_joined.csv"), stringsAsFactors=FALSE)
m$n_pooled <- as.numeric(m$n_pooled); m$k <- as.numeric(m$k)

## Look for effects matching the quoted learning claims by exposure/outcome across ALL effects (incl no study data)
eff <- read.csv(file.path(base,"repo_data/Effects.csv"), stringsAsFactors=FALSE, check.names=FALSE)
names(eff) <- make.names(names(eff), unique=TRUE)
eff <- eff %>% rename(effect_size_id=Effect.Size.ID, exposure=Plain.Language...Exposure,
                      outcome=Outcome.Plain.Language.Descriptor, cat=Outcome.Level.1,
                      n_comb=Combined.N, k_orig=k..number.of.effects.informing.this.test.,
                      value=Value)
## Candidates for the 3 quoted learning effects
cat("== Effects.csv rows: Learning:General with Screen use: General / TV / Video, value negative ~0.1\n")
cand <- eff %>% filter(outcome %in% c("Learning: General"), grepl("Screen use: General|TV programs|Video games: General", exposure))
cand <- cand %>% mutate(vr=round(value,2), n_comb=as.numeric(n_comb), k_orig=as.numeric(k_orig))
print(cand[, c("effect_size_id","exposure","value","n_comb","k_orig","cat")])

## Check study-data availability in Studies.csv for these ids
st <- read.csv(file.path(base,"repo_data/Studies.csv"), stringsAsFactors=FALSE, check.names=FALSE)
names(st) <- make.names(names(st), unique=TRUE)
sid <- st %>% group_by(Effect.Size.ID) %>% summarise(rows=n())
cat("\nRows in reanalysis with ok=FALSE:\n")
print(table(m$ok[!is.na(m$ok)]))
cat("\nStudy-data coverage for the learning candidate ids:\n")
for (id in cand$effect_size_id) {
  cat(id, "study rows:", sum(st$Effect.Size.ID==id), "\n")
}
