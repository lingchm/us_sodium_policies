library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(polite)
library(data.table)
library(rvest) # https://rvest.tidyverse.org/articles/rvest.html

setwd("/Users/lingchm/Documents/Github/us_sodium_policy_dashboard")


##################
# Functions
##################

extractAge <- function(descriptions){
  categories <- c("toddler", "children", "elderly", "other") 
  age_group <- data.frame(c(1:length(categories))*0, row.names=categories)
  for (i in 1:length(descriptions)) {
    if (grepl("school", descriptions[i], ignore.case=TRUE))
    {
      age_group["children",] = 1
    }
    if (grepl("elder", descriptions[i], ignore.case=TRUE) | 
        grepl("older", descriptions[i], ignore.case=TRUE) | 
        grepl("senior", descriptions[i], ignore.case=TRUE))
    {
      age_group["elderly",] = 1
    }
    if (grepl("infant", descriptions[i], ignore.case=TRUE) | 
        grepl("toddler", descriptions[i], ignore.case=TRUE) )
    {
      age_group["children",] = 1
      age_group["toddler",] = 1
    }
    if (sum(age_group) == 0) {
      age_group["other",] = 1
    }
  }
  return(age_group)
}


extractOrganizations <- function(descriptions) {
  categories <- c("school", "farmers", "groceries", "army", "hospital", 
                  "restaurant", "vendingmachine", "public", "other") 
  organization <- data.frame(c(1:length(categories))*0,
                             row.names=categories)
  for (i in 1:length(descriptions)) {
    if (grepl("school", descriptions[i], ignore.case=TRUE))
    {
      organization["school",] = 1
    }
    if (grepl("farmer", descriptions[i], ignore.case=TRUE)) {
      organization["farmers",] = 1
    }  
    if (grepl("grocer", descriptions[i], ignore.case=TRUE)) {
      organization["groceries",] = 1
    } 
    if (grepl("army", descriptions[i], ignore.case=TRUE) | 
        grepl("veteran", descriptions[i], ignore.case=TRUE)) {
      organization["army",] = 1
    } 
    if (grepl("restaurant", descriptions[i], ignore.case=TRUE)) {
      organization["restaurant",] = 1
    } 
    if (grepl("hospital", descriptions[i], ignore.case=TRUE) | 
        grepl("health program", descriptions[i], ignore.case=TRUE)) {
      organization["hospital",] = 1
    } 
    if (grepl("vending machine", descriptions[i], ignore.case=TRUE)) {
      organization["vendingmachine",] = 1
    } 
    if (grepl("city-owned", descriptions[i], ignore.case=TRUE) | 
        grepl("city owned", descriptions[i], ignore.case=TRUE) | 
        grepl("city propert", descriptions[i], ignore.case=TRUE) |
        grepl("city funded", descriptions[i], ignore.case=TRUE) | 
        grepl("city facilit", descriptions[i], ignore.case=TRUE) |
        grepl("city contracted", descriptions[i], ignore.case=TRUE)  |
        grepl("city-sponsored", descriptions[i], ignore.case=TRUE) | 
        grepl("county-owned", descriptions[i], ignore.case=TRUE) | 
        grepl("county owned", descriptions[i], ignore.case=TRUE) |
        grepl("county funded", descriptions[i], ignore.case=TRUE) | 
        grepl("county facilit", descriptions[i], ignore.case=TRUE) | 
        grepl("county-contracted", descriptions[i], ignore.case=TRUE) |
        grepl("county property", descriptions[i], ignore.case=TRUE |
              grepl("public", descriptions[i], ignore.case=TRUE))) {
      organization["public",] = 1
    }  
  }
  if (sum(organization) == 0) {
    organization["other",] = 1
  }
  return(organization)
}


extractPolicyCategory <- function(descriptions){
  categories <- c("Institutional Procurement", 
                  "Educational Campaign", 
                  "Nutrition Labeling", 
                  "Nutrition Standards",
                  "Product Reformulation",
                  "other")
  policy_category_who <- data.frame(c(1:length(categories))*0, row.names=categories)
  for (i in 1:length(descriptions)) {
    if (grepl("Procurement", descriptions[i], ignore.case=TRUE))
    {
      policy_category_who["Institutional Procurement",] = 1
    }
    if (grepl("campaign", descriptions[i], ignore.case=TRUE) |
        grepl("Information Gathering", descriptions[i], ignore.case=TRUE) |
        grepl("educational", descriptions[i], ignore.case=TRUE))
    {
      policy_category_who["Educational Campaign",] = 1
    }
    if (grepl("labeling", descriptions[i], ignore.case=TRUE))
    {
      policy_category_who["Nutrition Labeling",] = 1
    }
    if (grepl("new standards", descriptions[i], ignore.case=TRUE)) # not good keyword
    {
      policy_category_who["Nutrition Standards",] = 1
    }
    if (grepl("reformulation", descriptions[i], ignore.case=TRUE))
    {
      policy_category_who["Product Reformulation",] = 1
    }
  }
  if (sum(policy_category_who) == 0) {
    policy_category_who["other",] = 1
  }
  return(policy_category_who)
}


