suppressMessages(library(haven))
d<-"C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/9mfws/data_and_code"
m<-read_dta(file.path(d,"double_auction","data","market.dta"))
cat("dims",dim(m)," cols:",paste(names(m),collapse=", "),"\n")
# price lag & change autocorrelation (market_good_trades.do)
m<-m[!is.na(m$transactionid),]
m<-m[order(m$SessionID,m$MarketID_period,m$transactionid),]
# price_change_lag presumably constructed in do; replicate: diff within session-period
library(dplyr)
m<-m %>% group_by(SessionID,MarketID_period) %>% mutate(price_change=price-dplyr::lag(price),price_change_lag=dplyr::lag(price_change))
s<-m[!is.na(m$price_change)&!is.na(m$price_change_lag),]
cat("\npwcorr price_change price_change_lag:\n"); print(cor.test(s$price_change,s$price_change_lag))
