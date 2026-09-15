## Study 2 data inspection
d <- read.csv('../../extracted/Pennycook et al._Study 2.csv', check.names=FALSE,
              na.strings='', stringsAsFactors=FALSE, fileEncoding='latin1')
cat('nrow:', nrow(d), '\n')
cat('Condition table:\n'); print(table(d$Condition, useNA='ifany'))
cat('cols with Fake1_1 variants:\n'); print(grep('^Fake1_1', names(d), value=TRUE))
cat('has DemRep:', 'DemRep' %in% names(d), ' CRT_ACC:', 'CRT_ACC' %in% names(d), '\n')
## which columns hold ratings
cand <- names(d)[grepl('^(Fake1_|Real1_)', names(d))]
cat('rating-ish cols (first 40):\n'); print(head(cand,40))
