## General Preparation ##
#########################

# Packages
library(network)
library(plyr)
library(haven)
library(tidyverse)


# Some functions #
##################

herfindahl_index <- function(eth_vector) { # Herfindahl index from vector of ethnic background
  
  1 - (eth_vector %>% na.omit() %>% as.vector() %>%
         table() %>% prop.table() %>% .^2 %>% sum()) # this gives the table of relative frequencies for the ethnic grpups, takes the sum of 
  # squared relative frequencies, and subtracts it from 1
  
}


# Load data
path_in <- "/Users/da_kresch/Projects/Data/CILS" 

## Load the Data ##
cils.class <- read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth classmates/w1_yc_en_v1.2.0.dta"), encoding = "latin1") %>%
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth classmates/w1_yc_ge_v1.2.0.dta"), encoding = "latin1")) %>%
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth classmates/w1_yc_nl_v1.2.0.dta"), encoding = "latin1")) %>%
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth classmates/w1_yc_sw_v1.2.0.dta"), encoding = "latin1")) %>%
  mutate_all(funs(replace(., . < 0, NA))) # load classroom data and set system missings

cils.main <- read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth main/w1_ym_en_v1.2.0.dta"), encoding = "latin1") %>% 
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth main/w1_ym_ge_v1.2.0.dta"), encoding = "latin1")) %>%
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth main/w1_ym_nl_v1.2.0.dta"), encoding = "latin1")) %>%
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/youth main/w1_ym_sw_v1.2.0.dta"), encoding = "latin1")) %>%
  mutate_all(funs(replace(., . < 0, NA))) # load youth main data and set system missings

cils.pare <- read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/parents/w1_p_en_v1.2.0.dta"), encoding = "latin1") %>% 
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/parents/w1_p_ge_v1.2.0.dta"), encoding = "latin1")) %>%
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/parents/w1_p_nl_v1.2.0.dta"), encoding = "latin1")) %>%
  bind_rows(read_dta(paste0(path_in, "/Licensed version 1.2.0/Data Sets/full version/parents/w1_p_sw_v1.2.0.dta"), encoding = "latin1")) %>%
  mutate_all(funs(replace(., . < 0, NA))) %>% 
  select(youthid, p1_iseiG, p1_piseiG)

cils.main <- cils.main %>% left_join(cils.pare, by = "youthid")



## Prepare Data ##
##################

