txt <- readLines("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/paper_extracted.txt")
pat <- "^[[:alnum:]\\-\\'\"\\ \\.]+\\s+[0-9]{4}\\s+[ULH]\\s+[ULH]\\s+[ULH]\\s+[ULH]\\s+[ULH]\\s+[ULH]\\s+[ULH]\\s*$"
rows <- txt[grepl(pat, txt)]
cat("Matched Table-1-style data rows:", length(rows), "\n")
cat(head(rows,3), sep="\n"); cat("...\n"); cat(tail(rows,3), sep="\n")
## Also count distinct first-author-year across whole table
