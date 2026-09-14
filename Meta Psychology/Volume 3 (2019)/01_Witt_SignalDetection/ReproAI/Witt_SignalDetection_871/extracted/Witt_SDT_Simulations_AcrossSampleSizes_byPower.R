##
## Jessica K. Witt - Colorado State University - Psychology
##
## November 15, 2017 (last revised 3/28/18)
##
## Uses signal detection theory techniques to compare and contrast
## across different criteria for statistical significance
##
## Criterion are: (1) p < .05; (2) Bayes Factor > 3; etc...
##
## Hit = data were modeled as a real effect (Cohen's d > 0) and 
##       criteria indicates the effect is significant (e.g. p < .05)
## False alarm = data were modeled as a null effect (Cohen's d = 0) and 
##       criteria indicates the effect is significant (e.g. p < .05)
##
## Strategy: Simulate means from two groups and compute relevant statistics
## Mean for group 1 is .5 (as in 50% on a memory test)
## Mean for group 2 is a function of the specified effect size
##
## Two outcome measures:
##  (1) Area under the curve (AUC) - measure of discriminability
##  (2) Distance to perfection - Euclidean distance between a given point on the ROC curve and perfect performance (100% hits and 0% false alarms)



setwd("C:/Users/jkwitt/Dropbox/SDT and Stats")


########## Packages #################
require(BayesFactor)
require(pROC)
require(ggplot2)
require(reshape2)
require(pwr)


########## Functions #################

## Assumes 2 groups, so two in mySDs
runSims <- function(sampleSizes, effectSizes, mean1, mySDs, numStudiesNull,numStudiesEff) {
  
  sdPooled <- sqrt((mySDs[1]^2 + mySDs[2]^2) / 2)
  saveSims <- as.data.frame(matrix(0,ncol=7, nrow=length(sampleSizes) * (numStudiesNull+numStudiesEff)))
  colnames(saveSims) <- c("groupNum","modeledD","sampleSize","actualD","t","p","BF")
  sa <- 0
  
  for (i in 1:length(sampleSizes)) {
    N <- sampleSizes[i]
    
    for (j in 1:length(effectSizes)) {
      mean2 <- mean1 - (effectSizes[j] * sdPooled)
      
      numStudies3 <- ifelse(effectSizes[j] == 0, numStudiesNull,numStudiesEff)  #only run a quarter of real effects
      
      for (k in 1:numStudies3) {
        
        #simulate data
        group1 <- rnorm(N,mean1,mySDs[1])
        group2 <- rnorm(N,mean2,mySDs[2])
        
        #run t-test
        if  (mySDs[1]==mySDs[2]) {
          a <- t.test(group2, group1,var.equal=T)
        } else {
          a <- t.test(group2, group1)
        }
        
        #save outcomes
        sa <- sa+1
        saveSims$modeledD[sa] <- effectSizes[j]
        saveSims$sampleSize[sa] <- N
        saveSims$actualD[sa] <- (mean(group1) - mean(group2))/sqrt((sd(group1)^2 + sd(group2)^2)/2)
        
        saveSims$p[sa] <- a$p.value
        saveSims$t[sa] <- a$statistic
        saveSims$BF[sa] <- exp(ttest.tstat(t=a$statistic, n1=N, n2=N, rscale = 0.707)[['bf']])
        
      } #end for k numstudies  
    } #end for j effectSizes
  } #end for i sampleSizes
  
  return(saveSims)
} #end function


#AUC Function
#tips taken from:
#https://www.r-bloggers.com/roc-curves-in-two-lines-of-r-code/