# This function takes a classroom ID, the classroom data and the main data and prepares
# all the data for this classroom
data_preparation_class <- function(this_class_id = 200202, classroom_data = cils.class, main_data = cils.main) {

## Prepare the friendship network ##
####################################

  
# Define the network boundaries #
# ###############################

# Step 1: Collect all IDs for the chosen classroom from the main and the sociometric questionnaire (respondents)
this_class <- classroom_data %>% inner_join(main_data, by = c("youthid", "classid")) %>%
  filter(classid == this_class_id)

# Step 2: Consider the friendship network data
this_class_friends <- this_class %>% select(youthid, y1_bfs_1, y1_bfs_2, y1_bfs_3, y1_bfs_4, y1_bfs_5)

# Step 3: Collect all the IDs from respondents (in this_class) and nominated in the friendship data
#         and assign consecutive IDs starting from 1‚
ids <- this_class_friends %>% distinct(youthid) %>% na.omit() %>% arrange(youthid) %>% rowid_to_column(var = "id")


# Prepare the friendship network #
##################################

# Step 1: Create an edgelist
edgelist <- ids %>% select(youthid) %>% left_join(this_class_friends, by = "youthid") %>%  # merge friendship data to set of IDs in network
  mutate_all(funs(replace(.,! . %in% (ids %>% pull(youthid)), NA)))	%>% # discard invalid nominations, i.e., those not in the ID set
  mutate_all(funs(mapvalues(.,(ids %>% pull(youthid)), (ids %>% pull(id)), warn_missing=FALSE))) %>% # replace with the consecutive IDs starting from 1
  gather(key="num",val="receiver",-youthid) %>% select(youthid, receiver) %>% as.matrix() # gather to edgelist (long format)

# Step 2: Generate a network, i.e., an adjecency matrix in statnet format
adjacency <- matrix(0,nrow = ids %>% dim() %>% .[1], ncol = ids %>% dim() %>% .[1]) # generate empty adjacency matrix

adjacency[edgelist] <- 1 # insert the existing friendship relations
adjacency <- adjacency %>% as.network(matrix.type = "adjacency") %>% # format
  as.matrix() %>% network()

min_class_size <- ids %>% pull(youthid) %>% max() %% 100

## Prepare Data at the Individual Level ##
##########################################

# Popularity: this is coded from network data #
###############################################

popularity_noms <- this_class %>% select(y1_pos_1, y1_pos_2, y1_pos_3, y1_pos_4, y1_pos_5) %>% # pick the popularity variables
  mutate_all(funs(replace(.,! . %in% (ids %>% pull(youthid)), NA))) %>% # discard invalid nominations, i.e., those not in the ID set
  gather(key = "pos", value = "youthid") %>% na.omit() %>% # gather to long format (each nomination is a row)
  group_by(youthid) %>% # get individual nominations
  summarize(
    rel_pop = n() / min_class_size, # number of nominations by number of actors in class
  ) %>% right_join(ids %>% select(youthid), by = "youthid") %>% # merge with ID vector
  mutate( # if an actor does not appear in the popularity nomination data, they get a popularity score of 0
    rel_pop = ifelse(is.na(rel_pop), 0, rel_pop)
  )


# Individual data from the main questionnaire #
###############################################

individual <- ids %>% left_join(popularity_noms, by = "youthid") %>% # merge popularity data to ID vector
  left_join(main_data, by = "youthid") %>% # merge main data to ID vector
    transmute( # generate set of variables (first few unchanged, necessary because transmute drops if there is no operation on a variable)
    youthid = youthid,
    id = id,
    country = mean(country, na.rm = TRUE),
    classid = mean(classid, na.rm = TRUE),
    rel_pop = rel_pop,
    nat = case_when( # natives have to be defined by survey country
      country == 1 ~ 826, # UK
      country == 2 ~ 276, # GER
      country == 3 ~ 528, # NL
      country == 4 ~ 752, # SW
      TRUE ~ NA_real_
    ),
  country_name = case_when(
    country == 1 ~"EN",
    country == 2 ~"GE",
    country == 3 ~"NL",
    country == 4 ~"SW",
    TRUE ~  NA_character_
  ),
  girl = ifelse(y1_sex == 2, 1, 0),
  #girl = ifelse(is.na(girl), 1, girl),
  cobm_c = ifelse(is.na(y1_cobm), y1_cobf, y1_cobm), # if mother's COB missing, give child's
  cobm_c = ifelse(is.na(cobm_c), y1_cob, cobm_c), # if still missing, give father's
  cobf_c = ifelse(is.na(y1_cobf), y1_cobm, y1_cobf), # if father's COB missing, give child's
  cobf_c = ifelse(is.na(cobf_c), y1_cob, cobf_c), # if still missing, give mother's

  #cobm_c = ifelse(is.na(y1_cobm), y1_cob, y1_cobm), # if mother's COB missing, give child's
  #cobm_c = ifelse(is.na(cobm_c), y1_cobf, cobm_c), # if still missing, give father's
  #cobf_c = ifelse(is.na(y1_cobf), y1_cob, y1_cobf), # if father's COB missing, give child's
  #cobf_c = ifelse(is.na(cobf_c), y1_cobm, cobf_c), # if still missing, give mother's


  eth = case_when( # definition of ethnic background; 
    cobm_c != nat ~  cobm_c, # if mother not born in survey country: mother's country of birth
    cobm_c == nat  & cobf_c != nat ~ cobf_c, # if mother but not father born in survey country: father's country of birth
    cobm_c == nat & cobf_c == nat ~  nat, # if both born in survey country: native
    TRUE ~  NA_real_), # otherwise (12 cases) native
  eth_nm = case_when( # definition of ethnic background; 
    cobm_c != nat ~  cobm_c, # if mother not born in survey country: mother's country of birth
    cobm_c == nat  & cobf_c != nat ~ cobf_c, # if mother but not father born in survey country: father's country of birth
    cobm_c == nat & cobf_c == nat ~  nat, # if both born in survey country: native
    TRUE ~  nat), # otherwise (12 cases) native
  y1_iseimG = y1_iseimG, # note: this is what the Smith et al paper describes, but is also uses parental data in the Smith et al do-files
  y1_iseifG = y1_iseifG,
  p1_iseiG = p1_iseiG,
  p1_piseiG = p1_piseiG,
  ) %>% rowwise() %>% mutate( # individual ISEI score is maximum of parents' scores, once for adolescent, once for parental interview
   max_isei = max(y1_iseimG, y1_iseifG, na.rm = TRUE) %>% ifelse(. < 0, NA, .),
   max_isei_p = max(p1_iseiG, p1_piseiG, na.rm = TRUE) %>% ifelse(. < 0, NA, .)
 ) %>% ungroup() %>% mutate( # missing values on adolescent interview ISEI are substituted 
                             # by parental interview ISEI, and, if missing, 
                             # by classroom mean (this is Smith et al.'s choice, not documented 
                             # in the paper but hhisei_child.do)
   max_isei = ifelse(is.na(max_isei), max_isei_p, max_isei),
   max_isei = ifelse(is.na(max_isei), mean(max_isei, na.rm = TRUE), max_isei)
 ) %>% select(-c(cobm_c, cobf_c, y1_iseimG, y1_iseifG, max_isei_p, p1_iseiG, p1_piseiG))


## Prepare Data at the Classroom Level ##
#########################################

# Classroom data aggregated from individual data #
##################################################

classroom <- individual %>% summarize(
  classid = mean(classid, na.rm = TRUE), # classid, unchanged
  # n_nat = sum(eth_nm == nat, na.rm = TRUE), # number from majority (survey-country specific)
  # n_mig = sum(eth_nm != nat, na.rm = TRUE), # number from minorities (survey-country specific)
  n_nat = sum(eth == nat, na.rm = TRUE), # number from majority (survey-country specific)
  n_mig = sum(eth != nat, na.rm = TRUE), # number from minorities (survey-country specific)
  n_boy = sum(girl == 0, na.rm = TRUE),
  n_girl = sum(girl == 1, na.rm = TRUE),
  # sh_nat = mean(eth_nm == nat, na.rm = TRUE), # share natives (survey-country specfic)
  sh_nat = mean(eth == nat, na.rm = TRUE), # share natives (survey-country specfic)
  herf = herfindahl_index(eth), # Herfindahl index for ethnic diversity
  her_mig = herfindahl_index(eth  %>% ifelse(. == nat, NA, .)), # Herfindahl index for non-natives only
  class_size = n(),
  mean_isei = mean(max_isei, na.rm = TRUE),
  country = max(country, na.rm = TRUE),
  country_name = first(country_name)
)



# Network characteristics from the sociometric questionnaire data #
###################################################################

# network_chars <- this_class %>% select(classid, y1_p_participantsG, y1_p_invalidnomsG, y1_nnominatorG, y1_nnomineeG, y1_outnomsG, y1_classid_matchG) %>%
#   rowid_to_column() %>% filter(rowid == 1) %>% select(-rowid) 

network_chars <- this_class %>% 
  select(classid, y1_p_participantsG, y1_p_invalidnomsG, y1_nnominatorG,
         y1_nnomineeG, y1_outnomsG, y1_classid_matchG) %>%
  summarize(
    sum_nnominee = sum(y1_nnomineeG == 1),
    sum_nnominator = sum(y1_nnominatorG == 1),
    y1_p_participantsG = first(y1_p_participantsG),
    y1_p_invalidnomsG = first(y1_p_invalidnomsG),
    y1_outnomsG = first(y1_outnomsG),
    y1_classid_matchG = first(y1_classid_matchG),
    classid = first(classid)
  ) 

# Merge network characteristics
classroom <- classroom %>% left_join(network_chars, by = "classid")



## Add individual-level variable to the network object for ERGM analysis ##
###########################################################################

# Specify covariates
cova_list <- c("rel_pop", "girl", "eth", "eth_nm", "max_isei")

for(cova_i in cova_list) {
  set.vertex.attribute(adjacency, cova_i, individual %>% pull(cova_i) %>% as.vector())
  
}


## Output the generated data ##
###############################

output <- list(adjacency = adjacency, classroom = classroom, individual = individual)


}

