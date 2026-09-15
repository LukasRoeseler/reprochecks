README for Reproduction of

Horowitz, Jonathan. 2018. "Relative Education and the Advantage of a College Degree". American Sociological Review. 83 (4) 771-801.

1. Choose a base folder and create a folder system inside of it:
/raw_data/
/prepared_data/
/data_prep_code/

2. Go to cps.ipums.org, log in, and create a data extract with:

a. Samples from ASEC 1971-2010 and no other samples
b. The variables
"YEAR"
"SERIAL"
"MONTH"
"CPSID"
"ASECFLAG"
"ASECWTH"
"REGION"
"METRO"
"METAREA"
"PERNUM"
"CPSIDP"
"ASECWT"
"AGE"
"SEX"
"RACE"
"MARST"
"HISPAN"
"OCC"
"OCC2010"
"WHYPTLWK"
"EDUC"   
(some of these will be automatically selected for you. Additional variables *probably* won't cause any problems). 
c. Limit the cases to just ages 25-62
d. Create the extract and download the .DAT.GZ extract file as well as the .xml DDI file into /raw_data/

3. Download all .dta files from the OSF repo into /raw_data/
4. Download the file https://www.onetcenter.org/dl_files/db_51.zip into /raw_data/. Leave it zipped.
5. Download compile_data.R from the OSF repo into /data_prep_code/
6. Open compile_data.R, set the working directory to the /data_prep_code/ folder (in RStudio, Session -> Set Working Directory -> To Source File Location while the .R file is focused)
7. Ensure the appropriate packages are installed:
install.packages(c('ipumsr','data.table','magrittr','vtable','haven','sjlabelled','purrr','stringr'))
8. Change line 22 of the code to reflect the name of your IPUMS extract .xml file.
9. Run compile_data.R
10. All intermediate data sets will be saved to /prepared_data/, as will the final data set cps_with_onet, in .Rdata, .dta, and .csv form.
11. Variable documentation and basic summary tables will be saved in HTML format to /.