#AUC Function
# Calculates the area under the curve (AUC) for a given set of simulations
plotAUC <- function(saveSims,dt,plotIt,crits,priorOdds) {
  
  auc <- rep(0,2+length(priorOdds))  #auc for p-value and Bayes factor
  
  sg <- c(log(saveSims$p[which(saveSims$modeledD > 0)]),log(saveSims$p[which(saveSims$modeledD == 0)]))
  sf <- c(rep(1,length(which(saveSims$modeledD > 0))),rep(0,length(which(saveSims$modeledD == 0))))
  
  fit_glm <- glm(sf ~ sg, family=binomial(link="logit"))
  glm_response_scores <- predict(fit_glm, data.frame(sg,sf), type="response")
  
  auc[1] <- auc(sf, glm_response_scores)
  
  sg3 <- c(saveSims$actualD[which(saveSims$modeledD > 0)],saveSims$actualD[which(saveSims$modeledD == 0)])
  #  sg3 <- abs(c(saveSims$actualD[which(saveSims$modeledD > 0)],saveSims$actualD[which(saveSims$modeledD == 0)]))
  
  fit_glm3 <- glm(sf ~ sg3, family=binomial(link="logit"))
  glm_response_scores3 <- predict(fit_glm3, data.frame(sg3,sf), type="response")
  
  auc[2] <- auc(sf, glm_response_scores3)
  
  for(ii in 1:length(priorOdds)) {
    sg2 <- c(log(priorOdds[ii] * saveSims$BF[which(saveSims$modeledD > 0)]),log(priorOdds[ii] * saveSims$BF[which(saveSims$modeledD == 0)]))
    fit_glm2 <- glm(sf ~ sg2, family=binomial(link="logit"))
    glm_response_scores2 <- predict(fit_glm2, data.frame(sg2,sf), type="response")
    auc[2 + ii] <- auc(sf, glm_response_scores2)
    
  }
  
  if(plotIt) {  
    tiff("fig2a.tiff",height=500,width=500)
    #    plot(roc(sf, glm_response_scores, direction="<"), col="green", lwd=4)
    plot.roc(sf, glm_response_scores, direction="<",legacy.axes = T, col="green", lwd=4,xlab="False Alarm Rate",ylab="Hit Rate",auc.polygon=T)
    lines(roc(sf, glm_response_scores2, direction="<"), col="blue", lwd=1)
    #lines(roc(sf, glm_response_scores3, direction="<"), col="red", lwd=.5)  #if want to include ROC by effect size
    
    rCol <- rainbow(length(crits))
    dtCol <- rCol[dt$criterion]
    pSz <- ifelse(dt$critCat==1,1.5,.8)+1
    pCH <- ifelse(dt$critCat==1,1,19)
    points(1-(dt$fa/numStudiesNull),dt$hits/numStudiesEff,col=dtCol,pch=19,cex=pSz)
    legend("bottomright",col=rCol,legend = crits,pch=19)
    dev.off()
  } #end if plotIt
  

  
  return(auc)
}  # end function plotAUC





evalSig <- function(critCat,critValue,saveSims,priorOdds) {
  
  effectSizes <- sort(unique(saveSims$modeledD))
  sampleSizes <- sort(unique(saveSims$sampleSize))
  numEffectSizes <- length(effectSizes) - 1
  numCriteria <- length(critCat)
  nc2 <- length(critCat[which(critCat == 1)]) + (length(critCat[which(critCat == 2)]) * length(priorOdds))
  allC <- length(sampleSizes) * numEffectSizes * nc2 
  dt <- as.data.frame(matrix(NA,ncol=14,nrow=allC))
  colnames(dt) <- c("sampleSize","effectSizes","criterion","hits","fa","actEffectSize","criterionF","miss","corrRej","numAmbigEff","numAmbigNull", "ROCdist","critCat","priorOdds")
  da <- 0  #index for dt
  
  for(i in 1:length(sampleSizes)) {
    for(j in 1:numEffectSizes) {
      for (k in 1:numCriteria) {
        
        jj <- j+1  #assumes first effect size is 0, working with next one
        
        if (critCat[k] == 1) {  #p-value
          da <- da+1
          dt$sampleSize[da] <- sampleSizes[i]
          dt$effectSizes[da] <- effectSizes[j+1]
          dt$criterion[da] <- k
          
          dt$hits[da] <- length(which(saveSims$p[which(saveSims$modeledD>0)] <= critValue[k]))
          dt$fa[da] <-length(which(saveSims$p[which(saveSims$modeledD==0)] <= critValue[k]))
          dt$miss[da] <- length(which(saveSims$modeledD > 0)) - dt$hits[da]
          dt$corrRej[da] <- length(which(saveSims$modeledD == 0)) - dt$fa[da]
          dt$criterionF[da] <- paste("p",critValue[k])
          dt$critCat[da] <- 1
        } else {  #Bayes factor
          for (jj in 1:length(priorOdds)) {
            da <- da+1
            dt$sampleSize[da] <- sampleSizes[i]
            dt$effectSizes[da] <- effectSizes[j+1]
            dt$criterion[da] <- k
            
            dt$hits[da] <- length(which(saveSims$BF[which(saveSims$modeledD > 0)]*priorOdds[jj] >= critValue[k]))
            dt$fa[da] <- length(which(saveSims$BF[which(saveSims$modeledD == 0)]*priorOdds[jj] >= critValue[k]))
            dt$miss[da] <- length(which(saveSims$BF[which(saveSims$modeledD > 0)]*priorOdds[jj] <= (1/critValue[k])))
            dt$corrRej[da] <- length(which(saveSims$BF[which(saveSims$modeledD == 0)]*priorOdds[jj] <= (1/critValue[k])))
            dt$numAmbigEff[da] <- length(which(saveSims$BF[which(saveSims$modeledD > 0)]*priorOdds[jj] < critValue[k] & saveSims$BF[which(saveSims$modeledD > 0)]*priorOdds[jj] > (1/critValue[k]) ))
            dt$numAmbigNull[da] <- length(which(saveSims$BF[which(saveSims$modeledD == 0)]*priorOdds[jj] < critValue[k] & saveSims$BF[which(saveSims$modeledD == 0)]*priorOdds[jj] > (1/critValue[k]) ))
            dt$criterionF[da] <- paste("BF",critValue[k])
            dt$critCat[da] <- 2
            dt$priorOdds[da] <- priorOdds[jj]
          }
        } 
        
        h1 <- 1 - (dt$hits[da]/length(which(saveSims$modeledD > 0)))  #vertical distance
        h2 <- dt$fa[da]/length(which(saveSims$modeledD == 0))  #horizDistance
        dt$ROCdist[da] <- sqrt(h1^2 + h2^2)
        
        dt$actEffectSize[da] <- mean(saveSims$actualD[which(saveSims$modeledD > 0)])
        
      }
    }
  }
  
  return(dt)
}



