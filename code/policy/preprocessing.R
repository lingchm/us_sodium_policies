##################
# Preprocess other datasets
##################

library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(polite)
library(data.table)
library(rvest) # https://rvest.tidyverse.org/articles/rvest.html
library(readxl)


# load data
setwd("/Users/lingchm/Documents/Github/us_sodium_policies")
df_policies <- fread("data/policy/central_database_cleaned_20220824.csv")
df_census_state_year <- fread("data/census/datacensus_state_year_all.csv")
df_urbanicity <- fread('data/census/pop-urban-pct-historical.csv', header=TRUE) #USA yes
df_cvd <- fread("data/cvd/cvd_burden_1990-2019.csv") #USA yes
df_income <- fread("data/income/median_household_income_1984-2018.csv", header=TRUE)


##################
# urbanicity
##################

years <- colnames(df_urbanicity)[4:15]
df_urbanicity_new <- c()
for (year in years){
  temp <- df_urbanicity %>% select(state, year) %>% rename(`urbanicity_index`=year)
  temp$year <- year
  df_urbanicity_new <- rbind(df_urbanicity_new, temp)
}

fwrite(df_urbanicity_new, "data/preprocessed/df_urbanicity.csv")

##################
# income
##################
years <- colnames(df_income)[2:36]
df_income_new <- c()
for (year in years){
  temp <- df_income %>% select(state, year) %>% rename(`median_household_income`=year)
  temp$year <- year
  df_income_new <- rbind(df_income_new, temp)
}
df_income_new$median_household_income <- as.numeric(gsub(",", "", df_income_new$median_household_income))
fwrite(df_income_new, "data/preprocessed/df_income.csv")


##################
# census
##################

# mean age, gender pct, etc. 
unique(df_census_state_year$state)

df_census_state_year <- df_census_state_year %>% mutate(total_age = age_mean * total_population,
                                                        total_age_elderly = age_elderly_pct * total_population,
                                                        total_age_children = age_children_pct * total_population,
                                                        total_sex_female = sex_female_pct * total_population,
                                                        total_race_white = race_white_pct * total_population,
                                                        total_race_black = race_black_pct * total_population,
                                                        total_race_other = race_other_pct * total_population)

df_census_year <- df_census_state_year %>% filter(state!="NYC" & state!="KR") %>% 
  group_by(year) %>% summarize(total_population=sum(total_population),
                               age_mean=sum(total_age) / sum(total_population),
                               age_elderly_pct=sum(total_age_elderly) / sum(total_population),
                               age_children_pct=sum(total_age_children) / sum(total_population),
                               sex_female_pct=sum(total_sex_female) / sum(total_population),
                               race_white_pct=sum(total_race_white) / sum(total_population),
                               race_black_pct=sum(total_race_black) / sum(total_population),
                               race_other_pct=sum(total_race_other) / sum(total_population))

df_census_year$state <- "USA"
df_census_state_year <- rbind(df_census_state_year, df_census_year, fill=TRUE)
df_census_state_year <- df_census_state_year %>% select(-c(total_age,total_age_elderly,total_age_children,
                                                           total_sex_female,total_race_white,total_race_black,
                                                           total_race_other))
df_census_state_year %>% filter(state=="USA")

fwrite(df_census_state_year, "data/preprocessed/df_census.csv")

##################
# CVD
##################
fwrite(df_cvd, "data/preprocessed/df_cvd.csv")



##################
# merge at state level
##################
df_policies <- fread("data/policy/central_database_cleaned_20220824.csv")
df_census_state_year <- fread("data/preprocessed/df_census.csv")
df_urbanicity <- fread('data/preprocessed/df_urbanicity.csv') 
df_cvd <- fread("data/preprocessed/df_cvd.csv") 
df_income <- fread("data/preprocessed/df_income.csv")

unique(df_policies$state)
unique(df_census_state_year$state)
unique(df_urbanicity$state)
unique(df_cvd$state)
unique(df_income$state)

df_census_state_year <- df_census_state_year %>% filter(state != "NYC" & state != "KR")

df_census_state <- df_census_state_year %>% 
  filter(state %in% c(state.abb,"DC", "USA")) %>%  #NYC
  group_by(state) %>%
  summarise(total_population = mean(total_population),
            age_mean = mean(age_mean),
            age_elderly_pct = mean(age_elderly_pct),
            age_children_pct = mean(age_children_pct),
            sex_female_pct = mean(sex_female_pct),
            race_white_pct = mean(race_white_pct),
            race_black_pct = mean(race_black_pct),
            race_other_pct = mean(race_other_pct))

df_policy_state <- df_policies %>% 
  filter(level=="state")   %>% 
  group_by(state) %>%
  summarize(number_efforts = n(),
            number_efforts_children = sum(age_children),
            number_efforts_elderly = sum(age_elderly),
            number_efforts_educational_campaign = sum(category_educational_campaign),
            number_efforts_institutional_procurement = sum(category_institutional_procurement),
            number_efforts_nutrition_standards = sum(category_nutrition_standards),
            number_efforts_product_reformulation = sum(category_product_reformulation),
            number_efforts_school = sum(org_school))

df_urbanicity_state <- df_urbanicity %>% group_by(state) %>%
  summarize(urbanicity_index = mean(urbanicity_index))

df_cvd_state <- df_cvd %>% group_by(state) %>%
  summarize(cvd_death_rate = mean(CVD_death_Rate),
            cvd_incidence_rate = mean(CDV_incidence_rate)) 

df_income_state <- df_income %>% group_by(state) %>%
  summarize(median_household_income = mean(median_household_income)) 


