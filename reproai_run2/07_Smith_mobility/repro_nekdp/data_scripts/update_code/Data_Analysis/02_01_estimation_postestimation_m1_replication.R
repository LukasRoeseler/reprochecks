
library("ergm")
library("doParallel")
library("stargazer")
library("mvmeta")
library("metafor")
library("tidyverse")

load(paste0(path_data, "/inputdata.RData"))
  
procs <- as.numeric(Sys.getenv("MOAB_PROCCOUNT"))
cl <- makeCluster(procs)
registerDoParallel(cl)


# Function to get information on individual ergms
collect_ergm_results <- function(
  ergm_call, 
  this_ergm_data, 
  selected_coefs = c("nodematch.eth", "edgecov.eth_match_nat", "edgecov.eth_match_mig")) {

  if (!is.null(ergm_call)) {

    ergm_results <- summary(ergm_call)$coefficients
    ergm_results <- bind_cols(name = ergm_results %>% rownames(), ergm_results)
    
    ergm_select <- ergm_results %>% mutate(dec_log = ergm_call$loglikelihood) %>%
    summarize(
      max_se = max(`Std. Error`),
      max_hom = max(ifelse(name %in% selected_coefs, abs(Estimate), 0)),
      max_hom_se = max(ifelse(name %in% selected_coefs, `Std. Error`, 0)),
      dec_log = mean(dec_log),
      max_coef = max(abs(Estimate)),
      max_mcmc = max(`MCMC %`),
      any_na = is.na(mean(Estimate)) | is.na(mean(`Std. Error`)) | is.na(mean(`MCMC %`)),
      all_coefs = summary(ergm_call)$formula[3] %>% as.character() %>% str_count(., "\\+") + 1 + 1 == dim(ergm_results[,1])[1]
    ) %>% mutate(
      inc_sm = ifelse(max_hom_se <= 5 & max_hom <= 5 & dec_log < 5, TRUE, FALSE),
      inc_sm = ifelse(is.na(inc_sm), FALSE, inc_sm),
      inc_st = ifelse(inc_sm == TRUE & max_mcmc < 20 & any_na == FALSE & max_coef <= 10 & all_coefs == TRUE, TRUE, FALSE),
      inc_st = ifelse(is.na(inc_st), FALSE, inc_st)
    )
    
    ergm_hom <- ergm_results %>% select(name, Estimate) %>% mutate(name = paste0("coef_", name)) %>% 
    spread(key = "name", value = "Estimate") %>% bind_cols(
      ergm_results %>% select(name, `Std. Error`) %>% mutate(
        name = paste0("var_", name),
        `Std. Error` = `Std. Error`^2
      ) %>% 
      spread(key = "name", value = `Std. Error`)
    )

    ergm_mcmc <- ergm_call$sample %>% as.tibble() %>% rowid_to_column(var = "iteration") %>%
    gather(key = "param", value = "val", -iteration) %>% 
    filter(grepl("esp#", param) == FALSE) %>% 
    mutate(classid = this_ergm_data$classroom %>% pull(classid))

    ergm_meta_prep <- 
    list(ergm_meta_coef = coef(ergm_call),
     ergm_meta_vcov = vcov(ergm_call)
   )
    

  } else {

    ergm_results <- tibble(name = NA)

    ergm_results <- tibble(name = NA, Estimate = NA,  `Std. Error` = NA, 
      `MCMC %`= NA, `z value` = NA, `Pr(>|z|)`= NA) 

    ergm_select <- tibble(max_se = NA, max_hom = NA, max_hom_se = NA, dec_log = NA, max_coef = NA, max_mcmc = NA, 
      any_na = NA, all_coefs = NA, inc_sm = NA, inc_st = NA)

    ergm_hom <- tibble(coef_absdiff.max_isei_std = NA)

    #ergm_mcmc <- tibble(iteration = NA)
    ergm_mcmc <- tibble(iteration = NA, val = NA, param = NA)


    ergm_meta_prep <- NULL

  } 

  full_results_list <- list(
    adjacency = this_ergm_data$adjacency,
    individual = this_ergm_data$individual,
    classroom = this_ergm_data$classroom %>% bind_cols(ergm_select) %>% bind_cols(ergm_hom),
    ergm_results = ergm_results,
    ergm_mcmc = ergm_mcmc,
    ergm_meta_prep = ergm_meta_prep
  )

  return(full_results_list)

}


  
# Post-Analysis functions
  

