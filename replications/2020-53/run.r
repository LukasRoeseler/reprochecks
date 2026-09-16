## CODE FOR COMPUTATION OF NEOLITHIC EXPANSION ROUTES 
## Betti et al. 2020. Climate shaped how Neolithic farmers and European hunter-gatherers interacted after a major slowdown from 6,100 BCE to 4,500 BCE. Nature Human Behaviour

# Opens dataset of Neolithic site dates and location. The dataset has the following columns: Lat(Latitude), Long (Longitude), Site, Country, Date.BCE (calibrated date BCE)
read.csv("dataset.csv")->agriculture      
agriculture<-agriculture[order(agriculture$Date.BCE),]
library(grDevices)
library(maptools)
readShapePoly("country.shp",force_ring=T)->world

## generates core area from which expansion is measured (Neolithic dates earlier than 8,000 BCE)
core.area<-subset(agriculture,Date.BCE < -8000)
prev.chull<-chull(core.area[,1:2])   # Minimum convex polygon encompassing core area sites
route.points.core<-prev.chull
dates<-abs(agriculture$Date.BCE)

## analyses European continental sites in 100-year groups; Great Britain, Ireland and Scandinavia  (Sweden adn Norway) not included.
excluded.countries<-c('Great Britain','Ireland','Scotland','Sweden','Norway')
agriculture.continent<-agriculture[!agriculture$Country%in%excluded.countries,]
route.points<-route.points.core
for (i in 1:50) {
  agriculture.sub<-agriculture.continent[abs(agriculture.continent$Date.BCE)>(8000-100*i),]
  new.chull<-chull(agriculture.sub[,1:2])
  route.points<-c(route.points,new.chull[!new.chull %in% prev.chull])
  prev.chull<-new.chull
}
route.points.continent<-agriculture.continent[route.points,]   # minimum convex polygon vertices for continental sites, as calculated every 100 years after 8000 BCE

## analyses sites in 100-year groups, only Great Britain
countries<-c('Great Britain','Scotland')
agriculture.GB<-agriculture[agriculture$Country%in%countries,]
route.points<-c(NULL)
for (i in 1:50) {
  agriculture.sub<-agriculture.GB[abs(agriculture.GB$Date.BCE)>=(5200-100*i),]
  new.chull<-chull(agriculture.sub[,1:2])
  route.points<-c(route.points,new.chull[!new.chull %in% prev.chull])
  prev.chull<-new.chull
}
route.points.GB<-agriculture.GB[route.points,]  # minimum convex polygon vertices for GB sites, as calculated every 100 years after 5200 BCE (no eolithic sites in GB earlier)

## analyses sites in 100-year groups, only Ireland
countries<-c('Ireland')
agriculture.Ireland<-agriculture[agriculture$Country%in%countries,]
route.points<-c(NULL)
for (i in 1:50) {
  agriculture.sub<-agriculture.Ireland[abs(agriculture.Ireland$Date.BCE)>=(5200-100*i),]
  new.chull<-chull(agriculture.sub[,1:2])
  route.points<-c(route.points,new.chull[!new.chull %in% prev.chull])
  prev.chull<-new.chull
}
route.points.Ireland<-agriculture.Ireland[route.points,]  # minimum convex polygon vertices for Irish sites (including Northern Ireland), as calculated every 100 years after 5200 BCE

## analyses sites in 100-year groups, only Scandinavia
countries<-c('Sweden','Norway')
agriculture.Scand<-agriculture[agriculture$Country%in%countries,]
route.points<-c(NULL)
for (i in 1:50) {
  agriculture.sub<-agriculture.Scand[abs(agriculture.Scand$Date.BCE)>=(4400-100*i),]
  new.chull<-chull(agriculture.sub[,1:2])
  route.points<-c(route.points,new.chull[!new.chull %in% prev.chull])
  prev.chull<-new.chull
}
route.points.Scand<-agriculture.Scand[route.points,]  # minimum convex polygon vertices for Scandinavian sites (Sweden, Norway), as calculated every 100 years after 4400 BCE

## key expansion points detected by the algorithm

route.points<-c(NULL)
route.points<-rbind(route.points.Scand,route.points.GB,route.points.Ireland,route.points.continent)
route.points<-route.points[order(route.points$Date.BCE),]

## Definition of expansion routes as driven by nw vertices in Neolithic site polygon every 100 years.
library(geosphere)
library(rgeos)
library(rgdal)
library(sp)
library(data.table)
 # continental Europe
