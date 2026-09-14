datadir <- "C:/Users/lroesele.IVV5NET/AppData/Local/Temp/opencode/flpdata/extracted/data"
for (nm in c("sim_gp_fp2.RData", "sim_gp_fp1.RData")) {
  e <- new.env(); load(file.path(datadir, nm), envir=e)
  cat("\n== ", nm, "==\n")
  objs <- ls(envir=e)
  cat("objects:", paste(objs, collapse=", "), "\n")
  for (o in objs) { v <- get(o, envir=e); if(is.numeric(v)&&length(v)<=12) { cat(" ", o, "dim:", paste(dim(v),collapse="x"), "class:", class(v), "\n") } else if(is.array(v)) { cat(" ", o, "dim:", paste(dim(v),collapse="x"), "\n") } }
}
