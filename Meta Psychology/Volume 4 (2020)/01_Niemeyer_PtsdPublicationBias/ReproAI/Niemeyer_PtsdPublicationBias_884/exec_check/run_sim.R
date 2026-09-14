###########################################################################
##### SIMULATION STUDY ASSESSING PROPERTIES OF PUBLICATION BIAS TESTS #####
##### (RANK-CORRELATION, EGGER, TEST OF EXCESS SIGNIFICANCE, AND      #####
##### P-UNIFORM) AND ESTIMATORS OF META-ANALYSIS AND 10% MOST PRECISE #####
##### EFFECT SIZES GIVEN CHARACTERISTICS OF THE SUBSETS               #####
##### Author: Robbie C.M. van Aert                                    #####
########################################################################### 

rm(list = ls())

################
### PACKAGES ###
################

# install.packages(c("XLConnect", "metafor", "puniform"))
# REPROAI NOTE: XLConnect requires Java which is unavailable on the audit host.
# Lossless loader swap to openxlsx (reads the same cached cell values, same sheet
# order). No simulation parameters or numbers change.
library(openxlsx)
library(metafor)
library(puniform)
library(parallel)

#################
### FUNCTIONS ###
#################

### Function for using the test of excess significance as described in 
# Ioannidis and Trikalinos (2007)
tes <- function(yi, sei, alpha, side) 
{
  
  ### FE meta-analysis for statistical power analysis
  est.fe <- rma(yi = yi, sei = sei, method = "FE")$b[1] 
  
  ### Compute statistical power and determine the number of observed statistically 
  # significant results
  if (side == "right") { 
    pow <- pnorm(qnorm(alpha, lower.tail = FALSE, sd = sei), mean = est.fe, 
                 sd = sei, lower.tail = FALSE)
    O <- sum(pnorm(yi/sei, lower.tail = FALSE) < alpha)
  } else if (side == "left") {
    pow <- pnorm(qnorm(alpha, sd = sei), mean = est.fe, sd = sei)
    O <- sum(pnorm(yi/sei) < alpha)
  }
  
  E <- sum(pow) # Expected number of statistically significant result  
  n <- length(yi) # Number of studies in meta-analysis
  A <- (O - E)^2/E + (O - E)^2/(n - E) # Compute chi-square statistic
  pval.tes <- pchisq(A, 1, lower.tail = FALSE) # Compute p-value
  
  return(data.frame(A = A, pval.tes = pval.tes, O = O, E = E, n = n))
  
}

################################################################################

### Load data (REPROAI: openxlsx substitute for XLConnect readWorksheet)
f.xlsx <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/01_Niemeyer_PtsdPublicationBias/ReproAI/Niemeyer_PtsdPublicationBias_884/exec_check/data/Data_sets_PTSD_update_130419.xlsx"
sheet.names <- getSheetNames(f.xlsx)
dat <- lapply(sheet.names, function(s) read.xlsx(f.xlsx, sheet = s))
names(dat) <- sheet.names

### Used meta-analysis method
method <- c(rep("FE", 14), "DL", rep("FE", 4), "DL", "FE", rep("DL", 2), "FE", "DL",
            rep("FE", 2), "DL", "FE", rep("DL", 11), rep("FE", 2), rep("DL", 3), 
            rep("FE", 8), rep("DL", 8), "FE", rep("DL", 17), "N", rep("FE", 4),
            rep("DL", 3), rep("FE", 4), rep("DL", 9))

### Conditions
mus <- 0
alpha <- 0.025
pubs <- c(0, 0.25, 0.5, 0.75, 0.85, 0.95, 1)
# REPROAI: reduced iterations (400) vs the manuscript's 10,000 (2000 was still
# too slow on this host). Preserves the author's fixed seed scheme (set.seed(9419*pos)).
# Aggregate claims are checked against the shipped res2_*.csv (the author's full run).
iters <- 400
nworkers <- detectCores()

### Create grid with all conditions
cond <- expand.grid(mus = mus, pubs = pubs)

time.start <- proc.time()