exclude<-c(NULL)
segments.axes<-data.frame(Site1=character(),Date1=factor(),Lat1=factor(),Long1=factor(),Site2=character(),Date2=factor(),Lat2=factor(),Long2=factor(),Dist=factor())
all.points<-route.points.continent
all.points<-all.points[order(all.points$Date.BCE),]

for (i in 11:nrow(all.points)){
 foo<-all.points[1:i,]
 if (length(exclude)>=1){
 foo<-foo[-exclude,]
 }
 geo.dist<-distm(all.points[i,c(2,1)],foo[,c(2,1)],fun=distHaversine)/1000
 geo.dist[geo.dist == 0] <- 100000
 if (min(geo.dist)<=50) {     # exclude new vertices that are less than 50km away from previous route points (to reduce noise)
  exclude<-cbind(exclude,i)
 } else {
 date.i<-all.points[i,]$Date.BCE
  # To find the next point in the route, it first selects sites up to 300 years after the new site (i.e. potential filling-in sites)
 foo.date.i<-agriculture.continent[agriculture.continent$Date.BCE>=date.i&agriculture.continent$Date.BCE<(date.i+300),]     
  # It then selects up to 4 closest previous vertices (i.e. route points), including the closest one and up to three others within 150% of the distance between the new vertex and the closest existing route point  
 segments.4<-foo[which(geo.dist %in% sort(geo.dist)[1]),c(3,5,1,2)] 
 if (sort(geo.dist)[2]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[2]),c(3,5,1,2)])}
 if (sort(geo.dist)[3]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[3]),c(3,5,1,2)])} 
 if (sort(geo.dist)[4]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[4]),c(3,5,1,2)])} 
  # To choose among these possible connecting route points, it looks at the number of filling-in sites that appeared near the connecting segment (within 50 Km from the segment) in the following 300 years
 if (nrow(segments.4)>1){
 segments.foo<-rbind(all.points[i,c(3,5,1,2)],segments.4)
 coordinates( segments.foo ) <- c( "Long", "Lat" )
 proj4string( segments.foo ) <- CRS( "+proj=longlat +datum=WGS84" )
  # candidate vertices' and filling-in sites' coordinates projected onto 2D Euclidean space for further spatial analyses
 segments.4.projected<-spTransform(segments.foo, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 coordinates( foo.date.i ) <- c( "Long", "Lat" )
 proj4string( foo.date.i ) <- CRS( "+proj=longlat +datum=WGS84" )
 foo.date.i.projected<-spTransform(foo.date.i, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 points.proj<-coordinates(foo.date.i.projected)
 points.j<-c(NULL)
 for(j in 2:nrow(segments.4.projected)){       # finds the number of sites within 50 km from the segment, by first rotating the plane to make the segment horizontal, then selecting  the sites with the same rotated x and an y within +- 50000m
 segment.j<-coordinates(segments.4.projected[c(1,j),])
 ang.j<--atan((segment.j[1,2]-segment.j[2,2])/(segment.j[1,1]-segment.j[2,1]))
 rotated.segm<-cbind(segment.j[,1]*cos(ang.j)-segment.j[,2]*sin(ang.j),segment.j[,1]*sin(ang.j)+segment.j[,2]*cos(ang.j))
 rotated.points<-cbind(points.proj[,1]*cos(ang.j)-points.proj[,2]*sin(ang.j),points.proj[,1]*sin(ang.j)+points.proj[,2]*cos(ang.j))
 points.j[j-1]<-length(which(between(rotated.points[,1],rotated.segm[1,1],rotated.segm[2,1])&between(rotated.points[,2],rotated.segm[1,2]-50000,rotated.segm[2,2]+50000)))/abs(rotated.segm[1,1]-rotated.segm[2,1]) # density of fillin-in sites
 }
 best.site<-segments.4[which.max(points.j),] # indentifies the segment with the highest density of filling-in sites
 boo<-cbind(all.points[i,c(3,5,1,2)],best.site,min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)  # new vertex connected to previously identified route point
 }else{ 
 # this is used in case there is only one close possible route point to connect to, and tehre is no need to copare potential connections based on density of filling-in sites
 boo<-cbind(all.points[i,c(3,5,1,2)],foo[max.col(-geo.dist),c(3,5,1,2)],min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)
 }}
} 
  # Route into Great Britain from continental Europe
exclude<-c(NULL)
all.points<-route.points.GB
all.points<-all.points[order(all.points$Date.BCE),]