############################
####### Start Code #########
############################


#Num of studies to be run and number of times that number of studies should be run
numStudiesNull <- 10 #for Fig 9,11
numStudiesEff <- 10  #for Fig 9,11
numTimes <- 100 #for Fig 9,11


#Sample sizes and Effect sizes (note: sample size = sample size per group; assumes equal samples per group)
if (1>0) {
#sSizesAll <- seq(32,200,length.out=7)  #for Fig 11
#sSizesAll[length(sSizesAll)+1] <- 2000 #for Fig 11
sSizesAll <- seq(32,2000,length.out=30) #for Fig 9
sSizesAll <- round(sSizesAll)
effSzAll <- rep(.5,length(sSizesAll))
} else {
myPower <- c(50,60,70,seq(80,99)) / 100
myPower <- c(.9,.95,.99)
sSizesAll <- round(myPower)
effSzAll <- rep(.5,length(myPower))
for (i in 1:length(myPower)) {
  ss <- pwr.t.test(n = NULL,d = effSzAll[1],power=myPower[i],type="two.sample",alternative = "two.sided")
  sSizesAll[i] <- round(ss$n,0)
}
}


priorOdds <- c(1)  

#data frame to save sims outcomes
saveSims <- as.data.frame(matrix(0,ncol=7, nrow=1))
colnames(saveSims) <- c("groupNum","modeledD","sampleSize","actualD","t","p","BF")

#data frame to save SDT analyses
allDt <- as.data.frame(matrix(0,ncol=15,nrow=1))
colnames(allDt) <- c("sampleSize","effectSizes","criterion","hits","fa","actEffectSize","criterionF","miss","corrRej","numAmbigEff","numAmbigNull", "ROCdist","critCat","priorOdds","runNum")

#criteria for significance to be used
critCat <- c(1,1,1,1,2,2,2,2) # 1 = p-value; 2 = BF
critValue <- c(.1,.05,.005,.001,1,2,3,10)  #critical value for significance,, aligns with critCat
crits <- c("p<.10","p<.05","p<.005","p<.001","BF>1","BF>2","BF>3","BF>10")  #label not needed for function

#Group mean and SDs
mean1 <- .5
mySDs <- c(.1, .1)

#AUC estimates
if (length(priorOdds) == 1) {
  aa <- 6
  ab <- "aucBF1"
} else {
  aa <- 5+length(priorOdds)
  ab <- rep("BF",length(priorOdds))
  for(i in 1:length(priorOdds)) {
    ab[i] <- paste("aucBF",priorOdds[i],sep="")
  }
}
aucs <- as.data.frame(matrix(0,ncol=aa,nrow=length(sSizesAll)*numTimes))
colnames(aucs) <- c("sampleSize","effectSize","runTime","aucP","aucES",ab)
ai <- 0


###### Loops for Data simulation and SDT calculations ####