do.sim <- function(pos, cond, iters, alpha, dat)
{
  
  set.seed(9419*pos)
  
  ### Select condition
  mu <- cond$mus[pos]
  pub <- cond$pubs[pos]
  
  cat("mu = ", mu, "pub = ", pub, fill = TRUE)
  
  ### Empty objects
  rank_sig <- egg_sig <- tes_sig <- puni_sig <- ksig <- matrix(NA, nrow = length(dat), 
                                                               ncol = iters)
  
  for (j in 1:length(dat))
  {
   
    ### Store sei as object
    sei <- dat[[j]]$sei
    
    i <- 1 # Counter for storing results iterations
    
    while (i <= iters)
    {
      
      ### Empty object
      yi_sim <- numeric(length(sei))
      
      m <- 1 # Counter for storing results generating data
      
      while (m <= length(sei))
      {
        ### Sample an effect size
        y <- rnorm(1, mean = mu, sd = sei[m])
        
        ### Compute one-tailed p-value
        pval <- pnorm(y/sei[m], lower.tail = FALSE)
        
        if (pval < alpha | runif(1) < 1-pub)
        { # If p-value is below alpha or randomly generated number from uniform 
          # distribution is below 1-pub, store effect size
          yi_sim[m] <- y
          m <- m + 1
        }
      }
      
      ### Store proportion of statistically significant results
      ksig[j,i] <- mean(pnorm(yi_sim/sei, lower.tail = FALSE) < alpha)
      
      ##########################################################################
      
      ### Random-effects meta-analysis with Paule-Mandel estimator for tau^2
      if (j == 69 | j == 70)
      { # tau^2 can be estimated very large for data sets with raw mean difference 
        # as effect size measure, so increase upper bound of root-finding
        ma <- try(rma(yi = yi_sim, sei = sei, method = "PM", 
                      control = list(tau2.max = 1000)))
      } else
      {
        ma <- try(rma(yi = yi_sim, sei = sei, method = "PM"))
      }
      
      if (inherits(ma, "try-error"))
      { # If tau^2 cannot be estimated, start new iteration
        next
      }
      
      ##########################################################################
      
      ### Rank-correlation test (suppressWarnings() to suppress warning in
      # case of ties)
      tmp <- suppressWarnings(ranktest(ma))
      rank_sig[j,i] <- ifelse(tmp$pval < .05, 1, 0)
      
      ### Egger's regression test
      tmp <- try(regtest(ma))
      if (inherits(tmp, "try-error"))
      { # If tau^2 cannot be estimated, start new iteration
        next
      }
      egg_sig[j,i] <- ifelse(tmp$pval < .05, 1, 0)
      
      ### Test of excess significance
      tmp <- tes(yi = yi_sim, sei = sei, alpha = .025, side = "right")
      tes_sig[j,i] <- ifelse(tmp$pval.tes < .05, 1, 0)
      
      ### P-uniform
      tmp <- try(puniform(yi = yi_sim, vi = sei^2, method = "P", side = "right",
                          alpha = .05), silent = TRUE)
      if (class(tmp) == "try-error")
      { # If there are no significant results, return NA
        puni_sig[j,i] <- NA
      } else
      {
        ### Store two-tailed p-value of p-uniform
        pval <- ifelse(tmp$pval.pb < 0.5, tmp$pval.pb*2, (1-tmp$pval.pb)*2)
        puni_sig[j,i] <- ifelse(pval < .05, 1, 0)
      }
      
      i <- i + 1
      
    }
  }
  
  ### Store results of publication bias tests
  res1_rank <- mean(rank_sig)
  res1_egg <- mean(egg_sig)
  res1_tes <- mean(tes_sig, na.rm = TRUE)
  res1_puni <- mean(puni_sig, na.rm = TRUE)
  
  ### Statistical power per data set 
  res2_rank <- rowMeans(rank_sig)
  res2_egg <- rowMeans(egg_sig)
  res2_tes <- rowMeans(tes_sig, na.rm = TRUE)
  res2_puni <- rowMeans(puni_sig, na.rm = TRUE)
  
  ### Store information on number of statistically significant results
  res3_mean <- mean(ksig)
  res3_zero <- sum(ksig == 0)/(iters*length(dat))
  
  ### Proportion of data sets with statistical power larger than 0.8
  res4_rank <- mean(res2_rank > 0.8)
  res4_egg <- mean(res2_egg > 0.8)
  res4_tes <- mean(res2_tes > 0.8)
  res4_puni <- mean(res2_puni > 0.8, na.rm = TRUE)
  
  ### Proportion of data sets with k > 10 with power larger than 0.8
  large_data <- unlist(lapply(dat, FUN = function(x) nrow(x) > 10))
  res5_rank <- mean(res2_rank[large_data] > 0.8)
  res5_egg <- mean(res2_egg[large_data] > 0.8)
  res5_tes <- mean(res2_tes[large_data] > 0.8)
  res5_puni <- mean(res2_puni[large_data] > 0.8, na.rm = TRUE)
  
  return(list(c(res1_rank, res1_egg, res1_tes, res1_puni, res3_mean, res3_zero, 
                res4_rank, res4_egg, res4_tes, res4_puni, 
                res5_rank, res5_egg, res5_tes, res5_puni), 
              res2_rank = res2_rank, res2_egg = res2_egg, res2_tes = res2_tes, 
              res2_puni = res2_puni))
}