for (i in 1:nrow(all.points)){
foo<-all.points[1:i,]
if (i==1){
continent.points<-route.points.continent[route.points.continent$Date.BCE<all.points[i,]$Date.BCE,]
geo.dist<-distm(all.points[i,c(2,1)],continent.points[,c(2,1)],fun=distHaversine)/1000
geo.dist[geo.dist == 0] <- 100000
boo<-cbind(all.points[i,c(3,5,1,2)],continent.points[max.col(-geo.dist),c(3,5,1,2)],min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)
 }
 else{
 if (length(exclude)>=1){
 foo<-foo[-exclude,]
 }
 geo.dist<-distm(all.points[i,c(2,1)],foo[,c(2,1)],fun=distHaversine)/1000
 geo.dist[geo.dist == 0] <- 100000
 if (min(geo.dist)<=50) {    # exclude new vertices that are less than 50km away from previous route points (to reduce noise)
  exclude<-cbind(exclude,i)
 } else {
 date.i<-all.points[i,]$Date.BCE
  # To find the next point in the route, it first selects sites up to 300 years after the new site (i.e. potential filling-in sites)
 foo.date.i<-agriculture.GB[agriculture.GB$Date.BCE>=date.i&agriculture.GB$Date.BCE<(date.i+300),]    
 # It then selects up to 4 closest previous vertices (i.e. route points), including the closest one and up to three others within 150% of the distance between the new vertex and the closest existing route point   
 segments.4<-foo[which(geo.dist %in% sort(geo.dist)[1]),c(3,5,1,2)] 
 if (sort(geo.dist)[2]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[2]),c(3,5,1,2)])}
 if (length(geo.dist)>2){
 if(sort(geo.dist)[3]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[3]),c(3,5,1,2)])}} 
 if (length(geo.dist)>3){
 if(sort(geo.dist)[4]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[4]),c(3,5,1,2)])}} 
 # To choose among these possible connecting route points, it looks at the number of filling-in sites that appeared near the connecting segment (within 50 Km from the segment) in the following 300 years
 if (nrow(segments.4)>1){
 segments.foo<-rbind(all.points[i,c(3,5,1,2)],segments.4)
 coordinates( segments.foo ) <- c( "Long", "Lat" )
 proj4string( segments.foo ) <- CRS( "+proj=longlat +datum=WGS84" )
 # candidate vertices' and filling-in sites' coordinates projected onto 2D Euclidean space for further spatial analyses
 segments.4.projected<-spTransform(segments.foo, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 coordinates( foo.date.i ) <- c( "Long", "Lat" )
 proj4string( foo.date.i ) <- CRS( "+proj=longlat +datum=WGS84" )
 foo.date.i.projected<-spTransform(foo.date.i, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 points.proj<-coordinates(foo.date.i.projected)
 points.j<-c(NULL)
 for(j in 2:nrow(segments.4.projected)){       # finds the number of sites within 50 km from the segment, by first rotating the plane to make the segment horizontal
 segment.j<-coordinates(segments.4.projected[c(1,j),])
 ang.j<--atan((segment.j[1,2]-segment.j[2,2])/(segment.j[1,1]-segment.j[2,1]))
 rotated.segm<-cbind(segment.j[,1]*cos(ang.j)-segment.j[,2]*sin(ang.j),segment.j[,1]*sin(ang.j)+segment.j[,2]*cos(ang.j))
 rotated.points<-cbind(points.proj[,1]*cos(ang.j)-points.proj[,2]*sin(ang.j),points.proj[,1]*sin(ang.j)+points.proj[,2]*cos(ang.j))
 points.j[j-1]<-length(which(between(rotated.points[,1],rotated.segm[1,1],rotated.segm[2,1])&between(rotated.points[,2],rotated.segm[1,2]-50000,rotated.segm[2,2]+50000)))/abs(rotated.segm[1,1]-rotated.segm[2,1])
 }
 best.site<-segments.4[which.max(points.j),] # indentifies the segment with the highest density of filling-in site
 boo<-cbind(all.points[i,c(3,5,1,2)],best.site,min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)    # new vertex connected to previously identified route point
 }else{ 
 # this is used in case there is only one close possible route point to connect to, and tehre is no need to copare potential connections based on density of filling-in sites
 boo<-cbind(all.points[i,c(3,5,1,2)],foo[max.col(-geo.dist),c(3,5,1,2)],min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)
 }}
}} 
  # Route into SIreland from Great Britain
exclude<-c(NULL)
all.points<-route.points.Ireland
all.points<-all.points[order(all.points$Date.BCE),]

