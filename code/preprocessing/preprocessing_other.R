library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(polite)
library(data.table)
library(rvest) # https://rvest.tidyverse.org/articles/rvest.html

setwd("/Users/lingchm/Dropbox (GaTech)/I-research/9_su/updates/1-policies")

##################
# Manually added policies 
##################

# prepare table schema 
table_master <- data.frame(state = character(),
                           citation_year = integer(),
                           effect_year = integer(),
                           effect_year2 = integer(),
                           #authority_year = integer(),
                           policy_type = character(),
                           policy_category_4 = character(),
                           policy_category_12 = character(),
                           description = character(),
                           citation = character(),
                           authority = character(),
                           age_group = character(),
                           level = character(),
                           multiple_policies = integer(),
                           organization = character())


table_master <- table_master %>% add_row(state = "NY", 
                                         citation_year = 2016,
                                         effect_year = 2009,
                                         effect_year2 = 2014,
                                         #authority_year = as.numeric(str_extract_all(table$Authority[j], "\\d{4}", simplify = T)), 
                                         policy_type = "Other",
                                         policy_category_4 = "Product Reformulation",
                                         policy_category_12 = "Product Reformulation",
                                         description = "the National Salt Reduction Initiative (NSRI). The NSRI is a nationwide partnership of more than 90 city and state health authorities and organizations coordinated by New York City since 2009. The NSRI’s goal is to cut excess salt in packaged and restaurant foods by 25 percent over five years through voluntary corporate commitments – an achievement that would reduce the nation’s sodium intake by 20 percent. https://www1.nyc.gov/office-of-the-mayor/news/058-13/mayor-bloomberg-deputy-mayor-gibbs-health-commissioner-farley-results-national",
                                         citation = "1. Curtis CJ, Clapp J, Niederman SA, Ng SW, Angell SY. US food industry progress during the National Salt Reduction Initiative: 2009–2014. AJPH. 2016 Oct;106(10):1815-9. The National Salt Reduction Initiative (NSRI) is a U.S.-based coalition initiated in 2009 aimed at “reducing population sodium intake by 20%, through a reduction in sodium in US packaged and restaurant foods by 25% by 2014”. The NSRI set target levels in 61 packaged food categories for 2012 and 2014. “In 2009, when the targets were established, no categories met NSRI 2012 or 2014 targets. In 2014, 16 (26%) categories met 2012 targets and 2 (3%) met 2014 targets.” By 2014, 45% of food products had achieved the 2012 targets. From 2009 to 2014, the sales-weighted mean sodium density declined significantly by 6.8%, with reductions seen in 43% of food categories. No change was reported in restaurant food.2. The initial phase of this effort, the National Salt Reduction Initiative, tracked nation-wide progress of sodium reduction in packaged and restaurant foods. Between 2009 and 2014, there was a 6.8% reduction in sodium levels in the U.S. food supply. -https://www1.nyc.gov/site/doh/health/health-topics/national-salt-sugar-reduction-initiative.page",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "national",
                                         organization = "restaurant",
                                         age_group = "other")

table_master <- table_master %>% add_row(state = "NY", 
                         citation_year = 2015,
                         effect_year = 2010,
                         effect_year2 = 2014,
                         policy_type = "Other",
                         policy_category_4 = "Institutional Procurement",
                         policy_category_12 = "Institutional Procurement",
                         description = "The New York City Health Department implemented the Healthy Hospital Food Initiative (HHFI) from 2010-2014, which included nutrient-based food procurement standards and standards for patient meals. A study comparing the nutritional composition of regular-diet patient meals in 8 hospitals before and after the initiative found that “Median sodium content decreased 19%, from 2,636mg to 2,149mg per day.” Additionally, fiber increased by 25%, the percentage of calories from fat decreased by 24% and from saturated fat by 21%, and daily dessert offerings decreased 92%. At follow-up, nutrition content across all hospital menus improved and either met or exceeded the minimum HHFI standards.",
                         citation = "Moran A, Lederer A, Curtis CJ. Use of nutrition standards to improve nutritional quality of hospital patient meals: findings from New York City’s Healthy Hospital Food Initiative. Journal of the Academy of Nutrition and Dietetics. 2015 Nov 1;115(11):1847-54.",
                         authority = NA,
                         multiple_policies = 0,
                         level = "city",
                         organization = "healthcare facilities",
                         age_group = "other")  

