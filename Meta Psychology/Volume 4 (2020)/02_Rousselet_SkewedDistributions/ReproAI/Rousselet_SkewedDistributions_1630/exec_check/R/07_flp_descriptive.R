# ReproAI :: verify FLP descriptive claims from raw data
datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"
load(file.path(datadir, "french_lexicon_project_rt_data.RData"))
cat("Object names:", ls(), "\n")
cat("flp head rows:", nrow(flp), " cols:", names(flp), "\n")
cat("N participants:", length(unique(flp$participant)), "\n")
cat("Conditions:", sort(unique(flp$condition)), "\n")
nres <- tapply(flp$rt, list(flp$participant, flp$condition), length)
cat("Trials per participant-condition (min,max):", range(nres), "\n")
cat("summary nres:\n"); print(summary(as.vector(nres)))

medres <- tapply(flp$rt, list(flp$participant, flp$condition), median)
meanres <- tapply(flp$rt, list(flp$participant, flp$condition), mean)
# non-word - word differences
diff.md <- medres[,2] - medres[,1]
diff.m  <- meanres[,2] - meanres[,1]
cat("\nProportion participants with positive (non-word>word) differences:\n")
cat("  median-based (paper 96.4%):", round(100*mean(diff.md>0),1), "%\n")
cat("  mean-based   (paper 94.8%):", round(100*mean(diff.m>0),1), "%\n")
cat("\nMAD of difference distributions (paper mean RT=57, median RT=54):\n")
cat("  mean diff MAD:", round(mad(diff.m)), " median diff MAD:", round(mad(diff.md)), "\n")

# skewness
skewfun <- function(x){ m<-mean(x); v<-var(x); m3<-sum((x-m)^3)/length(x); m3/v^1.5 }
skewres <- tapply(flp$rt, list(flp$participant, flp$condition), skewfun)
cat("\nProportion participants with larger (parametric) skewness in Word (paper 80%):\n")
cat("  ", round(100*sum((skewres[,1]-skewres[,2])>0)/nrow(skewres),1), "%\n")
cat("Proportion participants with larger non-parametric skewness (mean-median) in Word (paper 70%):\n")
cat("  ", round(100*sum(((meanres[,1]-medres[,1])-(meanres[,2]-medres[,2]))>0)/nrow(skewres),1), "%\n")

cat("\nIQR mean diff:", round(IQR(diff.m)), " IQR median diff:", round(IQR(diff.md)), "\n")
