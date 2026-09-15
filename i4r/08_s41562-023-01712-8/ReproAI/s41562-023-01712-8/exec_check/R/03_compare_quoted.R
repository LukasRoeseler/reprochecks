suppressMessages({library(dplyr)})
base <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/ReproAI/s41562-023-01712-8/exec_check"
m <- read.csv(file.path(base,"output/reanalysis_joined.csv"), stringsAsFactors=FALSE)
m$n_pooled <- as.numeric(m$n_pooled); m$k <- as.numeric(m$k)

## Paper-quoted claims: descriptor, k, N  (search for effect ids)
claims <- read.table(text = "
lit_general  38 18318
coview       12 6083
edutv_lit    13 1955
num_math     85 36793
num_vid      25 2008
ar_learn     15 1474
touch_learn  79 5810
ebook_learn  50 2288
tv_learn     18 62135
vid_learn    10 4276
gen_learn    18 13100
adv_food     13 1756
advergame    15 3842
sm_sex       14 23096
tv_sleep     10 9798
tv_body      12 3196
inet_dep    118 527696
sm_dep       12 93740
", header=FALSE, stringsAsFactors=FALSE)
names(claims) <- c("label","k","N")
claims$k <- as.integer(claims$k); claims$N <- as.integer(claims$N)

## For each claim, find effects matching k and within a tolerance on N
for (i in seq_len(nrow(claims))) {
  kk <- claims$k[i]; NN <- claims$N[i]
  cand <- m[!is.na(m$n_pooled) & !is.na(m$k) & m$k == kk &
            m$n_pooled >= NN*0.995 & m$n_pooled <= NN*1.005, ]
  if (nrow(cand) > 0) {
    cat(sprintf("== %s (k=%d N=%d):\n", claims$label[i], kk, NN))
    for (j in seq_len(nrow(cand))) {
      cat(sprintf("   %s | %s | %s | r=%.3f [%.3f, %.3f] k=%d N=%d I2=%.1f\n",
          cand$effect_size_id[j], cand$outcome[j], cand$exposure[j],
          cand$pooled_r[j], cand$cilb95[j], cand$ciub95[j],
          cand$k[j], cand$n_pooled[j], cand$i2[j]))
    }
  } else {
    cat(sprintf("== %s (k=%d N=%d): NO MATCH in reanalysis\n", claims$label[i], kk, NN))
  }
}