for (ssa in 1:length(sSizesAll)) {
  sampleSizes <- sSizesAll[ssa]  

  effectSizes <- c(0,effSzAll[ssa])  #sets first effect size to 0; necessary for SDT analyses
  
  for(i in 1:numTimes) {
    
    ## Run simulations
    ss <- runSims(sampleSizes,effectSizes, mean1, mySDs, numStudiesNull, numStudiesEff)
    ss$groupNum <- i
    saveSims <- rbind(saveSims,ss)
    

    ## Run SDT analyses
    ##critical: Assumes the first effect size is 0
    dt <- evalSig(critCat,critValue,ss,priorOdds)
    dt$runNum <- i
    allDt <- rbind(allDt,dt)
    
    # Plot ROC curves and caculate AUC (if desired)
    plotIt <- FALSE
    currAUC <- plotAUC(ss,dt,plotIt,crits,priorOdds)  
    ai <- ai+1
    aucs[ai,1] <- sampleSizes[1]
    aucs[ai,2] <- effectSizes[2]
    aucs[ai,3] <- i #runNumber
    aucs[ai,4] <- currAUC[1]
    aucs[ai,5] <- currAUC[2]
    for(ii in 1:length(priorOdds)) {
      aucs[ai,5 + ii] <- currAUC[2 + ii]
    }    
    
  } #end for i runTimes
} #end for ssa

allDt <- allDt[-1,]  #get rid of initial dummy row that was just used to init allDt
saveSims <- saveSims[-1,]

######################
###### Analyses ######
######################

cxLab <- 3
cxAxis <- 2
colnames(aucs)[6] <- "aucBF"
readline("stop")


#### Compare AUCs  (Fig 9a) ####
ap <- aggregate(aucP ~ sampleSize + effectSize,aucs,mean)
ap2 <- aggregate(aucBF ~ sampleSize + effectSize,aucs,mean)
tiff("Fig9a.tiff",height=300,width=500)
par(mar=c(5.1,5.1,1.1,1.1))
plot(seq(1:length(sSizesAll)),ap$aucP,col=rainbow(length(sSizesAll),start=0,end=.8),bty="l",ylim=c(.7,1),pch=1,cex=3,xaxt="n",xlab="N",ylab="",cex.axis=1.5)
title(xlab="N (per group)",ylab="Area Under the Curve",cex.lab=2,line=3)
points(seq(1:length(sSizesAll)),ap2$aucBF,col=rainbow(length(sSizesAll),start=0,end=.8),pch=19,cex=2)
la <- c(1,length(sSizesAll)/3,length(sSizesAll)/3*2,length(sSizesAll))
axis(side=1,at=la,labels = sSizesAll[la],cex.axis=1.5)
legend_image <- as.raster(matrix(colfunc(20), ncol=1))
legend("bottomright",pch=c(1,19),pt.cex=c(2,1.5),legend = c("p-values","Bayes factors"),cex=1.5)
dev.off()


#### Compare AUCs by Power ####
ap <- aggregate(aucP ~ sampleSize + effectSize,aucs,mean)
ap$pwr <- myPower    
ap3 <- aggregate(aucP ~ sampleSize + effectSize,aucs,sd)
ap$sd <- ap3$aucP
ap$se <- ap3$aucP / sqrt(length(myPower)*2)
ap2 <- aggregate(aucBF ~ sampleSize + effectSize,aucs,mean)
plot(seq(1:length(sSizesAll)),ap$aucP,col=rainbow(length(sSizesAll),start=0,end=.8),bty="l",ylim=c(.7,1),pch=1,cex=2,xaxt="n",xlab="N (per group)",ylab="Area Under the Curve")
#points(seq(1:length(sSizesAll)),ap2$aucBF,col=rainbow(length(sSizesAll),start=0,end=.8),pch=19)
#legend("bottomleft",pch=c(1,19),pt.cex=c(2,1),legend = c("p-values","Bayes factors"))
la <- c(1,length(sSizesAll)/3,length(sSizesAll)/3*2,length(sSizesAll))
axis(side=1,at=seq(1,length(myPower)),labels = myPower*100)
for (i in 1:length(myPower)) {
  segments(i,ap$aucP[i] - ap$se[i],i,ap$aucP[i] + ap$se[i],lwd=3,col=rainbow(length(myPower),start=0,end=.8)[i])
}

