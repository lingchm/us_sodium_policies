##################
# Create panel data
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
df_state <- fread("RShiny/data/df_state.csv")
df_state_year <- fread("RShiny/data/df_state_year.csv")


####################### boxplots #######################
title = paste("Relationship between state-level white race percentage \n and number of policies") # (N=",nrow(df_state),")", delim="")
plot(df_state$race_white_pct, df_state$number_policies)
boundaries <- boxplot(df_state$race_white_pct ~ df_state$number_policies_cat, 
                      main=title,
                      col="#69b3a2",
                      ylim=c(0.2, 1.1 ),
                      xlab="Total number of policies",
                      ylab="White race %")
nbGroup <- nlevels(as.factor(df_state$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.1,
  paste("n = ",table(df_state$number_policies_cat),sep="")  
)

title = paste("Relationship between state-level percentage of other race\n and number of policies") # (N=",nrow(df_state),")", delim="")
#plot(df_state$race_other_pct, df_state$number_policies)
boundaries <- boxplot(df_state$race_other_pct ~ df_state$number_policies_cat, 
                      main=title,
                      col="#69b3a2",
                      ylim=c(0., 0.25),
                      xlab="Total number of policies",
                      ylab="Other race %")
nbGroup <- nlevels(as.factor(df_state$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.1,
  paste("n = ",table(df_state$number_policies_cat),sep="")  
)


title = paste("Relationship between state-level percentage of black race\n and number of policies") # (N=",nrow(df_state),")", delim="")
#plot(df_state$race_other_pct, df_state$number_policies)
boundaries <- boxplot(df_state$race_black_pct ~ df_state$number_policies_cat, 
                      main=title,
                      col="#69b3a2",
                      ylim=c(0., 0.5),
                      xlab="Total number of policies",
                      ylab="Black race %")
nbGroup <- nlevels(as.factor(df_state$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.1,
  paste("n = ",table(df_state$number_policies_cat),sep="")  
)

title = paste("Relationship between state-level percentage of female sex\n and number of policies") # (N=",nrow(df_state),")", delim="")
#plot(df_state$race_other_pct, df_state$number_policies)
boundaries <- boxplot(df_state$sex_female_pct ~ df_state$number_policies_cat, 
                      main=title,
                      col="#69b3a2",
                      ylim=c(0.47, 0.55),
                      xlab="Total number of policies",
                      ylab="Female sex %")
nbGroup <- nlevels(as.factor(df_state$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.01,
  paste("n = ",table(df_state$number_policies_cat),sep="")  
)


title = paste("Relationship between state-level population\n and number of policies") # (N=",nrow(df_state),")", delim="")
#plot(df_state$race_other_pct, df_state$number_policies)
boundaries <- boxplot(df_state$total_population ~ df_state$number_policies_cat, 
                      main=title,
                      col="#69b3a2",
                      ylim=c(0., 4*1e7),
                      xlab="Total number of policies",
                      ylab="Total population")
nbGroup <- nlevels(as.factor(df_state$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.3*1e7,
  paste("n = ",table(df_state$number_policies_cat),sep="")  
)


####################### timeline plots #######################
library(plotly)
df_state_year$year <- as.Date(df_state_year$year)

p <- df_state_year %>% 
  filter(state=="CA" | state=="NC") %>%
  ggplot( aes(x=year, group=state, y=median_household_income)) +
  geom_area(fill="#69b3a2", alpha=0.5) +
  geom_line(color="#69b3a2") +
  xlim(c(1969, 2020)) + 
  ylab("total population") + theme_light() 
p <- ggplotly(p)

p


####################### Panel Regression ####################### 
library(foreign)
library(car)
library(gplots)
df_state_year <- df_state_year %>% 
  filter(state != "USA" & state != "NYC" & state != "KR") %>%
  filter(year >= 2000 & year < 2019)

unique(df_state_year$state)
unique(df_state_year$year)

coplot(number_efforts ~ year | state, type="l", data=df_state_year) # lines
coplot(number_efforts ~ year | state, type="b", data=df_state_year) # points and lines
coplot(total_population ~ year | state, type="l", data=df_state_year) # lines
scatterplot(total_population~year|state, boxplots=FALSE, 
            smooth=TRUE, reg.line=FALSE, data=df_state_year)

# analysis 
coplot(number_efforts ~ cvd_death_rate | race_other_pct*total_population, 
       type="p", data=df_state_year) # lines
coplot(number_efforts ~ cvd_incidence_rate | race_other_pct*total_population, 
       type="p", data=df_state_year) # lines

# fixed effects: heterogeneity across states
plotmeans(number_efforts ~ state, 
          n.label=FALSE, connect=FALSE, data=df_state_year,
          main="Heterogeneity across states (n=20)",
          ylab="average number of efforts per year")
# fixed effects: heterogeneity across years
plotmeans(number_efforts ~ year, 
          n.label=FALSE, connect=FALSE, data=df_state_year,
          main="Heterogeneity across years (n=51)",
          ylab="average number of efforts per state")
# fixed effects using state as dummy variable
fixed.dum <-lm(number_efforts ~ cvd_incidence_rate + factor(state)-1, 
               data=df_state_year)
summary(fixed.dum)
fixed.dum <-lm(number_efforts ~ cvd_death_rate + factor(state)-1, 
               data=df_state_year)
summary(fixed.dum)
fixed.dum <-lm(number_efforts_cat1 ~ median_household_income + factor(state)-1, 
               data=df_state_year)
summary(fixed.dum)
fixed.dum <-lm(number_efforts_cat1 ~ urbanicity_index + factor(state)-1, 
               data=df_state_year)
summary(fixed.dum)
fixed.dum <-lm(number_efforts_cat1 ~ race_other_pct + factor(state)-1, 
               data=df_state_year)
summary(fixed.dum)

fixed.dum <-lm(number_efforts_cat1 ~ age_children_pct + factor(state)-1, 
               data=df_state_year)
summary(fixed.dum)

phtest(fixed, random) # if p < 0.05 then use fixed effects



####################
START_YEAR = 2000
END_YEAR = 2020
STATES <- unique(df_policies$state)



  census_state_year <- census_state_year %>% 
  filter(state %in% c(state.abb, "NYC", "DC")) %>% 
  filter(year >= START_YEAR, year <= END_YEAR)
unique(census_state_year$state)
t <- census_state_year %>% group_by(state) %>% summarize(count=n())
t <- census_state_year %>% filter(state=="NYC")
t <- census_state_year %>% filter(state=="NY")
t <- census_state_year %>% filter(state=="WY")
52 * 21

df_policies <- df_policies %>% filter(level == "state")
df_policies <- df_policies %>% filter(effect_year_from >= 1)
df_policies <- df_policies %>% filter(effect_year_from >= START_YEAR,
                                      effect_year_from <= END_YEAR)
max(df_policies$effect_year_from)

# check state names 
unique(df_policies$state)

# group by state and year 
df_policies <- df_policies %>% mutate(number_WHO_categories = category_nutrition_labeling + category_institutional_procurement + category_product_reformulation + category_educational_campaign,
                                      level_local = ifelse(level %in% c("local", "county", "city"), 1, 0),
                                      level_state = ifelse(level == "state", 1, 0),
                                      type_law = ifelse(policy_type_simple == "Law", 1, 0),
                                      type_rule = ifelse(policy_type_simple == "Administrative Rule", 1, 0),
                                      type_exeorder = ifelse(policy_type_simple == "Executive Order", 1, 0))
table(df_policies$number_WHO_categories)
table(df_policies$type_exeorder)

policies_state_year <- df_policies %>% group_by(state, effect_year_from) %>%
  summarize(number_policies = n(),
            number_WHO_categories = ifelse(sum(category_nutrition_labeling) > 0, 1, 0) + 
              ifelse(sum(category_institutional_procurement) > 0, 1, 0) +
              ifelse(sum(category_product_reformulation) > 0, 1, 0) +
              ifelse(sum(category_educational_campaign) > 0, 1, 0) +
              ifelse(sum(category_institutional_procurement) > 0, 1, 0),
            number_state_level = sum(level_state),
            number_local_level = sum(level_local),
            number_laws = sum(type_law),
            number_admrules = sum(type_rule),
            number_exeorders = sum(type_exeorder),
            category_nutrition_labeling_count = sum(category_nutrition_labeling),
            category_institutional_procurement_count = sum(category_institutional_procurement),
            category_product_reformulation_count = sum(category_product_reformulation),
            category_educational_campaign_count = sum(category_educational_campaign),
            category_nutrition_standards_count = sum(category_nutrition_standards),
            category_other_count = sum(category_other),
            age_children_count = sum(age_children),
            age_elderly_count = sum(age_elderly),
            organization_school_count = sum(organization_school),
            organization_farmers_count = sum(organization_farmers),
            organization_groceries_count = sum(organization_groceries),
            organization_restaurant_count = sum(organization_restaurant),
            organization_healthcare_facilities_count = sum(organization_healthcare_facilities),
            organization_public_count = sum(organization_public),
            organization_army_count = sum(organization_army)
            )

# combine census and policies
policies_state_year <- policies_state_year %>% rename(year = effect_year_from)
all_state_year <- merge(census_state_year, policies_state_year, by=c("state", "year"), all.x=TRUE)
all_state_year <- merge(policies_state_year, census_state_year, by=c("state", "year"), all.x=TRUE)

# fill no policy ones with 0
colnames(all_state_year)
all_state_year <- all_state_year %>% mutate_at(c(12:ncol(all_state_year)), ~replace(., is.na(.), 0))

# no data
all_state_year %>% filter(is.na(total_population)) %>% select(state, year)
all_state_year %>% filter(state=="NY") %>% select(state, year, total_population)
all_state_year %>% filter(state=="NYC") %>% select(state, year, total_population)

fwrite(all_state_year, "data/panel_data_20220621.csv")

remove(census_state_year, df_policies, policies_state_year)

##################
# Age
##################

all_state_year <- fread("data/panel_data_20220621.csv")
all_state_year <- all_state_year %>% filter(state != "VI")

#### children 
all_state_year$age_children_countgt1 <- as.factor(all_state_year$age_children_count != 0)
all_state_year$age_elderly_countgt1 <- as.factor(as.numeric(all_state_year$age_elderly_count != 0))
table(all_state_year$age_children_countgt1)
table(all_state_year$age_children_count)
table(all_state_year$age_elderly_countgt1)

give.n <- function(x){
  return(c(y = mean(x), label = length(x)))
}

boundaries <- boxplot(all_state_year$age_children_pct ~ all_state_year$age_children_countgt1, col="#69b3a2",
                      ylim=c(0.17,0.37),
                      main="Comparison of children population % between \nstates with vs without children policies",
                      xlab="At least one policy for children",
                      ylab="state population children %")
nbGroup <- nlevels(all_state_year$age_children_countgt1)
text( 
  x=c(1:nbGroup), 
  y=boundaries$stats[nrow(boundaries$stats),] + 0.05, 
  paste("n = ",table(all_state_year$age_children_countgt1),sep="")  
)
min(all_state_year$age_children_pct)


# test
qqnorm(all_state_year$age_children_pct)
qqline(all_state_year$age_children_pct)
x <- all_state_year %>% filter(age_children_countgt1 == TRUE) %>% select(age_children_pct)
y <- all_state_year %>% filter(age_children_countgt1 == FALSE) %>% select(age_children_pct)
t.test(x, y, alternative = "greater", var.equal = TRUE)
res.ftest <- var.test(age_children_pct ~ age_children_countgt1, data = all_state_year)
res.ftest

#### elderly 
ggplot(all_state_year, aes(x=as.factor(age_elderly_countgt1), y=age_elderly_pct)) + 
  geom_boxplot() + ylab("state population elderly %") + xlab("At least one policy for elderly") +  
  ggtitle("Number of Policies by Type") + theme_light() +
  #stat_summary(fun.data = give.n, geom = "text") +
  geom_jitter(color="black", size=0.4, alpha=0.9) 

boundaries <- boxplot(all_state_year$age_elderly_pct ~ all_state_year$age_elderly_countgt1, col="#69b3a2",
                      ylim=c(0.05,0.23),
                      main="Comparison of children population % between \nstates with vs without elderly policies",
                      xlab="At least one policy for elderly",
                      ylab="state population children %")
nbGroup <- nlevels(all_state_year$age_elderly_countgt1)
text( 
  x=c(1:nbGroup), 
  y=boundaries$stats[nrow(boundaries$stats),] + 0.03, 
  paste("n = ",table(all_state_year$age_elderly_countgt1),sep="")  
)


##################
# What states have more policies?
##################

# total population 
all_state_year$number_policies_cat <- factor(ifelse(all_state_year$number_policies == 0, "0", 
                                             ifelse(all_state_year$number_policies == 1, "1",
                                                    ifelse(all_state_year$number_policies == 2, "2",
                                                           ">=3"))), levels=c("0","1","2",">=3"))

boundaries <- boxplot(all_state_year$total_population ~ all_state_year$number_policies_cat, col="#69b3a2",
                      ylim=c(0, max(all_state_year$total_population) + 10000000),
                      main="Relationship between state population \n and number of policies",
                      xlab="Number of policies",
                      ylab="State population")
nbGroup <- nlevels(as.factor(all_state_year$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= 45000000, #boundaries$stats[nrow(boundaries$stats),] + 
  paste("n = ",table(all_state_year$number_policies_cat),sep="")  
)


# race_white_pct
boundaries <- boxplot(all_state_year$race_white_pct ~ all_state_year$number_policies_cat, col="#69b3a2",
                      ylim=c(0.2, 1.1 ),
                      main="Relationship between state white race % \n and number of policies",
                      xlab="Number of policies",
                      ylab="White race %")
nbGroup <- nlevels(as.factor(all_state_year$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.1,
  paste("n = ",table(all_state_year$number_policies_cat),sep="")  
)

boundaries <- boxplot(all_state_year$race_black_pct ~ all_state_year$number_policies_cat, col="#69b3a2",
                      ylim=c(0, 0.7 ),
                      main="Relationship between state black race % \n and number of policies",
                      xlab="Number of policies",
                      ylab="Black race %")
nbGroup <- nlevels(as.factor(all_state_year$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.3,
  paste("n = ",table(all_state_year$number_policies_cat),sep="")  
)

boundaries <- boxplot(all_state_year$race_other_pct ~ all_state_year$number_policies_cat, col="#69b3a2",
                      ylim=c(0, 0.3 ),
                      main="Relationship between state other race % \n and number of policies",
                      xlab="Number of policies",
                      ylab="Other race %")
nbGroup <- nlevels(as.factor(all_state_year$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 0.15,
  paste("n = ",table(all_state_year$number_policies_cat),sep="")  
)

## median age
boundaries <- boxplot(all_state_year$age_mean ~ all_state_year$number_policies_cat, col="#69b3a2",
                      ylim=c(30, 45),
                      main="Relationship between state mean age \n and number of policies",
                      xlab="Number of policies",
                      ylab="State mean age")
nbGroup <- nlevels(as.factor(all_state_year$number_policies_cat))
text( 
  x=c(1:nbGroup), 
  y= boundaries$stats[nrow(boundaries$stats),] + 2,
  paste("n = ",table(all_state_year$number_policies_cat),sep="")  
)

## organization 

