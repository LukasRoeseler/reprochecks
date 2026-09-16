suppressMessages({library(MASS)})
repo <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/downloads/github/ycleong__MotivatedPerception"
Parms <- read.csv(file.path(repo,"data","model_outputs","subject_parms","simpleFull_subjparms.csv"))
cat("==== Fig3: cor( z, drift_bias ) ====\n")
print(cor.test(Parms$z, Parms$drift_bias))
rb <- rlm(drift_bias ~ z, data = Parms)
cat("\nRobust lm drift_bias ~ z:\n"); print(summary(rb))

Tr <- read.csv(file.path(repo,"data","model_outputs","trace_processed","simpleFull_trace_all.csv"), header=FALSE)
colnames(Tr) <- c("a","t","exp_z_mot","exp_z_int","v_bias","v_stim","v_int")
Tr$z_bias <- Tr$exp_z_mot
cat("\nP(z_bias > 0) =", round(mean(Tr$z_bias>0),4))
cat("\nP(v_bias > 0) =", round(mean(Tr$v_bias>0),4))
cat("\nz_bias mean", round(mean(Tr$z_bias),4), "5% q", round(quantile(Tr$z_bias,0.05),4))
cat("\nv_bias mean", round(mean(Tr$v_bias),4), "5% q", round(quantile(Tr$v_bias,0.05),4))
cat("\nDONE\n")
