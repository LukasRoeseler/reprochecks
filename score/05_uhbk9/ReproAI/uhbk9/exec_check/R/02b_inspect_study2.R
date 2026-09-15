d <- read.csv('../../extracted/Pennycook et al._Study 2.csv', check.names=FALSE,
              na.strings='', stringsAsFactors=FALSE, fileEncoding='latin1')
cat('first col name:', dput(names(d)[1]), '\n')
## locate condition-like column
condcol <- names(d)[grep('[Cc]ondition', names(d))[1]]
cat('condition col:', condcol, '\n')
print(table(d[[condcol]], useNA='ifany'))
cat('rating ranges Fake1_1:\n'); x<-as.numeric(d[['Fake1_1']]); print(table(x, useNA='ifany'))
cat('non-missing Fake1_1..15 & Real1_1..15:\n')
print(c(sum(!is.na(d[['Fake1_1']])), sum(!is.na(d[['Real1_1']]))))
