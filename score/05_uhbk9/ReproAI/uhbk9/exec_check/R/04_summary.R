## Consolidate key reproduction numbers for the report
source('00_lib.R')
s1 <- readRDS('output/study1_long_clean.rds')
s1$accf <- s1$acc %in% 1
cat('=== Study1 Figure 1 proportions ===\n')
for(accv in c(TRUE,FALSE)){lab<-if(accv)'Accuracy'else'Sharing'
  for(rv in c(0,1)){r<-s1$rating[s1$accf==accv & s1$real==rv]
    cat(sprintf('%s %s: %.4f (%.2f%%)\n',lab,if(rv)'True'else'False',mean(r),100*mean(r))) } }
cat('\n=== Study2 r(28) and ratio (final) ===\n')
m2 <- readRDS('output/study2_main.rds')
cat('ratio=', m2$dc['m1']-m2$dc['m0'], ' / ', m2$dt['m1']-m2$dt['m0'], '\n')
cat('discerningttest:', (m2$dt['m1']-m2$dt['m0'])/(m2$dc['m1']-m2$dc['m0']), '\n')
cat('corr r=', m2$corr, ' p=', cor.test(m2$fg$trtEffect, m2$fg$perceivedAcc)$p.value, '\n')