adding_classroom_data <- function(x) {
    x$ergm_results %>% 
      mutate(
        classid = x$classroom %>% pull(classid),
        inc_sm  = x$classroom %>% pull(inc_sm)
    )
   }

# Meta-analysis and meta-regression
univariate_meta_analysis <- function(var, coefs_meta, vcovs_meta) {

  y <- coefs_meta[,var]
  S <- vcovs_meta %>% lapply(function(x) {x[var, var]})
  meta <- mvmeta(formula = y, S = S, , control = list(maxiter = 500))
  res <- meta %>% 
    summary() %>% 
    coef() %>%
    as_tibble() %>% 
    mutate(
      name = var,
      n_class = meta$dim$m
    )

  res

}


meta_analyses <- function(classid_strict_list, ergm_results) {

  coefs_meta <- ergm_results[classid_strict_list] %>% lapply(function(x) {x$ergm_meta_prep$ergm_meta_coef}) %>% bind_cols() %>% as.matrix() %>% t()
  vcovs_meta <- ergm_results[classid_strict_list] %>% lapply(function(x) {x$ergm_meta_prep$ergm_meta_vcov})
  colnames(coefs_meta) <- names(ergm_results[classid_strict_list][[1]]$ergm_meta_prep$ergm_meta_coef)

  multivariate_meta <- mvmeta(formula = coefs_meta, S = vcovs_meta) %>% summary() 
  multivariate_meta <- multivariate_meta$coefficients %>% as_tibble() %>% bind_cols(name = colnames(coefs_meta)) %>% mutate(type = "multivariate", n_class = multivariate_meta$dim$m)
  univariate_meta   <- colnames(coefs_meta) %>% lapply(univariate_meta_analysis, coefs_meta = coefs_meta, vcovs_meta = vcovs_meta) %>% bind_rows()  %>% mutate(type = "univariate")

  meta <- multivariate_meta %>% bind_rows(univariate_meta) %>% select(c(type, name), everything())

  meta

} 


univariate_meta_regression <- function(classid_strict_list, ergm_results, outcome_name, var_name, variable_names) {

  formula_str <- as.formula(paste(outcome_name, "~", paste(variable_names, collapse = " + ")))

  classroom_data <- ergm_results[classid_strict_list] %>% lapply(function(x) {x$classroom}) %>% bind_rows()

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


# MCMC plots
plot_param_mcmc <- function(res, path_out) {


  if (nrow(res$ergm_mcmc) > 1) {

    res$ergm_mcmc %>% 
    filter(iteration %% 100 == 0) %>%
    ggplot(aes(x = iteration, y = val)) +
    geom_line() + 
    theme_bw() + 
    facet_wrap(~param, scales = "free") +
    labs(y = paste(res$classroom %>% pull(classid)))

    ggsave(
      filename = paste0("convergence-01-trace", "-", res$classroom %>% pull(classid), ".jpg"), 
      path = path_out,
      height = 6, 
      width = 9
    )

    res$ergm_mcmc %>%
    ggplot(aes(x = val)) + 
    geom_density() + 
    theme_bw() + 
    facet_wrap(~param, scales = "free") +
    labs(y = paste(res$classroom %>% pull(classid)))

    ggsave(
     filename = paste0("convergence-01-dens", "-", res$classroom %>% pull(classid), ".jpg"),
     path = path_out,
     height = 6, 
     width = 9
   )

  }

}



#### Analysis with the paper data ####
###################################### 

setwd(path_estimate)

dir.create("mcmc")
setwd("mcmc")

path_out <- getwd()


# Running all ERGMs
model1_list_paper <- foreach(i =  seq_along(all_ergm_classes_prepared_paper), 
                              .packages = c("ergm", "tidyverse"),
                              .verbose = TRUE, 
                              .errorhandling = "stop"
                              ) %dopar% {
                                
                                # Model 1

                                ergm_call <- tryCatch(
                                  ergm(all_ergm_classes_prepared_paper[[i]]$adjacency~edges+mutual+gwesp(.25)
                                                  + nodematch("eth")
                                                  + nodematch("girl")
                                                  + absdiff("rel_pop_std")
                                                  + absdiff("max_isei_std"),
                                                  constraints = ~bd(maxout = 5),
                                                  control = control.ergm(
                                                    MCMC.burnin = 50000,
                                                    MCMC.samplesize = 100000,
                                                    MCMLE.maxit = 4
                                                  )),
                                   error = function(cond) {return(NULL)}
                                 )

                                res_m1 <- collect_ergm_results(ergm_call = ergm_call, this_ergm_data = all_ergm_classes_prepared_paper[[i]], selected_coefs = "nodematch.eth")
                                
                                plot_param_mcmc(res_m1, path_out = path_out)

                                res_m1

                              }

stopCluster(cl)


##### ANALYSIS FOR NATIVE HOMOPHILY #######
setwd("..")


# Save results 
ergm_results <- model1_list_paper %>% lapply(function(x) {x$ergm_mcmc <- "removed"; x})

save(ergm_results, file = "ergm_results.RData")


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


##############################################
# Data Analysis with weak inclusion criteria #
##############################################

dir.create("weak")
setwd("weak")


### Plotting outliers ###

# Coefficients
include_weak %>%
  ggplot(aes(x = classid, y = Estimate)) +
  geom_line(aes(group = 1)) +
  geom_hline(aes(yintercept = low), linetype = "dashed") +
  geom_hline(aes(yintercept = high), linetype = "dashed") +
  facet_wrap(name~., scales = "free", nrow = 8) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
        )