df_state <- merge(df_census_state, df_urbanicity_state, by="state", all.x=TRUE)
df_state <- merge(df_state, df_cvd_state, by="state", all.x=TRUE)
df_state <- merge(df_state, df_policy_state, by="state", all.x=TRUE)
df_state <- merge(df_state, df_income_state, by="state", all.x=TRUE)
df_state[is.na(df_state)] <- 0

df_state$number_efforts_cat1 <- cut(df_state$number_efforts,
                                    breaks=c(-1,0,max(df_state$number_efforts)),
                                    labels=c('0', '1'))

df_state$number_efforts_cat5 <- cut(df_state$number_efforts,
                                    breaks=c(-1,0,1,2,3,4,max(df_state$number_efforts)),
                                    labels=c('0', '1', '2', '3','4','5 or more'))
df_state$number_efforts_cat3 <- cut(df_state$number_efforts,
                                    breaks=c(-1,0,1,2,max(df_state$number_efforts)),
                                    labels=c('0', '1', '2', '3 or more'))
df_state$number_efforts_children_cat <- cut(df_state$number_efforts_children,
                                            breaks=c(-1,0,max(df_state$number_efforts_children)),
                                            labels=c('0', '1 or more'))
df_state$number_efforts_elderly_cat <- cut(df_state$number_efforts_elderly,
                                           breaks=c(-1,0,max(df_state$number_efforts_elderly)),
                                           labels=c('0', '1 or more'))
table(df_state$number_efforts_cat1)
table(df_state$number_efforts_cat3)
table(df_state$number_efforts_cat5)
table(df_state$number_efforts)
fwrite(df_state, "RShiny/data/df_state.csv")



##################
# merge at state-year level
##################
df_policies <- fread("data/policy/central_database_cleaned_20220824.csv")
df_census_state_year <- fread("data/preprocessed/df_census.csv")
df_urbanicity <- fread('data/preprocessed/df_urbanicity.csv') 
df_cvd <- fread("data/preprocessed/df_cvd.csv") 
df_income <- fread("data/preprocessed/df_income.csv")

df_policies$state <- ifelse(df_policies$level == "national", "USA", df_policies$state)

df_policy_state_year <- df_policies %>% 
  #filter(level %in% c("national", "state")) %>% 
  group_by(state, effect_year) %>%
  summarize(number_efforts = n(),
            number_efforts_children = sum(age_children),
            number_efforts_elderly = sum(age_elderly),
            number_efforts_educational_campaign = sum(category_educational_campaign),
            number_efforts_institutional_procurement = sum(category_institutional_procurement),
            number_efforts_nutrition_standards = sum(category_nutrition_standards),
            number_efforts_product_reformulation = sum(category_product_reformulation),
            number_efforts_school = sum(org_school)) %>%
  rename(year = effect_year)

df_state_year <- merge(df_census_state_year, df_urbanicity, by=c("state","year"), all.x=TRUE)
df_state_year <- merge(df_state_year, df_cvd, by=c("state","year"), all.x=TRUE)
df_state_year <- merge(df_state_year, df_income, by=c("state","year"), all.x=TRUE)
df_state_year <- merge(df_state_year, df_policy_state_year, by=c("state","year"), all.x=TRUE)

df_state_year <- df_state_year %>%
  mutate(
    number_efforts = replace(number_efforts,is.na(number_efforts),0),
         number_efforts_children = replace(number_efforts_children,is.na(number_efforts_children),0),
         number_efforts_elderly = replace(number_efforts_elderly,is.na(number_efforts_elderly),0),
         number_efforts_educational_campaign = replace(number_efforts_educational_campaign,is.na(number_efforts_educational_campaign),0),
         number_efforts_institutional_procurement = replace(number_efforts_institutional_procurement,is.na(number_efforts_institutional_procurement),0),
         number_efforts_nutrition_standards = replace(number_efforts_nutrition_standards,is.na(number_efforts_nutrition_standards),0),
         number_efforts_product_reformulation = replace(number_efforts_product_reformulation,is.na(number_efforts_product_reformulation),0),
         number_efforts_school = replace(number_efforts_school,is.na(number_efforts_school),0))
df_state_year <- df_state_year %>%
  rename(cvd_death_rate = CVD_death_Rate,
         cvd_incidence_rate = CDV_incidence_rate)

df_state_year$number_efforts_cat1 <- cut(df_state_year$number_efforts,
                                    breaks=c(-1,0,max(df_state_year$number_efforts)),
                                    labels=c('0', '1'))

df_state_year$number_efforts_cat5 <- cut(df_state_year$number_efforts,
                                    breaks=c(-1,0,1,2,3,4,max(df_state_year$number_efforts)),
                                    labels=c('0', '1', '2', '3','4','5 or more'))
df_state_year$number_efforts_cat3 <- cut(df_state_year$number_efforts,
                                    breaks=c(-1,0,1,2,max(df_state_year$number_efforts)),
                                    labels=c('0', '1', '2', '3 or more'))
df_state_year$number_efforts_children_cat <- cut(df_state_year$number_efforts_children,
                                            breaks=c(-1,0,max(df_state_year$number_efforts_children)),
                                            labels=c('0', '1 or more'))
df_state_year$number_efforts_elderly_cat <- cut(df_state_year$number_efforts_elderly,
                                           breaks=c(-1,0,max(df_state_year$number_efforts_elderly)),
                                           labels=c('0', '1 or more'))

fwrite(df_state_year, "RShiny/data/df_state_year.csv")
