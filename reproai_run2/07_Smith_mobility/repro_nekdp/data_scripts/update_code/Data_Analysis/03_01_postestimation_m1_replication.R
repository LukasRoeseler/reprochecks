
library("here")
library("ergm")
library("doParallel")
library("stargazer")
library("mvmeta")
library("metafor")
library("tidyverse")


  
# Post-Analysis functions
  

adding_classroom_data <- function(x) {
    x$ergm_results %>% 
      mutate(
        classid = x$classroom %>% pull(classid),
        inc_sm  = x$classroom %>% pull(inc_sm)
    )
   }


univariate_meta_regression <- function(classroom_data, outcome_name, var_name, variable_names) {

  formula_str <- as.formula(paste(outcome_name, "~", paste(variable_names, collapse = " + ")))

  meta <- rma(yi = formula_str, vi = get(var_name), data = classroom_data, control = list(maxiter = 500))
  res <- meta %>% 
    summary() %>% 
    coef() %>%
    as_tibble() %>% 
    mutate(
      name = meta$beta %>% rownames(),
      n_class = meta$k,
      type = "univariate"
    )

  res %>% select(c(type, name), everything())

}


# Load the generated data

setwd(here("Data_Analysis/ergm_replication_scratch_data/path_to_results"))

load("ergm_results.RData")



### Data Preparation ###
########################


# Bounds for inclusion according to stricter criteria
ergm_model_results <- ergm_results %>% 
  lapply(adding_classroom_data) %>% 
  bind_rows() %>% 
  mutate(
    classid = as.factor(classid),
    low = ifelse(name == "edges", -8, -3),
    high = ifelse(name == "edges", 0, 3),
    low = ifelse(name == "mutual", -3, low),
    high = ifelse(name == "mutual", 4, high),
)

# Information on models that are included according to weak inclusion criteria
include_weak <- ergm_model_results %>% filter(inc_sm == TRUE)
classid_weak <- include_weak %>% distinct(classid) %>% arrange(classid) %>% pull(classid)

# Information on models that are included according to strict inclusion criteria
classid_strict <- include_weak %>% mutate(
  exclude = ifelse(Estimate < low | Estimate > high | `Std. Error` > 3 | `MCMC %` > 10, 1, 0)
) %>% group_by(classid) %>%
summarize(
  max_exclude = max(exclude, na.rm = TRUE)
) %>% filter(max_exclude == 0) %>% arrange(classid) %>% pull(classid)

include_strict <- include_weak %>% filter(classid %in% classid_strict)

# Get the indices of the relevant models to extract them from ergm_rsults objct
classid_all <- ergm_model_results %>% distinct(classid) %>% arrange(classid) %>% pull(classid)

index_weak   <- seq_along(ergm_results)[classid_all %in% classid_weak]
index_strict <- seq_along(ergm_results)[classid_all %in% classid_strict]


# Networks to be excluded from meta-regressions because no convergence according to convergence plots
exclude_mcmc <- c(
101602,
103101,
103202,
103301,
104101,
104102,
105902,
106802,
106901,
107401,
108501,
108802,
110501,

201101,
201401,
201502,
201702,
202402,
202701,
203102,
203601,
204002,
204103,
205102,
205202,
205501,
206503,
206701,
207403,
207502,
207702,
207902,
208201,
208403,
208801,
209004,
209802,
210102,
211102,
212601,
212702,

300101,
300403,
301001,
301101,
301702,
301901,
301903,
302002,
302201,
302401,
302701,
303301,
303302,
304701,
304802,
304902,
306301,
306802,
307401,
308401,
308502,
308804,
309102,
309203,
309302,
309503,

400401,
400601,
400602,
401402,
401501,
420001,
402002,
402101,
402202,
402502,
403502,
403601,
404302,
404402,
404702,
405201,
405202,
405401,
405402,
405602,
405801,
405802,
406102,
406202,
406302,
406801,
407302,
407601,
408001,
408002,
408502,
408701,
408801,
409301,
409602,
409802,
409901,
410201,
410302,
410502,
410702,
410801,
410802,
410902,
411602,
411701
)

# Get classids and indices for the models included according to
# the evaluation of convergence through convergence plots
classid_mcmc <- classid_strict[!classid_strict %in% exclude_mcmc]
index_mcmc <- seq_along(ergm_results)[classid_all %in% classid_mcmc]
include_mcmc <- include_weak %>% filter(classid %in% classid_mcmc)

##############################################
# Data Analysis with weak inclusion criteria #
##############################################

dir.create("weak2")
setwd("weak2")


classroom_data <- ergm_results[index_weak] %>% 
  map(~.$classroom) %>% 
  bind_rows() %>%
  mutate(
    herf_mean = herf - mean(herf),
    sh_nat_mean = sh_nat - mean(sh_nat),
    mean_isei_mean = mean_isei - mean(mean_isei),
    class_size_mean = class_size - mean(class_size),

  )



### Running the data analysis ###

try(
  univariate_meta_regression(
    classroom_data = classroom_data,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat_mean", "I(sh_nat_mean^2)", "class_size_mean", "mean_isei_mean", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-04-regression-m2.txt", digits = 2, digits.extra = 0)
)


weak_table <- univariate_meta_regression(
    classroom_data = classroom_data,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat_mean", "I(sh_nat_mean^2)", "class_size_mean", "mean_isei_mean", "country_name")
  ) %>% mutate(type = "weak")





################################################
# Data Analysis with strict inclusion criteria #
################################################

setwd("..")
dir.create("strict2")
setwd("strict2")



classroom_data <- ergm_results[index_strict] %>% 
  map(~.$classroom) %>% 
  bind_rows() %>%
  mutate(
    herf_mean = herf - mean(herf),
    sh_nat_mean = sh_nat - mean(sh_nat),
    mean_isei_mean = mean_isei - mean(mean_isei),
    class_size_mean = class_size - mean(class_size),

  )

try(
  univariate_meta_regression(
    classroom_data = classroom_data,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat_mean", "I(sh_nat_mean^2)", "class_size_mean", "mean_isei_mean", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-04-regression-m2.txt", digits = 2, digits.extra = 0)
)


strict_table <- univariate_meta_regression(
    classroom_data = classroom_data,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat_mean", "I(sh_nat_mean^2)", "class_size_mean", "mean_isei_mean", "country_name")
  ) %>% mutate(type = "strict")




##########################################################
# Data Analysis with convergence according to MCMC plots #
##########################################################

setwd("..")
dir.create("mcmc")
setwd("mcmc")


classroom_data <- ergm_results[index_mcmc] %>% 
  map(~.$classroom) %>% 
  bind_rows() %>%
  mutate(
    herf_mean = herf - mean(herf),
    sh_nat_mean = sh_nat - mean(sh_nat),
    mean_isei_mean = mean_isei - mean(mean_isei),
    class_size_mean = class_size - mean(class_size)
  )


try(
  univariate_meta_regression(
    classroom_data = classroom_data,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat_mean", "I(sh_nat_mean^2)", "class_size_mean", "mean_isei_mean", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-04-regression-m2.txt", digits = 2, digits.extra = 0)
)


mcmc_table <-  univariate_meta_regression(
    classroom_data = classroom_data,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat_mean", "I(sh_nat_mean^2)", "class_size_mean", "mean_isei_mean", "country_name")
  ) %>% mutate(type = "mcmc")



setwd("..")


# Save all results in a table
table <- weak_table %>% bind_rows(strict_table) %>% bind_rows(mcmc_table)

save(table, file = "table.RData")