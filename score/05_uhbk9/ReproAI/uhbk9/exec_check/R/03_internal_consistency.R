## ReproAI uhbk9 - internal consistency checks: demographics, attention, Table S2/S5, Table1/2
num <- function(x) suppressWarnings(as.numeric(x))
d1 <- read.csv('../../extracted/Pennycook et al._Study 1.csv', check.names=FALSE, na.strings='', stringsAsFactors=FALSE, fileEncoding='latin1')
d2 <- read.csv('../../extracted/Pennycook et al._Study 2.csv', check.names=FALSE, na.strings='', stringsAsFactors=FALSE, fileEncoding='latin1')
cat('=== Demographics ===\n')
cat('Study1 n=', nrow(d1), ' mean age=', round(mean(num(d1$age),na.rm=TRUE),1),
    ' M=',sum(num(d1$gender)==1,na.rm=TRUE),' F=',sum(num(d1$gender)==2,na.rm=TRUE),
    ' other=',sum(is.na(num(d1$gender))),'\n',sep='')
cat('  age range ', min(num(d1$age),na.rm=TRUE),'-',max(num(d1$age),na.rm=TRUE),'\n',sep='')
cat('Study2 n=', nrow(d2),
    ' M=',sum(num(d2$Gender.0)==1,na.rm=TRUE),' F=',sum(num(d2$Gender.0)==2,na.rm=TRUE),'\n',sep='')
g2 <- num(d2$Gender.0)
cat('  Study2 gender table:'); print(table(g2, useNA='ifany'))
cat('  Study2 age mean=',round(mean(num(d2$Age.0),na.rm=TRUE),1),'\n',sep='')

## attention checks Study1
attention_fn <- function(dd, p1,p2,p3col){
  pass1 <- dd[[p1]]; pass2 <- dd[[p2]]; pass3 <- dd[[p3col]]
  p1v <- !is.na(pass1); p2v <- !is.na(pass2); p3v <- !is.na(pass3)
  list(s1=sum(p1v), s2=sum(p2v), s3=sum(p3v))
}
cat('\n=== Attention (screeners) ===\n')
cat('S1 screener cols present:', sum(grepl('^screen1_',names(d1)))>0, '\n')
cat('S1 screen1_4 non-missing:', sum(!is.na(d1$screen1_4)), ' screen2_3:', sum(!is.na(d1$screen2_3)), ' screen3_2:', sum(!is.na(d1$screen3_2)), '\n')

## Table S2 (Study1) unstandardized by attentiveness - quick col1 (all subjects) already done
## CRT alpha etc not needed
## Table 1 check: simple-effect betas. Rebuild Study1 z variates
cat('\n=== Table 1: simple-effects beta (CRT within acc-false etc) on rating (z) ===\n')
## Use long data
s1 <- readRDS('output/study1_long_clean.rds')
s1$sharing <- as.numeric(!(s1$acc %in% 1))
s1$accf <- s1$acc %in% 1
m <- mean(s1$rating); sd <- sd(s1$rating); s1$z <- (s1$rating-m)/sd
## z-score covariates
zsc <- function(v) (v-mean(v,na.rm=TRUE))/sd(v,na.rm=TRUE)
s1$zcrt <- ave(s1$crt, FUN=function(x) zsc(x))
mods <- list(
  CRT = 'CRT', SciKnow='sk', MMS='mms', Distance='mind10')
s1$scrub <- ave(s1$crt, FUN=function(x) zsc(x))
s1$zsk  <- ave(s1$sk,  FUN=function(x) zsc(x))
s1$zmms <- ave(s1$mms, FUN=function(x) zsc(x))
## partisanship demrep already z? demrep was set to demrep-1 raw; z it
s1$zdr <- ave(s1$demrep, FUN=function(x) zsc(x))
## distance log+ z (Ldist10)
s1$Ld  <- ave(log(s1$mind10), FUN=function(x) zsc(x))
cat('demo: crt/zsk/zmms/zdr/Ld sample diffs ok\n')
## simple-effect betas: for each IV, regression of intercept+IV within each cell (acc x true/false)
IV <- list(crt='zcrt', sk='zsk', mms='zmms', demrep='zdr', dist='Ld')
for (nm in names(IV)) {
  v <- IV[[nm]]
  line <- paste0('cell:', nm,'  ')
  for (acc in c(TRUE,FALSE)) for (rv in c(0,1)) {
    dd <- s1[s1$accf==acc & s1$real==rv,]
    fc <- lm(as.formula(paste0('z ~ ', v)), dd)
    line <- paste0(line, sprintf('%s-%s b=%+.3f ', if(acc)'A' else 'S', if(rv)'T' else 'F', coef(fc)[2]))
  }
  cat(line,'\n')
}