toComp <- which(myPower == .95)
saveOuts <- as.data.frame(matrix(NA,ncol=4,nrow=length(sSizesAll)-toComp))
colnames(saveOuts) <- c("s1","s2","t","p")
for (i in (toComp+1):length(sSizesAll)) {
  mp <- aucs[which(aucs$sampleSize == sSizesAll[toComp] | aucs$sampleSize == sSizesAll[i]),]
  modd <- t.test(mp$aucP[which(mp$sampleSize == sSizesAll[toComp])],mp$aucP[which(mp$sampleSize == sSizesAll[i])])
  saveOuts$s1[i-toComp] <- myPower[toComp]
  saveOuts$s2[i-toComp] <- myPower[i]
  saveOuts$t[i-toComp] <- modd$statistic
  saveOuts$p[i-toComp] <- modd$p.value
}
    plot(saveOuts$s2,saveOuts$p)
    abline(h=.05,col="red")


    
readline("stop here")

#### Plot distance to perfection  (fig 11) ####
aa <- aggregate(ROCdist ~ criterion + sampleSize, data=allDt,mean)
ab <- aggregate(ROCdist ~ criterion + sampleSize, data=allDt,sd)
ab$ci <- qnorm(.975) * ab$ROCdist / sqrt(numStudiesEff + numStudiesNull)
ac <- length(aa$criterion)
ad <- length(unique(aa$criterion))
aa$sampleSize[which(aa$sampleSize == 2000)] <- 250 
pCH <- ifelse(critCat[aa$criterion] == 1,17,19)
tiff("Fig11.tiff",height=500,width=900)
par(mar=c(5.8,5.1,.1,.1))
plot(aa$sampleSize+(2*aa$criterion),aa$ROCdist,bty="l",xaxt="n",xlab="",ylab="",pch=pCH,col=rainbow(length(crits),start=0,end=.8),cex=2,ylim=c(0,1),cex.axis=cxAxis)
title(ylab="Distance to Perfection",cex.lab=cxLab,line=3)
title(xlab="Sample Size (n per group)",cex.lab=cxLab,line=4)
axis(side=1,at=sort(unique(aa$sampleSize)) + length(crits),labels = sSizesAll,cex.axis=cxAxis)
legend("topright",pch=c(rep(17,4),rep(19,4)),col=rainbow(length(crits)),legend = crits,cex=1.5,pt.cex=1.5)
for(i in 1:ac) {
#  segments(aa$sampleSize[i]+(2*aa$criterion[i]),aa$ROCdist[i] - ab$ci[i],aa$sampleSize[i]+(2*aa$criterion[i]),aa$ROCdist[i]+ab$ci[i])
  segments(aa$sampleSize[i]+(2*aa$criterion[i]),aa$ROCdist[i] - ab$ci[i],aa$sampleSize[i]+(2*aa$criterion[i]),aa$ROCdist[i]+ab$ci[i],col=rainbow(length(crits),start=0,end=.8)[aa$criterion[i]])
}

dev.off()

