suppressMessages(library(readr)); library(dplyr)
setwd("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/09_deLeeuw_ERP/ReproAI/deLeeuw_ERP_1481/exec_check")
excluded.subjects <- c(8,21,11,23,25,40)
beh <- read_csv('data/generated/beh_data_tidy.csv', show_col_types=FALSE) %>%
  filter(!subject_id %in% excluded.subjects) %>%
  filter(!syntax_cat %in% c('Filler-Gram','Filler-Ungram'))
sb <- beh %>% group_by(syntax_cat, subject_id) %>%
  summarize(accuracy = mean(correct)*100, .groups='drop') 
print(as.data.frame(sb[sb$syntax_cat=="Grammatical",c("subject_id","accuracy")]), row.names=FALSE)
cat("rows Grammatical:", nrow(beh[beh$syntax_cat=="Grammatical",]), "subjects:", length(unique(beh$subject_id[beh$syntax_cat=="Grammatical"])), "\n")
