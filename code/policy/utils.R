####################################
# Functions for policy data preprocessing
# Author: Lingchao Mao
# Last modified: 8/24/2022
####################################

extractAge <- function(descriptions){
  categories <- c("age_children", "age_elderly", "age_toddler", "age_other", "veteran") 
  df_age <- data.frame(matrix(0, ncol = length(categories), nrow = length(descriptions)))
  colnames(df_age) <- categories
  for (i in 1:length(descriptions)) {
    if (grepl("school", descriptions[i], ignore.case=TRUE) |
        grepl("child", descriptions[i], ignore.case=TRUE) |
        grepl("boy", descriptions[i], ignore.case=TRUE) |
        grepl("girl", descriptions[i], ignore.case=TRUE) |
        grepl("teenager", descriptions[i], ignore.case=TRUE) |
        grepl("youth", descriptions[i], ignore.case=TRUE) |
        grepl("adolescent", descriptions[i], ignore.case=TRUE))
    {
      df_age[i,"age_children"] = 1
    }
    if (grepl("elder", descriptions[i], ignore.case=TRUE) | 
        grepl("older", descriptions[i], ignore.case=TRUE) | 
        grepl("senior", descriptions[i], ignore.case=TRUE))
    {
      df_age[i,"age_elderly"] = 1
    }
    if (grepl("infant", descriptions[i], ignore.case=TRUE) | 
        grepl("toddler", descriptions[i], ignore.case=TRUE) )
    {
      df_age[i,"age_children"] = 1
      df_age[i,"age_toddler"] = 1
    }
    if (grepl("veteran", descriptions[i], ignore.case=TRUE) )
    {
      df_age[i,"veteran"] = 1
    }
    
    if (sum(df_age[i,]) == 0) {
      df_age[i,"age_other"] = 1
    }
  }
  return(df_age)
}


extractOrganization <- function(descriptions) {
  categories <- c("org_school", "org_farmers", "org_groceries", "org_army", "org_hospital", 
                  "org_restaurant", "org_vendingmachine", "org_public", "org_other") 
  df_organization <- data.frame(matrix(0, ncol = length(categories), nrow = length(descriptions)))
  colnames(df_organization) <- categories
  for (i in 1:length(descriptions)) {
    if (grepl("school", descriptions[i], ignore.case=TRUE))
    {
      df_organization[i,"org_school"] = 1
    }
    if (grepl("farmer", descriptions[i], ignore.case=TRUE)) {
      df_organization[i,"org_farmers"] = 1
    }  
    if (grepl("grocer", descriptions[i], ignore.case=TRUE)) {
      df_organization[i,"org_groceries"] = 1
    } 
    if (grepl("army", descriptions[i], ignore.case=TRUE) | 
        grepl("veteran", descriptions[i], ignore.case=TRUE)| 
        grepl("military", descriptions[i], ignore.case=TRUE)) {
      df_organization[i,"org_army"] = 1
    } 
    if (grepl("restaurant", descriptions[i], ignore.case=TRUE) |
        grepl("cafes", descriptions[i], ignore.case=TRUE) | 
        grepl("cafeteria", descriptions[i], ignore.case=TRUE)) {
      df_organization[i,"org_restaurant"] = 1
    } 
    if (grepl("hospital", descriptions[i], ignore.case=TRUE) | 
        grepl("health program", descriptions[i], ignore.case=TRUE) | 
        grepl("health facilit", descriptions[i], ignore.case=TRUE)  |  
        grepl("health care", descriptions[i], ignore.case=TRUE) |
        grepl("Medicaid", descriptions[i], ignore.case=TRUE) | 
        grepl("Medicare", descriptions[i], ignore.case=TRUE)) {
      df_organization[i,"org_hospital"] = 1
    } 
    if (grepl("vending machine", descriptions[i], ignore.case=TRUE)) {
      df_organization[i,"org_vendingmachine"] = 1
    } 
    if ((grepl("city", descriptions[i], ignore.case=TRUE) | 
        grepl("county", descriptions[i], ignore.case=TRUE) |
        grepl("public", descriptions[i], ignore.case=TRUE)) & 
        (grepl(" owned", descriptions[i], ignore.case=TRUE) | 
        grepl("propert", descriptions[i], ignore.case=TRUE) |
        grepl("funded", descriptions[i], ignore.case=TRUE) | 
        grepl("facilit", descriptions[i], ignore.case=TRUE) |
        grepl("contracted", descriptions[i], ignore.case=TRUE)  |
        grepl("sponsored", descriptions[i], ignore.case=TRUE) | 
        grepl("office building", descriptions[i], ignore.case=TRUE))) {
      df_organization[i,"org_public"] = 1
    }  
    if (rowSums(df_organization[i,]) < 1) {
    df_organization[i,"org_other"] = 1
    # adult day care facility, food facilities, urban gardens, corner stores 
    }}
  
  return(df_organization)
}


extractPolicyDetails <- function(descriptions){
  categories <- c("details_voluntary",
                  "details_mandatory",
                  "details_taskforce",
                  "details_studies", 
                  "details_pricing",
                  "details_farmerincentives",
                  "details_suggarfat")
  df_details <- data.frame(matrix(0, ncol = length(categories), nrow = length(descriptions)))
  colnames(df_details) <- categories
  
  for (i in 1:length(descriptions)) {
    if (grepl("voluntary", descriptions[i], ignore.case=TRUE))
    {
      df_details[i,"details_voluntary"] = 1
    }
    if (grepl("mandatory", descriptions[i], ignore.case=TRUE) |
        grepl("required", descriptions[i], ignore.case=TRUE) |
        grepl("enforced", descriptions[i], ignore.case=TRUE))
    {
      df_details[i,"details_mandatory"] = 1
    }
    if (grepl("task force", descriptions[i], ignore.case=TRUE))
    {
      df_details[i,"details_taskforce"] = 1
    }
    if (grepl("studies", descriptions[i], ignore.case=TRUE) |
        grepl("reports", descriptions[i], ignore.case=TRUE)) # not good keyword
    {
      df_details[i,"details_studies"] = 1
    }
    if (grepl("pricing strateg", descriptions[i], ignore.case=TRUE) |
        grepl("price", descriptions[i], ignore.case=TRUE))
    {
      df_details[i,"details_pricing"] = 1
    }
    if (grepl("incentive", descriptions[i], ignore.case=TRUE) & 
        grepl("farmer", descriptions[i], ignore.case=TRUE))
    {
      df_details[i,"details_farmerincentives"] = 1
    }
    if (grepl("suggar", descriptions[i], ignore.case=TRUE) | 
        grepl("fat", descriptions[i], ignore.case=TRUE))
    {
      df_details[i,"details_suggarfat"] = 1
    }
  }
  return(df_details)
}



### ARCHIVE - used manual labeling instead 
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