#### Plot Fig 9b,c,d ####
#plot BF vs p-value across sample Size
if (1>0) {
  tiff("Fig9b.tiff",height=500,width=800)
  par(mar=c(5.1,6.1,1.1,.1))
  plot(log(saveSims$p), log(saveSims$BF),bty="l",pch=19,col=rainbow(max(saveSims$sampleSize),start=0,end=.8)[saveSims$sampleSize],xlab="",ylab="",yaxt="n",xaxt="n",ylim=c(-4,5),xlim=c(-10,0),cex.lab=cxLab)
  title(xlab="p Value",ylab="Bayes Factor",cex.lab=cxLab,line=4)
#  title(ylab="Bayes Factor",cex.lab=cxLab,line=3)
  abline(h=log(1))
  abline(v=log(.05))
  ya <- c(.3,1,3,30)
  axis(side=2,at=log(ya),labels = ya,cex.axis=cxAxis,las=1)
  xa <- c(.0000001,.001,.01,.05,.5)
  axis(side=1,at=log(xa),labels = xa,cex.axis=cxAxis)
  legend_image <- as.raster(matrix(rainbow(length(sSizesAll),start=0,end=.8), ncol=1))
  rasterImage(legend_image, log(.2), log(10), log(.5),log(200))
  la <- round(quantile(saveSims$sampleSize,c(0,.333,.6667,1)),0)
  yPos <- rep(NA,4)
  for (i in 1:4) {
    yPos[i] <- min(saveSims$BF[which(saveSims$sampleSize == la[i])])
  }
  par(xpd=NA)
  text(x=log(.55),y=seq(log(10),log(200),l=length(la)), labels=rev(la),adj=c(0,.5),cex=cxAxis)
  par(xpd=T)
  
  # calculate position of inset  [from: https://stackoverflow.com/questions/17041246/how-to-add-an-inset-subplot-to-topright-of-an-r-plot]
  plotdim <- par("plt")
  xleft   = plotdim[1] + (plotdim[2] - plotdim[1]) * 0.05
  xright   = plotdim[1] + (plotdim[2] - plotdim[1]) * 0.40
  ybottom  = plotdim[3] + (plotdim[4] - plotdim[3]) * 0.05  
#  ybottom  = plotdim[3]
  ytop  = plotdim[3] + (plotdim[4] - plotdim[3]) * 0.3  

  # set position for inset
  par(
    fig = c(xleft, xright, ybottom, ytop)
    , mar=c(0,0,0,0)
    , new=TRUE
  )
  
  plot(log(saveSims$p), log(saveSims$BF),bty="l",pch=19,col=rainbow(max(saveSims$sampleSize),start=0,end=.8)[saveSims$sampleSize],xlab="",ylab="",yaxt="n",xaxt="n")
  rect(-10,-4,0,5,lty=2)  #matches xlim and ylim in plot above
  
  dev.off()


  
  saveLM <- as.data.frame(matrix(0,ncol=8,nrow=length(sSizesAll)))
  colnames(saveLM) <- c("N","intercept","slope","rSq","p10","p05","p005","p44")
  
  for (compIndex in 1:length(sSizesAll)) {
    
    ss <- saveSims[which(saveSims$sampleSize == sSizesAll[compIndex]),]
    ty <- lm(log(ss$BF) ~ log(ss$p))
    saveLM[compIndex,1] <- sSizesAll[compIndex]
    saveLM[compIndex,2] <- ty$coefficients[1]
    saveLM[compIndex,3] <- ty$coefficients[2]
    saveLM[compIndex,4] <- summary.lm(ty)$r.squared
    saveLM[compIndex,5] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.1))
    saveLM[compIndex,6] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.05))
    saveLM[compIndex,7] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.005))
    saveLM[compIndex,8] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.44))
    
  } #end for compIndex
  
  #### Plot Fig 9c and d ####
  
  if(1>0) {  #plot results of LM between p and BFs
    
    tiff("Fig9c.tiff",height = 500, width = 800)
    par(mar=c(5.1,6.1,.1,.1))
    plot(saveLM[,1],exp(saveLM[,2]),bty="l",xlab="", ylab="",yaxt="n",cex=4,pch=19,col=rainbow(length(sSizesAll),start=0,end=.8),cex.lab=cxLab,cex.axis=cxAxis)
    title(xlab="N (per group)", ylab="Intercept (as a p-value)",cex.lab=cxLab,line=4)
    axis(side=2,at=c(.05, .10, .15, .20),labels=c(".05",".10",".15",".20"),las=1,cex.axis=cxAxis)
    dev.off()
    
    tiff("Fig9d.tiff",height = 500, width = 800)
    par(mar=c(5.1,6.1,.1,.1))
    plot(saveLM[,1],exp(saveLM[,3]),bty="l",xlab="", ylab="",yaxt="n",cex=4,pch=19,col=rainbow(length(sSizesAll),start=0,end=.8),cex.lab=cxLab,cex.axis=cxAxis)
    title(xlab="N (per group)", ylab="Slope",cex.lab=cxLab,line=4)
    axis(side=2,at=exp(c(-.7, -.8, -.9, -1)),labels=c("-.7","-.8","-.9","-1"),las=1,cex.axis=cxAxis)
    dev.off()

      somePs <- seq(.00001,1,length.out = 1000)
#    plot(log(somePs),saveLM$intercept[1] + saveLM$slope[1]*log(somePs),type="l",bty="l",xlab="p-value",ylab="Bayes factor")
#    for (ipi in 2:length(saveLM[,1])) {
#      lines(log(somePs),saveLM$intercept[ipi] + saveLM$slope[ipi]*log(somePs),col=ipi)
#    }
#    abline(v=log(.05),lwd=2)
#    abline(v=log(.005))
#    abline(h=log(1))
#    legend("topright",lwd=1,col=seq(1:length(saveLM$N)),legend = sort(unique(saveLM$N)))
    
  } #end if 
} #end if plot LM p vs BF (fig 4)



#### Min/Max value plots (Fig 6) ####
n2 <- 20