table_master <- table_master %>% add_row(state = "NY", 
                         citation_year = 2019,
                         effect_year = 2010,
                         effect_year2 = 2014,
                         policy_type = "Statute and Regulation",
                         policy_category_4 = "Nutrition Labeling",
                         policy_category_12 = "Nutrition Labeling - Mandatory",
                         description = "In 2015, the New York City Department of Health (DOH) implemented and enforced a regulation requiring warning labels on high sodium menu items (>2,300 mg/item) in chain restaurants. To create awareness for the regulation and foster restaurant compliance, the DOH held a press event with industry and mailed guidance to restaurants on how to meet the regulation requirements. They also rolled out a media campaign to educate the public about the warning icons in English and Spanish via print, television, and online media platforms. Days after the regulation went into effect, the National Restaurant Association filed a lawsuit to block its implementation. After an 18-month legal battle, the city won the lawsuit and enforcement began in 2016. The key steps for designing a high-sodium warning policy include designing the label, defining the sodium threshold above which consumers should be alerted, and determining which restaurants would be required to comply.",
                         citation = "Anekwe AV, Lent M, Kennelly MO, Angell SY. New York City's sodium warning regulation: from conception to enforcement. American journal of public health. 2019 Sep 1;109(9):1191-2.",
                         authority = NA,
                         multiple_policies = 0,
                         level = "local",
                         organization = "restaurant",
                         age_group = "other")  

table_master <- table_master %>% add_row(state = "NY", 
                         citation_year = 2011,
                         effect_year = 2011,
                         effect_year2 = NA,
                         policy_type = "Policy",
                         policy_category_4 = "Institutional Procurement",
                         policy_category_12 = "Institutional Procurement",
                         description = "Schenectady County Public Health Services, in collaboration with Cornell Cooperative Extension, plans to reduce the sodium content in seniors’ home-delivered meals and meals served at congregate meal sites by 30% over three years. Improvement: Sodium decreased almost 10% in one year across a five-week rotating menu. Nearly 109,000 senior home-delivered and congregate meals are prepared each year by staff at Glendale Nursing Home. ",
                         citation = "millionhearts.hhs.gov/files/PN_Schenectady.pdf",
                         # data_source = "millionhearts" TODO 
                         authority = NA,
                         multiple_policies = 0,
                         level = "local",
                         organization = "other",
                         age_group = "elder")  

# table_master <- table_master %>% add_row(state = NA, 
#                          citation_year = 2011,
#                          effect_year = 2011,
#                          effect_year2 = NA,
#                          policy_type = "Other",
#                          policy_category_4 = "Other",
#                          policy_category_12 = "Other",
#                          description = "the Department of Health and Human Services, with several key initial partners, launched Million Hearts, an initiative that aims to prevent one million heart attacks and strokes over the next five years. As one component of this initiative, the U.S. Food and Drug Administration (FDA) and the Food Safety and Inspection Service (FSIS) launched efforts to identify opportunities to reduce sodium in food in order to put more control into consumers' hands. Excess sodium is a contributory factor in the development of hypertension, which is a major risk factor for heart disease and stroke. ",
#                          citation = "https://www.ihs.gov/newsroom/pressreleases/2011pressreleases/newpublicprivatesectorinitiativeaimstoprevent1millionheartattacksandstrokesinfiveyears/",
#                          authority = NA,
#                          multiple_policies = 0,
#                          level = "national",
#                          organization = "other",
#                          age_group = "other") 


# https://healthyfoodpolicyproject.org/policy/new-york-city-n-y-24-rcny-%c2%a7-81-49-current-through-jan-8-2020
table_master <- table_master %>% add_row(state = "NY", 
                                         citation_year = 2015,
                                         effect_year = 2015, 
                                         effect_year2 = 2020,
                                         policy_type = "Policy",
                                         policy_category_4 = "Other",
                                         policy_category_12 = "Other",
                                         description = "This policy requires chain restaurants with 15 or more locations to provide high sodium content warning labels on menu boards for food items or combination meals containing more than or equal to 2300 milligrams (mg) of sodium." ,
                                         citation = "This policy is located in New York City, New York Rules, Title 24 - Department of Health and Mental Hygiene, New York City Health Code, Title IV - Environmental Sanitation, Part A - Food and Drugs, Article 81 - Food Preparation and Food Establishments, Section 81.49 - Sodium warning. History: Added City Record 9/16/2015, eff. 10/16/2015.",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "state",
                                         organization = "restaurant",
                                         age_group = "other") 

