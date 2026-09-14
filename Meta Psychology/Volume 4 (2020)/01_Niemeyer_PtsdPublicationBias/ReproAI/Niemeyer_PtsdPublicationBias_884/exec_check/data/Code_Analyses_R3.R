#############################################################################
##### APPLYING META-ANALYSIS AND PUBLICATION BIAS METHODS TO DATA SETS  #####
##### ON THE EFFICACY OF PTSD                                           #####
#############################################################################

rm(list = ls()) # Clean workspace

# install.packages(c("XLConnect", "metafor", "puniform", "weightr"))
library(XLConnect)
library(weightr)
library(metafor)
library(puniform)

### Load data
setwd("C:/Dropbox/Werk/Onderzoek/Papers/Paper Helen/R1")
wb <- loadWorkbook("Data_sets_PTSD_update_130419.xlsx")
dat <- readWorksheet(wb, sheet = getSheets(wb))

### Used meta-analysis method
method <- c(rep("FE", 14), "DL", rep("FE", 4), "DL", "FE", rep("DL", 2), "FE", "DL",
            rep("FE", 2), "DL", "FE", rep("DL", 11), rep("FE", 2), rep("DL", 3), 
            rep("FE", 8), rep("DL", 8), "FE", rep("DL", 17), "N", rep("FE", 4),
            rep("DL", 3), rep("FE", 4), rep("DL", 9))

#################
### FUNCTIONS ###
#################

### PET-PEESE function as described in Stanley and Doucouliagos (2014b)
petpeese <- function(yi, vi, ma.est) {
  
  pet <- lm(yi ~ sqrt(vi), weights = 1/vi) # PET analysis
  pval.pet  <- summary(pet)$coefficients[1, 4] # Store p-value
  tval.pet <- summary(pet)$coefficients[1, 3] # Store t-value
  
  if (ma.est < 0)
  { # Compute one-tailed p-value depending on whether MA estimate is positive/negative
    # Using one-tailed p-value for determining PET or PEESE is in line with Stanley (2017)
    one.pval <- ifelse(tval.pet < 0, pval.pet/2, 1-pval.pet/2)
  } else if (ma.est > 0)
  {
    one.pval <- ifelse(tval.pet > 0, pval.pet/2, 1-pval.pet/2)
  }
  
  ### If null-hypothesis of no effect could not be rejected, use PET
  if (one.pval > 0.1) { method <- "PET" 
  } else { method <- "PEESE" }
  
  ### Store results of PET-PEESE
  if (method == "PET") {
    est <- summary(pet)$coefficients[1,1]
    se <- summary(pet)$coefficients[1,2]
    ci.lb <- confint(pet)[1,1]
    ci.ub <- confint(pet)[1,2]
  } else if (method == "PEESE") {
    peese <- lm(yi ~ vi, weights = 1/vi)
    est <- summary(peese)$coefficients[1,1]
    se <- summary(peese)$coefficients[1,2]
    ci.lb <- confint(peese)[1,1]
    ci.ub <- confint(peese)[1,2]
  }
  
  return(data.frame(method = method, est = est, se = se, tval.pet = tval.pet, 
                    pval.pet = pval.pet, ci.lb = ci.lb, ci.ub = ci.ub))
}