#for studies modeled as null effect
plot(sampleSizes[1:n2],seq(0,max(1/allBFs[1:n2,1,]),length.out = n2),col="white",bty="l",ylab="1 / Bayes factor",xlab= "N")
for (i in 1:n2) {
  points(rep(sampleSizes[i],1000),1/allBFs[i,1,],col=rainbow(n2,start=0,end=.8)[i])
}

plot(sampleSizes[1:n2],seq(0,1,length.out = n2),col="white",bty="l",ylab="p-value",xlab= "N")
for (i in 1:n2) {
  points(rep(sampleSizes[i],1000),allPs[i,1,],col=rainbow(n2,start=0,end=.8)[i])
}

#for studies modeled as null effect w jitter
plot(sampleSizes[1:n2],seq(0,max(1/allBFs[1:n2,1,]),length.out = n2),col="white",bty="l",ylab="1 / Bayes factor",xlab= "N")
for (i in 1:n2) {
  points(jitter(rep(sampleSizes[i],1000)),1/allBFs[i,1,],col=rainbow(n2,start=0,end=.8)[i],cex=.2)
}

plot(sampleSizes[1:n2],seq(0,1,length.out = n2),col="white",bty="l",ylab="p-value",xlab= "N")
for (i in 1:n2) {
  points(jitter(rep(sampleSizes[i],1000)),allPs[i,1,],col=rainbow(n2,start=0,end=.8)[i], cex=.2)
}


#modeled as real effects
plot(sampleSizes[1:n2],seq(0,max(allBFs[1:n2,2,]),length.out = n2),col="white",bty="l",ylab="Bayes factor",xlab= "N")
for (i in 1:n2) {
  points(rep(sampleSizes[i],1000),allBFs[i,2,],col=rainbow(n2,start=0,end=.8)[i])
}

plot(sampleSizes[1:n2],seq(0,1,length.out = n2),col="white",bty="l",ylab="p-value",xlab= "N")
for (i in 1:n2) {
  points(rep(sampleSizes[i],1000),allPs[i,2,],col=rainbow(n2,start=0,end=.8)[i])
}

#modeled as real effects w jitter
plot(sampleSizes[1:n2],seq(0,max(log(allBFs[1:n2,2,])),length.out = n2),col="white",bty="l",ylab="log(Bayes factor)",xlab= "N")
for (i in 1:n2) {
  points(jitter(rep(sampleSizes[i],1000)),log(allBFs[i,2,]),col=rainbow(n2,start=0,end=.8)[i],cex=.2)
}
abline(h=log(3))

plot(sampleSizes[1:n2],seq(0,1,length.out = n2),col="white",bty="l",ylab="p-value",xlab= "N")
for (i in 1:n2) {
  points(jitter(rep(sampleSizes[i],1000)),allPs[i,2,],col=rainbow(n2,start=0,end=.8)[i],cex=.2)
}



#### Plot All Fig 9 ####

saveLM <- as.data.frame(matrix(0,ncol=8,nrow=length(sSizesAll)))
colnames(saveLM) <- c("N","intercept","slope","rSq","p10","p05","p005","p44")

for (compIndex in 1:length(sSizesAll)) {
  
  ss <- saveSims[which(saveSims$sampleSize == sSizesAll[compIndex]),]
  ty <- lm(log(ss$BF) ~ log(ss$p))
  saveLM[compIndex,1] <- sSizesAll[compIndex]
  saveLM[compIndex,2] <- ty$coefficients[1]
  saveLM[compIndex,3] <- ty$coefficients[2]
  saveLM[compIndex,4] <- summary.lm(ty)$r.squared
  saveLM[compIndex,5] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.1))
  saveLM[compIndex,6] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.05))
  saveLM[compIndex,7] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.005))
  saveLM[compIndex,8] <- exp(ty$coefficients[1] + ty$coefficients[2] * log(.44))
  
} #end for compIndex

tiff("Fig9.tiff",height = 1000, width = 1600)
par(mfrow=c(2,2))
par(mar=c(5.1,6.1,4.1,1.1))

