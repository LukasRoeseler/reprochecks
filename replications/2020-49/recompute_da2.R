suppressMessages({library(readstata13); library(data.table)})
cat("=== DOUBLE AUCTION RECOMPUTATION ===\n")
t <- proc.time()
d <- as.data.table(read.dta13("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/9mfws/data_and_code/double_auction/data/market.dta", convert.factors=FALSE))
cat("rows:", nrow(d), " time:", round((proc.time()-t)[3],1), "s\n")

# Smith's alpha per market-period from transaction prices
d[, alpha_good := sqrt(mean((price - eq_price)^2))/eq_price[1], by=MarketID_period]

mp <- unique(d[, .(MarketID_period, eq_quantity, Quantity, efficiency, period, default, alpha_good)])
cat("\nDistinct market-period rows:", nrow(mp), "\n")
cat("Efficiency: mean=", round(mean(mp$efficiency, na.rm=TRUE),3),
    " median=", round(median(mp$efficiency, na.rm=TRUE),3),
    " sd=", round(sd(mp$efficiency, na.rm=TRUE),3), "\n")
cat("Efficiency (default==1): mean=", round(mean(mp$efficiency[mp$default==1], na.rm=TRUE),3),
    " median=", round(median(mp$efficiency[mp$default==1], na.rm=TRUE),3),
    " n=", sum(mp$default==1, na.rm=TRUE), "\n")

# Quantity regression
mp[, `:=`(log.quantity=log(Quantity), log.eq.q=log(eq_quantity))]
fit <- lm(log.eq.q ~ log.quantity, data=mp)
cat("\n[REG] log(eq_quantity) ~ log(Quantity):\n")
cat("  R2 =", round(summary(fit)$r.squared,3), "\n")
cat("  slope =", round(coef(fit)[2],4), "\n  n =", nrow(mp), "\n")

# Smith's alpha vs efficiency
aa <- mp[alpha_good<=1 & efficiency>=0]
cc <- cor(aa$efficiency, aa$alpha_good, use="complete.obs")
cat("\nCorr(efficiency, Smith alpha) =", round(cc,3), "  n=", nrow(aa), "\n")

# Price autocorrelation
d[, `:=`(price.lag=shift(price,n=1), eq=eq_price), by=MarketID_period]
d[, `:=`(pc=(price-price.lag)/eq)]
d[, pc.lag := shift(pc,n=1)]
dd <- d[!is.na(pc) & !is.na(pc.lag)]
dd <- dd[abs(pc)<=4 & abs(pc.lag)<=4]
fit2 <- lm(pc ~ pc.lag, data=dd)
cat("\n[REG] price.change ~ lag(price.change):\n")
cat("  corr rho =", round(cor(dd$pc, dd$pc.lag),3), "\n")
cat("  R2 =", round(summary(fit2)$r.squared,3), "\n")
cat("  slope =", round(coef(fit2)[2],4), "\n  n =", nrow(dd), "\n")
