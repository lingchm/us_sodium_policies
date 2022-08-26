####################################
# Combine policy data from different sources into a master database
# Author: Lingchao Mao
# Last modified: 8/24/2022
####################################

library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(polite)
library(data.table)
library(rvest) # https://rvest.tidyverse.org/articles/rvest.html
library(readxl)

setwd("/Users/lingchm/Documents/Github/us_sodium_policies")
source("code/policy/utils.R")


##### PREP

# load data
file = "data/policy/central_database_20220715-2.xlsx"
manual_database <- as.data.frame(read_excel(file, sheet = "manual_database"))
ncsl_database <- as.data.frame(read_excel(file, sheet = "ncsl_database"))
cspi_database <- as.data.frame(read_excel(file, sheet = "cspi_database"))
westlaw_database <- as.data.frame(read_excel(file, sheet = "Westlaw"))

# get columns that have been manually verified 
verified_cols <- c("state", "level", "effect_year", "end_year","citation_year",
                   "policy_type","policy_type_simple","citation",
                   "authority","category_nutrition_labeling",
                   "category_institutional_procurement", "category_nutrition_standards",
                   "category_product_reformulation","category_educational_campaign",
                   "category_other","age_children", "age_elderly", "data_source",
                   "description")
verified_cols_ncsl <- c(verified_cols, "category_mandatory", "category_voluntary",
                        "category_task_forces", "category_studies", 
                        "category_pricing", "category_incentives")

# special processing for NCSL 
all_database <- rbind(cspi_database[,verified_cols], 
                      manual_database[,verified_cols],
                      westlaw_database[,verified_cols])
# check missing
print("Missing data:")
colSums(is.na(all_database))
table(all_database$policy_type)
table(all_database$policy_type_simple)


##### POLICY DETAILS
df_details <- extractPolicyDetails(all_database$description)
all_database <- cbind(all_database, df_details)
ncsl_details <- extractPolicyDetails(ncsl_database$description) %>% select(details_suggarfat)
ncsl_temp <- ncsl_database[,verified_cols_ncsl] %>% 
  rename(details_voluntary="category_voluntary",details_mandatory="category_mandatory",
         details_taskforce="category_task_forces",details_studies="category_studies",
         details_farmerincentives="category_pricing",details_pricing="category_incentives")
ncsl_temp <- cbind(ncsl_temp, ncsl_details)
all_database <- rbind(all_database, ncsl_temp)

table(all_database$details_voluntary)
table(all_database$details_mandatory)
table(all_database$details_taskforce)
table(all_database$details_studies)
table(all_database$details_farmerincentives)
table(all_database$details_pricing)
table(all_database$details_suggarfat)

##### AGE
df_age <- extractAge(all_database$description)
rowSums(df_age)
table(df_age$age_elderly)
table(all_database$age_elderly)
table(df_age$age_children)
table(all_database$age_children)

# rerun age for all except westlaw
for (i in 1:nrow(all_database)){
  if (all_database[i,]$data_source != "Westlaw") {
    all_database[i,"age_elderly"] <- df_age[i, "age_elderly"]
    all_database[i,"age_children"] <- df_age[i, "age_children"]
  } 
}

all_database$age_toddler <- df_age$age_toddler
all_database$age_other <- df_age$age_other
all_database$veteran <- df_age$veteran

##### ORGANIZATION
df_organization <- extractOrganization(all_database$description)
all_database <- cbind(all_database, df_organization)

# check some
all_database %>% filter(org_public == 1) %>% select(description)
all_database %>% filter(org_other == 1) %>% select(description)
table(all_database$org_public)
table(all_database$org_school)


#### EXPORT 
colnames(all_database)
fwrite(all_database, "data/policy/central_database_cleaned_20220824.csv")

