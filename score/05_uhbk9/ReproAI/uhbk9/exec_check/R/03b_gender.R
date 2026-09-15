d1 <- read.csv('../../extracted/Pennycook et al._Study 1.csv', check.names=FALSE, na.strings='', stringsAsFactors=FALSE, fileEncoding='latin1')
cat('Study1 gender col values:\n'); print(table(d1$gender, useNA='ifany'))
cat('Study1 Gender.0 col values:\n'); print(table(d1$Gender.0, useNA='ifany'))
cat('Study1 age values 1..5? age table unique:\n'); print(table(d1$age, useNA='ifany'))