extractPolicyCategoryDetailed <- function(descriptions){
  categories <- c("Voluntary",
                  "Mandatory",
                  "Task forces",
                  "Studies or reports", 
                  "Pricing Strategies",
                  "Farmer's Market Incentives")
  policy_category_detailed <- data.frame(c(1:length(categories))*0, row.names=categories)
  for (i in 1:length(descriptions)) {
    if (grepl("voluntary", descriptions[i], ignore.case=TRUE))
    {
      policy_category_detailed["Voluntary",] = 1
    }
    if (grepl("mandatory", descriptions[i], ignore.case=TRUE))
    {
      policy_category_detailed["Mandatory",] = 1
    }
    if (grepl("task force", descriptions[i], ignore.case=TRUE))
    {
      policy_category_detailed["Task forces",] = 1
    }
    if (grepl("studies", descriptions[i], ignore.case=TRUE)) # not good keyword
    {
      policy_category_detailed["Studies or reports",] = 1
    }
    if (grepl("pricing strateg", descriptions[i], ignore.case=TRUE))
    {
      policy_category_detailed["Pricing Strategies",] = 1
    }
    if (grepl("incentives", descriptions[i], ignore.case=TRUE) & 
        grepl("farmer", descriptions[i], ignore.case=TRUE))
    {
      policy_category_detailed["Farmer's Market Incentives",] = 1
    }
  }
  return(policy_category_detailed)
}


####


extractPolicyTypeSimple <- function(description){
  return(ifelse(description=="Regulations", "Law",
                ifelse(description=="Regulation", "Law",
                       ifelse(description=="Reguulation", "Law",
                              ifelse(description=="Statutes", "Law",
                                     ifelse(description=="Statute", "Law",
                                            ifelse(description=="Resolution", "Law",
                                                   ifelse(description=="Statutes and Regulation", "Law",
                                                          ifelse(description=="Statute and Regulations", "Law",
                                                                 ifelse(description=="Statutes and Regulations", "Law",
                                                                        ifelse(description=="Policies", "Administrative Rule", 
                                                                               ifelse(description=="Policy", "Administrative Rule", 
                                                                                      ifelse(description=="Executive", "Executive Order", 
                                                                                             ifelse(description=="Executive Order", "Executive Order", 
                                                                                                    "other"))))))))))))))
}

extractPolicyType <- function(description){
  return(ifelse(grepl("polic", description, ignore.case=TRUE), "Policy", 
                ifelse(grepl("executive order", description, ignore.case=TRUE), "Executive Order", 
                       ifelse(grepl("executive", description, ignore.case=TRUE), "Executive Order", 
                              ifelse(grepl("resolution", description, ignore.case=TRUE), "Resolution", 
                                     ifelse(grepl("statute", description, ignore.case=TRUE), "Statute", 
                                            ifelse(grepl("regulation", description, ignore.case=TRUE), "Regulation",
                                                   "other")))))))
}


##################
# NCSL data
##################
# scrap data from the NCSL website
url <- "https://www.ncsl.org/research/health/analysis-of-state-laws-related-to-dietary-sodium.aspx"
target <- bow(url,user_agent = "lingchm@gmail.com for UW research project", force = TRUE)
html <- scrape(target)

# a total of 51 tables
# first 11 tables are categorized into 11 categories
# the 40 tables are same information categorized into 40 states 
tables <- html %>% html_elements("table") %>% html_table()
length(tables)
table_names1 <- html %>% html_elements("h2") %>% html_text2()
table_names1 <- table_names1[3:13]
table_names2 <- html %>% html_elements("h3") %>% html_text2()
table_names2 <- table_names2[2:41]
table_names <- c(table_names1, table_names2)
table_names <- str_replace(table_names, "\r ", "")
table_names

# categories based on website order 
policy_category_12 <- c("Institutional Procurement - School", 
                        "Institutional Procurement - Government Agencies",
                        "Educational Campaign - School", 
                        "Nutrition Labeling - Mandatory", 
                        "Nutrition Labeling - Voluntary", 
                        "Efforts to Commend or Support Voluntary Sodium Reduction: Resolutions Encouraging Efforts",
                        "Efforts for Information Gathering through Studies or Reports",
                        "Efforts for Information Gathering through Task Forces",
                        "Efforts to Increase Access to Fruits and Vegetables: Farmer’s Markets and Grocery and Infrastructure Development Incentives",
                        "Pricing Strategies through Subsidies and Incentives",
                        "Other")

policy_category_4 <- c("Institutional Procurement", 
                       "Institutional Procurement",
                       "Educational Campaign", 
                       "Nutrition Labeling", 
                       "Nutrition Labeling", 
                       "Other","Other","Other","Other","Other","Other")