# Identify all classrooms
all_classes <- cils.class %>% distinct(classid) %>% pull(classid) %>% as.vector()

# Prepare all classrooms
all_classes_prepared  <- lapply(all_classes, data_preparation_class)

# Get the classroom data into a single data frame
classroom_data <- lapply(all_classes_prepared, function(x){ x[[2]]} ) %>% bind_rows() %>% rowid_to_column(var = "list_nr")



# Select the classrooms according to Smith et al. code criteria
ergm_network_list <- classroom_data %>% mutate(
  code = ifelse(
  !classid %in% c(107301, 107302) &
  y1_outnomsG != 1 &
  y1_classid_matchG == 1 &
  y1_p_invalidnomsG <= .1 &
  sum_nnominator <= 2 &
  sum_nnominee <= 2 &
  # y1_nnominatorG <= 2 &
  # y1_nnomineeG <= 2 &
  class_size >= 10 &
  n_boy > 2 &
  n_girl > 2 &
  n_nat > 2 &
  n_mig > 2,
  1, 0
  ),
  paper = ifelse(
    y1_outnomsG != 1 &
    y1_classid_matchG == 1 &
    y1_p_invalidnomsG <= .1 &
    sum_nnominator <= 2 &
    sum_nnominee <= 2 &
    #y1_nnominatorG <= 2 &
    #y1_nnomineeG <= 2 &
    y1_p_participantsG >= .75 &
    class_size >= 10 &
    n_boy >= 2 &
    n_girl >= 2 &
    n_nat >= 2 &
    n_mig >= 2,
    1, 0
  )
)


