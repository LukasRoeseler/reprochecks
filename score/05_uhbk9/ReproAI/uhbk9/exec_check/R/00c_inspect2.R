d <- read.csv('../../extracted/Pennycook et al._Study 1.csv',
              check.names = FALSE, na.strings = '', stringsAsFactors = FALSE,
              fileEncoding = 'latin1')
cand <- c('Fake1_1','Fake1_1.0','Fake1_1.1','Fake1_1.2')
ok <- function(x) x %in% c('0','1')
nreal <- rowSums(sapply(cand, function(c) as.numeric(ok(d[[c]]))))
cat('per-subject #real across 4 candidates:\n'); print(table(nreal))
one <- which(nreal == 1)
cat('subjects with exactly one real:', length(one), '\n')
for (i in head(one, 20)) {
  cat('row', i, 'cond=', d$Condition[i], ' ')
  for (c in cand) cat(c, '=', d[[c]][i], ' ')
  cat('\n')
}
cat('Condition distribution among nreal==1:\n'); print(table(d$Condition[one]))
cat('Acc among nreal==1:\n'); print(table(d$Acc[one]))
