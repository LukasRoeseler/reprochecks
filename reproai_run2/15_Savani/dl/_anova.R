d <- readxl::read_excel('Data_by_Subject_KS.xlsx')
d <- d[!is.na(d$numactions),]
d$culture <- as.factor(d$culture); d$cond <- as.factor(d$cond)
m <- lm(numactions ~ culture*cond, data=d)
cat('TYPE2\n'); print(car::Anova(m, type=2))
cat('TYPE3\n'); print(car::Anova(m, type=3))
cat('aov summary\n'); print(summary(aov(numactions~culture*cond, data=d)))
cat('---- simple effects t-tests (equal var) ----\n')
ind_ch <- d$numactions[d$culture==1 & d$cond==1]
ind_ct <- d$numactions[d$culture==1 & d$cond==0]
us_ch  <- d$numactions[d$culture==0 & d$cond==1]
us_ct  <- d$numactions[d$culture==0 & d$cond==0]
cat('India choice vs control:', paste(capture.output(t.test(ind_ch, ind_ct, var.equal=TRUE)), collapse='\n'), '\n')
cat('US choice vs control:', paste(capture.output(t.test(us_ch, us_ct, var.equal=TRUE)), collapse='\n'), '\n')
cat('Choice India vs US:', paste(capture.output(t.test(ind_ch, us_ch, var.equal=TRUE)), collapse='\n'), '\n')