table_master <- table_master %>% add_row(state = "NY", 
                                         citation_year = 2014,
                                         effect_year = 2014, 
                                         effect_year2 = NA,
                                         policy_type = "Policy",
                                         policy_category_4 = "Institutional Procurement",
                                         policy_category_12 = "Institutional Procurement - Government Agencies",
                                         description = "This law sets healthy food standards for contracts for concession stands, cafeterias and vending machines on property owned by the County of Suffolk, except for restaurants at County golf courses where food and beverages are served by wait staff, the Suffolk County correctional facilities, the Long Island Ducks Stadium, the Vanderbilt Museum and at Suffolk County Community College campuses. It addresses specific categories of food that must be offered and places restrictions on calories and sodium for certain foods. Additionally, it requires posting of caloric information; and advertising healthy choices on vending machine promotional space.",
                                         citation = "This policy is located in New York City, New York Rules, Title 24 - Department of Health and Mental Hygiene, New York City Health Code, Title IV - Environmental Sanitation, Part A - Food and Drugs, Article 81 - Food Preparation and Food Establishments, Section 81.49 - Sodium warning. History: Added City Record 9/16/2015, eff. 10/16/2015.",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "county",
                                         organization = "public-owned or leased facilities",
                                         age_group = "other") 


table_master <- table_master %>% add_row(state = "NM", 
                                         citation_year = NA,
                                         effect_year = NA, 
                                         effect_year2 = 2017,
                                         policy_type = "Other",
                                         policy_category_4 = "Institutional Procurement",
                                         policy_category_12 = "Institutional Procurement - Government Agencies",
                                         description = "Requires all food and beverages in vending machines on city-owned or leased property, or on real property which is occupied by city employees during the day, to meet specified sodium and trans fat standards, and for all machines to provide calorie labeling information. Also requires 25% of food products to meet additional nutrition standards relating to calories, fat and sugar content; and 50% of beverages to meet calorie standards, with other guidelines for milk and juice.",
                                         citation = "Albuquerque, N.M., Admin. Instructions 3-15 (current through November 2017)",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "city",
                                         organization = "public-owned or leased facilities",
                                         age_group = "other") 


table_master <- table_master %>% add_row(state = "CA", 
                                         citation_year = 2006,
                                         effect_year = 2009, # 2009
                                         effect_year2 = 2018,
                                         policy_type = "Other",
                                         policy_category_4 = "Other",
                                         policy_category_12 = "Other",
                                         description = "Establishes nutrition standards for all food and beverages offered in county-contracted vending machines in county facilities and offices (unless exempted by the Board of Supervisors). Standards address fat, sodium, calories, trans fat, and added sugars.",
                                         citation = "Albuquerque, N.M., Admin. Instructions 3-15 (current through November 2017)",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "county",
                                         organization = "public-owned or leased facilities",
                                         age_group = "other") 

table_master <- table_master %>% add_row(state = "MO", 
                                         citation_year = NA,
                                         effect_year = 2014, # 2009
                                         effect_year2 = NA,
                                         policy_type = "Statute and Regulation", # resolution 
                                         policy_category_4 = "Other",
                                         policy_category_12 = "Other",
                                         description = "Adopts healthy vending guidelines for city-owned facilities. Guidelines require that 50% of food and beverages in each machine meet specific nutrition standards. Beverage standard focus on water and low- or no-calorie beverages; food nutrition standards address fat, trans fat, sodium, dietary fiber, and limit sugar. Standards also address pricing and placement.",
                                         citation = "Brentwood, Mo., Resolution 1019 (Oct. 20, 2014) ",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "county",
                                         organization = "public-owned or leased facilities",
                                         age_group = "other") 

table_master <- table_master %>% add_row(state = "MD", 
                                         citation_year = NA,
                                         effect_year = 2020, # 2009
                                         effect_year2 = 2021,
                                         policy_type = "Statute and Regulation", # statute 
                                         policy_category_4 = "Institutional Procurement",
                                         policy_category_12 = "Institutional Procurement",
                                         description = "This law requires food service facilities in the county that offer children's meals to offer with those meals a healthy default side option and--where a beverage is included as part of the meal--a healthy default beverage. They must also offer at least one meal that is a Healthy Children's Meal. The law specifies that its requirements are to be phased in over four years, with enforcement beginning in year five. Beverages permitted for the default healthy beverage option include unsweetened waters; 100% fruit juices served undiluted or mixed with water, with no added sweeteners in servings of no more than eight ounces; and dairy and non-dairy milks that are served in portions with no more than 130 calories. Healthy Childrens Meal are meals that contain not more than: 550 calories; 700 milligrams of sodium; 10 percent of calories from saturated fat; 15 grams of added sugars; and 0 grams of trans fat, and comprised of foods from certain specified categories (fruit, vegetable, low/non-fat dairy, meat/meat alternate, whole grains), including at least one 1/2 cup serving of non-fried fruits or vegetables. The healthy default side for childrens meals that are not a Healthy Childrens Meal must be the healthiest side option available as part of aHealthy Children's Meal (note: healthiest is not defined). The law also defines childrens meals, and expressly excludes a combination of food items that has been prepackaged by or at a facility other than the food service facility offering the prepackaged combination for purchase.",
                                         citation = "Prince George’s County, Md., Code of Ordinances §§ 12-215 to -218 (current through Nov. 2, 2021)",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "county",
                                         organization = "other",
                                         age_group = "child") 