if (nworkers == 1)
{
  out <- lapply(1:nrow(cond), do.sim, cond = cond, iters = iters, alpha = alpha, 
                dat = dat)
} else 
{
  cl <- makePSOCKcluster(nworkers, outfile = "log.txt") # Create cluster
  clusterCall(cl, function() library(metafor))
  clusterCall(cl, function() library(puniform))
  clusterExport(cl, varlist = c("tes"))
  out <- clusterApplyLB(cl, 1:nrow(cond), do.sim, cond = cond, iters = iters, 
                        alpha = alpha, dat = dat) # Run simulation
  stopCluster(cl) # Shut down the nodes   
}

time.end <- proc.time()
cat("Seconds:", (time.end - time.start)[3], "\n")
cat("Minutes:", (time.end - time.start)[3]/60, "\n")
cat("Hours:  ", (time.end - time.start)[3]/(60*60), "\n")

### Change format of results and add column names
out1 <- lapply(out, function(w) w[[1]])
out1 <- do.call(rbind, out1)
colnames(out1) <- c("res1_rank", "res1_egg", "res1_tes", "res1_puni", 
                    "res3_mean", "res3_zero", "res4_rank", "res4_egg", "res4_tes", 
                    "res4_puni", "res5_rank", "res5_egg", "res5_tes", "res5_puni")

res_sim <- cbind(cond, out1)
# dump("res_sim", "res_sim.txt")

### REPROAI: save results to audit output dir (replacing Dropbox-only writes)
out.dir <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 4 (2020)/01_Niemeyer_PtsdPublicationBias/ReproAI/Niemeyer_PtsdPublicationBias_884/exec_check/output"
print(res_sim)
write.csv(res_sim, file = file.path(out.dir, "res_sim_agg_repro.csv"), row.names = FALSE)

### Create charactor vector with condition names
names <- numeric(nrow(cond))
for (w in 1:nrow(cond))
{
  names[w] <- paste("mu = ", cond[w, ]$mus, "; pub = ", cond[w, ]$pubs, sep = "")
}

### Create vector with column names
ID <- as.numeric(substr(names(dat), start = 1, stop = regexpr(" ", names(dat))-1))

### REPROAI: save per-dataset power matrices
res2_rank <- round(do.call(rbind, lapply(out, function(w) w[["res2_rank"]])), 3)
res2_egg <- round(do.call(rbind, lapply(out, function(w) w[["res2_egg"]])), 3)
res2_tes <- round(do.call(rbind, lapply(out, function(w) w[["res2_tes"]])), 3)
res2_puni <- round(do.call(rbind, lapply(out, function(w) w[["res2_puni"]])), 3)

rownames(res2_rank) <- rownames(res2_egg) <- rownames(res2_tes) <- rownames(res2_puni) <- names
colnames(res2_rank) <- colnames(res2_egg) <- colnames(res2_tes) <- colnames(res2_puni) <- ID

write.csv(res2_rank, file = file.path(out.dir, "res2_rank_repro.csv"))
write.csv(res2_egg, file = file.path(out.dir, "res2_egg_repro.csv"))
write.csv(res2_tes, file = file.path(out.dir, "res2_tes_repro.csv"))
write.csv(res2_puni, file = file.path(out.dir, "res2_puni_repro.csv"))

### REPROAI checks mirroring manuscript claims
for (nm in c("rank", "egg", "tes", "puni")) {
  m <- get(paste0("res2_", nm))
  cat("PROP >0.8 pub<0.95 (", nm, "):", sum(m[1:6, ] > 0.8), "\n")
  cat("PROP >0.8 pub=1 (", nm, "):", sum(m[7, ] > 0.8), "/", ncol(m), "\n")
}
cat("REPROAI_SIM_COMPLETE\n")
