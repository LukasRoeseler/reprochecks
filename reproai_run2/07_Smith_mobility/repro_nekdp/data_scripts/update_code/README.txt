Instructions for running data preparation and data analysis:

1. Run "01_00_master_preparation_replication.R" from "Data_Preparation", which calls "01_01_preparation_class_replication". In "01_01_preparation_class_replication", adjust data_path to point to top path at which data is stored. The script then generates the input data in "Data_Analysis/ergm_replication_scratch_data". 

2. Run "02_00_master_estimation_m1_replication.R" from "Data_Analysis", which calls "02_01_estimation_postestimation_m1_replication". In "02_00_master_estimation_m1_replication.R", adjust "name_data" to the name of the data folder generated in the first step.

3. Run "03_01_postestimation_m1_repliation.R" from "Data_Analysis". Adjust "path_to_results" according to the path in which the data generated in 2. is stored.

All results from the data analysis are stored in subfolders of the data folder generated in the first step.