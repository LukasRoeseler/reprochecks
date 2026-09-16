suppressMessages({library(geosphere); library(utils)})
rf <- "C:/Users/LROESE~1.IVV/AppData/Local/Temp/opencode/repro_pilot/work/2hcqr/CRW/CRW/FinalRoutes_19.09.2019_to_slowdown.csv"
d <- read.csv(rf, stringsAsFactors=FALSE)
cat("Rows:", nrow(d), "  Routes:", length(unique(d$Route)), "\n")
cat("Routes & steps:\n"); print(table(d$Route))
out <- NULL
for (r in sort(unique(d$Route))) {
  sub <- d[d$Route==r,]
  # haversine distances in km between consecutive points
  dkm <- distHaversine(sub[1:(nrow(sub)-1), c("Longitude","Latitude")], sub[2:nrow(sub), c("Longitude","Latitude")])/1000
  dt <- diff(sub$Time)               # years (calendar, BP scale)
  v  <- dkm/abs(dt)                  # km per year
  out <- rbind(out, data.frame(Route=r, nseg=length(dkm),
        tot_km=sum(dkm), start_year=max(sub$Time), end_year=min(sub$Time),
        mean_vel=mean(v, na.rm=TRUE), median_vel=median(v, na.rm=TRUE),
        first_vel=v[1], last_vel=v[length(v)],
        v1=v[1:min(3,length(v))]))
}
print(out, digits=4)
cat("\nVelocities km/yr per segment per route:\n")
for (r in sort(unique(d$Route))) {
  sub <- d[d$Route==r,]
  dkm <- distHaversine(sub[1:(nrow(sub)-1), c("Longitude","Latitude")], sub[2:nrow(sub), c("Longitude","Latitude")])/1000
  dt <- diff(sub$Time)
  cat(sprintf("Route %s: dist(km)=%s dt(yr)=%s vel=%s\n", r,
      paste(round(dkm,1),collapse=","), paste(dt,collapse=","),
      paste(round(dkm/abs(dt),3),collapse=",")))
}
