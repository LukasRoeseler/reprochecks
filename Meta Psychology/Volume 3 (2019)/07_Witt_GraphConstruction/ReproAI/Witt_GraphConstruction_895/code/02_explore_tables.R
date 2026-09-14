options(stringsAsFactors = FALSE)
wrk <- "C:/Users/lroesele.IVV5NET/Claude_Code/ReproAI/Meta Psychology/Volume 3 (2019)/07_Witt_GraphConstruction/ReproAI/Witt_GraphConstruction_895"
condCode <- function(g){
  g <- tolower(as.character(g))
  ifelse(g %in% c("full"), 1L, ifelse(g %in% c("sd"), 2L, ifelse(g %in% c("small","min","minimal"), 3L, NA_integer_)))
}
slopes <- function(dt, excl, dcrit=NULL, centerMode="reg"){
  dt$corr <- ifelse(dt$effectSize == 0, 1, NA)
  dt$corr[which(dt$effectSize == 1)] <- 1.5
  dt$corr[which(dt$effectSize == 3)] <- 2
  dt$corr[which(dt$effectSize == 5)] <- 3
  dt$corr[which(dt$effectSize == 8)] <- 4
  dt$corrCentered <- dt$corr - 2.5
  dt$cond <- condCode(dt$graphType)
  dt <- dt[!is.na(dt$cond),]
  if(!is.null(dcrit)) dt <- dt[dt$effectSize > dcrit,]
  subjs <- sort(setdiff(unique(dt$Subject), excl))
  out <- data.frame()
  for (s in subjs) for (cc in 1:3){
    d <- dt[dt$Subject==s & dt$cond==cc,]
    if(centerMode=="reg"){ m <- lm(resp ~ corrCentered, data=d); i<-coef(m)[1]; b<-coef(m)[2] }
    else { m <- lm(resp ~ scale(corr,scale=FALSE,center=TRUE), data=d); i<-coef(m)[1]; b<-coef(m)[2] }
    out <- rbind(out, data.frame(subj=s,cond=cc,coef=b,intercept=i,bias=(i-2.5)/2.5*100))
  }
  out
}
summ <- function(A){
  m <- aggregate(coef~cond,A,mean); s <- aggregate(coef~cond,A,sd)
  mb <- aggregate(bias~cond,A,mean); sb <- aggregate(bias~cond,A,sd)
  list(A=paste(round(m$coef,2),"(",round(s$coef,2),")",collapse=" / "),
       B=paste(round(mb$bias,0),"(",round(sb$bias,0),")",collapse=" / "))
}

cat("======== EXP1 ========\n")
d1 <- read.csv(file.path(wrk,"data","axisSize 1-24.csv"))
colnames(d1)[which(colnames(d1)=="axisRange")] <- "graphType"
d1 <- d1[d1$Subject<10,]
cat("excl 1,8 (paper): ", summ(slopes(d1,c(1,8)))$A, " bias:", summ(slopes(d1,c(1,8)))$B, "\n")
cat("excl none:        ", summ(slopes(d1,c()))$A, " bias:", summ(slopes(d1,c()))$B, "\n")
cat("excl 1 only:      ", summ(slopes(d1,c(1)))$A, "\n")
cat("excl 8 only:      ", summ(slopes(d1,c(8)))$A, "\n")

cat("\n======== EXP3 ========\n")
d3 <- read.csv(file.path(wrk,"data","axisRangeEBv2 1-14.csv"))
cat("excl 3,4 (paper): ", summ(slopes(d3,c(3,4)))$A, " bias:", summ(slopes(d3,c(3,4)))$B, "\n")
cat("excl 1,2,3,4,5:   ", summ(slopes(d3,c(1,2,3,4,5)))$A, "\n")
cat("excl 2,3,4,5:     ", summ(slopes(d3,c(2,3,4,5)))$A, "\n")
cat("excl 3,4,2,5:     ", summ(slopes(d3,c(2,3,4,5)))$A, "\n")
cat("excl 3,4 (nofit): ", summ(slopes(d3,c(3,4),centerMode="raw"))$A, "\n")

cat("\n======== EXP3 dcrit effectSize>1 (Table A4) ========\n")
cat("excl 3,4: ", paste(round(aggregate(coef~cond,slopes(d3,c(3,4),1,centerMode="reg"),mean)$coef,2),"/",sep=""), "\n")