# Different variants

all_ergm_classes_prepared_code <- all_classes_prepared[ergm_network_list %>% filter(code == 1) %>% pull(list_nr)]

data_std <- all_ergm_classes_prepared_code %>% 
  lapply(function(x) x$individual) %>% 
  bind_rows() %>%
  summarize(
    mean_max_isei = mean(max_isei),
    sd_max_isei = sd(max_isei),
    mean_rel_pop = mean(rel_pop),
    sd_rel_pop = sd(rel_pop),
  ) 

all_ergm_classes_prepared_code <- all_ergm_classes_prepared_code %>% lapply(
  function(x) {
    x$individual <- x$individual %>% 
      mutate(
        max_isei_std = (max_isei - (data_std %>% pull(mean_max_isei))) / data_std %>% pull(sd_max_isei),
        rel_pop_std =  (rel_pop - (data_std %>% pull(mean_rel_pop))) / data_std %>% pull(sd_rel_pop)
      )
      set.vertex.attribute(x$adjacency, "max_isei_std", x$individual %>% pull(max_isei_std) %>% as.vector()) 
      set.vertex.attribute(x$adjacency, "rel_pop_std",  x$individual %>% pull(rel_pop_std) %>% as.vector()) 
      x
  }
)


all_ergm_classes_prepared_paper <- all_classes_prepared[ergm_network_list %>% filter(paper == 1) %>% pull(list_nr)]



data_std <- all_ergm_classes_prepared_paper %>% 
  lapply(function(x) x$individual) %>% 
  bind_rows() %>%
  summarize(
    mean_max_isei = mean(max_isei),
    sd_max_isei = sd(max_isei),
    mean_rel_pop = mean(rel_pop),
    sd_rel_pop = sd(rel_pop),
  ) 

all_ergm_classes_prepared_paper <- all_ergm_classes_prepared_paper %>% lapply(
  function(x) {
    x$individual <- x$individual %>% 
      mutate(
        max_isei_std = (max_isei - (data_std %>% pull(mean_max_isei))) / data_std %>% pull(sd_max_isei),
        rel_pop_std = (rel_pop - (data_std %>% pull(mean_rel_pop))) / data_std %>% pull(sd_rel_pop)
      )
      set.vertex.attribute(x$adjacency, "max_isei_std", x$individual %>% pull(max_isei_std) %>% as.vector()) 
      set.vertex.attribute(x$adjacency, "rel_pop_std",  x$individual %>% pull(rel_pop_std) %>% as.vector()) 
      x
  }
  )

classroom_data_ergm_code  <- lapply(all_ergm_classes_prepared_code , function(x){ x[[2]]} ) %>% bind_rows() %>% rowid_to_column(var = "list_nr")
classroom_data_ergm_paper <- lapply(all_ergm_classes_prepared_paper, function(x){ x[[2]]} ) %>% bind_rows() %>% rowid_to_column(var = "list_nr")