# prepare table schema 
table_master <- data.frame(state = character(),
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

# process data row by row
for (i in 1:length(table_names1)) { # for each table 
  table <- as.data.frame(tables[i])
  
  # for each row in table 
  for (j in 1:nrow(table)) { 
    # some rows have multiple policies, check number of policies based on \n
    n_laws = length(strsplit(table$Effective.Date[j], "\r\n", perl = TRUE)[[1]])
    
    # ensure the number of layws is correct by checking "1.", "2."...
    while ((length(str_extract_all(table$Effective.Date[j], paste(as.character(n_laws),". ",sep=""))[[1]]) == 0) & (n_laws > 1)){
      n_laws = n_laws - 1
      if (n_laws < 2) {
        break 
      }
    }
    
    # process single-policy row
    if (n_laws == 1){
      citation_date = str_extract_all(table$Citation[j], "\\d{4}\\)")[[1]] # with parenthesis 
      citation_year = as.numeric(str_extract_all(citation_date, "\\d{4}", simplify = T))
      effect_year_ = as.numeric(str_extract_all(table$Effective.Date[j], "\\d{4}", simplify = T))
      ending_year = ifelse(length(effect_year_) > 1, as.numeric(str_extract_all(effect_years[k], "\\d{4}", simplify = T))[2], NA)
      organization <- extractOrganizations(c(policy_category_12[i], table$Brief.Description[j], table$Citation[j], table$Type.of.Policy[j]))
      policy_type <- extractPolicyType(word(table$Type.of.Policy[j], 1))
      policy_category <- extractPolicyCategory(c(table$Type.of.Policy[j], policy_category_4[i], table$Brief.Description[j]))
      policy_category_detail <- extractPolicyCategoryDetailed(c(table$Type.of.Policy[j], policy_category_12[i],  table$Brief.Description[j]))
      age_group <- extractAge(c(table$Type.of.Policy[j], policy_category_4[i],  table$Brief.Description[j]))
      table_master <- table_master %>% add_row(
        state = table$State[j], 
        level = "state",
        effect_year_from =ifelse(length(effect_year_[1]) == 0, NA, effect_year_[1]),
        ending_year = ending_year,
        citation_year = ifelse(length(citation_year) == 0, NA, citation_year),
        policy_type = policy_type,
        policy_type_simple = extractPolicyTypeSimple(policy_type),
        description = table$Brief.Description[j],
        citation = table$Citation[j],
        authority = table$Authority[j],
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
        data_source = "NCSL",
        multiple_policies = 0
      )
    }
    else{
      citations = strsplit(table$Citation[j], "\r\n", perl = TRUE)[[1]]
      effect_years = strsplit(table$Effective.Date[j], "\r\n", perl = TRUE)[[1]]
      policy_type <- extractPolicyType(word(table$Type.of.Policy[j], 1))
      policy_category <- extractPolicyCategory(c(table$Type.of.Policy[j], policy_category_4[i], table$Brief.Description[j]))
      policy_category_detail <- extractPolicyCategoryDetailed(c(table$Type.of.Policy[j], policy_category_12[i],  table$Brief.Description[j]))
      age_group <- extractAge(c(table$Type.of.Policy[j], policy_category_4[i],  table$Brief.Description[j]))
      for (k in 1:n_laws) {
        citation_date = str_extract_all(citations[k], "\\d{4}\\)")[[1]] # with parenthesis 
        citation_year = as.numeric(str_extract_all(citation_date, "\\d{4}", simplify = T))
        effect_year_ = as.numeric(str_extract_all(effect_years[k], "\\d{4}", simplify = T))
        ending_year = ifelse(length(effect_year_) > 1, as.numeric(str_extract_all(effect_years[k], "\\d{4}", simplify = T))[2], NA)
        organization <- extractOrganizations(c(policy_category_12[i], table$Brief.Description[j], citations[k], table$Type.of.Policy[j]))
        table_master <- table_master %>% add_row(
          state = table$State[j], 
          level = "state",
          effect_year_from = ifelse(length(effect_year_[1]) == 0, NA, effect_year_[1]),
          ending_year = ending_year,
          citation_year = ifelse(length(citation_year) == 0, NA, citation_year),
          policy_type = policy_type,
          policy_type_simple = extractPolicyTypeSimple(policy_type),
          description = table$Brief.Description[j],
          citation = table$Citation[j],
          authority = table$Authority[j],
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
          data_source = "NCSL",
          multiple_policies = 1
        )
        
      }
    }
  }
}

# check columns with missing data
colnames(table_master)
sum(is.na(table_master$policy_type))
sum(is.na(table_master$state))
sum(is.na(table_master$effect_year_from))
table_master[which(is.na(table_master$effect_year_from)),]
sum(is.na(table_master$category_nutrition_labeling))
sum(is.na(table_master$citation_year))
table_master[which(is.na(table_master$citation_year)),]

table(table_master$category_educational_campaign)
table(table_master$category_institutional_procurement)
table(table_master$category_product_reformulation)
table(table_master$category_nutrition_labeling)
table(table_master$category_other)
table(table_master$category_task_forces)
table(table_master$category_pricing)

table(table_master$organization_school)
table(table_master$organization_farmers)
table(table_master$organization_groceries)
table(table_master$organization_restaurant)
table(table_master$organization_public)
table(table_master$organization_hospital)

fwrite(table_master, "data/ncsl_database_20220613.csv")
