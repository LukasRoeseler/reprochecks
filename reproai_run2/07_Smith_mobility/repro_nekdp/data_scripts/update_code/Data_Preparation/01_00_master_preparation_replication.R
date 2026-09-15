### THIS IS THE MASTER FILE FOR DATA PREPARATION ###
####################################################

# General procedure #
# ----------------- #
# 1. This file takes as input a) a path were the prepared data is supposed to be stored; b) a path were the data preparation
# file is stored, c) the name of the data preparation file, d) the name of the folder in which the prepared data is supposed
# to be stored. 
# 2. The file then generates the top-level folder in which (all) prepared data is supposed to be stored. According to 
# the date at which this file is run, a subfolder is generated that stores the specific prepared data.
# 3. The preparation file is copied into the subfolder to allow for reproducibility
# 4. The preparation file is run and stores the prepared data (inputdata.RData) in the subfolder.

library(here)

# Path for storage of (all) preparation data (across preparations)
path <- here("Data_Analysis")

# Name of the folder for storage of (all) preparation data (across preparations)
data_folder <- "ergm_replication_scratch_data"

# Path to the folder in which the data preparation file is stored
path_preparation <- here("Data_Preparation")

# Name of the file for data preparation
preparation_file <- "01_01_preparation_class_replication.R"

# Create the storage folder
dir.create(paste(path,"/",data_folder,sep=""))

# Get starting date
get.date <- paste(substr(Sys.time(),1,10),"___",gsub(":","-",substr(Sys.time(),12,19)),sep="")

# Generate subfolder named by starting date
indir <- paste(path,"/",data_folder,"/",get.date,sep="")
dir.create(indir)

# Copy the data preparation file to the subfolder
file.copy(from = paste(path_preparation,"/",preparation_file,sep=""),
		  	to = paste(indir,"/",preparation_file,sep=""))

# file.copy(from = paste(path_preparation,"/",preparation_function_file,sep=""),
# 		  	to = paste(indir,"/",preparation_function_file,sep=""))


# Run the data preparation file
source(paste(indir,"/",preparation_file,sep=""))

# Save the data produced by the data preparation file
save.image(paste(indir,"/inputdata",".RData",sep=""))