### Function for using the test of excess significance as described in Ioannidis and Trikalinos (2007)
tes <- function(yi, sei, alpha, side) {
  
  est.fe <- rma(yi = yi, sei = sei, method = "FE")$b[1] # FE meta-analysis for statistical power analysis
  
  ### Compute statistical power and determine the number of observed statistically significant results
  if (side == "right") { 
    pow <- pnorm(qnorm(alpha, lower.tail = FALSE, sd = sei), mean = est.fe, sd = sei, lower.tail = FALSE)
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

### Function for computing Loevinger's H
LoevH <- function(tab) { #################################
  a <- tab[1,1]          #####   a   #    b    #    p1   #
  b <- tab[1,2]          #####   c   #    d    #    q1   #
  c <- tab[2,1]          #################################   
  d <- tab[2,2]          #####   p2  #    q2   #         #
  p1 <- a+b              #################################
  p2 <- a+c
  q1 <- c+d
  q2 <- b+d
  H <- (a*d-b*c)/min(p1*q2, p2*q1)
  return(H)
}

### Create empty objects
res1 <- matrix(NA, nrow = length(dat), ncol = 15, dimnames = list(1:length(dat), c("est.ma", "ci.lb.ma", "ci.ub.ma", "zval.ma",
                                                                                   "pval.ma", "tau2", "I2", "lb.I2", "ub.I2", "Q", "pval.Q", 
                                                                                   "pval.right", "pval.left", "sd.sei", "perc.sig")))
res2 <- matrix(NA, nrow = length(dat), ncol = 11, dimnames = list(1:length(dat), c("ksig", "est.pu", "ci.lb.pu", "ci.ub.pu",
                                                                                   "L.0.pu", "pval.pu", "zval.pu", "pval.pb.pu", "est.pu.all",
                                                                                   "ci.lb.pu.all", "ci.ub.pu.all")))
res3 <- matrix(NA, nrow = length(dat), ncol = 6, dimnames = list(1:length(dat), c("est.pp", "se.pp", "tval.pp", "pval.pp", "ci.lb.pp",
                                                                                  "ci.ub.pp")))
res4 <- matrix(NA, nrow = length(dat), ncol = 5, dimnames = list(1:length(dat), c("A", "pval.tes", "O", "E", "k")))

res5 <- matrix(NA, nrow = length(dat), ncol = 6, dimnames = list(1:length(dat), c("est.trim", "ci.lb.trim", "ci.ub.trim", "zval.trim",
                                                                                  "pval.trim", "imp.k")))

res6 <- matrix(NA, nrow = length(dat), ncol = 2, dimnames = list(1:length(dat), c("tau", "pval.begg")))

res7 <- matrix(NA, nrow = length(dat), ncol = 2, dimnames = list(1:length(dat), c("zval.egg", "pval.egg")))

res8 <- matrix(NA, nrow = length(dat), ncol = 6, dimnames = list(1:length(dat), c("est.sel", "ci.lb.sel", "ci.ub.sel", "zval.sel",
                                                                                  "pval.sel", "tau2.sel")))

res2.side <- res3.method <- total.k <- vector("logical", length(dat))

i <- 1 # Counter for storing results
alpha <- .05 # Alpha level in primary studies (two-tailed test is assumed)
lors <- c(2, 6, 10, 13, 14, 15, 16, 17, 18, 20, 21, 23, 24, 27, 29, 76) # Transform results to ORs or RRs for these data sets

######################
### START ANALYSES ###
######################

for (i in 1:length(dat)) {
  
  total.k[i] <- nrow(dat[[i]]) # Store number of studies in meta-analysis
  
  ### Select effect sizes and standard errors without NAs
  yi <- dat[[i]]$yi[!is.na(dat[[i]]$yi)]
  sei <- dat[[i]]$sei[!is.na(dat[[i]]$yi)]
  
  #####################
  ### META-ANALYSIS ###
  #####################
  
  if (i == 80) { tmp <- rma(yi = yi, sei = sei, weights = dat[[i]]$EG.N+dat[[i]]$CG.N, method = "FE") 
  } else { # Meta-analysis with DL as estimator for tau^2 or fixed-effect MA
    tmp <- rma(yi = yi, sei = sei, method = method[i]) 
  } 
  pval.right <- sum(pnorm(yi/sei, lower.tail = FALSE) < alpha/2) # Number of significant p-values in right tail
  pval.left <- sum(pnorm(yi/sei) < alpha/2) # Number of significant p-values in left tail
  
  if (method[i] == "DL")
  { # Compute CI for I^2-statistic if random-effects model was used
    I2 <- tmp$I2
    tmp.ci <- confint(tmp)$random
    lb.I2 <- tmp.ci[3,2]
    ub.I2 <- tmp.ci[3,3]
  } else 
  {
    I2 <- lb.I2 <- ub.I2 <- 0
  }
  
  ### Store results random-effects meta-analysis  
  if (i %in% lors) { # Transform LORs or LRRs to ORs or RRs
    res1[i, ] <- round(c(exp(tmp$b[1]), exp(tmp$ci.lb), exp(tmp$ci.ub), tmp$zval, 
                         tmp$pval, tmp$tau2, I2, lb.I2, ub.I2, tmp$QE, 
                         tmp$QEp, pval.right, pval.left, sd(sei), 100*((pval.left+pval.right)/total.k[i])), 3)
  } else {
    res1[i, ] <- round(c(tmp$b[1], tmp$ci.lb, tmp$ci.ub, tmp$zval, tmp$pval, tmp$tau2, 
                         I2, lb.I2, ub.I2, tmp$QE, tmp$QEp, 
                         pval.right, pval.left, sd(sei), 100*((pval.left+pval.right)/total.k[i])), 3)
  }
  
  #################
  ### P-UNIFORM ###
  #################
  
  ### Apply p-uniform if there are statistically significant studies
  if (pval.left > 0 | pval.right > 0) {
    if (pval.right > pval.left) { # If most significant p-values are in the right tail
      side <- "right"
      pvals <- pnorm(yi/sei, lower.tail = FALSE)
    } else { # If most significant p-values are in the left tail
      side <- "left" 
      pvals <- pnorm(yi/sei)
    }
    
    tmp2 <- puniform(yi = yi, vi = sei^2, side = side, alpha = alpha, method = "P", plot = FALSE) # Apply p-uniform
    ### Store results p-uniform
    res2.side[i] <- side 
    pval.0 <- ifelse(tmp2$pval.0 < 0.5, tmp2$pval.0*2, (1-tmp2$pval.0)*2)
    
    if (i %in% lors) { # Transform LORs or LRRs to ORs or RRs
      res2[i, ] <- round(c(tmp2$ksig, exp(tmp2$est), exp(tmp2$ci.lb), exp(tmp2$ci.ub), tmp2$L.0, 
                           pval.0, tmp2$L.pb, tmp2$pval.pb, exp(tmp2$est), exp(tmp2$ci.lb), exp(tmp2$ci.ub)), 3)
    } else {
      res2[i, ] <- round(c(tmp2$ksig, tmp2$est, tmp2$ci.lb, tmp2$ci.ub, tmp2$L.0, 
                           pval.0, tmp2$L.pb, tmp2$pval.pb, tmp2$est, tmp2$ci.lb, tmp2$ci.ub), 3)
    }
    
    # If average of statistically significant p-values is larger than alpha/4, 
    # set estimate equal to 0 (recommendation in Van Aert et al. [2016])
    if (mean(pvals[pvals < alpha/2]) > alpha/4) { 
      
      if (i %in% lors) { # Transform LORs or LRRs to ORs or RRs
        res2[i, ] <- round(c(tmp2$ksig, 0, NA, NA, tmp2$L.0, pval.0, tmp2$L.pb, 
                             tmp2$pval.pb, exp(tmp2$est), exp(tmp2$ci.lb), exp(tmp2$ci.ub)), 3)
      } else {
        res2[i, ] <- round(c(tmp2$ksig, 0, NA, NA, tmp2$L.0, pval.0, tmp2$L.pb, 
                             tmp2$pval.pb, tmp2$est, tmp2$ci.lb, tmp2$ci.ub), 3)
      }
    }
  } else { # If there are no statistically significant studies return NA
    res2[i, ] <- rep(NA, ncol(res2))
  }
  
  #################
  ### PET-PEESE ###
  #################
  
  tmp3 <- petpeese(yi = yi, vi = sei^2, ma.est = tmp$b[1])
  ### Store results of PET-PEESE
  res3.method[i] <- as.character(tmp3$method)
  
  if (i %in% lors) { # Transform LORs or LRRs to ORs or RRs
    res3[i, ] <- round(c(exp(tmp3$est), tmp3$se, tmp3$tval.pet, tmp3$pval.pet, exp(tmp3$ci.lb), exp(tmp3$ci.ub)), 3)
  } else {
    res3[i, ] <- round(c(tmp3$est, tmp3$se, tmp3$tval.pet, tmp3$pval.pet, tmp3$ci.lb, tmp3$ci.ub), 3)
  }
  
  ###########
  ### TES ###
  ###########
  
  if (tmp$b[1] > 0) { side.tes <- "right"
  } else { side.tes <- "left" }
  
  tmp4 <- tes(yi = yi, sei = sei, alpha = alpha/2, side = side.tes)
  ### Store results of TES
  res4[i, ] <- round(c(tmp4$A, tmp4$pval.tes, tmp4$O, tmp4$E, tmp4$n), 3)
  
  #####################
  ### TRIM AND FILL ###
  #####################
  
  tmp5 <- trimfill(tmp)
  ### Store results of trim and fill
  res5[i, ] <- round(c(tmp5$b[1], tmp5$ci.lb, tmp5$ci.ub, tmp5$zval, tmp5$pval, tmp5$k0), 3)
  
  if (i %in% lors) { # Transform LORs or LRRs to ORs or RRs
    res5[i, ] <- round(c(exp(tmp5$b[1]), exp(tmp5$ci.lb), exp(tmp5$ci.ub), tmp5$zval, tmp5$pval, tmp5$k0), 3)
  } else {
    res5[i, ] <- round(c(tmp5$b[1], tmp5$ci.lb, tmp5$ci.ub, tmp5$zval, tmp5$pval, tmp5$k0), 3)
  }
  
  #############################
  ### RANK-CORRELATION TEST ###
  #############################
  
  tmp6 <- ranktest(tmp)
  ### Store results rank-correlation test
  res6[i, ] <- round(c(tmp6$tau, tmp6$pval), 3)
  
  #######################
  ### REGRESSION TEST ###
  #######################
  
  tmp7 <- regtest(tmp)
  ### Store results regression test
  res7[i, ] <- round(c(tmp7$zval, tmp7$pval), 3)
  
  ################################
  ### SELECTION MODEL APPROACH ###
  ################################
  
  ### Set p-value cutpoints of selection model depending on whether majority of 
  # statistically significant effect sizes are in left or right-tail. In case of 
  # no significant effect sizes, the right-tail is used
  if (side == "left")
  {
    tmp8 <- try(weightfunct(effect = yi, v = sei^2, steps = c(0.975, 1)))
  } else
  {
    tmp8 <- try(weightfunct(effect = yi, v = sei^2))
  }
  
  if (class(tmp8) == "try-error")
  { # If method cannot be applied, return NAs
    res8[i, ] <- rep(NA, 6)
  } else
  { 
    
    if (i %in% lors) { # Transform LORs or LRRs to ORs or RRs
      res8[i, ] <- round(c(exp(tmp8$adj_est[2]), exp(tmp8$ci.lb_adj[2]), 
                           exp(tmp8$ci.ub_adj[2]), tmp8$z_adj[2], 
                           tmp8$p_adj[2], tmp8$adj_est[1]), 3)
    } else {
      res8[i, ] <- round(c(tmp8$adj_est[2], tmp8$ci.lb_adj[2], tmp8$ci.ub_adj[2], 
                           tmp8$z_adj[2], tmp8$p_adj[2], tmp8$adj_est[1]), 3)
    }
  }
  
}

ID <- as.numeric(substr(names(dat), start = 1, stop = regexpr(" ", names(dat))-1))

res1 <- cbind(ID = ID, as.data.frame(res1))
res2 <- cbind(ID = ID, as.data.frame(res2), I2 = res1$I2)
res2 <- cbind(res2, side = res2.side)
res3 <- cbind(ID = ID, as.data.frame(res3))
res3 <- cbind(res3, method = res3.method)
res4 <- cbind(ID = ID, as.data.frame(res4))
res5 <- cbind(ID = ID, as.data.frame(res5))
res6 <- cbind(ID = ID, as.data.frame(res6)) # Different than results with CMA for 
# ID 53 and 91 are caused by computing the exact p-value with the ranktest function
res7 <- cbind(ID = ID, as.data.frame(res7))
res8 <- cbind(ID = ID, as.data.frame(res8))

sh1 <- cbind(ID = ID, k = res4$n, ksig = res2$ksig, est.ma = res1$est.ma, pval.ma = res1$pval.ma, 
             est.pp = res3$est, est.pu = res2$est.pu, 
             I2 = res1$I2, pval.tes = res4$pval.tes, pval.pb.pu = res2$pval.pb, sd.sei = res1$sd.sei)
sh1

summary(total.k) # Median number of studies in meta-analysis
summary(res1$pval.right+res1$pval.left) # Median number of significant studies in a meta-analysis
summary(res1$perc.sig) # Median percentage of significant studies in a meta-analysis
sum(res1$pval.left != 0 | res1$pval.right != 0) # How many data sets have at least one significant study
summary(res1$I2) # Median and quartiles of I2

### Figure funnel plot ###
i <- 85

### Select effect sizes and standard errors without NAs
yi <- dat[[i]]$yi[!is.na(dat[[i]]$yi)]
sei <- dat[[i]]$sei[!is.na(dat[[i]]$yi)]

tmp <- rma(yi = yi, sei = sei, method = method[i])
tmp5 <- trimfill(tmp)
# tiff("funnel.tiff", width = 4, height = 4, pointsize = 8, units = "in", res = 300)
funnel(tmp5, refline=0, xlab=expression(paste("Hedges' ", italic(g))), 
       main="Funnel plot for meta-analysis by Sloan et al. (2013)")
legend(x = "topright", legend = c("Observed effect sizes", "Imputed effect sizes"), 
       cex = 0.9, pch = c(16,1), bg = "white")
# dev.off()

### Table appendix
order.ID <- c(43, 44, 77, 18, 19, 20, 21, 22, 23, 57, 58, 11, 12, 13, 65, 74, 69,
              71, 64, 2, 4, 5, 6, 14, 17, 29, 67, 68, 70, 72, 73, 75, 76, 45, 8,
              9, 10, 1, 3, 7, 30, 31, 48, 49, 52, 53, 16, 27, 28, 41, 42, 63, 82,
              83, 32, 34, 35, 37, 15, 24, 25, 26, 33, 36, 38, 39, 40, 61, 54, 55,
              56, 59, 60, 66, 81, 87, 89, 90, 78, 88, 79, 80, 84, 85, 86, 
              46, 47, 50, 51, 91, 92, 93, 94, 97, 98, 103, 105, 106)

### Empty object
tabA1 <- matrix(NA, nrow=length(order.ID), ncol=9, dimnames=list(as.character(order.ID), 
                                                                 c("Author", "Replicated ES", "No studies",
                                                                   "BeggEgger", "TES", "puniform",
                                                                   "Trim", "PET", "Sel.model")))

### Round results for presentation
res1.tab <- round(res1, 2)
res6.tab <- round(res6, 2)
res7.tab <- round(res7, 2)
res4.tab <- round(res4, 2)
res2.tab <- round(res2[ ,1:13], 2)
res5.tab <- round(res5, 2)
res3.tab <- round(res3[ ,1:7], 2)
res8.tab <- round(res8, 2)

m <- 0 # Counter for storing results

### Create table
for (i in order.ID) {
  
  m <- m+1
  
  extr <- which(res1$ID == i) # Get index for extracting data
  
  tabA1[m,1] <- names(dat)[extr]
  tabA1[m,2] <- paste(res1.tab$est.ma[extr], " (", res1.tab$ci.lb.ma[extr], ";", 
                      res1.tab$ci.ub.ma[extr], "), ", "I2=", round(res1.tab$I2[extr], 1), 
                      ", (", round(res1.tab$lb.I2[extr], 1), ";", 
                      round(res1.tab$ub.I2[extr], 1), ")", sep="")
  
  ksig.tab <- ifelse(is.na(res2.tab$ksig[extr]), 0, res2.tab$ksig[extr])
  tabA1[m,3] <- paste(res4.tab$k[extr], " (", ksig.tab, ")", sep="")
  
  if (res6$pval.begg[extr] < .05 & res7$pval.egg[extr] < .05) {
    tabA1[m,4] <- paste("tau=", res6$tau[extr], "*", ", ", "z=", res7.tab$zval.egg[extr], "*", sep="")
  } else if (res6$pval.begg[extr] < .05 & res7$pval.egg[extr] > .05) {
    tabA1[m,4] <- paste("tau=", res6.tab$tau[extr], "*", ", ", "z=", res7.tab$zval.egg[extr], sep="")
  } else if (res6$pval.begg[extr] > .05 & res7$pval.egg[extr] < .05) {
    tabA1[m,4] <- paste("tau=", res6.tab$tau[extr], ", ", "z=", res7.tab$zval.egg[extr], "*", sep="")
  } else if (res6$pval.begg[extr] > .05 & res7$pval.egg[extr] > .05) {
    tabA1[m,4] <- paste("tau=", res6.tab$tau[extr], ", ", "z=", res7.tab$zval.egg[extr], sep="")
  }
  
  if (res4$pval.tes[extr] < .05) {
    tabA1[m,5] <- paste("A=", res4.tab$A[extr], "*", sep="")
  } else if (res4$pval.tes[extr] > .05) {
    tabA1[m,5] <- paste("A=", res4.tab$A[extr], sep="")
  }
  
  if (is.na(res2$pval.pb.pu[extr])) {
    tabA1[m,6] <- "No significant studies"
  } else if (res2$pval.pb.pu[extr] < .05 & is.na(res2$ci.lb.pu[extr])== FALSE) {
    tabA1[m,6] <- paste(res2.tab$est.pu.all[extr], " (", res2.tab$ci.lb.pu.all[extr], ";", 
                        res2.tab$ci.ub.pu.all[extr], ")", ", Lupuni=", res2.tab$zval.pu[extr], "*", sep="")
  } else if (res2$pval.pb.pu[extr] > .05 & is.na(res2$ci.lb.pu[extr])== FALSE) {
    tabA1[m,6] <- paste(res2.tab$est.pu.all[extr], " (", res2.tab$ci.lb.pu.all[extr], ";", 
                        res2.tab$ci.ub.pu.all[extr], ")", ", Lupuni=", res2.tab$zval.pu[extr], sep="")
  } else if (res2$pval.pb.pu[extr] < .05 & is.na(res2$ci.lb.pu[extr])) {
    tabA1[m,6] <- paste(res2.tab$est.pu.all[extr], "setnull", " (", res2.tab$ci.lb.pu.all[extr], ";", 
                        res2.tab$ci.ub.pu.all[extr], ")", ", Lupuni=", res2.tab$zval.pu[extr], "*", sep="")
  } else if (res2$pval.pb.pu[extr] > .05 & is.na(res2$ci.lb.pu[extr])) {
    tabA1[m,6] <- paste(res2.tab$est.pu.all[extr], "setnull", " (", res2.tab$ci.lb.pu.all[extr], ";", 
                        res2.tab$ci.ub.pu.all[extr], ")", ", Lupuni=", res2.tab$zval.pu[extr], sep="")
  }
  
  tabA1[m,7] <- paste(res5.tab$est.trim[extr], " (", res5.tab$ci.lb.trim[extr], ";", 
                      res5.tab$ci.ub.trim[extr], ")", ", kimp=", res5.tab$imp.k[extr], sep="")
  
  tabA1[m,8] <- paste(res3.tab$est.pp[extr], " (", res3.tab$ci.lb.pp[extr], ";", 
                      res3.tab$ci.ub.pp[extr], ") ", sep="")
  
  if (is.na(res8.tab$est.sel[extr]))
  {
    tabA1[m,9] <- "No convergence"
  } else
  {
    tabA1[m,9] <- paste(res8.tab$est.sel[extr], " (", res8.tab$ci.lb.sel[extr], ";", 
                        res8.tab$ci.ub.sel[extr], ") ", sep="")
  }
  
}

# write.csv(tabA1, file="tabA1.csv")

### Create 2x2 tables and compute Loevinger's H for publication bias tests
begg.sig <- res6$pval.begg < .05 # Rank-correlation test
egg.sig <- res7$pval.egg < .05 # Egger's test
tes.sig <- res4$pval.tes < .05 # Test of Excess Significance
puni.pb.sig <- res2$pval.pb.pu < .05 # p-uniform's publication bias test

sum(egg.sig)/length(egg.sig) # Maximum percentage of publication bias by Egger's test

### How often did two publication bias tests detect bias
sum(rowSums(cbind(begg.sig, egg.sig, tes.sig, puni.pb.sig), na.rm = TRUE) == 2)
sum(rowSums(cbind(begg.sig, egg.sig, tes.sig, puni.pb.sig), na.rm = TRUE) == 2)/length(begg.sig)

### Egger's test and rank-correlation test
ftable(egg.sig, begg.sig)
round(LoevH(ftable(egg.sig, begg.sig)), 3)

### TES and rank-correlation test
ftable(tes.sig, begg.sig)
round(LoevH(ftable(tes.sig, begg.sig)), 3)

### P-uniform and rank-correlation test
sub <- subset(data.frame(puni.pb.sig, begg.sig), is.na(puni.pb.sig) == FALSE)
ftable(sub$puni.pb.sig, sub$begg.sig)
round(LoevH(ftable(sub$puni.pb.sig, sub$begg.sig)), 3)

### TES and Egger's test
ftable(tes.sig, egg.sig)
round(LoevH(ftable(tes.sig, egg.sig)), 3)

### P-uniform and Egger's test
sub <- subset(data.frame(puni.pb.sig, egg.sig), is.na(puni.pb.sig) == FALSE)
ftable(sub$puni.pb.sig, sub$egg.sig)
round(LoevH(ftable(sub$puni.pb.sig, sub$egg.sig)), 3)

### P-uniform and TES
sub <- subset(data.frame(puni.pb.sig, tes.sig), is.na(puni.pb.sig) == FALSE)
ftable(sub$puni.pb.sig, sub$tes.sig)
round(LoevH(ftable(sub$puni.pb.sig, sub$tes.sig)), 3)

################################################################################

### Compute how often publication bias tests are significant per subgroup
df <- data.frame(ID=res6$ID, begg.sig, egg.sig, tes.sig, puni.pb.sig) # Create data frame with IDs and outcomes

### Create vectors with IDs belonging to a particular group
TFCBT <- c(74, 69, 71, 64, 2, 4, 5, 6, 14, 17, 29, 67, 68, 70, 72, 73, 75, 76, 45,
           97)
CBT.comb <- c(8, 9, 10, 1, 3, 7, 30, 31, 48, 49, 52, 53)
EMDR <- c(32, 34, 35, 37, 15, 24, 25, 26, 33, 36, 38, 39, 40)
comb <- c(61, 81, 87, 89, 90, 78, 88, 79, 80, 84, 85, 86, 93, 46, 47, 50, 51, 91, 
          92, 106)
treat <- c(43, 44, 77, 18, 19, 20, 21, 22, 23, 57, 58, 11, 12, 13, 65, 16, 27, 
           28, 41, 42, 63, 82, 83, 54, 55, 56, 59, 60, 94, 66, 98, 103, 105)

### Create subgroups and compute percentage of significant results
sub.TFCBT <- subset(df, df$ID %in% TFCBT)
pubbias.TFCBT <- round(colMeans(sub.TFCBT, na.rm=TRUE)[2:5], 3)

sub.CBT.comb <- subset(df, df$ID %in% CBT.comb)
pubbias.CBT.comb <- round(colMeans(sub.CBT.comb, na.rm=TRUE)[2:5], 3)

sub.EMDR <- subset(df, df$ID %in% EMDR)
pubbias.EMDR <- round(colMeans(sub.EMDR, na.rm=TRUE)[2:5], 3)

sub.comb <- subset(df, df$ID %in% comb)
pubbias.comb <- round(colMeans(sub.comb, na.rm=TRUE)[2:5], 3)

sub.treat <- subset(df, df$ID %in% treat)
pubbias.treat <- round(colMeans(sub.treat, na.rm=TRUE)[2:5], 3)

pubbias.sub <- round(rbind(pubbias.TFCBT, pubbias.CBT.comb, pubbias.EMDR, pubbias.comb, pubbias.treat)*100, 1)
# write.csv(pubbias.sub, file="pubbias.sub.csv")

################################################################################
################################################################################

### Test of no effect
ma.sig <- res1$pval.ma < 0.05
sum(ma.sig == TRUE) # Total number signifcant results
round(mean(ma.sig)*100, 1) # Percentage significant results

trim.sig <- res5$pval.trim < 0.05
sum(trim.sig == TRUE) # Total number signifcant results
round(mean(trim.sig)*100, 1) # Percentage significant results

pp.sig <- res3$pval.pp < 0.05
sum(pp.sig == TRUE) # Total number signifcant results
round(mean(pp.sig)*100, 1) # Percentage significant results

puni.sig <- res2$pval.pu < 0.05
sum(is.na(puni.sig) == FALSE) # Data sets where p-uniform could be applied
sum(puni.sig == TRUE, na.rm = TRUE) # Total number signifcant results
round(mean(puni.sig, na.rm = TRUE)*100, 1) # Percentage significant results

sel.sig <- res8$pval.sel < 0.05
sum(is.na(sel.sig) == FALSE) # Data sets where selection model approach converged
sum(sel.sig == TRUE, na.rm = TRUE) # Total number signifcant results
round(mean(sel.sig, na.rm = TRUE)*100, 1) # Percentage significant results

### Create 2x2 tables and compute Loevinger's H for test of no effect
### Trim and fill and meta-analysis
ftable(trim.sig, ma.sig)
round(LoevH(ftable(trim.sig, ma.sig)), 3)

### PET-PEESE and meta-analysis
ftable(pp.sig, ma.sig)
round(LoevH(ftable(pp.sig, ma.sig)), 3)

### P-uniform and meta-analysis
sub <- subset(data.frame(puni.sig, ma.sig), is.na(puni.sig) == FALSE)
ftable(sub$puni.sig, sub$ma.sig)
round(LoevH(ftable(sub$puni.sig, sub$ma.sig)), 3)

### Trim and fill and PET-PEESE
ftable(pp.sig, trim.sig)
round(LoevH(ftable(trim.sig, pp.sig)), 3)

### Trim and fill and P-uniform
sub <- subset(data.frame(puni.sig, trim.sig), is.na(puni.sig) == FALSE)
ftable(sub$puni.sig, sub$trim.sig)
round(LoevH(ftable(sub$puni.sig, sub$trim.sig)), 3)

### PET-PEESE and P-uniform
sub <- subset(data.frame(puni.sig, pp.sig), is.na(puni.sig) == FALSE)
ftable(sub$puni.sig, sub$pp.sig)
round(LoevH(ftable(sub$puni.sig, sub$pp.sig)), 3)

### Selection model approach and meta-analysis
sub <- subset(data.frame(sel.sig, ma.sig), is.na(sel.sig) == FALSE)
ftable(sub$sel.sig, sub$ma.sig)
round(LoevH(ftable(sub$sel.sig, sub$ma.sig)), 3)

### Selection model approach and trim and fill
sub <- subset(data.frame(sel.sig, trim.sig), is.na(sel.sig) == FALSE)
ftable(sub$sel.sig, sub$trim.sig)
round(LoevH(ftable(sub$sel.sig, sub$trim.sig)), 3)

### Selection model approach and PET-PEESE
sub <- subset(data.frame(sel.sig, pp.sig), is.na(sel.sig) == FALSE)
ftable(sub$sel.sig, sub$pp.sig)
round(LoevH(ftable(sub$sel.sig, sub$pp.sig)), 3)

### Selection model approach and p-uniform
sub <- subset(data.frame(sel.sig, puni.sig), is.na(sel.sig) == FALSE & is.na(puni.sig) == FALSE)
ftable(sub$sel.sig, sub$puni.sig)
round(LoevH(ftable(sub$sel.sig, sub$puni.sig)), 3)

################################################################################

### Compute how often null hypothesis of no effect is rejected per subgroup
df <- data.frame(ID=res1$ID, ma.sig, trim.sig, pp.sig, puni.sig, sel.sig) # Create data frame with IDs and outcomes

### Create subgroups and compute percentage of significant results
sub.TFCBT <- subset(df, df$ID %in% TFCBT)
null.TFCBT <- round(colMeans(sub.TFCBT, na.rm=TRUE)[2:6], 3)
round(sum(sub.TFCBT$ma.sig == FALSE & sub.TFCBT$trim.sig == TRUE)/nrow(sub.TFCBT)*100, 1) # Nsig-sig trim and fill
round(sum(sub.TFCBT$ma.sig == TRUE & sub.TFCBT$trim.sig == FALSE)/nrow(sub.TFCBT)*100, 1) # Sig-nsig trim and fill
round(sum(sub.TFCBT$ma.sig == FALSE & sub.TFCBT$pp.sig == TRUE)/nrow(sub.TFCBT)*100, 1) # Nsig-sig PET-PEESE
round(sum(sub.TFCBT$ma.sig == TRUE & sub.TFCBT$pp.sig == FALSE)/nrow(sub.TFCBT)*100, 1) # Sig-nsig PET-PEESE
round(sum(sub.TFCBT$ma.sig == FALSE & sub.TFCBT$puni.sig == TRUE, na.rm = TRUE)/nrow(sub.TFCBT)*100, 1) # Nsig-sig p-uniform
round(sum(sub.TFCBT$ma.sig == TRUE & sub.TFCBT$puni.sig == FALSE, na.rm = TRUE)/nrow(sub.TFCBT)*100, 1) # Sig-nsig p-uniform
round(sum(sub.TFCBT$ma.sig == FALSE & sub.TFCBT$sel.sig == TRUE, na.rm = TRUE)/nrow(sub.TFCBT)*100, 1) # Nsig-sig sel model
round(sum(sub.TFCBT$ma.sig == TRUE & sub.TFCBT$sel.sig == FALSE, na.rm = TRUE)/nrow(sub.TFCBT)*100, 1) # Sig-nsig sel model

sub.CBT.comb <- subset(df, df$ID %in% CBT.comb)
null.CBT.comb <- round(colMeans(sub.CBT.comb, na.rm=TRUE)[2:6], 3)
round(sum(sub.CBT.comb$ma.sig == FALSE & sub.CBT.comb$trim.sig == TRUE)/nrow(sub.CBT.comb)*100, 1) # Nsig-sig trim and fill
round(sum(sub.CBT.comb$ma.sig == TRUE & sub.CBT.comb$trim.sig == FALSE)/nrow(sub.CBT.comb)*100, 1) # Sig-nsig trim and fill
round(sum(sub.CBT.comb$ma.sig == FALSE & sub.CBT.comb$pp.sig == TRUE)/nrow(sub.CBT.comb)*100, 1) # Nsig-sig PET-PEESE
round(sum(sub.CBT.comb$ma.sig == TRUE & sub.CBT.comb$pp.sig == FALSE)/nrow(sub.CBT.comb)*100, 1) # Sig-nsig PET-PEESE
round(sum(sub.CBT.comb$ma.sig == FALSE & sub.CBT.comb$puni.sig == TRUE, na.rm = TRUE)/nrow(sub.CBT.comb)*100, 1) # Nsig-sig p-uniform
round(sum(sub.CBT.comb$ma.sig == TRUE & sub.CBT.comb$puni.sig == FALSE, na.rm = TRUE)/nrow(sub.CBT.comb)*100, 1) # Sig-nsig p-uniform
round(sum(sub.CBT.comb$ma.sig == FALSE & sub.CBT.comb$sel.sig == TRUE, na.rm = TRUE)/nrow(sub.CBT.comb)*100, 1) # Nsig-sig sel model
round(sum(sub.CBT.comb$ma.sig == TRUE & sub.CBT.comb$sel.sig == FALSE, na.rm = TRUE)/nrow(sub.CBT.comb)*100, 1) # Sig-nsig sel model

sub.EMDR <- subset(df, df$ID %in% EMDR)
null.EMDR <- round(colMeans(sub.EMDR, na.rm=TRUE)[2:6], 3)
round(sum(sub.EMDR$ma.sig == FALSE & sub.EMDR$trim.sig == TRUE)/nrow(sub.EMDR)*100, 1) # Nsig-sig trim and fill
round(sum(sub.EMDR$ma.sig == TRUE & sub.EMDR$trim.sig == FALSE)/nrow(sub.EMDR)*100, 1) # Sig-nsig trim and fill
round(sum(sub.EMDR$ma.sig == FALSE & sub.EMDR$pp.sig == TRUE)/nrow(sub.EMDR)*100, 1) # Nsig-sig PET-PEESE
round(sum(sub.EMDR$ma.sig == TRUE & sub.EMDR$pp.sig == FALSE)/nrow(sub.EMDR)*100, 1) # Sig-nsig PET-PEESE
round(sum(sub.EMDR$ma.sig == FALSE & sub.EMDR$puni.sig == TRUE, na.rm = TRUE)/nrow(sub.EMDR)*100, 1) # Nsig-sig p-uniform
round(sum(sub.EMDR$ma.sig == TRUE & sub.EMDR$puni.sig == FALSE, na.rm = TRUE)/nrow(sub.EMDR)*100, 1) # Sig-nsig p-uniform
round(sum(sub.EMDR$ma.sig == FALSE & sub.EMDR$sel.sig == TRUE, na.rm = TRUE)/nrow(sub.EMDR)*100, 1) # Nsig-sig sel model
round(sum(sub.EMDR$ma.sig == TRUE & sub.EMDR$sel.sig == FALSE, na.rm = TRUE)/nrow(sub.EMDR)*100, 1) # Sig-nsig sel model

sub.comb <- subset(df, df$ID %in% comb)
null.comb <- round(colMeans(sub.comb, na.rm=TRUE)[2:6], 3)
round(sum(sub.comb$ma.sig == FALSE & sub.comb$trim.sig == TRUE)/nrow(sub.comb)*100, 1) # Nsig-sig trim and fill
round(sum(sub.comb$ma.sig == TRUE & sub.comb$trim.sig == FALSE)/nrow(sub.comb)*100, 1) # Sig-nsig trim and fill
round(sum(sub.comb$ma.sig == FALSE & sub.comb$pp.sig == TRUE)/nrow(sub.comb)*100, 1) # Nsig-sig PET-PEESE
round(sum(sub.comb$ma.sig == TRUE & sub.comb$pp.sig == FALSE)/nrow(sub.comb)*100, 1) # Sig-nsig PET-PEESE
round(sum(sub.comb$ma.sig == FALSE & sub.comb$puni.sig == TRUE, na.rm = TRUE)/nrow(sub.comb)*100, 1) # Nsig-sig p-uniform
round(sum(sub.comb$ma.sig == TRUE & sub.comb$puni.sig == FALSE, na.rm = TRUE)/nrow(sub.comb)*100, 1) # Sig-nsig p-uniform
round(sum(sub.comb$ma.sig == FALSE & sub.comb$sel.sig == TRUE, na.rm = TRUE)/nrow(sub.comb)*100, 1) # Nsig-sig sel model
round(sum(sub.comb$ma.sig == TRUE & sub.comb$sel.sig == FALSE, na.rm = TRUE)/nrow(sub.comb)*100, 1) # Sig-nsig sel model

sub.treat <- subset(df, df$ID %in% treat)
null.treat <- round(colMeans(sub.treat, na.rm=TRUE)[2:6], 3)
round(sum(sub.treat$ma.sig == FALSE & sub.treat$trim.sig == TRUE)/nrow(sub.treat)*100, 1) # Nsig-sig trim and fill
round(sum(sub.treat$ma.sig == TRUE & sub.treat$trim.sig == FALSE)/nrow(sub.treat)*100, 1) # Sig-nsig trim and fill
round(sum(sub.treat$ma.sig == FALSE & sub.treat$pp.sig == TRUE)/nrow(sub.treat)*100, 1) # Nsig-sig PET-PEESE
round(sum(sub.treat$ma.sig == TRUE & sub.treat$pp.sig == FALSE)/nrow(sub.treat)*100, 1) # Sig-nsig PET-PEESE
round(sum(sub.treat$ma.sig == FALSE & sub.treat$puni.sig == TRUE, na.rm = TRUE)/nrow(sub.treat)*100, 1) # Nsig-sig p-uniform
round(sum(sub.treat$ma.sig == TRUE & sub.treat$puni.sig == FALSE, na.rm = TRUE)/nrow(sub.treat)*100, 1) # Sig-nsig p-uniform
round(sum(sub.treat$ma.sig == FALSE & sub.treat$sel.sig == TRUE, na.rm = TRUE)/nrow(sub.treat)*100, 1) # Nsig-sig sel model
round(sum(sub.treat$ma.sig == TRUE & sub.treat$sel.sig == FALSE, na.rm = TRUE)/nrow(sub.treat)*100, 1) # Sig-nsig sel model

null.sub <- round(rbind(null.TFCBT, null.CBT.comb, null.EMDR, null.comb, null.treat)*100,1)
# write.csv(null.sub, file="null.sub.csv")

################################################################################
################################################################################

### Compute effect size estimates based on Cohen's d

### Effect size measures used in each meta-analysis. Note index is here absolute 
# position in the data and NOT ID
### Relative risks
lrrs <- c(2, 6, 10, 13, 14, 15, 16, 17, 18, 20, 21, 23, 24, 27, 29)

### Relative risks transformed to log odds ratios and log odds ratios
### Vector is used for transforming meta-analytic results to Cohen's d
lors <- c(2, 6, 10, 13, 14, 15, 16, 17, 18, 20, 21, 23, 24, 27, 29, 64, 65)

### Hedges' g that could not be transformed to Cohen's d and Cohen's d plus 
# excluded meta-analysis (ID = 77)
gs.ds.lors <- c(1, 3, 4, 5, 7, 8, 9, 11, 12, 19, 22, 25, 26, 28, 32:42, 45:53, 
                61, 62, 64, 65, 66, 67, 68, 76, 80, 96, 97, 98) 

### Studies that used Hedges' g and could be transformed to Cohen's d
ds <- c(30, 31, 43, 44, 54, 55, 56, 57, 58, 59, 60, 63, 69, 70, 71, 72, 73, 74, 75,
        77, 78, 79, 81:95)

# di.meta <- wid.meta <- di.puni <- wid.puni <- di.puni.0 <- di.pp <- wid.pp <- 
#   di.trim <- wid.trim <- di.sel <- wid.sel <- numeric(length(dat)) # Empty objects for storing results

di.meta <- di.puni <- di.puni.0 <- di.pp <- di.trim <- di.sel <- numeric(length(dat)) # Empty objects for storing results

for (i in 1:length(dat)) {
  
  if (i %in% lrrs) { # Conduct meta-analysis on log odds
    yi <- dat[[i]]$log.or[!is.na(dat[[i]]$yi)]
    sei <- dat[[i]]$log.or.sei[!is.na(dat[[i]]$yi)]
  } else if (i %in% gs.ds.lors) { # Conduct meta-analysis on Hedges' g, Cohen's d, 
    # or studies that used log odds as effect size
    yi <- dat[[i]]$yi[!is.na(dat[[i]]$yi)]
    sei <- dat[[i]]$sei[!is.na(dat[[i]]$yi)]
  } else if (i %in% ds) {
    yi <- dat[[i]]$di[!is.na(dat[[i]]$yi)]
    sei <- dat[[i]]$sei.d[!is.na(dat[[i]]$yi)]
  }
  
  #####################
  ### META-ANALYSIS ###
  #####################
  
  if (i == 80) { tmp <- rma(yi = yi, sei = sei, weights = dat[[i]]$EG.N+dat[[i]]$CG.N, method = "FE") 
  } else { tmp <- rma(yi = yi, sei = sei, method = method[i]) } # MA with DL as estimator for tau^2 or fixed-effect MA
  
  pval.right <- sum(pnorm(yi/sei, lower.tail = FALSE) < alpha/2) # Number of significant p-values in right tail
  pval.left <- sum(pnorm(yi/sei) < alpha/2) # Number of significant p-values in left tail
  
  if (i %in% lors) { # Transform estimate to Cohen's d if log odds ratio was used
    di.meta[i] <- tmp$b[1]*(sqrt(3)/pi)
    # wid.meta[i] <- (tmp$ci.ub-tmp$ci.lb)*(sqrt(3)/pi)
  } else {
    di.meta[i] <- tmp$b[1]
    # wid.meta[i] <- tmp$ci.ub-tmp$ci.lb
  }
  
  #################
  ### P-UNIFORM ###
  #################
  
  ### Apply p-uniform if there are statistically significant studies
  if (pval.left > 0 | pval.right > 0) {
    if (pval.right > pval.left) { # If most significant p-values are in the right tail
      side <- "right"
      pvals <- pnorm(yi/sei, lower.tail = FALSE)
    } else { # If most significant p-values are in the left tail
      side <- "left" 
      pvals <- pnorm(yi/sei)
    }
    
    tmp2 <- puniform(yi = yi, vi = sei^2, side = side, alpha = alpha, method = "P", plot = FALSE) # Apply p-uniform
    
    if (i %in% lors) { # Transform estimate to Cohen's d if log odds ratio was used
      di.puni[i] <- tmp2$est*(sqrt(3)/pi)
      # wid.puni[i] <- (tmp2$ci.ub-tmp2$ci.lb)*(sqrt(3)/pi)
    } else {
      di.puni[i] <- tmp2$est
      # wid.puni[i] <- tmp2$ci.ub-tmp2$ci.lb
    }
    
    # If average of statistically significant p-values is larger than alpha/4, 
    # set estimate equal to 0 (recommendation in Van Aert et al. [in press])
    di.puni.0[i] <- ifelse(mean(pvals[pvals < alpha/2]) > alpha/4, 0, di.puni[i])
    
  } else { # If there are no statistically significant studies return NA
    di.puni[i] <- NA
    di.puni.0[i] <- NA
    # wid.puni[i] <- NA
  }
  
  #################
  ### PET-PEESE ###
  #################
  
  tmp3 <- petpeese(yi = yi, vi = sei^2, ma.est = tmp$b[1])
  ### Store results of PET-PEESE
  if (i %in% lors) { # Transform estimate to Cohen's d if log odds ratio was used
    di.pp[i] <- tmp3$est*(sqrt(3)/pi)
    # wid.pp[i] <- (tmp3$ci.ub-tmp3$ci.lb)*(sqrt(3)/pi)
  } else {
    di.pp[i] <- tmp3$est
    # wid.pp[i] <- (tmp3$ci.ub-tmp3$ci.lb)
  }
  
  #####################
  ### TRIM AND FILL ###
  #####################
  
  tmp5 <- trimfill(tmp)
  ### Store results of trim and fill
  if (i %in% lors) { # Transform estimate to Cohen's d if log odds ratio was used
    di.trim[i] <- tmp5$b[1]*(sqrt(3)/pi)
    # wid.trim[i] <- (tmp5$ci.ub-tmp5$ci.lb)*(sqrt(3)/pi)
  } else {
    di.trim[i] <- tmp5$b[1]
    # wid.trim[i] <- tmp5$ci.ub-tmp5$ci.lb
  }
  
  ################################
  ### SELECTION MODEL APPROACH ###
  ################################
  
  if (di.meta[i] > 0)
  {
    tmp6 <- try(weightfunct(effect = yi, v = sei^2))
  } else if (di.meta[i] < 0)
  {
    tmp6 <- try(weightfunct(effect = yi, v = sei^2, steps = c(0.975, 1)))
  }
  
  if (class(tmp6) == "try-error")
  { # If method cannot be applied, return NA
    di.sel[i] <- NA
  } else
  { 
    if (i %in% lors) { # Transform LORs or LRRs to ORs or RRs
      di.sel[i] <- tmp6$adj_est[2]*(sqrt(3)/pi)
      # wid.sel[i] <- (tmp.sel[6]-tmp.sel[5])*(sqrt(3)/pi)
    } else {
      di.sel[i] <- tmp6$adj_est[2]
      # wid.sel[i] <- tmp.sel[6]-tmp.sel[5]
    }
  }
  
}

res9 <- data.frame(ID=ID, di.meta=di.meta, di.puni=di.puni, di.puni.0=di.puni.0,
                   di.pp=di.pp, di.trim=di.trim, di.sel=di.sel,  
                   pval.left=res1$pval.left, pval.right=res1$pval.right)

res9 <- res9[-76, ] # Exclude meta-analysis with ID = 77 because transformation to Cohen's d was not possible

################################################################################

### Compute difference between publication bias methods and meta-analysis
round(mean(res9$di.pp-res9$di.meta), 3) # Average of Difference between PET-PEESE and meta-analysis
round(median(res9$di.pp-res9$di.meta), 3) # Median of Difference between PET-PEESE and meta-analysis
round(sd(res9$di.pp-res9$di.meta), 3)
round(mean(res9$di.trim-res9$di.meta), 3) # Average of Difference between trim-and-fill and meta-analysis
round(median(res9$di.trim-res9$di.meta), 3) # Median of Difference between trim-and-fill and meta-analysis
round(sd(res9$di.trim-res9$di.meta), 3)

sub.res9 <- subset(res9, is.na(res9$di.sel) == FALSE) # Subset of studies where selection model approach converged
round(mean(sub.res9$di.sel-sub.res9$di.meta), 3) # Average of Difference between selection model approach and meta-analysis
round(median(sub.res9$di.sel-sub.res9$di.meta), 3) # Median of Difference between selection model approach and meta-analysis
round(sd(sub.res9$di.sel-sub.res9$di.meta), 3)

sub.res9 <- subset(res9, is.na(res9$di.puni) == FALSE) # Subset of studies with statistically significant studies
round(mean(sub.res9$di.pp-sub.res9$di.meta), 3) # Average of Difference between PET-PEESE and meta-analysis
round(median(sub.res9$di.pp-sub.res9$di.meta), 3) # Median of Difference between PET-PEESE and meta-analysis
round(sd(sub.res9$di.pp-sub.res9$di.meta), 3)
round(mean(sub.res9$di.trim-sub.res9$di.meta), 3) # Average of Difference between trim-and-fill and meta-analysis
round(median(sub.res9$di.trim-sub.res9$di.meta), 3) # Median of Difference between trim-and-fill and meta-analysis
round(sd(sub.res9$di.trim-sub.res9$di.meta), 3)
round(mean(sub.res9$di.puni-sub.res9$di.meta), 3) # Average of Difference between p-uniform and meta-analysis
round(median(sub.res9$di.puni-sub.res9$di.meta), 3) # Median of Difference between p-uniform and meta-analysis
round(sd(sub.res9$di.puni-sub.res9$di.meta), 3)
round(mean(sub.res9$di.sel-sub.res9$di.meta), 3) # Average of Difference between selection model approach and meta-analysis
round(median(sub.res9$di.sel-sub.res9$di.meta), 3) # Median of Difference between selection model approach and meta-analysis
round(sd(sub.res9$di.sel-sub.res9$di.meta), 3)

round(mean(sub.res9$di.puni.0-sub.res9$di.meta), 3) # Average of Difference between p-uniform with set equal to 0 and meta-analysis
round(median(sub.res9$di.puni.0-sub.res9$di.meta), 3) # Median of Difference between p-uniform with set equal to 0 and meta-analysis
round(sd(sub.res9$di.puni.0-sub.res9$di.meta), 3) 

summary(ifelse(sub.res9$pval.right > 0, sub.res9$pval.right, sub.res9$pval.left)) # Compute median number significant studies
sum(ifelse(sub.res9$pval.right > 0, sub.res9$pval.right, sub.res9$pval.left) <= 3) # p-uniform based on at most three studies

sum(sub.res9$di.puni.0 == 0) # How often estimate of p-uniform was set equal to zero

################################################################################

### Compute differences in effect size estimates per subgroup
df <- data.frame(ID=res9$ID, trim=res9$di.trim-res9$di.meta, pp=res9$di.pp-res9$di.meta,
                 puni=res9$di.puni-res9$di.meta, puni.0=res9$di.puni.0-res9$di.meta, 
                 sel=res9$di.sel-res9$di.meta) # Create data frame with IDs and outcomes

### Create subgroups and compute percentage of significant results
sub.TFCBT <- subset(df, df$ID %in% TFCBT)
est.TFCBT <- round(colMeans(sub.TFCBT, na.rm=TRUE)[2:6], 3)
med.TFCBT <- round(apply(sub.TFCBT, 2, median, na.rm=TRUE)[2:6], 3)
sd.TFCBT <- round(apply(sub.TFCBT, 2, sd, na.rm=TRUE)[2:6], 3)

sub.CBT.comb <- subset(df, df$ID %in% CBT.comb)
est.CBT.comb <- round(colMeans(sub.CBT.comb, na.rm=TRUE)[2:6], 3)
med.CBT.comb <- round(apply(sub.CBT.comb, 2, median, na.rm=TRUE)[2:6], 3)
sd.CBT.comb <- round(apply(sub.CBT.comb, 2, sd, na.rm=TRUE)[2:6], 3)

sub.EMDR <- subset(df, df$ID %in% EMDR)
est.EMDR <- round(colMeans(sub.EMDR, na.rm=TRUE)[2:6], 3)
med.EMDR <- round(apply(sub.EMDR, 2, median, na.rm=TRUE)[2:6], 3)
sd.EMDR <- round(apply(sub.EMDR, 2, sd, na.rm=TRUE)[2:6], 3)

sub.comb <- subset(df, df$ID %in% comb)
est.comb <- round(colMeans(sub.comb, na.rm=TRUE)[2:6], 3)
med.comb <- round(apply(sub.comb, 2, median, na.rm=TRUE)[2:6], 3)
sd.comb <- round(apply(sub.comb, 2, sd, na.rm=TRUE)[2:6], 3)

sub.treat <- subset(df, df$ID %in% treat)
est.treat <- round(colMeans(sub.treat, na.rm=TRUE)[2:6], 3)
med.treat <- round(apply(sub.treat, 2, median, na.rm=TRUE)[2:6], 3)
sd.treat <- round(apply(sub.treat, 2, sd, na.rm=TRUE)[2:6], 3)

est.sub <- rbind(est.TFCBT, med.TFCBT, sd.TFCBT, est.CBT.comb, med.CBT.comb,
                 sd.CBT.comb, est.EMDR, med.EMDR, sd.EMDR, est.comb, med.comb,
                 sd.comb, est.treat, med.treat, sd.treat)

### Create table for subgroups
tab.es.sub <- matrix(NA, nrow = 5, ncol = 5, dimnames = list(c("TFCBT", "CBT", 
                                                               "EMDR", "Combined", "Treatment"), 
                                                             c("Trim", "PET", "puni", "puni.0", 
                                                               "Sel.model")))

for (i in 1:length(est.TFCBT))
{
  tab.es.sub[1,i] <- paste(est.TFCBT[i], ", Mdn=", med.TFCBT[i], ", (SD=", sd.TFCBT[i], ")", sep="")
  tab.es.sub[2,i] <- paste(est.CBT.comb[i], ", Mdn=", med.CBT.comb[i], ", (SD=", sd.CBT.comb[i], ")", sep="")
  tab.es.sub[3,i] <- paste(est.EMDR[i], ", Mdn=", med.EMDR[i], ", (SD=", sd.EMDR[i], ")", sep="")
  tab.es.sub[4,i] <- paste(est.comb[i], ", Mdn=", med.comb[i], ", (SD=", sd.comb[i], ")", sep="")
  tab.es.sub[5,i] <- paste(est.treat[i], ", Mdn=", med.treat[i], ", (SD=", sd.treat[i], ")", sep="")
}

# write.csv(tab.es.sub, file="tab.es.sub.csv")

################################################################################

### Compute summary statistics of estimates corrected for publication bias 

### Number of positive and negative meta-analytic estimates
sum(res9$di.meta > 0)
sum(res9$di.meta < 0)

### How often p-uniform could be applied
sum(!is.na(res9$di.puni))

### How often selection model approach did not converge
sum(is.na(res9$di.sel))

### Multiply estimates of all methods by -1 if di.meta is negative
di.meta.pos <- ifelse(res9$di.meta < 0, res9$di.meta * -1, res9$di.meta)
di.puni.pos <- ifelse(res9$di.meta < 0, res9$di.puni * -1, res9$di.puni)
di.puni.0.pos <- ifelse(res9$di.meta < 0, res9$di.puni.0 * -1, res9$di.puni.0)
di.pp.pos <- ifelse(res9$di.meta < 0, res9$di.pp * -1, res9$di.pp)
di.trim.pos <- ifelse(res9$di.meta < 0, res9$di.trim * -1, res9$di.trim)
di.sel.pos <- ifelse(res9$di.meta < 0, res9$di.sel * -1, res9$di.sel)

tab.es <- matrix(NA, nrow = 5, ncol = 2, 
                 dimnames = list(c("MA", "Trim", "PP", "p-uniform", "sel. model"), 
                                 c("Mean", "Min")))

tmp <- round(summary(di.meta.pos), 3)
tmp.sd <- round(sd(di.meta.pos), 3)
tab.es["MA", "Mean"] <- paste(tmp[4], ", ", tmp[3], sep = "")
tab.es["MA", "Min"] <- paste("[", tmp[1], ";", tmp[6], "], ", "(", tmp.sd, ")", sep="")

tmp <- round(summary(di.trim.pos), 3)
tmp.sd <- round(sd(di.trim.pos), 3)
tab.es["Trim", "Mean"] <- paste(tmp[4], ", ", tmp[3], sep = "")
tab.es["Trim", "Min"] <- paste("[", tmp[1], ";", tmp[6], "], ", "(", tmp.sd, ")", sep="")

tmp <- round(summary(di.pp.pos), 3)
tmp.sd <- round(sd(di.pp.pos), 3)
tab.es["PP", "Mean"] <- paste(tmp[4], ", ", tmp[3], sep = "")
tab.es["PP", "Min"] <- paste("[", tmp[1], ";", tmp[6], "], ", "(", tmp.sd, ")", sep="")

tmp <- round(summary(di.puni.pos), 3)
tmp.sd <- round(sd(di.puni.pos, na.rm = TRUE), 3)
tab.es["p-uniform", "Mean"] <- paste(tmp[4], ", ", tmp[3], sep = "")
tab.es["p-uniform", "Min"] <- paste("[", tmp[1], ";", tmp[6], "], ", "(", tmp.sd, ")", sep="")

tmp <- round(summary(di.sel.pos), 3)
tmp.sd <- round(sd(di.sel.pos, na.rm = TRUE), 3)
tab.es["sel. model", "Mean"] <- paste(tmp[4], ", ", tmp[3], sep = "")
tab.es["sel. model", "Min"] <- paste("[", tmp[1], ";", tmp[6], "], ", "(", tmp.sd, ")", sep="")

# write.csv(tab.es, file="C:/Dropbox/Werk/Onderzoek/Papers/Paper Helen/R3/tab.es.csv")