for (i in 1:nrow(all.points)){
 foo<-all.points[1:i,]
 if (i==1){
GB.points<-route.points.GB[route.points.GB$Date.BCE<all.points[i,]$Date.BCE,]
geo.dist<-distm(all.points[i,c(2,1)],GB.points[,c(2,1)],fun=distHaversine)/1000
geo.dist[geo.dist == 0] <- 100000
boo<-cbind(all.points[i,c(3,5,1,2)],GB.points[max.col(-geo.dist),c(3,5,1,2)],min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)
 }
 else{
 if (length(exclude)>=1){
 foo<-foo[-exclude,]
 }
 geo.dist<-distm(all.points[i,c(2,1)],foo[,c(2,1)],fun=distHaversine)/1000
 geo.dist[geo.dist == 0] <- 100000
 if (min(geo.dist)<=50) {    # exclude new vertices that are less than 50km away from previous route points (to reduce noise)
  exclude<-cbind(exclude,i)
 } else {
 date.i<-all.points[i,]$Date.BCE
  # To find the next point in the route, it first selects sites up to 300 years after the new site (i.e. potential filling-in sites)
 foo.date.i<-agriculture.Ireland[agriculture.Ireland$Date.BCE>=date.i&agriculture.Ireland$Date.BCE<(date.i+300),]   
 # It then selects up to 4 closest previous vertices (i.e. route points), including the closest one and up to three others within 150% of the distance between the new vertex and the closest existing route point    
 segments.4<-foo[which(geo.dist %in% sort(geo.dist)[1]),c(3,5,1,2)] 
 if (sort(geo.dist)[2]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[2]),c(3,5,1,2)])}
 if (length(geo.dist)>2){
 if (sort(geo.dist)[3]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[3]),c(3,5,1,2)])}} 
 if (length(geo.dist)>3){
 if (sort(geo.dist)[4]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[4]),c(3,5,1,2)])}} 
 # To choose among these possible connecting route points, it looks at the number of filling-in sites that appeared near the connecting segment (within 50 Km from the segment) in the following 300 years
 if (nrow(segments.4)>1){
 segments.foo<-rbind(all.points[i,c(3,5,1,2)],segments.4)
 coordinates( segments.foo ) <- c( "Long", "Lat" )
 proj4string( segments.foo ) <- CRS( "+proj=longlat +datum=WGS84" )
 # candidate vertices' and filling-in sites' coordinates projected onto 2D Euclidean space for further spatial analyses
 segments.4.projected<-spTransform(segments.foo, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 coordinates( foo.date.i ) <- c( "Long", "Lat" )
 proj4string( foo.date.i ) <- CRS( "+proj=longlat +datum=WGS84" )
 foo.date.i.projected<-spTransform(foo.date.i, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 points.proj<-coordinates(foo.date.i.projected)
 points.j<-c(NULL)
 for(j in 2:nrow(segments.4.projected)){       # finds the number of sites within 50 km from the segment, by first rotating the plane to make the segment horizontal
 segment.j<-coordinates(segments.4.projected[c(1,j),])
 ang.j<--atan((segment.j[1,2]-segment.j[2,2])/(segment.j[1,1]-segment.j[2,1]))
 rotated.segm<-cbind(segment.j[,1]*cos(ang.j)-segment.j[,2]*sin(ang.j),segment.j[,1]*sin(ang.j)+segment.j[,2]*cos(ang.j))
 rotated.points<-cbind(points.proj[,1]*cos(ang.j)-points.proj[,2]*sin(ang.j),points.proj[,1]*sin(ang.j)+points.proj[,2]*cos(ang.j))
 points.j[j-1]<-length(which(between(rotated.points[,1],rotated.segm[1,1],rotated.segm[2,1])&between(rotated.points[,2],rotated.segm[1,2]-50000,rotated.segm[2,2]+50000)))/abs(rotated.segm[1,1]-rotated.segm[2,1])
 }
 best.site<-segments.4[which.max(points.j),] # indentifies the segment with the highest density of filling-in site
 boo<-cbind(all.points[i,c(3,5,1,2)],best.site,min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)    # new vertex connected to previously identified route point
 }else{ 
 # this is used in case there is only one close possible route point to connect to, and tehre is no need to copare potential connections based on density of filling-in sites
 boo<-cbind(all.points[i,c(3,5,1,2)],foo[max.col(-geo.dist),c(3,5,1,2)],min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)
 }}
}} 
 # Route into Sweden and Norway from continental Europe
exclude<-c(NULL)
all.points<-route.points.Scand
all.points<-all.points[order(all.points$Date.BCE),]

