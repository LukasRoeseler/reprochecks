pkgs <- c("BayesFactor","psych","metafor","MASS","emmeans"); have <- rownames(installed.packages()); for (p in pkgs) cat(p, ifelse(p %in% have, "YES","no"), "\n")
