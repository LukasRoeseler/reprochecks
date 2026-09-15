txt <- readLines("C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/I4R ReproAI Checks/08_s41562-023-01712-8/paper_extracted.txt", warn=FALSE)
## find Table 1 block
start <- which(grepl("^Abrami 2020", txt)); end <- which(grepl("^Zucker 2009", txt))
cat("Table start line", start, "end line", end, "\n")
block <- txt[start:end]
toks <- lapply(block, function(l){ t<-strsplit(l,"\\s+")[[1]]; t<-t[nzchar(t)]; t })
## a valid row: at least name(s), a 4-digit year, then 7 single-letter ratings
valid <- sapply(toks, function(t){
  if(length(t)<9) return(FALSE)
  year_idx <- which(grepl("^[0-9]{4}$", t))
  if(length(year_idx)==0 || tail(year_idx,1) != length(t)-7) return(FALSE)
  ratings <- t[(tail(year_idx,1)+1):length(t)]
  all(ratings %in% c("L","U","H"))
})
cat("Parsed Table 1 data rows (printed):", sum(valid), "\n")
