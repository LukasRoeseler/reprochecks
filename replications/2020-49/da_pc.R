suppressMessages({library(readstata13); library(data.table)})
d <- as.data.table(read.dta13("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/9mfws/data_and_code/double_auction/data/market.dta", convert.factors=FALSE))
d[, `:=`(price.lag = shift(price, n=1)), by=MarketID_period]
d[, pc := (price - price.lag)/eq_price]
d[, pc.lag := shift(pc, n=1)]
dd <- d[!is.na(pc) & !is.na(pc.lag) & abs(pc)<=4 & abs(pc.lag)<=4]
f <- lm(pc ~ pc.lag, data=dd)
cat("[REG] price.change ~ lag price.change (|.|<=4)\n")
cat("  corr =", round(cor(dd$pc, dd$pc.lag),4), "\n")
cat("  R2 =", round(summary(f)$r.squared,4), "  slope =", round(coef(f)[2],4), "  n =", nrow(dd), "\n")

# alpha diagnostic
d[, alpha_good := sqrt(mean((price - eq_price)^2))/eq_price[1], by=MarketID_period]
mp <- unique(d[, .(MarketID_period, efficiency, alpha_good, period)])
cat("\nalpha_good non-NA:", sum(!is.na(mp$alpha_good)), " of", nrow(mp), "\n")
cat("efficiency non-NA:", sum(!is.na(mp$efficiency)), "\n")
cat("efficiency range:", paste(range(mp$efficiency, na.rm=TRUE), collapse=" "), "\n")
