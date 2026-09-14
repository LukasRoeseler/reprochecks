suppressMessages({ library(readr); library(dplyr) })
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check")
excluded.subjects <- c(8, 21, 11, 23, 25, 40)
beh <- read_csv('data/generated/beh_data_tidy.csv', show_col_types=FALSE)
cat("subject_id class:", class(beh$subject_id), "| sample values:", paste(head(unique(beh$subject_id)), collapse=","), "\n")
cat("Is '8' among subject_ids (as char)?", "8" %in% unique(beh$subject_id), "\n")
cat("Is '08' among subject_ids?", "08" %in% unique(beh$subject_id), "\n")

A <- beh %>% filter(!subject_id %in% excluded.subjects) %>% filter(!syntax_cat %in% c('Filler-Gram','Filler-Ungram'))
cat("N subjects after author-style filter (!subject_id %in% c(8,21,11,23,25,40)) :", length(unique(A$subject_id)), "\n")

# Proper filter: convert to integer
B <- beh %>% mutate(sid = as.integer(subject_id)) %>% filter(!sid %in% excluded.subjects) %>% filter(!syntax_cat %in% c('Filler-Gram','Filler-Ungram'))
cat("N subjects after proper integer filter:", length(unique(B$sid)), "\n")

tbl <- function(d, lab){ d %>% group_by(syntax_cat, subject_id) %>% summarize(acc=mean(correct)*100, .groups='drop') %>%
  group_by(syntax_cat) %>% summarize(mean=mean(acc), sd=sd(acc)) %>% mutate(method=lab) }
cat("TABLE1 AUTHOR-STYLE FILTER (no real exclusion):\n"); print(tbl(A,"author-style") ,digits=6)
cat("TABLE1 PROPER INTEGER FILTER (excl. 6):\n"); print(tbl(B,"proper"),digits=6)