ggsave(filename = "01-inclusion-01-coefficients.jpg", width = 10, height = 8)


# Standard Errors
include_weak %>%
  ggplot(aes(x = classid, y = `Std. Error`)) +
  geom_line(aes(group = 1)) +
  geom_hline(yintercept =  3, linetype = "dashed") +
  facet_wrap(name~., scales = "free", nrow = 8) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
        )

ggsave(filename = "01-inclusion-02-stderror.jpg", width = 10, height = 8)


# MCMC Percentage
include_weak %>%
  ggplot(aes(x = classid, y = `MCMC %`)) +
  geom_line(aes(group = 1)) +
  geom_hline(yintercept =  10, linetype = "dashed") +
  facet_wrap(name~., scales = "free", nrow = 8) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
        )

ggsave(filename = "01-inclusion-03-mcmcerror.jpg", width = 10, height = 8)



### Running the data analysis ###

try(
  meta_analyses(
    classid_strict_list = index_weak, 
    ergm_results = ergm_results
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-01-analysis.txt", digits = 2, digits.extra = 0)
)

try(
  univariate_meta_regression(
    classid_strict_list = index_weak,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("herf", "I(herf^2)", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-02-regression-m1_.txt", digits = 2, digits.extra = 0)
)

try(
  univariate_meta_regression(
    classid_strict_list = index_weak,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("herf", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-03-regression-m1-linear.txt", digits = 2, digits.extra = 0)
)


try(
  univariate_meta_regression(
    classid_strict_list = index_weak,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat", "I(sh_nat^2)", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-04-regression-m2.txt", digits = 2, digits.extra = 0)
)


try(
  univariate_meta_regression(
    classid_strict_list = index_weak,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-05-regression-m2-linear.txt", digits = 2, digits.extra = 0)
)


### Plots of bivariate relations ###

classroom_data <- ergm_results[index_weak] %>% lapply(function(x) {x$classroom}) %>% bind_rows()

classroom_data %>%
  ggplot(aes(x = herf, y = coef_nodematch.eth, weight = 1 / sqrt(var_nodematch.eth))) +
  geom_point(aes(size = sqrt(1 / var_nodematch.eth))) +
  geom_smooth(formula = y~x, method = "lm", color = "black", fill = "black") +
  geom_smooth(formula = y~x + I(x^2), method = "lm", color = "red", fill = "red") + 
  geom_smooth(formula = y~x, method = "loess", color = "blue", fill = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_bw() + 
  theme(legend.position = "none") +
  labs(
    x = "Herfindahl index",
    y = "Ethnic homophily"
  )

ggsave(filename = "03-bivariate-01-herf-homophily.jpg", height = 6, width = 9)


classroom_data %>%
  ggplot(aes(x = sh_nat, y = coef_nodematch.eth, weight = 1 / sqrt(var_nodematch.eth))) +
  geom_point(aes(size = sqrt(1 / var_nodematch.eth))) +
  geom_smooth(formula = y~x, method = "lm", color = "black", fill = "black") +
  geom_smooth(formula = y~x + I(x^2), method = "lm", color = "red", fill = "red") + 
  geom_smooth(formula = y~x, method = "loess", color = "blue", fill = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_bw() + 
  theme(legend.position = "none") +
  labs(
    x = "Share native in class",
    y = "Ethnic homophily"
  )
 
ggsave(filename = "03-bivariate-02-nat-homophily.jpg", height = 6, width = 9)





################################################
# Data Analysis with strict inclusion criteria #
################################################

setwd("..")
dir.create("strict")
setwd("strict")


### Plotting outliers ###

# Coefficients
include_strict %>%
  ggplot(aes(x = classid, y = Estimate)) +
  geom_line(aes(group = 1)) +
  geom_hline(aes(yintercept = low), linetype = "dashed") +
  geom_hline(aes(yintercept = high), linetype = "dashed") +
  facet_wrap(name~., scales = "free", nrow = 8) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
        )

ggsave(filename = "01-inclusion-01-coefficients.jpg", width = 10, height = 8)


# Standard Errors
include_strict %>%
  ggplot(aes(x = classid, y = `Std. Error`)) +
  geom_line(aes(group = 1)) +
  geom_hline(yintercept =  3, linetype = "dashed") +
  facet_wrap(name~., scales = "free", nrow = 8) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
        )

ggsave(filename = "01-inclusion-02-stderror.jpg", width = 10, height = 8)


# MCMC Percentage
include_strict %>%
  ggplot(aes(x = classid, y = `MCMC %`)) +
  geom_line(aes(group = 1)) +
  geom_hline(yintercept =  10, linetype = "dashed") +
  facet_wrap(name~., scales = "free", nrow = 8) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
        )

ggsave(filename = "01-inclusion-03-mcmcerror.jpg", width = 10, height = 8)



### Running the data analysis ###

try(
  meta_analyses(
    classid_strict_list = index_strict, 
    ergm_results = ergm_results
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-01-analysis.txt", digits = 2, digits.extra = 0)
)

try(
  univariate_meta_regression(
    classid_strict_list = index_strict,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("herf", "I(herf^2)", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-02-regression-m1_.txt", digits = 2, digits.extra = 0)
)

try(
  univariate_meta_regression(
    classid_strict_list = index_strict,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("herf", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-03-regression-m1-linear.txt", digits = 2, digits.extra = 0)
)


try(
  univariate_meta_regression(
    classid_strict_list = index_strict,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat", "I(sh_nat^2)", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-04-regression-m2.txt", digits = 2, digits.extra = 0)
)


try(
  univariate_meta_regression(
    classid_strict_list = index_strict,
    ergm_results = ergm_results,
    outcome_name = "coef_nodematch.eth", 
    var_name = "var_nodematch.eth", 
    variable_names = c("sh_nat", "class_size", "mean_isei", "country_name")
  ) %>% data.frame() %>%
  stargazer(summary = FALSE, type = "html", out = "02-meta-05-regression-m2-linear.txt", digits = 2, digits.extra = 0)
)



### Plots of bivariate relations ###

classroom_data <- ergm_results[index_strict] %>% lapply(function(x) {x$classroom}) %>% bind_rows()

classroom_data %>%
  ggplot(aes(x = herf, y = coef_nodematch.eth, weight = 1 / sqrt(var_nodematch.eth))) +
  geom_point(aes(size = sqrt(1 / var_nodematch.eth))) +
  geom_smooth(formula = y~x, method = "lm", color = "black", fill = "black") +
  geom_smooth(formula = y~x + I(x^2), method = "lm", color = "red", fill = "red") + 
  geom_smooth(formula = y~x, method = "loess", color = "blue", fill = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_bw() + 
  theme(legend.position = "none") +
  labs(
    x = "Herfindahl index",
    y = "Ethnic homophily"
  )

ggsave(filename = "03-bivariate-01-herf-homophily.jpg", height = 6, width = 9)


classroom_data %>%
  ggplot(aes(x = sh_nat, y = coef_nodematch.eth, weight = 1 / sqrt(var_nodematch.eth))) +
  geom_point(aes(size = sqrt(1 / var_nodematch.eth))) +
  geom_smooth(formula = y~x, method = "lm", color = "black", fill = "black") +
  geom_smooth(formula = y~x + I(x^2), method = "lm", color = "red", fill = "red") + 
  geom_smooth(formula = y~x, method = "loess", color = "blue", fill = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_bw() + 
  theme(legend.position = "none") +
  labs(
    x = "Share native in class",
    y = "Ethnic homophily"
  )
 
ggsave(filename = "03-bivariate-02-nat-homophily.jpg", height = 6, width = 9)
