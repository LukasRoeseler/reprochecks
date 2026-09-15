/*------------------------------------------------------------------------------
Data needed/Data version used in paper:
- Data of the field experiment, reduced version for validation study, July 2024: validation_replication_fe.dta
- Data of the factorial survey, reduced version for validation study, July 2024: validation_replication_fs.dta
------------------------------------------------------------------------------*/

clear all
version 18
capture log close
set more off
estimates clear

* Set paths to working directories

/* Customize this path to the location on your computer where the downloaded 
replication folder is located */

global workingDir ".../replication_package_incl_data"

*-------------------------------------------------------------------------------
global data "$workingDir/00_data"
global posted "$workingDir/02_posted"
global tables "$workingDir/03_tables"
global figures "$workingDir/04_figures"
global logs "$workingDir/05_logs"
*-------------------------------------------------------------------------------

local logdate : di %tdCYND daily("$S_DATE", "DMY")
log using "$logs/validation_study_`logdate'.txt", text replace 


do 01_dataprep_significance.do
do 02_descriptives.do
do 03_models.do
do 04_robustness.do