table_master <- table_master %>% add_row(state = "MD", 
                                         citation_year = 2015,
                                         effect_year = 2015, # 2009
                                         effect_year2 = 2017,
                                         policy_type = "Other", 
                                         policy_category_4 = "Institutional Procurement",
                                         policy_category_12 = "Institutional Procurement",
                                         description = "Provides nutrition standards for packaged food and beverages served at youth-oriented County programs, and sold through vending machines on County property. (to be applied to 75% of packaged food and beverages offered in vending machines on County property).",
                                         citation = "Howard County, Md., Code § 12.1800 et seq. (current through Dec. 28, 2017)",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "county",
                                         organization = "public-owned or leased facilities",
                                         age_group = "youth") 

table_master <- table_master %>% add_row(state = "KS", 
                                         citation_year = NA,
                                         effect_year = 2016, # 2009
                                         effect_year2 = NA,
                                         policy_type = "Statute and Regulation", #resolution 
                                         policy_category_4 = "Institutional Procurement",
                                         policy_category_12 = "Institutional Procurement",
                                         description = "This resolution requires all vending machines, coolers, and other beverage retail equipment on county property to meet nutritional guidelines. ",
                                         citation = "Thomas County, Kan. Ordinance No. 2016-23 (2016)",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "county",
                                         organization = "public-owned or leased facilities",
                                         age_group = "other") 


table_master <- table_master %>% add_row(state = "NY", 
                                         citation_year = NA,
                                         effect_year = 2015, # 2009
                                         effect_year2 = 2017,
                                         policy_type = "Other", #resolution 
                                         policy_category_4 = "Institutional Procurement",
                                         policy_category_12 = "Institutional Procurement",
                                         description = "Directs the Mayor's Office to develop and adopt a Healthy Meetings and Special Events Policy, which will include healthy meeting guidelines so that when food is provided at activities and special events supported by or sponsored by the City, healthy food and beverage options must be included. The policy also will encourage physical activity, greener options, and support of local products. Requires all events, conferences, and meetings, including departmental meetings, to adhere to the Guidelines, and states that the City is joining the National Alliance for Nutrition and Activity Healthy Meeting Pledge, and encourages other City-related agencies to adopt healthy meeting guidelines.",
                                         citation = "Albany, N.Y., Code § 34-2 (current through May 15, 2017) ",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "city",
                                         organization = "public-owned or leased facilities",
                                         age_group = "other") 

table_master <- table_master %>% add_row(state = "CA", 
                                         citation_year = NA,
                                         effect_year = 2011, # 2009
                                         effect_year2 = 2019,
                                         policy_type = "Other", #resolution 
                                         policy_category_4 = "Other",
                                         policy_category_12 = "Other",
                                         description = "San Francisco's Healthy Food Incentive Ordinance allows incentive items (such as a toy) to be given away with the purchase of a meal, food, or beverage only if the meal/food/beverage meets specific nutrition standards.",
                                         citation = "San Francisco, Cal, Code § 471 (current through Sep. 11, 2019) ",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "city",
                                         organization = "public-owned or leased facilities",
                                         age_group = "other") 

table_master <- table_master %>% add_row(state = "MD", 
                                         citation_year = NA,
                                         effect_year = 2010, # 2009
                                         effect_year2 = 2019,
                                         policy_type = "Statute and Regulation", #Local Laws, Resolutions, Ordinances, 
                                         policy_category_4 = "Other",
                                         policy_category_12 = "Other",
                                         description = "This policy is located in Montgomery County, Maryland Code of Ordinances, Part II - Local Laws, Resolutions, Ordinances, Etc., Chapter 15 - Eating and Drinking Establishments. History: 2009 L.M.C., ch. 29, §§ 1, 2; 2010 L.M.C., ch. 40, § 1.",
                                         citation = "Montgomery County, Md., Code of Ordinances § 15-15A (current through Oct. 2, 2019) ",
                                         authority = NA,
                                         multiple_policies = 0,
                                         level = "county",
                                         organization = "restaurant",
                                         age_group = "other") 

####
# export to csv
fwrite(table_master, "manual_database.csv")


