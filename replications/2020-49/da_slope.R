suppressMessages({library(readstata13); library(data.table)})
d <- as.data.table(read.dta13("C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/repro_pilot/downloads/osf/9mfws/data_and_code/double_auction/data/market.dta", convert.factors=FALSE))
d[, alpha_good := sqrt(mean((price-eq_price)^2))/eq_price[1], by=MarketID_period]
mp <- unique(d[, .(MarketID_period, eq_quantity, Quantity, efficiency, default, alpha_good)])
mp[, `:=`(lq = log(Quantity), leq = log(eq_quantity))]
f  <- lm(lq ~ leq, data=mp)
cat("[REG] log(Quantity) ~ log(eq_quantity):\n")
cat("  R2 =", round(summary(f)$r.squared,3), "  slope =", round(coef(f)[2],4), "\n")
aa <- mp[!is.na(alpha_good) & !is.na(efficiency) & alpha_good<=1 & efficiency>=0]
cat("\nSmith alpha vs efficiency: n =", nrow(aa), " corr =", round(cor(aa$efficiency, aa$alpha_good),3), "\n")
