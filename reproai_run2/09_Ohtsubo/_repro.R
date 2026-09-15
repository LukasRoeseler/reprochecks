suppressMessages({library(readxl)})
d <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/reprochecks/reproai_run2/09_Ohtsubo/dl_httpsosfiodownloadp9whq.bin"
data <- read_excel(d, sheet = "Sheet3", skip = 1)

# recode reversed item r4 (1->7 ... 7->1)
rec <- function(x) 8 - as.numeric(x)
data$r4rec <- rec(data$r4)
data$intimacy_scale <- (data$r1 + data$r4rec + data$r6 + data$r7)/4

# verify our constructed scale equals the Intimacy column
cat("mismatch rows (intimacy_scale vs Intimacy):", which(abs(data$intimacy_scale - data$Intimacy) > 1e-9), "\n")

# sex counts, total
cat("rows:", nrow(data), "\n")
cat("sex table:\n"); print(table(data$sex))
cat("cnd table:\n"); print(table(data$cnd))

# For each candidate exclusion, compute Student t-test + means/SDs + cohen d
candidates <- c(3, 12, 13, 22, 25)
pooled_d <- function(m1,sd1,n1,m2,sd2,n2){ sp <- sqrt(((n1-1)*sd1^2+(n2-1)*sd2^2)/(n1+n2-2)); (m1-m2)/sp }
for (ex in candidates){
  dd <- data[-ex, ]
  tt <- t.test(Intimacy ~ cnd, data = dd, var.equal = TRUE, alternative = "two.sided")
  g1 <- as.numeric(dd$Intimacy[dd$cnd==1]); g2 <- as.numeric(dd$Intimacy[dd$cnd==2])
  m1<-mean(g1); s1<-sd(g1); m2<-mean(g2); s2<-sd(g2)
  dcohen <- pooled_d(m1,s1,length(g1),m2,s2,length(g2))
  cat(sprintf("excl %2d : N=%d  t(%.0f)=%.3f  p=%.9f  d=%.3f  group1(cnd1) M=%.3f SD=%.3f n=%d  group2(cnd2) M=%.3f SD=%.3f n=%d\n",
      ex, nrow(dd), tt$parameter, tt$statistic, tt$p.value, dcohen, m1,s1,length(g1), m2,s2,length(g2)))
}

cat("\nArticle claim (Study 2a): attention M=4.58 SD=.82 (n=?); no-attention M=2.82 SD=.79; t(27)=5.91; d=2.20; N=29\n")
