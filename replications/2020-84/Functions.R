
# Recreated Functions.R helper functions (reimplemented from usage in scripts + methodology)
# Never shipped on OSF; recovered per audit instructions.

zero1 <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

get_lower_tri <- function(cormat) {
  cormat[upper.tri(cormat)] <- NA
  cormat
}

get.desc <- function(dat) {
  # Descriptive statistics used in Materials & Methods descriptive table
  rd <- function(x) round(x, 2)
  data.frame(
    var = colnames(dat),
    mean = apply(dat, 2, function(x) rd(mean(x, na.rm = TRUE))),
    sd = apply(dat, 2, function(x) rd(sd(x, na.rm = TRUE))),
    min = apply(dat, 2, function(x) rd(min(x, na.rm = TRUE))),
    max = apply(dat, 2, function(x) rd(max(x, na.rm = TRUE))),
    n = apply(dat, 2, function(x) sum(!is.na(x)))
  )
}

read.dta <- function(file, ...) {
  haven::read_dta(file = file, ...)
}

read.dta13 <- function(file, ...) {
  readstata13::read.dta13(file = file, ...)
}
