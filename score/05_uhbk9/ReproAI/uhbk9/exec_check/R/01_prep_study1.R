## Verify version-selection mapping and build clean long data for Study 1
d <- read.csv('../../extracted/Pennycook et al._Study 1.csv',
              check.names = FALSE, na.strings = '', stringsAsFactors = FALSE,
              fileEncoding = 'latin1')
ok <- function(x) x %in% c('0','1')
cond2ver <- c('1'='', '2'='.0', '3'='.1', '4'='.2')
nsubj <- nrow(d)
fakeMat <- matrix(NA, nsubj, 15)
realMat <- matrix(NA, nsubj, 15)
verUsed <- character(0)
for (i in 1:nsubj) {
  v <- cond2ver[as.character(d$Condition[i])]
  for (j in 1:15) {
    f <- d[[paste0('Fake1_', j, v)]][i]
    r <- d[[paste0('Real1_', j, v)]][i]
    fakeMat[i,j] <- if (ok(f)) as.numeric(f) else NA
    realMat[i,j] <- if (ok(r)) as.numeric(r) else NA
  }
}
cat('non-NA fake cells:', sum(!is.na(fakeMat)), ' of', nsubj*15, '\n')
cat('non-NA real cells:', sum(!is.na(realMat)), ' of', nsubj*15, '\n')
cat('rows with all 30 ratings:', sum(rowSums(!is.na(cbind(fakeMat,realMat)))==30), '\n')
## build long
long <- data.frame(
  id      = rep(1:nsubj, each = 30),
  item_num= rep(c(1:15, 16:30), times = nsubj),
  real    = rep(c(rep(0,15), rep(1,15)), times = nsubj),
  rating  = as.numeric(t(cbind(fakeMat, realMat)))
)
subj <- data.frame(id=1:nsubj, condition=d$Condition, acc=d$Acc,
                   demrep=as.numeric(d$DemRep) - 1, crt=as.numeric(d$CRT_ACC),
                   sk=as.numeric(d$SciKnow), mms=as.numeric(d$MMS),
                   concern=as.numeric(d$COVID_concern_1), news=as.numeric(d$COVID_news),
                   mind10=as.numeric(d$min_dist_10), mind50=as.numeric(d$min_dist_50))
long <- merge(long, subj, by='id'); long <- long[order(long$id, long$item_num),]
cat('long rows:', nrow(long), ' non-missing rating:', sum(!is.na(long$rating)), '\n')
## accuracy condition = acc==1 ; sharing = otherwise (Acc NA => sharing = 1)
long$sharing <- as.numeric(!(long$acc %in% 1))
long$accf <- long$acc %in% 1
cat('accuracy-subject-rows:', sum(long$accf), ' sharing-subject-rows:', sum(long$sharing), '\n')
cat('unique acc values:', paste(unique(as.character(long$acc)), collapse=','), '\n')
saveRDS(long, 'output/study1_long_clean.rds')
cat('saved study1_long_clean.rds\n')