for (i in 1:nrow(all.points)){
 foo<-all.points[1:i,]
 if (i==1){
continent.points<-route.points.continent[route.points.continent$Date.BCE<all.points[i,]$Date.BCE,]
geo.dist<-distm(all.points[i,c(2,1)],continent.points[,c(2,1)],fun=distHaversine)/1000
geo.dist[geo.dist == 0] <- 100000
boo<-cbind(all.points[i,c(3,5,1,2)],continent.points[max.col(-geo.dist),c(3,5,1,2)],min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)
 }
 else{
 if (length(exclude)>=1){
 foo<-foo[-exclude,]
 }
 geo.dist<-distm(all.points[i,c(2,1)],foo[,c(2,1)],fun=distHaversine)/1000
 geo.dist[geo.dist == 0] <- 100000
 if (min(geo.dist)<=50) {    # exclude new vertices that are less than 50km away from previous route points (to reduce noise)
  exclude<-cbind(exclude,i)
 } else {
 date.i<-all.points[i,]$Date.BCE
  # To find the next point in the route, it first selects sites up to 300 years after the new site (i.e. potential filling-in sites)
 foo.date.i<-agriculture.Scand[agriculture.Scand$Date.BCE>=date.i&agriculture.Scand$Date.BCE<(date.i+300),] 
 # It then selects up to 4 closest previous vertices (i.e. route points), including the closest one and up to three others within 150% of the distance between the new vertex and the closest existing route point       
 segments.4<-foo[which(geo.dist %in% sort(geo.dist)[1]),c(3,5,1,2)] 
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[2]),c(3,5,1,2)])}
 if (length(geo.dist)>2){
 if (sort(geo.dist)[3]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[3]),c(3,5,1,2)])}}
 if (length(geo.dist)>3){
 if (sort(geo.dist)[4]/sort(geo.dist)[1]<1.5){
 segments.4<-rbind(segments.4,foo[which(geo.dist %in% sort(geo.dist)[4]),c(3,5,1,2)])}} 
 # To choose among these possible connecting route points, it looks at the number of filling-in sites that appeared near the connecting segment (within 50 Km from the segment) in the following 300 years
 if (nrow(segments.4)>1){
 segments.foo<-rbind(all.points[i,c(3,5,1,2)],segments.4)
 coordinates( segments.foo ) <- c( "Long", "Lat" )
 proj4string( segments.foo ) <- CRS( "+proj=longlat +datum=WGS84" )
 # candidate vertices' and filling-in sites' coordinates projected onto 2D Euclidean space for further spatial analyses
 segments.4.projected<-spTransform(segments.foo, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 coordinates( foo.date.i ) <- c( "Long", "Lat" )
 proj4string( foo.date.i ) <- CRS( "+proj=longlat +datum=WGS84" )
 foo.date.i.projected<-spTransform(foo.date.i, CRS( " +proj=lcc +lon 0=90w +lat 1=20n +lat 2=60n")) # projected using Northern Lambert Conformal Conic CRS
 points.proj<-coordinates(foo.date.i.projected)
 points.j<-c(NULL)
 for(j in 2:nrow(segments.4.projected)){       # finds the number of sites within 50 km from the segment, by first rotating the plane to make the segment horizontal
 segment.j<-coordinates(segments.4.projected[c(1,j),])
 ang.j<--atan((segment.j[1,2]-segment.j[2,2])/(segment.j[1,1]-segment.j[2,1]))
 rotated.segm<-cbind(segment.j[,1]*cos(ang.j)-segment.j[,2]*sin(ang.j),segment.j[,1]*sin(ang.j)+segment.j[,2]*cos(ang.j))
 rotated.points<-cbind(points.proj[,1]*cos(ang.j)-points.proj[,2]*sin(ang.j),points.proj[,1]*sin(ang.j)+points.proj[,2]*cos(ang.j))
 points.j[j-1]<-length(which(between(rotated.points[,1],rotated.segm[1,1],rotated.segm[2,1])&between(rotated.points[,2],rotated.segm[1,2]-50000,rotated.segm[2,2]+50000)))/abs(rotated.segm[1,1]-rotated.segm[2,1])
 }
 best.site<-segments.4[which.max(points.j),] # indentifies the segment with the highest density of filling-in site
 boo<-cbind(all.points[i,c(3,5,1,2)],best.site,min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)  # new vertex connected to previously identified route point
 }else{ 
 # this is used in case there is only one close possible route point to connect to, and tehre is no need to copare potential connections based on density of filling-in sites
 boo<-cbind(all.points[i,c(3,5,1,2)],foo[max.col(-geo.dist),c(3,5,1,2)],min(geo.dist))
 colnames(boo)=c('Site1','Date1','Lat1','Long1','Site2','Date2','Lat2','Long2','Dist')
 segments.axes<-rbind(segments.axes,boo)
 }}
}} 

write.csv(segments.axes,"segments.axes.csv")

