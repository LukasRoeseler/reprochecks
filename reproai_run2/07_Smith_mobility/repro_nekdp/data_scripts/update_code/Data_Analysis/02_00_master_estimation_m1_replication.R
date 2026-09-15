library("here")

name_files <-  "Data_Analysis"
name_datafolder <- "ergm_replication_scratch_data"
name_data <- "2020-07-20___16-13-01"

path_files <- here(name_files)
path_data <-  paste0(name_files, "/", name_datafolder, "/", name_data)

estimation_file <- "02_01_estimation_postestimation_m1_replication.R"

get.date.run <- paste(substr(Sys.time(),1,10),"___",gsub(":","-",substr(Sys.time(),12,19)),sep="")

name_estimate <- get.date.run
path_estimate <- paste(path_data,"/",get.date.run,sep="")

dir.create(path_estimate)

file.copy(from = paste(path_files,"/",estimation_file,sep=""),
			to = paste(path_estimate,  "/",estimation_file,sep=""))

source(paste(path_estimate,"/",estimation_file,sep=""))

THE END