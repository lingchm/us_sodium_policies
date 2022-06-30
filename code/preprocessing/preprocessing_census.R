library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(polite)
library(data.table)
library(rvest) # https://rvest.tidyverse.org/articles/rvest.html

setwd("/Users/lingchm/Documents/Github/us_sodium_policies")


##################
# Census US
##################

# read in data
filename <- "data/original/us.1969_2020.singleages.adjusted.txt" #61M
#filename <- "data/original/us.1969_2020.19ages.adjusted.txt" #15M
print(paste(round(file.info(filename)$size  / 2^30,3), 'gigabytes'))
linn2 <- fread(filename)
conn <- file(filename, open="r")
#linn <- readLines(conn)

table_all <- data.frame(year = integer(),
                        state = character(),
                        total_population = integer(),
                        age_mean = numeric(),
                        age_elderly_pct = numeric(),
                        age_children_pct = numeric(),
                        age_toddler_pct = numeric(),
                        sex_female_pct = numeric(),
                        race_white_pct = numeric(),
                        race_black_pct = numeric(),
                        race_other_pct = numeric()
                        )
# "KR" is used for the dummy state created to represent hurricane Katrina/Rita evacuees

prev_year = 1111
prev_state = "XX"

for (i in 1:length(linn)){ #length(linn)
  year = as.integer(substr(linn[i], 1, 4))
  state = substr(linn[i], 5, 6)
  state_FIPS = substr(linn[i],7,8)
  
  # construct a temporary state by year table 
  if (prev_year != year | prev_state != state) {
    
    # compact information and append to master table 
    if (i > 2){
      total_population = sum(table_state_year$population)
      table_state_year$mean_age_helper <- table_state_year$population * table_state_year$age
      age_elderly_pct <- (table_state_year %>% filter(age >= 65) %>% 
        summarize(total_population = sum(population) / total_population))[1,1]
      age_children_pct <- (table_state_year %>% filter(age <= 18) %>% 
        summarize(total_population = sum(population) / total_population))[1,1]
      age_toddler_pct <- (table_state_year %>% filter(age <= 3) %>% 
        summarize(total_population = sum(population) / total_population))[1,1]
      age_mean <- sum(table_state_year$mean_age_helper) / total_population
      sex_female_pct <- (table_state_year %>% filter(sex >= 2) %>% 
        summarize(total_population = sum(population) / total_population))[1,1]
      race_white_pct <- (table_state_year %>% filter(race == 1) %>% 
                       summarize(total_population = sum(population) / total_population))[1,1]
      race_black_pct <- (table_state_year %>% filter(race == 2) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      race_other_pct <- (table_state_year %>% filter(race >= 3) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      table_all <- table_all %>% add_row(year = prev_year,
                              state = prev_state,
                              total_population = total_population,
                              age_mean = age_mean,
                              age_elderly_pct = age_elderly_pct,
                              age_children_pct = age_children_pct,
                              age_toddler_pct = age_toddler_pct,
                              sex_female_pct = sex_female_pct,
                              race_white_pct = race_white_pct,
                              race_black_pct = race_black_pct,
                              race_other_pct = race_other_pct)
      fwrite(table_all, "datacensus_state_year_all.csv")
    }
    # create new table 
    fwrite(table_state_year, paste("datacensus_",state,"_",year,".csv",del=""))
    remove(table_state_year)
    table_state_year <- data.frame(race = integer(),
                                   age = integer(),
                                   sex = integer(), 
                                   population = integer())
    prev_year = year
    prev_state = state
    print(paste(year, state, i))
  }
  table_state_year <- table_state_year %>% add_row(
                                            race = as.integer(substr(linn[i],14,14)),
                                            age = as.integer(substr(linn[i],17,18)),
                                            sex = as.integer(substr(linn[i],16,16)), 
                                            population = as.integer(substr(linn[i],19,27)))

}

total_population = sum(table_state_year$population)
table_state_year$mean_age_helper <- table_state_year$population * table_state_year$age
age_elderly_pct <- (table_state_year %>% filter(age >= 65) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_children_pct <- (table_state_year %>% filter(age <= 18) %>% 
                       summarize(total_population = sum(population) / total_population))[1,1]
age_toddler_pct <- (table_state_year %>% filter(age <= 3) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_mean <- sum(table_state_year$mean_age_helper) / total_population
sex_female_pct <- (table_state_year %>% filter(sex >= 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_white_pct <- (table_state_year %>% filter(race == 1) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_black_pct <- (table_state_year %>% filter(race == 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_other_pct <- (table_state_year %>% filter(race >= 3) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
table_all <- table_all %>% add_row(year = prev_year,
                                   state = prev_state,
                                   total_population = total_population,
                                   age_mean = age_mean,
                                   age_elderly_pct = age_elderly_pct,
                                   age_children_pct = age_children_pct,
                                   age_toddler_pct = age_toddler_pct,
                                   sex_female_pct = sex_female_pct,
                                   race_white_pct = race_white_pct,
                                   race_black_pct = race_black_pct,
                                   race_other_pct = race_other_pct)


fwrite(table_all, "datacensus_state_year_all.csv")



##################
# Census NY
##################


"""
https://guides.newman.baruch.cuny.edu/nyc_data
    The Bronx is Bronx County (ANSI / FIPS 36005)
    Brooklyn is Kings County (ANSI / FIPS 36047)
    Manhattan is New York County (ANSI / FIPS 36061)
    Queens is Queens County (ANSI / FIPS 36081)
    Staten Island is Richmond County (ANSI / FIPS 36085)
"""


# read in data
filename <- "data/original/ny.1969_2020.singleages.txt" #61M
#filename <- "data/original/us.1969_2020.19ages.adjusted.txt" #15M
print(paste(round(file.info(filename)$size  / 2^30,3), 'gigabytes'))
#linn2 <- fread(filename)
conn <- file(filename, open="r")
linn <- readLines(conn)

table_all <- fread("data/datacensus_state_year_all.csv")


NY_county_FIPS = c("36005","36047","36061","36081","36085")

table_state_year <- data.frame(race = integer(),
                               age = integer(),
                               sex = integer(), 
                               population = integer())



prev_year = 1111
prev_state = "XX"

for (i in 1:length(linn)){ #length(linn)length(linn)
  year = as.integer(substr(linn[i], 1, 4))
  state = "NYC"
  state_FIPS = substr(linn[i],7,8)
  county_FIPS = substr(linn[i],7,11)
  
  # construct a temporary state by year table 
  if (prev_year != year) {
    
    # compact information and append to master table 
    if (i >= 2){
      total_population = sum(table_state_year$population)
      table_state_year$mean_age_helper <- table_state_year$population * table_state_year$age
      age_elderly_pct <- (table_state_year %>% filter(age >= 65) %>% 
                            summarize(total_population = sum(population) / total_population))[1,1]
      age_children_pct <- (table_state_year %>% filter(age <= 18) %>% 
                             summarize(total_population = sum(population) / total_population))[1,1]
      age_toddler_pct <- (table_state_year %>% filter(age <= 3) %>% 
                            summarize(total_population = sum(population) / total_population))[1,1]
      age_mean <- sum(table_state_year$mean_age_helper) / total_population
      sex_female_pct <- (table_state_year %>% filter(sex >= 2) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      race_white_pct <- (table_state_year %>% filter(race == 1) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      race_black_pct <- (table_state_year %>% filter(race == 2) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      race_other_pct <- (table_state_year %>% filter(race >= 3) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      table_all <- table_all %>% add_row(year = prev_year,
                                         state = prev_state,
                                         total_population = total_population,
                                         age_mean = age_mean,
                                         age_elderly_pct = age_elderly_pct,
                                         age_children_pct = age_children_pct,
                                         age_toddler_pct = age_toddler_pct,
                                         sex_female_pct = sex_female_pct,
                                         race_white_pct = race_white_pct,
                                         race_black_pct = race_black_pct,
                                         race_other_pct = race_other_pct)
      # fwrite(table_all, "datacensus_state_year_all.csv")
    }
    # create new table 
    # fwrite(table_state_year, paste("datacensus_",state,"_",year,".csv",del=""))
    remove(table_state_year)
    table_state_year <- data.frame(race = integer(),
                                   age = integer(),
                                   sex = integer(), 
                                   population = integer())
    prev_year = year
    prev_state = state
    print(paste(year, state, i, total_population))
  }
  if (county_FIPS %in% NY_county_FIPS) {
    table_state_year <- table_state_year %>% add_row(
      race = as.integer(substr(linn[i],14,14)),
      age = as.integer(substr(linn[i],17,18)),
      sex = as.integer(substr(linn[i],16,16)), 
      population = as.integer(substr(linn[i],19,27)))
    print(paste(year, county_FIPS, i))
  }
}

total_population = sum(table_state_year$population)
table_state_year$mean_age_helper <- table_state_year$population * table_state_year$age
age_elderly_pct <- (table_state_year %>% filter(age >= 65) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_children_pct <- (table_state_year %>% filter(age <= 18) %>% 
                       summarize(total_population = sum(population) / total_population))[1,1]
age_toddler_pct <- (table_state_year %>% filter(age <= 3) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_mean <- sum(table_state_year$mean_age_helper) / total_population
sex_female_pct <- (table_state_year %>% filter(sex >= 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_white_pct <- (table_state_year %>% filter(race == 1) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_black_pct <- (table_state_year %>% filter(race == 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_other_pct <- (table_state_year %>% filter(race >= 3) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
table_all <- table_all %>% add_row(year = prev_year,
                                   state = prev_state,
                                   total_population = total_population,
                                   age_mean = age_mean,
                                   age_elderly_pct = age_elderly_pct,
                                   age_children_pct = age_children_pct,
                                   age_toddler_pct = age_toddler_pct,
                                   sex_female_pct = sex_female_pct,
                                   race_white_pct = race_white_pct,
                                   race_black_pct = race_black_pct,
                                   race_other_pct = race_other_pct)




# GET 22020 DATA
table_state_year <- data.frame(race = integer(),
                               age = integer(),
                               sex = integer(), 
                               population = integer())
prev_year = 1111
prev_state = "XX"

length(linn) - length(linn) / (2020-1969)
for (i in 1:500000){ #length(linn)length(linn)
  year = as.integer(substr(linn[i], 1, 4))
  state = "NYC"
  state_FIPS = substr(linn[i],7,8)
  county_FIPS = substr(linn[i],7,11)
  
  # construct a temporary state by year table 
  if (prev_year != year) {
    
    # compact information and append to master table 
    if (i >= 2){
      total_population = sum(table_state_year$population)
      table_state_year$mean_age_helper <- table_state_year$population * table_state_year$age
      age_elderly_pct <- (table_state_year %>% filter(age >= 65) %>% 
                            summarize(total_population = sum(population) / total_population))[1,1]
      age_children_pct <- (table_state_year %>% filter(age <= 18) %>% 
                             summarize(total_population = sum(population) / total_population))[1,1]
      age_toddler_pct <- (table_state_year %>% filter(age <= 3) %>% 
                            summarize(total_population = sum(population) / total_population))[1,1]
      age_mean <- sum(table_state_year$mean_age_helper) / total_population
      sex_female_pct <- (table_state_year %>% filter(sex >= 2) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      race_white_pct <- (table_state_year %>% filter(race == 1) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      race_black_pct <- (table_state_year %>% filter(race == 2) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      race_other_pct <- (table_state_year %>% filter(race >= 3) %>% 
                           summarize(total_population = sum(population) / total_population))[1,1]
      table_all <- table_all %>% add_row(year = prev_year,
                                         state = prev_state,
                                         total_population = total_population,
                                         age_mean = age_mean,
                                         age_elderly_pct = age_elderly_pct,
                                         age_children_pct = age_children_pct,
                                         age_toddler_pct = age_toddler_pct,
                                         sex_female_pct = sex_female_pct,
                                         race_white_pct = race_white_pct,
                                         race_black_pct = race_black_pct,
                                         race_other_pct = race_other_pct)
      # fwrite(table_all, "datacensus_state_year_all.csv")
    }
    # create new table 
    # fwrite(table_state_year, paste("datacensus_",state,"_",year,".csv",del=""))
    remove(table_state_year)
    table_state_year <- data.frame(race = integer(),
                                   age = integer(),
                                   sex = integer(), 
                                   population = integer())
    prev_year = year
    prev_state = state
    print(paste(year, state, i, total_population))
  }
  if (county_FIPS %in% NY_county_FIPS) {
    table_state_year <- table_state_year %>% add_row(
      race = as.integer(substr(linn[i],14,14)),
      age = as.integer(substr(linn[i],17,18)),
      sex = as.integer(substr(linn[i],16,16)), 
      population = as.integer(substr(linn[i],19,27)))
    print(paste(year, county_FIPS, i))
  }
}

total_population = sum(table_state_year$population)
table_state_year$mean_age_helper <- table_state_year$population * table_state_year$age
age_elderly_pct <- (table_state_year %>% filter(age >= 65) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_children_pct <- (table_state_year %>% filter(age <= 18) %>% 
                       summarize(total_population = sum(population) / total_population))[1,1]
age_toddler_pct <- (table_state_year %>% filter(age <= 3) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_mean <- sum(table_state_year$mean_age_helper) / total_population
sex_female_pct <- (table_state_year %>% filter(sex >= 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_white_pct <- (table_state_year %>% filter(race == 1) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_black_pct <- (table_state_year %>% filter(race == 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_other_pct <- (table_state_year %>% filter(race >= 3) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
table_all <- table_all %>% add_row(year = prev_year,
                                   state = prev_state,
                                   total_population = total_population,
                                   age_mean = age_mean,
                                   age_elderly_pct = age_elderly_pct,
                                   age_children_pct = age_children_pct,
                                   age_toddler_pct = age_toddler_pct,
                                   sex_female_pct = sex_female_pct,
                                   race_white_pct = race_white_pct,
                                   race_black_pct = race_black_pct,
                                   race_other_pct = race_other_pct)


fwrite(table_all, "datacensus_state_year_all_wNYC.csv")

# note: data before 1980 is missing

table_all2 <- fread("data/datacensus_state_year_all.csv")
table_all2 %>% filter(state=="NY")




########## Other WY and NYC
table_state_year <- fread("data/census/datacensus_WY_2020.csv ")
total_population = sum(table_state_year$population)
table_state_year$mean_age_helper <- table_state_year$population * table_state_year$age
age_elderly_pct <- (table_state_year %>% filter(age >= 65) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_children_pct <- (table_state_year %>% filter(age <= 18) %>% 
                       summarize(total_population = sum(population) / total_population))[1,1]
age_toddler_pct <- (table_state_year %>% filter(age <= 3) %>% 
                      summarize(total_population = sum(population) / total_population))[1,1]
age_mean <- sum(table_state_year$mean_age_helper) / total_population
sex_female_pct <- (table_state_year %>% filter(sex >= 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_white_pct <- (table_state_year %>% filter(race == 1) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_black_pct <- (table_state_year %>% filter(race == 2) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
race_other_pct <- (table_state_year %>% filter(race >= 3) %>% 
                     summarize(total_population = sum(population) / total_population))[1,1]
table_all <- table_all %>% add_row(year = prev_year,
                                   state = prev_state,
                                   total_population = total_population,
                                   age_mean = age_mean,
                                   age_elderly_pct = age_elderly_pct,
                                   age_children_pct = age_children_pct,
                                   age_toddler_pct = age_toddler_pct,
                                   sex_female_pct = sex_female_pct,
                                   race_white_pct = race_white_pct,
                                   race_black_pct = race_black_pct,
                                   race_other_pct = race_other_pct)
