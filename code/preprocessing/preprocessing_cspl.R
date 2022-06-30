library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(polite)
library(data.table)
library(rvest) # https://rvest.tidyverse.org/articles/rvest.html

setwd("/Users/lingchm/Dropbox (GaTech)/I-research/9_su/updates/1-policies")

##################
# PDF data converted to TXT
##################

# read in data
fileName <- "data/original/center for science in the public interest's sodiu mpolicy database.txt"
conn <- file(fileName, open="r")
linn <- readLines(conn)

# prepare table schema 
table_pdf <- data.frame(state = character(),
                        level = character(),
                        effect_year_from = integer(),
                        ending_year = integer(),
                        citation_year = integer(),
                        policy_type = character(),
                        policy_type_simple = character(), 
                        description = character(),
                        citation = character(),
                        authority = character(),
                        category_nutrition_labeling = integer(),
                        category_institutional_procurement = integer(),
                        category_nutrition_standards = integer(),
                        category_product_reformulation = integer(),
                        category_educational_campaign = integer(),
                        category_other = integer(),
                        category_voluntary = integer(),
                        category_mandatory = integer(),
                        category_task_forces = integer(),
                        category_studies = integer(),
                        category_pricing = integer(),
                        category_incentives = integer(),
                        age_children = integer(),
                        age_elderly = integer(),
                        organization_school = integer(),
                        organization_farmers = integer(),
                        organization_groceries = integer(),
                        organization_army = integer(),
                        organization_hospital = integer(),
                        organization_restaurant = integer(),
                        organization_vendingmachine = integer(),
                        organization_public = integer(),
                        data_source = character(),
                        multiple_policies = integer())

# loop through each bullet point for each policy 
level = "national"
for (i in 4:length(linn)){   # omit first three lines   #for (i in 1:length(linn)){
  
  # blank line or page number
  if (nchar(linn[i]) <= 2){
    next 
  }
  
  # bullet point line
  line = gsub("/f", "", trimws(linn[i]))
  if(grepl("•", linn[i], fixed = TRUE)){
    if(i > 5) {
      policy_type <- extractPolicyType(body)
      organization <- extractOrganizations(body)
      age_group <- extractAge(body)
      policy_category <- extractPolicyCategory(body)
      policy_category_detail <- extractPolicyCategoryDetailed(body)
      policy_type <- extractPolicyType(body)
      table_pdf <- table_pdf %>% add_row(
        state = state, 
        level = level,
        effect_year_from = as.numeric(stringr::str_extract(body, "\\d{4}")),# find first 4 digit number
        ending_year = NA,
        citation_year = NA,
        policy_type = policy_type,
        policy_type_simple = extractPolicyTypeSimple(policy_type),
        description = body,
        citation = citation,
        authority = NA,
        category_nutrition_labeling = policy_category["Nutrition Labeling",],
        category_institutional_procurement = policy_category["Institutional Procurement",],
        category_nutrition_standards = policy_category["Nutrition Standards",],
        category_product_reformulation = policy_category["Product Reformulation",],
        category_educational_campaign = policy_category["Educational Campaign",],
        category_other = policy_category[ "other",],
        category_voluntary = policy_category_detail["Voluntary",],
        category_mandatory = policy_category_detail["Mandatory",],
        category_task_forces = policy_category_detail["Task forces",],
        category_studies = policy_category_detail["Studies or reports",],
        category_pricing = policy_category_detail["Pricing Strategies",],
        category_incentives = policy_category_detail["Farmer's Market Incentives",],
        age_children = age_group["children",],
        age_elderly = age_group["elderly",],
        organization_school = organization["school",],
        organization_farmers = organization["farmers",],
        organization_groceries = organization["groceries",],
        organization_army = organization["army",],
        organization_hospital = organization["hospital",],
        organization_restaurant = organization["restaurant",],
        organization_vendingmachine = organization["vendingmachine",],
        organization_public = organization["public",],
        data_source = "CSPI",
        multiple_policies = 0
      )      
    }
    level = level_new
    state = ifelse(level == "national", NA, state_new)
    idx_start = unlist(gregexpr('•', line))[1]
    header = trimws(substr(line, idx_start + 1, nchar(line)))
    body = ""
    citation = ""
    state_ = substr(line, nchar(line) - 2, nchar(line))
    state = ifelse(state_ %in% state.abb, state_, state.abb[match(state,state.name)])
    
  } else if (line == "National Policies") {
    level_new = "national"
  } else if (line == "State and Local Policies") {
    level_new = "state"
  } else if (line == "Cities"){
    level_new = "city"
  } else if (line == "Counties"){
    level_new = "county"
  } else if (line %in% c(state.name, "District of Columbia")) {
    level_new = "state"
    state_new = line
  } else{
    body = paste(body, line)
    if (substr(line, 1, 8) == "https://") {
      citation = line
    }
  }
  
  print(paste(i, linn[i], nchar(linn[i])))
}
close(conn)

# post-processing
table(table_pdf$level)
table(table_pdf$age_children)
table(table_pdf$age_elderly)
table(table_pdf$organization_restaurant)

table(table_pdf$category_educational_campaign)
table(table_pdf$category_institutional_procurement)
table(table_pdf$category_product_reformulation)
table(table_pdf$category_nutrition_labeling)
table(table_pdf$category_other)
table(table_pdf$category_task_forces)
table(table_pdf$category_pricing)

table(table_pdf$organization_school)
table(table_pdf$organization_farmers)
table(table_pdf$organization_groceries)
table(table_pdf$organization_restaurant)
table(table_pdf$organization_public)
table(table_pdf$organization_hospital)

fwrite(table_pdf, "data/cspi_database_20220613.csv")