#Panel A
ap <- aggregate(aucP ~ sampleSize + effectSize,aucs,mean)
ap2 <- aggregate(aucBF ~ sampleSize + effectSize,aucs,mean)
plot(seq(1:length(sSizesAll)),ap$aucP,col=rainbow(length(sSizesAll),start=0,end=.8),bty="l",ylim=c(.7,1),pch=1,cex=3.2,xaxt="n",xlab="",ylab="",cex.axis=1.5)
title(xlab="N (per group)",ylab="Area Under the Curve",cex.lab=cxLab,line=3)
points(seq(1:length(sSizesAll)),ap2$aucBF,col=rainbow(length(sSizesAll),start=0,end=.8),pch=19,cex=2)
la <- c(1,length(sSizesAll)/3,length(sSizesAll)/3*2,length(sSizesAll))
axis(side=1,at=la,labels = sSizesAll[la],cex.axis=cxAxis)
legend("bottomright",pch=c(1,19),pt.cex=c(2,1.5),legend = c("p values","Bayes factors"),cex=1.5)
text(-2.3,1.03,"a",cex=4,xpd=NA)


#Panel B
plot(log(saveSims$p), log(saveSims$BF),bty="l",pch=19,col=rainbow(max(saveSims$sampleSize),start=0,end=.8)[saveSims$sampleSize],xlab="",ylab="",yaxt="n",xaxt="n",ylim=c(-4,5),xlim=c(-10,0),cex.lab=cxLab)
text(-11,6,"b",cex=4,xpd=NA)
title(xlab="p Value",ylab="Bayes Factor",cex.lab=cxLab,line=4)
#  title(ylab="Bayes Factor",cex.lab=cxLab,line=3)
abline(h=log(1))
abline(v=log(.05))
ya <- c(.3,1,3,30)
axis(side=2,at=log(ya),labels = ya,cex.axis=cxAxis,las=1)
xa <- c(.0000001,.001,.01,.05,.5)
axis(side=1,at=log(xa),labels = xa,cex.axis=cxAxis)
legend_image <- as.raster(matrix(rainbow(length(sSizesAll),start=0,end=.8), ncol=1))
rasterImage(legend_image, log(.2), log(10), log(.5),log(200))
la <- round(quantile(saveSims$sampleSize,c(0,.333,.6667,1)),0)
yPos <- rep(NA,4)
for (i in 1:4) {
  yPos[i] <- min(saveSims$BF[which(saveSims$sampleSize == la[i])])
}

par(xpd=NA)
text(x=log(.55),y=seq(log(10),log(200),l=length(la)), labels=rev(la),adj=c(0,.5),cex=cxAxis)
par(xpd=T)

#Do Subplot
points(log(saveSims$p)/50 - 6, log(saveSims$BF)/50-4, cex=.5,col = rainbow(max(saveSims$sampleSize),start=0,end=.8)[saveSims$sampleSize])
segments(log(min(saveSims$p))/50-6.2,log(min(saveSims$BF))/50-4.2,log(max(saveSims$p))/50-5.8,log(min(saveSims$BF))/50-4.2)
segments(log(min(saveSims$p))/50-6.2,log(min(saveSims$BF))/50-4.2,log(min(saveSims$p))/50-6.2,log(max(saveSims$BF))/50-3.8)
myRect <- c(-10,-4,0,5) / 50
myRect <- myRect - c(6,4,6,4)
rect(myRect[1],myRect[2],myRect[3],myRect[4],lty=2)  #matches xlim and ylim in plot above




#Panel C
plot(saveLM[,1],exp(saveLM[,2]),bty="l",xlab="", ylab="",yaxt="n",xaxt="n",cex=4,pch=19,col=rainbow(length(sSizesAll),start=0,end=.8),cex.lab=cxLab)
title(xlab="N (per group)", ylab="Intercept (as a p value)",cex.lab=cxLab,line=4)
axis(side=1,at=la,labels=la,cex.axis=cxAxis)
axis(side=2,at=c(.05, .10, .15, .20),labels=c(".05",".10",".15",".20"),las=1,cex.axis=cxAxis)
text(-200,.215,"c",cex=4,xpd=NA)

#Panel D
plot(saveLM[,1],exp(saveLM[,3]),bty="l",xlab="", ylab="",yaxt="n",xaxt="n",cex=4,pch=19,col=rainbow(length(sSizesAll),start=0,end=.8),cex.lab=cxLab)
title(xlab="N (per group)", ylab="Slope",cex.lab=cxLab,line=4)
axis(side=1,at=la,labels=la,cex.axis=cxAxis)
axis(side=2,at=exp(c(-.7, -.8, -.9, -1)),labels=c("-.7","-.8","-.9","-1"),las=1,cex.axis=cxAxis)
text(-200,exp(-.67),"d",cex=4,xpd=NA)


dev.off()
